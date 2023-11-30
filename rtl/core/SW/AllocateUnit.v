`default_nettype none
module PriorityEncoder #(
		 parameter REQ_LEN = 4,
		 parameter GRANT_LEN = 2
		 )
   (
    input wire [REQ_LEN-1:0]   in,
    output reg [GRANT_LEN-1:0] out,
    output reg 		       en
   );
   
   integer 		      i;
   always @ (*) begin
      en = 0;
      out = 0;
      for (i = REQ_LEN-1 ; i >= 0 ; i = i - 1) begin
	 if (~in[i]) begin
	    out = i;
	    en = 1;
	 end
      end
   end
endmodule

module MaskUnit  #(
		   parameter REQ_LEN = 4,
		   parameter GRANT_LEN = 2
		   )
   (
    input wire [GRANT_LEN-1:0] mask,
    input wire [REQ_LEN-1:0]   in,
    output reg [REQ_LEN-1:0]   out
   );
   
   integer 		      i;
   always @ (*) begin
      out = 0;
      for (i = 0 ; i < REQ_LEN ; i = i+1) begin
	 out[i] = (mask < i) ? 1'b0 : 1'b1;
      end
   end
endmodule

module AllocateUnit  #(
		       parameter REQ_LEN = 4,
		       parameter GRANT_LEN = 2
		       )
   (
    input wire [REQ_LEN-1:0] 	busy,
    output wire 		en_1,
    output wire 		en_2,
    output wire [GRANT_LEN-1:0] free_entry_1,
    output wire [GRANT_LEN-1:0] free_entry_2,
    input wire [1:0] 		req_num,
    output wire 		allocatable
   );
   
   wire [REQ_LEN-1:0] 	       busy_mask;
   
   PriorityEncoder #(REQ_LEN, GRANT_LEN) priority_encoder_1
     (
      .in(busy),
      .out(free_entry_1),
      .en(en_1)
      );

   MaskUnit #(REQ_LEN, GRANT_LEN) mask_unit
     (
      .mask(free_entry_1),
      .in(busy),
      .out(busy_mask)
      );
   
   PriorityEncoder #(REQ_LEN, GRANT_LEN) priority_encoder_2
     (
      .in(busy | busy_mask),
      .out(free_entry_2),
      .en(en_2)
      );

   assign allocatable = (req_num > ({1'b0,en_1}+{1'b0,en_2})) ? 1'b0 : 1'b1;
endmodule
`default_nettype wire
