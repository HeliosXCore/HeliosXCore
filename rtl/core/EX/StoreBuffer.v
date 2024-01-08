`include "consts/Consts.vh"
`define STORE_BUFFER_ENT_NUM 32
`define STORE_BUFFER_ENT_NUM_BITS 5

module StoreBuffer (
    (* IO_BUFFER_TYPE = "none" *) input wire clk_i,
    (* IO_BUFFER_TYPE = "none" *) input wire reset_i,
    (* IO_BUFFER_TYPE = "none" *) input wire issue_i,  // 是否有访存指令发射
    (* IO_BUFFER_TYPE = "none" *)
    input wire we_i,  // 用于区分是 store 指令还是 load 指令
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] address_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] write_data_i,
    (* IO_BUFFER_TYPE = "none" *) input wire complete_i,  // 由 ROB 传来，说明已提交，可以写入内存

    // 用于 load 指令从 store buffer 中取数的情况
    (* IO_BUFFER_TYPE = "none" *) output wire hit,  // load 指令是否命中
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] read_data_o,

    // 用于 store 指令把数据从 store buffer 实际写入到 memory
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] write_address_o,  // 写入地址
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] write_data_o  // 写入数据
);

    // 3个表示位置的循环数组指针
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] empty_ptr;  // 指示下一个空的表项
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] complete_ptr;  // 指示最新已完成的指令
    // retire_ptr: 由于采用双端口BRAM，因此写入无需考虑内存占用，因此不需要 retire_ptr

    // 假设store buffer中已有5条store指令的信息，ROB已经提交了4条，内存实际已写入了2条，示意图如下。
    // ----------- 0       1       2       3       4       5      -----------
    //                     |               |               |
    // -----------     retire_ptr     complete_ptr      empty_ptr -----------

    integer i;
    reg [`ADDR_LEN-1:0] address[`STORE_BUFFER_ENT_NUM-1:0];
    reg [`DATA_LEN-1:0] data[`STORE_BUFFER_ENT_NUM-1:0];
    // 这个变量是考虑到当某一周期store buffer数据提交到mem时，数据已在store buffer中不可用，但mem又还没有完成写入的情况，因此store buffer中数据不可用延迟一个周期
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] last_complete_ptr;

    reg hit_reg;
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] load_index;

    always @(posedge clk_i) begin
        if (reset_i) begin
            empty_ptr <= 5'bxxxxx;
            complete_ptr = 5'bxxxxx;
            last_complete_ptr <= 5'bxxxxx;
            hit_reg <= 0;
            load_index <= 5'bxxxxx;
            for (i = 0; i < `STORE_BUFFER_ENT_NUM; i = i + 1) begin
                address[i] <= `ADDR_LEN'hxxxxxxxx;
                data[i] <= `DATA_LEN'hxxxxxxxx;
            end
        end else begin
            // 延迟一个周期标记数据无效
            address[last_complete_ptr] = `ADDR_LEN'hxxxxxxxx;
            data[last_complete_ptr] = `DATA_LEN'hxxxxxxxx;
            if (issue_i) begin
                // 有访存请求
                if (we_i) begin
                    // 如果是 store 指令，注意阻塞赋值
                    empty_ptr = (empty_ptr === 5'bxxxxx) ? 0 : empty_ptr;
                    address[empty_ptr] = address_i;
                    data[empty_ptr] = write_data_i;
                    // todo: 暂未考虑 store buffer 满的情况
                    empty_ptr <= (empty_ptr == ~0) ? 0 : empty_ptr + 1;
                end else begin
                    // 如果是 load 指令
                    hit_reg <= 0;
                    load_index <= 5'bxxxxx;
                    for (i = 0; i < `STORE_BUFFER_ENT_NUM; i = i + 1) begin
                        if (address[i] == address_i) begin
                            hit_reg <= 1;
                            load_index <= i[`STORE_BUFFER_ENT_NUM_BITS-1:0];
                        end
                    end
                end
            end
            if (complete_i) begin
                // 当前指令已提交
                complete_ptr = (complete_ptr === 5'bxxxxx || complete_ptr == ~0) ? 0 : complete_ptr + 1;
                last_complete_ptr <= complete_ptr;
            end
        end
    end

    assign hit = hit_reg;
    assign read_data_o = data[load_index];
    assign write_address_o = address[complete_ptr];
    assign write_data_o = data[complete_ptr];

endmodule
