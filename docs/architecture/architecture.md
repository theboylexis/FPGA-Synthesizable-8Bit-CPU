# LEXIS-8 Architecture Specification

**Version:** 1.0
**Status:** Architecture specification
**Target FPGA:** Sipeed Tang Nano 20K

## 1. Project Overview

LEXIS-8 is a custom 8-bit processor designed from fundamental digital logic and implemented using synthesizable Verilog RTL.

The project investigates how combinational and sequential digital circuits can be composed into a functioning processor, verified in simulation, and deployed to an FPGA.

The processor is intentionally small so that its datapath, instruction set, control logic, and execution behavior can be understood in detail.

## 2. Architectural Goals

The processor shall:

1. Operate on 8-bit data.
2. Provide eight general-purpose registers.
3. Execute a custom 16-bit instruction set.
4. Support arithmetic, logical, memory, comparison, and control-flow operations.
5. Use separate program and data memories.
6. Be implemented using synthesizable Verilog RTL.
7. Be verified at both subsystem and processor level.
8. Be deployable on the Sipeed Tang Nano 20K FPGA.

## 3. Core Specifications

| Component                  | Specification |
| -------------------------- | ------------- |
| Datapath width             | 8 bits        |
| General-purpose registers  | 8             |
| Register names             | R0–R7         |
| Register width             | 8 bits        |
| Register identifier        | 3 bits        |
| Instruction width          | 16 bits       |
| Program Counter width      | 8 bits        |
| Instruction Register width | 16 bits       |
| Program memory             | 256 × 16-bit  |
| Data memory                | 256 × 8-bit   |
| Status flags               | Z, N, C       |

## 4. Register File

The processor contains eight 8-bit general-purpose registers:

```text
R0
R1
R2
R3
R4
R5
R6
R7
```

A 3-bit register identifier selects one of the eight registers.

The register file provides:

* Two combinational read ports.
* One synchronous write port.

Register writes occur on the active clock edge when write enable is asserted.

Reset initializes all general-purpose registers to zero.

## 5. Program Counter

The Program Counter (PC) is an 8-bit register containing the address of the current instruction in program memory.

Program memory contains 256 instruction locations, each holding one 16-bit instruction.

Therefore, the PC addresses instruction words rather than individual bytes.

For normal sequential execution:

```text
PC_next = PC + 1
```

For control-flow instructions, the control unit may instead load a target address into the PC.

## 6. Instruction Register

The Instruction Register (IR) holds the currently fetched 16-bit instruction.

The instruction fields are interpreted by the control logic to generate datapath control signals.

## 7. Program Memory

Program memory is specified as:

```text
256 × 16-bit
```

Each address corresponds to one instruction word.

The address is supplied by the 8-bit PC.

## 8. Data Memory

Data memory is specified as:

```text
256 × 8-bit
```

An 8-bit address selects one of 256 data locations.

The memory interface supports reading and writing 8-bit values.

## 9. Arithmetic Logic Unit

The ALU operates on two 8-bit operands and produces an 8-bit result.

Initial ALU operations:

```text
ADD
SUB
AND
OR
XOR
```

The ALU also generates status information used by the processor control logic.

## 10. Status Flags

LEXIS-8 defines three status flags:

```text
Z — Zero
N — Negative
C — Carry
```

### Zero flag

Z is asserted when the ALU result is zero.

### Negative flag

N reflects the most significant bit of the 8-bit ALU result.

### Carry flag

C represents the carry output of an addition and the defined carry/borrow status for subtraction.

The exact RTL definition of subtraction carry/borrow behavior will be specified and verified with the ALU implementation.

### Flag update policy

The following instructions update the flags:

```text
ADD
SUB
CMP
```

The following instructions leave the flags unchanged:

```text
AND
OR
XOR
MOV
LOAD
STORE
LDI
JMP
BEQ
HALT
```

## 11. Instruction Set Architecture

LEXIS-8 uses 16-bit instructions and a 4-bit opcode.

Four bits provide:

```text
2^4 = 16
```

possible opcode patterns.

Thirteen opcode patterns are currently assigned and three are reserved.

| Opcode | Instruction | Format |
| ------ | ----------- | ------ |
| `0000` | HALT        | —      |
| `0001` | ADD         | R      |
| `0010` | SUB         | R      |
| `0011` | AND         | R      |
| `0100` | OR          | R      |
| `0101` | XOR         | R      |
| `0110` | MOV         | MOV    |
| `0111` | LOAD        | I      |
| `1000` | STORE       | I      |
| `1001` | CMP         | CMP    |
| `1010` | JMP         | J      |
| `1011` | BEQ         | J      |
| `1100` | LDI         | I      |
| `1101` | RESERVED    | —      |
| `1110` | RESERVED    | —      |
| `1111` | RESERVED    | —      |

