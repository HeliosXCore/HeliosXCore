`include "consts/Consts.vh"

module DataMemory(
    (* IO_BUFFER_TYPE = "none" *) input wire clk_i,
    (* IO_BUFFER_TYPE = "none" *) input wire en_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] write_address_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] write_data_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] read_address_i,

    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] read_date_o
);  
    // 32x65536 Single Dual Port RAM
    BRAM_32X65536 bram(
        // 用于 store buffer 写入
        .clka(clk_i),    // input wire clka
        .ena(en_i),
        .wea(1),      // input wire [0 : 0] wea
        .addra(write_address_i[15:0]),  // input wire [15 : 0] addra
        .dina(write_data_i),    // input wire [31 : 0] dina

        // 用于 load 读取
        .clkb(clk_i),    // input wire clkb
        .addrb(read_address_i[15:0]),  // input wire [15 : 0] addrb
        .doutb(read_date_o)  // output wire [31 : 0] doutb
    );
endmodule