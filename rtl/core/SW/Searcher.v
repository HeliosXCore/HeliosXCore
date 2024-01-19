module SearchBegin #(
    parameter ENTSEL = 2,
    parameter ENTNUM = 4
) (
    input  wire [ENTNUM-1:0] entry_i,
    output reg  [ENTSEL-1:0] select_o,
    output reg               en_o
);

    integer i;
    always @(*) begin
        select_o = 0;
        en_o = 0;
        for (i = ENTNUM - 1; i >= 0; i = i - 1) begin
            if (entry_i[i]) begin
                select_o = i[ENTSEL-1:0];
                en_o = 1;
            end
        end
    end

endmodule

module SearchEnd #(
    parameter ENTSEL = 2,
    parameter ENTNUM = 4
) (
    input  wire [ENTNUM-1:0] entry_i,
    output reg  [ENTSEL-1:0] select_o,
    output reg               en_o
);

    integer i;
    always @(*) begin
        select_o = 0;
        en_o = 0;
        for (i = 0; i < ENTNUM; i = i + 1) begin
            if (entry_i[i]) begin
                select_o = i[ENTSEL-1:0];
                en_o = 1;
            end
        end
    end

endmodule

module Searcher #(
    parameter ENTSEL = 2,
    parameter ENTNUM = 4
) (
    input  wire [ENTNUM-1:0] begin_entry_i,
    output reg  [ENTSEL-1:0] begin_select_o,
    output reg               begin_en_o,
    input  wire [ENTNUM-1:0] end_entry_i,
    output reg  [ENTSEL-1:0] end_select_o,
    output reg               end_en_o
);

    SearchBegin #(
        .ENTSEL(ENTSEL),
        .ENTNUM(ENTNUM)
    ) begin_searcher (
        .entry_i(begin_entry_i),
        .select_o(begin_select_o),
        .en_o(begin_en_o)
    );

    SearchEnd #(
        .ENTSEL(ENTSEL),
        .ENTNUM(ENTNUM)
    ) end_searcher (
        .entry_i(end_entry_i),
        .select_o(end_select_o),
        .en_o(end_en_o)
    );

endmodule
