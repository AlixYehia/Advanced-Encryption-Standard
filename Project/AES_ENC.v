module AES_ENC (
    input       wire                        clk, rst,
    input       wire                        NextEnc,
    input       wire        [0:127]         AddRoundKey_Out,    
    input       wire        [3:0]           Round,
    input       wire        [3:0]           Nr,
    input       wire                        EncFinish,
    output      wire        [0:127]         ShiftRows_Out,
    output      wire        [0:127]         MixColumns_Out
);



// Internal Signals \\

// // Key Expansion Outputs 
//     wire        [0:127]     ExpandedKey;
//     wire                    KeyReady;
// //------------------------------------------------

// // AddRoundKey Outputs
//     wire                    NextEncKey;  
//     wire                    NextDecKey;  
//     wire         [3:0]      Round;  
//     wire         [0:127]    AddRoundKey_Out;  
// //------------------------------------------------


// SubByte Outputs
    wire        [0:127]     SubByte_Out;
    wire                    SubByteValid;
//------------------------------------------------


// ShiftRows Outputs
    // wire        [0:127]     ShiftRows_Out;
    wire                    ShiftRowsValid;
//------------------------------------------------


// MixColumns Outputs
    // wire        [0:127]     MixColumns_Out;
    wire                    MixColumnsValid;
//------------------------------------------------


    // wire        [0:127]     AddRoundKey_In;
    // wire        [0:127]         AES_ENC_Out;
//____________________________________________________________





// // Key Expansion
// KeyExpansion KeyExpansion_Inst (
//     .clk(clk), 
//     .rst(rst),
//     .KeyEncEN(NextEncKey),     
//     .KeyDecEN(NextDecKey),     
//     .EncFinish(EncFinish),    
//     .DecFinish(DecFinish),    
//     .KeyValid(KeyValid),     
//     .Key(Key),          
//     .Round(Round),        
//     .Nk(Nk),           
//     .Nr(Nr),    
//     .ExpandedKey(ExpandedKey),  
//     .KeyReady(KeyReady)      
// );
    



// // AddRoundKey
// AddRoundKey AddRoundKey_Inst (
//     .clk(clk),
//     .rst(rst),
//     .KeyValid(KeyValid),
//     .KeyReady(KeyReady),
//     .ExpandedKey(ExpandedKey),
//     .OldState(AddRoundKey_In),
//     .Nk(Nk),
//     .Nr(Nr),    
//     .NextEncKey(NextEncKey),
//     .NextDecKey(NextDecKey),
//     .EncFinish(EncFinish),
//     .DecFinish(DecFinish),
//     .Round(Round),
//     .NewState(AddRoundKey_Out)
// );




// SubByte
SubBytes SubBytes_Inst (
    .clk(clk),
    .rst(rst),
    .in_vector(AddRoundKey_Out),
    .SubByteEN(NextEnc),
    .SubByteValid(SubByteValid),
    .out_vector(SubByte_Out)
);



// ShiftRows
ShiftRows ShiftRows_Inst (
    .clk(clk),
    .rst(rst),
    .state_in(SubByte_Out),
    .ShiftRowsEN(SubByteValid),
    .ShiftRowsValid(ShiftRowsValid),
    .state_out(ShiftRows_Out) 
);



// MixColumns
MixColumns MixColumns_Inst (
    .clk(clk),
    .rst(rst),
    .ShiftRows_Matrix(ShiftRows_Out),
    .MixColumnsEN(ShiftRowsValid),
    .MixColumnsValid(MixColumnsValid),
    .MixColumns_Matrix(MixColumns_Out) 
);


endmodule