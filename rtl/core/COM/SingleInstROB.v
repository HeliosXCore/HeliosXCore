`include "consts/Consts.vh"
module SingleInstROB (
    input wire                 clk_i,
    input wire                 reset_i,
    input wire                 dp1_i,                 //是否发射
    input wire [ `RRF_SEL-1:0] dp1_addr_i,            //第一条发射的指令在ROB的地址
    input wire [`INSN_LEN-1:0] pc_dp1_i,
    input wire                 dstvalid_dp1_i,
    input wire [ `REG_SEL-1:0] dst_dp1_i,
    input wire                 finish_ex_alu1_i,      //alu1单元是否执行完成
    input wire [ `RRF_SEL-1:0] finish_ex_alu1_addr_i, //alu1执行完成的指令在ROB的地址

    output reg [`ROB_SEL-1:0] commit_ptr_1_o,
    output wire arfwe_1_o,
    output wire [`REG_SEL-1:0] dst_arf_1_o,
    output wire [`ADDR_LEN-1:0] pc_com_o,
    output wire comnum_o

);

    //表示该 ROB entry 当前是否有效,即是否已被分配给某条指令。当新指令被分派时,会将对应 entry 的 valid 位置1,表示现在有效。
    reg [`ROB_NUM-1:0] valid;
    //表示该 ROB entry 对应的指令是否已执行完成。当某条指令执行结束时,会将 finish 对应的位置1,表示该指令已完成执行。               
    reg [`ROB_NUM-1:0] finish;
    //表明该 ROB entry 对应的dst是否有效。
    reg [`ROB_NUM-1:0] dstValid;
    reg [`ADDR_LEN-1:0] inst_pc[0:`ROB_NUM-1];
    reg [`REG_SEL-1:0] dst[0:`ROB_NUM-1];

    wire commit_1;

    //当valid和finish同时为1时,允许提交
    assign commit_1 = valid[commit_ptr_1_o] & finish[commit_ptr_1_o];

    //提交指令的数量
    assign comnum_o = commit_1;

    //提交到arf的目的逻辑寄存器地址
    assign dst_arf_1_o = dst[commit_ptr_1_o];

    assign pc_com_o = inst_pc[commit_ptr_1_o];

    wire [`ROB_SEL-1:0] tmp;
    wire [`ROB_SEL-1:0] tmp1;
    assign tmp = ((commit_ptr_1_o + {5'b0, commit_1}) & 6'b111111);
    assign tmp1 = (tmp == 0) ? 1 : tmp;

    //当commit_1 和 dstvalid同时为1时,允许写回寄存器
    assign arfwe_1_o = dstValid[commit_ptr_1_o] & commit_1;

    always @(posedge clk_i) begin
        if (reset_i) begin
            valid <= 0;
            finish <= 0;
            commit_ptr_1_o <= 1;
        end else begin
            //更新提交指针
            //等价于commit_ptr_1_o = (commit_ptr_1_o + commit_1) % `ROB_NUM;
            commit_ptr_1_o <= tmp1;
            // commit_ptr_1_o <= commit_ptr_1_o + {5'b0, commit_1};
            //当执行单元完成时,更新完成标志
            if (finish_ex_alu1_i) begin
                finish[finish_ex_alu1_addr_i] <= 1'b1;
            end
            // 当ROB entry的指令提交时,将valid置0
            if (commit_1) begin
                valid[commit_ptr_1_o] <= 1'b0;
            end
        end
    end

    always @(posedge clk_i) begin
        if (dp1_i) begin
            // // 分配ROB entry
            valid[dp1_addr_i] <= 1'b1;
            //标记该条指令还未执行完成
            finish[dp1_addr_i] <= 1'b0;
            // 记录指令信息
            inst_pc[dp1_addr_i] <= pc_dp1_i;
            // 记录指令的目的寄存器
            dst[dp1_addr_i] <= dst_dp1_i;
            // 标记目的寄存器是否有效
            dstValid[dp1_addr_i] <= dstvalid_dp1_i;

        end

    end


endmodule
