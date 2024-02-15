`include "consts/Consts.vh"
`default_nettype none

module SyncRAM2r2w #(
    parameter BRAM_ADDR_WIDTH = `ADDR_LEN,
    parameter BRAM_DATA_WIDTH = `DATA_LEN,
    parameter DATA_DEPTH      = 32
) (
    input  wire                       clk_i,
    input  wire [BRAM_ADDR_WIDTH-1:0] raddr1,
    input  wire [BRAM_ADDR_WIDTH-1:0] raddr2,
    output reg  [BRAM_DATA_WIDTH-1:0] rdata1,
    output reg  [BRAM_DATA_WIDTH-1:0] rdata2,
    input  wire [BRAM_ADDR_WIDTH-1:0] waddr1,
    input  wire [BRAM_ADDR_WIDTH-1:0] waddr2,
    input  wire [BRAM_DATA_WIDTH-1:0] wdata1,
    input  wire [BRAM_DATA_WIDTH-1:0] wdata2,
    input  wire                       we1,
    input  wire                       we2
);

    reg [BRAM_DATA_WIDTH-1:0] mem[0:DATA_DEPTH-1];

    assign rdata1 = mem[raddr1];
    assign rdata2 = mem[raddr2];

    always @(posedge clk_i) begin
        if (we1) mem[waddr1] <= wdata1;
        if (we2) mem[waddr2] <= wdata2;
    end
endmodule  // SyncRAM2r2w


module SyncRAM #(
    parameter BRAM_ADDR_WIDTH = `ADDR_LEN,
    parameter BRAM_DATA_WIDTH = `DATA_LEN,
    parameter DATA_DEPTH      = 32
) (
    input  wire                       clk_i,
    input  wire [BRAM_ADDR_WIDTH-1:0] raddr1,
    input  wire [BRAM_ADDR_WIDTH-1:0] raddr2,
    input  wire [BRAM_ADDR_WIDTH-1:0] raddr3,
    input  wire [BRAM_ADDR_WIDTH-1:0] raddr4,
    output wire [BRAM_DATA_WIDTH-1:0] rdata1,
    output wire [BRAM_DATA_WIDTH-1:0] rdata2,
    output wire [BRAM_DATA_WIDTH-1:0] rdata3,
    output wire [BRAM_DATA_WIDTH-1:0] rdata4,
    input  wire [BRAM_ADDR_WIDTH-1:0] waddr1,
    input  wire [BRAM_ADDR_WIDTH-1:0] waddr2,
    input  wire [BRAM_DATA_WIDTH-1:0] wdata1,
    input  wire [BRAM_DATA_WIDTH-1:0] wdata2,
    input  wire                       we1,
    input  wire                       we2
);

    SyncRAM2r2w #(BRAM_ADDR_WIDTH, BRAM_DATA_WIDTH, DATA_DEPTH) mem0 (
        .clk_i(clk_i),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .waddr1(waddr1),
        .waddr2(waddr2),
        .wdata1(wdata1),
        .wdata2(wdata2),
        .we1(we1),
        .we2(we2)
    );

    SyncRAM2r2w #(BRAM_ADDR_WIDTH, BRAM_DATA_WIDTH, DATA_DEPTH) mem1 (
        .clk_i(clk_i),
        .raddr1(raddr3),
        .raddr2(raddr4),
        .rdata1(rdata3),
        .rdata2(rdata4),
        .waddr1(waddr1),
        .waddr2(waddr2),
        .wdata1(wdata1),
        .wdata2(wdata2),
        .we1(we1),
        .we2(we2)
    );

endmodule  // SyncRAM_4r2w

`default_nettype wire
