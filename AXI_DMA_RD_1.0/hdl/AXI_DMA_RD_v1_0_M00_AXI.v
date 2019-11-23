
`timescale 1 ns / 1 ps

	module AXI_DMA_RD_v1_0_M00_AXI #
	(
		// Users to add parameters here
		
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Base address of targeted slave
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 256,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 64,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 0,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 0,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here
		output	wire			tout,
		input	wire			pixel_clk,
		input	wire			r_fifo_en,
		output	wire	[31:0]	r_fifo_data,
		output	reg				vga_start,	
		// User ports ends
		// Do not modify the ports beyond this line

		// Initiate AXI transactions
		input wire  INIT_AXI_TXN,
		// Asserts when transaction is complete
		output wire  TXN_DONE,
		// Asserts when ERROR is detected
		output reg  ERROR,
		// Global Clock Signal.
		input wire  M_AXI_ACLK,
		// Global Reset Singal. This Signal is Active Low
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address ID
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
		// Master Interface Write Address
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each write transaction.
		output wire [3 : 0] M_AXI_AWQOS,
		// Optional User-defined signal in the write address channel.
		output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data.
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write last. This signal indicates the last transfer in a write burst.
		output wire  M_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
		// Write response. This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Optional User-defined signal in the write response channel
		input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address.
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each read transaction
		output wire [3 : 0] M_AXI_ARQOS,
		// Optional User-defined signal in the read address channel.
		output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
		output wire  M_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
		// Master Read Data
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer
		input wire [1 : 0] M_AXI_RRESP,
		// Read last. This signal indicates the last transfer in a read burst
		input wire  M_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		output wire  M_AXI_RREADY
	);


	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	  // function called clogb2 that returns an integer which has the 
	  // value of the ceiling of the log base 2.                      
	  function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	  endfunction                                                     

	// C_TRANSACTIONS_NUM is the width of the index counter for 
	// number of write or read transaction.
	 localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);

	// Burst length for transactions, in C_M_AXI_DATA_WIDTHs.
	// Non-2^n lengths will eventually cause bursts across 4K address boundaries.
	 localparam integer C_MASTER_LENGTH	= 12;
	// total number of burst transfers is master length divided by burst length and burst size
	 localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);
	// Example State machine to initialize counter, initialize write transactions, 
	// initialize read transactions and comparison of read data with the 
	// written data words.
	parameter [1:0] IDLE = 2'b00, // This state initiates AXI4Lite transaction 
			// after the state machine changes state to INIT_WRITE 
			// when there is 0 to 1 transition on INIT_AXI_TXN
		INIT_WRITE   = 2'b01, // This state initializes write transaction,
			// once writes are done, the state machine 
			// changes state to INIT_READ 
		INIT_READ = 2'b10, // This state initializes read transaction
			// once reads are done, the state machine 
			// changes state to INIT_COMPARE 
		INIT_COMPARE = 2'b11; // This state issues the status of comparison 
			// of the written data with the read data	
	parameter READ_END_ADDR=8294400;
	
	 reg [1:0] mst_exec_state;

	// AXI4LITE signals
	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	reg  	axi_bready;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arvalid;
	reg  	axi_rready;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	write_index;
	//read beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	read_index;
	//size of C_M_AXI_BURST_LEN length burst in bytes
	wire [C_TRANSACTIONS_NUM+3 : 0] 	burst_size_bytes;
	//The burst counters are used to track the number of burst transfers of C_M_AXI_BURST_LEN burst length needed to transfer 2^C_MASTER_LENGTH bytes of data.
	reg [C_NO_BURSTS_REQ : 0] 	write_burst_counter;
	reg [C_NO_BURSTS_REQ : 0] 	read_burst_counter;
	reg  	start_single_burst_write;
	reg  	start_single_burst_read;
	reg  	writes_done;
	reg  	reads_done;
	reg  	error_reg;
	reg  	compare_done;
	reg  	read_mismatch;
	reg  	burst_write_active;
	reg  	burst_read_active;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;
	//Interface response error flags
	wire  	write_resp_error;
	wire  	read_resp_error;
	wire  	wnext;
	wire  	rnext;
	reg  	init_txn_ff;
	reg  	init_txn_ff2;
	reg  	init_txn_edge;
	wire  	init_txn_pulse;
	//addr user reg and wire
	reg	read_cycle_flag;
	reg	read_cmd_flag;
	reg	read_data_flag;
	wire	fifo_w_en;
	wire	[63:0]	fifo_w_data;
	wire		full,empty;
	wire	[12:0]	rd_data_count;
	wire	[11:0]	wr_data_count;


	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WDATA	= axi_wdata;
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WUSER	= 'b0;
	assign M_AXI_WVALID	= axi_wvalid;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARID	= 'b0;
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_ARCACHE	= 4'b0010;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b1;
	assign M_AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Example design I/O
	assign TXN_DONE	= compare_done;
	//Burst size in bytes
	assign burst_size_bytes	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
	assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;


//Generate a pulse to initiate AXI transaction.
always @(posedge M_AXI_ACLK)										      
begin                                                                        
    // Initiates AXI transaction delay    
	if (M_AXI_ARESETN == 0 )                                                   
		begin                                                                    
			init_txn_ff 	<= 	1'b0;                                                   
			init_txn_ff2 	<= 	1'b0;                                                   
		end                                                                               
	else                                                                       
		begin  
			init_txn_ff 	<= 	INIT_AXI_TXN;
			init_txn_ff2 	<= 	init_txn_ff;                                                                 
		end                                                                      
end 
   
//INIT_AXI_TXN 信号的上升沿触发突发传输
// read_cycle_flag 信号用于标记有效的传输周期
   
//Axi read channel
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 0)
		read_cycle_flag <= 1'b0;
	else if(init_txn_pulse == 1'b1)
		read_cycle_flag <= 1'b1;
	//else if(read_cycle_flag == 1'b1 && axi_araddr == READ_END_ADDR && M_AXI_RLAST == 1'b1)
		//read_cycle_flag <= 1'b0;
end


//读指令标志位，用于标志可以发送读地址的时间，为高时才可发送地址信息。在读地址被从机接收后置低，非读数据期间为高。
always @(posedge M_AXI_ACLK )
begin
	if(M_AXI_ARESETN == 0)
		read_cmd_flag <= 1'b0;
	else if(read_cycle_flag == 1'b1 && M_AXI_ARREADY == 1'b1 && axi_arvalid ==1'b1)
		read_cmd_flag <= 1'b0;
	else if(read_cycle_flag == 1'b1 && read_data_flag == 1'b0)
		read_cmd_flag <= 1'b1;
end

// axi_arvalid （读地址有效信号）。每当fifo中储存的数据小于预设值时，进行一次突发传输，读取ddr中的数据储存到fifo中。
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		axi_arvalid <= 1'b0;
	else if(read_cmd_flag == 1'b1 && axi_arvalid == 1'b1 && M_AXI_ARREADY == 1'b1)
		axi_arvalid <= 1'b0;
	else if(read_cmd_flag == 1'b1 && axi_arvalid == 1'b0 && wr_data_count<'d2047)
		axi_arvalid <= 1'b1;
end


//当 M_AXI_ARREADY信号有效后，表示从机已经接收到了突发读地址信号，此时将 read_data_flag（读数据标志位）置高，直到读取到突发传输的最后一个数据（M_AXI_RLAST == 1'b1）
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		read_data_flag <= 1'b0;
	else if(read_cmd_flag == 1'b1 && axi_arvalid == 1'b1 && M_AXI_ARREADY == 1'b1)
		read_data_flag <= 1'b1;
	else if(read_data_flag == 1'b1 && axi_rready == 1'b1 && M_AXI_RVALID == 1'b1 && M_AXI_RLAST == 1'b1)
		read_data_flag <= 1'b0;
end

//读标志位有效后，将 axi_rready（读数据准备信号） 置高，表示主机已经准备好接受读取的数据
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		axi_rready <= 1'b0;
	else if(read_data_flag == 1'b1 && axi_rready == 1'b0)
		axi_rready <= 1'b1;
	else if(read_data_flag == 1'b0)
		axi_rready <= 1'b0;
end
		
assign tout = |M_AXI_RDATA;

//当 M_AXI_ARREADY信号有效后，表示从机已经接收到了此次突发读地址信号，此时将地址置为下一次突发的首地址
always @(posedge M_AXI_ACLK )
begin
	if(M_AXI_ARESETN == 1'b0)
		axi_araddr <='d0;
	else if(read_cycle_flag == 1'b1 && axi_araddr == READ_END_ADDR && M_AXI_RLAST == 1'b1)//read_cycle_flag == 1'b0)
		axi_araddr <= 'd0;
	else if(axi_arvalid == 1'b1 && M_AXI_ARREADY == 1'b1 && read_cmd_flag == 1'b1)
		axi_araddr <= axi_araddr + burst_size_bytes;
end

//当fifo中的数据大于预设值后，才启动显示模块进行读取。
always @(posedge pixel_clk)
begin
	if(M_AXI_ARESETN == 1'b0)
		vga_start <= 1'b0;
	else if(rd_data_count >'d2047)
		vga_start <= 1'b1;
end

//当 axi_rready  和 M_AXI_RVALID 同时有效时， AXI读数据端口输出有效的数据，此时将该数据写入到缓存fifo中。

assign fifo_w_en 	= 	axi_rready&M_AXI_RVALID;
assign fifo_w_data	=	M_AXI_RDATA;
 
 
//从DDR中读取出的图像数据暂时缓存到fifo中，供显示模块读取。
 
frame_fifo_64x4096 frame_fifo 
(
  .wr_clk(M_AXI_ACLK),                // input wire wr_clk
  .rd_clk(pixel_clk),                // input wire rd_clk
  .din(fifo_w_data),                      // input wire [63 : 0] din
  .wr_en(fifo_w_en &(~full)),                  // input wire wr_en
  .rd_en(r_fifo_en&(~empty)),                  // input wire rd_en
  .dout(r_fifo_data),                    // output wire [31 : 0] dout
  .full(full),                    // output wire full
  .empty(empty),                  // output wire empty
  .rd_data_count(rd_data_count),  // output wire [12 : 0] rd_data_count
  .wr_data_count(wr_data_count)  // output wire [11 : 0] wr_data_count
);

	                                                                                        

	// Add user logic here

	// User logic ends

	endmodule
