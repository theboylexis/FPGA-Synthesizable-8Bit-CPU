# FPGA-Synthesizable 8-Bit CPU

A custom 8-bit processor designed from scratch in Verilog and built toward deployment on an FPGA.

The project explores processor design from the RTL level upward: register storage, arithmetic and logic, instruction encoding, control logic, memory, CPU integration, verification, and FPGA implementation.

Rather than implementing an existing processor architecture, the CPU uses a custom instruction set designed specifically for this project.

## Project Goals

The primary goals are to:

* Design a complete 8-bit CPU from fundamental digital logic concepts.
* Develop a custom instruction set architecture.
* Write synthesizable Verilog RTL for each hardware subsystem.
* Verify individual modules with dedicated testbenches before integration.
* Integrate the datapath, control unit, and memory into a functioning processor.
* Synthesize and deploy the completed design on a Sipeed Tang Nano 20K FPGA.
* Document design decisions, verification results, and engineering tradeoffs throughout development.

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
| HDL                       | Verilog                                  |

## High-Level Architecture

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
              │    Control Unit     │
              └──────────┬──────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   ┌─────────────┐  ┌─────────┐  ┌─────────────┐
   │Register File│  │   ALU   │  │ Data Memory │
   │  8 × 8-bit │◄─►│ 8-bit   │◄─►│   256 × 8   │
   └─────────────┘  └─────────┘  └─────────────┘
                         │
                         ▼
                    Z / N / C
```

## Instruction Set

The processor uses fixed-width 16-bit instructions.

| Opcode | Instruction | Operation                                    |
| ------ | ----------- | -------------------------------------------- |
| `0000` | HALT        | Stop execution                               |
| `0001` | ADD         | `Rd = Rs1 + Rs2`                             |
| `0010` | SUB         | `Rd = Rs1 - Rs2`                             |
| `0011` | AND         | `Rd = Rs1 AND Rs2`                           |
| `0100` | OR          | `Rd = Rs1 OR Rs2`                            |
| `0101` | XOR         | `Rd = Rs1 XOR Rs2`                           |
| `0110` | MOV         | `Rd = Rs1`                                   |
| `0111` | LOAD        | `Rd = MEM[address]`                          |
| `1000` | STORE       | `MEM[address] = Rs`                          |
| `1001` | CMP         | Compare `Rs1` and `Rs2`, update status flags |
| `1010` | JMP         | `PC = address`                               |
| `1011` | BEQ         | If `Z = 1`, `PC = address`                   |
| `1100` | LDI         | `Rd = immediate`                             |
| `1101` | RESERVED    | Reserved                                     |
| `1110` | RESERVED    | Reserved                                     |
| `1111` | RESERVED    | Reserved                                     |

The current ISA contains **13 assigned opcodes and 3 reserved opcodes**.

Detailed instruction formats and encoding decisions are documented under `docs/`.

## Instruction Formats

### Register-Type

Used by:

* ADD
* SUB
* AND
* OR
* XOR

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

Example:

```text
MOV R2, R1

R2 = R1
```

### Immediate / Memory-Type

Used by:

* LOAD
* STORE
* LDI

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
```

```text
LOAD R3, 0x80

R3 = MEM[0x80]
```

```text
STORE R3, 0x80

MEM[0x80] = R3
```

### Jump-Type

Used by:

* JMP
* BEQ

```text
15          12 11                     4 3          0
+-------------+-------------------------+------------+
|   opcode    |        address          |  reserved  |
+-------------+-------------------------+------------+
     4 bits             8 bits              4 bits
```

Examples:

```text
JMP 0x20

PC = 0x20
```

```text
BEQ 0x20

If Z = 1:
    PC = 0x20
```

### Compare-Type

```text
15          12 11       9 8        6 5                     0
+-------------+-----------+----------+----------------------+
|   opcode    |   Rs1     |   Rs2    |       reserved       |
+-------------+-----------+----------+----------------------+
     4 bits       3 bits      3 bits           6 bits
```

Example:

```text
CMP R1, R2

Compare R1 and R2
Update Z, N, and C
No general-purpose register is written
```

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

## Development Approach

The processor is being developed incrementally.

