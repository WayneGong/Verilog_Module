
 module top(
input                       clk,
input                       rst_n,
input		[3:1]			key,
output			            uart_tx,
input			            uart_rx,
output       [3:0]            led

                     
);

assign	led	=	{key,1'b0};

wire	[7:0]	tx_data;
wire			tx_en;			

uart_top 
#(
	.SYS_CLK_FRP	(	50_000_000	),
	.BAUDRATE		(	9600    	)
)
uart_top_test
(
	.clk			(	clk		),
	.rst_n			(	rst_n		),	
	
	.tx_data		(	tx_data		),		//input
	.tx_en			(	tx_en		),		//input
	.uart_tx		(	uart_tx		),		//output
					
	.rx_data		(	rx_data		),		//output	
	.rx_done		(	rx_done		),		//output
	.uart_rx		(	uart_rx		)		//input
);

uart_test_data uart_test_data_m0 
(
    .clk			(	clk					),
    .rst_n			(	rst_n				),   
    .o_en			(	tx_en				),
	.o_data			(	tx_data				)    

);


endmodule