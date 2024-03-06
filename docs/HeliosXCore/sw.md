# Select and Wakeup 阶段

Select and Wakeup 阶段用于接收重命名部件送来的操作数信号并将其送入到保留站中，最后决定何时将保留站中的操作数信号唤醒将其送入执行单元中。重命名部件送出的操作数信号有两种类型，一种是实际的从寄存器取出的操作数，另一种是寄存器未被提交，送入的是由重命名部件分配的重命名寄存器编号，在 HeliosXCore 叫做 **RRFTag**，这两种可能由一个一位宽的 `valid_i` 信号来决定：

```verilog
    input wire [`DATA_LEN-1:0] dp_op_1_1_i,
    input wire [`DATA_LEN-1:0] dp_op_1_2_i,
    input wire dp_valid_1_1_i,
    input wire dp_valid_1_2_i,
```

当接收到操作数时，分配单元会尝试为操作数分配保留站项，如果分配到保留站项则将操作数信号送入到保留站项，否则则告知重命名单元没有可分配的保留站项，随后重命名部件讲暂停派发操作数。

HeliosXCore 使用的是分离式的保留站设计，将 ALU 指令/存储指令/Branch 指令/乘除指令分别放入分离的保留站中。其中为不同类型的指令设计了不同的分配策略。对于 ALU 指令来说，SW (Select and Wakeup，下简称 SW)阶段实现了乱序发射的功能，由于 SW 允许一拍最多送两条指令的操作数进来，因此 ALU 的分配单元实现了一个名为 **RS Free Entry Finder** 的部件用于找到最多两个未使用的保留站项，RS Free Entry Finder 通过使用两个优先解码器来查找是否存在空闲的保留站项。

存储指令的分配单元使用的分配策略则与 ALU 指令的分配策略不同，在存储指令中实现了按序发射的策略。HeliosXCore 实现了一个名为 **InorderAllocateUnit** 的单元用于实现这个功能。**InorderAllocateUnit** 使用保留站作为 FIFO Buffer 并实现按序执行。在 **InorderAllocateUnit** 中我们规定了 `issue_ptr_o` 以及 `allocate_ptr_o` 两个信号分别表示发射的保留站编号以及分配的保留站编号:

```verilog
module InorderAllocIssueUnit #(
    parameter ENT_SEL = 2,
    parameter ENT_NUM = 4
) (
    input clk_i,
    input reset_i,
    input wire [1:0] req_num_i,
    input wire [ENT_NUM-1:0] busy_vector_i,
    input wire [ENT_NUM-1:0] previous_busy_vector_next_i,
    input wire [ENT_NUM-1:0] ready_vector_i,
    input wire dp_stall_i,
    input wire dp_kill_i,
    output reg [ENT_SEL-1:0] alloc_ptr_o,
    output wire allocatable_o,
    output wire [ENT_SEL-1:0] issue_ptr_o,
    output wire issue_valid_o
);
```

除此之外也有一个 Busy Vector 用于维护每个保留站 Entry 的忙碌状态，其中分配指针采用顺序分配的方式，从保留站从零到满依次分配，当保留站编号溢出时则重新回到 0 进行分配。而发射指针则有三个模式：

- Busy Vector 全为 0，即所有保留站项都空闲，则发射指针指向当前分配指针。
- `begin_0` 和 `end_0` 在 `begin_1` 和 `end_1` 之间，发射指针被设置为 `end_0` + 1。
- `begin_1` 和 `end_1` 在 `begin_0` 和 `end_0` 之间，发射指针被设置为 `begin_1`。

```verilog
    assign issue_ptr_o = ~not_full ? alloc_ptr_o : ((begin_1 == 0) && ({30'b0, end_1} == ENT_NUM - 1)) ? (end_0 + 1) : begin_1;
    assign issue_valid_o = ready_vector_i[issue_ptr_o];
    assign allocatable_o = (reset_i == 1)? 0: (req_num_i == 2'h0) ? 1'b1: 
            (req_num_i == 2'h1) ? ((~busy_vector_i[alloc_ptr_o] ? 1'b1: 1'b0)): 
            ((~busy_vector_i[alloc_ptr_o] && ~busy_vector_i[alloc_ptr_o + 1]) ? 1'b1: 1'b0);

    always @(posedge clk_i) begin
        if (reset_i) begin
            alloc_ptr_o <= 0;
        end else if (~dp_stall_i && ~dp_kill_i && allocatable_o) begin
            alloc_ptr_o <= alloc_ptr_o + req_num_i;
        end
    end
```

当分配单元分配完保留站之后，分配单元将分配的保留站项索引送给保留站，保留站根据索引将操作数信号送入到对应的保留站项中。接下来将以 ALU 保留站为例描述保留站选择和唤醒的详细流程。

保留站项接收到操作数后会将其送入到一个名为 **SourceManager** 的结构，源操作数管理部件由 SW 内部维护，用于管理和唤醒源操作数，SourceManager 的实现如下所示：

```verilog
    assign src_o = src_ready_i ? src_i :
        exe_dst_1_i == src_i[`RRF_SEL-1: 0]? exe_result_1_i :
        exe_dst_2_i == src_i[`RRF_SEL-1: 0]? exe_result_2_i :
        exe_dst_3_i == src_i[`RRF_SEL-1: 0]? exe_result_3_i :
        exe_dst_4_i == src_i[`RRF_SEL-1: 0]? exe_result_4_i :
        exe_dst_5_i == src_i[`RRF_SEL-1: 0]? exe_result_5_i : src_i;

    assign resolved_o = src_ready_i |
        (exe_dst_1_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_2_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_3_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_4_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_5_i == src_i[`RRF_SEL-1: 0]);
```

SourceManager 将进行判断是否操作数已经准备好，如果准备好则将 `resolved_o` 置 1，否则将持续等待执行前递的结果。

在 ALU 保留站项中为了处理执行前递和操作数送入保留站同一个周期的问题，我们设计了操作数选择器可以在同一周期唤醒操作数：

```verilog
    assign write_op_update_1 = (we_i & ~write_op_1_valid_i) ? 
                     (exe_result_1_dst_i == write_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_2_dst_i == write_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_3_dst_i == write_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_4_dst_i == write_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_5_dst_i == write_op_1_i[`RRF_SEL-1:0]) : 0;

    assign write_op_1 = (~write_op_update_1) ? write_op_1_i:
        (exe_result_1_dst_i == write_op_1_i[`RRF_SEL-1:0]) ? exe_result_1_i :
        (exe_result_2_dst_i == write_op_1_i[`RRF_SEL-1:0]) ? exe_result_2_i :
        (exe_result_3_dst_i == write_op_1_i[`RRF_SEL-1:0]) ? exe_result_3_i :
        (exe_result_4_dst_i == write_op_1_i[`RRF_SEL-1:0]) ? exe_result_4_i :
        (exe_result_5_dst_i == write_op_1_i[`RRF_SEL-1:0]) ? exe_result_5_i : write_op_1_i;
```

最终当一条指令的两个操作数都被准备好了之后它将被发射到执行单元，随后将保留站项中的内容清除并更新 busy 向量以表示该保留站项可用。