//RS-232  Transmitter and receiver module

module UART_TOP(
//clock and resetn
	input						clk,
	input						rst_n,
//Serial Port Signals
	input		wire			RsRx,				//Input from RS-232
	output	wire			RsTx,				//Output to RS-232
  
//tx_data_in,rx_data_out
	input		wire	[7:0]	tx_data_in,
	output	wire	[7:0]	rx_data_out,

//data enable Signals
	input		wire			tx_en,
	input		wire			rx_en,
//UART Interrupt
  
  output		wire			uart_irq  //Interrupt
);

//Internal Signals
  
//Data I/O between AHB and FIFO
	wire [7:0]	uart_wdata;  
	wire [7:0] 	uart_rdata;
  
//Signals from TX/RX to FIFOs
	wire 			uart_wr;
	wire 			uart_rd;
  
//wires between FIFO and TX/RX
	wire	[7:0]	tx_data;
	wire	[7:0]	rx_data;
	wire	[7:0] status;
  
//FIFO Status
	wire			tx_full;
	wire			tx_empty; 
	wire			rx_full;
	wire			rx_empty;
  
//UART status ticks
	wire			tx_done;
	wire			rx_done;
  
//baud rate signal
	wire			b_tick;
  
   
   
//UART  write select
	assign 	uart_wr 		= 	tx_en;
	assign 	uart_wdata	= 	tx_data_in;

//UART read select
	assign	uart_rd 		=	rx_en;
	assign	rx_data_out	=	uart_rdata;
  
	assign 	uart_irq		=	~rx_empty; 
  
//generate a fixed baud rate 19200bps
BAUDGEN uBAUDGEN
(
    .clk			(	clk				),
    .resetn		(	rst_n				),
    .baudtick	(	b_tick			)
);
  
//Transmitter FIFO
FIFO  
   #(.DWIDTH(8), .AWIDTH(8))
uFIFO_TX 
(
    .clk			(	clk					),
    .resetn		(	rst_n					),
    .rd			(	tx_done				),
    .wr			(	uart_wr				),
    .w_data		(	uart_wdata[7:0]	),
    .empty		(	tx_empty				),
    .full		(	tx_full				),
    .r_data		(	tx_data[7:0]		)
);
  
//Receiver FIFO
FIFO
	#(.DWIDTH(8), .AWIDTH(8))
uFIFO_RX
(
	.clk			(	clk					),
	.resetn		(	rst_n					),
	.rd			(	uart_rd				),
	.wr			(	rx_done				),
	.w_data		(	rx_data[7:0]		),
	.empty		(	rx_empty				),
	.full			(	rx_full				),
	.r_data		(	uart_rdata[7:0]	)
);
  
//UART receiver
UART_RX uUART_RX
(
	.clk			(	clk					),
	.resetn		(	rst_n					),
	.b_tick		(	b_tick				),
	.rx			(	RsRx					),
	.rx_done		(	rx_done				),
	.dout			(	rx_data[7:0]		)
);
  
//UART transmitter
UART_TX uUART_TX
(
	.clk			(	clk					),
	.resetn		(	rst_n					),
	.tx_start	(	!tx_empty			),
	.b_tick		(	b_tick				),
	.d_in			(	tx_data[7:0]		),
	.tx_done		(	tx_done				),
	.tx			(	RsTx					)
);
 
 
  
endmodule
