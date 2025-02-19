module AddRoundKey (
    input       wire                    clk, rst,
    input       wire                    KeyValid,
    input       wire                    KeyReady,
    input       wire        [0:127]     ExpandedKey,
    input       wire        [0:127]     OldState,
    input       wire        [3:0]       Nk,
    input       wire        [3:0]       Nr,                 
    output      wire                    NextEnc,    
    output      wire                    NextDec,    
    output      reg                     EncFinish,
    output      reg                     DecFinish,
    output      reg         [3:0]       Round,
    output      reg         [0:127]     NewState
);



    reg         EncStart;



assign NextEnc = ((EncStart ^ KeyReady) && !EncFinish);


assign NextDec = (EncFinish && !KeyReady && !DecFinish);
    



always @(posedge clk or negedge rst) begin
    if (!rst) begin
        EncStart <= 1'b0;
    end 
    else if (KeyValid) begin
        EncStart <= 1'b1;
    end        
    else if (EncFinish) begin
        EncStart <= 1'b0;
    end
end    



always @(posedge clk or negedge rst) begin
    if (!rst) begin
        NewState <= 128'b0;
    end 
    else if (KeyReady) begin
        NewState <= OldState ^ ExpandedKey;
    end    
end    



always @(posedge clk or negedge rst) begin
    if (!rst) begin
        Round <= 4'b0;
    end
    else if (KeyReady && Round == Nr) begin
        Round <= 4'b0;
    end
    else if (KeyReady) begin
        Round <= Round + 1'b1;                
    end
end


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        EncFinish <= 1'b0;
    end
    else if (KeyReady && Round == Nr) begin
        EncFinish <= 1'b1;
    end
    else if (KeyValid) begin
        EncFinish <= 1'b0;        
    end
end


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        DecFinish <= 1'b0;
    end
    else if (EncFinish && KeyReady && Round == Nr) begin
        DecFinish <= 1'b1;
    end
    else if (KeyValid) begin
        DecFinish <= 1'b0;        
    end
end



endmodule