Reserved fields within instructions shall be encoded as zero.

## 12. Instruction Formats

### R-Type

```text
15       12 11      9 8       6 5       3 2       0
┌──────────┬─────────┬─────────┬─────────┬─────────┐
│  opcode  │   Rd    │   Rs1   │   Rs2   │reserved │
│  4 bits  │ 3 bits  │ 3 bits  │ 3 bits  │ 3 bits  │
└──────────┴─────────┴─────────┴─────────┴─────────┘
```

Used by:

```text
ADD
SUB
AND
OR
XOR
```

Operation examples:

```text
ADD Rd, Rs1, Rs2
Rd ← Rs1 + Rs2

SUB Rd, Rs1, Rs2
Rd ← Rs1 - Rs2
```

### MOV-Type

```text
15       12 11      9 8       6 5               0
┌──────────┬─────────┬─────────┬─────────────────┐
│  opcode  │   Rd    │   Rs1   │     reserved    │
│  4 bits  │ 3 bits  │ 3 bits  │      6 bits     │
└──────────┴─────────┴─────────┴─────────────────┘
```

Operation:

```text
MOV Rd, Rs1

Rd ← Rs1
```

### I-Type

```text
15       12 11      9 8                    1 0
┌──────────┬─────────┬──────────────────────┬─┐
│  opcode  │    R    │       immediate      │0│
│  4 bits  │  3 bits │        8 bits        │1│
└──────────┴─────────┴──────────────────────┴─┘
```

Used by:

```text
LOAD
STORE
LDI
```

For LOAD:

```text
LOAD Rd, address

Rd ← MEM[address]
```

For STORE:

```text
STORE Rs, address

MEM[address] ← Rs
```

For LDI:

```text
LDI Rd, immediate

Rd ← immediate
```

### J-Type

```text
15       12 11                    4 3               0
┌──────────┬──────────────────────┬─────────────────┐
│  opcode  │       address        │    reserved     │
│  4 bits  │        8 bits        │     4 bits      │
└──────────┴──────────────────────┴─────────────────┘
```

Used by:

```text
JMP
BEQ
```

Operations:

```text
JMP address

PC ← address
```

```text
BEQ address

if Z == 1:
    PC ← address
else:
    PC ← PC + 1
```

### CMP-Type

```text
15       12 11      9 8       6 5               0
┌──────────┬─────────┬─────────┬─────────────────┐
│  opcode  │   Rs1   │   Rs2   │     reserved    │
│  4 bits  │ 3 bits  │ 3 bits  │      6 bits     │
└──────────┴─────────┴─────────┴─────────────────┘
```

Operation:

```text
CMP Rs1, Rs2
```

The ALU performs the subtraction:

```text
Rs1 - Rs2
```

The subtraction result is not written to a general-purpose register. The operation updates the status flags.

## 13. Instruction Examples

Example:

```text
ADD R2, R0, R1
```

Fields:

```text
opcode   = 0001
Rd       = 010
Rs1      = 000
Rs2      = 001
reserved = 000
```

Encoded instruction:

```text
0001010000001000
```

Example:

```text
LDI R3, 42
```

Fields:

```text
opcode    = 1100
Rd        = 011
immediate = 00101010
reserved  = 0
```

Encoded instruction:

```text
1100011001010100
```

Example:

```text
LOAD R3, 0x80
```

Fields:

```text
opcode   = 0111
R        = 011
address  = 10000000
reserved = 0
```

Encoded instruction:

```text
0111011100000000
```

## 14. Initial Execution Model

A normal instruction follows the conceptual sequence:

```text
FETCH
  ↓
DECODE
  ↓
EXECUTE
  ↓
WRITEBACK / MEMORY
  ↓
FETCH
```

The exact control-state implementation will be defined during control-unit design.

## 15. Initial Test Program

The first processor-level test program will be:

```text
LDI  R0, 5
LDI  R1, 3
ADD  R2, R0, R1
HALT
```

Expected final register state:

```text
R0 = 5
R1 = 3
R2 = 8
```

This program will become one of the first integration tests for the processor.

## 16. Design Status

The architecture and initial ISA have been specified.

Implementation has not yet begun.

The next subsystem to be implemented is the register file, followed by the ALU, datapath, control unit, memories, and complete processor integration.
