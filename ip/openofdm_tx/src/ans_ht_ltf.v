/*

STILL TO BE UPDATED TO BECOME AN HT-LTF GENERATOR

A module used for generating the 80 (time) samples of the HT long preamble
starting from the 802.11 standard (frequency) coefficients tabled in ans_ht_ltf_rom.v

The standard (frequency) coefficient are manipulated according to the content of the register
defined by this module as ''input [127:0] obf_coeff''

This register stores a 2bits "multiplier-coefficient" for each of the 64 OFDM carrier (20MHz). 
In fact, to implement our obsfuscation technique, selected carriers shall be either partially amplified or suppressed.
Without obfuscation, the standard content extracted from ans_ht_ltf_rom (driven by the wire 'ht_ltf_freqrom'), 
shall be converted to its time-domain representation applying the IFFT, however, if obfuscation is enabled, custom_ltf
may be be further manipulated and may be:

- divided by 2
- divided by 4
- divided by 8

In light of this description the reader should notice that we always keep available 3 registers called, respectively, ltf_DivBy2, ltf_DivBy4 and ltf_DivBy8

NB:
assign ltf_DivBy2 = {ht_ltf_freqrom[31], ht_ltf_freqrom[31:17], ht_ltf_freqrom[15], ht_ltf_freqrom[15:1]};
assign ltf_DivBy4 = {ht_ltf_freqrom[31], ht_ltf_freqrom[31], ht_ltf_freqrom[31:18], ht_ltf_freqrom[15], ht_ltf_freqrom[15], ht_ltf_freqrom[15:2]};
assign ltf_DivBy8 = {ht_ltf_freqrom[31], ht_ltf_freqrom[31], ht_ltf_freqrom[31], ht_ltf_freqrom[31:19], ht_ltf_freqrom[15], ht_ltf_freqrom[15], ht_ltf_freqrom[15], ht_ltf_freqrom[15:3]};

Which properly apply "Two's_complement" algebra on both the real and imaginary parts of custom_ltf which, indeed, is a 32-bits long register where the
16 leftmost/rightmost bits denote, in Two's complement notation, the real and imaginary parts of a complex number.

Summing up, each carrier is either left unchanged, divided by 2, 4 or 8 according to the 2-bits reserved for this carrier in "input [127:0] obf_coeff".
The selected operation is reflected in the (internal) wire ans_ht_ltf_shifted that, according to the possible value (00, 01, 10, 11) of the related 2-bits,
prepares the proper input for the IFFT block of this module.

NB:
assign ans_ht_ltf_shifted = 
(stateX == S_LOADING && curr_coeff == 2'b00) ? custom_ltf : 
(stateX == S_LOADING && curr_coeff == 2'b01) ? ltf_DivBy8 : 
(stateX == S_LOADING && curr_coeff == 2'b10) ? ltf_DivBy2 : 
(stateX == S_LOADING && curr_coeff == 2'b11) ? ltf_DivBy4
 : 32'bx;
     
 
The rest of the module defines a State machine responsible for the generation of the 80 time-samples of the HT-LTF
applying the obfuscation coefficients to the frequency represation of the HT-LTF as tabled in ans_ht_ltf_rom.v

The state machine evolution follows this sequence of steps:

0 -> S_IDLE
Initially the FSM just waits for the signal (i.e., interrupt) that notifies the start of a new packet transmission.
Indeed, the "letsgo" signal that enables the transition from S_IDLE to S_LOADING is asserted in the dot11_tx.v module
when phy_tx_start gets asserted.

1 -> S_LOADING
In this state the FSM iterates over progress_cnt (which ranges from 0 to 63) and:
- extract a standard coefficient from the ROM
- applies the obfuscation multiplier and then provides the so obfuscated coefficient as input to an IFFT block (called in this module ourIfftBlock)

Once this loading routine has been completed for all 64 carriers, then the FSM starts waiting for the output of the IFFT

2 -> S_WAITIFFT
The FSM remains in this state until ourIfftBlock starts providing output.
In other terms, as soon as ourIfftBlock raises the ifft_osync signal, a signal which notifies the end of the IFFT computation and the start
of the IFFT output generation: at this point then FSM transits to the S_IFFT2FIFO state.

3 -> S_IFFT2FIFO
According to the 802.11 standard, the HT-LTF is made by 64+16symbols...

The first 64 symbols printed in output by ourIfftBlock are the first 64 samples of our obfuscated HT-LTF. 
These same symbols can be recycled later to finish building the complete HT-LTF.
For this reason, during S_IFFT2FIFO this module makes two main actions:
    3.1) redirects the IFFT_output to a FIFO-bram (called ourFIFO)
    3.2) starts already emitting output, redirecting the IFFT output on the output wire of this module, namely, 'output wire[31:0] ans_ht_ltf'

Recap: After 64 clock ticks spent in state S_IFFT2FIFO, ourFIFO will be completely loaded with the first 64 symbols of the HT-LTF.
These same 64 values will have been sent as output already over ans_ht_ltf.
At this point the FSM transits to S_RECYCLE16 state.

4 -> S_RECYCLE16
Entering this state means that, to complete building the LTF sequence, the content of ourFIFO must be "circularly recycled" 16 times,
appending the 16 last symbols to the 64 already output during S_IFFT2FIFO.
During S_RECYCLE16 the FSM redirects the output of the FIFO to ans_ht_ltf (the module output)
   
From S_RECYCLE16 the FSM transits back to S_IDLE, concluding the lifecycle of this module.

NB: while the FSM evolution is coded in the main always @(posedge clk) block of this module,
the manipulation/redirection of input/output signals is coded exploiting continuous assignment statements,
these latter are written right below the main ''always'' block.
*/

