module OldestFinder2 #(
    parameter ENTLEN = 1,
    parameter VALLEN = 8
)(
    input wire [2 * ENTLEN - 1 : 0] entry_vector_i,
    input wire [2 * VALLEN - 1 : 0] value_vector_i,
    output wire [ENTLEN - 1 : 0] oldest_entry_o,
    output wire [VALLEN - 1 : 0] oldest_value_o
);

    wire [ENTLEN - 1 : 0] entry_vector_1 = entry_vector_i[0+: ENTLEN];
    wire [ENTLEN - 1 : 0] entry_vector_2 = entry_vector_i[ENTLEN+: ENTLEN];
    wire [VALLEN - 1 : 0] value_vector_1 = value_vector_i[0+: VALLEN];
    wire [VALLEN - 1 : 0] value_vector_2 = value_vector_i[VALLEN+: VALLEN];

    assign oldest_entry_o = (value_vector_1 < value_vector_2) ? entry_vector_1 : entry_vector_2;
    assign oldest_value_o = (value_vector_1 < value_vector_2) ? value_vector_1 : value_vector_2;

endmodule