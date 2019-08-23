module  test_char_send
(
	input				clk,
	input				rst_n,
	output reg	[3:0] 	led,	
	output				uart_tx
);

reg		[30:0]	time_cnt;
reg		[ 7:0]	tx_data_in;
reg				tx_en;

always@(posedge clk,negedge	rst_n)
begin
	if(!rst_n)
		time_cnt	<=	'b0;
	else if( time_cnt ==	50_000_000 )		//time is 3s 
		time_cnt	<=	'b0;
	else
		time_cnt	<=	time_cnt	+	1'b1;
end


always@(*)
begin
	if( time_cnt <=	10)
		begin case( time_cnt )
			0		:	tx_data_in	=	8'h22	;
			1		:	tx_data_in	=	8'h00	;	
			2		:	tx_data_in	=	8'h22	;
			3		:	tx_data_in	=	8'h55	;
			default	:	tx_data_in	=	8'h55	;
		endcase end
	else 
		tx_data_in	=	8'h00;		
end

always@(*)			//每隔1秒，发送4个测试数据
begin
	if( time_cnt <=	3 )
		tx_en	=	1'b1;
	else
		tx_en	=	1'b0;
end	

always @(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		led	<=	4'b0001;
	else if( time_cnt	==	49_999_999 ) 
		led	<=	{led[2:0],led[3]}	;
	else
		led	<=	led;
end

	
UART_TOP UART_TOP_m0
(

	.clk				(	clk					),
	.rst_n				(	rst_n				),

	.RsRx				(						),				//Input from RS-232
	.RsTx				(	uart_tx				),				//Output to RS-232

	.tx_data_in			(	tx_data_in			),
	.rx_data_out		(						),

	.tx_en				(	tx_en				),
	.rx_en				(						),

	.uart_irq			(						)  //Interrupt
);

endmodule	