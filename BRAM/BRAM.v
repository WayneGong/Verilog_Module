////////////////////////////////////////////////////////////////////////////////
// AHB-Lite Memory Module
////////////////////////////////////////////////////////////////////////////////
module AHB2MEM
   #(	parameter 	MEMWIDTH 	= 8,		//256 * data 
		parameter	DATAWIDTH 	= 32
   )               // Size = 32KB
   (
   input wire          	 			clk, 
   input wire          	 			wen,
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
	if(wen)
		memory[waddr]	<=	data_in;
end   

always@(posedge clk)
begin
	data_out	<=	memory[raddr];
end

endmodule
