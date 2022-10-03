module stf_rom6
(
  input		[3:0]	addr,
  output reg	[31:0]	dout
);
always @ *
  case (addr)
	0:	dout = 32'h02f2_02f2;
	1:	dout = 32'hfbd6_0000;
	2:	dout = 32'h02f2_fd0e;
	3:	dout = 32'h0000_042a;
	4:	dout = 32'hfd0e_fd0e;
	5:	dout = 32'h042a_0000;
	6:	dout = 32'hfd0e_02f2;
	7:	dout = 32'h0000_fbd6;
	8:	dout = 32'h02f2_02f2;
	9:	dout = 32'hfbd6_0000;
	10:	dout = 32'h02f2_fd0e;
	11:	dout = 32'h0000_042a;
	12:	dout = 32'hfd0e_fd0e;
	13:	dout = 32'h042a_0000;
	14:	dout = 32'hfd0e_02f2;
	15:	dout = 32'h0000_fbd6;
	default:	dout = 32'h00000000;
  endcase
endmodule
