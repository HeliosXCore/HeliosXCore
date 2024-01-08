// Arithmetic FUNCT3 encodings
`define RV32_FUNCT3_ADD_SUB 0
`define RV32_FUNCT3_SLL     1
`define RV32_FUNCT3_SLT     2
`define RV32_FUNCT3_SLTU    3
`define RV32_FUNCT3_XOR     4
`define RV32_FUNCT3_SRA_SRL 5
`define RV32_FUNCT3_OR      6
`define RV32_FUNCT3_AND     7

// Branch FUNCT3 encodings
`define RV32_FUNCT3_BEQ  0
`define RV32_FUNCT3_BNE  1
`define RV32_FUNCT3_BLT  4
`define RV32_FUNCT3_BGE  5
`define RV32_FUNCT3_BLTU 6
`define RV32_FUNCT3_BGEU 7

// MISC-MEM FUNCT3 encodings
`define RV32_FUNCT3_FENCE   0
`define RV32_FUNCT3_FENCE_I 1

// SYSTEM FUNCT3 encodings
`define RV32_FUNCT3_PRIV   0
`define RV32_FUNCT3_CSRRW  1
`define RV32_FUNCT3_CSRRS  2
`define RV32_FUNCT3_CSRRC  3
`define RV32_FUNCT3_CSRRWI 5
`define RV32_FUNCT3_CSRRSI 6
`define RV32_FUNCT3_CSRRCI 7