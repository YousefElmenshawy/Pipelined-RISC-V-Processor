# Pipelined RISC-V Processor

A complete implementation of a 5-stage pipelined 32-bit RISC-V processor supporting the RV32I base integer instruction set with comprehensive hardware hazard detection and resolution mechanisms.

## Project Overview

This project implements a fully pipelined RISC-V processor with hardware-based hazard handling. The processor features a classic 5-stage pipeline architecture with forwarding paths and stall logic to resolve data, control, and structural hazards efficiently.

## Datapath

![Pipelined Datapath](./Assets/PipelinedDatapath.png)

The above diagram illustrates the complete pipelined datapath showing all five pipeline stages (IF, ID, EX, MEM, WB), forwarding paths, hazard detection logic, and control signals.

## Pipeline Stages

The processor implements a classic 5-stage pipeline architecture:

### 1. IF (Instruction Fetch)
- **Program Counter (PC)**: Maintains current instruction address
- **Instruction Memory**: Fetches instruction from memory based on PC
- **IF/ID Pipeline Register**: Stores PC and fetched instruction for next stage
- **PC Update Logic**: Increments PC or updates based on branch/jump decisions

### 2. ID (Instruction Decode)
- **Register File Read**: Reads source registers (Rs1, Rs2) in parallel with decode
- **Immediate Generator**: Extracts and sign-extends immediate values
- **Control Unit**: Generates control signals from opcode and function fields
- **ID/EX Pipeline Register**: Stores decoded instruction, register values, immediates, and control signals

### 3. EX (Execute)
- **ALU**: Performs arithmetic/logic operations with forwarded or pipeline register data
- **ALU Control Unit**: Generates specific ALU operation from control signals
- **Branch Delegator**: Evaluates branch conditions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- **Address Calculation**: Computes branch targets, AUIPC results, and LUI operations
- **EX/MEM Pipeline Register**: Stores ALU results, branch decisions, and memory control signals

### 4. MEM (Memory Access)
- **Unified Memory**: Handles both instruction fetch and data memory access (single-ported)
- **Load Operations**: Reads data from memory (LW, LH, LHU, LB, LBU)
- **Store Operations**: Writes data to memory (SW, SH, SB)
- **MEM/WB Pipeline Register**: Stores memory read data and ALU results for write-back

### 5. WB (Write Back)
- **Write Data Selector**: Multiplexes between ALU result, memory data, PC+4, AUIPC result, and LUI data
- **Register File Write**: Writes selected data back to destination register

---

## Hazard Handling

The pipelined processor implements three types of hazard resolution mechanisms to maintain correct program execution while maximizing throughput.

### 1. Data Hazards (RAW - Read After Write)

**Problem**: A data hazard occurs when an instruction depends on the result of a previous instruction that hasn't completed yet.

**Example**:
```assembly
add x3, x2, x1   # x3 is computed in EX, available in EX/MEM
add x5, x3, x6   # x3 needed in EX stage - hazard!
```

**Solution: Forwarding Unit**

The Forwarding Unit (`ForwardingUnit.v`) detects and resolves RAW hazards by bypassing data from later pipeline stages directly to the ALU inputs, eliminating the need to wait for write-back.

**Implementation Details**:
- **Monitors**: Compares source registers (ID/EX Rs1, Rs2) against destination registers in later stages (EX/MEM Rd, MEM/WB Rd)
- **Forward from EX/MEM** (Priority 1): When EX/MEM stage has the required data
  - Condition: `EX_MEM_RegWrite && (EX_MEM_Rd != 0) && (EX_MEM_Rd == ID_EX_Rs1/Rs2)`
  - Action: Forward ALU result from EX/MEM register (`ForwardA/B = 2'b10`)
- **Forward from MEM/WB** (Priority 2): When MEM/WB stage has the required data
  - Condition: `MEM_WB_RegWrite && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs1/Rs2)`
  - Action: Forward write-back data from MEM/WB register (`ForwardA/B = 2'b01`)
