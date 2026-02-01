`timescale 1ns/1ns
`include "soc_proc_mem.v"


/*
SOC
  1. Memory    :  BRAM Hex file 
  2. Processor  :  RISC-V Normal one
*/

module soc_proc_mem_tb();

	reg clk, resetn;
	wire [4:0] LEDS; // system LEDs
	reg  rx;  // UART receive
	wire tx;   // UART transmit

	/*
	** Error (suppressible): (vsim-3053) soc_proc_mem.v(43): Illegal output or inout port connection for port 'mem_rdata'. : One side it is input and other side it output.
	In TB  : Input is reg and putput is wire ------------- Opposite nature.

	*/

	soc_proc_mem GA1 (
		.CLK(clk),  // system clock 
		.RESET(resetn),// reset button
		.LEDS(LEDS), // system LEDs
		.RXD(rx),  // UART receive
		.TXD(tx)   // UART transmit
	);

	initial begin
		clk = 0;
		resetn = 0;
		rx = 0;
		#50;
		resetn = 1;
	end

	always #10 clk = ~clk;

	initial begin
		#200000;
		$stop;
end

endmodule

















