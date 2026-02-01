`timescale 1ns/1ns
`include "Processor.v"
module processor_tb;

    // Clock + Reset
    reg clk;
    reg resetn;

    // Processor <-> Memory interface
    wire [31:0] mem_addr;
    reg  [31:0] mem_rdata;
    wire        mem_rstrb;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wmask;
    reg [31:0] mem [0:65535]; // 256 KB memory

    // Instantiate the Processor
    Processor dut (
        .clk(clk),
        .resetn(resetn),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_rstrb(mem_rstrb),
        .mem_wdata(mem_wdata),
        .mem_wmask(mem_wmask)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // ---------------------------------------------------------
    // Simple dummy memory model for standalone CPU testing
    // ---------------------------------------------------------
    // You can hardcode a few instructions here to test:
    // Example: ADDI x1, x0, 5  --> 0x00500093
    //          ADDI x2, x0, 7  --> 0x00700113
    //          ADD  x3, x1, x2 --> 0x002081B3
    //          EBREAK          --> 0x00100073 (SYSTEM)
    // ---------------------------------------------------------
    
    /*
    always @(*) begin
        case (mem_addr)
            32'h0000_0000: mem_rdata = 32'h00500093; // addi x1, x0, 5
            32'h0000_0004: mem_rdata = 32'h00700113; // addi x2, x0, 7
            32'h0000_0008: mem_rdata = 32'h002081B3; // add  x3, x1, x2
            32'h0000_000C: mem_rdata = 32'h00100073; // ebreak (SYSTEM)
            default:       mem_rdata = 32'h00000013; // nop
        endcase
    end
    */

// --------------------------------------------------------- // Memory model using external HEX file // --------------------------------------------------------- 
	 
	initial begin 
		$readmemh("gpio_test_4.hex", mem); 
	end 
	always @(*) begin 
		if (mem_rstrb) mem_rdata = mem[mem_addr[31:2]]; // word aligned 
	end

    // ---------------------------------------------------------
    // Testbench control
    // ---------------------------------------------------------
    initial begin
        clk = 0;
        resetn = 0;

        // Hold reset
        #50;
        resetn = 1;

        // Run CPU for some time
        #100000;

        $display("Standalone Processor test completed.");
        $stop;
    end

    // VCD dump
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, processor_tb);
    end

endmodule
