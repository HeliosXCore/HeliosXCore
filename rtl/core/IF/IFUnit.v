`include "consts/Consts.vh"
`include "consts/ALU.vh"

module IFUnit (
    input wire 			  clk_i,
    input wire 			  reset_i,
    input wire [`ADDR_LEN-1:0] pc_i,
    input wire [4*`INSN_LEN-1:0] idata_i,

    output wire [`ADDR_LEN-1:0] npc_o,
    output wire [`INSN_LEN-1:0] inst1_o
    //output wire [`INSN_LEN-1:0] inst2_o,
    //output wire 		invalid2_pipe_o

);

    reg [`ADDR_LEN-1:0] npc_if;
    reg [`ADDR_LEN-1:0] npc;
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
	 npc <= `ENTRY_POINT;
//     end else if (prmiss) begin
//	 pc_i <= jmpaddr;
      end else if (stall_IF) begin
	 npc <= pc_i;
      end else begin
	 npc <= pc_i+4;
      end
   end

   PipelineIF pipeline_if(
		       .clk_i(clk_i),
		       .reset_i(reset_i),
		       .pc_i(pc_i),
		       .npc_o(npc_o),
		       .inst1_o(inst1_o),
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
	 npc_if <= npc_o;
	 pc_if <= pc_i;
	 inst1_if <= inst1_o;
//	 inst2_if <= inst2_o;
//	 inv1_if <= 0;
//	 inv2_if <= invalid2_pipe_o;
	 
      end
   end // always @ (posedge clk)

endmodule
