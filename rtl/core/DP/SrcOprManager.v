`include "../../consts/Consts.v"

module SrcOprManager(
  input wire arf_busy_i,
  input	wire [`DATA_LEN-1:0] arf_data_i,
  input wire [`RRF_SEL-1:0] arf_rrftag_i,
  input wire rrf_valid_i,
  input wire [`DATA_LEN-1:0] rrf_data_i,
  input wire src_eq_zero_i,
  output wire [`DATA_LEN-1:0] src_o,
  output wire 		       rdy_o
);

   assign src_o = src_eq_zero_i ? `DATA_LEN'b0 :
		~arf_busy_i ? arf_data_i:
		rrf_valid_i ? rrf_data_i:
		arf_rrftag_i;
	  // 表明src是否已经就绪，即src中已经是data了，而不是rrftag
   assign rdy = src_eq_zero_i | (~arf_busy_i | rrf_valid_i);
endmodule
