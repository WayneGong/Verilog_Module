//		C_S_AXI_DATA_WIDTH	= 32,	// Width of S_AXI data bus		
//		C_S_AXI_ADDR_WIDTH	= 4		// Width of S_AXI address bus

`timescale 1 ns / 1 ps

module AXI_Test_S_v1_0_S00_AXI  #
(
	parameter integer C_S_AXI_DATA_WIDTH	= 32,		// Width of S_AXI data bus		
	parameter integer C_S_AXI_ADDR_WIDTH	= 4			// Width of S_AXI address bus
)
(
	input 	wire  								S_AXI_ACLK,		// Global Clock Signal		
	input 	wire  								S_AXI_ARESETN,	// Global Reset Signal		
		
	input 	wire [C_S_AXI_ADDR_WIDTH-1 : 0]		S_AXI_AW_ADDR,	// Write address (issued by master, acceped by Slave)
	input 	wire [ 2:0] 						S_AXI_AW_PROT,	// Write channel Protection type
	input 	wire  								S_AXI_AW_VALID,	// Write address valid
	output 	wire  								S_AXI_AW_READY,	// Write address ready
					
	input 	wire [C_S_AXI_DATA_WIDTH-1:0]		S_AXI_W_DATA,	// Write data (issued by master, acceped by Slave)   
	input 	wire [(C_S_AXI_DATA_WIDTH/8)-1:0]	S_AXI_W_STRB,	// Write strobes(写选通脉冲，规定哪些字节通道有效)
	input 	wire  								S_AXI_W_VALID,	// Write valid
	output 	wire  								S_AXI_W_READY,	// Write ready
					
	output 	wire [ 1:0] 						S_AXI_B_RESP,	// Write response
	output 	wire  								S_AXI_B_VALID,	// Write response valid.	
	input 	wire  								S_AXI_B_READY,	// Response ready.	
					
	input 	wire [C_S_AXI_ADDR_WIDTH-1:0] 		S_AXI_AR_ADDR,	// Read address (issued by master, acceped by Slave)
	input 	wire [ 2:0] 						S_AXI_AR_PROT,	// Protection type
	input 	wire  								S_AXI_AR_VALID,	// Read address valid
	output 	wire  								S_AXI_AR_READY,	// Read address ready
					
	output 	wire [C_S_AXI_DATA_WIDTH-1:0]		S_AXI_R_DATA,	// Read data (issued by slave)
	output 	wire [ 1:0] 						S_AXI_R_RESP,	// Read response.
	output 	wire  								S_AXI_R_VALID,	// Read valid. 
	input 	wire  								S_AXI_R_READY	// Read ready.
);

// AXI4LITE signals
reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_aw_addr		;
reg  							axi_aw_ready	;

reg  							axi_w_ready		;

reg [ 1:0] 						axi_b_resp		;
reg  							axi_b_valid		;

reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_ar_addr		;
reg  							axi_ar_ready	;

reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_r_data		;
reg [ 1:0] 						axi_r_resp		;
reg  							axi_r_valid		;

// Example-specific design signals
// local par_ameter for addressing 32 bit / 64 bit C_S_AXI_DATA_W_IDTH
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)
localparam integer	ADDR_LSB			=	(C_S_AXI_DATA_WIDTH/32) + 1;
localparam integer	OPT_MEM_ADDR_BITS	=	1	;
//----------------------------------------------
//-- Signals for user logic register space example
//------------------------------------------------
//-- Number of Slave Registers 4
reg 	[C_S_AXI_DATA_WIDTH-1:0]	slv_reg0		;
reg 	[C_S_AXI_DATA_WIDTH-1:0]	slv_reg1		;
reg 	[C_S_AXI_DATA_WIDTH-1:0]	slv_reg2		;
reg 	[C_S_AXI_DATA_WIDTH-1:0]	slv_reg3		;
wire	 							slv_reg_rden	;
wire	 							slv_reg_wren	;
reg 	[C_S_AXI_DATA_WIDTH-1:0]	reg_data_out	;
integer	 							byte_index		;
reg	 								aw_en			;		//写地址使能

// I/O Connections assignments
//这些都是输出信号,wire 型信号被 reg 型信号驱动
assign 	S_AXI_AW_READY	= 	axi_aw_ready	;
assign 	S_AXI_W_READY	= 	axi_w_ready		;
assign 	S_AXI_B_RESP	= 	axi_b_resp		;
assign 	S_AXI_B_VALID	= 	axi_b_valid		;
assign 	S_AXI_AR_READY	= 	axi_ar_ready	;
assign 	S_AXI_R_DATA	= 	axi_r_data		;
assign 	S_AXI_R_RESP	= 	axi_r_resp		;
assign 	S_AXI_R_VALID	= 	axi_r_valid		;

// Implement axi_aw_ready generation
// axi_aw_ready is asserted for one S_AXI_ACLK clock cycle when both
// S_AXI_AW_VALID and S_AXI_W_VALID are asserted. axi_aw_ready is
// de-asserted when reset is low.

//实现 '写地址准备信号（axi_aw_ready）' 的生成
//当 S_AXI_AW_VALID 和 S_AXI_W_VALID 有效时，axi_aw_ready 有效一个S_AXI_ACLK 时钟周期
//当 reset 为低时，axi_aw_ready 无效

always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_aw_ready <= 1'b0;
      aw_en <= 1'b1;
    end 
  else
    begin    
      if (~axi_aw_ready && S_AXI_AW_VALID && S_AXI_W_VALID && aw_en)
        begin
		  //当在写地址和数据总线上有有效的写地址和写数据时，从机准备接受写地址
          // slave is ready to accept write address when there is a valid write address and write data
          // on the write address and data bus. This design expects no outstanding transactions. 
          axi_aw_ready <= 1'b1;
          aw_en <= 1'b0;
        end
      else if (S_AXI_B_READY && axi_b_valid)		//写响应和准备信号有效，说明一次数据传输已经完成
            begin									//此时，将写地址使能（aw_en）置为有效，表明可以进行下一轮的数据传输
              aw_en <= 1'b1;		
              axi_aw_ready <= 1'b0;
            end
      else           
        begin
          axi_aw_ready <= 1'b0;
        end
    end 
end       

// Implement axi_aw_addr latching
// This process is used to latch the address when both 
// S_AXI_AW_VALID and S_AXI_W_VALID ar_e valid. 

//实现 '写地址' 的锁存
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_aw_addr <= 0;
    end 
  else
    begin    
      if (~axi_aw_ready && S_AXI_AW_VALID && S_AXI_W_VALID && aw_en)
        begin
          // 写地址锁存 
          axi_aw_addr <= S_AXI_AW_ADDR;
        end
    end 
end       

// Implement axi_w_ready generation
// axi_w_ready is asserted for one S_AXI_ACLK clock cycle when both
// S_AXI_AW_VALID and S_AXI_W_VALID ar_e asserted. axi_w_ready is 
// de-asserted when reset is low. 

//实现“写数据准备信号”的生成
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_w_ready <= 1'b0;
    end 
  else
    begin    
      if (~axi_w_ready && S_AXI_W_VALID && S_AXI_AW_VALID && aw_en )
        begin
		  //当地址和数据总线上有有效的地址和数据时，从设备准备接收写数据，此时将写数据准备信号置为有效
          // slave is ready to accept write data when 
          // there is a valid write address and write data
          // on the write address and data bus. This design 
          // expects no outstanding transactions. 
          axi_w_ready <= 1'b1;
        end
      else
        begin
          axi_w_ready <= 1'b0;
        end
    end 
end       

// Implement memory mapped register select and write logic generation
// The write data is accepted and written to memory mapped registers when
// axi_aw_ready, S_AXI_W_VALID, axi_w_ready and S_AXI_W_VALID ar_e asserted. Write strobes ar_e used to
// select byte enables of slave registers while writing.
// These registers ar_e clear_ed when reset (active low) is applied.
// Slave register write enable is asserted when valid address and data ar_e available
// and the slave is ready to accept the write address and write data.

//实现内存映射寄存器选择和写逻辑的生成
//当写地址和数据信号握手成功后，从设备寄存器写使能有效，对应地址的寄存器接收所写入的数据
assign slv_reg_wren = axi_w_ready && S_AXI_W_VALID && axi_aw_ready && S_AXI_AW_VALID;

always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      slv_reg0 <= 0;
      slv_reg1 <= 1;
      slv_reg2 <= 2;
      slv_reg3 <= 3;
    end 
  else begin
if (slv_reg_wren)
      begin
        case ( axi_aw_addr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
          2'h0:
             for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
              if ( S_AXI_W_STRB[byte_index] == 1 ) 		
                slv_reg0[(byte_index*8) +: 8] <= S_AXI_W_DATA[(byte_index*8) +: 8];          
          2'h1:
             for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
              if ( S_AXI_W_STRB[byte_index] == 1 ) 
                slv_reg1[(byte_index*8) +: 8] <= S_AXI_W_DATA[(byte_index*8) +: 8];
          2'h2:
             for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
              if ( S_AXI_W_STRB[byte_index] == 1 ) 
                slv_reg2[(byte_index*8) +: 8] <= S_AXI_W_DATA[(byte_index*8) +: 8];             
          2'h3:
             for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
              if ( S_AXI_W_STRB[byte_index] == 1 ) 
                slv_reg3[(byte_index*8) +: 8] <= S_AXI_W_DATA[(byte_index*8) +: 8];
          default : begin
                      slv_reg0 <= slv_reg0;
                      slv_reg1 <= slv_reg1;
                      slv_reg2 <= slv_reg2;
                      slv_reg3 <= slv_reg3;
                    end
        endcase
      end
  end
end    

// Implement write response logic generation
// The write response and response valid signals are asserted by the slave 
// when axi_w_ready, S_AXI_W_VALID, axi_w_ready and S_AXI_W_VALID ar_e asserted.  
// This marks the acceptance of address and indicates the status of 
// write transaction.

//实现写响应逻辑生成  
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_b_valid  <= 0;
      axi_b_resp   <= 2'b0;
    end 
  else
    begin    
      if (axi_aw_ready && S_AXI_AW_VALID && ~axi_b_valid && axi_w_ready && S_AXI_W_VALID)
        begin
          // indicates a valid write response is available
          axi_b_valid <= 1'b1;
          axi_b_resp  <= 2'b0; // 'OKAY' response 
        end                   // work error responses in future
      else
        begin
          if (S_AXI_B_READY && axi_b_valid) 
            //check if bready is asserted while bvalid is high) 
            //(there is a possibility that bready is always asserted high)   
            begin
              axi_b_valid <= 1'b0; 
            end  
        end
    end
end   

// Implement axi_ar_ready generation
// axi_ar_ready is asserted for one S_AXI_ACLK clock cycle when
// S_AXI_AR_VALID is asserted. axi_aw_ready is 
// de-asserted when reset (active low) is asserted. 
// The read address is also latched when S_AXI_AR_VALID is 
// asserted. axi_ar_addr is reset to zero on reset assertion.
//实现 “读地址准备信号”的生成
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_ar_ready <= 1'b0;
      axi_ar_addr  <= 32'b0;
    end 
  else
    begin    
      if (~axi_ar_ready && S_AXI_AR_VALID)
        begin
          // 当读地址有效信号有效时，读地址准备信号有效，同时进行读地址锁存
          axi_ar_ready <= 1'b1;
          axi_ar_addr  <= S_AXI_AR_ADDR;
        end
      else
        begin
          axi_ar_ready <= 1'b0;
        end
    end 
end       

// Implement axi_ar_valid generation
// axi_r_valid is asserted for one S_AXI_ACLK clock cycle when both 
// S_AXI_AR_VALID and axi_ar_ready ar_e asserted. The slave registers 
// data ar_e available on the axi_r_data bus at this instance. The 
// assertion of axi_r_valid marks the validity of read data on the 
// bus and axi_r_resp indicates the status of read transaction.axi_r_valid 
// is deasserted on reset (active low). axi_r_resp and axi_r_data ar_e 
// clear_ed to zero on reset (active low). 
// 实现“读应答信号（axi_ar_valid）”的生成
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_r_valid <= 0;		//读数据有效信号
      axi_r_resp  <= 0;		//读应答信号
    end 
  else
    begin    
      if (axi_ar_ready && S_AXI_AR_VALID && ~axi_r_valid)
        begin
          // 读地址有效后，“读数据有效信号”设为有效
          axi_r_valid <= 1'b1;
          axi_r_resp  <= 2'b0; // 'OKAY' response
        end   
      else if (axi_r_valid && S_AXI_R_READY)
        begin
          // 读数据被接收后，将“读数据有效信号”设为无效
          axi_r_valid <= 1'b0;
        end                
    end
end    

// Implement memory mapped register select and read logic generation
// Slave register read enable is asserted when valid address is available
// and the slave is ready to accept the read address.

//实现内存映射寄存器选择和读逻辑生成


always @(*)
begin
      // Address decoding for reading registers
      case ( axi_ar_addr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
        2'h0   : reg_data_out <= slv_reg0;
        2'h1   : reg_data_out <= slv_reg1;
        2'h2   : reg_data_out <= slv_reg2;
        2'h3   : reg_data_out <= slv_reg3;
        default : reg_data_out <= 0;
      endcase
end

//从设备读寄存器使能，当读地址接收完成后，该使能信号有效，表示读数据可以输出
assign slv_reg_rden = axi_ar_ready & S_AXI_AR_VALID & ~axi_r_valid;

// Output register or memory read data
//读数据输出
always @( posedge S_AXI_ACLK )
begin
  if ( S_AXI_ARESETN == 1'b0 )
    begin
      axi_r_data  <= 0;
    end 
  else
    begin    
      // When there is a valid read address (S_AXI_AR_VALID) with 
      // acceptance of read address by the slave (axi_ar_ready), 
      // output the read dada 
      if (slv_reg_rden)
        begin
          axi_r_data <= reg_data_out;     // register read data
        end   
    end
end    

// Add user logic here

// User logic ends

endmodule