- **No Forwarding**: When no hazard detected (`ForwardA/B = 2'b00`)

**Forwarding Paths**:
```
EX/MEM.ALU_Result ──→ Mux4 (MuxA/MuxB) ──→ ALU Input
MEM/WB.WriteData  ──→ Mux4 (MuxA/MuxB) ──→ ALU Input
```

**Benefits**: Resolves most data hazards with zero stall cycles, maintaining pipeline throughput.

---

### 2. Load-Use Hazards

**Problem**: A special case of data hazard where a load instruction is immediately followed by an instruction using the loaded data. The load data is not available until after the MEM stage, but the dependent instruction needs it in the EX stage—forwarding alone cannot resolve this.

**Example**:
```assembly
lw  x3, 0(x1)    # x3 available after MEM stage
add x5, x3, x6   # x3 needed in EX stage (one cycle too early!)
```

**Solution: Hazard Detection Unit - Load-Use Stall**

The Hazard Unit (`HazardUnit.v`) detects load-use hazards and stalls the pipeline for **one cycle** to allow the load data to become available for forwarding.

**Implementation Details**:
- **Detection Logic**:
  ```verilog
  if (((IF_ID_RS1 == ID_EX_Rd) || (IF_ID_RS2 == ID_EX_Rd)) 
      && ID_EX_MemRead 
      && (ID_EX_Rd != 0))
      stall = 1'b1;
  ```
- **Stall Actions**:
  - **Freeze PC**: Prevents fetching new instruction (`Register PC` enable = `~stall`)
  - **Freeze IF/ID**: Holds current instruction in decode stage (`IF/ID` enable = `~stall`)
  - **Insert Bubble**: Flushes ID/EX register with NOP control signals (via `Control_Mux`)

**Stall Cycle Behavior**:
1. **Cycle N**: Load instruction in EX, dependent instruction in ID
2. **Cycle N+1 (Stall)**: Load moves to MEM, bubble inserted in EX, dependent instruction held in ID
3. **Cycle N+2**: Load in WB, dependent instruction in EX with forwarding from MEM/WB

**Benefits**: Resolves load-use hazards with minimal penalty (1 cycle stall), then forwarding handles remaining dependency.

---

### 3. Structural Hazards (Memory Port Conflicts)

**Problem**: The processor uses a single-ported memory shared between instruction fetch (IF stage) and data access (MEM stage). When a memory operation (load/store) occurs in the MEM stage while IF stage attempts to fetch an instruction, a structural conflict arises.

**Example**:
```
Cycle N: 
  - IF stage: Fetching instruction at address 0x100
  - MEM stage: Load/Store accessing data memory (CONFLICT!)
```

**Solution: Hazard Detection Unit - Fetch Stall**

The Hazard Unit detects memory conflicts and temporarily stalls instruction fetching for **one cycle** to prioritize data memory access over instruction fetch.

**Implementation Details**:
- **Detection Logic**:
  ```verilog
  if (EX_MEM_MemRead || EX_MEM_MemWrite)
      fetchstall = 1'b1;
  ```
- **Memory Arbitration** (`Memory.v`):
  ```verilog
  MemAddr = (EX_MEM_MemRead | EX_MEM_MemWrite) ? 
            EX_MEM_ALU_out[7:0] :    // Data memory address
            PCOut[7:0];              // Instruction fetch address
  ```

**Stall Actions**:
- **Freeze PC**: Holds current PC value (`Register PC` enable = `~fetchstall`)
- **Freeze IF/ID**: Prevents corrupted instruction from entering pipeline (`IF/ID` enable = `~fetchstall`)
- **Prioritize Data Access**: Memory serves data request from MEM stage

**Fetch Stall Behavior**:
1. **Cycle N**: Memory instruction in MEM stage, IF attempts fetch
2. **Cycle N (Stall)**: Memory serves data request, PC and IF/ID frozen
3. **Cycle N+1**: Memory instruction completes, IF resumes normal fetch

