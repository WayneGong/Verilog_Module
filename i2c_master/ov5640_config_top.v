module ov5640_config_top
(
	input                       clk,
	input                       rst_n,

	output						scl_padoen_o,
	output						sda_padoen_o,
	
	inout                       cmos_scl,          //cmos i2c clock
	inout                       cmos_sda          //cmos i2c data

);

wire		[9:0]				lut_index;
wire		[31:0]				lut_data;

	
//I2C master controller
//IIC时序生成器，用于摄像头参数的配置
i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (clk                      ),
	.clk_div_cnt                (16'd500                  ),
	.i2c_addr_2byte             (1'b1                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (                         ),
	.done                       (                         ),
	.scl_padoen_o				(	scl_padoen_o						),
	.sda_padoen_o				(	sda_padoen_o						),
	
	
	.i2c_scl                    (cmos_scl                 ),
	.i2c_sda                    (cmos_sda                 )
);

//configure look-up table
//摄像头配置参数表
lut_ov5640_rgb565_480_272 lut_ov5640_rgb565_480_272_m0
(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
);

endmodule