module Memory (
   input  wire           clk,
   input  wire    [31:0] mem_addr,  // address to be read
   output reg [31:0] mem_rdata, // data read from memory
   input  wire 	     mem_rstrb, // goes high when processor wants to read
   input  wire    [31:0] mem_wdata, // data to be written
   input  wire    [3:0]  mem_wmask	// masks for writing the 4 bytes (1=write byte)
);

   reg [31:0] MEM [0:1535]; // 1536 4-bytes words = 6 Kb of RAM in total

   initial begin
      $readmemh("gpio_test_task3.hex", MEM);
   end

   wire [29:0] word_addr = mem_addr[31:2];
   
   always @(posedge clk) begin
      if(mem_rstrb) begin
         mem_rdata <= MEM[word_addr];
	      //$display(" MEM_RSTRB = 1. READ DATA FROM MEMORY. ADDRESS : %0xh : MEM RDATA : %0xh", word_addr, MEM[word_addr]);
      end
      if(mem_wmask[0]) begin
		   MEM[word_addr][ 7:0 ] <= mem_wdata[ 7:0 ];
		   //$display(" WRITE TO MEMORY : WMASK = BYTE0 :: WRITE DATA : %0xh",  mem_wdata[ 7:0 ]);
      end
      if(mem_wmask[1]) begin 
         MEM[word_addr][15:8 ] <= mem_wdata[15:8 ]; 
		   //$display(" WRITE TO MEMORY : WMASK = BYTE1 :: WRITE DATA : %0xh",  mem_wdata[ 15:8 ]);
      end
      if(mem_wmask[2]) begin 
		   MEM[word_addr][23:16] <= mem_wdata[23:16]; 
		   //$display(" WRITE TO MEMORY : WMASK = BYTE2 :: WRITE DATA : %0xh",  mem_wdata[ 23:16 ]);
      end
      if(mem_wmask[3]) begin 
		   MEM[word_addr][31:24] <= mem_wdata[31:24]; 
		   //$display(" WRITE TO MEMORY : WMASK = BYTE3 :: WRITE DATA : %0xh",  mem_wdata[ 31:24 ]);
      end
   end
endmodule