**Benefits**: Ensures memory consistency with single-ported memory while minimizing performance impact (1 cycle stall per memory operation).

---

### Hazard Resolution Summary

| Hazard Type | Detection Unit | Resolution Mechanism | Stall Cycles | Implementation |
|-------------|---------------|---------------------|--------------|----------------|
| **Data (RAW)** | Forwarding Unit | Data bypassing from EX/MEM or MEM/WB | 0 | `ForwardingUnit.v` + `Mux4` |
| **Load-Use** | Hazard Unit | Pipeline stall + forwarding | 1 | `HazardUnit.v` (`stall` signal) |
| **Structural (Memory)** | Hazard Unit | Fetch stall + memory arbitration | 1 | `HazardUnit.v` (`fetchstall` signal) |

---

## Architecture Components

### Pipeline Registers
- **IF/ID**: Stores PC and fetched instruction (64-bit)
- **ID/EX**: Stores control signals, PC, register values, immediate, function codes, and register addresses (162-bit)
- **EX/MEM**: Stores control signals, ALU result, branch target, memory data, and write-back data (209-bit)
- **MEM/WB**: Stores control signals, memory output, ALU result, and write-back data (170-bit)

### Control & Hazard Units
- **Control Unit** (`ControlUnit.v`): Generates control signals from opcode
- **Hazard Detection Unit** (`HazardUnit.v`): Detects load-use and structural hazards, generates stall signals
- **Forwarding Unit** (`ForwardingUnit.v`): Detects data dependencies and controls forwarding paths

### Execution Units
- **Register File** (`RegisterFile.v`): 32 general-purpose registers (x0-x31), dual-read single-write ports
- **ALU** (`ALU.v`): Arithmetic and logic operations with flag generation (Carry, Zero, Overflow, Sign)
- **ALU Control Unit** (`ALU_ControlUnit.v`): Generates specific ALU operation from control signals
- **Branch Delegator** (`BranchDelegator.v`): Evaluates branch conditions based on flags

### Memory
- **Unified Memory** (`Memory.v`): Single-ported memory serving both instruction fetch and data access
- **Memory Arbitration**: Prioritizes data memory access (MEM stage) over instruction fetch (IF stage)

### Data Path Components
- **Immediate Generator** (`ImmGen.v`): Extracts and sign-extends immediates for all instruction formats
- **Shifters** (`Shifter.v`, `Shift_Left.v`, `ShifterTwelve.v`): Handle shift operations and immediate shifts
- **Multiplexers** (`Mux.v`, `Mux4.v`): Data path selection including forwarding muxes
- **PC Selector** (`PC_Selector.v`): Selects next PC (PC+4, branch target, JAL, JALR)
- **Write Data Selector** (`WriteData_Selector.v`): Selects write-back source

---

## Supported Instructions

**R-Type**: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU  
**I-Type**: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU, LW, LH, LHU, LB, LBU, JALR  
**S-Type**: SW, SH, SB  
**B-Type**: BEQ, BNE, BLT, BGE, BLTU, BGEU  
**U-Type**: LUI, AUIPC  
**J-Type**: JAL  
**SYS-Type**: ECALL, EBREAK, PAUSE, FENCE, FENCE.TSO

---

## Control Signals

| Signal | Width | Description |
|--------|-------|-------------|
| `Branch` | 1-bit | Enables conditional branching |
| `MemRead` | 1-bit | Enables data memory read |
| `MemWrite` | 1-bit | Enables data memory write |
| `ALUSrc` | 1-bit | Selects between register or immediate for ALU |
| `RegWrite` | 1-bit | Enables register file write |
| `ALUOp[1:0]` | 2-bit | Determines ALU operation category |
| `PCsel[1:0]` | 2-bit | Selects next PC value (PC+4, branch, JAL, JALR) |
| `WDsel[2:0]` | 3-bit | Selects write-back data source |
| `BreakSel` | 1-bit | Handles EBREAK/ECALL PC behavior |
| `ForwardA[1:0]` | 2-bit | Controls ALU input A forwarding |
| `ForwardB[1:0]` | 2-bit | Controls ALU input B forwarding |
| `stall` | 1-bit | Stalls pipeline for load-use hazard |
| `fetchstall` | 1-bit | Stalls fetch for memory structural hazard |

