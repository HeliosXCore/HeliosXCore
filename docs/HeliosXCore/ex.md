# Execute 阶段

执行阶段实现了逻辑运算单元（AluUnit）、分支单元（BranchUnit）、访存单元（MemAccessUnit）。

## AluUnit

接收 SW 阶段传来的操作码与操作数进行逻辑运算。

使用两个选择器选择出实际参与运算的数：

- SrcASelect：从 rs1、pc 中选择一个
- SrcBSelect：从 rs2、imm、4 中选择一个

最后输出运算结果 result

## BranchUnit

通过 alu_op、src1、rc2 进行运算得到是否满足跳转条件（jal、jalr指令恒满足），结果保存在 compare_result 中。根据 compare_result 设置最终跳转结果 jump_result_o的值，如果跳转，则为目标地址 jump_addr_o，否则为 pc + 4。

## MemAccessUnit

### store 指令

为了考虑分支预测错误后的一系列恢复操作，在访存模块增设了 StoreBuffer，所有 store 指令的信息（写入地址和写入数据等）会暂时保存在 StoreBuffer 中，当 Commit 阶段的 ROB 将该 store 指令提交后，实际的内存写入才会发生。

### StoreBuffer

目前 StoreBuffer 中的字段有 address、data、valid，可以容纳 31 条未提交的 store 指令（下标0作为初始化状态使用）。

```verilog
`define STORE_BUFFER_ENT_NUM 32

reg [`ADDR_LEN-1:0] address[`STORE_BUFFER_ENT_NUM-1:0];
reg [`DATA_LEN-1:0] data[`STORE_BUFFER_ENT_NUM-1:0];
reg valid[`STORE_BUFFER_ENT_NUM-1:0];
```

- address：要写入的内存地址；
- data：要写入的内存数据；
- valid：该表项是否有效。

StoreBuffer 由 3 个循环指针控制：

```verilog
reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] used_ptr;
reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] complete_ptr;
reg [`STORE_BUFFER_ENT_NUM_BITS-1:0] retire_ptr;
```

- used_ptr：指示最新使用的表项；
- complete_ptr：指示最新已完成的指令；
- retire_ptr：指示最新已退休的指令。

举例说明：

```verilog
// 假设store buffer中已有5条store指令的信息，ROB已经提交了3条，内存实际已写入了1条，则3个指针的位置如下。
// ----------- 0       1       2       3       4       5      -----------
//                     |               |               |
// -----------     retire_ptr     complete_ptr      used_ptr  -----------
```

控制逻辑：

- 当有 store 指令发射时，used_ptr 自增，同时将要写入的地址和数据保存到 StoreBuffer 中，并将表项的 valid 置为 1；
- 当接收到由 ROB 传来的提交信号时，complete_ptr 自增；
- 当内存没有被占用（即没有 load 指令发射）时，如果 retire_ptr 不等于 complete_ptr，那么 retire_ptr 自增，这会影响 StoreBuffer 的 3 个输出（mem_we_o、write_address_o、write_data_o），从而进行实际的内存写入。这个过程同时也会将该表项的 valid 置为0。

### load 指令

当一个 load 指令发射时，其数据源有两个，分别是内存和StoreBuffer 。

对内存和 StoreBuffer 的读取是同时发生，但 StoreBuffer 的优先级更高。即，如果 StoreBuffer 中保存着这个地址的数据，则将其作为读取结果输出（因为内存中的数据是旧数据）。通过将 hit 信号置 1 表明命中可以让 MemAccessUnit 选择正确的数据。



