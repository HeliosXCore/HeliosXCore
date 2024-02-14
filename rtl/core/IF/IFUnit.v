`include "consts/Consts.vh"
`include "consts/ALU.vh"

module IFUnit (
    input wire    clk_i,
    input wire    reset_i,
    input wire    [`INSN_LEN-1:0] idata_i,
    input wire    stall_IF,
    input wire    kill_IF,
    input wire    stall_ID,
    input wire    kill_ID,
    input wire    stall_DP,
    input wire    kill_DP,

    output reg  [`ADDR_LEN-1:0] npc_o,
    //实际上npc_o这里并没有起到什么作用
    //output wire [`ADDR_LEN-1:0] npc_o,
    output reg  [`INSN_LEN-1:0] inst_o,
    output wire [`ADDR_LEN-1:0] iaddr_o
);

    wire [`ADDR_LEN-1:0] npc;
    wire [`INSN_LEN-1:0] inst;

    // reg  [`ADDR_LEN-1:0] pc_if;
    reg  [`ADDR_LEN-1:0] pc;

    always @(posedge clk_i) begin
        if (reset_i) begin
            pc <= `ENTRY_POINT;
        end else begin
            pc <= npc;
        end
    end


    //assign iaddr_o = reset_i ? `ENTRY_POINT : stall_IF ? pc : npc;

    always @(posedge clk_i) begin
        if (reset_i) begin
            npc_o <= `ENTRY_POINT;
        end else if (stall_IF) begin
            npc_o <= pc;
        end else begin
            npc_o <= npc;
        end
    end

    PipelineIF pipeline_if (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .pc_i(pc),
        .npc_o(npc),
        .inst_o(inst),
        .idata_i(idata_i)
    );

    always @(posedge clk_i) begin
        if (reset_i | kill_IF) begin
            // 这个感觉不需要啊
            // pc_if  <= 0;
            inst_o <= 0;

        end else if (~stall_IF) begin
            // pc_if  <= pc;
            inst_o <= inst;
        end
    end

    assign iaddr_o = npc_o;


endmodule
