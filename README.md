# Pipelined RISC-V Processor

A complete implementation of a RISC-V processor, progressing from a single-cycle architecture to a fully pipelined design.

## Project Overview

This project implements a 32-bit RISC-V processor supporting the RV32I base integer instruction set. The development follows a milestone-based approach, starting with a fundamental single-cycle design and advancing to an optimized pipelined architecture.

## Milestones

### Milestone 1: Single-Cycle Implementation ✅

The single-cycle processor executes one instruction per clock cycle, with all stages completing sequentially within a single clock period.

#### Datapath

![Single-Cycle Datapath](./assets/SingleCycle_Datapath.png)

#### Architecture Components

**Instruction Fetch & Decode**
- **Program Counter (PC)**: 32-bit register maintaining current instruction address
- **Instruction Memory**: Read-only memory storing program instructions
- **Immediate Generator**: Extracts and sign-extends immediate values from instructions

**Execution**
- **Register File**: 32 general-purpose registers (x0-x31)
- **ALU (Arithmetic Logic Unit)**: Performs arithmetic and logical operations
- **ALU Control Unit**: Generates control signals based on instruction type and function codes
- **Shift Unit**: Handles logical/arithmetic shift operations

**Memory Access**
- **Data Memory**: Read/write memory for load/store operations
- **Branch Delegator**: Evaluates branch conditions (BEQ, BNE, BLT, BGE, BLTU, BGEU)

**Write Back**
- **Write Data Selector**: Multiplexes between ALU result, memory data, PC+4, AUIPC result, and LUI data

#### Control Signals

| Signal | Description |
|--------|-------------|
| `Branch` | Enables conditional branching |
| `MemRead` | Enables data memory read |
| `MemWrite` | Enables data memory write |
| `ALUSrc` | Selects between register or immediate for ALU |
| `RegWrite` | Enables register file write |
| `ALUOp[1:0]` | Determines ALU operation category |
| `PCsel[1:0]` | Selects next PC value (PC+4, branch, JAL, JALR) |
| `WDsel[2:0]` | Selects write-back data source |

#### Supported Instructions

**R-Type**: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU  
**I-Type**: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU, LW, JALR  
**S-Type**: SW  
**B-Type**: BEQ, BNE, BLT, BGE, BLTU, BGEU  
**U-Type**: LUI, AUIPC  
**J-Type**: JAL

#### Key Features

- Full RV32I base instruction set support
- Unified ALU with flag generation (Carry, Zero, Overflow, Sign)
- Flexible immediate handling for all instruction formats
- Comprehensive branch condition evaluation
- Multiple write-back data sources

#### Module Hierarchy

```
SingleCycle (Top Module)
├── PC (Program Counter Register)
├── InstMem (Instruction Memory)
├── ControlUnit (Main Control Unit)
├── ImmGen (Immediate Generator)
├── RegisterFile (32 Registers)
├── ALU (Arithmetic Logic Unit)
├── ALU_ControlUnit (ALU Control)
├── Shift_Left (Shift Unit)
├── DataMem (Data Memory)
├── BranchDelegator (Branch Logic)
├── PC_Selector (Next PC Multiplexer)
└── WriteData_Selector (Write-back Multiplexer)
```

### Milestone 2: Pipelined Implementation 🚧

*Coming Soon*

The pipelined implementation will introduce five pipeline stages with hazard detection and forwarding mechanisms for improved throughput.

#### Planned Pipeline Stages
1. **IF (Instruction Fetch)**
2. **ID (Instruction Decode)**
3. **EX (Execute)**
4. **MEM (Memory Access)**
5. **WB (Write Back)**

## Project Structure

```
Pipelined-RISC-V-Processor/
├── README.md
├── assets/
│   └── single-cycle-datapath.png
├── src/
│   ├── SingleCycle.v
│   ├── PC.v
│   ├── InstMem.v
│   ├── ControlUnit.v
│   ├── ImmGen.v
│   ├── RegisterFile.v
│   ├── ALU.v
│   ├── ALU_ControlUnit.v
│   ├── DataMem.v
│   ├── BranchDelegator.v
│   └── ... (other modules)
└── testbenches/
    └── ... (test files)
```

## Getting Started

### Prerequisites
- Xilinx Vivado (or compatible Verilog simulator)
- Basic understanding of RISC-V ISA
- Familiarity with digital design concepts

### Running the Design

1. Clone the repository
2. Open the project in Vivado
3. Add source files to your project
4. Run behavioral simulation or synthesize for FPGA deployment

## Design Specifications

- **Data Width**: 32 bits
- **Architecture**: RISC-V RV32I
- **Clock**: Single clock domain
- **Reset**: Synchronous active-high reset
- **Memory**: Separate instruction and data memories
- **Addressing**: Word-aligned (addresses divided by 4)

## Testing

The processor has been verified with various test programs including:
- Arithmetic operations
- Logical operations
- Load/Store instructions
- Branch conditions
- Jump instructions (JAL/JALR)
- Upper immediate instructions (LUI/AUIPC)

## Future Enhancements

- [ ] Complete pipelined implementation
- [ ] Hazard detection unit
- [ ] Data forwarding unit
- [ ] Branch prediction
- [ ] Cache implementation
- [ ] Extended instruction set support (M, A, F, D extensions)

## License

This project is developed for educational purposes.

## Contributors

*Add your name and contributions here*

---

**Note**: This is an ongoing educational project. Milestone 2 (pipelined implementation) is under development.