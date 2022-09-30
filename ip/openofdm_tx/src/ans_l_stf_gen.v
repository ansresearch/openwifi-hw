

module ans_l_stf_gen
(
    input wire [3:0] addr,
    //input wire [127:0] mask,
    output wire [31:0] symbol
);
    
    wire [31:0] r1_out, r2_out, r3_out, r4_out, r5_out, r6_out,
     r10_out, r11_out, r12_out, r13_out, r14_out, r15_out;
    
    wire [15:0] sum_i, sum_q;
    
    l_stf_rom1 rom1   (.addr(addr), .dout(r1_out));
    l_stf_rom2 rom2   (.addr(addr), .dout(r2_out));
    l_stf_rom3 rom3   (.addr(addr), .dout(r3_out));
    l_stf_rom4 rom4   (.addr(addr), .dout(r4_out));
    l_stf_rom5 rom5   (.addr(addr), .dout(r5_out));
    l_stf_rom6 rom6   (.addr(addr), .dout(r6_out));

    l_stf_rom10 rom10 (.addr(addr), .dout(r10_out));
    l_stf_rom11 rom11 (.addr(addr), .dout(r11_out));
    l_stf_rom12 rom12 (.addr(addr), .dout(r12_out));
    l_stf_rom13 rom13 (.addr(addr), .dout(r13_out));
    l_stf_rom14 rom14 (.addr(addr), .dout(r14_out));
    l_stf_rom15 rom15 (.addr(addr), .dout(r15_out));
    
    
    adder12 adder_i (.a0(r1_out[31:16]), .a1(r2_out[31:16]), .a2(r3_out[31:16]),
     .a3(r4_out[31:16]), .a4(r5_out[31:16]), .a5(r6_out[31:16]), .a6(r10_out[31:16]),
     .a7(r11_out[31:16]), .a8(r12_out[31:16]), .a9(r13_out[31:16]), .a10(r14_out[31:16]),
     .a11(r15_out[31:16]), .sum(sum_i));

    adder12 adder_q (.a0(r1_out[15:0]), .a1(r2_out[15:0]), .a2(r3_out[15:0]),
     .a3(r4_out[15:0]), .a4(r5_out[15:0]), .a5(r6_out[15:0]), .a6(r10_out[15:0]),
     .a7(r11_out[15:0]), .a8(r12_out[15:0]), .a9(r13_out[15:0]), .a10(r14_out[15:0]),
     .a11(r15_out[15:0]), .sum(sum_q));
     
     //assign curr_coeff = mask[(iq_cnt * 2) +: 2];
     
     assign symbol = {sum_i, sum_q};


endmodule
