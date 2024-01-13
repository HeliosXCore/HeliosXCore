`define OPCODE_LEN 7

`define RV32_LOAD     7'b00_000_11
`define RV32_STORE    7'b01_000_11
// `define RV32_MADD     7'b10_000_11
`define RV32_BRANCH   7'b11_000_11

// `define RV32_LOAD_FP  7'b00_001_11
// `define RV32_STORE_FP 7'b01_001_11 
// `define RV32_MSUB     7'b10_001_11
`define RV32_JALR     7'b11_001_11

// `define RV32_CUSTOM_0 7'b00_010_11
// `define RV32_CUSTOM_1 7'b01_010_11
// `define RV32_NMSUB    7'b10_010_11
// 7'b11010_11 is reserved

`define RV32_MISC_MEM 7'b00_011_11
// `define RV32_AMO      7'b01_011_11
// `define RV32_NMADD    7'b10_011_11
`define RV32_JAL      7'b11_011_11

`define RV32_OP_IMM   7'b00_100_11
`define RV32_OP       7'b01_100_11
// `define RV32_OP_FP    7'b10_100_11
`define RV32_SYSTEM   7'b11_100_11

`define RV32_AUIPC    7'b00_101_11
`define RV32_LUI      7'b01_101_11
// `define RV32_OP_V     7'b10_101_11
// 7'b11_101_11 is reserved

// `define OP_IMM_32     7'b00_110_11
// `define OP_32         7'b01_110_11
// `define RV32_CUSTOM_2 7'b10_110_11
// `define RV32_CUSTOM_3 7'b11_110_11