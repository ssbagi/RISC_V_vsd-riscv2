`timescale 1ns/1ns
`include "memory.v"
`include "Processor.v"

/*
SOC
  1. Memory    :  BRAM Hex file 
  2. Processor  :  RISC-V Normal one
*/

module soc_proc_mem_tb();

reg clk, resetn;
wire [3:0] mem_wmask;
wire [31:0] mem_rdata; 

wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire mem_rstrb;

/*
 ** Error (suppressible): (vsim-3053) soc_proc_mem.v(43): Illegal output or inout port connection for port 'mem_rdata'. : One side it is input and other side it output.
In TB  : Input is reg and output is wire ------------- Opposite nature.

*/

	Processor PROC (
		.clk(clk),
		.resetn(resetn),
		.mem_addr(mem_addr), 
		.mem_rdata(mem_rdata), 
		.mem_rstrb(mem_rstrb),
		.mem_wdata(mem_wdata),
		.mem_wmask(mem_wmask)
	);

	wire [31:0] RAM_rdata, GPIO_rdata, GPIO_wdata;
	wire [29:0] mem_wordaddr = mem_addr[31:2];
	wire isIO   = mem_addr[22];
	wire isGPIO = ((mem_addr & 32'hFFFF_FF00) == 32'h2000_0000); // GPIO mapped at 0x2000_0000
	wire isRAM  = !isIO;
	wire mem_wstrb = |mem_wmask;
	assign GPIO_wdata = mem_wdata;
	
	/*
       // Instantiate the Memory
	Memory RAM (
		.clk(clk),
		.mem_addr(mem_addr),
		.mem_rdata(RAM_rdata),
		.mem_rstrb(isRAM & mem_rstrb),
		.mem_wdata(mem_wdata),
		.mem_wmask({4{isRAM}}&mem_wmask)
	);
	*/
	
	Memory MEM (
		.clk(clk),
		.mem_addr(mem_addr),  		// address to be read
		.mem_rdata(mem_rdata), 		// data read from memory
		.mem_rstrb(mem_rstrb), 		// goes high when processor wants to read
		.mem_wdata(mem_wdata), 		// data to be written
		.mem_wmask(mem_wmask)	// masks for writing the 4 bytes (1=write byte)
	);
	
        gpio_ip GPIO (
      		.clk(clk),
      		.rst_n(!resetn),
      		.gpio_en(isGPIO),
      		.gpio_in(GPIO_wdata),
      		.write_enable(!mem_rstrb),
      		.gpio_out(GPIO_rdata),
      		.out_enable(gpio_out_enable)
   	); 
	

initial begin
       clk = 0;
       resetn = 0;
       #50;
       resetn = 1;
end

always #10 clk = ~clk;

initial begin
	#200000;
       $stop;
end

endmodule

















