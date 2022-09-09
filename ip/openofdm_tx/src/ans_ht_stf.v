/*

STILL TO BE UPDATED TO BECOME AN HT-STF GENERATOR

A module used for generating the 80 (time) samples of the HT short preamble
starting from the 802.11 standard (frequency) coefficients tabled in ans_ht_ltf_rom.v

Similar logic of HT-LTF ... check ans_ht_ltf.v 
*/

module ans_ht_stf_generator(
    input wire clk, reset, letsgo, givemeoutput,
    input [127:0] obf_coeff,
    output wire[31:0] ans_ht_stf, wire ans_ht_stf_started 
);

// states of the ans_ht_stf_gen FSM
reg[2:0] stateX = 0;
localparam S_IDLE              = 0;
localparam S_LOADING           = 1;
localparam S_WAITIFFT          = 2;
localparam S_WAITREADY4OUT     = 3;
localparam S_IFFT2FIFO         = 4;
localparam S_RECYCLE16         = 5;

// Wiring with our custom ans_ht_ltf_rom
wire [31:0] ht_stf_freqrom;
wire [31:0] ans_ht_stf_shifted;
reg[6:0] progress_cnt;

reg [31:0] tmpOutput;

ans_ht_stf_rom freqROM (.addr(progress_cnt), .dout(ht_stf_freqrom));

// Wires where we make our obfuscation math
wire [31:0] ht_stf_DivBy2;
wire [31:0] ht_stf_DivBy4;
wire [31:0] ht_stf_DivBy8;
wire [1:0]  curr_coeff;

// Our IFFT block
localparam  IWIDTH=16, OWIDTH=16, LGWIDTH=6;
reg ifft_ce;
wire [(2*IWIDTH-1):0]   ifft_input;
wire  [(2*OWIDTH-1):0]  ifft_result;
wire ifft_osync;

ifftmain ourIfftBlock (.i_clk(clk), .i_reset(reset), .i_ce(ifft_ce),
 .i_sample(ifft_input),  .o_result(ifft_result), .o_sync(ifft_osync));

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
if (reset) begin
    /*
    Reset everyting and go in patient S_IDLE state.
    NB: This reset signal propagates also to the IFFT.reset and to the ourFIFO.reset;
    so in theory after this module reset here our private IFFT and FIFO instances are clean.
    */
    ifft_ce = 0;
    progress_cnt = 0;
    stateX <= S_IDLE; 
end else begin
case(stateX)
    S_IDLE: begin
        if(letsgo) begin
            ifft_ce <= 1;
            progress_cnt = 0;
            stateX <= S_LOADING;
        end
    end    
    
    S_LOADING: begin
        if (progress_cnt < 63) begin
            //continuous assign takes care of
            //passing ROM content as input to IFFT block
            progress_cnt <= progress_cnt + 1;
        end else begin
        progress_cnt <= 0;
        stateX <= S_WAITIFFT;          
        end
    end
    
    S_WAITIFFT: begin
        if (ifft_osync) begin
            ifft_ce <= 0;
            tmpOutput <= ifft_result;
            stateX <= S_WAITREADY4OUT;
        end
    end
    
     S_WAITREADY4OUT: begin
        if (givemeoutput) begin
            progress_cnt <= 0;
            stateX <= S_IFFT2FIFO;
        end
     end
        

    S_IFFT2FIFO: begin
        if (progress_cnt < 1) begin
             ifft_ce <= 1; // enable progress of output
        end
        if (progress_cnt < 63) begin       
            progress_cnt <= progress_cnt + 1;
        end else begin
            progress_cnt <= 0;
            stateX = S_RECYCLE16;
        end
    end
    
    S_RECYCLE16: begin
        if (progress_cnt < 16) begin
            // Redirect FIFO output in FIFO input for 16 time, so to generate HT-STF sequence...
            progress_cnt <= progress_cnt + 1;
        end else begin
        //IT'S OVER! Reset & Go back IDLE :)
        ifft_ce = 0;    
        progress_cnt = 0;
        stateX <= S_IDLE;
        end  
    end    
    endcase 

end

end

// Prepare shifted versions of ht-ltf (frequency) coefficients
// NB: standard ht-ltf (frequency) coeff comes directly from our ROM (ht_stf_freqrom)
assign ht_stf_DivBy2 = {ht_stf_freqrom[31], ht_stf_freqrom[31:17], ht_stf_freqrom[15], ht_stf_freqrom[15:1]};
assign ht_stf_DivBy4 = {ht_stf_freqrom[31], ht_stf_freqrom[31], ht_stf_freqrom[31:18], ht_stf_freqrom[15], ht_stf_freqrom[15], ht_stf_freqrom[15:2]};
assign ht_stf_DivBy8 = {ht_stf_freqrom[31], ht_stf_freqrom[31], ht_stf_freqrom[31], ht_stf_freqrom[31:19], ht_stf_freqrom[15], ht_stf_freqrom[15], ht_stf_freqrom[15], ht_stf_freqrom[15:3]};

assign curr_coeff = obf_coeff[(progress_cnt * 2) +: 2];

//While LOADING, choose the ''shifted ltf''
assign ans_ht_stf_shifted = 
(stateX == S_LOADING && curr_coeff == 2'b00) ? ht_stf_freqrom : 
(stateX == S_LOADING && curr_coeff == 2'b01) ? ht_stf_DivBy8 : 
(stateX == S_LOADING && curr_coeff == 2'b10) ? ht_stf_DivBy2 : 
(stateX == S_LOADING && curr_coeff == 2'b11) ? ht_stf_DivBy4
 : 32'bx;


//Provide shited coefficients as input to the IFFT only during LOADING state
assign ifft_input = (stateX == S_LOADING) ? ans_ht_stf_shifted : 32'bx;

/* Accept input and set input for ourFIFO in 2 moments: 
    1. when o_sync is true (first sample)
    2. During IFFT2FIFO redirect ifft_result to ourFIFO.input
*/
assign fifo_ivalid = (stateX == S_IFFT2FIFO) ? 1 : 0;
assign fifo_idata  = (stateX == S_IFFT2FIFO && progress_cnt < 1) ? tmpOutput :
                     (stateX == S_IFFT2FIFO && progress_cnt > 0) ? ifft_result : 32'bx;

// We are interested in the output of ourFIFO only during S_RECYCLE16, 
// because during that state what comes out of the FIFO is used for building the LTF sequence
// (and is also re-enqueued in the same FIFO for some time...) 
assign fifo_oready = (stateX == S_RECYCLE16) ? 1 : 0;

/* How we build the ht-ltf sequence output by this module? (NB: output goes on ans_ht_ltf)
    1. With the first 64 symbols provided by ourIFFT (written in ifft_result) that we have available when o_sync is asserted and during S_IFFT2FIFO
    2. The rest of the ht-ltf sequence is extracted from ourFIFO used as a circular buffer
*/
assign ans_ht_stf = (stateX == S_IFFT2FIFO && progress_cnt < 1) ? tmpOutput :
                    (stateX == S_IFFT2FIFO && progress_cnt > 0) ? ifft_result :
                    (stateX == S_RECYCLE16) ? fifo_odata : 32'bx;

//We raise this flag to let the FSM3 in dot11_tx.v module understand when it's time to subscribe to
//the output coming out from this ltf_generator module
assign ans_ht_stf_started = (stateX == S_IFFT2FIFO) ? 1 : 0;

endmodule
