module seg_display
(
	input      			clk,
	input      			rst_n,
	input		[23:0]	dis_data,
	output	reg	[5:0]	seg_sel,
	output	reg	[7:0]	seg_data
);

parameter	SET_DIS_TIME	=	50_000 - 1;

//数码管要显示的数据
wire	[3:0]      seg0_data	=	dis_data[23:20];
wire	[3:0]      seg1_data	=	dis_data[19:16];
wire	[3:0]      seg2_data	=	dis_data[15:12];
wire	[3:0]      seg3_data	=	dis_data[11:8];
wire	[3:0]      seg4_data	=	dis_data[7:4];
wire	[3:0]      seg5_data	=	dis_data[3:0];

reg		[3:0]      seg_data_mux;


reg	[20:0]	dis_time_cnt;
reg	[3:0]	seg_cnt;

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		dis_time_cnt	<=	'b0;
	else if( dis_time_cnt == SET_DIS_TIME )
		dis_time_cnt	<=	'b0;
	else
		dis_time_cnt	<=	dis_time_cnt	+	1'b1;
end

always@(posedge clk,negedge rst_n )
begin
	if(!rst_n)
		seg_cnt	<=	'b0;
	else if( dis_time_cnt == SET_DIS_TIME )
		seg_cnt	<=	seg_cnt	+	1'b1;		
	else
		seg_cnt	<=	seg_cnt;
end

always@(*)
begin
	case(seg_cnt)
		0		:	seg_data_mux	=	seg0_data;			
		1		:	seg_data_mux	=	seg1_data;
		2		:	seg_data_mux	=	seg2_data;
		3		:	seg_data_mux	=	seg3_data;
		4		:	seg_data_mux	=	seg4_data;
		5		:	seg_data_mux	=	seg5_data;
		default	:	seg_data_mux	=	0;
	endcase	
end


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		seg_data <= 7'b111_1111;
	case( seg_data_mux )
		4'd0:seg_data <= 7'b100_0000;
		4'd1:seg_data <= 7'b111_1001;
		4'd2:seg_data <= 7'b010_0100;
		4'd3:seg_data <= 7'b011_0000;
		4'd4:seg_data <= 7'b001_1001;
		4'd5:seg_data <= 7'b001_0010;
		4'd6:seg_data <= 7'b000_0010;
		4'd7:seg_data <= 7'b111_1000;
		4'd8:seg_data <= 7'b000_0000;
		4'd9:seg_data <= 7'b001_0000;
		4'ha:seg_data <= 7'b000_1000;
		4'hb:seg_data <= 7'b000_0011;
		4'hc:seg_data <= 7'b100_0110;
		4'hd:seg_data <= 7'b010_0001;
		4'he:seg_data <= 7'b000_0110;
		4'hf:seg_data <= 7'b000_1110;
		default:seg_data <= 7'b111_1111;
	endcase
end


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)	
		seg_sel <= 6'b111111;	
	else case(seg_cnt)
		//first digital led
		4'd0	:	seg_sel <= 6'b11_1110;
		4'd1	:	seg_sel <= 6'b11_1101;			
		4'd2	:	seg_sel <= 6'b11_1011;			
		4'd3	:	seg_sel <= 6'b11_0111;
		4'd4	:	seg_sel <= 6'b10_1111;			
		4'd5	:	seg_sel <= 6'b01_1111;
		default	:	seg_sel <= 6'b11_1111;			
	endcase	
end

endmodule
