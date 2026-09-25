FPGA-Synthesizable 8-Bit CPU

<p align="center">
  <strong>A custom multi-cycle 8-bit CPU designed in Verilog, verified in simulation, and implemented for the Sipeed Tang Nano 20K FPGA.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HDL-Verilog-111111?style=flat-square" alt="Verilog"/>
  <img src="https://img.shields.io/badge/Datapath-8--bit-111111?style=flat-square" alt="8-bit Datapath"/>
  <img src="https://img.shields.io/badge/Instruction%20Width-16--bit-111111?style=flat-square" alt="16-bit Instructions"/>
  <img src="https://img.shields.io/badge/ISA-13%20Instructions-111111?style=flat-square" alt="13-instruction ISA"/>
  <img src="https://img.shields.io/badge/Target-Tang%20Nano%2020K-111111?style=flat-square" alt="Tang Nano 20K"/>
</p>

Overview

This project is a custom 8-bit processor built from the RTL level upward to reinforce concepts from digital systems design, computer architecture, and FPGA development.

The CPU uses a 16-bit fixed-width instruction format, 8-bit datapath, 8 general-purpose registers, separate program and data memories, status flags, and a multi-cycle control unit.

The complete 13-instruction ISA has been verified end-to-end in simulation. The design has also been synthesized and successfully passed place-and-route for the Sipeed Tang Nano 20K.

Current Status

RTL & Verification

CPU architecture and 16-bit instruction format

13-instruction custom ISA

Register file, ALU, PC, memories, instruction/status registers

Instruction decoder and multi-cycle control unit

Module-level testbenches

Full CPU integration

13 / 13 assigned instructions verified end-to-end

FPGA Implementation

GOWIN project configured for GW2AR-LV18QN88C8/I7

Full CPU synthesized successfully

Tang Nano 20K top-level wrapper added

Board pin constraints added

Place & Route completed successfully

Program physical FPGA

Validate CPU behavior on hardware

Final hardware demo

Architecture

Component

Specification

Datapath

8-bit

Instruction width

16-bit

Registers

8 × 8-bit GPRs

Program Counter

8-bit

Program memory

256 × 16-bit

Data memory

256 × 8-bit

Status flags

Zero, Negative, Carry/Borrow

Execution model

Multi-cycle FSM

Memory organization

Separate program and data memory

Execution Flow

FETCH → DECODE → EXECUTE / MEMORY → WRITEBACK → FETCH

Not every instruction uses every state.

High-Level Datapath

PC
│
▼
Program Memory
│
▼
Instruction Register
│
▼
Instruction Decoder
│
├──────────────► Control Unit
│
▼
Register File ─────► ALU ─────► Status Register
     │                │
     │                └────────────┐
     │                             │
     └────► Data Memory            │
                │                  │
                └────► Writeback MUX ─────► Register File

Instruction Set

Opcode

Instruction

Operation

0000

HALT

Stop execution

0001

ADD

Rd = Rs1 + Rs2

0010

SUB

Rd = Rs1 - Rs2

0011

AND

Rd = Rs1 AND Rs2

0100

OR

Rd = Rs1 OR Rs2

0101

XOR

Rd = Rs1 XOR Rs2

0110

MOV

Rd = Rs1

0111

LOAD

Rd = MEM[address]

1000

STORE

MEM[address] = Rs

1001

CMP

Compare Rs1 and Rs2, update flags

1010

JMP

PC = address

1011

BEQ

If Z = 1, PC = address

1100

LDI

Rd = immediate

1101

RESERVED

Reserved

1110

RESERVED

Reserved

1111

RESERVED

Reserved

Verification

Verification was performed with Icarus Verilog at both module and CPU-integration level.

The integration tests cover:

arithmetic and logical operations

register-to-register movement

immediate loading

data-memory load/store

comparison and stored status flags

conditional branch taken / not taken

unconditional jump

processor halt

Result: all 13 assigned instructions pass end-to-end simulation.

FPGA Implementation

The CPU has been brought into GOWIN EDA and targeted to the Tang Nano 20K FPGA.

Current FPGA work includes:

synthesis of the complete CPU RTL

board-specific top-level wrapper

27 MHz board clock integration

reset and register-selection inputs

active-low LED debug output

Tang Nano 20K pin constraints

successful Place & Route

The synthesized design currently occupies well under 1% of the target device.

Physical board programming and hardware validation will begin once the FPGA board is available.

Repository Structure

FPGA-Synthesizable-8Bit-CPU/
├── rtl/              # Reusable CPU RTL
├── tb/               # Module and integration testbenches
├── programs/         # Machine-code test programs
├── simulations/      # Simulation outputs
├── docs/             # Architecture, ISA and verification notes
└── fpga/
    ├── top/          # Tang Nano 20K wrapper
    ├── constraints/  # Board pin constraints
    ├── gowin/        # GOWIN project files
    └── build/        # FPGA build outputs

Tools

Verilog · Icarus Verilog · GOWIN EDA · Git · VS Code · Sipeed Tang Nano 20K

Next Step

Program the Tang Nano 20K and verify the processor on physical hardware.

Author

Alex Marfo Appiah