module ans_ht_ltf_generator(
    input wire clk, reset, letsgo, givemeoutput,
    input [127:0] obf_coeff,
    output wire[31:0] ans_ht_ltf, wire ans_ht_ltf_started 
);

// states of the ans_ht_ltf_gen FSM
reg[2:0] stateX = 0;
localparam S_IDLE              = 0;
localparam S_LOADING           = 1;
localparam S_WAITIFFT          = 2;
localparam S_WAITREADY4OUT     = 3;
localparam S_IFFT2FIFO         = 4;
localparam S_RECYCLE16         = 5;

// Wiring with our custom ans_ht_ltf_rom
wire [31:0] ht_ltf_freqrom;
wire [31:0] ans_ht_ltf_shifted;
reg[6:0] progress_cnt;

reg [31:0] tmpOutput;

ans_ht_ltf_rom freqROM (.addr(progress_cnt), .dout(ht_ltf_freqrom));

// Wires where we make our obfuscation math
wire [31:0] ht_ltf_DivBy2;
wire [31:0] ht_ltf_DivBy4;
wire [31:0] ht_ltf_DivBy8;
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
            // Redirect FIFO output in FIFO input for 16 time, so to generate HT-LTF sequence...
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
// NB: standard ht-ltf (frequency) coeff comes directly from our ROM (ht_ltf_freqrom)
assign ht_ltf_DivBy2 = {ht_ltf_freqrom[31], ht_ltf_freqrom[31:17], ht_ltf_freqrom[15], ht_ltf_freqrom[15:1]};
assign ht_ltf_DivBy4 = {ht_ltf_freqrom[31], ht_ltf_freqrom[31], ht_ltf_freqrom[31:18], ht_ltf_freqrom[15], ht_ltf_freqrom[15], ht_ltf_freqrom[15:2]};
assign ht_ltf_DivBy8 = {ht_ltf_freqrom[31], ht_ltf_freqrom[31], ht_ltf_freqrom[31], ht_ltf_freqrom[31:19], ht_ltf_freqrom[15], ht_ltf_freqrom[15], ht_ltf_freqrom[15], ht_ltf_freqrom[15:3]};

assign curr_coeff = obf_coeff[(progress_cnt * 2) +: 2];

//While LOADING, choose the ''shifted ltf''
assign ans_ht_ltf_shifted = 
(stateX == S_LOADING && curr_coeff == 2'b00) ? ht_ltf_freqrom : 
(stateX == S_LOADING && curr_coeff == 2'b01) ? ht_ltf_DivBy8 : 
(stateX == S_LOADING && curr_coeff == 2'b10) ? ht_ltf_DivBy2 : 
(stateX == S_LOADING && curr_coeff == 2'b11) ? ht_ltf_DivBy4
 : 32'bx;


//Provide shited coefficients as input to the IFFT only during LOADING state
assign ifft_input = (stateX == S_LOADING) ? ans_ht_ltf_shifted : 32'bx;

/* Accept input and set input for ourFIFO in 2 moments: 
    1. when transition from S_WAITREADY4OUT to IFFT2FIFO (first sample)
    2. During IFFT2FIFO (always redirect ifft_result to ourFIFO.input)
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
assign ans_ht_ltf = (stateX == S_IFFT2FIFO && progress_cnt < 1) ? tmpOutput :
                    (stateX == S_IFFT2FIFO && progress_cnt > 0) ? ifft_result :
                    (stateX == S_RECYCLE16) ? fifo_odata : 32'bx;

//We raise this flag to let the FSM3 in dot11_tx.v module understand when it's time to subscribe to
//the output coming out from this ltf_generator module
assign ans_ht_ltf_started = (stateX == S_IFFT2FIFO) ? 1 : 0;

endmodule