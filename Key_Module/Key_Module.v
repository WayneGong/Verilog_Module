//---------------------------------------------------------------------------
//--	文件名		:	key_in_Module.v
//--	描述		:	按键消抖模块1,按下时为低有效
//---------------------------------------------------------------------------
module key_Module
#(
	KEY_NUM	=	3
)
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
input		[ KEY_NUM-1:0]		key_in;		//对应开发板上的key_in
output		[ KEY_NUM-1:0]		key_out;				

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------

reg		[31:0]			press_time_cnt;			//记录按键按下的时间
reg		[25:0]			sampling_time_cnt;		//按键采样计时器计数器
reg		[ KEY_NUM-1:0]	key_in_reg1;			//用来接收按键信号的寄存器
reg		[ KEY_NUM-1:0]	key_in_reg2;			//key_in_reg的下一个状态

reg		[ KEY_NUM-1:0]	key_long_out;
wire	[ KEY_NUM-1:0]	key_one_out;

//设置定时器的时间为20ms
//按键按下时为低电平，没有按下时为高电平
//当按键的值不为全1时，则按键被按下，此时记录按键按下的时间，当计时的低25位为全1时，计时约为0.6秒，输出一次有效的按键值，直到按键松开

always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)							
		press_time_cnt	<=	'b0;				
	else if( key_in	!= 3'b111 )		//当按键的值不为全1时，则按键被按下
		press_time_cnt	<=	press_time_cnt	+	1'b1;			
	else
		press_time_cnt	<=	'b0;
end


always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)								
		key_long_out	<=	8'h00;	
	else if( ( press_time_cnt[24:0] == 25'h1ff_ffff ) && ( press_time_cnt > SET_TIME_1S )  ) 
		key_long_out	<=	~key_in;			//按下的按键为低电平，取反后输出。
	else 
		key_long_out	<=	8'h00;	
end

//设置定时器的时间为2ms，每过2ms采样一次按键的值
parameter SET_TIME_2MS 	= 20'd100_000;	
parameter SET_TIME_1S 	= 32'd50_000_000;

always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)							
		sampling_time_cnt	<=	20'h0;				
	else if( sampling_time_cnt == SET_TIME_2MS )
		sampling_time_cnt	<=	20'h0;	
	else
		sampling_time_cnt	<=	sampling_time_cnt	+	1'b1;
end

always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)								
		key_in_reg1	<=	8'b1111_1111;	
	else if( sampling_time_cnt == SET_TIME_2MS ) 
		key_in_reg1	<=	key_in;			//用来给time_cnt赋值
	else 
		key_in_reg1	<=	key_in_reg1;
end

always @ (posedge clk, negedge rst_n)
begin
	if(!rst_n)	
		key_in_reg2	<=	8'b1111_1111;
	else
		key_in_reg2	<=	key_in_reg1	;
end

assign	key_one_out = key_in_reg1 & (~key_in_reg2 )	;

assign	key_out	=	( press_time_cnt <= SET_TIME_1S )	?	key_one_out	: key_long_out;

endmodule


