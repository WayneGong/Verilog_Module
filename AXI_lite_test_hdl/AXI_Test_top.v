module AXI_Test_M_S
(
	input  	axi_aclk,		
	input	axi_aresetn,	
	input	axi_init_axi_txn,
	output	axi_error,
	output	axi_txn_done	
);

parameter	AXI_DATA_WIDTH	=	32;
parameter	AXI_ADDR_WIDTH	=	4;


//Write address channel
wire [AXI_ADDR_WIDTH-1 : 0] 		AXI_AW_ADDR;	// Master Interface Write Address Channel ports 
wire [2 : 0] 						AXI_AW_PROT;	// Write channel Protection type.
wire  								AXI_AW_VALID;	// Write address valid. 
wire  								AXI_AW_READY;	// Write address ready.

//Write Data Channel  
wire [AXI_DATA_WIDTH-1 : 0] 		AXI_W_DATA;	// Master Interface Write Data Channel ports
wire [AXI_DATA_WIDTH/8-1 : 0] 		AXI_W_STRB;	// Write strobes. 
wire  								AXI_W_VALID;	// Write valid.
wire  								AXI_W_READY;	// Write ready.

//Write response Channel
wire [1 : 0] 						AXI_B_RESP;	// Master Interface Write Response Channel ports. 
wire  								AXI_B_VALID;	// Write response valid.
wire  								AXI_B_READY;	// Response ready.

//Read Address Channel
wire [AXI_ADDR_WIDTH-1 : 0] 		AXI_AR_ADDR;	// Master Interface Read Address Channel ports
wire [2 : 0] 						AXI_AR_PROT;	// Protection type. 
wire  								AXI_AR_VALID;	// Read address valid. 
wire  								AXI_AR_READY;	// Read address ready.

//Read response Channel
wire [AXI_DATA_WIDTH-1 : 0] 		AXI_R_DATA;	// Master Interface Read Data Channel ports
wire [1 : 0] 						AXI_R_RESP;	// Read response.
wire  								AXI_R_VALID;	// Read valid.
wire  								AXI_R_READY;
 	
AXI_Test_M 	AXI_Test_M_inst

(
	// Ports of Axi Master Bus Interface M00_AXI
	.m00_axi_init_axi_txn	(	axi_init_axi_txn),							
	.m00_axi_error			(	axi_error		),                  
	.m00_axi_txn_done		(	axi_txn_done	),                  
	.m00_axi_aclk			(	axi_aclk		),          		
	.m00_axi_aresetn		(	axi_aresetn		),
	.m00_axi_awaddr			(	AXI_AW_ADDR		),		
	.m00_axi_awprot			(	AXI_AW_PROT		),      
	.m00_axi_awvalid		(	AXI_AW_VALID	), 
	.m00_axi_awready		(	AXI_AW_READY	), 
	.m00_axi_wdata			(	AXI_W_DATA		),     
	.m00_axi_wstrb			(	AXI_W_STRB		),     
	.m00_axi_wvalid			(	AXI_W_VALID		),     
	.m00_axi_wready			(	AXI_W_READY		),     
	.m00_axi_bresp			(	AXI_B_RESP		),     
	.m00_axi_bvalid			(	AXI_B_VALID		),     
	.m00_axi_bready			(	AXI_B_READY		),     
	.m00_axi_araddr			(	AXI_AR_ADDR		),     
	.m00_axi_arprot			(	AXI_AR_PROT		),     
	.m00_axi_arvalid		(	AXI_AR_VALID	), 
	.m00_axi_arready		(	AXI_AR_READY	), 
	.m00_axi_rdata			(	AXI_R_DATA		),      
	.m00_axi_rresp			(	AXI_R_RESP		),      
	.m00_axi_rvalid			(	AXI_R_VALID		),      
	.m00_axi_rready			(	AXI_R_READY		)       
);                                         
                                           
AXI_Test_S	 AXI_Test_S_inst
(
	.s00_axi_aclk			(	axi_aclk		),	
	.s00_axi_aresetn		(	axi_aresetn		),			
	.s00_axi_awaddr			(	AXI_AW_ADDR		),		
	.s00_axi_awprot			(	AXI_AW_PROT		),			
	.s00_axi_awvalid		(	AXI_AW_VALID	),			
	.s00_axi_awready		(	AXI_AW_READY	),			
	.s00_axi_wdata			(	AXI_W_DATA		),			
	.s00_axi_wstrb			(	AXI_W_STRB		),		
	.s00_axi_wvalid			(	AXI_W_VALID		),		
	.s00_axi_wready			(	AXI_W_READY		),			
	.s00_axi_bresp			(	AXI_B_RESP		),			
	.s00_axi_bvalid			(	AXI_B_VALID		),		
	.s00_axi_bready			(	AXI_B_READY		),		
	.s00_axi_araddr			(	AXI_AR_ADDR		),		
	.s00_axi_arprot			(	AXI_AR_PROT		),		
	.s00_axi_arvalid		(	AXI_AR_VALID	),		
	.s00_axi_arready		(	AXI_AR_READY	),		
	.s00_axi_rdata			(	AXI_R_DATA		),		
	.s00_axi_rresp			(	AXI_R_RESP		),		
	.s00_axi_rvalid			(	AXI_R_VALID		),		
	.s00_axi_rready			(	AXI_R_READY		)   	
                                    	
);                                  	         
                                    	        
                                            
                                            
endmodule                                   
                                            