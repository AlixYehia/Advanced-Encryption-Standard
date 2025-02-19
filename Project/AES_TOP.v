module AES_TOP (
    input       wire                        clk, rst,
    input       wire                        KeyValid,
    input       wire        [0:127]         InTxt,
    input       wire        [0:255]         Key,
    input       wire        [3:0]           Nk,                 // External Input, 4, 6, 8
    input       wire        [3:0]           Nr,                 // External Input, 10, 12, 14
    output      wire        [0:127]         OutTxt,
    output      wire                        EncFinish,
    output      wire                        DecFinish
);
    



// Internal Signals \\

// Key Expansion Outputs 
    wire        [0:127]     ExpandedKey;
    wire                    KeyReady;
//------------------------------------------------

// AddRoundKey Outputs
    wire                    NextEnc;  
    wire                    NextDec;  
    wire        [3:0]       Round;  
    wire        [0:127]     AddRoundKey_Out;  
//------------------------------------------------

// AES ENC Outputs
    wire        [0:127]     ShiftRows_Out;
    wire        [0:127]     MixColumns_Out;
//-----------------------------------------------


// AES ENC Outputs
    wire        [0:127]     InvSubByte_Out;
//-----------------------------------------------


    wire        [0:127]     AES_ENC_Out;
    wire        [0:127]     AES_DEC_Out;
    wire        [0:127]     AddRoundKey_In;
//____________________________________________________________



assign AES_ENC_Out = (Round == 4'd0)? InTxt : (Round == Nr)? ShiftRows_Out : MixColumns_Out;


assign AES_DEC_Out = (Round == 4'd0)? OutTxt : InvSubByte_Out;


assign AddRoundKey_In  = (EncFinish)? AES_DEC_Out : AES_ENC_Out;


assign OutTxt = (EncFinish /*&& DecFinish*/)? AddRoundKey_Out : 'bx;



// Key Expansion
KeyExpansion KeyExpansion_Inst (
    .clk(clk), 
    .rst(rst),
    .KeyEncEN(NextEnc),     
    .KeyDecEN(NextDec),     
    .EncFinish(EncFinish),    
    .DecFinish(DecFinish),    
    .KeyValid(KeyValid),     
    .Key(Key), 
    .Round(Round),        
    .Nk(Nk),           
    .Nr(Nr),    
    .ExpandedKey(ExpandedKey),  
    .KeyReady(KeyReady)      
);
    



// AddRoundKey
AddRoundKey AddRoundKey_Inst (
    .clk(clk),
    .rst(rst),
    .KeyValid(KeyValid),
    .KeyReady(KeyReady),
    .ExpandedKey(ExpandedKey),
    .OldState(AddRoundKey_In),
    .Nk(Nk),
    .Nr(Nr),    
    .NextEnc(NextEnc),
    .NextDec(NextDec),
    .EncFinish(EncFinish),
    .DecFinish(DecFinish),
    .Round(Round),
    .NewState(AddRoundKey_Out)
);



// AES ENC
AES_ENC AES_ENC_Inst (
    .clk(clk), 
    .rst(rst),
    .NextEnc(NextEnc),
    .AddRoundKey_Out(AddRoundKey_Out),    
    .Round(Round),
    .Nr(Nr),
    .EncFinish(EncFinish),
    .ShiftRows_Out(ShiftRows_Out),
    .MixColumns_Out(MixColumns_Out)
);



// AES DEC
AES_DEC AES_DEC_Inst (
    .clk(clk), 
    .rst(rst),
    .NextDec(NextDec),
    .AddRoundKey_Out(AddRoundKey_Out),    
    .Round(Round),
    .Nr(Nr),
    .InvSubByte_Out(InvSubByte_Out)
);



endmodule