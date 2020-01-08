module uart_test_data
(
    input               		clk,
    input               		rst_n,

    output	reg					o_en,
    output	reg   [7:0]      	o_data
);

reg  	[4:0]		cnt;
reg		[30:0]		time_cnt;

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		time_cnt	<=	'b0;
	else if( time_cnt == 50_000_000 )
		time_cnt	<=	'b0;
	else
		time_cnt	<=	time_cnt	+	1'b1;
end

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		o_en	<=	1'b0;
	else if( cnt == 7 )
		o_en	<=	1'b0;
	else if( time_cnt == 50_000_000 )
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
		0		:	o_data	=	8'h01;
		1		:   o_data	=	8'h23;
		2		:   o_data	=	8'h45;
		3		:   o_data	=	8'h67;
		4		:   o_data	=	8'h89;
		5		:   o_data	=	8'hab;
		6		:   o_data	=	8'hcd;
		7		:   o_data	=	8'hef;
		default	:   o_data	=	8'b0;
	endcase

end

endmodule