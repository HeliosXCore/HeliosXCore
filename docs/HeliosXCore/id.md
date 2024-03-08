# 译码阶段（ID）

译码阶段实现了一个顶层的译码单元（IDUnit）和两个次一级功能模块：译码器（Decoder）、立即数扩展（ImmDecoder）。

## IDUnit

IDUnit作为译码阶段的顶层单元，从前一个取指阶段的reg输入一条指令inst_i，经由译码器译码和立即数扩展，输出如下所示的数据信号，并将其存储在流水级ID与DP之间的reg中

```verilog
output reg [  `IMM_TYPE_WIDTH-1:0] imm_type_1_o,//当前指令的立即数类型
output reg [        `DATA_LEN-1:0] imm_1_o,//当前指令的立即数扩展
output reg [         `REG_SEL-1:0] rs1_1_o,//当前指令中的第一个源操作数寄存器地址
output reg [         `REG_SEL-1:0] rs2_1_o,//当前指令中的第二个源操作数寄存器地址
output reg [         `REG_SEL-1:0] rd_1_o,//当前指令的目标寄存器地址
output reg [ `SRC_A_SEL_WIDTH-1:0] src_a_sel_1_o,//用于选择ALU操作数
output reg [ `SRC_B_SEL_WIDTH-1:0] src_b_sel_1_o,//用于选择ALU操作数
output reg                         wr_reg_1_o,//是否将数据写入目标寄存器
output reg                         uses_rs1_1_o,//rs1的有效信号
output reg                         uses_rs2_1_o,//rs2的有效信号
output reg                         illegal_instruction_1_o,//表示该指令未定义
output reg [    `ALU_OP_WIDTH-1:0] alu_op_1_o,//ALU操作类型
output reg [      `RS_ENT_SEL-1:0] rs_ent_1_o,//保留站ID
output reg [                  2:0] dmem_size_1_o,//决定Load/Store指令数据的大小
output reg [  `MEM_TYPE_WIDTH-1:0] dmem_type_1_o,//决定Load/Store指令数据的大小
output reg [     `MD_OP_WIDTH-1:0] md_req_op_1_o,//运算类型（乘、除、模）
output reg                         md_req_in_1_signed_1_o,//乘法器的第一个源操作数是否有符号
output reg                         md_req_in_2_signed_1_o,//乘法器的第二个源操作数是否有符号
output reg [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1_o//决定乘法器输出的哪一部分为最后的乘法结果:高32位还是低32位
```

## Decoder

对于一条输入指令inst_i，译码器会根据RISC-V指令格式来提取相应的数据信息进行存储

```verilog
wire [              6:0] opcode = inst_i[6:0];
wire [              6:0] funct7 = inst_i[31:25];
wire [             11:0] funct12 = inst_i[31:20];
wire [              2:0] funct3 = inst_i[14:12];

assign rd_o = inst_i[11:7];//指令目的寄存器
assign rs1_o = inst_i[19:15];//指令源寄存器
assign rs2_o = inst_i[24:20];//指令源寄存器
```

同时根据opcode的类型分别对相应的译码信号输出进行处理，部分示例如下

```verilog
assign imm_type_o = (opcode == `RV32_LOAD) ? `IMM_I :
                    (opcode == `RV32_STORE) ? `IMM_S :
                    (opcode == `RV32_JAL) ? `IMM_J :
                    (opcode == `RV32_JALR) ? `IMM_J :
                    (opcode == `RV32_LUI) ? `IMM_U :
                    (opcode == `RV32_AUIPC) ? `IMM_U :
                    (opcode == `RV32_OP) ? `IMM_I :
                    (opcode == `RV32_OP_IMM) ? `IMM_I :
    				0;
```

## ImmDecoder

该模块主要实现对立即数的扩展功能。从一条RISC-V指令中提取立即数，根据立即数类型进行相应的符号扩展或零扩展。

由于RISC-V指令中的立即数有多种编码方式,包括I型、S型、B型、U型、J型等，所以ImmDecoder模块接收指令inst和立即数类型imm_type作为输入。根据立即数类型,从指令中提取对应的立即数位域，然后进行符号扩展或零扩展,扩展到同一数据宽度，最后将扩展后的立即数值输出。这样就可以从编码方式各异的RISC-V指令中解码出统一格式的立即数。

```verilog
assign imm = (imm_type == `IMM_I) ? {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]} :
             (imm_type == `IMM_S) ? {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]} :
             (imm_type == `IMM_U) ? {inst[31], inst[30:20], inst[19:12], 12'b0} :
             (imm_type == `IMM_J) ? {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0} :
             {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};
```

