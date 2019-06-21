`timescale 1 ps/ 1 ps

module AXI_Test_S	#
(
	// Parameters of Axi Slave Bus Interface S00_AXI
	parameter integer C_S00_AXI_DATA_WIDTH	= 32,
	parameter integer C_S00_AXI_ADDR_WIDTH	= 4
)
(
	input 	wire  									s00_axi_aclk,	
	input 	wire  									s00_axi_aresetn,	
	input 	wire [C_S00_AXI_ADDR_WIDTH-1: 0] 		s00_axi_awaddr,		
	input 	wire [ 2:0] 							s00_axi_awprot,	
	input 	wire  									s00_axi_awvalid,	
	output 	wire  									s00_axi_awready,	
	input 	wire [C_S00_AXI_DATA_WIDTH-1:0] 		s00_axi_wdata,	
	input 	wire [(C_S00_AXI_DATA_WIDTH/8)-1:0] 	s00_axi_wstrb,	
	input 	wire  									s00_axi_wvalid,	
	output 	wire  									s00_axi_wready,	
	output 	wire [ 1:0] 							s00_axi_bresp,	
	output 	wire  									s00_axi_bvalid,	
	input 	wire  									s00_axi_bready,	
	input 	wire [C_S00_AXI_ADDR_WIDTH-1:0] 		s00_axi_araddr,	
	input 	wire [ 2:0] 							s00_axi_arprot,	
	input 	wire  									s00_axi_arvalid,	
	output 	wire  									s00_axi_arready,	
	output 	wire [C_S00_AXI_DATA_WIDTH-1 : 0] 		s00_axi_rdata,	
	output 	wire [ 1:0] 							s00_axi_rresp,	
	output 	wire  									s00_axi_rvalid,	
	input 	wire  									s00_axi_rready	

);
                          
AXI_Test_S_v1_0_S00_AXI # 
( 
	.C_S_AXI_DATA_WIDTH	(	C_S00_AXI_DATA_WIDTH	),
	.C_S_AXI_ADDR_WIDTH	(	C_S00_AXI_ADDR_WIDTH	)
)	AXI_Test_S_v1_0_S00_AXI_inst 
(
	.S_AXI_ACLK		(	s00_axi_aclk		),			
	.S_AXI_ARESETN	(	s00_axi_aresetn		),          
	.S_AXI_AR_ADDR	(	s00_axi_araddr		),              
	.S_AXI_AR_PROT	(	s00_axi_arprot		),              
	.S_AXI_AR_READY	(	s00_axi_arready		),              
	.S_AXI_AR_VALID	(	s00_axi_arvalid		),              
	.S_AXI_AW_ADDR	(	s00_axi_awaddr		),              
	.S_AXI_AW_PROT	(	s00_axi_awprot		),              
	.S_AXI_AW_READY	(	s00_axi_awready		),              
	.S_AXI_AW_VALID	(	s00_axi_awvalid		),              
	.S_AXI_B_READY	(	s00_axi_bready		),              
	.S_AXI_B_RESP	(	s00_axi_bresp		),              
	.S_AXI_B_VALID	(	s00_axi_bvalid		),              
	.S_AXI_R_DATA	(	s00_axi_rdata		),              
	.S_AXI_R_READY	(	s00_axi_rready		),              
	.S_AXI_R_RESP	(	s00_axi_rresp		),              
	.S_AXI_R_VALID	(	s00_axi_rvalid		),              
	.S_AXI_W_DATA	(	s00_axi_wdata		),              
	.S_AXI_W_READY	(	s00_axi_wready		),              
	.S_AXI_W_STRB	(	s00_axi_wstrb		),              
	.S_AXI_W_VALID	(	s00_axi_wvalid		)               
);
                                                    
endmodule

