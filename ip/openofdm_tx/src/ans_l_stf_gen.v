

module ans_l_stf_gen
(
    input wire [3:0] addr,
    input wire [23:0] coeffs,
    output wire [31:0] symbol
);
    
    // Unpacking coefficients
    wire [1:0] c1, c2, c3, c4, c5, c6, c10, c11, c12, c13, c14, c15;
    assign c1 = coeffs[23:22];
    assign c2 = coeffs[21:20];
    assign c3 = coeffs[19:18];
    assign c4 = coeffs[17:16];
    assign c5 = coeffs[15:14];
    assign c6 = coeffs[13:12];
    assign c10 = coeffs[11:10];
    assign c11 = coeffs[9:8];
    assign c12 = coeffs[7:6];
    assign c13 = coeffs[5:4];
    assign c14 = coeffs[3:2];
    assign c15 = coeffs[1:0];
    
    // Extracting roms content
    wire [31:0] r1_out, r2_out, r3_out, r4_out, r5_out, r6_out,
     r10_out, r11_out, r12_out, r13_out, r14_out, r15_out;
    
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
    
    // Splitting i/q parts of roms content
    wire [15:0] rom1_i, rom2_i, rom3_i, rom4_i, rom5_i,
     rom6_i, rom10_i, rom11_i, rom12_i, rom13_i, rom14_i, rom15_i;
    
    wire [15:0] rom1_q, rom2_q, rom3_q, rom4_q, rom5_q,
     rom6_q, rom10_q, rom11_q, rom12_q, rom13_q, rom14_q, rom15_q;
    
    ans_shifter si1 (.toshift(r1_out[31:16]), .c(c1), .shifted(rom1_i));
    ans_shifter si2 (.toshift(r2_out[31:16]), .c(c2), .shifted(rom2_i));
    ans_shifter si3 (.toshift(r3_out[31:16]), .c(c3), .shifted(rom3_i));
    ans_shifter si4 (.toshift(r4_out[31:16]), .c(c4), .shifted(rom4_i));
    ans_shifter si5 (.toshift(r5_out[31:16]), .c(c5), .shifted(rom5_i));
    ans_shifter si6 (.toshift(r6_out[31:16]), .c(c6), .shifted(rom6_i));
    ans_shifter si10 (.toshift(r10_out[31:16]), .c(c10), .shifted(rom10_i));
    ans_shifter si11 (.toshift(r11_out[31:16]), .c(c11), .shifted(rom11_i));
    ans_shifter si12 (.toshift(r12_out[31:16]), .c(c12), .shifted(rom12_i));
    ans_shifter si13 (.toshift(r13_out[31:16]), .c(c13), .shifted(rom13_i));
    ans_shifter si14 (.toshift(r14_out[31:16]), .c(c14), .shifted(rom14_i));
    ans_shifter si15 (.toshift(r15_out[31:16]), .c(c15), .shifted(rom15_i));
    
    ans_shifter sq1 (.toshift(r1_out[15:0]), .c(c1), .shifted(rom1_q));
    ans_shifter sq2 (.toshift(r2_out[15:0]), .c(c2), .shifted(rom2_q));
    ans_shifter sq3 (.toshift(r3_out[15:0]), .c(c3), .shifted(rom3_q));
    ans_shifter sq4 (.toshift(r4_out[15:0]), .c(c4), .shifted(rom4_q));
    ans_shifter sq5 (.toshift(r5_out[15:0]), .c(c5), .shifted(rom5_q));
    ans_shifter sq6 (.toshift(r6_out[15:0]), .c(c6), .shifted(rom6_q));
    ans_shifter sq10 (.toshift(r10_out[15:0]), .c(c10), .shifted(rom10_q));
    ans_shifter sq11 (.toshift(r11_out[15:0]), .c(c11), .shifted(rom11_q));
    ans_shifter sq12 (.toshift(r12_out[15:0]), .c(c12), .shifted(rom12_q));
    ans_shifter sq13 (.toshift(r13_out[15:0]), .c(c13), .shifted(rom13_q));
    ans_shifter sq14 (.toshift(r14_out[15:0]), .c(c14), .shifted(rom14_q));
    ans_shifter sq15 (.toshift(r15_out[15:0]), .c(c15), .shifted(rom15_q));
    
    // summing up i/q addends
    wire [15:0] sum_i, sum_q;
    
    adder12 adder_i (.a0(rom1_i), .a1(rom2_i), .a2(rom3_i), .a3(rom4_i),
     .a4(rom5_i), .a5(rom6_i), .a6(rom10_i), .a7(rom11_i), .a8(rom12_i),
     .a9(rom13_i), .a10(rom14_i), .a11(rom15_i), .sum(sum_i));

    adder12 adder_q (.a0(rom1_q), .a1(rom2_q), .a2(rom3_q), .a3(rom4_q),
     .a4(rom5_q), .a5(rom6_q), .a6(rom10_q), .a7(rom11_q), .a8(rom12_q),
     .a9(rom13_q), .a10(rom14_q), .a11(rom15_q), .sum(sum_q));
     
     // returning join i/q shifted_summed_symbol
     assign symbol = {sum_i, sum_q};

endmodule
