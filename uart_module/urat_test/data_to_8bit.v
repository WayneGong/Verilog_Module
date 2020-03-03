module data_64bit_to_8bit
#(
	parameter	INPUT_WIDTH	=	64
)
(
    input               		clk,
    input               		rst_n,
    input               		i_en,
    input    	[INPUT_WIDTH-1:0]			i_data,
    output	reg					o_en,
    output	reg   [7:0]      	o_data
);

reg  	[4:0]		cnt;
reg		[63:0]		i_data_reg;

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		i_data_reg	<=	64'b0;
	else if( i_en )
		i_data_reg	<=	i_data;
end

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		o_en	<=	1'b0;
	else if( cnt == 7 )
		o_en	<=	1'b0;
	else if( i_en )
		o_en	<=	1'b1;
	else
		o_en	<=	o_en;
end

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		cnt	<=	5'b0;
	else if( cnt == 7 )
		cnt	<=	5'b0;
	else if( o_en )
		cnt	<=	cnt	+	1'b1;
	else
		cnt	<=	5'b0;
end    

always@(*)
begin
	case(cnt)
		0		:	o_data	=	i_data_reg[63:56];
		1		:   o_data	=	i_data_reg[55:48];
		2		:   o_data	=	i_data_reg[47:40];
		3		:   o_data	=	i_data_reg[39:32];
		4		:   o_data	=	i_data_reg[31:24];
		5		:   o_data	=	i_data_reg[23:16];
		6		:   o_data	=	i_data_reg[15:8];
		7		:   o_data	=	i_data_reg[7:0];
		default	:   o_data	=	8'b0;
	endcase

end

endmodule