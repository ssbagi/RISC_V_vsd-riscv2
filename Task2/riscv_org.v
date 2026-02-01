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
   assign clk = CLK;
   assign resetn = RESET;

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

   /*
   SB_HFOSC #(
   .CLKHF_DIV("0b10") // 12 MHz
   ) hfosc (
      .CLKHFPU(1'b1),
      .CLKHFEN(1'b1),
      .CLKHF(clk_int)
   );
  */

/*
   // Gearbox and reset circuitry.
   Clockworks CW(
     .CLK(clk_int),
     .RESET(RESET),
     .clk(clk),
     .resetn(resetn)
   );
*/

endmodule











