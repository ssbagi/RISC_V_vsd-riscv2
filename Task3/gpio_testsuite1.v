`timescale 1ns/1ns
`include "gpio.v"

module gpio_tb;

    reg clk, rst_n;
    reg gpio_en, write_enable;
    reg [31:0] gpio_in;
    reg [31:0] gpio_addr;

    wire [31:0] gpio_out;

    // gpio_oe is input in RTL, ignore it for now
    wire [31:0] gpio_oe;

    gpio_ip DUT (
        .clk(clk),
        .rst_n(rst_n),
        .gpio_en(gpio_en),
        .gpio_in(gpio_in),
        .gpio_addr(gpio_addr),
        .gpio_out(gpio_out),
        .gpio_oe(gpio_oe),
        .write_enable(write_enable)
    );

    // Clock generation
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        gpio_en = 0;
        write_enable = 0;
        gpio_in = 0;
        gpio_addr = 0;
    end

    initial begin
        $dumpfile("gpio_fullsuite.vcd");
        $dumpvars(0, gpio_tb);
        $dumpvars(0, DUT.gpio_in_reg[0]);
        $dumpvars(0, DUT.gpio_in_reg[4]);
        $dumpvars(0, DUT.gpio_in_reg[8]);
    end

    initial begin
        $display("\n================ GPIO TEST SUITE STARTED ================\n");

        #50 rst_n = 1;

        // ============================================================
        // TESTCASE 1: Odd OUTPUT, Even INPUT (DIR = 0xAAAAAAAA)
        // ============================================================
        $display("\n--- TESTCASE 1: Odd OUTPUT, Even INPUT ---");

        // 1. Set DIR
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000004;
        gpio_in      = 32'hAAAAAAAA;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 2. Write DATA
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000000;
        gpio_in      = 32'hDEADBEEF;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 3. Read READ register
        gpio_en      = 1;
        write_enable = 0;
        gpio_addr    = 32'h20000008;
        gpio_in      = 32'hCAFEBABE;   // external input for even pins
        #20 gpio_en = 0;

        #60;


        // ============================================================
        // TESTCASE 2: Odd INPUT, Even OUTPUT (DIR = 0x55555555)
        // ============================================================
        $display("\n--- TESTCASE 2: Odd INPUT, Even OUTPUT ---");

        // 1. Set DIR
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000004;
        gpio_in      = 32'h55555555;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 2. Write DATA
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000000;
        gpio_in      = 32'hA5A5A5A5;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 3. Read READ register
        gpio_en      = 1;
        write_enable = 0;
        gpio_addr    = 32'h20000008;
        gpio_in      = 32'h12345678;   // external input for odd pins
        #20 gpio_en = 0;

        #60;


        // ============================================================
        // TESTCASE 3: Lower 16 INPUT, Upper 16 OUTPUT (DIR = 0xFFFF0000)
        // ============================================================
        $display("\n--- TESTCASE 3: Lower 16 INPUT, Upper 16 OUTPUT ---");

        // 1. Set DIR
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000004;
        gpio_in      = 32'hFFFF0000;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 2. Write DATA
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000000;
        gpio_in      = 32'hA5A5A5A5;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 3. Read READ register
        gpio_en      = 1;
        write_enable = 0;
        gpio_addr    = 32'h20000008;
        gpio_in      = 32'h12345678;   // external input for lower 16 bits
        #20 gpio_en = 0;

        #60;


        // ============================================================
        // TESTCASE 4: Lower 16 OUTPUT, Upper 16 INPUT (DIR = 0x0000FFFF)
        // ============================================================
        $display("\n--- TESTCASE 4: Lower 16 OUTPUT, Upper 16 INPUT ---");

        // 1. Set DIR
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000004;
        gpio_in      = 32'h0000FFFF;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 2. Write DATA
        gpio_en      = 1;
        write_enable = 1;
        gpio_addr    = 32'h20000000;
        gpio_in      = 32'hDEADBEEF;
        #20 gpio_en = 0; write_enable = 0;

        #40;

        // 3. Read READ register
        gpio_en      = 1;
        write_enable = 0;
        gpio_addr    = 32'h20000008;
        gpio_in      = 32'hCAFEBABE;   // external input for upper 16 bits
        #20 gpio_en = 0;

        #60;


        // ============================================================
        // END OF TEST SUITE
        // ============================================================
        $display("\n================ ALL TESTCASES COMPLETED ================\n");

        #100 $stop;
    end

endmodule










