`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/22 16:11:21
// Design Name: 
// Module Name: AXI_Test_M_S_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1 ps/ 1 ps
module AXI_Test_M_S_vlg_tst();

reg axi_aclk;
reg axi_aresetn;
reg axi_init_axi_txn;
// wires                                               
wire axi_error;
wire axi_txn_done;

// assign statements (if any)                          
AXI_Test_M_S i1 (
// port map - connection between master ports and signals/registers   
	.axi_aclk(axi_aclk),
	.axi_aresetn(axi_aresetn),
	.axi_error(axi_error),
	.axi_init_axi_txn(axi_init_axi_txn),
	.axi_txn_done(axi_txn_done)
);
initial                                                
begin                                                  
				axi_aclk			=	0	;
				axi_aresetn			=	0	;
				axi_init_axi_txn	=	0	;
		#100	axi_aresetn			=	1	;
		
		#100	axi_init_axi_txn	=	1	;
		
		
		#5000	$stop;
                     
end 
                                                   
always                                                 
	#10	axi_aclk	=	~axi_aclk;	 
                                                   
endmodule


