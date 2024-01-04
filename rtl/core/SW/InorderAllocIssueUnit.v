module InorderAllocIssueUnit #(
    parameter ENT_SEL = 2,
    parameter ENT_NUM = 4
) (
    input clk_i,
    input reset_i,
    input [1:0] req_num_i,
    input [ENT_NUM-1:0] busy_vector_i,
    input [ENT_NUM-1:0] previsous_busy_vector_next_i,
    input [ENT_NUM-1:0] ready_vector_i,
    input wire dp_stall_i,
    input wire dp_kill_i,
    output reg [ENT_SEL-1:0] alloc_ptr_o,
    output wire allocatable_o,
    output wire [ENT_SEL-1:0] issue_ptr_o,
    output wire issue_valid_o
);
    // Pattern:
    // 1. busy_vector_i 全部为 1，此时 issue_ptr_o = alloc_ptr_o
    // 2. begin_0 和 end_0 位于 begin_1 和 end_1 之间，此时 issue_ptr_o = end_0 + 1
    // 3. begin_1 和 end_1 位于 begin_0 和 end_0 之间，此时 issue_ptr_o = begin_1

    // 第一个 0 的入口序号
    wire [ENT_SEL-1:0] begin_0;
    // 第一个 1 的入口序号
    wire [ENT_SEL-1:0] begin_1;
    // 第一个 0 的结束序号
    wire [ENT_SEL-1:0] end_0;
    // 第一个 1 的结束序号
    wire [ENT_SEL-1:0] end_1;

    wire not_full;

    Searcher #(ENT_SEL, ENT_NUM) searcher_zero (
        .begin_entry_i(~busy_vector_i),
        .begin_select_o(begin_0),
        .begin_en_o(),
        .end_entry_i(~busy_vector_i),
        .end_select_o(end_0),
        .end_en_o(not_full)
    );

    Searcher #(ENT_SEL, ENT_NUM) searcher_one (
        .begin_entry_i(busy_vector_i),
        .begin_select_o(begin_1),
        .begin_en_o(),
        .end_entry_i(busy_vector_i),
        .end_select_o(end_1),
        .end_en_o()
    );

    assign issue_ptr_o = ~not_full ? alloc_ptr_o: ((begin_1 == 0) && ({2'b0, end_1} == ENT_NUM - 1))? (end_0 + 1): begin_1;
    assign issue_valid_o = ready_vector_i[issue_ptr_o];
    assign allocatable_o = (reset_i == 1)? 0: (req_num_i == 2'h0) ? 1'b1: 
            (req_num_i == 2'h1) ? ((~busy_vector_i[alloc_ptr_o] ? 1'b1: 1'b0)): 
            ((~busy_vector_i[alloc_ptr_o] && ~busy_vector_i[alloc_ptr_o + 1]) ? 1'b1: 1'b0);

    always @(posedge clk_i) begin
        if (reset_i) begin
            alloc_ptr_o <= 0;
        end else if (~dp_stall_i && ~dp_kill_i) begin
            alloc_ptr_o <= (alloc_ptr_o + req_num_i) % ENT_NUM[ENT_SEL-1:0];
        end
    end

endmodule
