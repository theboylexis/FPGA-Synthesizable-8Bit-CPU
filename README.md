# FPGA-Synthesizable 8-Bit CPU

<p align="center">
  <strong>A custom 8-bit processor designed from scratch in Verilog, verified in simulation, and built toward deployment on the Sipeed Tang Nano 20K FPGA.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HDL-Verilog-111111?style=flat-square" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Datapath-8--bit-111111?style=flat-square" alt="8-bit Datapath"/>
  <img src="https://img.shields.io/badge/Instruction%20Width-16--bit-111111?style=flat-square" alt="16-bit Instructions"/>
  <img src="https://img.shields.io/badge/Simulation-Icarus%20Verilog-111111?style=flat-square" alt="Icarus Verilog"/>
  <img src="https://img.shields.io/badge/Target-Tang%20Nano%2020K-111111?style=flat-square" alt="Tang Nano 20K"/>
</p>

---

## Overview

This project is a custom 8-bit CPU developed from the RTL level upward.

The processor includes a custom instruction set, register file, arithmetic logic unit, program counter, program and data memory, instruction register, status register, instruction decoder, multi-cycle control unit, and full CPU datapath integration.

Each subsystem is implemented independently in synthesizable Verilog, verified with dedicated testbenches, and then integrated into the complete processor.

The current RTL implementation successfully executes machine-code programs containing arithmetic, logical, memory, data-movement, comparison, branching, jumping, immediate-load, and halt instructions.

---

## Current Status

### RTL Design

**Complete and verified in simulation.**

* [x] Custom 16-bit instruction set
* [x] 8 × 8-bit register file
* [x] 8-bit ALU
* [x] Zero, Negative, and Carry/Borrow flags
* [x] 8-bit Program Counter
* [x] 256 × 16-bit program memory
* [x] 256 × 8-bit data memory
* [x] 16-bit Instruction Register
* [x] Status Register
* [x] Instruction Decoder
* [x] Multi-cycle Control Unit
* [x] Full CPU datapath integration
* [x] Full ISA integration verification

### FPGA Implementation

**Next phase.**

* [ ] Synthesize complete design
* [ ] Build Tang Nano 20K top-level wrapper
* [ ] Add clock/reset integration
* [ ] Define FPGA constraints
* [ ] Generate bitstream
* [ ] Program FPGA
* [ ] Run hardware demonstration

---

## Architecture

| Component                 | Specification                            |
| ------------------------- | ---------------------------------------- |
| Datapath                  | 8-bit                                    |
| Instruction width         | 16-bit                                   |
| General-purpose registers | 8 × 8-bit                                |
| Register addressing       | 3-bit                                    |
| Program Counter           | 8-bit                                    |
| Instruction Register      | 16-bit                                   |
| Program memory            | 256 × 16-bit words                       |
| Data memory               | 256 × 8-bit                              |
| Memory organization       | Separate program and data memory         |
| Status flags              | Zero (Z), Negative (N), Carry/Borrow (C) |
| Execution model           | Multi-cycle FSM                          |
| HDL                       | Verilog                                  |

---

## High-Level Datapath

```text
                    ┌─────────────────────┐
                    │   Program Memory    │
                    │      256 × 16       │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Instruction Register│
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Instruction Decoder │
                    └──────────┬──────────┘
                               │
                     ┌─────────▼─────────┐
                     │   Control Unit    │
                     └─────────┬─────────┘
                               │
             ┌─────────────────┼─────────────────┐
             │                 │                 │
             ▼                 ▼                 ▼
      ┌─────────────┐    ┌──────────┐     ┌─────────────┐
      │Register File│───►│   ALU    │     │ Data Memory │
      │  8 × 8-bit │◄───│  8-bit   │◄───►│   256 × 8   │
      └─────────────┘    └────┬─────┘     └─────────────┘
                              │
                              ▼
                       ┌─────────────┐
                       │Status Reg.  │
                       │   Z N C     │
                       └─────────────┘
```

