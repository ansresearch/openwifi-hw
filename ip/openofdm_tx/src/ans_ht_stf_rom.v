
module ans_ht_stf_rom
(
  input      [6:0]  addr,
  output reg [31:0] dout  
);

  always @ *
    case (addr)
    
    
    0:	dout = 32'h0000_0000;   //Subcar = -32
	1:	dout = 32'h0000_0000;   //Subcar = -31
	2:	dout = 32'h0000_0000;   //Subcar = -30
	3:	dout = 32'h0000_0000;   //Subcar = -29
	4:	dout = 32'hC000_C000;   //Subcar = -28
	5:	dout = 32'h0000_0000;   //Subcar = -27
	6:	dout = 32'h0000_0000;   //Subcar = -26
	7:	dout = 32'h0000_0000;   //Subcar = -25
	8:	dout = 32'hC000_C000;   //Subcar = -24
	9:	dout = 32'h0000_0000;   //Subcar = -23
	10:	dout = 32'h0000_0000;   //Subcar = -22
	11:	dout = 32'h0000_0000;   //Subcar = -21
	12:	dout = 32'h4000_4000;   //Subcar = -20
	13:	dout = 32'h0000_0000;   //Subcar = -19
	14:	dout = 32'h0000_0000;   //Subcar = -18
	15:	dout = 32'h0000_0000;   //Subcar = -17
	16:	dout = 32'h4000_4000;   //Subcar = -16
	17:	dout = 32'h0000_0000;   //Subcar = -15
	18:	dout = 32'h0000_0000;   //Subcar = -14
	19:	dout = 32'h0000_0000;   //Subcar = -13
	20:	dout = 32'h4000_4000;   //Subcar = -12
	21:	dout = 32'h0000_0000;   //Subcar = -11
	22:	dout = 32'h0000_0000;   //Subcar = -10
	23:	dout = 32'h0000_0000;   //Subcar = -9
	24:	dout = 32'h4000_4000;   //Subcar = -8
	25:	dout = 32'h0000_0000;   //Subcar = -7
	26:	dout = 32'h0000_0000;   //Subcar = -6
	27:	dout = 32'h0000_0000;   //Subcar = -5
	28:	dout = 32'h0000_0000;   //Subcar = -4
	29:	dout = 32'h0000_0000;   //Subcar = -3
	30:	dout = 32'h0000_0000;   //Subcar = -2
	31:	dout = 32'h0000_0000;   //Subcar = -1
	32:	dout = 32'h0000_0000;   //Subcar = 0
	33:	dout = 32'h0000_0000;   //Subcar = 1
	34:	dout = 32'h0000_0000;   //Subcar = 2
	35:	dout = 32'h0000_0000;   //Subcar = 3
	36:	dout = 32'h0000_0000;   //Subcar = 4
	37:	dout = 32'h0000_0000;   //Subcar = 5
	38:	dout = 32'h0000_0000;   //Subcar = 6
	39:	dout = 32'h0000_0000;   //Subcar = 7
	40:	dout = 32'h4000_4000;   //Subcar = 8
	41:	dout = 32'h0000_0000;   //Subcar = 9
	42:	dout = 32'h0000_0000;   //Subcar = 10
	43:	dout = 32'h0000_0000;   //Subcar = 11
	44:	dout = 32'hC000_C000;   //Subcar = 12
	45:	dout = 32'h0000_0000;   //Subcar = 13
	46:	dout = 32'h0000_0000;   //Subcar = 14
	47:	dout = 32'h0000_0000;   //Subcar = 15
	48:	dout = 32'h4000_4000;   //Subcar = 16
	49:	dout = 32'h0000_0000;   //Subcar = 17
	50:	dout = 32'h0000_0000;   //Subcar = 18
	51:	dout = 32'h0000_0000;   //Subcar = 19
	52:	dout = 32'hC000_C000;   //Subcar = 20
	53:	dout = 32'h0000_0000;   //Subcar = 21
	54:	dout = 32'h0000_0000;   //Subcar = 22
	55:	dout = 32'h0000_0000;   //Subcar = 23
	56:	dout = 32'hC000_C000;   //Subcar = 24
	57:	dout = 32'h0000_0000;   //Subcar = 25
	58:	dout = 32'h0000_0000;   //Subcar = 26
	59:	dout = 32'h0000_0000;   //Subcar = 27
	60:	dout = 32'h4000_4000;   //Subcar = 28
	61:	dout = 32'h0000_0000;   //Subcar = 29
	62:	dout = 32'h0000_0000;   //Subcar = 30
	63:	dout = 32'h0000_0000;   //Subcar = 31
	
    /* SCALED ROM --> causes overflow :(
        0:      dout = 32'h0000_0000;   //Subcar = -32
        1:      dout = 32'h0000_0000;   //Subcar = -31
        2:      dout = 32'h0000_0000;   //Subcar = -30
        3:      dout = 32'h0000_0000;   //Subcar = -29
        4:      dout = 32'h9e40_9e40;   //Subcar = -28
        5:      dout = 32'h0000_0000;   //Subcar = -27
        6:      dout = 32'h0000_0000;   //Subcar = -26
        7:      dout = 32'h0000_0000;   //Subcar = -25
        8:      dout = 32'h9e40_9e40;   //Subcar = -24
        9:      dout = 32'h0000_0000;   //Subcar = -23
        10:     dout = 32'h0000_0000;   //Subcar = -22
        11:     dout = 32'h0000_0000;   //Subcar = -21
        12:     dout = 32'h61c0_61c0;   //Subcar = -20
        13:     dout = 32'h0000_0000;   //Subcar = -19
        14:     dout = 32'h0000_0000;   //Subcar = -18
        15:     dout = 32'h0000_0000;   //Subcar = -17
        16:     dout = 32'h61c0_61c0;   //Subcar = -16
        17:     dout = 32'h0000_0000;   //Subcar = -15
        18:     dout = 32'h0000_0000;   //Subcar = -14
        19:     dout = 32'h0000_0000;   //Subcar = -13
        20:     dout = 32'h61c0_61c0;   //Subcar = -12
        21:     dout = 32'h0000_0000;   //Subcar = -11
        22:     dout = 32'h0000_0000;   //Subcar = -10
        23:     dout = 32'h0000_0000;   //Subcar = -9
        24:     dout = 32'h61c0_61c0;   //Subcar = -8
        25:     dout = 32'h0000_0000;   //Subcar = -7
        26:     dout = 32'h0000_0000;   //Subcar = -6
        27:     dout = 32'h0000_0000;   //Subcar = -5
        28:     dout = 32'h0000_0000;   //Subcar = -4
        29:     dout = 32'h0000_0000;   //Subcar = -3
        30:     dout = 32'h0000_0000;   //Subcar = -2
        31:     dout = 32'h0000_0000;   //Subcar = -1
        32:     dout = 32'h0000_0000;   //Subcar = 0
        33:     dout = 32'h0000_0000;   //Subcar = 1
        34:     dout = 32'h0000_0000;   //Subcar = 2
        35:     dout = 32'h0000_0000;   //Subcar = 3
        36:     dout = 32'h0000_0000;   //Subcar = 4
        37:     dout = 32'h0000_0000;   //Subcar = 5
        38:     dout = 32'h0000_0000;   //Subcar = 6
        39:     dout = 32'h0000_0000;   //Subcar = 7
        40:     dout = 32'h61c0_61c0;   //Subcar = 8
        41:     dout = 32'h0000_0000;   //Subcar = 9
        42:     dout = 32'h0000_0000;   //Subcar = 10
        43:     dout = 32'h0000_0000;   //Subcar = 11
        44:     dout = 32'h9e40_9e40;   //Subcar = 12
        45:     dout = 32'h0000_0000;   //Subcar = 13
        46:     dout = 32'h0000_0000;   //Subcar = 14
        47:     dout = 32'h0000_0000;   //Subcar = 15
        48:     dout = 32'h61c0_61c0;   //Subcar = 16
        49:     dout = 32'h0000_0000;   //Subcar = 17
        50:     dout = 32'h0000_0000;   //Subcar = 18
        51:     dout = 32'h0000_0000;   //Subcar = 19
        52:     dout = 32'h9e40_9e40;   //Subcar = 20
        53:     dout = 32'h0000_0000;   //Subcar = 21
        54:     dout = 32'h0000_0000;   //Subcar = 22
        55:     dout = 32'h0000_0000;   //Subcar = 23
        56:     dout = 32'h9e40_9e40;   //Subcar = 24
        57:     dout = 32'h0000_0000;   //Subcar = 25
        58:     dout = 32'h0000_0000;   //Subcar = 26
        59:     dout = 32'h0000_0000;   //Subcar = 27
        60:     dout = 32'h61c0_61c0;   //Subcar = 28
        61:     dout = 32'h0000_0000;   //Subcar = 29
        62:     dout = 32'h0000_0000;   //Subcar = 30
        63:     dout = 32'h0000_0000;   //Subcar = 31
        */

          default: dout = 32'h00000000;
    endcase

endmodule