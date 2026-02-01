`timescale 1ns/1ns

module memory_tb;

    reg         clk;
    reg  [31:0] mem_addr;
    reg         mem_rstrb;
    wire [31:0] mem_rdata;
    reg  [31:0] mem_wdata;
    reg  [3:0]  mem_wmask;

    // DUT instantiation
    Memory dut (
        .clk(clk),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_rstrb(mem_rstrb),
        .mem_wdata(mem_wdata),
        .mem_wmask(mem_wmask)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        mem_addr = 0;
        mem_rstrb = 0;
        mem_wdata = 0;
        mem_wmask = 0;

        // Allow firmware.hex to load
        #20;

        // -------------------------------
        // 1. READ FROM PRELOADED MEMORY
        // -------------------------------
        $display("Reading initial memory contents...");
        mem_addr = 32'h0000_0000;
        mem_rstrb = 1;
        #10;
        mem_rstrb = 0;
        #10;

        $display("Read data = %h", mem_rdata);

        // -------------------------------
        // 2. FULL WORD WRITE
        // -------------------------------
        $display("Writing full word...");
        mem_addr  = 32'h0000_0004;
        mem_wdata = 32'hDEADBEEF;
        mem_wmask = 4'b1111;   // write all bytes
        #10;
        mem_wmask = 4'b0000;   // stop writing
        #10;

        // Read back
        mem_rstrb = 1;
        #10;
        mem_rstrb = 0;
        #10;

        $display("Read back = %h", mem_rdata);

        // -------------------------------
        // 3. BYTE?MASKED WRITE
        // -------------------------------
        $display("Writing only byte[0]...");
        mem_addr  = 32'h0000_0008;
        mem_wdata = 32'hAABBCCDD;
        mem_wmask = 4'b0001;   // write only lowest byte
        #10;
        mem_wmask = 4'b0000;
        #10;

        // Read back
        mem_rstrb = 1;
        #10;
        mem_rstrb = 0;
        #10;

        $display("Masked write result = %h", mem_rdata);

        // -------------------------------
        // END SIMULATION
        // -------------------------------
        #50;
        $stop;
    end

    // VCD dump
    initial begin
        $dumpfile("memory_tb.vcd");
        $dumpvars(0, memory_tb);
    end

endmodule
