module axi_full_top
#
(
	parameter  	C_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
	parameter integer C_AXI_BURST_LEN	= 16,
	parameter integer C_AXI_ID_WIDTH	= 1,
	parameter integer C_AXI_ADDR_WIDTH	= 32,
	parameter integer C_AXI_DATA_WIDTH	= 32,
	parameter integer C_AXI_AWUSER_WIDTH	= 0,
	parameter integer C_AXI_ARUSER_WIDTH	= 0,
	parameter integer C_AXI_WUSER_WIDTH	= 0,
	parameter integer C_AXI_RUSER_WIDTH	= 0,
	parameter integer C_AXI_BUSER_WIDTH	= 0
)
(
	input			INIT_AXI_TXN,
	input			AXI_ACLK,
	input			AXI_ARESETN,	
	output			TXN_DONE
);

	wire [C_AXI_ID_WIDTH-1 : 0] 		AXI_AWID;
	wire [C_AXI_ADDR_WIDTH-1 : 0] 		AXI_AWADDR;
	wire [7 : 0] 						AXI_AWLEN;
	wire [2 : 0] 						AXI_AWSIZE;
	wire [1 : 0] 						AXI_AWBURST;
	wire  								AXI_AWLOCK;
	wire [3 : 0] 						AXI_AWCACHE;
	wire [2 : 0] 						AXI_AWPROT;
	wire [3 : 0] 						AXI_AWQOS;
	//wire [3 : 0] 						AXI_AWREGION;		//unuse  this port
	wire [C_AXI_AWUSER_WIDTH-1 : 0] 	AXI_AWUSER;
	wire  								AXI_AWVALID;
	wire  								AXI_AWREADY;
	wire [C_AXI_DATA_WIDTH-1 : 0] 		AXI_WDATA;
	wire [(C_AXI_DATA_WIDTH/8)-1 : 0]	AXI_WSTRB;
	wire  								AXI_WLAST;
	wire [C_AXI_WUSER_WIDTH-1 : 0] 		AXI_WUSER;
	wire  								AXI_WVALID;
	wire  								AXI_WREADY;
	wire [C_AXI_ID_WIDTH-1 : 0] 		AXI_BID;
	wire [1 : 0] 						AXI_BRESP;
	wire [C_AXI_BUSER_WIDTH-1 : 0] 		AXI_BUSER;
	wire  								AXI_BVALID;
	wire  								AXI_BREADY;
	wire [C_AXI_ID_WIDTH-1 : 0] 		AXI_ARID;
	wire [C_AXI_ADDR_WIDTH-1 : 0] 		AXI_ARADDR;
	wire [7 : 0] 						AXI_ARLEN;
	wire [2 : 0] 						AXI_ARSIZE;
	wire [1 : 0] 						AXI_ARBURST;
	wire  								AXI_ARLOCK;
	wire [3 : 0] 						AXI_ARCACHE;
	wire [2 : 0] 						AXI_ARPROT;
	wire [3 : 0] 						AXI_ARQOS;
	//wire [3 : 0] 						AXI_ARREGION;		//unuse  this port
	wire [C_AXI_ARUSER_WIDTH-1 : 0] 	AXI_ARUSER;
	wire  								AXI_ARVALID;
	wire  								AXI_ARREADY;
	wire [C_AXI_ID_WIDTH-1 : 0] 		AXI_RID;
	wire [C_AXI_DATA_WIDTH-1 : 0]		AXI_RDATA;
	wire [1 : 0] 						AXI_RRESP;
	wire  								AXI_RLAST;
	wire [C_AXI_RUSER_WIDTH-1 : 0] 		AXI_RUSER;
	wire  								AXI_RVALID;
	wire  								AXI_RREADY;

