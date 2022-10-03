`timescale 1ns / 1ps

module ans_stf_tb;

reg clock;
reg [7:0]   index;
wire [31:0] symbol;
reg [23:0] coeffs;


stf_gen UUT (
 .addr(index[3:0]),
 .coeffs(coeffs),
 .symbol(symbol));

integer outfile;

initial begin
    $dumpfile("ans_stf.vcd");
    $dumpvars;
    outfile=$fopen("/home/xilinx/LORENZO/ans_stf_out.txt","w");
    
    coeffs = 24'd0; // no obf
    coeffs = 24'hAAAAAA; // div by 2
    //coeffs = 24'hFFFFFF; // 
    
    clock = 0;
    index = 0;
end

always begin //200MHz
    #2.5 clock = !clock;
end

always @(posedge clock) begin
    if (index < 160) begin
        index <= index + 1;
        $display("[%0t]: symbol_i = %H, symbol_q = %H", $time, symbol[31:16], symbol[15:0]);
         $fdisplay(outfile, "%H", symbol);
    end else $finish;
end

endmodule
