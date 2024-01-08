`include "consts/Consts.vh"

module MemAccessUnit (
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
    // -------------------------------------------------- Store ---------------------------------------------------------------
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] store_buffer_write_address_o,  // store buffer 要写入 mem 的地址
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] store_buffer_write_data_o,  // store buffer 要写入 mem 的数据
    // -------------------------------------------------- Load ----------------------------------------------------------------
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] load_address_o,  // 要读取的地址，传给 mem
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] load_data_from_data_memory_i,  // 从 data memory 读取到的数据
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] load_data_o  // 最后得到的数据结果
);

    reg busy;  // 当前部件是否有指令在运行
    wire is_store;  // 是否是 store 指令
    wire hit_store_buffer;  // load 指令是否命中 store buffer
    wire [`ADDR_LEN-1:0] effective_address;  // 实际访存地址
    wire [`DATA_LEN-1:0] load_data_from_store_buffer;  // 从 store buffer 中读取到的数据

    assign rob_we_o = busy;  // 向 ROB 发送完成信号; 2.表示当前执行周期有访存指令，传递给 mem
    assign rrf_we_o = busy & if_write_rrf_i; // 3种用途：1.向 RRF 发送写信号;2.因为要写寄存器，所以判断出是 load 指令;3.load 指令需要从 mem 读数据，因此表示占用 mem
    assign load_address_o = effective_address;  // 设置写入/读取地址，有效地址是通过将寄存器 rs1 与符号扩展的12位偏移量相加而获得
    assign load_data_o = hit_store_buffer ? load_data_from_store_buffer : load_data_from_data_memory_i;
    assign is_store = ~if_write_rrf_i;
    assign effective_address = src1_i + imm_i;

    always @(posedge clk_i) begin
        if (reset_i) begin
            busy <= 0;
        end else begin
            busy <= issue_i;
        end
    end

    StoreBuffer store_buffer (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .issue_i(issue_i),
        .we_i(is_store),
        .address_i(effective_address),
        .write_data_i(src2_i),
        .complete_i(complete_i),

        .hit(hit_store_buffer),
        .read_data_o(load_data_from_store_buffer),
        .write_address_o(store_buffer_write_address_o),
        .write_data_o(store_buffer_write_data_o)
    );

endmodule  // exunit_ldst