axi_master_v1_0_M00_AXI axi_master_v1_0_M00_AXI_inst
(
	.INIT_AXI_TXN		(	INIT_AXI_TXN 	) ,	// input  INIT_AXI_TXN 
	.TXN_DONE			(	TXN_DONE 		) ,	// output  TXN_DONE 
	.ERROR				(	ERROR 			) ,	// output  ERROR 
	.M_AXI_ACLK			(	AXI_ACLK 		) ,	// input  M_AXI_ACLK 
	.M_AXI_ARESETN		(	AXI_ARESETN 	) ,	// input  M_AXI_ARESETN 
	.M_AXI_AWID			(	AXI_AWID 		) ,	// output [C_M_AXI_ID_WIDTH-1:0] M_AXI_AWID 
	.M_AXI_AWADDR		(	AXI_AWADDR 		) ,	// output [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR 
	.M_AXI_AWLEN		(	AXI_AWLEN 		) ,	// output [7:0] M_AXI_AWLEN 
	.M_AXI_AWSIZE		(	AXI_AWSIZE 		) ,	// output [2:0] M_AXI_AWSIZE 
	.M_AXI_AWBURST		(	AXI_AWBURST 	) ,	// output [1:0] M_AXI_AWBURST 
	.M_AXI_AWLOCK		(	AXI_AWLOCK 		) ,	// output  M_AXI_AWLOCK 
	.M_AXI_AWCACHE		(	AXI_AWCACHE 	) ,	// output [3:0] M_AXI_AWCACHE 
	.M_AXI_AWPROT		(	AXI_AWPROT 		) ,	// output [2:0] M_AXI_AWPROT 
	.M_AXI_AWQOS		(	AXI_AWQOS 		) ,	// output [3:0] M_AXI_AWQOS 
	.M_AXI_AWUSER		(	AXI_AWUSER 		) ,	// output [C_M_AXI_AWUSER_WIDTH-1:0] M_AXI_AWUSER 
	.M_AXI_AWVALID		(	AXI_AWVALID 	) ,	// output  M_AXI_AWVALID 
	.M_AXI_AWREADY		(	AXI_AWREADY 	) ,	// input  M_AXI_AWREADY 
	.M_AXI_WDATA		(	AXI_WDATA 		) ,	// output [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA 
	.M_AXI_WSTRB		(	AXI_WSTRB 		) ,	// output [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB 
	.M_AXI_WLAST		(	AXI_WLAST 		) ,	// output  M_AXI_WLAST 
	.M_AXI_WUSER		(	AXI_WUSER 		) ,	// output [C_M_AXI_WUSER_WIDTH-1:0] M_AXI_WUSER 
	.M_AXI_WVALID		(	AXI_WVALID 		) ,	// output  M_AXI_WVALID 
	.M_AXI_WREADY		(	AXI_WREADY 		) ,	// input  M_AXI_WREADY 
	.M_AXI_BID			(	AXI_BID 		) ,	// input [C_M_AXI_ID_WIDTH-1:0] M_AXI_BID 
	.M_AXI_BRESP		(	AXI_BRESP 		) ,	// input [1:0] M_AXI_BRESP 
	.M_AXI_BUSER		(	AXI_BUSER		) ,	// input [C_M_AXI_BUSER_WIDTH-1:0] M_AXI_BUSER 
	.M_AXI_BVALID		(	AXI_BVALID		) ,	// input  M_AXI_BVALID 
	.M_AXI_BREADY		(	AXI_BREADY 		) ,	// output  M_AXI_BREADY 
	.M_AXI_ARID			(	AXI_ARID 		) ,	// output [C_M_AXI_ID_WIDTH-1:0] M_AXI_ARID 
	.M_AXI_ARADDR		(	AXI_ARADDR 		) ,	// output [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR 
	.M_AXI_ARLEN		(	AXI_ARLEN 		) ,	// output [7:0] M_AXI_ARLEN 
	.M_AXI_ARSIZE		(	AXI_ARSIZE 		) ,	// output [2:0] M_AXI_ARSIZE 
	.M_AXI_ARBURST		(	AXI_ARBURST 	) ,	// output [1:0] M_AXI_ARBURST 
	.M_AXI_ARLOCK		(	AXI_ARLOCK 		) ,	// output  M_AXI_ARLOCK 
	.M_AXI_ARCACHE		(	AXI_ARCACHE 	) ,	// output [3:0] M_AXI_ARCACHE 
	.M_AXI_ARPROT		(	AXI_ARPROT 		) ,	// output [2:0] M_AXI_ARPROT 
	.M_AXI_ARQOS		(	AXI_ARQOS 		) ,	// output [3:0] M_AXI_ARQOS 
	.M_AXI_ARUSER		(	AXI_ARUSER 		) ,	// output [C_M_AXI_ARUSER_WIDTH-1:0] M_AXI_ARUSER 
	.M_AXI_ARVALID		(	AXI_ARVALID 	) ,	// output  M_AXI_ARVALID 
	.M_AXI_ARREADY		(	AXI_ARREADY 	) ,	// input  M_AXI_ARREADY 
	.M_AXI_RID			(	AXI_RID 		) ,	// input [C_M_AXI_ID_WIDTH-1:0] M_AXI_RID 
	.M_AXI_RDATA		(	AXI_RDATA 		) ,	// input [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA 
	.M_AXI_RRESP		(	AXI_RRESP 		) ,	// input [1:0] M_AXI_RRESP 
	.M_AXI_RLAST		(	AXI_RLAST 		) ,	// input  M_AXI_RLAST 
	.M_AXI_RUSER		(	AXI_RUSER 		) ,	// input [C_M_AXI_RUSER_WIDTH-1:0] M_AXI_RUSER 
	.M_AXI_RVALID		(	AXI_RVALID		) ,	// input  M_AXI_RVALID 
	.M_AXI_RREADY		(	AXI_RREADY 		) 	// output  M_AXI_RREADY 
);

