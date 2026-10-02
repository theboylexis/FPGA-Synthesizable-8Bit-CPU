# FPGA Hardware Bring-Up and Validation

**Date:** 2026-10-02  
**Board:** Sipeed Tang Nano 20K  
**FPGA:** GW2AR-LV18QN88C8/I7  
**Toolchain:** GOWIN EDA

## Goal

Move the completed 8-bit CPU from simulation and FPGA implementation into physical hardware validation on the Tang Nano 20K.

## Initial Board Bring-Up

The board was connected over USB-C and detected through the onboard debugger.

GOWIN Programmer successfully detected:

```text
USB Debugger A
GW2AR-18C
```

This confirmed that the board and JTAG programming path were available.

## LED Blink Test

Before loading the CPU, a minimal FPGA design was created to verify the basic hardware toolchain.

The design used:

```text
27 MHz onboard clock
24-bit counter
counter[23] driving an onboard LED
```

The LED output was inverted because the onboard LEDs are active-low.

The design successfully completed:

```text
Verilog
→ Synthesis
→ Place & Route
→ Configuration File Generation
→ SRAM Programming
→ Physical LED Output
```

One onboard LED blinked approximately once per second.

This confirmed:

- the FPGA could be programmed successfully
- the 27 MHz onboard clock was working
- the selected LED pin was correct
- the active-low LED behavior was understood

## CPU Debug Interface

A dedicated register debug interface was added to the CPU.

The register file gained a third combinational read port:

```verilog
input  wire [2:0] debug_address;
output wire [7:0] debug_data;
```

The selected register value was exposed through:

```verilog
assign debug_data = registers[debug_address];
```

The FPGA wrapper displayed the lower six bits of the selected register using the six onboard LEDs.

Because the LEDs are active-low:

```verilog
assign led = ~debug_register_data[5:0];
```

This means a lit LED represents a register bit equal to `1`.

## LED Debug Mapping

```text
LED0 → bit 0 → value 1
LED1 → bit 1 → value 2
LED2 → bit 2 → value 4
LED3 → bit 3 → value 8
LED4 → bit 4 → value 16
LED5 → bit 5 → value 32
```

Only the lower six bits of each 8-bit register are visible on the board.

## Arithmetic Hardware Test

The first CPU test program was:

```text
LDI R0, 5
LDI R1, 3
ADD R2, R0, R1
HALT
```

Observed register values:

```text
R0 = 5
R1 = 3
R2 = 8
```

The LED patterns matched the expected binary values.

**Result:** PASS

## Pushbutton Issue

The register-selection pushbutton was initially connected directly to the register selector.

A single physical button press sometimes advanced through multiple registers.

The cause was mechanical switch bounce.

A separate button test design was created to isolate:

- S1
- S2
- onboard LEDs
- 27 MHz clock

The hardware diagnostic showed the FPGA inputs behaving as:

```text
released = logic 0
pressed  = logic 1
```

in the tested configuration.

The final FPGA wrapper therefore uses the button signals as active-high inputs.

## Button Synchronization and Debounce

The register-selection input was updated with:

- two-stage synchronization
- debounce counter
- rising-edge pulse detection

A debounce period of approximately 5 ms was used at 27 MHz.

After this change, each S1 press advanced the debug register selector exactly once.

## Memory and Data-Movement Hardware Test

The second hardware test exercised:

```text
LDI
SUB
MOV
STORE
LOAD
HALT
```

Program behavior:

```text
R0 = 10
R1 = 6
R2 = R0 - R1 = 4
R3 = R2
MEM[0x20] = R3
R4 = MEM[0x20]
```

Observed register values:

```text
R0 = 10
R1 = 6
R2 = 4
R3 = 4
R4 = 4
```

The successful `LOAD` result indirectly confirmed that the preceding `STORE` wrote the expected value to data memory.

**Result:** PASS

## Logic and Control-Flow Hardware Test

The final hardware test exercised:

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

Expected and observed final register values:

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

The control-flow behavior matched expectations:

```text
CMP R2, R2
→ Z = 1
→ BEQ taken
→ first R5 write skipped

CMP R0, R1
→ Z = 0
→ BEQ not taken
→ R5 written with 0x55

JMP
→ skipped first R6 write
→ R6 ended as 0x11
```

**Result:** PASS

## Final Result

The CPU was successfully programmed and validated on the Sipeed Tang Nano 20K.

Across the three hardware programs, all 13 assigned ISA instructions were exercised:

```text
HALT
ADD
SUB
AND
OR
XOR
MOV
LOAD
STORE
CMP
JMP
BEQ
LDI
```

The physical FPGA results matched the expected simulation behavior.

## Key Lessons

- Simulation inputs are ideal; physical pushbuttons are asynchronous and can bounce.
- Synchronization is required before using asynchronous external inputs inside synchronous logic.
- Mechanical inputs require debounce logic for reliable behavior.
- Explicit debug ports are more robust than relying on internal hierarchical observation.
- FPGA bring-up is easier to debug when clock, I/O, and programming are validated independently before loading the full design.
- Successful synthesis and Place & Route do not replace physical hardware validation.