---

## Project Structure

```
Pipelined-RISC-V-Processor/
├── README.md
├── Assets/
│   ├── FullPipelined.drawio
│   └── PipelinedDatapath.png
├── Src/
│   ├── Pipelined.v               # Top-level pipelined processor module
│   ├── ALU.v                     # Arithmetic Logic Unit
│   ├── ALU_ControlUnit.v         # ALU control signal generator
│   ├── BranchDelegator.v         # Branch condition evaluator
│   ├── ControlUnit.v             # Main control unit
│   ├── ForwardingUnit.v          # Data forwarding logic
│   ├── HazardUnit.v              # Hazard detection and stall logic
│   ├── ImmGen.v                  # Immediate generator
│   ├── Memory.v                  # Unified instruction/data memory
│   ├── Mux.v                     # 2-to-1 multiplexer
│   ├── Mux4.v                    # 4-to-1 multiplexer (forwarding)
│   ├── PC_Selector.v             # Next PC selector
│   ├── Register.v                # Generic register module
│   ├── RegisterFile.v            # 32-register register file
│   ├── DFlipFlop.v               # D flip-flop primitive
│   ├── Shifter.v                 # Barrel shifter
│   ├── Shift_Left.v              # Left shift unit
│   ├── ShifterTwelve.v           # 12-bit left shifter (LUI)
│   ├── WriteData_Selector.v      # Write-back data selector
│   └── defines.v                 # Common definitions
├── TB/
│   └── Program_tb.v              # Testbench
└── RV32I_TestGen/
    ├── CMakeLists.txt
    ├── Generator.cpp
    ├── Generator.h
    ├── main.cpp
    ├── README.md
    ├── TestCases/
    │   ├── TC_R.txt
    │   ├── TC_I.txt
    │   ├── TC_S.txt
    │   ├── TC_U.txt
    │   ├── TC_B.txt
    │   ├── TC_Jal.txt
    │   ├── TC_Shifting.txt
    │   └── TC_Sum1to5.txt
    └── MemData/
        ├── Mem_R.txt
        ├── Mem_I.txt
        ├── Mem_S.txt
        ├── Mem_U.txt
        ├── Mem_B.txt
        ├── Mem_Jal.txt
        └── Mem_Sum1to5.txt
```

## Getting Started

### Prerequisites
- Xilinx Vivado (or compatible Verilog simulator)
- Basic understanding of RISC-V ISA and pipelining
- Familiarity with hazards and forwarding concepts

### Running the Design

1. Clone the repository
2. Open the project in Vivado
3. Add source files from `Src/` directory
4. Run behavioral simulation with test programs from `TB/`

## Design Specifications

- **Data Width**: 32 bits
- **Architecture**: RISC-V RV32I
- **Pipeline Stages**: 5 (IF, ID, EX, MEM, WB)
- **Hazard Handling**: Hardware forwarding and stalling
- **Memory**: Single-ported (instruction and data shared)
- **Clock**: Single clock domain
- **Reset**: Synchronous active-high reset

## Testing

The processor has been verified with various test programs including:
- Arithmetic operations (R-type)
- Logical operations
- Load/Store instructions with hazard handling
- Branch conditions
- Jump instructions (JAL/JALR)
- Upper immediate instructions (LUI/AUIPC)
- Data forwarding scenarios
- Load-use hazard cases
- Memory structural hazard scenarios

## Future Enhancements

- [ ] Branch prediction unit
- [ ] Cache implementation (I-cache and D-cache)
- [ ] Multi-ported memory
- [ ] Extended instruction sets (M, A, F, D extensions)
- [ ] Performance counters

## License

This project is developed for educational purposes.

## Contributors

- *Yousef Elmenshawy*
- *Kareem Rashed*

