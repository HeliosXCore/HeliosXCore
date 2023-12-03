`include "consts.v"
module ARF (
    input wire  clk,
    input wire  eset,
    input wire [`REG_SEL-1:0]   rs1_1_i,
    input wire [`REG_SEL-1:0]   rs2_1_i,
    input wire [`DATA_LEN-1:0]  rs1_1_data_i,
    input wire [`DATA_LEN-1:0]  rs2_1_data_i,

    input wire [`REG_SEL-1:0]   rs1_2_i,
    input wire [`REG_SEL-1:0]   rs2_2_i,
    input wire [`DATA_LEN-1:0]  rs1_2_data_i,
    input wire [`DATA_LEN-1:0]  rs2_2_data_i,

    input wire [`REG_SEL-1:0]   com_dst1_i,
    input wire [`REG_SEL-1:0]   com_dst1_data_i,
    input wire [`RRF_SEL-1:0]   com_dst1_renamed_i,
    input wire  com_dst1_we_i,

    input wire [`REG_SEL-1:0]   com_dst2_i,
    input wire [`REG_SEL-1:0]   com_dst2_data_i,    
    input wire [`RRF_SEL-1:0]   com_dst2_renamed_i,
    input wire  com_dst2_we_i,

    input wire [`REG_SEL-1:0]   tagbusy1_addr_i,                 //目的逻辑寄存器1，并设置其busy位
    input wire  tagbusy1_we_i,

    input wire [`REG_SEL-1:0]   tagbusy2_addr_i,              
    input wire  tagbusy2_we_i,

    input wire [`RRF_SEL-1:0]   settag1_i,                      //dst1_renamed.在读写端口冲突时,提供冲突物理寄存器地址,用于设置其忙状态  来自rrf_freelistmanager模块
    
    input wire [`RRF_SEL-1:0]   settag2_i,                      

    output wire [`RRF_SEL-1:0]  rs1_1_renamed_o,
    output wire [`RRF_SEL-1:0]  rs2_1_renamed_o,

    output wire [`RRF_SEL-1:0]  rs1_2_renamed_o,
    output wire [`RRF_SEL-1:0]  rs2_2_renamed_o,
    
    output wire     rs1_1_busy_o,
    output wire     rs2_1_busy_o,

    output wire     rs1_2_busy_o,
    output wire     rs2_2_busy_o

);
    /* 检查写端口是否写入有效寄存器，排除写入0号寄存器 */
    wire we1_0reg = com_dst1_we_i && (com_dst1_i != `REG_SEL'b0);            
    wire we2_0reg = com_dst2_we_i && (com_dst2_i != `REG_SEL'b0);
    
    /* 当提交指令之后需要设置清除物理寄存器编号对于的busy位 */
    wire clean_busy1 = com_dst1_we_i;                                       
    wire clean_busy2 = com_dst2_we_i;


    ram_sync_nolatch_4r2w
     #(`REG_SEL, `DATA_LEN, `REG_NUM)
    regfile(
	   .clk(clk),
	   .raddr1(rs1_1_i),
	   .raddr2(rs2_1_i),
	   .raddr3(rs1_2_i),
	   .raddr4(rs2_2_i),
	   .rdata1(rs1_1_data_i),
	   .rdata2(rs2_1_data_i),
	   .rdata3(rs1_2_data_i),
	   .rdata4(rs2_2_data_i),
	   .waddr1(com_dst1_i),
	   .waddr2(com_dst2_i),
	   .wdata1(com_dst1_data_i),
	   .wdata2(com_dst2_data_i),
	 
	   .we1(we1_0reg),
	   .we2(we2_0reg)
	   );
    



endmodule


module renaming_table (
    input wire clk,
    input wire reset,
    input wire [`REG_SEL-1:0] 	rs1_1_i,
    input wire [`REG_SEL-1:0] 	rs2_1_i,
    input wire [`REG_SEL-1:0]   com_dst1_i,
    input wire    clean_busy1_i,
    input wire [`REG_SEL-1:0]   com_dst1_renamed_i,

    input wire [`REG_SEL-1:0] 	rs1_2_i,
    input wire [`REG_SEL-1:0] 	rs2_2_i,
    input wire [`REG_SEL-1:0]   com_dst2_i,
    input wire    clean_busy2_i,
    input wire [`REG_SEL-1:0]   com_dst2_renamed_i,

    input wire [`REG_SEL-1:0]   settagbusy1_addr_i,
    input wire  settagbusy1_i,
    input wire [`RRF_SEL-1:0]   settag1_i, 

    input wire [`REG_SEL-1:0]   settagbusy2_addr_i,
    input wire  settagbusy2_i,
    input wire [`RRF_SEL-1:0]   settag2_i, 

    output wire [`RRF_SEL-1:0]  rs1_1_renamed_o,
    output wire [`RRF_SEL-1:0]  rs2_1_renamed_o,
    output wire     rs1_1_busy_o,
    output wire     rs2_1_busy_o,

    output wire [`RRF_SEL-1:0]  rs1_2_renamed_o,
    output wire [`RRF_SEL-1:0]  rs2_2_renamed_o,
    output wire     rs1_2_busy_o,
    output wire     rs2_2_busy_o,

);
    /* 映射表map将逻辑寄存器映射到物理寄存器 */
    reg [`RRF_SEL-1:0]   map[0:`REG_NUM-1];

    /* 逻辑寄存器其对应的物理寄存器是否处于忙状态 */
    reg [`REG_NUM-1:0] busy;


    always @(posedge clk ) begin
        if(reset)begin
            for (int i = 0; i < `REG_NUM-1; i = i + 1) begin
                map[i] <= 0;
                busy[i] <= 0;
            end
        end
        /* 若映射表map中不存在逻辑寄存器的映射，则分配一个新的物理寄存器，并且写入映射表记录这个映射关系并读出 */
    end

    always @(posedge clk ) begin
        if(clean_busy1_i) begin
            map[com_dst1_i] = 0;    //释放com_dst1_i对应的物理寄存器
            busy[com_dst1_i] = 0;   
        end
        if(clean_busy2_i) begin
            map[com_dst2_i] = 0;   //释放com_dst2_i对应的物理寄存器
            busy[com_dst2_i] = 0; 
        end
        if(settagbusy1_i) begin    //设置目的逻辑寄存器1对应的物理寄存器处于忙状态
            map[settagbusy1_addr_i] = settag1_i;   //重命名目的逻辑寄存器2
            busy[settagbusy1_addr_i] = 1;
        end
        if(settagbusy2_i) begin
            map[settagbusy2_addr_i] = settag2_i;  
            busy[settagbusy2_addr_i] = 1;
        end        
    end
    always @* begin
        if (busy[rs1_1_i] == 1) begin
            rs1_1_renamed_o = map[rs1_1_i];
        end else begin
            rs1_1_renamed_o = rs1_1_i;
        end

        if (busy[rs2_1_i] == 1) begin
            rs2_1_renamed_o = map[rs2_1_i];
        end else begin
            rs2_1_renamed_o = rs2_1_i;
        end

        if (busy[rs1_2_i] == 1) begin
            rs1_2_renamed_o = map[rs1_2_i];
        end else begin
            rs1_2_renamed_o = rs1_2_i;
        end

        if (busy[rs2_2_i] == 1) begin
            rs2_2_renamed_o = map[rs2_2_i];
        end else begin
            rs2_2_renamed_o = rs2_2_i;
        end
    end
endmodule


