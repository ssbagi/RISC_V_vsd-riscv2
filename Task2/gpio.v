module gpio_ip(
    input wire clk,
    input wire rst_n,
    input wire gpio_en,              // GPIO Enable Signal : To make sure only GPIO address is accessed.
    input wire [31:0] wdata,
    output wire [31:0] rdata,
    input wire write_enable,
    output reg [31:0] gpio_out,
    output reg out_enable
); 
    reg[31:0] gpio_in_reg; // Memory to store the last written value. 32-bit wide Register. 
    // GPIO Register Address is 0x2000_0000
    // Synchronous Clock with Synchronous reset.
    always @(posedge clk) begin
        if(!rst_n) begin
            gpio_out <= 32'b0;
            gpio_in_reg <= 32'b0;
            out_enable <= 1'b0;
        end
        else if (gpio_en) begin
            if(write_enable == 1'b1) begin
                gpio_in_reg <= wdata;
                out_enable <= 1'b1;
		        $display("TIME %t WRITE OPERATION GPIO_EN = %b WRITE_EN = %b GPIO_IN = %0h OUT_EN = %b", $time, gpio_en, write_enable, gpio_in, out_enable);
            end
            else if(write_enable == 1'b0) begin
                rdata <= gpio_in_reg;
                out_enable <= 1'b0;
		        $display("TIME %t READ OPERATION GPIO_EN = %b WRITE_EN = %b GPIO_OUT = %0X OUT_EN = %b", $time, gpio_en, write_enable, gpio_out, out_enable);
            end
        end
    end

    assign gpio_out = gpio_in_reg;

endmodule



