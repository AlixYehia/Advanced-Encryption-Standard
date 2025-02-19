module AES_DEC (
    input       wire                        clk, rst,
    input       wire                        NextDec,
    input       wire        [0:127]         AddRoundKey_Out,    
    input       wire        [3:0]           Round,
    input       wire        [3:0]           Nr,
    output      wire        [0:127]         InvSubByte_Out
);



// Internal Signals \\

// SubByte Outputs
    // wire        [0:127]     InvSubByte_Out;
    wire                    InvSubByteValid;
//------------------------------------------------


// ShiftRows Outputs
    wire        [0:127]     InvShiftRows_Out;
    wire                    InvShiftRowsValid;
//------------------------------------------------


// MixColumns Outputs
    wire        [0:127]     InvMixColumns_Matrix;
    wire                    InvMixColumnsValid;
//------------------------------------------------

    wire        [0:127]     InvShiftRows_In;
    wire                    InvShiftRowsEN;
//__________________________________________________________________



assign  InvShiftRows_In = (Round < 4'd2)?  AddRoundKey_Out : InvMixColumns_Matrix;
assign  InvShiftRowsEN  = (Round == 4'd0)? NextDec : InvMixColumnsValid;



// Inverse ShiftRows
InvShiftRows InvShiftRows_Inst (
    .clk(clk),
    .rst(rst),
    .state_in(InvShiftRows_In),                            
    .InvShiftRowsEN(InvShiftRowsEN),
    .InvShiftRowsValid(InvShiftRowsValid),
    .state_out(InvShiftRows_Out) 
);



// Inverse SubByte
InvSubBytes InvSubBytes_Inst (
    .clk(clk),
    .rst(rst),
    .state_in(InvShiftRows_Out),
    .InvSubByteEN(InvShiftRowsValid),
    .InvSubByteValid(InvSubByteValid),
    .InvSubByte_Out(InvSubByte_Out)             
);



// Inverse MixColumns
InvMixColumns InvMixColumns_Inst (
    .clk(clk),
    .rst(rst),
    .MixColumns_Matrix(AddRoundKey_Out),      
    .InvMixColumnsEN(NextDec),    
    .InvMixColumnsValid(InvMixColumnsValid), 
    .InvMixColumns_Matrix(InvMixColumns_Matrix)    
);



endmodule