#define IMM_I 0
#define IMM_S 1
#define IMM_U 2
#define IMM_J 3

//Decoder
#define RS_ENT_SEL 3
#define RS_ENT_ALU 1
#define RS_ENT_BRANCH 2
#define RS_ENT_JAL 2
#define RS_ENT_JALR 2
#define RS_ENT_MUL 3
#define RS_ENT_DIV 3
#define RS_ENT_LDST 4

//src_a
#define SRC_A_SEL_WIDTH 2
#define SRC_A_RS1  0
#define SRC_A_PC   1
#define SRC_A_ZERO 2

//src_b
#define SRC_B_SEL_WIDTH 2
#define SRC_B_RS2  0
#define SRC_B_IMM  1
#define SRC_B_FOUR 2
#define SRC_B_ZERO 3


