
# GPIO Register : Specification 

In Task2 we did Normal GPIO with out own understanding. Now, the Specification is proper. 

In Task-3, you will upgrade your GPIO IP into a realistic peripheral with multiple registers that software can configure and control. 
Design a proper register map, implement direction control, and validate everything using a C program running on the RISC-V core. 

**Goal** : Task strengthens your understanding of memory-mapped I/O and prepares you for more advanced IPs used in real SoCs

<img width="542" height="206" alt="image" src="https://github.com/user-attachments/assets/380d5ab3-8692-4d78-8d8d-09b24226e802" />

# Learning from Task2 : Correction in Task3

Actually in designing GPIO IP I made a blunder mistake i.e, **there is no seperate gpio_in and gpio_out pin concept. Actually GPIO : Bidirectional pins**.
I guess this Task3 hidden objective was to correct my misunderstanding and correct my design of IP in Task2.

For reference : https://www.ti.com/lit/ug/spruf95/spruf95.pdf?ts=1769786085619&ref_url=https%253A%252F%252Fin.search.yahoo.com%252F 

<img width="777" height="436" alt="image" src="https://github.com/user-attachments/assets/8e380311-096a-46b4-96c1-f228fd40598b" />


```

module gpio_ip(
    input wire clk,
    input wire rst_n,
    input wire gpio_en,               // Address Decoding : GPIO Enable Signal : To make sure only GPIO address is accessed.
    input [31:0] gpio_addr,          //  GPIO Address Input
    inout wire [31:0] gpio,         //   32 GPIO Input and Output pins
); 

```

# High Level Overiview

Cycle 1 : Direction Register
- gpio_addr = 0x04
- Read the contents of the GPIO pins.
  - 1 : Output
  - 0 : Input   
- Example : gpio_addr = 0x04 | gpio = 32'hFFFF_0000
  - Lets say Higher Halfword = 16'hFFFF | Lower Halfword = 16'h0000.
  - 16pins are configured as Output and 16pins are configured as Input.
    














