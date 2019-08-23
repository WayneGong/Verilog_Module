//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/7/19     meisq          1.0         Original
//*******************************************************************************/

module i2c_config(
	input              rst,
	input              clk,
	input[15:0]        clk_div_cnt,
	input              i2c_addr_2byte,
	output reg[9:0]    lut_index,
	input[7:0]         lut_dev_addr,
	input[15:0]        lut_reg_addr,
	input[7:0]         lut_reg_data,
	output reg         error,
	output             done,
	output				scl_padoen_o,
	output				sda_padoen_o,
	
	
	inout              i2c_scl,
	inout              i2c_sda
);
wire scl_pad_i;			//时钟输入信号线	
wire scl_pad_o;			//时钟输出信号线
//wire scl_padoen_o;		//时钟信号输出使能（低有效）

wire sda_pad_i;			//数据输入信号线	
wire sda_pad_o;			//数据输出信号线
//wire sda_padoen_o;		//数据信号输出使能（低有效）

assign sda_pad_i = i2c_sda;								//数据输入信号线总是连接到数据引脚	
assign i2c_sda = ~sda_padoen_o ? sda_pad_o : 1'bz;		//当输出使能有效时，把输出信号的值赋给引脚，否则当输出使能无效时，引脚保持高阻态，此时引脚有外部信号驱动
assign scl_pad_i = i2c_scl;								//时钟输入信号线总是连接到时钟引脚	
assign i2c_scl = ~scl_padoen_o ? scl_pad_o : 1'bz;		//和数据端口原理相同

reg i2c_read_req;					//读数据请求
wire i2c_read_req_ack;				//读数据应答
reg i2c_write_req;					//写数据请求
wire i2c_write_req_ack;				//写数据应答
wire[7:0] i2c_slave_dev_addr;		//器件ID
wire[15:0] i2c_slave_reg_addr;		//寄存器地址
wire[7:0] i2c_write_data;			
wire[7:0] i2c_read_data;			

wire err;
reg[2:0] state;

localparam S_IDLE                =  0;
localparam S_WR_I2C_CHECK        =  1;
localparam S_WR_I2C              =  2;
localparam S_WR_I2C_DONE         =  3;


assign done = (state == S_WR_I2C_DONE);
assign i2c_slave_dev_addr  = lut_dev_addr;
assign i2c_slave_reg_addr = lut_reg_addr;
assign i2c_write_data  = lut_reg_data;


always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		state <= S_IDLE;
		error <= 1'b0;
		lut_index <= 8'd0;
	end
	else 
		case(state)
			S_IDLE:
			begin
				state <= S_WR_I2C_CHECK;
				error <= 1'b0;
				lut_index <= 8'd0;
			end
			S_WR_I2C_CHECK:			//检查I2C写数据是否完成，要将摄像头的配置数据全部写入
			begin
				if(i2c_slave_dev_addr != 8'hff)
				begin
					i2c_write_req <= 1'b1;
					state <= S_WR_I2C;
				end
				else
				begin
					state <= S_WR_I2C_DONE;		//配置数据全部写完成后，将跳转到写完成状态
				end
			end
			S_WR_I2C:
			begin
				if(i2c_write_req_ack)		//一次数据写完成后，写应答信号有效，进入写检查，进行下一次操作
				begin
					error 			<= err ? 1'b1 : error; 
					lut_index 		<= lut_index + 8'd1;
					i2c_write_req 	<= 1'b0;
					state 			<= S_WR_I2C_CHECK;
				end
			end
			S_WR_I2C_DONE:
			begin
				state <= S_WR_I2C_DONE;
			end
			default:
				state <= S_IDLE;
		endcase
end



i2c_master_top i2c_master_top_m0
(
	.rst(rst),
	.clk(clk),
	.clk_div_cnt(clk_div_cnt),
	
	// I2C signals
	// i2c clock line
	.scl_pad_i(scl_pad_i),       // SCL-line input
	.scl_pad_o(scl_pad_o),       // SCL-line output (always 1'b0)
	.scl_padoen_o(scl_padoen_o),    // SCL-line output enable (active low)

	// i2c data line
	.sda_pad_i(sda_pad_i),       // SDA-line input
	.sda_pad_o(sda_pad_o),       // SDA-line output (always 1'b0)
	.sda_padoen_o(sda_padoen_o),    // SDA-line output enable (active low)
	
	.i2c_read_req(i2c_read_req),
	.i2c_addr_2byte(i2c_addr_2byte),
	.i2c_read_req_ack(i2c_read_req_ack),
	.i2c_write_req(i2c_write_req),
	.i2c_write_req_ack(i2c_write_req_ack),
	.i2c_slave_dev_addr(i2c_slave_dev_addr),
	.i2c_slave_reg_addr(i2c_slave_reg_addr),
	.i2c_write_data(i2c_write_data),
	.i2c_read_data(i2c_read_data),
	.error(err)
);
endmodule