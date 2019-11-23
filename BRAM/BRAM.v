////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
module BRAM 
   #(	
		parameter 	MEMWIDTH 	= 20,		//1024 * data 
		parameter	DATAWIDTH 	= 1
   )               
   (
   input wire          	 			clk, 
   input wire          	 			wr_en,
   input wire	[MEMWIDTH-1:0]		waddr,		//д��ַ
   input wire	[MEMWIDTH-1:0]		raddr,		//���ַ
   input wire	[DATAWIDTH-1:0] 	data_in,	//д����
   output reg	[DATAWIDTH-1:0] 	data_out	//������
   );

// Memory Array
reg  [DATAWIDTH-1:0] memory[0:(2**MEMWIDTH-1)];

initial
begin
	$readmemh("sin_1024_14bit_signd.hex", memory);
end      

always@(posedge clk)
begin
	if( wr_en )
		memory[waddr]	<=	data_in;
	data_out	<=	memory[raddr];
end   

endmodule
