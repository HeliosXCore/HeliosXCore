`timescale 1ns / 1ps
`include "consts/Consts.vh"

module StoreBufferTB();
    // Inputs
    reg clk_i = 0;
    reg reset_i = 1;
    reg we_i = 0;
    reg issue_i = 0;
    reg [`ADDR_LEN-1:0] address_i = 0;
    reg [`DATA_LEN-1:0] write_data_i = 0;
    reg complete_i = 0;

    // Outputs
    wire hit;
    wire [`DATA_LEN-1:0] read_data_o;
    wire [`ADDR_LEN-1:0] write_address_o;
    wire [`DATA_LEN-1:0] write_data_o;

    StoreBuffer storebuffer(
    .clk_i(clk_i),
    .reset_i(reset_i),
    .issue_i(issue_i),
    .we_i(we_i),
    .address_i(address_i),
    .write_data_i(write_data_i),
    .complete_i(complete_i),

    .hit(hit),
    .read_data_o(read_data_o),
    .write_address_o(write_address_o),
    .write_data_o(write_data_o)
);
    
    initial begin
        #10 reset_i=0;
        #10 issue_i=1;we_i=1; address_i=`ADDR_LEN'h80000000; write_data_i=`DATA_LEN'd1;
        #10 address_i=`ADDR_LEN'h80000001; write_data_i=`DATA_LEN'd2;
        #10 address_i=`ADDR_LEN'h80000002; write_data_i=`DATA_LEN'd3;
        #10 address_i=`ADDR_LEN'h80000003; write_data_i=`DATA_LEN'd4;
        #10 address_i=`ADDR_LEN'h80000004; write_data_i=`DATA_LEN'd5;

        #10 we_i=0;address_i=`ADDR_LEN'h80000000; write_data_i=`DATA_LEN'd1;
        #10 address_i=`ADDR_LEN'h80000001; write_data_i=`DATA_LEN'd1;
        #10 address_i=`ADDR_LEN'h80000002; write_data_i=`DATA_LEN'd1;
        #10 address_i=`ADDR_LEN'h80000003; write_data_i=`DATA_LEN'd1;
        #10 address_i=`ADDR_LEN'h80000004; write_data_i=`DATA_LEN'd1;
        #10 address_i=`ADDR_LEN'h80000005; write_data_i=`DATA_LEN'd1;
        
        #10 complete_i=1;

        #30 $display("test finish."); $finish();
    end

    always #5 clk_i=~clk_i;


endmodule
