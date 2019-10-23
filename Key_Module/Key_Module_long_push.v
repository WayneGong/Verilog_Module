//---------------------------------------------------------------------------
//--	文件名		:	key_in_Module.v
//--	描述		:	按键消抖模块，按键按下时为低电平
//---------------------------------------------------------------------------
module Key_Module_long_push
(
	clk,
	rst_n,
	key_in,
	key_out
);  
 
//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					clk;				//时钟的端口,开发板用的50MHz晶振
input					rst_n;				//复位的端口,低电平复位
input		[ 2:0]		key_in;					//对应开发板上的key_in
output		[ 2:0]		key_out;				//对应开发板上的LED

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[19:0]	time_cnt;			//用来计数按键延迟的定时计数器

reg		[ 7:0]	key_in_reg1;		//用来接收按键信号的寄存器
reg		[ 7:0]	key_in_reg2;		//key_in_reg的下一个状态


//设置定时器的时间为20ms
parameter SET_TIME_20MS = 27'd1_000_000;	


always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)							
		time_cnt	<=	20'h0;				
	else if( time_cnt == SET_TIME_20MS )
		time_cnt	<=	20'h0;	
	else
		time_cnt	<=	time_cnt	+	1'b1;
end


always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)								
		key_in_reg1	<=	8'bff;	
	else if( time_cnt == SET_TIME_20MS )
		key_in_reg1	<=	key_in;			//用来给time_cnt赋值
	else 
		key_in_reg1	<=	key_in_reg1;
end

always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)	
		key_in_reg2	<=	8'bff;
	else
		key_in_reg2	<=	key_in_reg1	;
end


assign key_out = key_in_reg1 & (~key_in_reg2 );	//判断按键有没有按下

	 
endmodule


