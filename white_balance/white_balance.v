//编码方式是ANSI  
module white_balance
(
input   wire            rgb_clk,
input   wire            rst,
input   wire    [7:0]   rgb_r,rgb_g,rgb_b,
input   wire            rgb_lv,
input   wire            rgb_fv,
output  wire     [7:0]   r,
output  wire     [7:0]   g,
output  wire     [7:0]   b
 
); 

//
parameter COL_SUM         = 1080;
parameter ROW_SUM         = 1920;

reg     [31:0]  r_sum,b_sum,g_sum;

//accualate the RGB sum                 
always@(posedge rgb_clk or negedge rst)
        if(!rst)begin
                r_sum   <=      'd0;
                g_sum   <=      'd0;
                b_sum   <=      'd0;
        end
        else if(rgb_fv == 1'b1)begin
                r_sum   <=      'd0;
                g_sum   <=      'd0;
                b_sum   <=      'd0;
        end               
        else if(rgb_lv == 1'b1)begin
                r_sum   <=      r_sum + rgb_r;
                g_sum   <=      g_sum + rgb_g;
                b_sum   <=      b_sum + rgb_b;
        end
//
reg     [11:0]  col_cnt,row_cnt;
always@(posedge rgb_clk or negedge rst)
        if(!rst)
                row_cnt <=      'd0;              
        else if(rgb_lv == 1'b1)
                row_cnt <=      row_cnt + 1'b1;
        else
                row_cnt <=      'd0;                     

always@(posedge rgb_clk or negedge rst)
        if(!rst)
                col_cnt <=      'd0;
        else if(rgb_fv == 1'b1)
                col_cnt <=      'd0;               
        else if(row_cnt == ROW_SUM - 1'b1)
                col_cnt <=      col_cnt + 1'b1;
                
//

reg             divisor_tvalid;
wire            divisor_tready;
reg     [31:0]  divisor_tdata;
reg             dividend_tvalid;
wire            dividend_tready;
reg     [31:0]  dividend_tdata;

wire            dout_tvalid;
reg             dout_tvalid_r;
reg             dout_tvalid_rr;
reg             dout_tvalid_rrr;
wire    [39:0]  dout_tdata;

reg     [ 3:0]  div_cnt;

reg     [23:0]  kr,kg,kb,kv,kvr,kvg,kvb;

reg     [23:0]  A;          
wire    [39:0]  P;
//乘法器，由于除法器只能处理整数，所以将除数和被除数放大1000倍。
//为了节约乘法器，速度和面积互换原则，分布计算除数和被除数。
always@(posedge rgb_clk or negedge rst)
        if(!rst)
                A <=      'd0;                
        else if(dout_tvalid_r == 1'b1 && div_cnt == 'd3)
                A      <= kr+kg+kb;
        else if(dout_tvalid_rr == 1'b1)
                case(div_cnt)            
                4       :A      <=      kv;
                5       :A      <=      kv;
                6       :A      <=      kv;
                default :A      <=      'd1;
                endcase
        else if(dout_tvalid == 1'b1)
                case(div_cnt)
                3       :A      <=      kr;
                4       :A      <=      kg;
                5       :A      <=      kb;
                default :A      <=      'd1;
                endcase
//一帧图像只需要计算6次除法运算，达到6次以后保持成7，一直到下一帧图像的起始信号过来才清0。
//同时，也控制一个除法周期内保证除数和被除数的vaild信号只拉高一个周期。                 
always@(posedge rgb_clk or negedge rst)
        if(!rst)
                div_cnt <=      'd0;
        else if(rgb_fv == 1'b1)
                div_cnt <=      'd0;                  
        else if(dout_tvalid == 1'b1 && div_cnt == 'd6)
                div_cnt <=      'd7;               
        else if(dout_tvalid == 1'b1)
                div_cnt <=      div_cnt + 1'b1;
                
//divisor part
//保证在一个除法运算周期内只拉高一次vaild信号
always@(posedge rgb_clk or negedge rst)
        if(!rst)
                divisor_tvalid <=       1'b0;              
        else if((row_cnt == ROW_SUM)&&(col_cnt == COL_SUM))//一帧图片完全结束以后拉高这个被除数的vaild信号
                divisor_tvalid <=       1'b1;
        else if(dout_tvalid_r == 1'b1 && div_cnt <= 'd6)
                divisor_tvalid <=       1'b1;        
        else if(divisor_tready == 1'b1 && divisor_tvalid == 1'b1)
                divisor_tvalid <=       1'b0;

//除数，注意时序问题，保证能采到正确的数据
always@(posedge rgb_clk or negedge rst)
        if(!rst)
                divisor_tdata <=       'd1;              
        else case(div_cnt)
                0       :divisor_tdata <=      ROW_SUM * COL_SUM;
                1       :divisor_tdata <=      ROW_SUM * COL_SUM;
                2       :divisor_tdata <=      ROW_SUM * COL_SUM;
                3       :divisor_tdata <=      'd3000;
                4       :if(dout_tvalid_r == 1'b1)divisor_tdata <=      P[31:0];
                5       :if(dout_tvalid_r == 1'b1)divisor_tdata <=      P[31:0];
                6       :if(dout_tvalid_r == 1'b1)divisor_tdata <=      P[31:0];
                default :divisor_tdata <=      'd1;
              endcase  
 
               
//dividend part，和除数类似
always@(posedge rgb_clk or negedge rst)
        if(!rst)
                dividend_tvalid <=       1'b0;              
        else if((row_cnt == ROW_SUM)&&(col_cnt == COL_SUM))
                dividend_tvalid <=       1'b1;
		else if(dout_tvalid_rr == 1'b1 && div_cnt <= 'd3)
                dividend_tvalid <=       1'b1; 		
        else if(dout_tvalid_rrr == 1'b1 && div_cnt <= 'd6 && div_cnt > 'd3)
                dividend_tvalid <=       1'b1;        
        else if(dividend_tready == 1'b1 && dividend_tvalid == 1'b1)
                dividend_tvalid <=       1'b0;

always@(posedge rgb_clk or negedge rst)
        if(!rst)
                dividend_tdata <=       'd0;              
        else case(div_cnt)
                0       :dividend_tdata <=      r_sum;
                1       :dividend_tdata <=      g_sum;
                2       :dividend_tdata <=      b_sum;
                3       :dividend_tdata <=      P[31:0];
                4       :dividend_tdata <=      P[31:0];
                5       :dividend_tdata <=      P[31:0];
                6       :dividend_tdata <=      P[31:0];
                default :dividend_tdata <=      'd1;
              endcase
                 
//data part. 为了节约乘法器，在计算Kvr，Kvg和Kvb的时候，先将除数放大1000倍，然后将被除数放大1000倍。
//所以将标志信号打拍。
always@(posedge rgb_clk)begin
        dout_tvalid_r  <=       dout_tvalid;              
        dout_tvalid_rr <=       dout_tvalid_r; 
		dout_tvalid_rrr<=		dout_tvalid_rr;		
        end
        
always@(posedge rgb_clk or negedge rst)
        if(!rst)begin
                kr     <= 'd1;
                kg     <= 'd1;
                kb     <= 'd1; 
                kv     <= 'd1;
                kvr     <= 'd1;                
                kvg     <= 'd1;                
                kvb     <= 'd1;                 
        end                
        else if(dout_tvalid)
                case(div_cnt)
                        0       :kr <=      dout_tdata[28:4];//由于图像数据在0~255，所以取整数部分的低16位和小数部分的高4位。
                        1       :kg <=      dout_tdata[28:4];
                        2       :kb <=      dout_tdata[28:4];
                        3       :kv <=      dout_tdata[28:4];
                        4       :kvr <=     dout_tdata[28:4];
                        5       :kvg <=     dout_tdata[28:4];
                        6       :kvb <=     dout_tdata[28:4];
                        default :begin
                                        kr <=      kr ;
                                        kg <=      kg ;
                                        kb <=      kb ;
                                        kv <=      kv ;
                                        kvr <=     kvr;
                                        kvg <=     kvg;
                                        kvb <=     kvb;
                                 end           
                endcase        
                                           
div_gen_0 div_gen_inst (
  .aclk(rgb_clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(divisor_tvalid),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tready(divisor_tready),    // output wire s_axis_divisor_tready
  .s_axis_divisor_tdata(divisor_tdata),      // input wire [31 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(dividend_tvalid),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tready(dividend_tready),  // output wire s_axis_dividend_tready
  .s_axis_dividend_tdata(dividend_tdata),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(dout_tdata)            // output wire [39 : 0] m_axis_dout_tdata
);

mult_gen_0 mult_gen_inst (
  .A(A),  // input wire [23 : 0] A
  .B(16'd1000),  // input wire [15 : 0] B
  .P(P)  // output wire [39 : 0] P
);

wire    [31:0]  testr,testg,testb; 
assign testr = ((kvr[9]*rgb_r)<<1)+(kvr[8]*rgb_r)+((kvr[7]*rgb_r)>>1)+((kvr[6]*rgb_r)>>2)+((kvr[5]*rgb_r)>>3)+((kvr[4]*rgb_r)>>4);
assign testg = ((kvg[9]*rgb_g)<<1)+(kvg[8]*rgb_g)+((kvg[7]*rgb_g)>>1)+((kvg[6]*rgb_g)>>2)+((kvg[5]*rgb_g)>>3)+((kvg[4]*rgb_g)>>4);
assign testb = ((kvb[9]*rgb_b)<<1)+(kvb[8]*rgb_b)+((kvb[7]*rgb_b)>>1)+((kvb[6]*rgb_b)>>2)+((kvb[5]*rgb_b)>>3)+((kvb[4]*rgb_b)>>4);
assign r = (testr[8:0]>256)?255:testr[7:0];//大于255则变成255
assign g = (testg[8:0]>256)?255:testg[7:0];
assign b = (testb[8:0]>256)?255:testb[7:0];
                                                                                                       
endmodule
