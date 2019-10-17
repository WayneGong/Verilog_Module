`timescale 1ns/1ps

module uart_rx  
#(
    parameter BAUDRATE 	= 	115200, 
    parameter FREQ 		= 	50_000_000
)
	
(
    input clk, nrst,
    input rx,
    output reg [7:0] rdata,
    output reg vld
);

localparam T = FREQ / BAUDRATE;			//发送一个字节数据需要的系统时钟数

reg flag;

reg 	[3:0] 	cnt_bit;
reg 	[31:0] 	cnt_clk;
reg		[7:0] 	rdata_reg;
assign	end_cnt_clk 	= 	(cnt_clk == T - 1);
assign	end_cnt_bit 	= 	end_cnt_clk && (cnt_bit == 10 - 1);

//	
always @(posedge clk or negedge nrst) 
begin
    if(nrst == 0)
        flag <= 0; 
    else if(flag == 0 && rx == 0)		//rx == 0 ,表示接收到了rx端的数据，此时将标志位置高，开始接收数据。
        flag <= 1;
    else if(cnt_bit == 1 - 1 && cnt_clk == T / 2 - 1 && rx == 1)
        flag <= 0;
    else if(end_cnt_bit)
        flag <= 0;
end
    

 
//波特率时钟计数器生成  
always @(posedge clk or negedge nrst) 
begin
    if(nrst == 0)
        cnt_clk <= 0;
    else if(flag) 
		begin
			if(end_cnt_clk)
				cnt_clk <= 0;
			else
				cnt_clk <= cnt_clk + 1'b1;
		end
    else
        cnt_clk <= 0;
end
 
//接收的字节数计数  
always @(posedge clk or negedge nrst) begin
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


//数据接收    
always @(posedge clk or negedge nrst) begin
    if(nrst == 0)
        rdata_reg <= 0;
    else if(cnt_clk == T / 2 - 1 && cnt_bit != 1 - 1 && cnt_bit != 10 - 1)
        rdata_reg[cnt_bit - 1] <= rx;
end
 
//一字节数据接收的标志位，保持一个时钟的高电平 
always @(posedge clk or negedge nrst) begin
    if(nrst == 0)
        vld <= 0;
    else if(end_cnt_bit)
        vld <= 1;		
    else
        vld <= 0;
end
   
always @(posedge clk or negedge nrst) begin
    if(nrst == 0)
        rdata	 <= 8'b0;
    else if(end_cnt_bit)
        rdata	<= rdata_reg;		
    else
        rdata	<= 8'b0;
end 

 
endmodule
