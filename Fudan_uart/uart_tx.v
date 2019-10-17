`timescale 1ns/1ps

module uart_tx #(
    parameter BAUDRATE = 115200, 
    parameter FREQ = 50_000_000)
(
    input 			clk, 
	input			nrst,
    input 			wrreq,
    input [7:0] 	wdata,
    output reg 		tx,
	output			tx_done,
    output reg 		rdy
);
    
reg 	[3:0] 	cnt_bit;
reg 	[31:0] 	cnt_clk;
    
localparam T = FREQ / BAUDRATE;			//发送一个字节数据需要的系统时钟数


wire 	end_cnt_clk;
wire 	end_cnt_bit;			
assign 	end_cnt_clk 	= 	( cnt_clk	==	T - 1 );
assign 	end_cnt_bit 	=	end_cnt_clk && cnt_bit == 10 - 1;

assign	tx_done			=	end_cnt_bit;

reg		[7:0] 	wdata_reg;

//rdy信号，空闲标志位。在空闲时为高电平，在发送数据期间为低电平。

always @(posedge clk or negedge nrst) 
begin
    if(nrst == 0)
        rdy <= 1;
    else if(wrreq)
        rdy <= 0;
    else if(end_cnt_bit)
        rdy <= 1;
end
    
always @(posedge clk or negedge nrst) 
begin
    if(nrst == 0)
        wdata_reg <= 8'b0;
    else if(wrreq)
        wdata_reg <= wdata;
end
 
//波特率时钟计数器生成 
always @(posedge clk or negedge nrst) 
begin
    if(nrst == 0)
		cnt_clk <= 0;
    else if(rdy == 0) 
		begin
			if(end_cnt_clk)
				cnt_clk <= 0;
			else
				cnt_clk <= cnt_clk + 1'b1;
		end
	else 
		cnt_clk <= 0;
end
 
//发送的字节数计数 
always @(posedge clk or negedge nrst) 
begin
    if(nrst == 0)
        cnt_bit <= 0;
    else if(end_cnt_clk) 
		begin
			if(end_cnt_bit)
				cnt_bit <= 0;
			else
				cnt_bit <= cnt_bit + 1'b1;
		end
end

//TX端数据赋值   
always @(posedge clk or negedge nrst) 
begin
    if(nrst == 0)
        tx <= 1;
    else if(rdy == 0 && cnt_clk == 0) 
		begin
			if(cnt_bit == 1 - 1)			//开始位，0
				tx <= 0;
			else if(cnt_bit == 10 - 1)		//结束位，1
				tx <= 1;
			else
				tx <= wdata_reg[cnt_bit - 1];	//数据位
		end
end
    
endmodule
