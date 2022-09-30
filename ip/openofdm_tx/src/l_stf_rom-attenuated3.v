`include "openofdm_tx_pre_def.v"

module l_stf_rom_attenuated
(
  input      [3:0]  addr,
  output reg [31:0] dout  
);


always @ *
  case (addr)
            0:   dout = 32'h01F6_01F6; //05E305E3;
            1:   dout = 32'hFA59_001A; //EF0C004D;
            2:   dout = 32'hFF6D_FCA6; //FE47F5F3;
            3:   dout = 32'h0617_FF76; //1246FE61;
            4:   dout = 32'h03ED_0000; //0BC70000;
            5:   dout = 32'h0617_FF76; //1246FE61;
            6:   dout = 32'hFF6D_FCA6; //FE47F5F3;
            7:   dout = 32'hFA59_001A; //EF0C004D;
            8:   dout = 32'h01F6_01F6; //05E305E3;
            9:   dout = 32'h001A_FA59; //004DEF0C;
           10:   dout = 32'hFCA6_FF6D; //F5F3FE47;
           11:   dout = 32'hFF76_0617; //FE611246;
           12:   dout = 32'h0000_03ED; //00000BC7;
           13:   dout = 32'hFF76_0617; //FE611246;
           14:   dout = 32'hFCA6_FF6D; //F5F3FE47;
           15:   dout = 32'h001A_FA59; //004DEF0C;

        default: dout = 32'h00000000;
  endcase

endmodule
