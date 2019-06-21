
`timescale 1 ns / 1 ps

module AXI_Test_M_v1_0_M00_AXI #
(
	parameter  C_M_START_DATA_VALUE			= 	32'hAA000000,	// The master will start generating data form it
	parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 	32'h40000000,	// read and write target slave base address
	parameter integer C_M_AXI_ADDR_WIDTH	= 	32,				// Width of M_AXI read and write address bus.
	parameter integer C_M_AXI_DATA_WIDTH	= 	32,				// Width of M_AXI read and write data bus. 
	parameter integer C_M_TRANSACTIONS_NUM	= 	4				// number of write and read transactions 
)
(

input 	wire  								INIT_AXI_TXN,	// Initiate AXI transactions（传输启动信号）
output 	reg  								ERROR,			// Asserts（生效）when ERROR is detected（错误指示信号）
output 	wire 	 							TXN_DONE,		// Asserts（生效）when AXI transactions is complete（传输完成信号）

//global signal
input 	wire  								M_AXI_ACLK,		// AXI clock signal （时钟信号）
input 	wire  								M_AXI_ARESETN,	// AXI active low reset signal （复位信号）

//Write address channel
output 	wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	M_AXI_AW_ADDR,	// Master Interface Write Address Channel ports 
output 	wire [2 : 0] 						M_AXI_AW_PROT,	// Write channel Protection type.
output 	wire  								M_AXI_AW_VALID,	// Write address valid. 
input 	wire  								M_AXI_AW_READY,	// Write address ready.

//Write Data Channel  
output 	wire [C_M_AXI_DATA_WIDTH-1 : 0] 	M_AXI_W_DATA,	// Master Interface Write Data Channel ports
output 	wire [C_M_AXI_DATA_WIDTH/8-1 : 0] 	M_AXI_W_STRB,	// Write strobes. 
output 	wire  								M_AXI_W_VALID,	// Write valid.
input 	wire  								M_AXI_W_READY,	// Write ready.

//Write response Channel
input 	wire [1 : 0] 						M_AXI_B_RESP,	// Master Interface Write Response Channel ports. 
input 	wire  								M_AXI_B_VALID,	// Write response valid.
output 	wire  								M_AXI_B_READY,	// Response ready.

//Read Address Channel
output 	wire [C_M_AXI_ADDR_WIDTH-1 : 0] 	M_AXI_AR_ADDR,	// Master Interface Read Address Channel ports
output 	wire [2 : 0] 						M_AXI_AR_PROT,	// Protection type. 
output 	wire  								M_AXI_AR_VALID,	// Read address valid. 
input 	wire  								M_AXI_AR_READY,	// Read address ready.

//Read response Channel
input 	wire [C_M_AXI_DATA_WIDTH-1 : 0] 	M_AXI_R_DATA,	// Master Interface Read Data Channel ports
input 	wire [1 : 0] 						M_AXI_R_RESP,	// Read response.
input 	wire  								M_AXI_R_VALID,	// Read valid.
output 	wire  								M_AXI_R_READY	// Read ready.
);

// function called clogb2 that returns an integer which has the
// value of the ceiling of the log base 2

//函数：求输入值以2位底的对数
 function integer clogb2 (input integer bit_depth);
	 begin
	 for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
		 bit_depth = bit_depth >> 1;
	 end
 endfunction

// TRANS_NUM_BITS is the width of the index counter for number of write or read transaction.
// TRANS_NUM_BITS 是写入或读取交易的索引计数器宽度
 localparam integer TRANS_NUM_BITS = clogb2	(	C_M_TRANSACTIONS_NUM	-	1	);

// Example State machine to initialize counter, initialize write transactions, 
// initialize read transactions and comparison of read data with the written data words.

parameter [1:0]	IDLE 		 = 2'b00,		//启动时的空闲状态;	INIT_AXI_TXN = 1时，表示数据开始传输，此时状态跳转到 INIT_WRITE 		
				INIT_WRITE 	 = 2'b01, 		//写交易初始化状态;	当写完成后，状态跳转到 INIT_READ			
				INIT_READ 	 = 2'b10, 		//读交易初始化状态;	当读完成后，状态跳转到 INIT_COMPARE		
				INIT_COMPARE = 2'b11; 		//写数据和读数据比较状态;	进行读数据和写数据的比较


 reg [1:0] mst_exec_state;					//State machine Status

// AXI4LITE signals
reg		axi_aw_valid;		//write address valid
reg  	axi_w_valid;		//write data valid
reg  	axi_ar_valid;		//read address valid

reg  	axi_r_ready;		//read data acceptance
reg  	axi_b_ready;		//write response acceptance

reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_aw_addr;		//write address
reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_ar_addr;		//read addresss
reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_w_data;			//write data

wire  	write_resp_error;	//Asserts when there is a write response error
wire  	read_resp_error;	//Asserts when there is a read response error
reg  	start_single_write;	//A pulse to initiate a write transaction	（写启动入交易的脉冲）
reg  	start_single_read;	//A pulse to initiate a read transaction	（读启动入交易的脉冲）
reg  	write_issued;		//write transaction is issued	（单拍写传输发起时有效，并保持直到写交易完成）		
reg  	read_issued;		//read transaction is issued	（单拍读传输发起时有效，并保持直到读交易完成）
reg  	writes_done;		//flag of write done	（写完成标志，写传输的数量由参数 C_M_TRANSACTIONS_NUM 决定）
reg  	reads_done;			//flag of read  done	（读完成标志，读传输的数量由参数 C_M_TRANSACTIONS_NUM 决定）
reg  	error_reg;			//data mismatch,write , read response error register	（数据不匹配，读，写响应错误）
reg 	[TRANS_NUM_BITS : 0] 		write_index;	//number of write transaction 	（写交易数量索引）
reg 	[TRANS_NUM_BITS : 0] 		read_index;		//number of read  transaction 	（读交易数量索引）
reg 	[C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;	//compare with the read data	（读取数据，用作与读数据比较）
reg  	compare_done;		//Flag marks the completion of comparison （完成 读数据 与 expected_rdata 比较的标志位）
reg  	read_mismatch;		//Flag of read data mismatch	（读数据不匹配标志位）
reg  	last_write;			//Flag of last write transction	（写最后一位标志位）
reg  	last_read;			//Flag of last read  transction	（读最后一位标志位）

reg  	init_txn_ff;		//INIT_AXI_TXN buffer register
reg  	init_txn_ff2;		//INIT_AXI_TXN buffer register
reg  	init_txn_edge;		//INIT_AXI_TXN edge detection
wire  	init_txn_pulse;		//INIT_AXI_TXN pulse


// I/O Connections assignments


assign 	M_AXI_AW_ADDR	= 	C_M_TARGET_SLAVE_BASE_ADDR 
							+ axi_aw_addr;	////Write Address 从设备的基地址+偏移地址(写地址)
assign 	M_AXI_W_DATA	= 	axi_w_data;		//Write Data
assign 	M_AXI_AW_PROT	= 	3'b000;			//Write Address Protection Type
assign 	M_AXI_AW_VALID	= 	axi_aw_valid;	//Write Address valid
assign 	M_AXI_W_VALID	= 	axi_w_valid;	//Write Data valid
assign 	M_AXI_W_STRB	= 	4'b1111;		//Set byte strobes
assign 	M_AXI_B_READY	= 	axi_b_ready;	//Write Response (B)
assign 	M_AXI_AR_ADDR	= 	C_M_TARGET_SLAVE_BASE_ADDR 
							+ axi_ar_addr;	//Read Address (AR)
assign 	M_AXI_AR_VALID	= 	axi_ar_valid;	//Read Address valid
assign 	M_AXI_AR_PROT	= 	3'b001;			//Read Address Protection Type
assign 	M_AXI_R_READY	= 	axi_r_ready;	//Read and Read Response (R)
assign 	TXN_DONE		= 	compare_done;	//Example design I/O
assign 	init_txn_pulse	= 	(!init_txn_ff2) && init_txn_ff;	
											//init_txn_pulse Generate


//Generate a pulse to initiate AXI transaction.
//生成 init_txn_pulse 脉冲信号 
always @(posedge M_AXI_ACLK)										      
  begin                                                                        
    // Initiates AXI transaction delay    
    if (M_AXI_ARESETN == 0 )                                                   
      begin                                                                    
        init_txn_ff <= 1'b0;                                                   
        init_txn_ff2 <= 1'b0;                                                   
      end                                                                               
    else                                                                       
      begin  
        init_txn_ff <= INIT_AXI_TXN;	// 移位缓存器，将输入信号寄存，当输入信号从 0 变到 1 时，
        init_txn_ff2 <= init_txn_ff;    // init_txn_pulse 将产生一个时钟周期的脉冲信号                                                             
      end                                                                      
  end     

//--------------------
//Write Address Channel
//--------------------

// The purpose of the write address channel is to request the address and 
// command information for the entire transaction.  It is a single beat
// of information.

// Note for this example the axi_aw_valid/axi_w_valid are asserted at the same
// time, and then each is deasserted independent from each other.
// This is a lower-performance, but simplier control scheme.

// AXI VALID signals must be held active until accepted by the partner.

// A data transfer is accepted by the slave when a master has
// VALID data and the slave acknoledges it is also READY. While the master
// is allowed to generated multiple, back-to-back requests by not 
// deasserting VALID, this design will add rest cycle for
// simplicity.

// Since only one outstanding transaction is issued by the user design,
// there will not be a collision between a new request and an accepted
// request on the same clock cycle. 

always @(posedge M_AXI_ACLK)										      
begin                                                                        
  //Only VALID signals must be deasserted during reset per AXI spec          
  //Consider inverting then registering active-low reset for higher fmax     
  if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                   
    begin                                                                    
      axi_aw_valid <= 1'b0;                                                   
    end                                                                      
    //Signal a new address/data command is available by user logic           
  else                                                                       
    begin                                                                    
      if (start_single_write)                                                
        begin                                                                
          axi_aw_valid <= 1'b1;                                               
        end                                                                  
   //Address accepted by interconnect/slave (issue of M_AXI_AW_READY by slave)
      else if (M_AXI_AW_READY && axi_aw_valid)                                 
        begin                                                                
          axi_aw_valid <= 1'b0;                                               
        end                                                                  
    end                                                                      
end                                                                          
                                                                             
                                                                             
// start_single_write triggers a new write                                   
// transaction. write_index is a counter to                                  
// keep track with number of write transaction                               
// issued/initiated                                                          
always @(posedge M_AXI_ACLK)                                                 
begin                                                                        
  if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                   
    begin                                                                    
      write_index <= 0;                                                      
    end                                                                      
    // Signals a new write address/ write data is                            
    // available by user logic                                               
  else if (start_single_write)                                               
    begin                                                                    
      write_index <= write_index + 1;                                        
    end                                                                      
end                                                                          


//--------------------
//Write Data Channel
//--------------------

//The write data channel is for transfering the actual data.
//The data generation is speific to the example design, and 
//so only the WVALID/WREADY handshake is shown here

always @(posedge M_AXI_ACLK)                                        
begin                                                                         
  if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                    
    begin                                                                     
      axi_w_valid <= 1'b0;                                                     
    end                                                                       
  //Signal a new address/data command is available by user logic              
  else if (start_single_write)                                                
    begin                                                                     
      axi_w_valid <= 1'b1;                                                     
    end                                                                       
  //Data accepted by interconnect/slave (issue of M_AXI_W_READY by slave)      
  else if (M_AXI_W_READY && axi_w_valid)                                        
    begin                                                                     
     axi_w_valid <= 1'b0;                                                      
    end                                                                       
end                                                                           


//----------------------------
//Write Response (B) Channel
//----------------------------

//The write response channel provides feedback that the write has committed
//to memory. BREADY will occur after both the data and the write address
//has arrived and been accepted by the slave, and can guarantee that no
//other accesses launched afterwards will be able to be reordered before it.

//The BRESP bit [1] is used indicate any errors from the interconnect or
//slave for the entire write burst. This example will capture the error.

//While not necessary per spec, it is advisable to reset READY signals in
//case of differing reset latencies between master/slave.

  always @(posedge M_AXI_ACLK)                                    
  begin                                                                
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                           
      begin                                                            
        axi_b_ready <= 1'b0;                                            
      end                                                              
    // accept/acknowledge bresp with axi_b_ready by the master          
    // when M_AXI_B_VALID is asserted by slave                          
    else if (M_AXI_B_VALID && ~axi_b_ready)                              
      begin                                                            
        axi_b_ready <= 1'b1;                                            
      end                                                              
    // deassert after one clock cycle                                  
    else if (axi_b_ready)                                               
      begin                                                            
        axi_b_ready <= 1'b0;                                            
      end                                                              
    // retain the previous value                                       
    else                                                               
      axi_b_ready <= axi_b_ready;                                        
  end                                                                  
                                                                       
//Flag write errors                                                    
assign write_resp_error = (axi_b_ready & M_AXI_B_VALID & M_AXI_B_RESP[1]);


//----------------------------
//Read Address Channel
//----------------------------

//start_single_read triggers a new read transaction. read_index is a counter to
//keep track with number of read transaction issued/initiated

  always @(posedge M_AXI_ACLK)                                                     
  begin                                                                            
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                       
      begin                                                                        
        read_index <= 0;                                                           
      end                                                                          
    // Signals a new read address is                                               
    // available by user logic                                                     
    else if (start_single_read)                                                    
      begin                                                                        
        read_index <= read_index + 1;                                              
      end                                                                          
  end                                                                              
                                                                                   
  // A new axi_ar_valid is asserted when there is a valid read address              
  // available by the master. start_single_read triggers a new read                
  // transaction                                                                   
  always @(posedge M_AXI_ACLK)                                                     
  begin                                                                            
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                       
      begin                                                                        
        axi_ar_valid <= 1'b0;                                                       
      end                                                                          
    //Signal a new read address command is available by user logic                 
    else if (start_single_read)                                                    
      begin                                                                        
        axi_ar_valid <= 1'b1;                                                       
      end                                                                          
    //RAddress accepted by interconnect/slave (issue of M_AXI_AR_READY by slave)    
    else if (M_AXI_AR_READY && axi_ar_valid)                                         
      begin                                                                        
        axi_ar_valid <= 1'b0;                                                       
      end                                                                          
    // retain the previous value                                                   
  end                                                                              


//--------------------------------
//Read Data (and Response) Channel
//--------------------------------

//The Read Data channel returns the results of the read request 
//The master will accept the read data by asserting axi_r_ready
//when there is a valid read data available.
//While not necessary per spec, it is advisable to reset READY signals in
//case of differing reset latencies between master/slave.

  always @(posedge M_AXI_ACLK)                                    
  begin                                                                 
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                            
      begin                                                             
        axi_r_ready <= 1'b0;                                             
      end                                                               
    // accept/acknowledge rdata/rresp with axi_r_ready by the master     
    // when M_AXI_R_VALID is asserted by slave                           
    else if (M_AXI_R_VALID && ~axi_r_ready)                               
      begin                                                             
        axi_r_ready <= 1'b1;                                             
      end                                                               
    // deassert after one clock cycle                                   
    else if (axi_r_ready)                                                
      begin                                                             
        axi_r_ready <= 1'b0;                                             
      end                                                               
    // retain the previous value                                        
  end                                                                   
                                                                        
//Flag write errors                                                     
assign read_resp_error = (axi_r_ready & M_AXI_R_VALID & M_AXI_R_RESP[1]);  


//--------------------------------
//User Logic
//--------------------------------

//Address/Data Stimulus

//Address/data pairs for this example. The read and write values should
//match.
//Modify these as desired for different address patterns.

  //Write Addresses                                        
  always @(posedge M_AXI_ACLK)                                  
      begin                                                     
        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
          begin                                                 
            axi_aw_addr <= 0;                                    
          end                                                   
          // Signals a new write address/ write data is         
          // available by user logic                            
        else if (M_AXI_AW_READY && axi_aw_valid)                  
          begin                                                 
            axi_aw_addr <= axi_aw_addr + 32'h00000004;            
                                                                
          end                                                   
      end                                                       
                                                                
  // Write data generation                                      
  always @(posedge M_AXI_ACLK)                                  
      begin                                                     
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 )                                
          begin                                                 
            axi_w_data   <=   C_M_START_DATA_VALUE;                  
          end                                                   
        // Signals a new write address/ write data is           
        // available by user logic                              
        else if (M_AXI_W_READY && axi_w_valid)                    
          begin                                                 
            axi_w_data   <=   C_M_START_DATA_VALUE + write_index;    
          end                                                   
        end          	                                       
                                                                
  //Read Addresses                                              
  always @(posedge M_AXI_ACLK)                                  
      begin                                                     
        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
          begin                                                 
            axi_ar_addr   <=   0;                                    
          end                                                   
          // Signals a new write address/ write data is         
          // available by user logic                            
        else if (M_AXI_AR_READY && axi_ar_valid)                  
          begin                                                 
            axi_ar_addr <= axi_ar_addr + 32'h00000004;            
          end                                                   
      end                                                       
                                                                
                                                                
                                                                
  always @(posedge M_AXI_ACLK)                                  
      begin                                                     
        if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                
          begin                                                 
            expected_rdata <= C_M_START_DATA_VALUE;             
          end                                                   
          // Signals a new write address/ write data is         
          // available by user logic                            
        else if (M_AXI_R_VALID && axi_r_ready)                    
          begin                                                 
            expected_rdata <= C_M_START_DATA_VALUE + read_index;
          end                                                   
      end                                                       
  //implement master command interface state machine                         
  always @ ( posedge M_AXI_ACLK)                                                    
  begin                                                                             
    if (M_AXI_ARESETN == 1'b0)                                                     
      begin                                                                         
      // reset condition                                                            
      // All the signals are assigned default values under reset condition          
		mst_exec_state  	<= 	IDLE	;                                            
        start_single_write 	<= 	1'b0	;                                                 
        write_issued  		<= 	1'b0	;                                                      
        start_single_read  	<= 	1'b0	;                                                 
        read_issued   		<= 	1'b0	;                                                      
        compare_done  		<= 	1'b0	;                                                      
        ERROR 				<= 	1'b0	;
      end                                                                           
    else                                                                            
      begin                                                                         
       // state transition                                                          
        case (mst_exec_state)                                                       
                                                                                    
          IDLE:                                                             
          // This state is responsible to initiate 
          // AXI transaction when init_txn_pulse is asserted 
            if ( init_txn_pulse == 1'b1 )                                     
              begin                                                                 
                mst_exec_state  <= INIT_WRITE;                                      
                ERROR 			<= 1'b0;
                compare_done 	<= 1'b0;
              end                                                                   
            else                                                                    
              begin                                                                 
                mst_exec_state  <= IDLE;                                    
              end                                                                   
                                                                                    
          INIT_WRITE:                                                               
            // This state is responsible to issue start_single_write pulse to       
            // initiate a write transaction. Write transactions will be             
            // issued until last_write signal is asserted.                          
            // write controller                                                     
            if (writes_done)                                                        
              begin                                                                 
                mst_exec_state <= INIT_READ;//                                      
              end                                                                   
            else                                                                    
              begin                                                                 
                mst_exec_state  <= INIT_WRITE;                                      
                                                                                    
                  if (~axi_aw_valid && ~axi_w_valid && ~M_AXI_B_VALID && ~last_write && ~start_single_write && ~write_issued)
                    begin                                                           
                      start_single_write	<= 	1'b1;                                   
                      write_issued  		<= 	1'b1;                                        
                    end                                                             
                  else if (axi_b_ready)                                              
                    begin                                                           
                      write_issued	<= 	1'b0;                                        
                    end                                                             
                  else                                                              
                    begin                                                           
                      start_single_write	<= 	1'b0; //Negate to generate a pulse      
                    end                                                             
              end                                                                   
                                                                                    
          INIT_READ:                                                                
            // This state is responsible to issue start_single_read pulse to        
            // initiate a read transaction. Read transactions will be               
            // issued until last_read signal is asserted.                           
             // read controller                                                     
             if (reads_done)                                                        
               begin                                                                
                 mst_exec_state	<= 	INIT_COMPARE;                                    
               end                                                                  
             else                                                                   
               begin                                                                
                 mst_exec_state	<= 	INIT_READ;                                      
                                                                                    
                 if (~axi_ar_valid && ~M_AXI_R_VALID && ~last_read && ~start_single_read && ~read_issued)
                   begin                                                            
                     start_single_read 	<= 	1'b1;                                     
                     read_issued  		<= 	1'b1;                                          
                   end                                                              
                 else if (axi_r_ready)                                               
                   begin                                                            
                     read_issued  <= 1'b0;                                          
                   end                                                              
                 else                                                               
                   begin                                                            
                     start_single_read <= 1'b0; //Negate to generate a pulse        
                   end                                                              
               end                                                                  
                                                                                    
           INIT_COMPARE:                                                            
             begin
                 // This state is responsible to issue the state of comparison          
                 // of written data with the read data. If no error flags are set,      
                 // compare_done signal will be asseted to indicate success.            
                 ERROR 			<= 	error_reg; 
                 mst_exec_state	<= 	IDLE;                                    
                 compare_done 	<= 	1'b1;                                              
             end                                                                  
           default :                                                                
             begin                                                                  
               mst_exec_state  <= IDLE;                                     
             end                                                                    
        endcase                                                                     
    end                                                                             
  end //MASTER_EXECUTION_PROC                                                       
                                                                                    
  //Terminal write count                                                            
                                                                                    
  always @(posedge M_AXI_ACLK)                                                      
  begin                                                                             
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
      last_write <= 1'b0;                                                           
                                                                                    
    //The last write should be associated with a write address ready response       
    else if ((write_index == C_M_TRANSACTIONS_NUM) && M_AXI_AW_READY)                
      last_write <= 1'b1;                                                           
    else                                                                            
      last_write <= last_write;                                                     
  end                                                                               
                                                                                    
  //Check for last write completion.                                                
                                                                                    
  //This logic is to qualify the last write count with the final write              
  //response. This demonstrates how to confirm that a write has been                
  //committed.                                                                      
                                                                                    
  always @(posedge M_AXI_ACLK)                                                      
  begin                                                                             
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
      writes_done <= 1'b0;                                                          
                                                                                    
      //The writes_done should be associated with a bready response                 
    else if (last_write && M_AXI_B_VALID && axi_b_ready)                              
      writes_done <= 1'b1;                                                          
    else                                                                            
      writes_done <= writes_done;                                                   
  end                                                                               
                                                                                    
//------------------                                                                
//Read example                                                                      
//------------------                                                                
                                                                                    
//Terminal Read Count                                                               
                                                                                    
  always @(posedge M_AXI_ACLK)                                                      
  begin                                                                             
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
      last_read <= 1'b0;                                                            
                                                                                    
    //The last read should be associated with a read address ready response         
    else if ((read_index == C_M_TRANSACTIONS_NUM) && (M_AXI_AR_READY) )              
      last_read <= 1'b1;                                                            
    else                                                                            
      last_read <= last_read;                                                       
  end                                                                               
                                                                                    
/*                                                                                  
 Check for last read completion.                                                    
                                                                                    
 This logic is to qualify the last read count with the final read                   
 response/data.                                                                     
 */                                                                                 
  always @(posedge M_AXI_ACLK)                                                      
  begin                                                                             
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)                                                         
      reads_done <= 1'b0;                                                           
                                                                                    
    //The reads_done should be associated with a read ready response                
    else if (last_read && M_AXI_R_VALID && axi_r_ready)                               
      reads_done <= 1'b1;                                                           
    else                                                                            
      reads_done <= reads_done;                                                     
    end                                                                             
                                                                                    
//-----------------------------                                                     
//Example design error register                                                     
//-----------------------------                                                     
                                                                                    
//Data Comparison                                                                   
  always @(posedge M_AXI_ACLK)                                                      
  begin                                                                             
    if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
    read_mismatch <= 1'b0;                                                          
                                                                                    
    //The read data when available (on axi_r_ready) is compared with the expected data
    else if ((M_AXI_R_VALID && axi_r_ready) && (M_AXI_R_DATA != expected_rdata))         
      read_mismatch <= 1'b1;                                                        
    else                                                                            
      read_mismatch <= read_mismatch;                                               
  end                                                                               
                                                                                    
// Register and hold any data mismatches, or read/write interface errors            
  always @(posedge M_AXI_ACLK)                                                      
  begin                                                                             
    if (M_AXI_ARESETN == 0  || init_txn_pulse == 1'b1)                                                         
      error_reg <= 1'b0;                                                            
                                                                                    
    //Capture any error types                                                       
    else if (read_mismatch || write_resp_error || read_resp_error)                  
      error_reg <= 1'b1;                                                            
    else                                                                            
      error_reg <= error_reg;                                                       
  end                                                                               


endmodule
