`timescale 1ns / 1ps

module ans_l_stf_tb;

reg clock;
reg [7:0]   index;
wire [31:0] symbol;

wire [3:0] romaddr;

assign romaddr = index % 16;

ans_l_stf_gen UUT (.addr(romaddr), .symbol(symbol));

integer outfile;

initial begin
    $dumpfile("ans_l_stf.vcd");
    $dumpvars;
    outfile=$fopen("/home/xilinx/LORENZO/ans_lstf_out.txt","w");
    
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
