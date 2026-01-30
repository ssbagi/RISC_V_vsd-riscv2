
# RISCV SoC Block Diagram 

The Basic SoC Block daigram overview. The details as per my understanding. There are logic in between for the selection which is written in verilog not be considered here for accuracy. 

GPIO REGISTER at 0x2000_0000 as Address.
 

# Learning Lesson 
Input and Output Pins I made it separately. The pins I need to make it as Input and Output in 32 pins only. Instead of making seperatly the GPIO_IN and GPIO_OUT. I need to have single set of 32 pins only.
Correcting this in the Task3. 

<img width="1668" height="1577" alt="image" src="https://github.com/user-attachments/assets/965dec3d-bcad-4318-a3b7-8a18ea149bcf" />


Source and Destination Registers :
```
// Source and destination registers
   wire [4:0] rs1Id = instr[19:15];
   wire [4:0] rs2Id = instr[24:20];
   wire [4:0] rdId  = instr[11:7];
```

CPU Read Registers from the Register File  :
```
      FETCH_REGS: begin
         rs1 <= RegisterBank[rs1Id];
         rs2 <= RegisterBank[rs2Id];
         state <= EXECUTE;
      end
```

CPU Write data to Registers : 
```
always @(posedge clk) begin
      if(!resetn) begin
         PC    <= 0;
         state <= FETCH_INSTR;
      end else begin
    if(writeBackEn && rdId != 0) begin
       RegisterBank[rdId] <= writeBackData;
       // $display("r%0d <= %b (%d) (%d)",rdId,writeBackData,writeBackData,$signed(writeBackData));
       // For displaying what happens.
    end
```

Memory Mapped Region.
```
    /*
      Memory-mapped IO in IO page : (0x0040_0000 : 0x007F_FFFF)
         - GPIO and UART peripherals are memory mapped in this range.
         - 22nd bit of mem_addr is used to distinguish between RAM and IO peripheral. 
         - It is high for the 4, 5, 6 and 7 numbers. 
         - In binary : 0000_0100_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx - 0000_0111_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx
   */
   wire isIO   = mem_addr[22];
   wire isGPIO = ((mem_addr & 32'hFFFF_FF00) == 32'h2000_0000); // Changed the Address MAP : 2000_0000. AT SoC Level making this change.
   wire isRAM  = !isIO;
  
  wire uart_valid = (isGPIO && gpio_out_enable) | (isIO & mem_wstrb & mem_wordaddr[IO_UART_DAT_bit]);
```    

# GPIO IP Specification

Participants will:
- Create a new RTL module for the GPIO IP
- Implement:
  - Register storage
  - Write logic
  - Readback logic
  - Follow synchronous design principles




## GPIO IP Code 