The CPU follows a multi-cycle execution model built around:

```text
FETCH → DECODE → EXECUTE / MEMORY → WRITEBACK → FETCH
```

Different instructions use only the states they require.

---

## Instruction Set Architecture

The processor uses fixed-width **16-bit instructions**.

| Opcode | Instruction | Operation                             |
| ------ | ----------- | ------------------------------------- |
| `0000` | HALT        | Stop execution                        |
| `0001` | ADD         | `Rd = Rs1 + Rs2`                      |
| `0010` | SUB         | `Rd = Rs1 - Rs2`                      |
| `0011` | AND         | `Rd = Rs1 AND Rs2`                    |
| `0100` | OR          | `Rd = Rs1 OR Rs2`                     |
| `0101` | XOR         | `Rd = Rs1 XOR Rs2`                    |
| `0110` | MOV         | `Rd = Rs1`                            |
| `0111` | LOAD        | `Rd = MEM[address]`                   |
| `1000` | STORE       | `MEM[address] = Rs`                   |
| `1001` | CMP         | Compare `Rs1` and `Rs2`, update flags |
| `1010` | JMP         | `PC = address`                        |
| `1011` | BEQ         | If `Z = 1`, `PC = address`            |
| `1100` | LDI         | `Rd = immediate`                      |
| `1101` | RESERVED    | Reserved                              |
| `1110` | RESERVED    | Reserved                              |
| `1111` | RESERVED    | Reserved                              |

The ISA currently contains **13 assigned opcodes and 3 reserved opcodes**.

---

## Instruction Formats

### Register-Type

Used by `ADD`, `SUB`, `AND`, `OR`, and `XOR`.

```text
15          12 11       9 8        6 5        3 2        0
+-------------+-----------+----------+----------+----------+
|   opcode    |    Rd     |   Rs1    |   Rs2    | reserved |
+-------------+-----------+----------+----------+----------+
     4 bits       3 bits      3 bits     3 bits     3 bits
```

Example:

```text
ADD R2, R0, R1

R2 = R0 + R1
```

### MOV-Type

```text
15          12 11       9 8        6 5                     0
+-------------+-----------+----------+----------------------+
|   opcode    |    Rd     |   Rs1    |       reserved       |
+-------------+-----------+----------+----------------------+
     4 bits       3 bits      3 bits           6 bits
```

### Immediate / Memory-Type

Used by `LDI`, `LOAD`, and `STORE`.

```text
15          12 11       9 8                       1 0
+-------------+-----------+-------------------------+-+
|   opcode    |     R     | address / immediate     |0|
+-------------+-----------+-------------------------+-+
     4 bits       3 bits           8 bits            1
```

Examples:

```text
LDI R3, 42
R3 = 42

LOAD R3, 0x80
R3 = MEM[0x80]

STORE R3, 0x80
MEM[0x80] = R3
```

### Jump-Type

Used by `JMP` and `BEQ`.

```text
15          12 11                     4 3          0
+-------------+-------------------------+------------+
|   opcode    |        address          |  reserved  |
+-------------+-------------------------+------------+
     4 bits             8 bits              4 bits
```

### Compare-Type

```text
15          12 11       9 8        6 5                     0
+-------------+-----------+----------+----------------------+
|   opcode    |   Rs1     |   Rs2    |       reserved       |
+-------------+-----------+----------+----------------------+
     4 bits       3 bits      3 bits           6 bits
```

`CMP` updates the status flags without writing to a general-purpose register.

---

## Verified CPU Subsystems

### Register File

The CPU contains eight 8-bit general-purpose registers with:

* Two combinational read ports
* One synchronous write port
* 3-bit register addressing
* Write-enable control
* Active-high synchronous reset

---

### Arithmetic Logic Unit

The ALU supports:

```text
ADD
SUB
AND
OR
XOR
```

It produces:

```text
Z = result is zero
N = result bit 7
C = carry-out for ADD / borrow indication for SUB
```

For subtraction:

