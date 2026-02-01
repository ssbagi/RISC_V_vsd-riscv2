`timescale 1ns/1ns
`include "riscv.v"

module riscv_tb();

    reg clk, reset, rx;
    wire tx;
    wire [4:0] leds;

    SOC riscv_soc(
        .CLK(clk),
        .RESET(reset),
        .RXD(rx),
        .TXD(tx),
        .LEDS(leds)
    );

    initial begin
        clk = 0;
        rx = 0;
        reset = 1;
        #50;
        reset = 0;
    end

    // Generating a clk of period 10ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("riscv_gpio_soc_task3.vcd");
        $dumpvars(0);
        $dumpvars(0, riscv_soc);
        //$dumpvars(0, riscv_soc.SOC.GPIO.gpio_in_reg[0]);
        //$dumpvars(0, riscv_soc.SOC.GPIO.gpio_in_reg[4]);
        //$dumpvars(0, riscv_soc.SOC.GPIO.gpio_in_reg[8]);
    end


    initial begin
        #200000;
        $stop;
    end

endmodule




