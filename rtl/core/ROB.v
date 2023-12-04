// `include "consts/Consts.v"
module ROB (
    input wire clk,
    input wire reset,

    input wire 			  dp1_i,                                     //是否发射
    input wire [`RRF_SEL-1:0] 	  dp1_addr_i,                        //第一条发射的指令在ROB的地址
    input wire [`INSN_LEN-1:0] 	  pc_dp1_i,
    input wire 			  storebit_dp1_i,
    input wire 			  dstvalid_dp1_i,
    input wire [`REG_SEL-1:0] 	  dst_dp1_i,
    input wire [`GSH_BHR_LEN-1:0]  bhr_dp1_i,
    input wire 			  isbranch_dp1_i,
    input wire 			  dp2_i,
    input wire [`RRF_SEL-1:0] 	  dp2_addr_i,
    input wire [`INSN_LEN-1:0] 	  pc_dp2_i,
    input wire 			  storebit_dp2_i,
    input wire 			  dstvalid_dp2_i,
    input wire [`REG_SEL-1:0] 	  dst_dp2_i,
    input wire [`GSH_BHR_LEN-1:0]  bhr_dp2_i,
    input wire 			  isbranch_dp2_i,

    input wire finish_ex_alu1_i,                                    //alu1单元是否执行完成
    input wire [`RRF_SEL-1:0] finish_ex_alu1_addr_i,                       //alu1执行完成的指令在ROB的地址
    input wire 			  finish_ex_alu2_i,
    input wire [`RRF_SEL-1:0] 	  finish_ex_alu2_addr_i,
    input wire 			  finish_ex_mul_i,
    input wire [`RRF_SEL-1:0] 	  finish_exfin_mul_addr_i,
    input wire 			  finish_ex_ldst_i,
    input wire [`RRF_SEL-1:0] 	  finish_ex_ldst_addr_i,
    input wire 			  finish_ex_branch_i,
    input wire [`RRF_SEL-1:0] 	  finish_ex_branch_addr_i,
    input wire 			  finish_ex_branch_brcond_i,
    input wire [`ADDR_LEN-1:0] 	  finish_ex_branch_jmpaddr_i, 

    output reg [`ROB_SEL-1:0] commit_ptr_1_o,
    output wire [`ROB_SEL-1:0] commit_ptr_2_o,
    output wire[1:0]    comnum_o,
    output wire store_commit_O,
    output wire   arfwe_1_o,
    output wire   arfwe_2_o,
    output wire [`REG_SEL-1:0] dst_arf_1_o,
    output wire [`REG_SEL-1:0] dst_arf_2_o,



);
    reg [`ROB_NUM-1:0] finish;
    reg [`REG_SEL-1:0] dst [0:`ROB_NUM-1];                         //储存目的逻辑寄存器的编号
    reg [`ROB_NUM-1:0] isValid_dst;                                


    wire commit_1 = finish[commit_ptr_1_o];
    

    assign dst_arf_1_o = dst[commit_ptr_1_o];
    assign arfwe_1_o =  isValid_dst[commit_ptr_1_o] & commit_1;
    

    always @(posedge clk ) begin
        if(reset) begin
            commit_ptr_1_o <= 0;
            finish <= 0;
        end
        else begin
            commit_ptr_1_o <= (commit_ptr_1_o + commit_1) % (`ROB_NUM);
            if(finish_ex_alu1_i)
                finish[ex_alu1_addr_i] <= 1'b1;

        end
    end


    always @(posedge clk ) begin
        if(dp1_i) begin
            finish[dp1_addr_i] <= 1'b0;
            dst[dp1_addr_i] <= dst_dp1_i;
            isValid_dst[dp1_addr_i] <= isValid_dst_dp1_i;
        end
    end



endmodule