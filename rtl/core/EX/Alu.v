`include "consts/ALU.vh"
`include "consts/Consts.vh"

module Alu (
    (* IO_BUFFER_TYPE = "none" *) input wire [`ALU_OP_WIDTH-1:0] op,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] in1,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] in2,

    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] out
);

    wire [`SHAMT_WIDTH-1:0] shamt;
    assign shamt = in2[`SHAMT_WIDTH-1:0];

    assign out = (op == `ALU_OP_ADD) ? (in1 + in2) : 
                (op == `ALU_OP_SLL) ? (in1 << shamt) :
                (op == `ALU_OP_XOR) ? (in1 ^ in2) :
                (op == `ALU_OP_OR)  ? (in1 | in2) :
                (op == `ALU_OP_AND) ? (in1 & in2) :
                (op == `ALU_OP_SRL) ? (in1 >> shamt) :
                (op == `ALU_OP_SEQ) ? {31'b0, in1 == in2} :
                (op == `ALU_OP_SNE) ? {31'b0, in1 != in2} :
                (op == `ALU_OP_SUB) ? (in1 - in2) :
                (op == `ALU_OP_SRA) ? ($signed(in1) >>> shamt) : 
                (op == `ALU_OP_SLT) ? {31'b0, $signed(in1) < $signed(in2)} : 
                (op == `ALU_OP_SGE) ? {31'b0, $signed(in1) >= $signed(in2)} : 
                (op == `ALU_OP_SLTU) ? {31'b0, in1 < in2} : 
                (op == `ALU_OP_SGEU) ? {31'b0, in1 >= in2} : 0;

endmodule
