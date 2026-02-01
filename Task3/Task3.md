
# GPIO Register : Specification 

In Task2 we did Normal GPIO with out own understanding. Now, the Specification is proper. 

In Task-3, you will upgrade your GPIO IP into a realistic peripheral with multiple registers that software can configure and control. 
Design a proper register map, implement direction control, and validate everything using a C program running on the RISC-V core. 

**Goal** : Task strengthens your understanding of memory-mapped I/O and prepares you for more advanced IPs used in real SoCs

![GPIO_IP_PIN](https://github.com/user-attachments/assets/4f2b1b75-d2c6-4cea-9e7c-d32c51fa1808)


# IP Level Design and Verification code

## Overview

This repository contains the IP‑level verification environment for a custom 32‑bit General‑Purpose Input/Output (GPIO) module. The objective of this environment is to validate the functional correctness, register behavior, direction control, and robustness of the GPIO IP before SoC‑level integration.

The verification is performed using a directed Verilog testbench with waveform dumping and a structured set of 16 functional, boundary, and stress‑oriented testcases.

### Method 1 :
- I am reusing the same gpio_in and gpio_out pins even for writing the Master or Even from the External World.

#### Method 2 : 
The wdata, rdata, gpio_en and gpio_out.
- wdata      :  Master sending to GPIO.
- rdata      :  GPIO sending to Master.
- gpio_in    :  External GPIO Input world connection.
- gpio_out   :  External GPIO Output world connection.

In actual way GPIO pins i.e., gpio_in and gpio_out has to be the same pins as shown in the below diagram.

<img width="835" height="312" alt="image" src="https://github.com/user-attachments/assets/458856eb-dc96-4e4b-b8f1-dedfea0760e9" />


## Design Under Test (DUT)
The DUT is implemented in gpio.v

It exposes the following key interfaces:
- gpio_in – External input pins
- gpio_out – Output pins driven by DATA register
- gpio_oe – Output enable (derived from DIR register)
- gpio_addr – Memory‑mapped address
- gpio_en – Access enable
- write_enable – Read/Write control
- clk, rst_n – Clock and reset

## Register Map 
| Register | Address      | Description                          | 
|----------|--------------|--------------------------------------| 
| DATA     | 0x2000_0000  | Output data register                 | 
| DIR      | 0x2000_0004  | Direction register (1 = OUT, 0 = IN) | 
| READ     | 0x2000_0008  | Reflected input/output state         |

The READ register merges gpio_in and gpio_out based on DIR bits.

## Testbench Structure
The testbench (gpio_tb.v) includes:
- Clock generation (10ns period)
- Reset sequencing
- DUT instantiation
- Memory‑mapped register access
- External input stimulus injection
- Waveform dumping (gpio_fullsuite.vcd)
- A complete suite of 16 directed testcases

All stimulus is applied through a single procedural block for deterministic execution.

## Testcase Summary

The verification suite contains 16 total testcases, grouped into four categories:

### Group A — Basic Functional Tests (1–4)
- Validates direction‑based merging of input/output pins:
- Odd OUTPUT, Even INPUT (DIR = AAAAAAAA)
- Odd INPUT, Even OUTPUT (DIR = 55555555)
- Lower‑16 INPUT, Upper‑16 OUTPUT (DIR = FFFF0000)
- Lower‑16 OUTPUT, Upper‑16 INPUT (DIR = 0000FFFF)

### Group B — Extended Functional Tests (5–8)
Adds DATA register readback:
DIR → DATA WRITE → DATA READ → READ REGISTER

### Group C — Extreme Direction Patterns (9–12)
Boundary and corner cases: 9. All INPUT (00000000) 10. All OUTPUT (FFFFFFFF) 11. Upper‑8 OUTPUT, Lower‑24 INPUT (FF000000) 12. Upper‑24 OUTPUT, Lower‑8 INPUT (00FFFFFF)

### Group D — Hazard & Stress Tests (13–16)
Robustness and timing sensitivity: 13. Back‑to‑back DATA writes 14. Read‑after‑write hazard 15. Glitching gpio_en mid‑transaction 16. Mixed DIR with random external input reflection

## How to Run
Using Icarus Verilog:

- iverilog -o gpio_tb gpio_tb.v gpio.v
- vvp gpio_tb
- gtkwave gpio_fullsuite.vcd



## Directory Structure

- gpio.v              # DUT
- gpio_tb.v           # Testbench with 16 testcases
- gpio_fullsuite.vcd  # Waveform dump (generated)
- README.md           # This file


## Waveforms Results

### Testcase 1 : Odd OUTPUT, Even INPUT
In the below waveform we observe that the writing the direction register and DATA register and the READ register when it is called based on the Direction register configured which GPIO pin acts as Output or Input. 

Now the READ Register reads the pins and stores in the values in the register. On reading this we get the value back.

![GPIO_TESTSUITE_WAVEFORM1](https://github.com/user-attachments/assets/1895e1ca-b7f5-4d38-8324-0b91618d5dcb)



### Testcase 2 : Odd INPUT, Even OUTPUT

![GPIO_TESTSUITE_WAVEFORM2](https://github.com/user-attachments/assets/a150b42c-1775-4db5-a75f-da878b2eefc5)



### Testcase 3 : Lower 16 INPUT, Upper 16 OUTPUT

![GPIO_TESTSUITE_WAVEFORM3](https://github.com/user-attachments/assets/a9fa0930-e3d2-4289-9ad1-6d9734c50298)



### Testcase 4 : Lower 16 OUTPUT, Upper 16 INPUT

![GPIO_TESTSUITE_WAVEFORM4](https://github.com/user-attachments/assets/28cbd2f8-63fd-40ac-8e9f-f90e67ef175d)




