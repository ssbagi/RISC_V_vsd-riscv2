`timescale 1ns/1ns
`include "gpio.v"

module gpio_tb;

    reg clk, rst_n;
    reg gpio_en, write_enable;
    reg [31:0] gpio_in;
    reg [31:0] gpio_addr;

    wire [31:0] gpio_out;
    wire [31:0] gpio_oe; // unused in TB, driven by DUT

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

    // Init
    initial begin
        clk = 0;
        rst_n = 0;
        gpio_en = 0;
        write_enable = 0;
        gpio_in = 0;
        gpio_addr = 0;
    end

    // Dump
    initial begin
        $dumpfile("gpio_fullsuite.vcd");
        $dumpvars(0, gpio_tb);
        $dumpvars(0, DUT.gpio_in_reg[0]);
        $dumpvars(0, DUT.gpio_in_reg[4]);
        $dumpvars(0, DUT.gpio_in_reg[8]);
    end

    // Stimulus
    initial begin
        $display("\n================ GPIO TEST SUITE STARTED ================\n");

        #50 rst_n = 1;

        // ============================================================
        // GROUP A — BASIC FUNCTIONAL (1–4)
        // ============================================================

        // TESTCASE 1: Odd OUTPUT, Even INPUT (DIR = 0xAAAAAAAA)
        $display("\n--- TC1: Odd OUTPUT, Even INPUT (DIR=AAAAAAAA) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hAAAAAAAA;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hDEADBEEF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'hCAFEBABE;
        #20 gpio_en=0; #60;

        // TESTCASE 2: Odd INPUT, Even OUTPUT (DIR = 0x55555555)
        $display("\n--- TC2: Odd INPUT, Even OUTPUT (DIR=55555555) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'h55555555;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hA5A5A5A5;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h12345678;
        #20 gpio_en=0; #60;

        // TESTCASE 3: Lower 16 INPUT, Upper 16 OUTPUT (DIR = 0xFFFF0000)
        $display("\n--- TC3: Lower16 INPUT, Upper16 OUTPUT (DIR=FFFF0000) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hFFFF0000;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hA5A5A5A5;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h12345678;
        #20 gpio_en=0; #60;

        // TESTCASE 4: Lower 16 OUTPUT, Upper 16 INPUT (DIR = 0x0000FFFF)
        $display("\n--- TC4: Lower16 OUTPUT, Upper16 INPUT (DIR=0000FFFF) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'h0000FFFF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hDEADBEEF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'hCAFEBABE;
        #20 gpio_en=0; #60;

        // ============================================================
        // GROUP B — EXTENDED (5–8) WITH DATA READBACK
        // ============================================================

        // TESTCASE 5: Odd OUTPUT, Even INPUT + DATA READBACK
        $display("\n--- TC5: Odd OUTPUT, Even INPUT + DATA READBACK ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hAAAAAAAA;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hDEADBEEF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000000;
        #20 gpio_en=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'hCAFEBABE;
        #20 gpio_en=0; #60;

        // TESTCASE 6: Odd INPUT, Even OUTPUT + DATA READBACK
        $display("\n--- TC6: Odd INPUT, Even OUTPUT + DATA READBACK ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'h55555555;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hA5A5A5A5;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000000;
        #20 gpio_en=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h12345678;
        #20 gpio_en=0; #60;

        // TESTCASE 7: Lower16 INPUT, Upper16 OUTPUT + DATA READBACK
        $display("\n--- TC7: Lower16 INPUT, Upper16 OUTPUT + DATA READBACK ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hFFFF0000;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hA5A5A5A5;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000000;
        #20 gpio_en=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h12345678;
        #20 gpio_en=0; #60;

        // TESTCASE 8: Lower16 OUTPUT, Upper16 INPUT + DATA READBACK
        $display("\n--- TC8: Lower16 OUTPUT, Upper16 INPUT + DATA READBACK ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'h0000FFFF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hDEADBEEF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000000;
        #20 gpio_en=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'hCAFEBABE;
        #20 gpio_en=0; #60;

        // ============================================================
        // GROUP C — EXTREME DIR PATTERNS (9–12)
        // ============================================================

        // TESTCASE 9: All INPUT (DIR = 0x00000000)
        $display("\n--- TC9: All INPUT (DIR=00000000) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'h00000000;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hFACEB00C;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h87654321;
        #20 gpio_en=0; #60;

        // TESTCASE 10: All OUTPUT (DIR = 0xFFFFFFFF)
        $display("\n--- TC10: All OUTPUT (DIR=FFFFFFFF) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hFFFFFFFF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hCAFED00D;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h11223344;
        #20 gpio_en=0; #60;

        // TESTCASE 11: Upper 8 OUTPUT, Lower 24 INPUT (DIR = 0xFF000000)
        $display("\n--- TC11: Upper8 OUTPUT, Lower24 INPUT (DIR=FF000000) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hFF000000;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'h0F0F0F0F;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'hABCDEF12;
        #20 gpio_en=0; #60;

        // TESTCASE 12: Upper 24 OUTPUT, Lower 8 INPUT (DIR = 0x00FFFFFF)
        $display("\n--- TC12: Upper24 OUTPUT, Lower8 INPUT (DIR=00FFFFFF) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'h00FFFFFF;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'h1234ABCD;
        #20 gpio_en=0; write_enable=0; #40;
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h55667788;
        #20 gpio_en=0; #60;

        // ============================================================
        // GROUP D — ADVANCED / HAZARD / STRESS (13–16)
        // ============================================================

        // TESTCASE 13: Back-to-Back DATA Writes (DIR = 0xFFFFFFFF)
        $display("\n--- TC13: Back-to-Back DATA Writes (DIR=FFFFFFFF) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hFFFFFFFF;
        #20 gpio_en=0; write_enable=0; #40;
        // First DATA write
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'h11111111;
        #20;
        // Second DATA write without big gap
        gpio_in=32'h22222222;
        #20 gpio_en=0; write_enable=0; #40;
        // READ register
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h00000000;
        #20 gpio_en=0; #60;

        // TESTCASE 14: Read-After-Write Hazard (DIR = 0xAAAAAAAA)
        $display("\n--- TC14: Read-After-Write Hazard (DIR=AAAAAAAA) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hAAAAAAAA;
        #20 gpio_en=0; write_enable=0; #40;
        // DATA write
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'hCAFEBABE;
        #20 gpio_en=0; write_enable=0;
        // Immediate READ
        #1  gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h12345678;
        #20 gpio_en=0; #60;

        // TESTCASE 15: Glitching gpio_en during access (DIR = 0x55555555)
        $display("\n--- TC15: Glitching gpio_en (DIR=55555555) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'h55555555;
        #20 gpio_en=0; write_enable=0; #40;
        // DATA write with glitch on gpio_en
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'h0F0F0F0F;
        #5  gpio_en=0;
        #5  gpio_en=1;
        #10 gpio_en=0; write_enable=0; #40;
        // READ
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'hAAAAAAAA;
        #20 gpio_en=0; #60;

        // TESTCASE 16: Random-like External Input Reflection (DIR = 0xA5A5A5A5)
        $display("\n--- TC16: Random-like External Input Reflection (DIR=A5A5A5A5) ---");
        gpio_en=1; write_enable=1; gpio_addr=32'h20000004; gpio_in=32'hA5A5A5A5;
        #20 gpio_en=0; write_enable=0; #40;
        // DATA write
        gpio_en=1; write_enable=1; gpio_addr=32'h20000000; gpio_in=32'h5A5A5A5A;
        #20 gpio_en=0; write_enable=0; #40;
        // READ with "random" external input
        gpio_en=1; write_enable=0; gpio_addr=32'h20000008; gpio_in=32'h3C3C3C3C;
        #20 gpio_en=0; #60;

        // ============================================================
        // END OF TEST SUITE
        // ============================================================
        $display("\n================ ALL 16 TESTCASES COMPLETED ================\n");

        #100 $stop;
    end

endmodule
