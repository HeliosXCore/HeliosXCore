`include "consts/Consts.vh"
`define STORE_BUFFER_ENT_NUM 32
`define STORE_BUFFER_ENT_NUM_BITS 5

module StoreBuffer (
    (* IO_BUFFER_TYPE = "none" *) input wire clk_i,
    (* IO_BUFFER_TYPE = "none" *) input wire reset_i,
    (* IO_BUFFER_TYPE = "none" *) input wire issue_i,  // 是否有访存指令发射
    (* IO_BUFFER_TYPE = "none" *) input wire we_i,  // 用于区分是 store 指令还是 load 指令
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] address_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] write_data_i,
    (* IO_BUFFER_TYPE = "none" *) input wire complete_i,  // 由 ROB 传来，说明已提交，可以写入内存

    // 用于 load 指令从 store buffer 中取数的情况
    (* IO_BUFFER_TYPE = "none" *) output wire hit,  // load 指令是否命中
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] read_data_o,

    // 用于 store 指令把数据从 store buffer 实际写入到 memory
    (* IO_BUFFER_TYPE = "none" *) output wire mem_we_o,  // 写入使能
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] write_address_o,  // 写入地址
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] write_data_o  // 写入数据

);

    // 3个表示位置的循环数组指针,0作为初始化使用，实际可用表项只有 31 项。
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] used_ptr;  // 指示最新使用的表项
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] complete_ptr;  // 指示最新已完成的指令
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] retire_ptr; // 指示最新已退休的指令

    // 假设store buffer中已有5条store指令的信息，ROB已经提交了3条，内存实际已写入了1条，示意图如下。
    // ----------- 0       1       2       3       4       5      -----------
    //                     |               |               |
    // -----------     retire_ptr     complete_ptr      used_ptr  -----------

    integer i;
    reg [`ADDR_LEN-1:0] address[`STORE_BUFFER_ENT_NUM-1:0];
    reg [`DATA_LEN-1:0] data[`STORE_BUFFER_ENT_NUM-1:0];
    reg valid[`STORE_BUFFER_ENT_NUM-1:0];

    reg hit_reg;
    reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] load_index;
    reg mem_we;

    always @(posedge clk_i) begin
        if (reset_i) begin
            used_ptr = 0;
            complete_ptr = 0;
            retire_ptr = 0;
            hit_reg <= 0;
            load_index <= 0;
            mem_we <= 0;
            for (i = 0; i < `STORE_BUFFER_ENT_NUM; i = i + 1) begin
                valid[i] <= 0;
                address[i] <= 0;
                data[i] <= 0;
            end
        end else begin
            mem_we <= 0;
            hit_reg <= 0;
            if (issue_i) begin
                // 有访存请求
                if (we_i) begin
                    // store 指令
                    // todo: 暂未考虑 store buffer 满的情况
                    // 从 1 开始计数
                    used_ptr = (used_ptr == ~0) ? 1 : used_ptr + 1;
                    address[used_ptr] <= address_i;
                    data[used_ptr] <= write_data_i;
                    valid[used_ptr] <= 1;
                end else begin
                    // load 指令，从 1 开始遍历
                    for (i = 1; i < `STORE_BUFFER_ENT_NUM; i = i + 1) begin
                        if (valid[i] && address[i] == address_i ) begin
                            hit_reg <= 1;
                            load_index <= i[`STORE_BUFFER_ENT_NUM_BITS-1:0];
                        end
                    end
                end
            end
            if (complete_i) begin
                // 当前指令已提交
                complete_ptr = (complete_ptr == ~0) ? 1 : complete_ptr + 1;
            end
            if ((!issue_i || (issue_i && we_i)) && complete_ptr != retire_ptr) begin
                // 当没有指令发射或发射的指令是store指令时
                retire_ptr = (retire_ptr == ~0) ? 1 : retire_ptr + 1;
                valid[retire_ptr] <= 0;
                mem_we <= 1;
            end
        end
    end

    assign hit = hit_reg;
    assign read_data_o = data[load_index];
    assign write_address_o = address[retire_ptr];
    assign write_data_o = data[retire_ptr];
    assign mem_we_o = mem_we;

endmodule
