`timescale 1ns/1ns
/*
	DUMMY CODE GIVEN
*/

module SB_HFOSC(
	input wire CLKHFEN,
	input wire CLKHFPU,
	output reg CLKHF
);

	parameter CLKHF_DIV = "0b00";

	initial begin
		CLKHF = 0;
	end

	always #41.66 CLKHF = ~CLKHF;
	
	/*
		Freq  = 12MHz
		Time = (1/12MHz) = 83.33ns.
		50% duty Cycle ---- 41.66ns.
	*/

endmodule