Each subsystem is:

1. Defined from its architectural requirements.
2. Implemented as synthesizable Verilog RTL.
3. Tested independently using a dedicated testbench.
4. Integrated only after its expected behavior has been verified.

This approach makes failures easier to isolate and creates verification evidence for each stage of the processor.

## Current Progress

### Architecture

* [x] Define 8-bit datapath
* [x] Define register architecture
* [x] Define memory organization
* [x] Define 16-bit instruction width
* [x] Define initial instruction set
* [x] Define instruction formats

### RTL

* [x] 8 × 8-bit register file
* [x] Dual combinational register reads
* [x] Synchronous register write
* [x] Register-file reset logic
* [x] 8-bit ALU
* [x] ADD, SUB, AND, OR, XOR operations
* [x] Zero, Negative, and Carry/Borrow flags
* [x] 8-bit Program Counter
* [x] Program Counter reset, increment, target load, and hold behavior
* [ ] Program memory
* [ ] Data memory
* [ ] Instruction register
* [ ] Instruction decoder
* [ ] Control unit
* [ ] CPU integration

### Verification

* [x] Register-file testbench
* [x] Register reset verification
* [x] Register write/read verification
* [x] Dual-read verification
* [x] Write-enable verification
* [x] Register reset-priority verification
* [x] ALU testbench
* [x] ADD and carry-out verification
* [x] SUB and borrow verification
* [x] Logical operation verification
* [x] Status flag verification
* [x] Program Counter testbench
* [x] Program Counter increment verification
* [x] Program Counter target-load verification
* [x] Program Counter hold verification
* [x] Program Counter control-priority verification
* [ ] Memory verification
* [ ] Control-unit verification
* [ ] Full CPU integration testing

### FPGA

* [ ] Synthesize complete processor
* [ ] Create Tang Nano 20K top-level design
* [ ] Define FPGA pin constraints
* [ ] Program FPGA
* [ ] Run hardware demonstration

## Implemented Subsystems

### Register File

The processor includes an 8 × 8-bit register file with:

* Two combinational read ports
* One synchronous write port
* 3-bit addressing for eight general-purpose registers
* Active-high synchronous reset
* Write-enable control

The register file has been verified using Icarus Verilog for reset behavior, register writes, simultaneous dual-port reads, write-enable protection, and reset priority.

### Arithmetic Logic Unit

The current ALU supports:

* ADD
* SUB
* AND
* OR
* XOR

It produces an 8-bit result together with three status outputs:

* **Z** — asserted when the result is zero
* **N** — reflects bit 7 of the result
* **C** — carry-out for addition and borrow indication for subtraction

For subtraction:

```text
C = 1 means a borrow occurred
C = 0 means no borrow occurred
```

The ALU has been verified with normal arithmetic, addition carry-out, subtraction borrow, equality, logical operations, and reserved control values.

### Program Counter

The 8-bit Program Counter supports:

* Synchronous reset to address `0x00`
* Sequential increment by one instruction word
* Direct loading of an 8-bit target address
* State hold when no control action is requested

Its control priority is:

```text
reset > pc_write > pc_increment > hold
```

The Program Counter has been verified for reset, increment, target loading, control priority, and hold behavior.

## Tools

Current development environment:

* Verilog HDL
* Icarus Verilog
* Visual Studio Code
* Git
* GitHub
* Sipeed Tang Nano 20K FPGA

Additional synthesis and FPGA implementation tooling will be documented as the project progresses.

## Initial Integration Program

A basic processor integration test is planned around:

```text
LDI R0, 5
LDI R1, 3
ADD R2, R0, R1
HALT
```

Expected behavior:

```text
R0 = 5
R1 = 3
R2 = R0 + R1
R2 = 8
```

This program will provide an initial end-to-end test of:

* instruction fetch
* instruction decode
* register access
* ALU execution
* register writeback
* Program Counter sequencing
* processor halt behavior

## Status

**Work in progress.**

The architecture, register file, ALU, status flags, and Program Counter have been implemented and verified.

**Next milestone:** Program memory.

## Author

Alex Marfo Appiah
Computer Engineering
Kwame Nkrumah University of Science and Technology (KNUST)
