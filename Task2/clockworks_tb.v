`timescale 1ns/1ns
`include "clockworks.v"

module clockworks_tb();

reg CLK, RESET;
wire clk, resetn;

	Clockworks CW1 (
		.CLK(CLK), // clock pin of the board
		.RESET(RESET), // reset pin of the board
		.clk(clk),   // (optionally divided) clock for the design ---- divided if SLOW is different from zero.
		.resetn(resetn) // (optionally timed) negative reset for the design
	);  

initial begin
CLK = 0;
RESET = 0;
end

always #5 CLK = ~CLK;

initial begin
	RESET = 0;
	#100;
	RESET = 1;
	#1500;
	$finish;
end

endmodule





