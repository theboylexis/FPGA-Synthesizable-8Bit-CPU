# FPGA-Synthesizable 8-Bit CPU

<p align="center">
  <strong>
    A custom multi-cycle 8-bit processor designed in Verilog, verified end-to-end in simulation,
    and physically validated on the Sipeed Tang Nano 20K FPGA.
  </strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HDL-Verilog-111111?style=flat-square" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Datapath-8--bit-111111?style=flat-square" alt="8-bit Datapath"/>
  <img src="https://img.shields.io/badge/Instruction%20Width-16--bit-111111?style=flat-square" alt="16-bit Instructions"/>
  <img src="https://img.shields.io/badge/ISA-13%20Instructions-111111?style=flat-square" alt="13 Instruction ISA"/>
  <img src="https://img.shields.io/badge/Target-Tang%20Nano%2020K-111111?style=flat-square" alt="Tang Nano 20K"/>
</p>

---

## Overview

This project is a custom 8-bit CPU developed to extend concepts from digital systems design into a complete processor implementation.

The processor was designed from the RTL level upward in Verilog and includes a register file, arithmetic logic unit, Program Counter, program and data memory, Instruction Register, status register, instruction decoder, multi-cycle control unit, and writeback datapath.

The CPU uses a fixed-width 16-bit instruction format and a custom 13-instruction ISA. Each subsystem was verified independently before being integrated into the complete processor.

The full ISA was verified end-to-end in simulation using Icarus Verilog. The design was then synthesized, passed Place & Route, programmed onto a Sipeed Tang Nano 20K, and validated on physical hardware using arithmetic, memory/data-movement, and control-flow test programs.

---

## Architecture

| Component | Specification |
| --- | --- |
| Datapath | 8-bit |
| Instruction width | 16-bit |
| General-purpose registers | 8 × 8-bit |
| Register addressing | 3-bit |
| Program Counter | 8-bit |
| Instruction Register | 16-bit |
| Program memory | 256 × 16-bit |
| Data memory | 256 × 8-bit |
| Memory organization | Separate program and data memory |
| Status flags | Zero, Negative, Carry/Borrow |
| Execution model | Multi-cycle FSM |

### Processor Flow

At a high level, instructions move through the processor in the following path:

```text
          ┌─────────────────────┐
          │   Program Counter   │
          │        (PC)         │
          └──────────┬──────────┘
                     │ address
                     ▼
          ┌─────────────────────┐
          │   Program Memory    │
          └──────────┬──────────┘
                     │ 16-bit instruction
                     ▼
          ┌─────────────────────┐
          │ Instruction Register│
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │ Instruction Decoder │
          └──────┬────────┬─────┘
                 │        │
        operands │        │ opcode / fields
                 ▼        ▼
       ┌────────────────┐ ┌────────────────┐
       │ Register File  │ │  Control Unit  │
       └───────┬────────┘ └───────┬────────┘
               │                  │
               │ register data    │ control signals
               ▼                  │
       ┌────────────────┐         │
       │      ALU       │◄────────┘
       └───────┬────────┘
               │
        ┌──────┴─────────────┐
        │                    │
        ▼                    ▼
┌────────────────┐   ┌────────────────┐
│ Status Register│   │  Data Memory   │
│   Z, N, C      │   │  LOAD / STORE  │
└────────────────┘   └───────┬────────┘
                              │
                              ▼
                     ┌────────────────┐
                     │ Writeback MUX  │
                     └───────┬────────┘
                             │
                             ▼
                     ┌────────────────┐
                     │ Register File  │
                     └────────────────┘
```

The **Control Unit** coordinates the datapath rather than carrying instruction data itself. It uses the decoded opcode and current FSM state to generate control signals for the Program Counter, Instruction Register, ALU, register file, status register, data memory, and writeback multiplexer.

The main instruction cycle is:

```text
FETCH
  ↓
DECODE
  ↓
EXECUTE / MEMORY / WRITEBACK
  ↓
FETCH next instruction
```

The exact path depends on the instruction. For example:

