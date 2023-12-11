`include "consts/Consts.vh"

module HeliosxCore (
    input wire clk_i,
    input wire reset_i,
    input wire [4 * `INSN_LEN - 1 : 0] inst_i,
    input wire [`DATA_LEN-1:0] read_dmem_data_i,

    output wire [`ADDR_LEN-1:0] pc_o,
    output wire dmem_we_o,
    output wire [`DATA_LEN-1:0] write_dmem_data_o,
    output wire [`ADDR_LEN-1:0] dmem_addr_o
);

endmodule
