
# 🚀 Pipelined RISC-V Processor (RV32I)

A fully functional **5-stage pipelined RISC-V processor** implementing the RV32I base integer instruction set, designed in **Verilog HDL** with comprehensive hazard detection and resolution mechanisms.

This project demonstrates advanced computer architecture concepts including pipelining, data forwarding, hazard detection, and control flow management. It features dual-source data forwarding, load-use hazard stalling, structural hazard arbitration, and includes a sophisticated C++ test program generator.

---

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Hazard Handling](#hazard-handling)
- [Supported Instructions](#supported-instructions)
- [Project Structure](#project-structure)
- [Test Generator](#test-generator)
- [Getting Started](#getting-started)
- [Technical Specifications](#technical-specifications)
- [Testing & Verification](#testing--verification)

---

## Overview

### Key Highlights
- **ISA**: RISC-V RV32I Base Integer Instruction Set (47 instructions)
- **Pipeline**: Classic 5-stage design (IF, ID, EX, MEM, WB)
- **Memory**: 512-byte unified byte-addressable memory (256B instructions, 256B data)
- **Registers**: 32 general-purpose 32-bit registers (x0-x31)
- **Hazard Resolution**: Hardware forwarding, load-use stalling, memory arbitration
- **Design**: Modular Verilog HDL with 20+ separate modules
- **Testing**: C++ test generator with comprehensive verification suite

### Datapath Diagram

![Pipelined Datapath](./Assets/PipelinedDatapath.png)

*Complete pipelined datapath showing all pipeline stages, forwarding paths, hazard detection logic, and control signals.*

---

## Architecture

### Pipeline Stages

The processor implements a classic 5-stage pipeline:

| Stage | Name | Function | Key Components |
|-------|------|----------|----------------|
| **IF** | Instruction Fetch | Fetch instruction from memory | PC, Instruction Memory, IF/ID Register |
| **ID** | Instruction Decode | Decode instruction and read registers | Register File, Control Unit, Immediate Generator, ID/EX Register |
| **EX** | Execute | Perform ALU operations and branch evaluation | ALU, ALU Control, Branch Delegator, Forwarding Muxes, EX/MEM Register |
| **MEM** | Memory Access | Load/store data memory operations | Unified Memory, MEM/WB Register |
| **WB** | Write Back | Write results to register file | Write Data Selector, Register File Write Port |

### Core Components

#### Control & Hazard Units
- **Control Unit** (`ControlUnit.v`): Decodes instructions and generates 13 control signals
- **Hazard Detection Unit** (`HazardUnit.v`): Detects load-use and structural hazards, generates stall signals
- **Forwarding Unit** (`ForwardingUnit.v`): Detects data dependencies and controls forwarding paths
- **ALU Control Unit** (`ALU_ControlUnit.v`): Generates specific ALU operation codes

#### Execution Units
- **ALU** (`ALU.v`): 13 operations with flag generation (Carry, Zero, Overflow, Sign)
- **Register File** (`RegisterFile.v`): 32×32-bit registers, dual-read single-write
- **Branch Delegator** (`BranchDelegator.v`): Evaluates all 6 branch conditions
- **Shifters**: Barrel shifter for variable shifts, fixed shifters for immediate offsets

#### Memory & Data Path
- **Unified Memory** (`Memory.v`): Single-ported 512-byte byte-addressable memory
- **Immediate Generator** (`ImmGen.v`): Extracts and sign-extends immediates for all formats
- **PC Selector** (`PC_Selector.v`): Selects next PC (PC+4, branch, JAL, JALR)
- **Write Data Selector** (`WriteData_Selector.v`): 5-input write-back multiplexer
- **Multiplexers** (`Mux.v`, `Mux4.v`): Data path selection and forwarding

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
- **Flush IF/ID**: Prevents corrupted instruction from entering pipeline (`IF/ID`  = `NOP`)
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


## Supported Instructions

The processor implements the complete RV32I base instruction set (47 instructions):

| Format | Category | Instructions |
|--------|----------|--------------|
| **R-Type** | Arithmetic/Logic/Shift | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| **I-Type** | Arithmetic/Logic | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| **I-Type** | Load | LW, LH, LHU, LB, LBU |
| **I-Type** | Jump | JALR |
| **S-Type** | Store | SW, SH, SB |
| **B-Type** | Branch | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| **U-Type** | Upper Immediate | LUI, AUIPC |
| **J-Type** | Jump | JAL |
| **SYS-Type** | System | ECALL, EBREAK, FENCE, FENCE.TSO, PAUSE |

---


## Project Structure

```
Pipelined-RISC-V-Processor/
├── README.md
├── Assets/
│   ├── FullPipelined.drawio      # Editable datapath diagram (Draw.io)
│   └── PipelinedDatapath.png     # Pipelined processor datapath visualization
│
├── Src/                          # Verilog HDL source files
│   ├── Pipelined.v               # Top-level pipelined processor module
│   ├── ALU.v                     # 32-bit Arithmetic Logic Unit (13 operations)
│   ├── ALU_ControlUnit.v         # ALU control signal decoder
│   ├── BranchDelegator.v         # Branch condition evaluator (BEQ, BNE, BLT, BGE, BLTU, BGEU)
│   ├── ControlUnit.v             # Main control unit (instruction decoder)
│   ├── defines.v                 # Global definitions, opcodes, and constants
│   ├── DFlipFlop.v               # D flip-flop building block
│   ├── ForwardingUnit.v          # EX/MEM and MEM/WB forwarding logic
│   ├── HazardUnit.v              # Load-use and structural hazard detection
│   ├── ImmGen.v                  # Immediate value extraction and sign-extension
│   ├── Memory.v                  # 512-byte unified byte-addressable memory
│   ├── Mux.v                     # Parameterized 2-to-1 multiplexer
│   ├── Mux4.v                    # 4-to-1 multiplexer (ALU input forwarding)
│   ├── PC_Selector.v             # Next PC selection logic (PC+4, branch, JAL, JALR)
│   ├── Register.v                # Generic N-bit register with load enable
│   ├── RegisterFile.v            # 32×32-bit register file (dual-read, single-write)
│   ├── Shifter.v                 # Barrel shifter (SLL, SRL, SRA)
│   ├── Shift_Left.v              # Single-bit left shifter (branch offset calculation)
│   ├── ShifterTwelve.v           # 12-bit left shifter (LUI/AUIPC upper immediate)
│   └── WriteData_Selector.v      # 5-input write-back data multiplexer
│
├── TB/
│   └── Program_tb.v              # Testbench for processor simulation
│
└── RV32I_TestGen/                # C++ test program generator
    ├── CMakeLists.txt            # CMake build configuration
    ├── main.cpp                  # CLI entry point with mode selection
    ├── Generator.h               # Generator class interface
    ├── Generator.cpp             # RV32I instruction generation logic
    ├── README.md                 # Generator documentation
    │
    ├── TestCases/
    │   ├── ByteAddressable/      # Byte-addressable memory test cases
    │   │   ├── TC_Fib.txt        # Fibonacci sequence program
    │   │   ├── TC_Sum1to5.txt    # Summation program
    │   │   ├── TC_SYS.txt        # System instruction tests
    │   │   ├── TC-B.txt          # Branch instruction tests
    │   │   ├── TC-I.txt          # I-type instruction tests
    │   │   ├── TC-J.txt          # JAL/JALR tests
    │   │   ├── TC-M.txt          # Mixed instruction tests
    │   │   ├── TC-R.txt          # R-type instruction tests
    │   │   ├── TC-S.txt          # Store instruction tests
    │   │   └── TC-U.txt          # U-type instruction tests
    │   └── WordAddressable/      # Word-addressable memory test cases
    │       ├── TC_Jal.txt
    │       └── TC_Shifting.txt
    │
    └── MemData/
        ├── ByteAddressable/      # Memory initialization files (binary format)
        │   ├── Mem_Fib.txt       # Fibonacci program memory image
        │   ├── Mem_Sum1to5.txt   # Summation program memory image
        │   ├── Mem_SYS.txt       # System instruction memory image
        │   ├── Mem-B.txt         # Branch tests memory image
        │   ├── Mem-I.txt         # I-type tests memory image
        │   ├── Mem-J.txt         # Jump tests memory image
        │   ├── Mem-M.txt         # Mixed tests memory image
        │   ├── Mem-R.txt         # R-type tests memory image
        │   ├── Mem-S.txt         # Store tests memory image
        │   └── Mem-U.txt         # U-type tests memory image
        └── WordAddressable/
            └── Mem_Jal.txt
```

---

## RV32I Test Program Generator

The project includes a sophisticated **C++ test program generator** (`RV32I_TestGen/`) that automatically creates RISC-V assembly programs and their corresponding memory initialization files for processor verification.

### Features

#### 🎯 Comprehensive Instruction Coverage
The generator supports **all RV32I base instruction formats** (47 instructions total - see [Supported Instructions](#supported-instructions) section).

#### 🎲 Generation Modes

1. **Single-Format Mode** - Generate test programs with instructions from one specific format (R, I, S, B, U, J, Y)
2. **Mixed-Format Mode** - Randomly generate instructions from all formats in a single test program


#### 📦 Output Formats

The generator produces two types of output files:

**Test Case Files** (`TestCases/ByteAddressable/TC-*.txt`):
- Byte-by-byte memory initialization with addresses
- Includes assembly comments for each instruction
- Format: `mem[addr] = 8'b[binary]; // [assembly]`
- Little-endian byte ordering

**Memory Data Files** (`MemData/ByteAddressable/Mem-*.txt`):
- Raw binary format ready for `$readmemb()` in Verilog
- One byte per line (8-bit binary)
- Direct memory loading into simulation

#### 🛠️ Smart Test Generation

The generator includes intelligent features for comprehensive testing:

- **Automatic Register Initialization**: Pre-loads registers with test values
- **Dependency Handling**: Ensures instructions have valid operands
- **Hazard Testing**: Creates data dependencies to test forwarding and stalling
- **Edge Case Coverage**: Tests signed/unsigned operations, boundary values, and special cases
- **System Instruction Termination**: Automatically appends system instructions to mark program end

#### 💻 Usage

**Command-Line Interface:**
```bash
# Generate specific format with custom instruction count
./RiscRandomProgramGenerator <MODE> <COUNT>


# Generate mixed instruction set
./RiscRandomProgramGenerator M 20

# Generate R-type only
./RiscRandomProgramGenerator R 10
```

**Interactive Mode:**
If no arguments provided, the generator enters interactive mode:
```
Enter MODE (R,I,S,B,U,J,M,ALL): R
Enter number of instructions: 10
```

**Valid Modes:**
- `R` - R-type arithmetic/logic instructions
- `I` - I-type immediate and load instructions
- `S` - Store instructions
- `B` - Branch instructions
- `U` - Upper immediate instructions (LUI, AUIPC)
- `J` - Jump instructions (JAL)
- `M` or `MIXED` - Mixed instruction formats
- `Y` or `SYS` - System instructions
- `ALL` - Generate all format test cases

#### 🏗️ Build Instructions

**Prerequisites:**
- CMake 3.30 or higher
- C++20 compatible compiler (GCC, Clang, MSVC)

**Build Steps:**
```bash
cd RV32I_TestGen
mkdir build && cd build
cmake ..
cmake --build .
```

**Windows:**
```cmd
cd RV32I_TestGen
mkdir build && cd build
cmake ..
cmake --build . --config Release
```

#### 📝 Example Output

**Test Case File (TC-R.txt):**
```verilog
mem[0] = 8'b00010011; // addi x2, x0, 2 [byte 1]
mem[1] = 8'b00000001; //  [byte 2]
mem[2] = 8'b00000000; //  [byte 3]
mem[3] = 8'b00000000; //  [byte 4]
mem[4] = 8'b10110011; // add x1, x2, x3 [byte 1]
mem[5] = 8'b00000000; //  [byte 2]
mem[6] = 8'b00110001; //  [byte 3]
mem[7] = 8'b00000000; //  [byte 4]
```

**Memory Data File (Mem-R.txt):**
```
00010011
00000001
00000000
00000000
10110011
00000000
00110001
00000000
```

#### 🎯 Pre-Generated Test Programs

The repository includes several hand-crafted test programs for specific scenarios:

- **`TC_Fib.txt` / `Mem_Fib.txt`**: Fibonacci sequence generator (tests loops, branches, ALU operations)
- **`TC_Sum1to5.txt` / `Mem_Sum1to5.txt`**: Summation program (tests accumulation and memory)
- **`TC-R.txt` / `Mem-R.txt`**: Complete R-type instruction test suite
- **`TC-I.txt` / `Mem-I.txt`**: I-type instructions including loads
- **`TC-S.txt` / `Mem-S.txt`**: Store instruction tests with different widths (SB, SH, SW)
- **`TC-B.txt` / `Mem-B.txt`**: All branch condition tests
- **`TC-J.txt` / `Mem-J.txt`**: Jump and link tests
- **`TC-U.txt` / `Mem-U.txt`**: Upper immediate tests (LUI, AUIPC)
- **`TC-M.txt` / `Mem-M.txt`**: Mixed instruction formats
- **`TC_SYS.txt` / `Mem_SYS.txt`**: System instruction tests

#### 🔬 Integration with Vivado

To use generated test programs in the processor simulation:

1. Generate test files using the generator
2. Copy desired `Mem-*.txt` file to project directory
3. Update `Memory.v` line 44 to load your test file:
   ```verilog
   $readmemb("Mem-R.txt", mem);  // Change filename as needed
   ```
4. Run behavioral simulation in Vivado
5. Observe register values, memory contents, and PC progression

---

## Getting Started

### Prerequisites
- **Xilinx Vivado** (2018.2 or later) or compatible Verilog simulator (ModelSim, Icarus Verilog)
- **Optional**: CMake 3.30+ and C++20 compiler for building the test generator

### Quick Start

**1. Clone the Repository**
```bash
git clone <repository-url>
cd Pipelined-RISC-V-Processor
```

**2. Open in Vivado**
- Launch Xilinx Vivado and create a new RTL project
- Add all source files from `Src/` directory (set `Pipelined.v` as top module)
- Add testbench from `TB/Program_tb.v` and set as top simulation module

**3. Load a Test Program**
- Choose a pre-generated memory file from `RV32I_TestGen/MemData/ByteAddressable/`
- Edit `Src/Memory.v` line 44 to load your test file:
  ```verilog
  $readmemb("Mem_Fib.txt", mem);  // Replace with desired test file
  ```

**4. Run Simulation**
- Click "Run Simulation" → "Run Behavioral Simulation" in Vivado
- Monitor key signals in waveform viewer:
  - `PCOut`: Program Counter progression
  - `IF_ID_Inst`: Fetched instructions
  - `stall`, `fetchstall`: Hazard detection signals
  - `ForwardA`, `ForwardB`: Forwarding control signals
  - `RF.RegFile`: Register file contents

### Pre-Generated Test Programs

| Test File | Description | Key Features Tested |
|-----------|-------------|---------------------|
| `Mem_Fib.txt` | Fibonacci sequence (14th number) | Loops, branches, ALU operations, forwarding |
| `Mem_Sum1to5.txt` | Sum of 1 to 5 | Accumulation, memory access |
| `Mem-R.txt` | All R-type instructions | ADD, SUB, AND, OR, XOR, shifts |
| `Mem-I.txt` | I-type and load instructions | ADDI, loads, load-use stalls |
| `Mem-S.txt` | Store instructions | SB, SH, SW with offsets |
| `Mem-B.txt` | Branch instructions | All 6 branch conditions |
| `Mem-J.txt` | Jump instructions | JAL, JALR with return address |
| `Mem-U.txt` | Upper immediate | LUI, AUIPC |
| `Mem-M.txt` | Mixed instruction set | Random mix of all types |
| `Mem_SYS.txt` | System instructions | ECALL, EBREAK, FENCE |

### Generating Custom Tests

```bash
# Build the generator (one-time setup)
cd RV32I_TestGen
mkdir build && cd build
cmake ..
cmake --build .

# Generate custom test
./RiscRandomProgramGenerator R 20      # 20 R-type instructions
./RiscRandomProgramGenerator MIXED 50  # 50 mixed instructions
```

---## Technical Specifications

### Core Architecture
- **ISA**: RISC-V RV32I Base Integer Instruction Set
- **Data Width**: 32 bits
- **Address Width**: 32 bits (8-bit used for memory addressing)
- **Pipeline Stages**: 5 (IF, ID, EX, MEM, WB)
- **Hazard Handling**: Hardware forwarding and stalling (see [Hazard Handling](#hazard-handling))

### Memory Organization
- **Memory Type**: Unified single-ported byte-addressable memory
- **Total Memory**: 512 bytes (4096 bits)
- **Instruction Memory**: Addresses 0-255 (256 bytes)
- **Data Memory**: Addresses 256-511 (256 bytes)
- **Memory Width**: 8-bit per address (byte-addressable)
- **Instruction Fetch**: 4-byte little-endian alignment
- **Load/Store Support**: Byte (LB/SB), halfword (LH/SH), word (LW/SW) with sign/zero extension

### Register File
- **Registers**: 32 general-purpose registers (x0-x31)
- **Register Width**: 32 bits each
- **x0 Behavior**: Hardwired to zero (writes ignored)
- **Read Ports**: 2 (dual-read)
- **Write Ports**: 1 (single-write)
- **Read Timing**: Combinational (data available same cycle)
- **Write Timing**: Positive edge-triggered

### ALU Specifications
- **Operations**: ADD, SUB, SLT, SLTU, AND, OR, XOR, SLL, SRL, SRA, PASS (13 total)
- **Flags**: Carry (CF), Zero (ZF), Overflow (VF), Sign (SF)
- **Operand Width**: 32 bits
- **Shift Range**: 0-31 bits

### Control Signals

| Signal | Width | Description |
|--------|-------|-------------|
| `Branch` | 1-bit | Enables conditional branching |
| `MemRead` / `MemWrite` | 1-bit | Memory access control |
| `ALUSrc` | 1-bit | ALU input B selection (register/immediate) |
| `RegWrite` | 1-bit | Register file write enable |
| `ALUOp[1:0]` | 2-bit | ALU operation category |
| `PCsel[1:0]` | 2-bit | Next PC selection (PC+4/branch/JAL/JALR) |
| `WDsel[2:0]` | 3-bit | Write-back source (ALU/Mem/PC+4/AUIPC/LUI) |
| `ForwardA/B[1:0]` | 2-bit | ALU input forwarding control |
| `stall` | 1-bit | Load-use hazard stall |
| `fetchstall` | 1-bit | Memory structural hazard stall |

### Pipeline Registers

| Register | Width | Key Contents |
|----------|-------|--------------|
| **IF/ID** | 64-bit | PC (32), Instruction (32) |
| **ID/EX** | 162-bit | Control signals, PC, Rs1/Rs2 data, Immediate, Function codes, Register addresses |
| **EX/MEM** | 241-bit | Control signals, Branch target, ALU result, Rs2 forwarded data, Rd, AUIPC/LUI data |
| **MEM/WB** | 170-bit | Control signals, Memory output, ALU result, Rd, PC, AUIPC/LUI data |

### Performance Characteristics
- **Ideal CPI**: 1 (one instruction per cycle without hazards)
- **Load-Use Hazard**: +1 cycle penalty
- **Memory Access**: +1 cycle penalty (fetch stall)
- **Taken Branch/Jump**: +2 cycles penalty (flush)
- **Data Forwarding**: 0 cycle penalty

---
## Testing & Verification

The processor has been extensively verified with comprehensive test programs covering all instruction types and hazard scenarios.

### Test Coverage

#### ✅ Instruction Type Coverage
All 47 RV32I instructions tested including:
- **R-type**: Arithmetic (ADD, SUB, SLT, SLTU), Logic (AND, OR, XOR), Shifts (SLL, SRL, SRA)
- **I-type**: Arithmetic, Logic, Shifts, Loads (LB, LH, LW, LBU, LHU), JALR
- **S-type**: Stores (SB, SH, SW)
- **B-type**: All 6 branch conditions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
- **U-type**: LUI, AUIPC
- **J-type**: JAL
- **SYS-type**: ECALL, EBREAK, FENCE, FENCE.TSO, PAUSE

#### ✅ Hazard Scenario Testing
- **Data Forwarding**: EX/MEM and MEM/WB forwarding, double forwarding, priority handling
- **Load-Use Hazards**: Stall insertion, bubble generation, PC/IF/ID freeze verification
- **Structural Hazards**: Fetch stall during loads/stores, memory arbitration
- **Control Hazards**: Branch/jump flush verification, PC update correctness

### Test Programs

| Test File | Description | Key Verification Points |
|-----------|-------------|------------------------|
| `Mem_Fib.txt` | Fibonacci sequence (14th number) | Loops, branches (BNE), arithmetic (ADD, ADDI), load-use hazards, data forwarding |
| `Mem_Sum1to5.txt` | Sum of 1 to 5 | Accumulation, loops, memory access |
| `Mem-R.txt` | All R-type instructions | Complete ALU operation coverage with forwarding |
| `Mem-I.txt` | I-type and load instructions | Immediate operations, load-use stalls |
| `Mem-S.txt` | Store instructions | SB, SH, SW with various offsets |
| `Mem-B.txt` | All branch types | Branch condition evaluation and flushing |
| `Mem-J.txt` | Jump instructions | JAL, JALR with return address handling |
| `Mem-U.txt` | Upper immediate | LUI, AUIPC with large immediate values |
| `Mem-M.txt` | Mixed instruction set | Random mix of all instruction types |
| `Mem_SYS.txt` | System instructions | ECALL, EBREAK, FENCE behavior |

### Verification Methodology
1. **Manual Assembly Testing**: Hand-crafted programs (Fibonacci, Sum) with known expected results
2. **Automated Generation**: C++ generator for comprehensive instruction coverage
3. **Waveform Analysis**: Visual verification of pipeline behavior and signal flow
4. **Register File Inspection**: Validation of final register values against expected results
5. **Memory Verification**: Confirming store operations write correct data
6. **Hazard Signal Tracking**: Verifying `stall`, `fetchstall`, `ForwardA/B` activate correctly

### Known Test Results
- **Fibonacci**: Successfully computes fib(14) = 377 in register x2
- **R-type**: All 10 operations execute correctly with proper forwarding
- **Load-Use**: Correctly inserts 1-cycle stall and forwards data on subsequent cycle
- **Branches**: All 6 conditions correctly evaluate and update PC
- **Memory**: Byte, halfword, word accesses with proper sign/zero extension

---

## Future Enhancements

- [ ] Branch prediction unit
- [ ] Cache implementation (I-cache and D-cache)
- [ ] Multi-ported memory
- [ ] Extended instruction sets (M, A, F, D extensions)
- [ ] Performance counters

---

## Contributors

- **Yousef Elmenshawy**
- **Kareem Rashed**

---

*This project is developed for educational purposes to demonstrate advanced computer architecture concepts.*
  - Branch taken flush (2-stage pipeline flush)
  - Jump instruction flush
  - PC update verification

### Test Programs
| Test File | Description | Tests Covered |
|-----------|-------------|---------------|
| `Mem_Fib.txt` | Fibonacci sequence (14th number) | Loops, branches (BNE), arithmetic (ADD, ADDI), load-use hazards, data forwarding |
| `Mem_Sum1to5.txt` | Sum of 1 to 5 | Loops, accumulation, memory access |
| `Mem-R.txt` | All R-type instructions | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU with forwarding |
| `Mem-I.txt` | I-type and load instructions | ADDI, ANDI, ORI, XORI, SLLI, SRLI, LB, LH, LW, LBU, LHU, load-use stalls |
| `Mem-S.txt` | Store instructions | SB, SH, SW with different immediate offsets |
| `Mem-B.txt` | All branch types | BEQ, BNE, BLT, BGE, BLTU, BGEU with control hazard flushing |
| `Mem-J.txt` | Jump instructions | JAL, JALR with return address save |
| `Mem-U.txt` | Upper immediate | LUI, AUIPC with large immediate values |
| `Mem-M.txt` | Mixed instruction set | Random mix of all instruction types |
| `Mem_SYS.txt` | System instructions | ECALL, EBREAK, FENCE, FENCE.TSO, PAUSE |

### Verification Methodology
1. **Manual Assembly Testing**: Hand-crafted test cases (Fibonacci, Sum) with known expected results
2. **Automated Generation**: C++ generator produces comprehensive instruction coverage
3. **Waveform Inspection**: Visual verification of pipeline behavior, hazard detection, and signal flow
4. **Register File Monitoring**: Checking final register values against expected computation results
5. **Memory Content Verification**: Validating store operations write correct data to memory
6. **Hazard Signal Tracking**: Confirming `stall`, `fetchstall`, `ForwardA`, `ForwardB` activate correctly

### Known Test Results
- **Fibonacci Test**: Successfully computes fib(14) = 377 in register x2
- **R-type Test**: All 10 R-type operations execute correctly with proper forwarding
- **Load-Use Test**: Correctly inserts 1-cycle stall and forwards data on subsequent cycle
- **Branch Test**: All 6 branch conditions correctly evaluate and update PC
- **Memory Test**: Byte, halfword, and word accesses with proper sign/zero extension

## Future Enhancements

- [ ] Branch prediction unit
- [ ] Cache implementation (I-cache and D-cache)
- [ ] Multi-ported memory
- [ ] Extended instruction sets (M, A, F, D extensions)
- [ ] Performance counters
- [ ] Cache implementation
- [ ] Extended instruction set support (M, A, F, D extensions)

## License

This project is developed for educational purposes.

## Contributors

- *Yousef Elmenshawy*
- *Kareem Rashed*

---

