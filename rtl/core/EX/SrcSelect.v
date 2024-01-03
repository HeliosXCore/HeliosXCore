`include "consts/Consts.vh"

module SrcASelect(
    (* IO_BUFFER_TYPE = "none" *) input wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] pc,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] rs1,
    
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] alu_src_a
);

    assign alu_src_a = (src_a_sel == `SRC_A_RS1) ? rs1 : (src_a_sel == `SRC_A_PC) ? pc : 0;

endmodule

module SrcBSelect(
    (* IO_BUFFER_TYPE = "none" *) input wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] imm,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] rs2,
    
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] alu_src_b
);

    assign alu_src_b = (src_b_sel == `SRC_B_RS2) ? rs2 : (src_b_sel == `SRC_B_IMM) ? imm : (src_b_sel == `SRC_B_FOUR) ? 4 : 0;

endmodule