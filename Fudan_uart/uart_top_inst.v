//port
input			uart_rx,
output			uart_tx,

uart_top 
#( 
	.SYS_CLOCK(50_000_000)
)uart_top_test
(
	.clk			(	clk			),
	.rst_n			(	rst_n		),	
					
	.rx_data		(	rx_data		),
	.rx_vld			(	rx_vld		),	
	.uart_tx		(	uart_tx		),
					
	.tx_data		(	tx_data		),
	.tx_vld			(	tx_vld		),
	.uart_rx		(	uart_rx		)
);

