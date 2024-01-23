`include "consts/Consts.vh"
`include "consts/ALU.vh"

module IFUnit (
   input wire 			clk_i,
   input wire 			reset_i,
   input wire [2*`INSN_LEN-1:0] idata_i,
   input wire [`ADDR_LEN-1:0] 	pc_i,
   input wire 			stall_IF,
   input wire 			kill_IF,
   input wire 			stall_ID,
   input wire 			kill_ID,
   input wire 			stall_DP,
   input wire 			kill_DP,	

   output reg [`ADDR_LEN-1:0] npc_o,
   output reg [`INSN_LEN-1:0] inst1_o
);

   wire [`ADDR_LEN-1:0] npc;
   wire [`INSN_LEN-1:0] inst1;

   reg [`ADDR_LEN-1:0] pc_if;
   
   always @ (posedge clk_i) begin
      if (reset_i) begin
         npc_o <= `ENTRY_POINT;
      end else if (stall_IF) begin
         npc_o <= pc_i;
      end else begin
         npc_o <= npc;
      end
   end

   PipelineIF pipeline_if(
		       .clk_i(clk_i),
		       .reset_i(reset_i),
	   	       .pc_i(pc_i),
		       .npc_o(npc),
		       .inst1_o(inst1),
		       .idata_i(idata_i)
		       );

   always @ (posedge clk_i) begin
      if (reset_i | kill_IF) begin
         pc_if <= 0;
         npc_o <= 0;
	      inst1_o <= 0;

      end else if (~stall_IF) begin
	      pc_if <= pc_i;
         npc_o <= npc;
	      inst1_o <= inst1;	 
      end
   end 


endmodule