defparam axi_master_v1_0_M00_AXI_inst.C_M_TARGET_SLAVE_BASE_ADDR	=	C_AXI_TARGET_SLAVE_BASE_ADDR;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_BURST_LEN 			=	C_AXI_BURS  T_LEN;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_ID_WIDTH 				=	C_AXI_ID_WIDTH;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_ADDR_WIDTH 			=	C_AXI_ADDR_WIDTH;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_DATA_WIDTH 			=	C_AXI_DATA_WIDTH;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_AWUSER_WIDTH 			=	C_AXI_AWUSER_WIDTH;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_ARUSER_WIDTH 			=	C_AXI_ARUSER_WIDTH;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_WUSER_WIDTH 			=	C_AXI_WUSER_WIDTH;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_RUSER_WIDTH 			=	C_AXI_RUSER_WIDTH;
defparam axi_master_v1_0_M00_AXI_inst.C_M_AXI_BUSER_WIDTH 			=	C_AXI_BUSER_WIDTH;




axi_slave_v1_0_S00_AXI axi_slave_v1_0_S00_AXI_inst
(
	.S_AXI_ACLK			(	AXI_ACLK 		) ,	// input  S_AXI_ACLK 
	.S_AXI_ARESETN		(	AXI_ARESETN 	) ,	// input  S_AXI_ARESETN 
	.S_AXI_AWID			(	AXI_AWID 		) ,	// input [C_S_AXI_ID_WIDTH-1:0] S_AXI_AWID 
	.S_AXI_AWADDR		(	AXI_AWADDR 		) ,	// input [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR 
	.S_AXI_AWLEN		(	AXI_AWLEN 		) ,	// input [7:0] S_AXI_AWLEN 
	.S_AXI_AWSIZE		(	AXI_AWSIZE 		) ,	// input [2:0] S_AXI_AWSIZE 
	.S_AXI_AWBURST		(	AXI_AWBURST 	) ,	// input [1:0] S_AXI_AWBURST 
	.S_AXI_AWLOCK		(	AXI_AWLOCK 		) ,	// input  S_AXI_AWLOCK 
	.S_AXI_AWCACHE		(	AXI_AWCACHE 	) ,	// input [3:0] S_AXI_AWCACHE 
	.S_AXI_AWPROT		(	AXI_AWPROT 		) ,	// input [2:0] S_AXI_AWPROT 
	.S_AXI_AWQOS		(	AXI_AWQOS 		) ,	// input [3:0] S_AXI_AWQOS 
//	.S_AXI_AWREGION		(	AXI_AWREGION 	) ,	// input [3:0] S_AXI_AWREGION 
	.S_AXI_AWUSER		(	AXI_AWUSER 		) ,	// input [C_S_AXI_AWUSER_WIDTH-1:0] S_AXI_AWUSER 
	.S_AXI_AWVALID		(	AXI_AWVALID 	) ,	// input  S_AXI_AWVALID 
	.S_AXI_AWREADY		(	AXI_AWREADY 	) ,	// output  S_AXI_AWREADY 
	.S_AXI_WDATA		(	AXI_WDATA 		) ,	// input [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA 
	.S_AXI_WSTRB		(	AXI_WSTRB 		) ,	// input [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB 
	.S_AXI_WLAST		(	AXI_WLAST 		) ,	// input  S_AXI_WLAST 
	.S_AXI_WUSER		(	AXI_WUSER 		) ,	// input [C_S_AXI_WUSER_WIDTH-1:0] S_AXI_WUSER 
	.S_AXI_WVALID		(	AXI_WVALID 		) ,	// input  S_AXI_WVALID 
	.S_AXI_WREADY		(	AXI_WREADY 		) ,	// output  S_AXI_WREADY 
	.S_AXI_BID			(	AXI_BID 		) ,	// output [C_S_AXI_ID_WIDTH-1:0] S_AXI_BID 
	.S_AXI_BRESP		(	AXI_BRESP 		) ,	// output [1:0] S_AXI_BRESP 
	.S_AXI_BUSER		(	AXI_BUSER 		) ,	// output [C_S_AXI_BUSER_WIDTH-1:0] S_AXI_BUSER 
	.S_AXI_BVALID		(	AXI_BVALID 		) ,	// output  S_AXI_BVALID 
	.S_AXI_BREADY		(	AXI_BREADY 		) ,	// input  S_AXI_BREADY 
	.S_AXI_ARID			(	AXI_ARID 		) ,	// input [C_S_AXI_ID_WIDTH-1:0] S_AXI_ARID 
	.S_AXI_ARADDR		(	AXI_ARADDR 		) ,	// input [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR 
	.S_AXI_ARLEN		(	AXI_ARLEN 		) ,	// input [7:0] S_AXI_ARLEN 
	.S_AXI_ARSIZE		(	AXI_ARSIZE 		) ,	// input [2:0] S_AXI_ARSIZE 
	.S_AXI_ARBURST		(	AXI_ARBURST 	) ,	// input [1:0] S_AXI_ARBURST 
	.S_AXI_ARLOCK		(	AXI_ARLOCK 		) ,	// input  S_AXI_ARLOCK 
	.S_AXI_ARCACHE		(	AXI_ARCACHE 	) ,	// input [3:0] S_AXI_ARCACHE 
	.S_AXI_ARPROT		(	AXI_ARPROT 		) ,	// input [2:0] S_AXI_ARPROT 
	.S_AXI_ARQOS		(	AXI_ARQOS 		) ,	// input [3:0] S_AXI_ARQOS 
//	.S_AXI_ARREGION		(	AXI_ARREGION 	) ,	// input [3:0] S_AXI_ARREGION 
	.S_AXI_ARUSER		(	AXI_ARUSER 		) ,	// input [C_S_AXI_ARUSER_WIDTH-1:0] S_AXI_ARUSER 
	.S_AXI_ARVALID		(	AXI_ARVALID 	) ,	// input  S_AXI_ARVALID 
	.S_AXI_ARREADY		(	AXI_ARREADY 	) ,	// output  S_AXI_ARREADY 
	.S_AXI_RID			(	AXI_RID 		) ,	// output [C_S_AXI_ID_WIDTH-1:0] S_AXI_RID 
	.S_AXI_RDATA		(	AXI_RDATA 		) ,	// output [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA 
	.S_AXI_RRESP		(	AXI_RRESP 		) ,	// output [1:0] S_AXI_RRESP 
	.S_AXI_RLAST		(	AXI_RLAST 		) ,	// output  S_AXI_RLAST 
	.S_AXI_RUSER		(	AXI_RUSER 		) ,	// output [C_S_AXI_RUSER_WIDTH-1:0] S_AXI_RUSER 
	.S_AXI_RVALID		(	AXI_RVALID 		) ,	// output  S_AXI_RVALID 
	.S_AXI_RREADY		(	AXI_RREADY 		) 	// input  S_AXI_RREADY 
);

defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_ID_WIDTH 		= C_AXI_ID_WIDTH;
defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_DATA_WIDTH 	= C_AXI_DATA_WIDTH;
defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_ADDR_WIDTH 	= C_AXI_ADDR_WIDTH;
defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_AWUSER_WIDTH 	= C_AXI_AWUSER_WIDTH;
defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_ARUSER_WIDTH 	= C_AXI_ARUSER_WIDTH;
defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_WUSER_WIDTH 	= C_AXI_WUSER_WIDTH;
defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_RUSER_WIDTH 	= C_AXI_RUSER_WIDTH;
defparam axi_slave_v1_0_S00_AXI_inst.C_S_AXI_BUSER_WIDTH 	= C_AXI_BUSER_WIDTH;


endmodule	