```
GPIO IP VERILOG CODE : I have developed three Types. I prefer Type 3 for integration only.

Type 1 :

Address Decoding is like this : Hardcoded the GPIO ADDRESS = 0x2000_0000

wire isGPIO = ((mem_addr & 32'hFFFF_FF00) == 32'h2000_0000); // GPIO mapped at 0x2000_0000  -------- AT SoC Level making this change.
At IP level when passing the gpio_addr = isGPIO && mem_addr. This will enable for that specific address only. 
write_enable(isGPIO & !mem_rstrb),       // GPIO WE = 1 when CPU wants to write to GPIO. Otherwise it will be read operation.

Since Only One 32-bit register. My design implemntation is like :
- WE = 1 then only write and Output Signal = 1.
- WE = 0 then only read. It reads previous value written to the Register. 

module gpio_ip(
    input clk,
    input rst_n,
    input [31:0] gpio_addr,
    input [31:0] gpio_in,
    input write_enable,
    output reg [31:0] gpio_out,
    output reg out_enable
); 
    reg[31:0] gpio_in_reg; // Memory to store the last written value. 32-bit wide Register. 
    //GPIO Register Address is 0x2000_0000
    // Using only one register for GPIO. So, no need of address decoding.
    // Synchronous Clock with Synchronous reset
    always @(posedge clk) begin
        if(!rst_n) begin
            gpio_out <= 32'b0;
            gpio_in_reg <= 32'b0;
            out_enable <= 1'b0;
        end
        else(gpio_addr) begin
            else if(write_enable == 1'b1) begin
                gpio_in_reg <= gpio_in;
                /*
                    It's good not to change the state of the gpio_out ---------- Power consumption due to switching of states.
                    gpio_out <= 32'bz;
                    While writing we don't need to read the gpio_out. So, disable the output.
                */
                out_enable <= 1'b1;
            end
            else if(write_enable == 1'b0) begin
                gpio_out <= gpio_in_reg;
                out_enable <= 1'b0;
            end
        end
    end

endmodule


TYPE 2 :

Accessing the GPIO with addition of ADDR Field. Addition of the gpio_addr field.
// Creation of the GPIO Register Set

GPIO Output Register BANK ASLO : 

module gpio_ip(
    input clk,                           // Clock Input
    input rst_n,                        // Active LOW RESET
    input [31:0] gpio_addr,            // GPIO Address Input
    input [31:0] gpio_in,             // GPIO Data Input
    input write_enable,              // Write Enable Signal
    output reg [31:0] gpio_out,     // GPIO Data Output
    output reg out_enable          // Output Enable Signal
); 
    reg[31:0] gpio_in_reg[255:0]; // 32-bit wide Register : Array of 256 registers for multiple GPIO ports.
    reg[7:0] out_reg = gpio_addr[7:0]; // Using lower 8 bits of address for selecting register : Register Number.
    reg[7:0] prev_addr; // To store previous address.
    integer i;
    // Synchronous Clock with Synchronous reset
    always @(posedge clk) begin
        if(!rst_n) begin
            gpio_out <= 32'b0;
            out_enable <= 1'b0;
            // Reset all 256 registers 
            for (i = 0; i < 256; i = i + 1) 
                gpio_in_reg[i] <= 32'b0;
        end
        else begin
            // Creation of 256 : Array of Registers. Writing to and Reading from multiple GPIO ports.
            if(write_enable == 1'b1) begin
                gpio_in_reg[out_reg] <= gpio_in;
                gpio_out <= 32'bZ; // High Impedance State while writing to avoid unnecessary power consumption.
                out_enable <= 1'b1;
                prev_addr <= out_reg;
            end
            else if(write_enable == 1'b0) begin
                gpio_out <= gpio_in_reg[prev_addr];
                out_enable <= 1'b0;
            end
        end
    end

endmodule

TYPE 3 : GPIO General with GPIO_EN pin removed the GPIO_ADDR. 

module gpio_ip(
    input clk,
    input rst_n,
    input gpio_en,              // GPIO Enable Signal : To make sure only GPIO address is accessed.
    // input [31:0] gpio_addr,  // GPIO Address Input : Not required as only one register is used for GPIO. So, no address decoding is required.
    input [31:0] gpio_in,
    input write_enable,
    output reg [31:0] gpio_out,
    output reg out_enable
); 
    reg[31:0] gpio_in_reg; // Memory to store the last written value. 32-bit wide Register. 
    // GPIO Register Address is 0x2000_0000
    // Using only one register for GPIO. So, no need of address decoding.
    // Synchronous Clock with Synchronous reset.
    always @(posedge clk) begin
        if(!rst_n) begin
            gpio_out <= 32'b0;
            gpio_in_reg <= 32'b0;
            out_enable <= 1'b0;
        end
        else if (gpio_en) begin
            if(write_enable == 1'b1) begin
                gpio_in_reg <= gpio_in;
                /*
                    It's good not to change the state of the gpio_out ---------- Power consumption due to switching of states.
                    gpio_out <= 32'bz;
                    While writing we don't need to read the gpio_out. So, disable the output.
                */
                out_enable <= 1'b1;
            end
            else if(write_enable == 1'b0) begin
                gpio_out <= gpio_in_reg;
                out_enable <= 1'b0;
            end
        end
    end

endmodule


```

# GPIO Simulation Waveform : One 32 bit Register Only

If we observe at T = 120ns. We see Writing to 00003D6C. After that write_enable = 1. Hence, Until write_enable becomes 1. It always gives previous written value.

<img width="1918" height="1030" alt="image" src="https://github.com/user-attachments/assets/1a26ebe5-7737-480b-9e5b-341510d77441" />


<img width="1918" height="1032" alt="image" src="https://github.com/user-attachments/assets/5ff39698-924f-4b2f-b212-0a757774b255" />


