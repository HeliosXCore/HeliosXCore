`include "consts/Consts.vh"
module Arf (
    input wire  clk_i,
    input wire  reset_i,

	// 读源寄存器
    input wire [`REG_SEL-1:0]   rs1_i,
    input wire [`REG_SEL-1:0]   rs2_i,
    output wire [`DATA_LEN-1:0]  rs1_arf_data_o,
    output wire [`DATA_LEN-1:0]  rs2_arf_data_o,
    output wire     rs1_arf_busy_o,
    output wire     rs2_arf_busy_o,
	output wire [`RRF_SEL-1:0] rs1_arf_rrftag_o,
	output wire [`RRF_SEL-1:0] rs2_arf_rrftag_o,


	// COM阶段提交的指令的源寄存器编号
	// 来自于ROB
    input wire [`REG_SEL-1:0]   completed_dst_num_i,
	  // 来自于rrf
    input wire [`DATA_LEN-1:0]   from_rrfdata_i,
	  // 来自于ROB
    input wire [`RRF_SEL-1:0]   completed_dst_rrftag_i,
	  // 来自于ROB
    input wire  completed_we_i,


	// 设置目的寄存器
	input wire [`REG_SEL-1:0] dst_num_setbusy_i,
    input wire [`RRF_SEL-1:0] dst_rrftag_setbusy_i,                 //目的逻辑寄存器1，并设置其busy位
    input wire  dst_en_setbusy_i

);

// arf data的实现
  SynRam_4r2w
     #(`REG_SEL, `DATA_LEN, `REG_NUM)
  ARFData (
	.clk_i(clk_i),
	.raddr1(rs1_i),
	.raddr2(rs2_i),
	.raddr3(),
	.raddr4(),
	.rdata1(rs1_arf_data_o),
	.rdata2(rs2_arf_data_o),
	.rdata3(),
	.rdata4(),
	.waddr1(completed_dst_num_i),
	.waddr2(),
	.wdata1(from_rrfdata_i),
	.wdata2(),
	.we1(completed_we_i),
	.we2()
  );

  RenameTable re_tb(
	.clk_i(clk_i),
	.reset_i(reset_i),
	.rs1_i(rs1_i),
	.rs2_i(rs2_i),
	.rs1_arf_busy_o(rs1_arf_busy_o),
	.rs2_arf_busy_o(rs2_arf_busy_o),
	.rs1_arf_rrftag_o(rs1_arf_rrftag_o),
	.rs2_arf_rrftag_o(rs2_arf_rrftag_o),
	.completed_we_i(completed_we_i),
	.completed_dst_num_i(completed_dst_num_i),
	.completed_dst_rrftag_i(completed_dst_rrftag_i),
	.dst_en_setbusy_i(dst_en_setbusy_i),
	.dst_num_setbusy_i(dst_num_setbusy_i),
	.dst_rrftag_setbusy_i(dst_rrftag_setbusy_i)
  );
  
endmodule

module RenameTable(
  input wire clk_i,
  input wire reset_i,

  // 根据源寄存器编号读取arf.busy和arf.rrftag
  input wire [`REG_SEL-1:0] rs1_i,
  input wire [`REG_SEL-1:0] rs2_i,
  output wire rs1_arf_busy_o,
  output wire rs2_arf_busy_o,
  output wire [`RRF_SEL-1:0] rs1_arf_rrftag_o,
  output wire [`RRF_SEL-1:0] rs2_arf_rrftag_o,
  
  // 清空arf.busy位
  input wire completed_we_i,
  input wire [`REG_SEL-1:0] completed_dst_num_i,
  input wire [`RRF_SEL-1:0] completed_dst_rrftag_i,

  // 将为目的寄存器分配的rrftag写入重命名表
  input wire dst_en_setbusy_i,
  input wire [`REG_SEL-1:0] dst_num_setbusy_i,
  input wire [`RRF_SEL-1:0] dst_rrftag_setbusy_i
);

// 创建重命名表
  reg [`REG_NUM-1:0] 		 arf_busy;
  reg [`REG_NUM-1:0] 		 arf_rrftag0;
  reg [`REG_NUM-1:0] 		 arf_rrftag1;
  reg [`REG_NUM-1:0] 		 arf_rrftag2;
  reg [`REG_NUM-1:0] 		 arf_rrftag3;
  reg [`REG_NUM-1:0] 		 arf_rrftag4;
  reg [`REG_NUM-1:0] 		 arf_rrftag5;

  // 读取busy
  assign rs1_arf_busy_o = arf_busy[rs1_i];
  assign rs2_arf_busy_o = arf_busy[rs2_i];
  
  // 读取rrftag
  assign rs1_arf_rrftag_o = {arf_rrftag5[rs1_i],arf_rrftag4[rs1_i],arf_rrftag3[rs1_i],arf_rrftag2[rs1_i],arf_rrftag1[rs1_i],arf_rrftag0[rs1_i]};

  assign rs2_arf_rrftag_o = {arf_rrftag5[rs2_i],arf_rrftag4[rs2_i],arf_rrftag3[rs2_i],arf_rrftag2[rs2_i],arf_rrftag1[rs2_i],arf_rrftag0[rs2_i]};

  // clear arf busy
  always @(posedge clk_i)begin
	if(reset_i)begin
	  arf_busy <= 0;
	end else if(completed_we_i) begin
	  if(completed_dst_rrftag_i == {arf_rrftag5[completed_dst_num_i],arf_rrftag4[completed_dst_num_i],arf_rrftag3[completed_dst_num_i],arf_rrftag2[completed_dst_num_i],arf_rrftag1[completed_dst_num_i],arf_rrftag0[completed_dst_num_i]}) begin
		arf_busy[completed_dst_num_i] <= 1'b0;
	 end
   end 
 end
   always @(posedge clk_i) begin
	 if(reset_i)begin
	   arf_rrftag0 <= 0;
	   arf_rrftag1 <= 0;
	   arf_rrftag2 <= 0;
	   arf_rrftag3 <= 0;
	   arf_rrftag4 <= 0;
	   arf_rrftag5 <= 0;
	 end else if(dst_en_setbusy_i) begin
		 arf_busy[dst_num_setbusy_i] <= 1;
		 arf_rrftag0[dst_num_setbusy_i] <= dst_rrftag_setbusy_i[0];
		 arf_rrftag1[dst_num_setbusy_i] <= dst_rrftag_setbusy_i[1];
		 arf_rrftag2[dst_num_setbusy_i] <= dst_rrftag_setbusy_i[2];
		 arf_rrftag3[dst_num_setbusy_i] <= dst_rrftag_setbusy_i[3];
		 arf_rrftag4[dst_num_setbusy_i] <= dst_rrftag_setbusy_i[4];
		 arf_rrftag5[dst_num_setbusy_i] <= dst_rrftag_setbusy_i[5];
	   end
	 end 
endmodule
