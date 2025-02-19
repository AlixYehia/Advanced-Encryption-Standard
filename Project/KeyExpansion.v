module KeyExpansion (
    input       wire                        clk, rst,
    input       wire                        KeyEncEN,           
    input       wire                        KeyDecEN,           
    input       wire                        EncFinish,          
    input       wire                        DecFinish,          
    input       wire                        KeyValid,           // External Input 
    input       wire        [0:255]         Key,                // External Input
    input       wire        [3:0]           Round,              // Round = 0:Nr
    input       wire        [3:0]           Nk,                 // External Input, 4, 6, 8
    input       wire        [3:0]           Nr,                 // External Input, 10, 12, 14
    output      reg         [0:127]         ExpandedKey,        // to AddRoundKey                
    output      reg                         KeyReady            // to AddRoundKey    
);
    

// SBox ROM    
    reg     [7:0]   SBox    [0:255];
    
    wire    [7:0]   ROMIn;               // Not Connected, but for LUTRAM

    wire            ROMEn;
    

    initial begin
        $readmemh("SBox.txt", SBox);
    end

    
    
//// Internal Signals \\\\
    reg     [0:31]      KeyWords       [0:59];

    reg     [0:31]      WrWord;
    wire    [0:31]      Word1, Word2;
    wire    [0:31]      RdWord;

    reg     [5:0]       AddrWr;
    reg     [5:0]       AddrRd;

    reg     [2:0]       Wrcnt;
    reg     [1:0]       Rdcnt;
    reg     [3:0]       g_cnt;
    reg     [3:0]       g_round;

    wire     WrEN;
    wire     RdEN;

    reg     KeyExpFinish;

    wire    [0:31]  gres;
//_____________________________________________________________________________




wire    [5:0]   idx1, idx2;

