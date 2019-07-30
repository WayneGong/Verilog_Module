module  RGB_Gary_Binary
(
	input                   rst_n,   
	input                   clk,
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de, 
	input		[2:0]		key, 
	input		[11:0]		i_x,        // video position X
	input		[11:0]		i_y,         // video position y	
	input		[15:0]		i_data,
	output					th_flag,   
	output		[23:0]		o_data,
	output		[11:0]		o_x,        // video position X
	output		[11:0]		o_y,         // video position y	
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de

);
reg		[30:0]				time_cnt;
reg		[1:0]				frame_count;
reg		[7:0]				threshold	=	60;
reg		[23:0]				image_data;
wire	[16:0]				Gary_data;
wire						Binary_data;

wire	[11:0] 	x_cnt	=	i_x;
wire	[11:0]	y_cnt	=	i_y;

assign	o_data	=	image_data;
assign	o_hs	=	i_hs;
assign	o_vs	=	i_vs;	
assign	o_de	=	i_de;
assign	o_x		=	i_x;
assign	o_y		=   i_y;


assign	th_flag		=	Binary_data;
assign	Gary_data	=	{ i_data[15:11],3'd0 }*76+ { i_data[10: 5],2'd0 }*150+{ i_data[ 4: 0],3'd0 }*30	;
	
assign	Binary_data	=	(Gary_data[15:8]>=threshold)?1'b1:1'b0;

always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		threshold	<=	8'd40;
	else if(  key[1] )
		threshold	<=	threshold	+	8'd5;
	else
		threshold	<=	threshold;
end


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		frame_count	<=	2'b0;
	else if( key[0] )
		frame_count	<=	frame_count	+	1'b1;
	else
		frame_count	<=	frame_count;
end

always@(*)
begin  
	case( frame_count )
		0	:		image_data	=	{	i_data[15:11],3'd0 , i_data[10: 5],2'd0 , i_data[ 4: 0],3'd0 };
		1	:		image_data	=	{	Gary_data[15:8] , Gary_data[15:8] , Gary_data[15:8]};
		2	:		image_data	=	{	24{Binary_data}	};
		default	:	image_data	=	{	i_data[15:11],3'd0 , i_data[10: 5],2'd0 , i_data[ 4: 0],3'd0 };	
	endcase
end


endmodule