The write_enable = 1. We see multiple writes happening to the register on every clk posedge. 

<img width="1918" height="303" alt="image" src="https://github.com/user-attachments/assets/f27cf1a9-76ae-4351-af46-0e010f8e4b70" />



# GPIO REGISTER BANK

In the below waveform if we observe at Time 1520ns. The Register Number = 5, WE = 1 hence in the register 5 we see the output being written to it. At 1540ns we see WE = 1. The Register selected is 8'b3B = 59. Writing.  
At Time 1560ns we observe that WE = 0. It reads the latest written Register value only as output. 

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/7ead550f-d0b9-480e-a68c-1b87ffef867c" />


<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/4f86b7d7-a609-40f8-ab46-e88bf1f706d9" />

# GPIO EN 

If we observe at time 105ns we observe gpio_en = 1, write_enable = 1, gpio_addr = 0x2000_0000 We write it to the GPIO Register. 

<img width="1913" height="880" alt="image" src="https://github.com/user-attachments/assets/befa4c09-ec8f-4a3d-ae79-f63a87a5644c" />

At time = 115ns we observe that write_en = 0, and the gpio_addr = 0x2000_0000. At gpio_out previous written value is given as output.

<img width="1918" height="880" alt="image" src="https://github.com/user-attachments/assets/1a2e35b0-f1db-4fbc-b6fd-8dafa89b7b6e" />


# Integration the GPIO into the RISC-V Core

The Whole Integration of the code.

