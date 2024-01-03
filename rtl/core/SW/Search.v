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
