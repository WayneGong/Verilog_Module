module uart_top
#(
	parameter	SYS_CLOCK	=	50_000_000
)
(
	input			clk,
	input			rst_n,	
	
	input	[7:0]	tx_data,
	input			tx_vld,	
	output			uart_tx,
	output			tx_done,

	output	[7:0]	rx_data,
	output			rx_vld,
	input			uart_rx

);


uart_tx uart_tx_inst
(
	.clk		(	clk			) ,	// input  clk_sig
	.nrst		(	rst_n		) ,	// input  nrst_sig
	.wrreq		(	tx_vld		) ,	// input  wrreq_sig
	.wdata		(	tx_data		) ,	// input [7:0] wdata_sig
	.tx			(	uart_tx		) ,	// output  tx_sig
	.tx_done	(	tx_done		),
	.rdy		(	tx_rdy		) 	// output  rdy_sig
);

defparam uart_tx_inst.BAUDRATE 	= 	115200;
defparam uart_tx_inst.FREQ 		= 	SYS_CLOCK;


uart_rx uart_rx_inst
(
	.clk		(	clk			) ,	// input  clk_sig
	.nrst		(	rst_n		) ,	// input  nrst_sig
	.rx			(	uart_rx	) ,	// input  rx_sig
	.rdata		(	rx_data		) ,	// output [7:0] rdata_sig
	.vld		(	rx_vld		) 	// output  	
);

defparam uart_rx_inst.BAUDRATE	= 	115200;
defparam uart_rx_inst.FREQ		= 	SYS_CLOCK;

endmodule	