```text
ADD   : FETCH → DECODE → EXECUTE → WRITEBACK → FETCH
LOAD  : FETCH → DECODE → MEMORY → WRITEBACK → FETCH
STORE : FETCH → DECODE → MEMORY → FETCH
CMP   : FETCH → DECODE → EXECUTE → FETCH
LDI   : FETCH → DECODE → WRITEBACK → FETCH
JMP   : FETCH → DECODE → EXECUTE → FETCH
HALT  : FETCH → DECODE → HALT
```

---

## Instruction Set Architecture

The processor uses 16-bit fixed-width instructions with 4-bit opcodes.

| Opcode | Instruction | Operation |
| --- | --- | --- |
| `0000` | HALT | Stop execution |
| `0001` | ADD | `Rd = Rs1 + Rs2` |
| `0010` | SUB | `Rd = Rs1 - Rs2` |
| `0011` | AND | `Rd = Rs1 AND Rs2` |
| `0100` | OR | `Rd = Rs1 OR Rs2` |
| `0101` | XOR | `Rd = Rs1 XOR Rs2` |
| `0110` | MOV | `Rd = Rs1` |
| `0111` | LOAD | `Rd = MEM[address]` |
| `1000` | STORE | `MEM[address] = Rs` |
| `1001` | CMP | Compare `Rs1` and `Rs2`, update flags |
| `1010` | JMP | `PC = address` |
| `1011` | BEQ | If `Z = 1`, `PC = address` |
| `1100` | LDI | `Rd = immediate` |
| `1101` | RESERVED | Reserved |
| `1110` | RESERVED | Reserved |
| `1111` | RESERVED | Reserved |

The ISA contains **13 assigned instructions and 3 reserved opcodes**.

### Instruction Formats

#### Register Type

Used by `ADD`, `SUB`, `AND`, `OR`, and `XOR`.

```text
opcode | Rd | Rs1 | Rs2 | reserved
  4      3     3     3       3
```

#### Immediate / Memory Type

Used by `LDI`, `LOAD`, and `STORE`.

```text
opcode | R | immediate/address | reserved
  4      3          8              1
```

#### Jump Type

Used by `JMP` and `BEQ`.

```text
opcode | address | reserved
  4        8         4
```

#### Compare Type

```text
opcode | Rs1 | Rs2 | reserved
  4       3     3        6
```

`CMP` performs a subtraction internally to update the status flags without writing the result to a general-purpose register.

---

## Design Highlights

### Register File

The processor contains eight writable 8-bit general-purpose registers with:

- two combinational read ports
- one synchronous write port
- 3-bit register addressing
- active-high synchronous reset

### ALU and Status Flags

The ALU supports:

```text
ADD
SUB
AND
OR
XOR
```

It produces three condition flags:

```text
Z = result is zero
N = most significant result bit
C = carry-out for ADD / borrow indication for SUB
```

For subtraction:

```text
C = 1 → borrow occurred
C = 0 → no borrow occurred
```

`ADD`, `SUB`, and `CMP` update the stored status flags. `BEQ` uses the stored Zero flag for conditional control flow.

### Multi-Cycle Control

The control unit is implemented as a finite-state machine with:

```text
FETCH
DECODE
EXECUTE
MEMORY
WRITEBACK
HALT
```

The FSM generates the control signals required for instruction loading, Program Counter updates, ALU selection, register writes, memory writes, flag updates, writeback selection, and halt behavior.

---

## Verification

Verification was performed at both module and processor level using Icarus Verilog.

Major RTL blocks were tested independently before CPU integration:

```text
Register File
ALU
Program Counter
Program Memory
Data Memory
Instruction Register
Status Register
Instruction Decoder
Control Unit
```

The integrated CPU was then tested using several machine-code programs.

### Arithmetic Test

```text
LDI R0, 5
LDI R1, 3
ADD R2, R0, R1
HALT
```

Expected final state:

```text
R0 = 5
R1 = 3
R2 = 8
```

### Memory / Data-Movement Test

Verified:

```text
LDI
SUB
MOV
STORE
LOAD
HALT
```

with the expected register and memory state.

### Logic / Control-Flow Test

Verified:

```text
AND
OR
XOR
CMP
BEQ taken
BEQ not taken
JMP
HALT
```

Branch and jump behavior was verified by confirming that instructions on skipped paths did not modify architectural state.

