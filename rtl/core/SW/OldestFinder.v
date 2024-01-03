module OldestFinder2 #(
    parameter ENTLEN = 1,
    parameter VALLEN = 8
) (
    input wire [2 * ENTLEN - 1 : 0] entry_vector_i,
    input wire [2 * VALLEN - 1 : 0] value_vector_i,
    output wire [ENTLEN - 1 : 0] oldest_entry_o,
    output wire [VALLEN - 1 : 0] oldest_value_o
);

    wire [ENTLEN - 1 : 0] entry_vector_1 = entry_vector_i[0+:ENTLEN];
    wire [ENTLEN - 1 : 0] entry_vector_2 = entry_vector_i[ENTLEN+:ENTLEN];
    wire [VALLEN - 1 : 0] value_vector_1 = value_vector_i[0+:VALLEN];
    wire [VALLEN - 1 : 0] value_vector_2 = value_vector_i[VALLEN+:VALLEN];

    assign oldest_entry_o = (value_vector_1 < value_vector_2) ? entry_vector_1 : entry_vector_2;
    assign oldest_value_o = (value_vector_1 < value_vector_2) ? value_vector_1 : value_vector_2;

endmodule

module OldestFinder4 #(
    parameter ENTLEN = 2,
    parameter VALLEN = 8
) (
    input wire [4 * ENTLEN - 1 : 0] entry_vector_i,
    input wire [4 * VALLEN - 1 : 0] value_vector_i,
    output wire [ENTLEN - 1 : 0] oldest_entry_o,
    output wire [VALLEN - 1 : 0] oldest_value_o
);
    wire [ENTLEN-1:0] old_entry_1;
    wire [ENTLEN-1:0] old_entry_2;
    wire [VALLEN-1:0] old_value_1;
    wire [VALLEN-1:0] old_value_2;

    OldestFinder2 #(
        .ENTLEN(ENTLEN),
        .VALLEN(VALLEN)
    ) oldest_finder_1 (
        .entry_vector_i({entry_vector_i[ENTLEN+:ENTLEN], entry_vector_i[0+:ENTLEN]}),
        .value_vector_i({value_vector_i[VALLEN+:VALLEN], value_vector_i[0+:VALLEN]}),
        .oldest_entry_o(old_entry_1),
        .oldest_value_o(old_value_1)
    );

    OldestFinder2 #(
        .ENTLEN(ENTLEN),
        .VALLEN(VALLEN)
    ) oldest_finder_2 (
        .entry_vector_i({entry_vector_i[3*ENTLEN+:ENTLEN], entry_vector_i[2*ENTLEN+:ENTLEN]}),
        .value_vector_i({value_vector_i[3*VALLEN+:VALLEN], value_vector_i[2*VALLEN+:VALLEN]}),
        .oldest_entry_o(old_entry_2),
        .oldest_value_o(old_value_2)
    );

    OldestFinder2 #(
        .ENTLEN(ENTLEN),
        .VALLEN(VALLEN)
    ) oldest_finder_3 (
        .entry_vector_i({old_entry_2, old_entry_1}),
        .value_vector_i({old_value_2, old_value_1}),
        .oldest_entry_o(oldest_entry_o),
        .oldest_value_o(oldest_value_o)
    );

endmodule

module OldestFinder #(
    parameter ENTLEN = 3,
    parameter VALLEN = 8
) (
    input wire [8 * ENTLEN - 1 : 0] entry_vector_i,
    input wire [8 * VALLEN - 1 : 0] value_vector_i,
    output wire [ENTLEN - 1 : 0] oldest_entry_o,
    output wire [VALLEN - 1 : 0] oldest_value_o
);

    wire [ENTLEN-1:0] old_entry_1;
    wire [ENTLEN-1:0] old_entry_2;
    wire [VALLEN-1:0] old_value_1;
    wire [VALLEN-1:0] old_value_2;

    OldestFinder4 #(
        .ENTLEN(ENTLEN),
        .VALLEN(VALLEN)
    ) oldest_finder_1 (
        .entry_vector_i({
            entry_vector_i[3*ENTLEN+:ENTLEN],
            entry_vector_i[2*ENTLEN+:ENTLEN],
            entry_vector_i[ENTLEN+:ENTLEN],
            entry_vector_i[0+:ENTLEN]
        }),
        .value_vector_i({
            value_vector_i[3*VALLEN+:VALLEN],
            value_vector_i[2*VALLEN+:VALLEN],
            value_vector_i[VALLEN+:VALLEN],
            value_vector_i[0+:VALLEN]
        }),
        .oldest_entry_o(old_entry_1),
        .oldest_value_o(old_value_1)
    );

    OldestFinder4 #(
        .ENTLEN(ENTLEN),
        .VALLEN(VALLEN)
    ) oldest_finder_2 (
        .entry_vector_i({
            entry_vector_i[7*ENTLEN+:ENTLEN],
            entry_vector_i[6*ENTLEN+:ENTLEN],
            entry_vector_i[5*ENTLEN+:ENTLEN],
            entry_vector_i[4*ENTLEN+:ENTLEN]
        }),
        .value_vector_i({
            value_vector_i[7*VALLEN+:VALLEN],
            value_vector_i[6*VALLEN+:VALLEN],
            value_vector_i[5*VALLEN+:VALLEN],
            value_vector_i[4*VALLEN+:VALLEN]
        }),
        .oldest_entry_o(old_entry_2),
        .oldest_value_o(old_value_2)
    );

    OldestFinder2 #(
        .ENTLEN(ENTLEN),
        .VALLEN(VALLEN)
    ) oldest_finder_3 (
        .entry_vector_i({old_entry_2, old_entry_1}),
        .value_vector_i({old_value_2, old_value_1}),
        .oldest_entry_o(oldest_entry_o),
        .oldest_value_o(oldest_value_o)
    );

endmodule
