`timescale 1ns / 1ps


module ltf_generator_tb;

    reg clk, reset, bootLTFgen;
    
    wire [31:0] exportToDot11;
    wire LTFstarted;
    reg  [127:0] mycoefficients;
    
    reg thereisoutput;
    reg [7:0] outputlength;
    
    reg [2:0] txcnt;

ltf_generator UUT (.clk(clk), .reset(reset), .letsgo(bootLTFgen),
.coefficients(mycoefficients),
.ltfsequence(exportToDot11), .LTFstarted(LTFstarted));

    integer logfile,outfile;
    
always begin //200MHz
        #2.5 clk = !clk;
end
    
   
initial begin
    $dumpfile("ltf_gen.vcd");
    $dumpvars;
    
    txcnt = 0;
    
    clk = 0;
    logfile=$fopen("/home/xilinx/LORENZO/logfile.txt","w");
    outfile=$fopen("/home/xilinx/LORENZO/outfile.txt","w");
    
    thereisoutput = 0;
    outputlength = 0;
    //mycoefficients = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; //128bit set to 1
    mycoefficients = 128'd0; //128bit set to 0
    //mycoefficients = {112'd0, 16'b0000_0101_1010_1111};
    
    
    //RUN 0
    reset = 1;
    #5;
    reset = 0;
    #5;
    bootLTFgen = 1; 
    #5;
    bootLTFgen = 0;
    #1700;
    
    //RUN 1
    reset = 1;
    #5;
    reset = 0;
    #10;
    bootLTFgen = 1; 
    #5;
    bootLTFgen = 0;
    #1700;
    
    //RUN 2
    reset = 1;
    #5;
    reset = 0;
    #10;
    bootLTFgen = 1; 
    #5;
    bootLTFgen = 0;
    
    
    
  
end

always @(posedge clk) begin

    if (LTFstarted)
        thereisoutput = 1;
    
    if ((LTFstarted || thereisoutput) && outputlength < 160) begin
    $display("[%0t]: Receiving sample #%d equal to %h from ltf_gen module", $time, outputlength, exportToDot11);
    $fdisplay(logfile, "[%0t]: Receiving sample #%d equal to %h from ltf_gen module", $time, outputlength, exportToDot11);
    $fdisplay(outfile, "%h", exportToDot11);
        outputlength <= outputlength + 1;
    end
    
    if (outputlength == 160) begin
        //GOOD POINT FOR RESET
        //reset = 1;
    $display("[%0t]: END of #%d TRX", $time, txcnt);
    $fdisplay(logfile, "[%0t]: END of #%d TRX", $time, txcnt);
    $finish;
    
    
    $fdisplay(outfile, "--------------------------------------------");
        txcnt <= txcnt + 1;
        thereisoutput <= 0;
        outputlength <= 0;
        
    end
    
    if (txcnt > 2) begin
        $fclose(outfile);
        $fclose(logfile);
        $finish;
    end 
    
end

endmodule
