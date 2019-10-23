
`timescale 1 ps/ 1 ps
module axi_full_top_vlg_tst();
// constants                                           
// general purpose registers
reg eachvec;
// test vector input registers
reg AXI_ACLK;
reg AXI_ARESETN;
reg INIT_AXI_TXN;
// wires                                               
wire TXN_DONE;

// assign statements (if any)                          
axi_full_top i1 (
// port map - connection between master ports and signals/registers   
	.AXI_ACLK(AXI_ACLK),
	.AXI_ARESETN(AXI_ARESETN),
	.INIT_AXI_TXN(INIT_AXI_TXN),
	.TXN_DONE(TXN_DONE)
);
initial                                                
begin                                                  
				AXI_ACLK		=	0;
				AXI_ARESETN		=	0;
				INIT_AXI_TXN	=	0;
				
	#1000		AXI_ARESETN		=	1;
	
	#1000		INIT_AXI_TXN	=	1;

	
	#50000		$stop;
	
end   
                                                 
always 	#20		AXI_ACLK	=	~AXI_ACLK;	                                                               
  
endmodule

