
module adder12 
(
input wire[15:0] a0, a1, a2, a3, a4,
 a5, a6, a7, a8, a9, a10, a11, 
output wire[15:0] sum
);

assign sum = a0 + a1 + a2 + a3 + a4
 + a5 + a6 + a7 + a8 + a9 + a10 + a11;
endmodule

//module adder 
//(
//    input wire[15:0] A, B,
//    output wire[15:0] sum
//);
//    assign sum = A + B;
//endmodule

//module adder4 (
//    input wire [15:0] A, B, C, D,
//    output wire [15:0] sum
//    );

//    assign sum = A + B + C + D;
//endmodule