module stf_rom5
(
  input		[3:0]	addr,
  output reg	[31:0]	dout
);
always @ *
  case (addr)
	0:	dout = 32'h02f2_02f2;
	1:	dout = 32'hfc27_0198;
	2:	dout = 32'h0000_fbd6;
	3:	dout = 32'h03d9_0198;
	4:	dout = 32'hfd0e_02f2;
	5:	dout = 32'hfe68_fc27;
	6:	dout = 32'h042a_0000;
	7:	dout = 32'hfe68_03d9;
	8:	dout = 32'hfd0e_fd0e;
	9:	dout = 32'h03d9_fe68;
	10:	dout = 32'h0000_042a;
	11:	dout = 32'hfc27_fe68;
	12:	dout = 32'h02f2_fd0e;
	13:	dout = 32'h0198_03d9;
	14:	dout = 32'hfbd6_0000;
	15:	dout = 32'h0198_fc27;
	default:	dout = 32'h00000000;
  endcase
endmodule