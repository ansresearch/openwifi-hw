

module ans_ht_ltf_gen(
    input wire clk, reset, boot, output_enabled,
    input [127:0] obf_coeff, output wire[31:0] ans_ht_ltf 
);

// states of the ans_ht_ltf_gen FSM
reg[2:0] stateX = 0;
localparam S_IDLE              = 0;
localparam S_LOADING           = 1;
localparam S_WAITIFFT          = 2;
localparam S_BUFFERING         = 3;
localparam S_EMITTING          = 4;

reg [31:0] Memory [63:0];

// Wiring with our custom ans_ht_ltf_rom
wire [31:0] ht_ltf_freqrom;
wire [31:0] ans_ht_ltf_shifted;
reg[6:0] progress_cnt;


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


//////////////////////////////////////////////////////////////////////////
// HT-LTF generator FINITE STATE MACHINE
//////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin
if (reset) begin
    ifft_ce = 0;
    progress_cnt = 0;
    stateX <= S_IDLE;
    //TODO clear Memory
end else begin
case(stateX)
    S_IDLE: begin
        if(boot) begin
            ifft_ce <= 1;
            progress_cnt = 0;
            stateX <= S_LOADING;
        end
    end    
    
    S_LOADING: begin
        //$display("[%0t]: LOADING %H", $time, ifft_input);
        if (progress_cnt < 63) begin
            progress_cnt <= progress_cnt + 1;
        end else begin
        progress_cnt <= 0;
        stateX <= S_WAITIFFT;          
        end
    end
    
    S_WAITIFFT: begin
        if (ifft_osync) begin
            //$display("[%0t]: MEM[%d] %H", $time, 0, ifft_result);
            stateX <= S_BUFFERING;
            Memory[0] = ifft_result;
            progress_cnt <= 1;
        end
    end
    
     S_BUFFERING: begin
        if (progress_cnt < 64) begin
            //$display("[%0t]: Mem[%d] %H", $time, progress_cnt, ifft_result);
            Memory[progress_cnt] = ifft_result;
            progress_cnt <= progress_cnt + 1;
        end else begin
            progress_cnt <= 0;
            ifft_ce <= 0;
            stateX <= S_EMITTING;
        end
     end

    S_EMITTING: begin
        // do nothing if dot11 did not ask for output yet
        if (output_enabled) begin
            if (progress_cnt < 80) begin
                //$display("[%0t]: -> Mem[%d] %H (%d)", $time, progress_cnt[5:0], Memory[progress_cnt[5:0]], progress_cnt);
                progress_cnt <= progress_cnt + 1;
            end else begin
                progress_cnt <= 0;
                stateX <= S_IDLE;
                //TODO clear Memory  
            end
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

wire output_in_progress;
assign output_in_progress = (stateX == S_EMITTING && output_enabled) ? 1 : 0;

//wire [6:0] memIndex = progress_cnt < 64 ? progress_cnt : progress_cnt - 16;
assign ans_ht_ltf = (output_in_progress == 1) ? Memory[progress_cnt[5:0]] : 32'bx;

endmodule