```

/**
 * Step 20: Creating a RISC-V processor
 * Using GNU tools
 */

`default_nettype none
`include "clockworks.v"
`include "emitter_uart.v"
`include "gpio.v"
`include "memory.v"
`include "Processor.v"


 module SOC (
    input wire	     CLK,  // system clock 
    input wire	     RESET,// reset button
    output reg [4:0] LEDS, // system LEDs
    input wire	     RXD,  // UART receive
    output wire 	     TXD   // UART transmit
);

   wire clk;
   wire resetn;
   wire gpio_out_enable;
   wire [31:0] mem_addr;
   wire [31:0] mem_rdata;
   wire mem_rstrb;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wmask;
   //assign clk = CLK;
   //assign resetn = RESET;

   // Instantiate the RISC-V Processor
   Processor CPU(
      .clk(clk),
      .resetn(!resetn),		 
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask(mem_wmask)
   );

   wire [31:0] RAM_rdata, GPIO_rdata, GPIO_wdata;
   wire [29:0] mem_wordaddr = mem_addr[31:2];
   /*
      Memory-mapped IO in IO page : (0x0040_0000 : 0x007F_FFFF)
         - GPIO and UART peripherals are memory mapped in this range.
         - 22nd bit of mem_addr is used to distinguish between RAM and IO peripheral. 
         - It is high for the 4, 5, 6 and 7 numbers. 
         - In binary : 0000_0100_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx - 0000_0111_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx
   */
   wire isIO   = mem_addr[22];
   wire isGPIO = ((mem_addr & 32'hFFFF_FF00) == 32'h2000_0000); // GPIO mapped at 0x2000_0000
   wire isRAM  = !isIO;
   wire mem_wstrb = |mem_wmask;
   assign GPIO_wdata = mem_wdata;
   
   // Instantiate the Memory
   Memory RAM (
      .clk(clk),
      .mem_addr(mem_addr),
      .mem_rdata(RAM_rdata),
      .mem_rstrb(isRAM & mem_rstrb),
      .mem_wdata(mem_wdata),
      .mem_wmask({4{isRAM}}&mem_wmask)
   );

   /*

      Instantiate the GPIO peripheral .
      As of now assumed that GPIO peripheral is memory mapped at address 0x0040_0000 - 0x005F_FFFF .
      
      CPU to GPIO to external world.

      mem_rstrb = 1 : Processor wants to read.
      mem_rstrb = 0 : Processor wants to write.

   */

   gpio_ip GPIO (
      .clk(clk),
      .rst_n(!resetn),
      .gpio_en(isGPIO),
      .gpio_in(GPIO_wdata),
      .write_enable(!mem_rstrb),
      .gpio_out(GPIO_rdata),
      .out_enable(gpio_out_enable)
   ); 

   // Memory-mapped IO in IO page, 1-hot addressing in word address. 
   localparam IO_LEDS_bit      = 0;  // W five leds 
   localparam IO_UART_DAT_bit  = 1;  // W data to send (8 bits) 
   localparam IO_UART_CNTL_bit = 2;  // R status. bit 9: busy sending 
   
   always @(posedge clk) begin
      if(isIO & mem_wstrb & mem_wordaddr[IO_LEDS_bit]) begin 
	      LEDS <= mem_wdata;
         //	 $display("Value sent to LEDS: %b %d %d",mem_wdata,mem_wdata,$signed(mem_wdata));
      end
   end

   wire uart_valid = isIO & mem_wstrb & mem_wordaddr[IO_UART_DAT_bit];
   wire uart_ready;
   
   corescore_emitter_uart #(
      .clk_freq_hz(12*1000000),
      .baud_rate(9600)
      //   .baud_rate(1000000)
   ) UART(
      .i_clk(clk),
      .i_rst(!resetn),
      .i_data(mem_wdata[7:0]),
      .i_valid(uart_valid),
      .o_ready(uart_ready),
      .o_uart_tx(TXD)      			       
   );

   wire [31:0] IO_rdata = mem_wordaddr[IO_UART_CNTL_bit] ? { 22'b0, !uart_ready, 9'b0}: 32'b0;
   
   assign mem_rdata = isGPIO & !mem_rstrb ? GPIO_rdata : isRAM ? RAM_rdata : IO_rdata;
   
   
   `ifdef BENCH
      always @(posedge clk) begin
         if(uart_valid) begin
            $write("%c", mem_wdata[7:0]);
            $fflush(32'h8000_0001);
         end
      end
   `endif   
   
   wire clk_int;

   
   SB_HFOSC #(
   .CLKHF_DIV("0b10") // 12 MHz
   ) hfosc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF(clk_int)
   );
  

   // Gearbox and reset circuitry.
   Clockworks CW(
     //.CLK(clk_int),
     .CLK(CLK),
     .RESET(RESET),
     .clk(clk),
     .resetn(resetn)
   );


endmodule


```

# Whole SoC Waveform

The Whole SoC Waveform : 

If we observe in below Wavform we observe that isGPIO is enable only for the Address 0x2000000 . We write to the GPIO register and readback the latest data from the GPIO register also. 

<img width="1919" height="1030" alt="image" src="https://github.com/user-attachments/assets/18f3468b-54b8-470d-a35f-937c953d0936" />


<img width="1919" height="1031" alt="image" src="https://github.com/user-attachments/assets/0b59a8b5-789b-4f5e-ac43-80724179814c" />


<img width="1919" height="1032" alt="image" src="https://github.com/user-attachments/assets/1c9f2b8b-31e8-4bbe-a775-ac46813c547a" />


<img width="1919" height="1035" alt="image" src="https://github.com/user-attachments/assets/260db81b-c9a5-4628-bcb8-42c3aee53a4a" />


<img width="1919" height="1031" alt="image" src="https://github.com/user-attachments/assets/c6e4c20b-b319-4c83-8565-568df98cf1a9" />


## The Testcase

The C Testcase to check the access of the GPIO Register and stuff 

```


#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define GPIO_ADDR (*(volatile unsigned int*)0x20000000)

// Delay means introduce NOP opcodes into the code : Wow Learnt.
#define DELAY 10

// Software delay for bare-metal RISC-V
void wait_cycles(volatile int count) {
    while (count-- > 0) {
        __asm__ volatile("nop");
    }
}

// Addition of the delay i.e., NOP : TO avoid RAW Hazard. RISC-V is an In-order Processor. 

int main() {
    unsigned int x, y, i = 100;

    GPIO_ADDR = 100 + i;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*2;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*3;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*4;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*5;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    GPIO_ADDR = 100 + i*6;
    wait_cycles(DELAY);  // Pause
    y = GPIO_ADDR;
    wait_cycles(DELAY);  // Pause

    return 0;
}


```

# YOSYS, ROUTING FPGA COMPIALTION


<img width="940" height="528" alt="image" src="https://github.com/user-attachments/assets/126055ed-7a03-4f4c-bf53-4721178f3c7c" />


<img width="940" height="528" alt="image" src="https://github.com/user-attachments/assets/499825d0-dd9b-43e8-9d85-22de37f72255" />



