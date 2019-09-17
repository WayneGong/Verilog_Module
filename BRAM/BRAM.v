////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
module BRAM 
   #(	parameter 	MEMWIDTH 	= 10,		//1024 * data 
		parameter	DATAWIDTH 	= 32
   )               
   (
   input wire          	 			clk, 
   input wire          	 			wr_en,
   input wire						rd_en,
   input wire	[MEMWIDTH-1:0]		waddr,		//写地址
   input wire	[MEMWIDTH-1:0]		raddr,		//读地址
   input wire	[DATAWIDTH-1:0] 	data_in,	//写数据
   output reg	[DATAWIDTH-1:0] 	data_out	//读数据
   );

// Memory Array
reg  [DATAWIDTH-1:0] memory[0:(2**(MEMWIDTH)-1)];

initial
begin
	$readmemh("initial_data.hex", memory);
end      

always@(posedge clk)
begin
	if( wr_en )
		memory[waddr]	<=	data_in;
end   

always@(posedge clk)
begin
	if( rd_en )
	data_out	<=	memory[raddr];
end

endmodule