assign idx1 = (AddrWr-Nk);
assign idx2 = (AddrWr-1'b1);

assign gres = (KeyEncEN && g_cnt == 4'd0)? gfunc(Word2, g_round) : 32'b0; 



//// RAM \\\\
always @(posedge clk) begin
    if (ROMEn) 
        SBox[AddrWr] <= ROMIn;
end

always @(posedge clk) begin
    if (WrEN)     
        KeyWords[AddrWr] <= WrWord;          
end          

assign Word1 = KeyWords[idx1];      
assign Word2 = KeyWords[idx2];      
//_____________________________________________________________________________



//// RAM Write Enable \\\\
assign WrEN = (KeyEncEN)? 1'b1:1'b0;
//_____________________________________________________________________________



//// RAM Write Address \\\\
always @(posedge clk or negedge rst) begin    
    if (!rst) begin
        AddrWr <= 6'b0;
    end
    else if (EncFinish) begin
        AddrWr <= 6'b0;        
    end
    else if (WrEN && !KeyExpFinish) begin
        AddrWr <= AddrWr + 1'b1;
    end    
end


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        KeyExpFinish <= 1'b0;
    end
    else if (DecFinish) begin
        KeyExpFinish <= 1'b0;        
    end
    else if (AddrWr == (4*(Nr+1'b1) - 2'd2)) begin
        KeyExpFinish <= 1'b1;        
    end
end
//_____________________________________________________________________________


//// RAM Read Enable \\\\
assign RdEN = (!KeyReady && (WrEN || EncFinish) && !DecFinish)? 1'b1 : 1'b0;
//_____________________________________________________________________________


//// RAM Read Address \\\\
always @(posedge clk or negedge rst) begin    
    if (!rst) begin
        AddrRd <= 6'b0;
    end
    else if (KeyEncEN) begin
        AddrRd <= AddrRd + 1'b1;
    end    
    else if (EncFinish && KeyReady) begin
        AddrRd <= AddrRd - 3'd4;
    end
end
//_____________________________________________________________________________


always @(*) begin
    if (KeyEncEN && (AddrWr < Nk)) begin                // Initial Key
        WrWord = Key[32*Wrcnt +: 32];             
    end   
    else if (KeyEncEN && g_cnt == 4'd0) begin           // Use gfunc
        WrWord = Word1 ^ gres;
    end 
    else if (KeyEncEN && Nk == 4'd8 && g_cnt == 4'd4) begin           // Use gfunc
        WrWord = Word1 ^ SubWord(Word2);
    end 
    else if (KeyEncEN && g_cnt != 4'd0) begin                           
        WrWord = Word1 ^ Word2;
    end 
    else begin                           
        WrWord = 'b0;
    end 
end



always @(posedge clk or negedge rst) begin    
    if (!rst) begin
        g_cnt <= 4'b0;
        g_round <= 4'b0;
    end
    else if (EncFinish) begin
        g_cnt <= 4'b0;
        g_round <= 4'b0;
    end
    else if (g_cnt == Nk-1) begin
        g_cnt <= 4'b0;  
        g_round <= g_round + 1'b1;
    end
    else if (KeyEncEN && !KeyExpFinish) begin
        g_cnt <= g_cnt + 1'b1;
    end    
end


    
always @(posedge clk or negedge rst) begin    
    if (!rst) begin
        Wrcnt <= 3'b0;
    end
    else if (EncFinish) begin
        Wrcnt <= 3'b0;        
    end
    else if (KeyEncEN) begin      // Initial Key
        Wrcnt <= Wrcnt + 1'b1;       
    end
end    
//_____________________________________________________________________________



//// Outputting \\\\
assign RdWord = (!EncFinish)? WrWord : KeyWords[(AddrRd - 3'd4 + Rdcnt)];


// Encryption
always @(posedge clk or negedge rst) begin    
    if (!rst) begin
        ExpandedKey <= 128'b0;
        Rdcnt <= 2'b0;
    end
    else if (RdEN && Round == 4'd0 && !EncFinish) begin
        ExpandedKey[32*Rdcnt +: 32] <= Key[32*Rdcnt +: 32];
        Rdcnt <= Rdcnt + 1'b1;       
    end
    else if (RdEN) begin
        ExpandedKey[32*Rdcnt +: 32] <= RdWord;
        Rdcnt <= Rdcnt + 1'b1;       
    end
end    



always @(posedge clk or negedge rst) begin    
    if (!rst) begin
        KeyReady <= 1'b0;
    end
    else if (Rdcnt == 2'd3) begin
        KeyReady <= 1'b1;
    end
    else begin
        KeyReady <= 1'b0;
    end
end    
//_____________________________________________________________________________




function [0:31] gfunc;
    input   reg     [0:31]      Word;       
    input   reg     [3:0]       gRound;

    reg     [7:0]       RC;
    reg     [0:31]      shWord;
    reg     [0:31]      subWord;

    integer i;

    begin
        case (gRound)
            4'd1 : RC =  8'h01;
            4'd2 : RC =  8'h02;
            4'd3 : RC =  8'h04;
            4'd4 : RC =  8'h08;
            4'd5 : RC =  8'h10;
            4'd6 : RC =  8'h20;
            4'd7 : RC =  8'h40;
            4'd8 : RC =  8'h80;        
            4'd9 : RC =  8'h1b;
            4'd10: RC =  8'h36;            
            default: RC = 8'h00;
        endcase

        shWord[0:7]   = Word[8:15];
        shWord[8:15]  = Word[16:23];
        shWord[16:23] = Word[24:31];
        shWord[24:31] = Word[0:7];

        subWord = SubWord(shWord);
        
        gfunc = {(subWord[0:7] ^ RC), subWord[8:15], subWord[16:23], subWord[24:31]};
        
    end
endfunction


function [0:31] SubWord;
    input   reg     [0:31]   oldWord;

    integer i;

    begin
        for (i = 0; i < 4; i = i+1) begin
            SubWord[8*i +: 8] = SBox[oldWord[8*i +:8]]; 
        end
    end
endfunction

endmodule