/*

According to this there are seperate Input and Output pins.
    gpio_in[N-1:0]      Input       External GPIO inputs
    gpio_out[N-1:0]     Output      GPIO outputs

*/


module gpio_ip(
    input  wire clk,
    input  wire rst_n,
    input  wire gpio_en,               //   Address Decoding : GPIO Enable Signal : To make sure only GPIO address is accessed.
    input  wire [31:0] gpio_in,        //   GPIO Data Input from Master to GPIO   : To Write the configuration or data.
    input  wire [31:0] gpio_addr,           //   GPIO Address Input.
    output reg [31:0] gpio_out,       //   32 GPIO Input and Output pins.
    output reg [31:0] gpio_oe,        //   32 GPIO Output Enable pins.
    input  wire write_enable
); 
    reg[31:0] gpio_in_reg[15:0]; // Memory to store the last written value. 32-bit wide Register.
    reg[7:0]  addr_offset;

    always @(gpio_addr) begin
        addr_offset = gpio_addr[7:0];
    end

    always @(posedge clk) begin
        // Reset Condition
        if(!rst_n) begin
            for(integer i = 0; i < 4; i++) begin
                gpio_in_reg[i] <= 32'b0;
                gpio_out <= 32'b0;
            end
            addr_offset <= 4'b0;
        end

        else if (gpio_en) begin
            if(addr_offset == 8'h0) begin
                if(write_enable) begin
                    gpio_in_reg[addr_offset] <= gpio_in;
                    $display("T=%t | gpio_addr = %0xh | addr_offset = %0xh | WE = %0b | gpio_in_reg[0] = %0xh", $time, gpio_addr, addr_offset, write_enable, gpio_in);
                end
                else begin
                    gpio_out <= gpio_in_reg[addr_offset];
                    gpio_oe <= 32'hFFFFFFFF;
                    $display("T=%t | gpio_addr = %0xh | addr_offset = %0xh |WE = %0b | gpio_in_reg[0] = %0xh", $time, gpio_addr, addr_offset, write_enable, gpio_in_reg[0]);  
                end
            end

            // GPIO Direction Register : 0x04 : Direction setting from the gpio_in
            else if(addr_offset == 8'h4) begin
                if(write_enable) begin
                    gpio_in_reg[addr_offset] <= gpio_in;
                    $display("T=%t | gpio_addr = %0xh | addr_offset = %0xh | WE = %0b | gpio_in_reg[4] = %0xh", $time, gpio_addr, addr_offset, write_enable, gpio_in);
                end
                else begin
                    gpio_out <= gpio_in_reg[addr_offset];
                    gpio_oe <= 32'hFFFFFFFF;
                    $display("T=%t | gpio_addr = %0xh | addr_offset = %0xh | WE = %0b | gpio_in_reg[4] = %0xh", $time, gpio_addr, addr_offset, write_enable, gpio_in_reg[4]);
                end
            end

            // GPIO Read Operation : 0x08
            else if(addr_offset == 8'h8) begin
                if(write_enable == 1'b0) begin // Read Operation 
                    for(integer i = 0; i <= 31; i++) begin
                        if(gpio_in_reg[4][i] == 1'b0) begin // Input Pins :: Reflects pin state
                            gpio_in_reg[addr_offset][i] <= gpio_in[i];
                            //$display(" CFG:INPUT PIN=%d | gpio_in[%d]=%b", i, i, gpio_in[i]); 
                        end
                        else begin // Output Pins :: Reflects driven value
                            gpio_in_reg[addr_offset][i] <= gpio_out[i];
                            //$display(" CFG:OUTPUT PIN=%d | gpio_out[%d]=%b", i, i, gpio_out[i]);
                        end
                    end
                end
                //$display("T=%t | gpio_addr = %0xh | addr_offset = %0xh | WE = %0b | gpio_in_reg[8] = %0xh", $time, gpio_addr, addr_offset, write_enable, gpio_in_reg[8]);
            end

        end

    end

endmodule



