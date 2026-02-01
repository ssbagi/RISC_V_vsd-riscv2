`timescale 1ns/1ns
`include "memory.v"
`include "Processor.v"
`include "clockworks.v"
`include "emitter_uart.v"
`include "sf_hfsoc.v"
`include "gpio.v"

/*
SOC
  1. Memory    :  BRAM Hex file 
  2. Processor  :  RISC-V Normal one
*/

module soc_proc_mem(
	input wire	     CLK,  // system clock 
	input wire	     RESET,// reset button
	output reg [4:0] LEDS, // system LEDs
	input wire	     RXD,  // UART receive
	output wire 	     TXD   // UART transmit
);

reg clk, resetn;
wire [3:0] mem_wmask;
wire [31:0] mem_rdata; 
wire gpio_out_enable;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire mem_rstrb;

/*
 ** Error (suppressible): (vsim-3053) soc_proc_mem.v(43): Illegal output or inout port connection for port 'mem_rdata'. : One side it is input and other side it output.
In TB  : Input is reg and putput is wire ------------- Opposite nature.

*/

	Processor PROC (
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

















