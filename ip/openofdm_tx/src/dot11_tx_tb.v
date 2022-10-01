`timescale 1ns/1ps

module dot11_tx_tb;

reg  clock;
reg [2:0] txcnt;
reg  reset;

reg  phy_tx_start;
wire phy_tx_done;
wire phy_tx_started;

reg [63:0] bram_din;
wire [11:0] bram_addr;

wire        result_iq_valid;
wire signed [15:0] result_i;
wire signed [15:0] result_q;

integer result_fd,f0,f1,f2;
integer tmp,logfile;

reg [63:0] Memory [0:4095];
initial begin
    $dumpfile("dot11_tx.vcd");
    $dumpvars;

    //$readmemh("../../../../../unit_test/test_vec/tx_intf.mem", Memory);
    //$readmemh("../../../../../unit_test/test_vec/ht_tx_intf_mem_mcs7_gi1_aggr0_byte100.mem", Memory);
    //$readmemh("../../../../../unit_test/test_vec/ht_tx_intf_mem_mcs7_gi1_aggr0_byte8176.mem", Memory);
    //$readmemh("../../../../../unit_test/test_vec/zz_bramtest_mcs4_byte100.mem", Memory);
    $readmemh("../../../../../unit_test/test_vec/test_mcs3_len100byte_nosgi.mem", Memory);
    
    result_fd = $fopen("/home/xilinx/LORENZO/dot11_txANS.txt", "w");
    
//    f0 = $fopen("/home/xilinx/LORENZO/f0.txt", "w");
//    f1 = $fopen("/home/xilinx/LORENZO/f1.txt", "w");
//    f2 = $fopen("/home/xilinx/LORENZO/f2.txt", "w");
    logfile = $fopen("/home/xilinx/LORENZO/logTBDOT11.txt");

    clock = 0;
    txcnt = 0;
    reset = 1;
    phy_tx_start = 0;

    //$fdisplay(logfile, "[%0t] COMINCIO\n", $time); 
    // RUN 0
    # 20
    reset = 0;
    phy_tx_start = 1;
    # 25 
    phy_tx_start = 0;
    
//    #10700 // Wait end of TX
//    $fdisplay(logfile, "[%0t] RICOMINCIO\n", $time);
    
//    // RUN 1
//    reset = 1;
//    phy_tx_start = 0;
//    # 20
//    reset = 0;
//    phy_tx_start = 1;
//    # 25 
//    phy_tx_start = 0;
    
//     #10700 // Wait end of TX
//     $fdisplay(logfile, "[%0t] RICOMINCIO\n", $time);
     
//     // RUN 2
//    reset = 1;
//    phy_tx_start = 0;
//    # 20
//    reset = 0;
//    phy_tx_start = 1;
//    # 25 
//    phy_tx_start = 0;
//     $fdisplay(logfile, "ASPETTO LA FINE\n");
    
    
    
    
end

always begin //200MHz
    #2.5 clock = !clock;
end

always @(posedge clock) begin
    if(reset)
        bram_din <= 0;
    else begin
        if (result_iq_valid) begin
//            case (txcnt)
//                0: $fwrite(f0, "%d %d\n", result_i, result_q);
//                1: $fwrite(f1, "%d %d\n", result_i, result_q);
//                2: $fwrite(f2, "%d %d\n", result_i, result_q);
//                default: tmp = result_fd;
//            endcase
            $fwrite(result_fd, "%d %d\n", result_i, result_q);
            $display("[%0t]: i:%d q:%d TX=%d", $time, result_i, result_q, txcnt);
            $fdisplay(logfile, "[%0t]: i:%d q:%d TX=%d", $time, result_i, result_q, txcnt);
        end
            
            
            
        bram_din <= Memory[bram_addr];
        if (phy_tx_done == 1 && txcnt < 3) begin
            $display("[%0t]: END of #%d TRX", $time, txcnt);
            $fdisplay(logfile, "=========== [%0t]: END of TRX  #%d ===========", $time, txcnt);
            $fclose(result_fd);
            $finish;
            txcnt <= txcnt + 1;
            reset <= 1;          
        end
    end
    
    if (txcnt == 3) begin
        $fclose(f0);
        $fclose(f1);
        $fclose(f2);
        $display("END OF ALL TXs\n");
        $fdisplay(logfile, "=======\n");
        $finish;
    end

end

dot11_tx dot11_tx_inst (
    .clk(clock),
    .phy_tx_arest(reset),

    .phy_tx_start(phy_tx_start),
    .phy_tx_done(phy_tx_done),
    .phy_tx_started(phy_tx_started),

    .init_pilot_scram_state(7'b1111111),
    .init_data_scram_state(7'b1111111),

    .bram_din(bram_din),
    .bram_addr(bram_addr),

    .result_iq_ready(1'b1),
    .result_iq_valid(result_iq_valid),
    .result_i(result_i),
    .result_q(result_q),
    
    // msb is left part of the spectrum, lsb right part (left is negative freqs, right is positive freqs)
    .mask(128'd0) // No Obf
    //.mask(128'h55555555555555555555555555555555) // 01 on all subcar => means divide by 8
    //.mask(128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA) // 10 on all subcar => means divide by 2
    //.mask(128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) // 11 on all subcar => means divide by 4
    //.mask(128'hE4E4E4E4E4E4E4E4E4E4E4E4E4E4E4E4) //11_10_01_00 repeated pattern 
    //.mask(128'hFFFFFF) //only 4 carriers obfuscated
    //.mask(128'h03030303030303030303030303030300)
    //.mask(128'h01030103010301030103010301030100)
    //.mask(128'h00000000000000000103010301030100)
    // Other examples of possible mask values
    //.mask(128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA)
    //.mask(128'h0000000000000000FFFFFFFFFFFFFFFF)
    
);

endmodule