**Result: 13 / 13 assigned instructions verified end-to-end in simulation.**

---

## FPGA Implementation

The CPU was implemented on a **Sipeed Tang Nano 20K** using GOWIN EDA.

Completed FPGA work includes:

- full CPU synthesis
- Tang Nano 20K board-level top module
- 27 MHz onboard clock integration
- physical constraints for clock, pushbuttons, and LEDs
- successful Place & Route
- SRAM programming through the onboard debugger
- LED-based register inspection
- pushbutton synchronization and debounce logic for reliable register selection
- physical validation of multiple processor test programs

The FPGA wrapper exposes the lower six bits of a selected CPU register through the six onboard LEDs. A pushbutton is used to advance through registers, allowing the architectural state of the processor to be inspected directly on the board.

### Hardware Bring-Up

Before programming the CPU, a minimal LED-blink design was used to validate the FPGA programming path:

```text
Verilog
→ Synthesis
→ Place & Route
→ Configuration File
→ GOWIN Programmer
→ Tang Nano 20K
→ Physical LED Output
```

This confirmed the onboard 27 MHz clock, LED pin mapping, programmer connection, and FPGA configuration flow.

### Hardware Validation

Three end-to-end CPU programs were then validated on physical hardware.

#### Arithmetic

```text
LDI R0, 5
LDI R1, 3
ADD R2, R0, R1
HALT
```

Observed:

```text
R0 = 5
R1 = 3
R2 = 8
```

#### Memory / Data Movement

```text
LDI   R0, 10
LDI   R1, 6
SUB   R2, R0, R1
MOV   R3, R2
STORE R3, 0x20
LOAD  R4, 0x20
HALT
```

Observed:

```text
R0 = 10
R1 = 6
R2 = 4
R3 = 4
R4 = 4
```

The loaded value matched the value previously stored in data memory.

#### Logic / Control Flow

The hardware test exercised:

```text
AND
OR
XOR
CMP
BEQ taken
BEQ not taken
JMP
HALT
```

Observed final register state:

```text
R0 = 15
R1 = 51
R2 = 3
R3 = 63
R4 = 60
R5 = 85
R6 = 17
R7 = 0
```

The observed register state matched the expected simulation results, including the correct skipping of instructions during taken branches and jumps.

### FPGA Bring-Up Debugging

During hardware bring-up, the raw register-selection pushbutton produced unreliable stepping due to mechanical switch bounce.

The issue was isolated using dedicated button and clock test designs. The board I/O and 27 MHz clock were verified independently before synchronization and debounce logic were added to the FPGA wrapper.

After the fix, each physical button press advanced the debug register selector by exactly one register.

This provided a practical introduction to the difference between idealized simulation inputs and asynchronous mechanical inputs on physical hardware.

---

## Repository Structure

```text
FPGA-Synthesizable-8Bit-CPU/
├── rtl/
│   ├── alu/
│   ├── control/
│   ├── cpu/
│   ├── memory/
│   └── registers/
│
├── tb/
│   ├── alu/
│   ├── control/
│   ├── cpu/
│   ├── integration/
│   └── registers/
│
├── programs/
│   ├── examples/
│   └── tests/
│
├── docs/
│   ├── architecture/
│   ├── isa/
│   ├── verification/
│   └── development-log/
│
├── fpga/
│   ├── top/
│   ├── constraints/
│   ├── bringup/
│   ├── gowin/
│   └── build/
│
└── simulations/
```

---

## Tools

`Verilog` · `Icarus Verilog` · `GOWIN EDA` · `Git` · `VS Code` · `Sipeed Tang Nano 20K`

---

## Project Status

| Stage | Status |
| --- | --- |
| RTL design | ✅ Complete |
| Module verification | ✅ Complete |
| Full ISA verification | ✅ Complete |
| CPU integration | ✅ Complete |
| FPGA synthesis | ✅ Complete |
| Place & Route | ✅ Complete |
| FPGA programming | ✅ Complete |
| Physical FPGA validation | ✅ Complete |

---

## Author

**Alex Marfo Appiah**  
Computer Engineering  
Kwame Nkrumah University of Science and Technology (KNUST)