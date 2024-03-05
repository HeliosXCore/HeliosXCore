`include "consts/Consts.vh"
module ROB (
    input wire                    clk_i,
    input wire                    reset_i,
    input wire                    dp1_i,                  //是否发射
    input wire [    `RRF_SEL-1:0] dp1_addr_i,             //第一条发射的指令在ROB的地址
    input wire [   `INSN_LEN-1:0] pc_dp1_i,
    input wire                    storebit_dp1_i,
    input wire                    dstvalid_dp1_i,
    input wire [    `REG_SEL-1:0] dst_dp1_i,
    input wire [`GSH_BHR_LEN-1:0] bhr_dp1_i,
    input wire                    isbranch_dp1_i,
    input wire                    dp2_i,
    input wire [    `RRF_SEL-1:0] dp2_addr_i,
    input wire [   `INSN_LEN-1:0] pc_dp2_i,
    input wire                    storebit_dp2_i,
    input wire                    dstvalid_dp2_i,
    input wire [    `REG_SEL-1:0] dst_dp2_i,
    input wire [`GSH_BHR_LEN-1:0] bhr_dp2_i,
    input wire                    isbranch_dp2_i,
    input wire                    finish_ex_alu1_i,       //alu1单元是否执行完成
    input wire [    `RRF_SEL-1:0] finish_ex_alu1_addr_i,  //alu1执行完成的指令在ROB的地址
    input wire                    finish_ex_alu2_i,
    input wire [ `RRF_SEL-1:0] finish_ex_alu2_addr_i,
    input wire                 finish_ex_mul_i,
    input wire [ `RRF_SEL-1:0] finish_ex_mul_addr_i,
    input wire                 finish_ex_ldst_i,
    input wire [ `RRF_SEL-1:0] finish_ex_ldst_addr_i,
    input wire                 finish_ex_branch_i,
    input wire [ `RRF_SEL-1:0] finish_ex_branch_addr_i,
    input wire                 finish_ex_branch_brcond_i,
    input wire [`ADDR_LEN-1:0] finish_ex_branch_jmpaddr_i,

    // input wire [`RRF_SEL-1:0] dispatch_ptr_i,

    // input wire [`RRF_SEL-1:0] rrf_freenum_i,
    // input wire prmiss_i,

    output reg [`ROB_SEL-1:0] commit_ptr_1_o,
    output wire [`ROB_SEL-1:0] commit_ptr_2_o,
    output wire[1:0]    comnum_o,
    output wire   store_commit_o,
    output wire   arfwe_1_o,
    output wire   arfwe_2_o,
    output wire [`REG_SEL-1:0] dst_arf_1_o,
    output wire [`REG_SEL-1:0] dst_arf_2_o,

    output wire [`ADDR_LEN-1:0] pc_combranch_o,
    output wire [`GSH_BHR_LEN-1:0] bhr_combranch_o,
    output wire [`ADDR_LEN-1:0] jmpaddr_combranch_o,
    output wire brcond_combranch_o,
    output wire combranch_o,
    output wire [`ADDR_LEN-1:0] pc_com_o


);
    //表示该 ROB entry 对应的指令是否已执行完成。当某条指令执行结束时,会将 finish 对应的位置1,表示该指令已完成执行。               
    reg [`ROB_NUM-1:0] finish;
    reg [`ROB_NUM-1:0] storebit;
    reg [`ROB_NUM-1:0] dstValid;
    reg [`ROB_NUM-1:0] brcond;
    reg [`ROB_NUM-1:0] isbranch;

    reg [`ADDR_LEN-1:0] inst_pc[0:`ROB_NUM-1];
    reg [`ADDR_LEN-1:0] jmpaddr[0:`ROB_NUM-1];
    reg [`REG_SEL-1:0] dst[0:`ROB_NUM-1];
    reg [`GSH_BHR_LEN-1:0] bhr[0:`ROB_NUM-1];


    //等价于 commit_ptr_2_o = (commit_ptr_1_o + 1) % `ROB_NUM;
    assign commit_ptr_2_o = (commit_ptr_1_o + {5'b0, 1'b1}) & 6'b1;

    // wire commit_1 = finish[commit_ptr_1_o] & ~prmiss_i;
    // wire commit_2 = finish[commit_ptr_2_o] & ~prmiss_i;


    wire commit_1 = finish[commit_ptr_1_o];
    // TODO:双指令使用下面第二行
    wire commit_2 = 0;
    // wire commit_2 = finish[commit_ptr_2_o];

    assign comnum_o = commit_1 + commit_2;

    // assign store_commit_o = (commit_1 & storebit[commit_ptr_1_o] & ~prmiss_i) | (commit_2 & storebit[commit_ptr_2_o] & ~prmiss_i);
    assign store_commit_o = (commit_1 & storebit[commit_ptr_1_o]) | (commit_2 & storebit[commit_ptr_2_o]);

    //提交到arf的目的逻辑寄存器地址
    assign dst_arf_1_o = dst[commit_ptr_1_o];
    assign dst_arf_2_o = dst[commit_ptr_2_o];

    // assign arfwe_1_o =  ~prmiss_i & dstValid[commit_ptr_1_o] & commit_1;
    // assign arfwe_2_o =  ~prmiss_i & dstValid[commit_ptr_2_o] & commit_2;

    assign arfwe_1_o = dstValid[commit_ptr_1_o] & commit_1;
    assign arfwe_2_o = dstValid[commit_ptr_2_o] & commit_2;


    // assign combranch_o = (~prmiss_i & commit_1 & isbranch[commit_ptr_1_o]) | (~prmiss_i & commit_2 & isbranch[commit_ptr_2_o]);
    // assign pc_combranch_o = (~prmiss_i & commit_1 & isbranch[commit_ptr_1_o]) ? inst_pc[commit_ptr_1_o] : inst_pc[commit_ptr_2_o];
    // assign bhr_combranch_o =( ~prmiss_i & commit_1 & isbranch[commit_ptr_1_o])? bhr[commit_ptr_1_o] : bhr[commit_ptr_2_o];
    // assign jmpaddr_combranch_o =( ~prmiss_i & commit_1 & isbranch[commit_ptr_1_o]) ?jmpaddr[commit_ptr_1_o] : jmpaddr[commit_ptr_2_o];

    assign combranch_o = (commit_1 & isbranch[commit_ptr_1_o]) | (commit_2 & isbranch[commit_ptr_2_o]);
    assign pc_combranch_o = (commit_1 & isbranch[commit_ptr_1_o]) ? inst_pc[commit_ptr_1_o] : inst_pc[commit_ptr_2_o];
    assign bhr_combranch_o = (commit_1 & isbranch[commit_ptr_1_o]) ? bhr[commit_ptr_1_o] : bhr[commit_ptr_2_o];
    assign jmpaddr_combranch_o = (commit_1 & isbranch[commit_ptr_1_o]) ? jmpaddr[commit_ptr_1_o] : jmpaddr[commit_ptr_2_o];



    always @(posedge clk_i) begin
        if (reset_i) begin
            commit_ptr_1_o <= 1;
            finish <= 0;
            brcond <= 0;
        end else begin

            //等价于commit_ptr_1_o <= (commit_ptr_1_o + commit_1 + commit_2) % (`ROB_NUM);
            //每次提交一次或两次指令,commit_ptr_1_o向后移动
            commit_ptr_1_o <= (commit_ptr_1_o + {5'b0, commit_1} + {5'b0, commit_2}) & 6'b111111;
            if (finish_ex_alu1_i) begin
                finish[finish_ex_alu1_addr_i] <= 1'b1;
                pc_com_o <= inst_pc[finish_ex_alu1_addr_i];
                
            end
            if (finish_ex_alu2_i) begin
                finish[finish_ex_alu2_addr_i] <= 1'b1;
                pc_com_o <= inst_pc[finish_ex_alu2_addr_i];
            end
            if (finish_ex_branch_i) begin
                finish[finish_ex_branch_addr_i]  <= 1'b1;
                pc_com_o <= inst_pc[finish_ex_branch_addr_i];
                //标记该条指令是否是条件分支指令
                brcond[finish_ex_branch_addr_i]  <= finish_ex_branch_brcond_i;
                //记录分支指令的跳转地址
                jmpaddr[finish_ex_branch_addr_i] <= finish_ex_branch_jmpaddr_i;

            end
            if (finish_ex_mul_i) begin
                finish[finish_ex_mul_addr_i] <= 1'b1;
                pc_com_o <= inst_pc[finish_ex_mul_addr_i];
            end
            if (finish_ex_ldst_i) begin
                finish[finish_ex_ldst_addr_i] <= 1'b1;
                pc_com_o <= inst_pc[finish_ex_ldst_addr_i];
            end
        end
    end

    always @(posedge clk_i) begin
        if (dp1_i) begin
            //标记该条指令还未执行完成
            finish[dp1_addr_i] <= 1'b0;
            // 记录指令信息
            inst_pc[dp1_addr_i] <= pc_dp1_i;
            // 记录指令的目的寄存器
            dst[dp1_addr_i] <= dst_dp1_i;
            // 标记是否为分支指令
            isbranch[dp1_addr_i] <= isbranch_dp1_i;
            // 标记是否为存储类指令
            storebit[dp1_addr_i] <= storebit_dp1_i;
            // 标记目的寄存器是否有效
            dstValid[dp1_addr_i] <= dstvalid_dp1_i;
            // 记录分支指令的跳转地址
            bhr[dp1_addr_i] <= bhr_dp1_i;
        end
        if (dp2_i) begin
            //标记该条指令还未执行完成
            finish[dp2_addr_i] <= 1'b0;
            // 记录指令信息
            inst_pc[dp2_addr_i] <= pc_dp2_i;
            // 记录指令的目的寄存器
            dst[dp2_addr_i] <= dst_dp2_i;
            // 标记是否为分支指令
            isbranch[dp2_addr_i] <= isbranch_dp2_i;
            // 标记是否为存储类指令
            storebit[dp2_addr_i] <= storebit_dp2_i;
            // 标记目的寄存器是否有效
            dstValid[dp2_addr_i] <= dstvalid_dp2_i;
            // 记录分支指令的跳转地址
            bhr[dp2_addr_i] <= bhr_dp2_i;
        end
    end



endmodule
