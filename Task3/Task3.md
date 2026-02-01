
# GPIO Register : Specification 

In Task2 we did Normal GPIO with out own understanding. Now, the Specification is proper. 

In Task-3, you will upgrade your GPIO IP into a realistic peripheral with multiple registers that software can configure and control. 
Design a proper register map, implement direction control, and validate everything using a C program running on the RISC-V core. 

**Goal** : Task strengthens your understanding of memory-mapped I/O and prepares you for more advanced IPs used in real SoCs


# IP Level Design and Verification code

## Overview

This repository contains the IP‑level verification environment for a custom 32‑bit General‑Purpose Input/Output (GPIO) module. The objective of this environment is to validate the functional correctness, register behavior, direction control, and robustness of the GPIO IP before SoC‑level integration.

The verification is performed using a directed Verilog testbench with waveform dumping and a structured set of 16 functional, boundary, and stress‑oriented testcases.

The wdata, rdata, gpio_en and gpio_out.
- wdata      :  Master sending to GPIO.
- rdata      :  GPIO sending to Master.
- gpio_in    :  External GPIO Input world connection.
- gpio_out   :  External GPIO Output world connection.

In actual way GPIO pins i.e., gpio_in and gpio_out has to be the same pins as shown in the below diagram.

![GPIO_IP_PIN](https://github.com/user-attachments/assets/0191ef57-fc76-4965-a481-7a06e33ff1ea)


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

In the below waveform we write the configuration to the DIR Register through wdata. In the DATA Register we write through the wdata. If we observe since the DATA Register the writing updates the output values also. Hence the gpio_out we get the values. In the READ Register reads the current the GPIO_PIN values. 

<img width="1918" height="1017" alt="image" src="https://github.com/user-attachments/assets/22329e63-ca55-4040-a22c-ffcd631851bd" />


### Testcase 2 : Odd INPUT, Even OUTPUT

<img width="1918" height="1018" alt="image" src="https://github.com/user-attachments/assets/f4b8066a-c817-40d0-82ad-b7e796adc002" />



### Testcase 3 : Lower 16 INPUT, Upper 16 OUTPUT

<img width="1918" height="1020" alt="image" src="https://github.com/user-attachments/assets/2fc70895-af92-4209-a337-b73d37cd1ab3" />


### Testcase 4 : Lower 16 OUTPUT, Upper 16 INPUT

<img width="1918" height="1017" alt="image" src="https://github.com/user-attachments/assets/5c9d1d94-42a9-4eb2-b356-c4abc15f4682" />


## RISCV SOC Integration



### Waveform

<img width="1918" height="1022" alt="image" src="https://github.com/user-attachments/assets/e71d0fb4-f1e1-4766-be4a-24008ba9a0de" />


<img width="1918" height="1018" alt="image" src="https://github.com/user-attachments/assets/e27dce67-854a-4073-b7d7-4d1e291037fb" />


<img width="1918" height="1020" alt="image" src="https://github.com/user-attachments/assets/87139a76-dbf0-402b-b78e-ad79330585a5" />


<img width="1918" height="1018" alt="image" src="https://github.com/user-attachments/assets/c24f6e3b-fde3-4351-ab92-0d48d7ee409c" />








