
`timescale 1 ns / 1 ps

	module AXI_DMA_WR_v1_0_M00_AXI #
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
		input	wire		pixel_clk,
		input	wire	[7:0]	bayer_r,
		input	wire	[7:0]	bayer_g,
		input	wire	[7:0]	bayer_b,
		input	wire		bayer_fv,
		input	wire		bayer_hv,
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
			
	parameter	DATA_LATCH = 2047;
	parameter	ADDR_END = 1920*1080*4;//8294400

	 reg [1:0] mst_exec_state;

	// AXI4LITE signals
	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	wire [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	wire  	axi_bready;
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
	
	wire	[31:0]	wr_fifo_data;
   	wire		wr_fifo_en;
   	reg		frame_flag;
   	reg		w_cycle_flag;
   	wire		full;
   	wire	[11:0]	rd_data_count;
   	reg		w_axi_flag;
   	wire		rd_fifo_en;
   	reg	[7:0]	wr_word_cnt;


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

       assign wr_fifo_data = {8'd0,bayer_r,bayer_g,bayer_b};

	//Generate a pulse to initiate AXI transaction.
	
	always @(posedge pixel_clk)
		if(M_AXI_ARESETN == 1'b0)
			frame_flag <= 1'b0;
		else if(bayer_fv == 1'b1)
			frame_flag <= 1'b1;
	
	assign wr_fifo_en = frame_flag & bayer_hv & (~full); 
	//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
frame_buf_32x8192 frame_buf_inst (
  .wr_clk(pixel_clk),                // input wire wr_clk
  .rd_clk(M_AXI_ACLK),                // input wire rd_clk
  .din(wr_fifo_data),                      // input wire [31 : 0] din
  .wr_en(wr_fifo_en),                  // input wire wr_en
  .rd_en(rd_fifo_en),                  // input wire rd_en
  .dout(axi_wdata),                    // output wire [63 : 0] dout
  .full(full),                    // output wire full
  .empty(empty),                  // output wire empty
  .rd_data_count(rd_data_count)  // output wire [11 : 0] rd_data_count
);               

//写fifo通道是慢时钟（pixel_clk），小位宽（32bit）,读fifo通道是快时钟（M_AXI_ACLK），大位宽（64bit）。
//一次fifo中写入的数据大于预设值后，由于读通道的带宽大于写通道第二带宽，因此，fifo的一次写入所用的时间将大于一次读取的时间。
//fifo中写入的数据大于预设值后，继续写入的数据速度小于读出的速度，故fifo中的有效数据数量将会减少。直到一次突发传输完成。
//等待下一次写入的数据大于预设值后，进行下一次的突传输，将数据从fifo读出，写入到DDR SDRAM 中。

// fifo 中写入的数据阈值标志位，当fifo中的数据大于预设值时 该信号为高
always @(posedge M_AXI_ACLK )
begin
	if(M_AXI_ARESETN == 1'b0)
		w_axi_flag <= 1'b0;
	else if(rd_data_count >=  DATA_LATCH)
		w_axi_flag <= 1'b1;
	else 
		w_axi_flag <= 1'b0;  
end		

// 一次突发传输的标志位 ，当 w_axi_flag 有效时，该信号有效，直到一次突发传输到最后一个数据（axi_wlast == 1'b1），该信号被置低
// 直到下一次fifo中的数据再次大于预设值，再启动下一次突发传输
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		w_cycle_flag <= 1'b0;
	else if(w_cycle_flag == 1'b0 && w_axi_flag == 1'b1)
		w_cycle_flag <= 1'b1;
	else if(w_cycle_flag == 1'b1 && axi_wlast == 1'b1)
		w_cycle_flag <= 1'b0;
end

//当开始突发传输时，axi_awvalid（地址有效信号）被拉高，直到接收到 M_AXI_AWREADY 有效信号，axi_awvalid 信号才被置低
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		axi_awvalid<= 1'b0;
	else if(w_cycle_flag == 1'b1 && M_AXI_AWREADY==1'b1)
		axi_awvalid <= 1'b0;
	else if(w_cycle_flag  == 1'b0 && w_axi_flag == 1'b1)
		axi_awvalid <= 1'b1;  
end		

//当开始突发传输时，axi_awvalid（地址有效信号）被拉高的同时，将突发首地址放置到axi_awaddr总线上，待 M_AXI_AWREADY 信号有效时，表示此次的地址信号被从机接收
//将该地址信号置为下一次突发传输的首地址
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		axi_awaddr <='d0;
	else if(axi_wvalid == 1'b1 && M_AXI_WREADY && axi_wlast == 1'b1 && axi_awaddr == ADDR_END)
		axi_awaddr <='d0;
	else if(axi_awvalid == 1'b1 && M_AXI_AWREADY == 1'b1)
		axi_awaddr <= axi_awaddr + burst_size_bytes ; 
end		

//突发传输被触发后，axi_wvalid（数据有效信号）被拉，表示总线上有有效的数据，直到传输到最后一个数据，该信号被拉低。
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN  == 1'b0)
		axi_wvalid <= 1'b0;
	else if(w_cycle_flag  == 1'b0 && w_axi_flag == 1'b1)
		axi_wvalid <= 1'b1;
	else if(w_cycle_flag == 1'b1 && ( wr_word_cnt == M_AXI_AWLEN-1 ) )
		axi_wvalid <= 1'b0;
end

//统计一次突发传输中发送的数据的个数
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		wr_word_cnt <= 'd0;
	else if(axi_wvalid == 1'b1 && M_AXI_WREADY == 1'b1)
		wr_word_cnt <= wr_word_cnt + 1'b1;
	else 
		wr_word_cnt <='d0;
end

//生成一次突发传输的最后一个数据标志信号，该信号与一次突发传输的最后一个数据对齐。
always @(posedge M_AXI_ACLK)
begin
	if(M_AXI_ARESETN == 1'b0)
		axi_wlast <= 1'b0;
	else if(wr_word_cnt == M_AXI_AWLEN-1)
		axi_wlast <= 1'b1;
	else
		axi_wlast <= 1'b0;
end

//用于生成fifo的读使能信号。 axi_wvalid 为高时，表示主机在发送有效数据。 M_AXI_WREADY 为高时，表示从机已准备好接受数据。

assign rd_fifo_en = axi_wvalid & M_AXI_WREADY;     

//写响应的准备信号始终有效。

assign axi_bready = 1'b1;                                                                     

	// Add user logic here

	// User logic ends

	endmodule
