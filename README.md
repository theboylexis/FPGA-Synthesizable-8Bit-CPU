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

| Component                 | Specification                     |
| ------------------------- | --------------------------------- |
| Datapath                  | 8-bit                             |
| Instruction width         | 16-bit                            |
| General-purpose registers | 8 × 8-bit                         |
| Register addressing       | 3-bit                             |
| Program Counter           | 8-bit                             |
| Instruction Register      | 16-bit                            |
| Program memory            | 256 × 16-bit words                |
| Data memory               | 256 × 8-bit                       |
| Memory organization       | Separate program and data memory  |
| Status flags              | Zero (Z), Negative (N), Carry (C) |
| HDL                       | Verilog                           |

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

| Opcode | Instruction | Operation                              |
| ------ | ----------- | -------------------------------------- |
| `0000` | HALT        | Stop execution                         |
| `0001` | ADD         | `Rd ← Rs1 + Rs2`                       |
| `0010` | SUB         | `Rd ← Rs1 - Rs2`                       |
| `0011` | AND         | `Rd ← Rs1 AND Rs2`                     |
| `0100` | OR          | `Rd ← Rs1 OR Rs2`                      |
| `0101` | XOR         | `Rd ← Rs1 XOR Rs2`                     |
| `0110` | MOV         | `Rd ← Rs1`                             |
| `0111` | LOAD        | `Rd ← MEM[address]`                    |
| `1000` | STORE       | `MEM[address] ← Rs`                    |
| `1001` | CMP         | Compare two registers and update flags |
| `1010` | JMP         | Unconditional jump                     |
| `1011` | BEQ         | Branch if Zero flag is set             |
| `1100` | LDI         | Load an 8-bit immediate                |
| `1101` | RESERVED    | Reserved                               |
| `1110` | RESERVED    | Reserved                               |
| `1111` | RESERVED    | Reserved                               |

The current ISA contains **13 assigned opcodes and 3 reserved opcodes**.

Detailed instruction formats and encoding decisions are documented under `docs/`.

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
* [x] Dual combinational read ports
* [x] Synchronous register write
* [x] Register-file reset logic
* [ ] ALU
* [ ] Status flag logic
* [ ] Program Counter
* [ ] Program memory
* [ ] Data memory
* [ ] Instruction decoder
* [ ] Control unit
* [ ] CPU integration

### Verification

* [x] Register-file testbench
* [x] Reset verification
* [x] Register write/read verification
* [x] Dual-read verification
* [x] Write-enable verification
* [x] Reset-priority verification
* [ ] ALU verification
* [ ] Control-unit verification
* [ ] Full CPU integration testing

### FPGA

* [ ] Synthesize complete processor
* [ ] Create Tang Nano 20K top-level design
* [ ] Define FPGA pin constraints
* [ ] Program FPGA
* [ ] Run hardware demonstration

## Register File

The first completed RTL subsystem is an 8 × 8-bit register file.

It provides:

* Two combinational read ports.
* One synchronous write port.
* 3-bit addressing for eight general-purpose registers.
* Active-high synchronous reset.
* Write-enable control.

The register file has been verified using Icarus Verilog for reset behavior, register writes, simultaneous dual-port reads, write-enable protection, and reset priority.

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

A basic processor integration test is planned around the following program:

```text
LDI R0, 5
LDI R1, 3
ADD R2, R0, R1
HALT
```

Expected register state:

```text
R0 = 5
R1 = 3
R2 = 8
```

This program will provide an initial end-to-end test of instruction fetch, decode, register access, ALU execution, writeback, and halt behavior.

## Status

**Work in progress.**

The architecture has been defined and the register file has been implemented and verified. ALU design and verification are the next development milestone.

## Author

Alex Marfo Appiah
Computer Engineering
Kwame Nkrumah University of Science and Technology (KNUST)
