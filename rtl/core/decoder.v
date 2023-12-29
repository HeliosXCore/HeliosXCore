`include "consts/Consts.vh"
`include "consts/RV32_opcodes.vh"
`include "consts/ALU.vh"

`default_nettype none
module decoder(
	input wire [31:0] 		  inst_i,
	output reg [`IMM_TYPE_WIDTH-1:0]   imm_type_o,
	output wire [`REG_SEL-1:0] 	  rs1_o,
	output wire [`REG_SEL-1:0] 	  rs2_o,
	output wire [`REG_SEL-1:0] 	  rd_o,
	output reg [`SRC_A_SEL_WIDTH-1:0]  src_a_sel_o,
	output reg [`SRC_B_SEL_WIDTH-1:0]  src_b_sel_o,
	output reg 			  wr_reg_o,
	output reg 			  uses_rs1_o,
	output reg 			  uses_rs2_o,
	output reg 			  illegal_instruction_o,
	output reg [`ALU_OP_WIDTH-1:0] 	  alu_op_o,
	output reg [`RS_ENT_SEL-1:0] 	  rs_ent_o,
//	output reg 			  dmem_use,
//	output reg 			  dmem_write,
	output wire [2:0] 		  dmem_size_o,
	output wire [`MEM_TYPE_WIDTH-1:0]  dmem_type_o, 
	output reg [`MD_OP_WIDTH-1:0] 	  md_req_op_o,
	output reg 			  md_req_in_1_signed_o,
	output reg 			  md_req_in_2_signed_o,
	output reg [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_o
);

  	wire [`ALU_OP_WIDTH-1:0] 			  srl_or_sra;
  	wire [`ALU_OP_WIDTH-1:0] 			  add_or_sub;
  	wire [`RS_ENT_SEL-1:0] 			  rs_ent_md;
   
  	wire [6:0] 		    opcode = inst_i[6:0];
  	wire [6:0] 		    funct7 = inst_i[31:25];
  	wire [11:0] 		    funct12 = inst_i[31:20];
   	wire [2:0] 		    funct3 = inst_i[14:12];
	// reg [`MD_OP_WIDTH-1:0]   md_req_op;
   	reg [`ALU_OP_WIDTH-1:0]  alu_op_arith;
   
  	assign rd_o = inst_i[11:7];
   	assign rs1_o = inst_i[19:15];
   	assign rs2_o = inst_i[24:20];

   	assign dmem_size_o = {1'b0,funct3[1:0]};
   	assign dmem_type_o = funct3;
	
	always @ (*) begin
      		imm_type_o = `IMM_I;
      		src_a_sel_o = `SRC_A_RS1;
      		src_b_sel_o = `SRC_B_IMM;
      		wr_reg_o = 1'b0;
      		uses_rs1_o = 1'b1;
      		uses_rs2_o = 1'b0;
      		illegal_instruction_o = 1'b0;
      //      	dmem_use = 1'b0;
      //    	dmem_write = 1'b0;
      		rs_ent_o = `RS_ENT_ALU;
      		alu_op_o = `ALU_OP_ADD;
      
      	case (opcode)
		`RV32_LOAD : begin
//          		dmem_use = 1'b1;
           		wr_reg_o = 1'b1;
	        	rs_ent_o = `RS_ENT_LDST;
//           		wb_src_sel_DX = `WB_SRC_MEM;
        	end
        	`RV32_STORE : begin
           		uses_rs2_o = 1'b1;
           		imm_type_o = `IMM_S;
//           		dmem_use = 1'b1;
 //          		dmem_write = 1'b1;
	   		rs_ent_o = `RS_ENT_LDST;
        	end
        	`RV32_BRANCH : begin
           		uses_rs2_o = 1'b1;
           	//branch_taken_unkilled = cmp_true;
           		src_b_sel_o = `SRC_B_RS2;
           		case (funct3)
             			`RV32_FUNCT3_BEQ : alu_op_o = `ALU_OP_SEQ;
            			`RV32_FUNCT3_BNE : alu_op_o = `ALU_OP_SNE;
             			`RV32_FUNCT3_BLT : alu_op_o = `ALU_OP_SLT;
             			`RV32_FUNCT3_BLTU : alu_op_o = `ALU_OP_SLTU;
             			`RV32_FUNCT3_BGE : alu_op_o = `ALU_OP_SGE;
             			`RV32_FUNCT3_BGEU : alu_op_o = `ALU_OP_SGEU;
             			default : illegal_instruction_o = 1'b1;
           		endcase // case (funct3)
	   		rs_ent_o = `RS_ENT_BRANCH;
        		end
        		`RV32_JAL : begin
	   //           	jal_unkilled = 1'b1;
           			uses_rs1_o = 1'b0;
           			src_a_sel_o = `SRC_A_PC;
           			src_b_sel_o = `SRC_B_FOUR;
           			wr_reg_o = 1'b1;
	   			rs_ent_o = `RS_ENT_JAL;
        		end
        		`RV32_JALR : begin
           			illegal_instruction_o = (funct3 != 0);
	   //           	jalr_unkilled = 1'b1;
           			src_a_sel_o = `SRC_A_PC;
           			src_b_sel_o = `SRC_B_FOUR;
           			wr_reg_o = 1'b1;
	   			rs_ent_o = `RS_ENT_JALR;
        		end

        		`RV32_OP_IMM : begin
           			alu_op_o = alu_op_arith;
           			wr_reg_o = 1'b1;
        		end
        		`RV32_OP  : begin
           			uses_rs2_o = 1'b1;
           			src_b_sel_o = `SRC_B_RS2;
           			alu_op_o = alu_op_arith;
           			wr_reg_o = 1'b1;
           			if (funct7 == `RV32_FUNCT7_MUL_DIV) begin
//              			uses_md_unkilled = 1'b1;
	      				rs_ent_o = rs_ent_md;
//              			wb_src_sel_DX = `WB_SRC_MD;
           			end
        		end

        		`RV32_AUIPC : begin
           			uses_rs1_o = 1'b0;
           			src_a_sel_o = `SRC_A_PC;
           			imm_type_o = `IMM_U;
           			wr_reg_o = 1'b1;
        		end
        		`RV32_LUI : begin
           			uses_rs1_o = 1'b0;
           			src_a_sel_o = `SRC_A_ZERO;
           			imm_type_o = `IMM_U;
           			wr_reg_o = 1'b1;
        		end
        		default : begin
           			illegal_instruction_o = 1'b1;
        		end
      	endcase // case (opcode)
   end // always @ (*)

   assign add_or_sub = ((opcode == `RV32_OP) && (funct7[5])) ? `ALU_OP_SUB : `ALU_OP_ADD;
   assign srl_or_sra = (funct7[5]) ? `ALU_OP_SRA : `ALU_OP_SRL;

   always @(*) begin
      case (funct3)
        `RV32_FUNCT3_ADD_SUB : alu_op_arith = add_or_sub;
        `RV32_FUNCT3_SLL : alu_op_arith = `ALU_OP_SLL;
        `RV32_FUNCT3_SLT : alu_op_arith = `ALU_OP_SLT;
        `RV32_FUNCT3_SLTU : alu_op_arith = `ALU_OP_SLTU;
        `RV32_FUNCT3_XOR : alu_op_arith = `ALU_OP_XOR;
        `RV32_FUNCT3_SRA_SRL : alu_op_arith = srl_or_sra;
        `RV32_FUNCT3_OR : alu_op_arith = `ALU_OP_OR;
        `RV32_FUNCT3_AND : alu_op_arith = `ALU_OP_AND;
        default : alu_op_arith = `ALU_OP_ADD;
      endcase // case (funct3)
   end // always @ begin


   //assign md_req_valid = uses_md;
   assign rs_ent_md = (
		       (funct3 == `RV32_FUNCT3_MUL) ||
		       (funct3 == `RV32_FUNCT3_MULH) ||
		       (funct3 == `RV32_FUNCT3_MULHSU) ||
		       (funct3 == `RV32_FUNCT3_MULHU)
		       ) ? `RS_ENT_MUL : `RS_ENT_DIV;
   
   always @(*) begin
      md_req_op_o = `MD_OP_MUL;
      md_req_in_1_signed_o = 0;
      md_req_in_2_signed_o = 0;
      md_req_out_sel_o = `MD_OUT_LO;
      case (funct3)
        `RV32_FUNCT3_MUL : begin
        end
        `RV32_FUNCT3_MULH : begin
           md_req_in_1_signed_o = 1;
           md_req_in_2_signed_o = 1;
           md_req_out_sel_o = `MD_OUT_HI;
        end
        `RV32_FUNCT3_MULHSU : begin
           md_req_in_1_signed_o = 1;
           md_req_out_sel_o = `MD_OUT_HI;
        end
        `RV32_FUNCT3_MULHU : begin
           md_req_out_sel_o = `MD_OUT_HI;
        end
        `RV32_FUNCT3_DIV : begin
           md_req_op_o = `MD_OP_DIV;
           md_req_in_1_signed_o = 1;
           md_req_in_2_signed_o = 1;
        end
        `RV32_FUNCT3_DIVU : begin
           md_req_op_o = `MD_OP_DIV;
        end
        `RV32_FUNCT3_REM : begin
           md_req_op_o = `MD_OP_REM;
           md_req_in_1_signed_o = 1;
           md_req_in_2_signed_o = 1;
           md_req_out_sel_o = `MD_OUT_REM;
        end
        `RV32_FUNCT3_REMU : begin
           md_req_op_o = `MD_OP_REM;
           md_req_out_sel_o = `MD_OUT_REM;
        end
      endcase
   end

   
endmodule // decoder
`default_nettype wire
