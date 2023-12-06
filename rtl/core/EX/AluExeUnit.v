`include "consts/ALU.v"

module AluExeUnit(
   input wire clk_i,
   input wire reset_i,
   input wire if_write_rrf_i,
   input wire [ALU_OP_WIDTH-1:0]   alu_op_i,
   input wire [DATA_LEN-1:0] src1_i,
   input wire [DATA_LEN-1:0] src2_i,
   input wire issue_i,
   output wire [DATA_LEN-1:0] result_o,
   output wire reorder_buffer_we_o,
   output wire rename_register_we_o,
   );
   
   // 当前部件是否有指令在运行
   reg busy;
   assign reorder_buffer_we_o = busy;
   assign rename_register_we_o = busy & if_write_rrf_i;

   always @ (posedge clk) begin
      if (reset) begin
	 busy <= 0;
      end else begin
	 busy <= issue_i;
      end
   end

   always @(*) begin
      case (alu_op_i)
        `ALU_OP_ADD : result_o = src1_i + src2_i;
      //   `ALU_OP_SLL : result_o = src1_i << shamt;
      //   `ALU_OP_XOR : result_o = src1_i ^ src2_i;
      //   `ALU_OP_OR :  result_o = src1_i | src2_i;
      //   `ALU_OP_AND : result_o = src1_i & src2_i;
      //   `ALU_OP_SRL : result_o = src1_i >> shamt;
      //   `ALU_OP_SEQ : result_o = {31'b0, src1_i == src2_i};
      //   `ALU_OP_SNE : result_o = {31'b0, src1_i != src2_i};
      //   `ALU_OP_SUB : result_o = src1_i - src2_i;
      //   `ALU_OP_SRA : result_o = $signed(src1_i) >>> shamt;
      //   `ALU_OP_SLT : result_o = {31'b0, $signed(src1_i) < $signed(src2_i)};
      //   `ALU_OP_SGE : result_o = {31'b0, $signed(src1_i) >= $signed(src2_i)};
      //   `ALU_OP_SLTU : result_o = {31'b0, src1_i < src2_i};
      //   `ALU_OP_SGEU : result_o = {31'b0, src1_i >= src2_i};
        default : result_o = 0;
      endcase // case op
   end

endmodule