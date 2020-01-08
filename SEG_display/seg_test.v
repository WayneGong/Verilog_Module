module seg_test
(
	input      			clk,
	input      			rst_n,
	
	output		[5:0]	seg_sel,
	output		[7:0]	seg_data
);

wire	[23:0]	dis_data	=	time_cnt[43:20];
reg		[43:0]	time_cnt;

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		time_cnt	<=	'b0;
//	else if( time_cnt == 50_000_000 )
//		time_cnt	<=	'b0;
	else
		time_cnt	<=	time_cnt	+	1'b1;
end


seg_display seg_display_inst
(
	.clk		(	clk			) ,	// input  clk
	.rst_n		(	rst_n		) ,	// input  rst_n
	.dis_data	(	dis_data	) ,	// input [23:0] dis_data
	.seg_sel	(	seg_sel		) ,	// output [5:0] seg_sel
	.seg_data	(	seg_data	) 	// output [7:0] seg_data
);

endmodule