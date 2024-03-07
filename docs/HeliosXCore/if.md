# 取指阶段（IF）

取指阶段计划要实现取指单元（IFUnit）和分支预测单元（BPU）。

目前实现的IFUnit主要是单指令的取指功能，即读取一条指令，并确定好下一个要读取的指令地址，保证流水线被持续填充。

pc初始值为 `ENTRY_POINT` （在本流水线中，这个值被设置为0），依据 `pc` 从`imem`中取出指令以后，送入取指部件fetch。

## 取指

在fetch的顶层取指单元IFUnit的内部，是具有一般取指功能的低级模块PipelineIF。PipelineIF模块里先实现了一个四选二指令的逻辑选择器（Selector），可以根据`pc[3:2]`从输入的四条指令中选择两条指令作为译码指令。

```verilog
module Selector
  (
   input wire [1:0] 		sel_i,
   input wire [4*`INSN_LEN-1:0] idata_i,
   output reg [`INSN_LEN-1:0] 	inst1_o,
   output reg [`INSN_LEN-1:0] 	inst2_o,
   );

   always @ (*) begin
      inst1_o = `INSN_LEN'h0;
      inst2_o = `INSN_LEN'h0;
      
      case(sel_i)
		2'b00 : begin
   			inst1_o = idata_i[31:0];
   			inst2_o = idata_i[63:32];
		end
		2'b01 : begin
   			inst1_o = idata_i[63:32];
   			inst2_o = idata_i[95:64];
		end
		2'b10 : begin
   			inst1_o = idata_i[95:64];
   			inst2_o = idata_i[127:96];
		end
		2'b11 : begin
   			inst1_o = idata_i[127:96];
   			inst2_o = idata_i[31:0];
		end
  	  endcase
   end
endmodule
```
后因决定先做单指令的流水线，就将IFUnit修改为每次读取一条指令作为本周期的译码指令，并送入流水级Fetch和Decode之间的reg中。同时，还需要更新将要读取的下一个指令地址npc的值（暂时不考虑分支预测和分支指令的话，npc就是pc+4）。

```verilog
assign npc_o  = reset_i ? 0 : pc_i + 4;
```

IFUnit单元中除了时序信号clk_i和重置信号reset_i，还包含了用以处理流水线暂停的带有前缀stall和kill的输入信号

```verilog
input wire    [`INSN_LEN-1:0] idata_i,
input wire    stall_IF,
input wire    kill_IF,
input wire    stall_ID,
input wire    kill_ID,
input wire    stall_DP,
input wire    kill_DP,

output reg  [`ADDR_LEN-1:0] npc_o,//输出下一条指令的pc值
output reg  [`INSN_LEN-1:0] inst_o,//输出当前指令，送入reg准备译码
output wire [`ADDR_LEN-1:0] iaddr_o//输出当前指令地址
```

## 更新PC值

IFUnit在每个时钟上升沿时更新下一条指令的地址npc的值

```verilog
 always @(posedge clk_i) begin
        if (reset_i) begin
            npc_o <= `ENTRY_POINT;//恢复成入口ENTRY_POINT
        end else if (stall_IF) begin
            npc_o <= pc;//流水线暂停，保留当前指令的pc值
        end else begin
            npc_o <= npc;//正常输出下一条指令的pc值
        end
 end
```
