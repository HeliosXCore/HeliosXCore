`include "consts/Consts.vh"

module MemAccessTop (
    (* IO_BUFFER_TYPE = "none" *) input wire clk_i,
    (* IO_BUFFER_TYPE = "none" *) input wire reset_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] src1_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] src2_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] imm_i,
    (* IO_BUFFER_TYPE = "none" *) input wire if_write_rrf_i,
    (* IO_BUFFER_TYPE = "none" *) input wire issue_i,
    (* IO_BUFFER_TYPE = "none" *) input wire complete_i,

    (* IO_BUFFER_TYPE = "none" *) output wire rrf_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire rob_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] load_data_o // 最后得到的数据结果
);

    wire [`ADDR_LEN-1:0] mem_access_load_address; // load 地址，传给 mem
    wire [`DATA_LEN-1:0] mem_access_load_data_from_data_memory; // 从 mem 中读取的数据
    wire [`ADDR_LEN-1:0] mem_access_store_buffer_write_address; // store buffer 要写入 mem 的地址
    wire [`DATA_LEN-1:0] mem_access_store_buffer_write_data; // store buffer 要写入 mem 的数据

    MemAccessUnit mem_access_unit(
        .clk_i                         ( clk_i                          ),
        .reset_i                       ( reset_i                        ),
        .src1_i                        ( src1_i                         ),
        .src2_i                        ( src2_i                         ),
        .imm_i                         ( imm_i                          ),
        .if_write_rrf_i                ( if_write_rrf_i                 ),
        .issue_i                       ( issue_i                        ),
        .complete_i                    ( complete_i                     ),
        .load_data_from_data_memory_i  ( mem_access_load_data_from_data_memory   ),

        .rrf_we_o                      ( rrf_we_o                       ),
        .rob_we_o                      ( rob_we_o                       ),
        .store_buffer_write_address_o  ( mem_access_store_buffer_write_address   ),
        .store_buffer_write_data_o     ( mem_access_store_buffer_write_data      ),
        .load_address_o                ( mem_access_load_address                 ),
        .load_data_o                   ( load_data_o                    )
    );

    DataMemory data_memory(
        .clk_i                   ( clk_i               ),
        .write_address_i               ( mem_access_store_buffer_write_address   ),
        .write_data_i            ( mem_access_store_buffer_write_data ),
        .read_address_i               ( mem_access_load_address   ),

        .read_date_o             ( mem_access_load_data_from_data_memory)
    );

endmodule