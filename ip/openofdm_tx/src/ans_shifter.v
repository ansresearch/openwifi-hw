module ans_shifter
(
    input wire [15:0] toshift,
    input wire [1:0] c,
    output wire [15:0] shifted
);

wire [15:0] div2, div4, div8;

assign div2 = {toshift[15], toshift[15:1]};
assign div4 = {toshift[15], toshift[15], toshift[15:2]};
assign div8 = {toshift[15], toshift[15], toshift[15], toshift[15:3]};

assign shifted = 
(c == 2'b00)? toshift : 
(c == 2'b01)? div8 : 
(c == 2'b10)? div2 : 
(c == 2'b11)? div4 :
 16'bx;

endmodule
