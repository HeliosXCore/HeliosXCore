// `include "consts/Consts.v"
module ROB (
    input wire clk,
    input wire reset,

    input wire dp1_i,                                               //是否发射
    input wire [`ROB_SEL-1:0] dp1_addr_i,                           //第一条发射的指令在ROB的地址
    // input wire [`ROB_SEL-1:0] dispatch_ptr_i,
    // input wire [`INSN_LEN-1:0] pc_dp1_i,
    input wire finish_ex_alu1_i,                                    //alu1单元是否执行完成
    input wire [`RRF_SEL-1:0] ex_alu1_addr_i,                       //alu1执行完成的指令在ROB的地址

    input wire [`REG_SEL-1:0] dst_dp1_i,
    input wire isValid_dst_dp1_i,

    output reg [`ROB_SEL-1:0] commit_ptr_o,
    output reg   arfwe_1_o,
    output reg [`REG_SEL-1:0] dst_arf_1_o



);
    reg [`ROB_NUM-1:0] finish;
    reg [`REG_SEL-1:0] dst [0:`ROB_NUM-1];                         //储存目的逻辑寄存器的编号
    reg [`ROB_NUM-1:0] isValid_dst;                                


    wire commit_1 = finish[commit_ptr_o];

    assign dst_arf_1_o = dst[commit_ptr_o];
    assign arfwe_1_o =  isValid_dst[commit_ptr_o] & commit_1;
    

    always @(posedge clk ) begin
        if(reset) begin
            commit_ptr_o <= 0;
            finish <= 0;
        end
        else begin
            commit_ptr_o <= (commit_ptr_o + commit_1) % (`ROB_NUM);
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