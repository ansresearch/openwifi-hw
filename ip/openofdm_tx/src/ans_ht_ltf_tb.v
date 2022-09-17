`timescale 1ns / 1ps


module ht_ltf_tb;

    reg clk, reset, bootLTFgen;
    
    wire [31:0] exportToDot11;
    wire LTFstarted;
    reg  [127:0] mycoefficients;
    
    reg thereisoutput;
    reg [7:0] outputlength;
    reg readyforoutput;
    
    reg [2:0] txcnt;

ans_ht_ltf_generator UUT (.clk(clk), .reset(reset), .letsgo(bootLTFgen), .givemeoutput(readyforoutput),
.obf_coeff(mycoefficients),
.ans_ht_ltf(exportToDot11), .ans_ht_ltf_started(LTFstarted));

    integer logfile,outfile;
    
always begin //200MHz
        #2.5 clk = !clk;
end
    
   
initial begin
    $dumpfile("ht_ltf_gen.vcd");
    $dumpvars;
    
    txcnt = 0;

    clk = 0;
    logfile=$fopen("/home/xilinx/LORENZO/ht_ltf_log.txt","w");
    outfile=$fopen("/home/xilinx/LORENZO/ht_ltf_out.txt","w");
    
    thereisoutput = 0;
    outputlength = 0;
    readyforoutput = 0;
    
    //mycoefficients = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; //128bit set to 1
    mycoefficients = 128'd0; //128bit set to 0
    //mycoefficients = {112'd0, 16'b0000_0101_1010_1111};
    
    
    //RUN 0
    $fdisplay(logfile, "[%0t]: START RUN 0", $time);
    reset = 1;
    #5;
    reset = 0;
    #5;
    bootLTFgen = 1; 
    #5;
    bootLTFgen = 0;
    #1700;
    readyforoutput = 1;
    #1000;
    
//    //RUN 1
    $fdisplay(logfile, "[%0t]: START RUN 1", $time);
    reset = 1;
    #5;
    reset = 0;
    #5;
    bootLTFgen = 1; 
    #5;
    bootLTFgen = 0;
    #1700;
    readyforoutput = 1;
    #1000;
    
//    //RUN 2
    $fdisplay(logfile, "[%0t]: START RUN 2", $time);
    reset = 1;
    #5;
    reset = 0;
    #5;
    bootLTFgen = 1; 
    #5;
    bootLTFgen = 0;
    #1700;
    readyforoutput = 1;
    #1000;
    
end

always @(posedge clk) begin

    if (LTFstarted) begin
        thereisoutput = 1;
        //$fdisplay(logfile, "[%0t]: OUTPUT STARTED FROM RUN %d", $time, txcnt);
    end
    
    if ((LTFstarted || thereisoutput) && outputlength < 80) 
    begin
        $display("[%0t]: Sample #%d equal to %H from ht_ltf_gen", $time, outputlength, exportToDot11);
        $fdisplay(logfile, "[%0t]: Sample #%d equal to %H from ht_ltf_gen", $time, outputlength, exportToDot11);
        $fdisplay(outfile, "%H", exportToDot11);
        outputlength <= outputlength + 1;
    end
    
    if (outputlength == 80) 
    begin
        //GOOD POINT FOR RESET
        //reset = 1;
        $display("[%0t]: END of TRX #%d", $time, txcnt);
        $fdisplay(logfile, "[%0t]: END of TRX #%d", $time, txcnt);
        //$finish;
        
        $fdisplay(outfile, "--------------------------------------------");
        txcnt <= txcnt + 1;
        thereisoutput <= 0;
        outputlength <= 0;
        readyforoutput <= 0;
    end
    
    if (txcnt > 2) begin
        $fclose(outfile);
        $fclose(logfile);
        $finish;
    end 
    
end

endmodule
