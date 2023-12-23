`include "consts/ALU.vh"
`include "consts/Consts.vh"

module BranchUnit (
    input wire clk_i,
    input wire reset_i,
    input wire if_write_rrf_i,
    input wire [`ALU_OP_WIDTH-1:0] alu_op_i,
    input wire [`DATA_LEN-1:0] src1_i,
    input wire [`DATA_LEN-1:0] src2_i,
    input wire [`ADDR_LEN-1:0] pc,
    input wire [`DATA_LEN-1:0] imm,
    input wire opcode,
    input wire issue_i,
    output wire [`DATA_LEN-1:0] result_o,
    output wire rob_we_o,
    output wire rrf_we_o,
    output wire [`ADDR_LEN-1:0] jmpaddr,
    output wire [`ADDR_LEN-1:0] jmpaddr_taken,
    output wire brcond
);

    // 当前部件是否有指令在运行
    reg busy;
    assign rob_we_o = busy;
    assign rrf_we_o = busy & if_write_rrf_i;

    always @(posedge clk_i) begin
        if (reset_i) begin
            busy <= 0;
        end else begin
            busy <= issue_i;
        end
    end

endmodule