```text
C = 1 → borrow occurred
C = 0 → no borrow occurred
```

---

### Program Counter

The 8-bit Program Counter supports:

```text
Reset
Increment
Direct target load
Hold
```

Control priority:

```text
reset > pc_write > pc_increment > hold
```

---

### Status Register

The CPU stores ALU condition flags in a dedicated status register.

This allows instructions such as:

```text
CMP R1, R2
BEQ 0x20
```

to preserve the result of the comparison across instruction boundaries.

---

### Control Unit

Instruction execution is coordinated using a multi-cycle finite-state machine.

Main states:

```text
FETCH
DECODE
EXECUTE
MEMORY
WRITEBACK
HALT
```

The control unit generates signals for:

* Instruction loading
* Program Counter updates
* Register writes
* Data-memory writes
* ALU operation selection
* Flag updates
* Writeback-source selection
* Processor halt state

---

## Verification

Verification is performed using **Icarus Verilog**.

Each major RTL block has its own testbench, followed by full CPU integration programs.

### Module-Level Verification

Verified modules include:

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

### End-to-End CPU Test

The first complete processor program executed:

```text
LDI R0, 5
LDI R1, 3
ADD R2, R0, R1
HALT
```

Final state:

```text
R0 = 5
R1 = 3
R2 = 8
PC = 4
CPU halted successfully
```

### Memory / Arithmetic Test

A second integration program verified:

```text
LDI
SUB
MOV
STORE
LOAD
HALT
```

Observed final state:

```text
R0 = 10
R1 = 6
R2 = 4
R3 = 4
R4 = 4

MEM[0x20] = 4
```

### Logic / Control-Flow Test

A third integration program verified:

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

The branch and jump tests verify control flow by checking that instructions on skipped paths do not modify architectural state.

---

## ISA Verification Status

| Instruction | Verified |
| ----------- | -------: |
| HALT        |        ✅ |
| ADD         |        ✅ |
| SUB         |        ✅ |
| AND         |        ✅ |
| OR          |        ✅ |
| XOR         |        ✅ |
| MOV         |        ✅ |
| LOAD        |        ✅ |
| STORE       |        ✅ |
| CMP         |        ✅ |
| JMP         |        ✅ |
| BEQ         |        ✅ |
| LDI         |        ✅ |

**13 / 13 assigned instructions verified end-to-end in simulation.**

---

## Repository Structure

```text
FPGA-Synthesizable-8Bit-CPU/
│
├── rtl/
│   ├── alu/
│   ├── common/
│   ├── control/
│   ├── cpu/
│   ├── memory/
│   ├── peripherals/
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
├── fpga/
│   ├── build/
│   ├── constraints/
│   └── top/
│
├── docs/
│   ├── architecture/
│   ├── isa/
│   ├── verification/
│   └── development-log/
│
└── simulations/
    └── waveforms/
```

---

## Development Workflow

Each subsystem follows the same process:

```text
Architecture
    ↓
RTL implementation
    ↓
Module testbench
    ↓
Functional verification
    ↓
CPU integration
    ↓
Integration testing
```

Generated simulation binaries are kept outside the source tree and excluded from version control.

---

## Tools

* Verilog HDL
* Icarus Verilog
* Visual Studio Code
* Git
* GitHub
* Sipeed Tang Nano 20K FPGA

FPGA synthesis and implementation tooling will be added during the hardware phase.

---

## Next Phase — FPGA Implementation

The RTL and ISA verification phase is complete.

The next stage is deployment to the **Sipeed Tang Nano 20K**:

```text
RTL synthesis
      ↓
FPGA top-level integration
      ↓
Clock / reset handling
      ↓
Pin constraints
      ↓
Bitstream generation
      ↓
Program Tang Nano 20K
      ↓
Hardware validation
```

The hardware phase will begin once the FPGA board is available.

---

## Author

**Alex Marfo Appiah**
Computer Engineering
Kwame Nkrumah University of Science and Technology (KNUST)
