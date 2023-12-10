module PriorityEncoder #(
    parameter REQ_LEN   = 4,
    parameter GRANT_LEN = 2
) (
    input  wire [  REQ_LEN-1:0] in,
    output reg  [GRANT_LEN-1:0] out,
    output reg                  en
);

    integer i;
    always @(*) begin
        en  = 0;
        out = 0;
        for (i = REQ_LEN - 1; i >= 0; i = i - 1) begin
            if (~in[i]) begin
                out = i[GRANT_LEN-1:0];
                en  = 1;
            end
        end
    end
endmodule

module MaskUnit #(
    parameter REQ_LEN   = 4,
    parameter GRANT_LEN = 2
) (
    input  wire [GRANT_LEN-1:0] mask,
    input  wire [  REQ_LEN-1:0] in,
    output reg  [  REQ_LEN-1:0] out
);

    integer i;
    always @(*) begin
        out = 0;
        for (i = 0; i < REQ_LEN; i = i + 1) begin
            out[i] = (mask < i[GRANT_LEN-1:0]) ? 1'b0 : 1'b1;
        end
    end
endmodule

module AllocateUnit #(
    parameter REQ_LEN   = 4,
    parameter GRANT_LEN = 2
) (
    input wire [REQ_LEN-1:0] busy_i,
    output wire en_1_o,
    output wire en_2_o,
    output wire [GRANT_LEN-1:0] free_entry_1_o,
    output wire [GRANT_LEN-1:0] free_entry_2_o,
    input wire [1:0] req_num_i,
    output wire allocatable_o
);

    wire [REQ_LEN-1:0] busy_mask;

    PriorityEncoder #(REQ_LEN, GRANT_LEN) priority_encoder_1 (
        .in (busy_i),
        .out(free_entry_1_o),
        .en (en_1_o)
    );

    MaskUnit #(REQ_LEN, GRANT_LEN) mask_unit (
        .mask(free_entry_1_o),
        .in  (busy_i),
        .out (busy_mask)
    );

    PriorityEncoder #(REQ_LEN, GRANT_LEN) priority_encoder_2 (
        .in (busy_i | busy_mask),
        .out(free_entry_2_o),
        .en (en_2_o)
    );

    assign allocatable_o = (req_num_i > ({1'b0, en_1_o} + {1'b0, en_2_o})) ? 1'b0 : 1'b1;
endmodule
