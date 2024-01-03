`include "consts/Consts.vh"
`include "consts/ALU.vh"

module IFUnit (
    input wire 			  clk_i,
    input wire 			  reset_i,
    input wire [4*`INSN_LEN-1:0] idata_i,

    output reg [`ADDR_LEN-1:0] pc_o
    //output wire [`INSN_LEN-1:0] inst1_o
    //output wire [`INSN_LEN-1:0] inst2_o,
    //output wire 		invalid2_pipe_o

);

    wire [`ADDR_LEN-1:0] npc;
    wire [`INSN_LEN-1:0] inst1;
    //wire [`INSN_LEN-1:0] inst2;
    //wire 		invalid2_pipe;

    reg [`ADDR_LEN-1:0] npc_if;
    reg [`ADDR_LEN-1:0] pc_if;
    reg [`INSN_LEN-1:0] inst1_if;
    //reg [`INSN_LEN-1:0] inst2_if;
    //reg 			    inv1_if;
    //reg 			    inv2_if;

    wire  stall_IF;
    wire  kill_IF;
    wire  stall_ID;
    wire  kill_ID;
    wire  stall_DP;
    wire  kill_DP;

    assign stall_IF = stall_ID | stall_DP;
    //assign kill_IF = prmiss;
   
   always @ (posedge clk_i) begin
      if (reset_i) begin
	 pc_o <= `ENTRY_POINT;
//     end else if (prmiss) begin
//	 pc_o <= jmpaddr;
      end else if (stall_IF) begin
	 pc_o <= pc_o;
      end else begin
	 pc_o <= npc;
      end
   end

   PipelineIF pipeline_if(
		       .clk_i(clk_i),
		       .reset_i(reset_i),
	   	       .pc_i(pc_o),
		       .npc_o(npc),
		       .inst1_o(inst1),
//		       .inst2_o(inst2_o),
//		       .invalid2_o(invalid2_pipe_o),
		       .idata_i(idata_i)
		       );

   always @ (posedge clk_i) begin
      if (reset_i | kill_IF) begin
	 npc_if <= 0;
	 pc_if <= 0;
	 inst1_if <= 0;
//	 inst2_if <= 0;
//	 inv1_if <= 1;
//	 inv2_if <= 1;
	 
      end else if (~stall_IF) begin
	 npc_if <= npc;
	 pc_if <= pc_o;
	 inst1_if <= inst1;
//	 inst2_if <= inst2_o;
//	 inv1_if <= 0;
//	 inv2_if <= invalid2_pipe_o;
	 
      end
   end // always @ (posedge clk)

endmodule
