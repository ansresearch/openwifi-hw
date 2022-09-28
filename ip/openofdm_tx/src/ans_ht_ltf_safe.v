/*

Just store and wait symbols already in time domain copied from original rom

*/

module ans_ht_ltf_safe (
    input wire clk, reset, letsgo, givemeoutput,
    input [127:0] obf_coeff,
    output wire[31:0] ht_safe_ltf, reg output_valid
);

// states of the ans_ht_ltf_gen FSM
reg[2:0] stateX = 0;
localparam S_IDLE                       = 0;
localparam S_FAKELOADING                = 1;
localparam S_WAITFAKECOMPUTATION        = 2;
localparam S_WAITREADY4OUT              = 3;
localparam S_STORAGE2FIFO               = 4;
localparam S_RECYCLE16                  = 5;

// Wiring with our time ht_ltf_rom64recycle
wire [31:0] rom_output;
reg[9:0] progress_cnt;

ht_ltf_rom64recycle ht_ltf_rom64recycle (
    .addr(progress_cnt[6:0]),
    .dout(rom_output)
);


// Our FIFO BRAM
wire [31:0] fifo_idata,  fifo_odata;
wire        fifo_ivalid, fifo_ovalid;
wire        fifo_iready, fifo_oready;
wire [15:0] fifo_space;
 
axi_fifo_bram #(.WIDTH(32), .SIZE(11)) ourFIFO(.clk(clk), .reset(reset), .clear(reset),
 .i_tdata(fifo_idata), .i_tvalid(fifo_ivalid), .i_tready(fifo_iready),
 .o_tdata(fifo_odata), .o_tvalid(fifo_ovalid), .o_tready(fifo_oready),
 .space(fifo_space), .occupied()
);

//////////////////////////////////////////////////////////////////////////
// HT-LTF generator FINITE STATE MACHINE
//////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin
if (fifo_oready) begin
    $display("[%0t]: safe output \t%d\t%H", $time, progress_cnt, fifo_odata);
    end
end


always @(posedge clk) begin
if (reset) begin

    progress_cnt = 0;
    output_valid = 0;
    stateX <= S_IDLE; 
    
end else begin

case(stateX)
    S_IDLE: begin
        if(letsgo) begin            
            stateX <= S_FAKELOADING;
        end
    end    
    
    S_FAKELOADING: begin
        if (progress_cnt < 80) begin
            //continuous assign takes care of
            //passing ROM content to OUTPUT STORAGE, i.e., our FIFO
            progress_cnt <= progress_cnt + 1;
        end else begin
        progress_cnt <= 0;
        stateX <= S_WAITFAKECOMPUTATION;          
        end
    end
    
    S_WAITFAKECOMPUTATION: begin
    if (progress_cnt < 299) begin
           //fake to wait for 300 cycles to let an IFFT computing
           // HT-LTF from freq to time
            progress_cnt <= progress_cnt + 1;
        end else begin
            progress_cnt <= 0;
            stateX <= S_WAITREADY4OUT;
            output_valid <= 1;
        end
    end
    
     S_WAITREADY4OUT: begin
        if (givemeoutput) begin
            progress_cnt <= 0;
            stateX <= S_STORAGE2FIFO;
        end
     end
        

    S_STORAGE2FIFO: begin
        if (progress_cnt < 80) begin       
            progress_cnt <= progress_cnt + 1;
        end else begin
            //IT'S OVER! Reset & Go back IDLE :)
        progress_cnt = 0;
        output_valid <= 0;
        stateX <= S_IDLE;
        end
    end
    
//    S_RECYCLE16: begin
//        if (progress_cnt < 16) begin
//            // Redirect FIFO output in FIFO input for 16 time, so to generate HT-LTF sequence...
//            progress_cnt <= progress_cnt + 1;
//        end else begin
//        //IT'S OVER! Reset & Go back IDLE :)
//        progress_cnt = 0;
//        output_valid <= 0;
//        stateX <= S_IDLE;
//        end  
//    end    
    endcase 

end

end


//assign debugodata = fifo_odata;

//Provide time-ROM coeff to FIFO
assign fifo_idata = (stateX == S_FAKELOADING) ? rom_output : 32'bx;

/* Populate the FIFO
    1. when loading symbols from ROM
    2. 16 times when we are 'svuotating' the FIFO
*/
assign fifo_ivalid = (stateX == S_FAKELOADING) ? 1 : 0;

assign fifo_idata  = (stateX == S_FAKELOADING) ? rom_output : 0;


assign fifo_oready = (stateX == S_STORAGE2FIFO) ? 1 : 0;


assign ht_safe_ltf = (stateX == S_STORAGE2FIFO) ? fifo_odata : 32'bx;

endmodule