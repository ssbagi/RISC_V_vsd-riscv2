
# RISCV SoC Block Diagram 

The Basic SoC Block daigram overview. The details as per my understanding. There are logic in between for the selection which is written in verilog not be considered here for accuracy. 

<img width="3000" height="2928" alt="image" src="https://github.com/user-attachments/assets/80f86193-fb65-4469-a613-39cf38013d4f" />


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
GPIO IP VERILOG CODE

Type 1 :

Address Decoding is like this :
wire isGPIO = isIO & (mem_addr[21:20] == 2'b00); // GPIO mapped at 0x0040_0000 - 0x005F_FFFF
.write_enable(isGPIO & !mem_rstrb),       // GPIO WE = 1 when CPU wants to write to GPIO. Otherwise it will be read operation.

Hardcoded the GPIO ADDRESS = 0x2000_0000
wire isGPIO = ((mem_addr & 32'hFFFF_FF00) == 32'h2000_0000); // GPIO mapped at 0x2000_0000  -------- AT SoC Level making this change.

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
        else(gpio_addr) begin // The Register write will happen only if we have GPIO_ADDR == 0x2000_0000 . Since asked for only one 32bit Register.
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
    reg[7:0] out_reg = gpio_addr[7:0]; // Using lower 2 bits of address for selecting register.
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

```

# GPIO Simulation Waveform

If we observe at T = 100ns. We see Writing to 00003D6C. After that write_enable = 1. Hence, Until write_enable becomes 1. It always gives previous written value.

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/211a91ae-67e6-4ff0-a9a8-4dc8eba3d36f" />


The write_enable = 1. We see multiple writes happening to the register on every clk posedge. 

<img width="1918" height="337" alt="image" src="https://github.com/user-attachments/assets/7c5c9987-439f-40c0-a889-9640daf248b8" />

GPIO REGISTER BANK

In the below waveform if we observe at Time 1520ns. The Register Number = 5, WE = 1 hence in the register 5 we see the output being written to it. At 1540ns we see WE = 1. The Register selected is 8'b3B = 59. Writing.  
At Time 1560ns we observe that WE = 0. It reads the latest written Register value only as output. 
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/60a69f9f-503e-4660-93aa-12902bd6acc4" />

<img width="1919" height="1055" alt="image" src="https://github.com/user-attachments/assets/544900d1-cfe5-47dc-bca3-45f36f5f0ffb" />


# Integration the GPIO into the RISC-V Core

The Whole Integration of the code.

```


module SOC (
    //  input 	     CLK,  // system clock 
    input 	     RESET,// reset button
    output reg [4:0] LEDS, // system LEDs
    input 	     RXD,  // UART receive
    output 	     TXD   // UART transmit
);

   wire clk;
   wire resetn;
   wire gpio_out_enable;
   wire [31:0] mem_addr;
   wire [31:0] mem_rdata;
   wire mem_rstrb;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wmask;

   // Instantiate the RISC-V Processor
   Processor CPU(
      .clk(clk),
      .resetn(resetn),		 
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
   wire GPIO_wdata = mem_wdata;
   
   // Instantiate the Memory
   Memory RAM(
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

   gpio_ip GPIO(
      .clk(clk),
      .rst_n(resetn),
      .gpio_addr(isGPIO & mem_addr),              // GPIO address from CPU.
      .gpio_in(GPIO_wdata),                      // GPIO input from CPU.
      .write_enable(!mem_rstrb),                 // GPIO WE = 1 when CPU wants to write to GPIO. Otherwise it will be read operation.
      .gpio_out(GPIO_rdata),                    // GPIO output.
      .out_enable(gpio_out_enable)              // GPIO output enable signal high during write operation from CPU to GPIO.
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
   
   assign mem_rdata = isRAM ? RAM_rdata : IO_rdata ;
   assign mem_rdata = isGPIO & !mem_rstrb ? GPIO_rdata : mem_rdata ;
   
   
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
     .CLK(clk_int),
     .RESET(RESET),
     .clk(clk),
     .resetn(resetn)
   );


endmodule

```

# Whole SoC Waveform

Developing the Testbench : I will use the Waveform simulation for the SoC in the Toolchain I could not do. 


# YOSYS, ROUTING FPGA COMPIALTION


<img width="940" height="528" alt="image" src="https://github.com/user-attachments/assets/126055ed-7a03-4f4c-bf53-4721178f3c7c" />


<img width="940" height="528" alt="image" src="https://github.com/user-attachments/assets/499825d0-dd9b-43e8-9d85-22de37f72255" />



