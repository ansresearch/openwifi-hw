module stf_rom12
(
  input		[3:0]	addr,
  output reg	[31:0]	dout
);
always @ *
  case (addr)
	0:	dout = 32'h02f2_02f2;
	1:	dout = 32'h02f2_fd0e;
	2:	dout = 32'hfd0e_fd0e;
	3:	dout = 32'hfd0e_02f2;
	4:	dout = 32'h02f2_02f2;
	5:	dout = 32'h02f2_fd0e;
	6:	dout = 32'hfd0e_fd0e;
	7:	dout = 32'hfd0e_02f2;
	8:	dout = 32'h02f2_02f2;
	9:	dout = 32'h02f2_fd0e;
	10:	dout = 32'hfd0e_fd0e;
	11:	dout = 32'hfd0e_02f2;
	12:	dout = 32'h02f2_02f2;
	13:	dout = 32'h02f2_fd0e;
	14:	dout = 32'hfd0e_fd0e;
	15:	dout = 32'hfd0e_02f2;
	default:	dout = 32'h00000000;
  endcase
endmodule