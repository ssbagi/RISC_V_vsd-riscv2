

module gpio_ip(
    input clk,
    input rst_n,
    input [31:0] gpio_in,
    input write_enable,
    output reg [31:0] gpio_out,
    output reg out_enable
); 
    reg[31:0] gpio_in_reg; // Memory to store the last written value. 32-bit wide Register. 

    // Synchronous Clock with Synchronous reset
    always @(posedge clk) begin
        if(rst_n) begin
            gpio_in <= 32'b0;
            out_enable <= 1'b0;
        end
        else if(write_enable == 1'b1) begin
            gpio_in_reg <= gpio_in;
            /*
                It's good not to change the state of the gpio_out ---------- Power consumption due to switching of states.
                gpio_out <= 32'bz;
                While writing we don't need to read the gpio_out. So, disable the output.
            */
            out_enable <= 1'b1;
            $display("GPIO Write Operation : Written Value = %h", gpio_in);
        end
        else if(write_enable == 1'b0) begin
            gpio_out <= gpio_in_reg;
            out_enable <= 1'b0;
            $display("GPIO Read Operation : Read Value = %h", gpio_out);
        end
    end

endmodule





