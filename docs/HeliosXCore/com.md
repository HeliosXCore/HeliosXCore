# COM阶段
提交阶段的目的：通过ROB来将乱序执行的指令变回程序中指定的顺序状态。


### ROB内部的结构

|finish|storebit|dstValid|brcond|isbranch|inst_pc|jmpaddr|dst|bhr|index|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| | | | | | | | | | 1 | 
| | | | | | | | | | 2 |
| | | | | | | | | | 3 |
| | | | | | | | | | 4 |

...    

|finish|storebit|dstValid|brcond|isbranch|inst_pc|jmpaddr|dst|bhr|index|
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| | | | | | | | | | 62 |
| | | | | | | | | | 63 |

#### ROB内部信号解释：  
`finish`:  表示该 ROB entry 对应的指令是否已执行完成。当某条指令执行结束时,会将 finish 对应的位置1,表示该指令已完成执行。  
`storebit`: 表示该 ROB entry 对应的指令是否是存储指令。  
`dstValid`：表示该 ROB entry 对应的指令是否有目的寄存器。  
`brcond`：表示该 ROB entry 对应的指令是否有条件跳转指令。  
`isbranch`：表示该 ROB entry 对应的指令是否是分支指令。  
`inst_pc`：表示该 ROB entry 对应的指令的PC。  
`jmpaddr`：表示该 ROB entry 对应的指令的跳转地址。  
`dst`：表示该 ROB entry 对应的指令的目的寄存器。  
`bhr`：表示该 ROB entry 对应的指令的branch history register。  
`index`：表示该 ROB entry 对应的指令在 ROB 中的位置，即 ROB 的编号同时也是rrf的编号。（注意：index的编号是从1开始的）

### 写入ROB：

当有输入信号`dp1_i = 1`或者 `dp2_i = 1` 时,会立即将这两条指令写入ROB对应的entry

举例说明
```verilog
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
```
- 在时钟上升沿当`dp1_i = 1`时,说明指令已经发射。
- 实际上并不是将指令本身直接写入ROB，而是将指令所具有的信息写入ROB.
- 目的寄存器rd在重命名之后的`rrftag = dp1_addr_i`,即ROB的index代表了这条指令的重命名之后的`rrftag`


### 提交：
以第一个执行ALU执行单元为例，当ALU执行单元完成当前的计算时，会将`finish__ex_alu1_i`信号设置为1，表示该条指令已经完成计算。与此同时还会将`finish_ex_alu1_addr_i`（该条指令在ROB当中的地址）信号一起传入ROB。其他执行单元完成计算之后也跟上述类似。
```verilog
input wire       finish_ex_alu1_i,       //alu1单元是否执行完成
input wire [`RRF_SEL-1:0] finish_ex_alu1_addr_i,  //alu1执行完成的指令在ROB的地址
```

```verilog
     if (finish_ex_alu1_i) begin
                finish[finish_ex_alu1_addr_i] <= 1'b1;
        end
```
- `finish`信号表示该条指令是否已经完成执行  
  
然后`commit_1`看当前`commit_ptr_1_o`指向的ROB的地址所对应的`finish`，如果是1，则将`commit_1`设置为1，表示可以提交。
```verilog
    commit_1 = finish[commit_ptr_1_o];
```

`commit_ptr_1_o`:总是指向正在提交的指令在ROB当中的地址。  

  
`commit_ptr_1_o`的初始化：
```verilog
    commit_ptr_1_o <= 1;
```
- 初始化为1，而不初始化为0的原因是：重命名阶段分配的重名寄存器的编号是从1开始的，而这样做的原因是无法分辨RRFtag=0的重命名寄存器是表示没有输出还是重命名寄存器的编号为0.

`commit_ptr_1_o`的更新：

- 如果指令提交，则commit_ptr_1_o更新为`commit_ptr_1_o`加上提交指令的数量
  


