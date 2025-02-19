`timescale 1ns / 1ns
module AES_TOP_TB;

    bit                         clk, rst;
    logic                       KeyValid;
    logic       [0:127]         InTxt;
    logic       [0:127]         ShiftRows_Out;
    logic       [0:127]         MixColumns_Out;
    logic       [0:255]         Key;
    logic       [3:0]           Nk;         
    logic       [3:0]           Nr;         
    wire        [0:127]         OutTxt;
    wire                        EncFinish;
    wire                        DecFinish;


    parameter clk_period = 20;

    
    reg     [0:127]     ExpecEnc4   [0:10];
    reg     [0:127]     ExpecDec4   [0:10];



AES_TOP DUT (.*);

always #(clk_period/2) clk = ~clk;    


// always @(posedge DUT.KeyReady) begin    
//     if (!EncFinish) begin
//         #(clk_period)    
//         CheckKey(ExpecEnc4[DUT.Round], DUT.Round);        
//     end
//     else if (!DecFinish) begin
//         #(clk_period)    
//         CheckKey(ExpecDec4[DUT.Round], DUT.Round);                
//     end
// end

initial begin
    $dumpfile("AES_ENC.vcd");
    $dumpvars;

    $readmemh("Enc_Nk4.txt", ExpecEnc4);
    $readmemh("Dec_Nk4.txt", ExpecDec4);


    Initialize();
    Reset();


// AES-128 Test
    InTxt = 'h00112233445566778899aabbccddeeff;
    Key[0:127] = 'h000102030405060708090a0b0c0d0e0f;
    Nk    = 'd4;
    Nr    = 'd10;
    KeyValid = 1'b1;
    #(clk_period)
    KeyValid = 1'b0;        

    $display("\n\n\tAES-128 Encryption");
    for (int i = 0; i <= Nr; i++) begin
        @(posedge DUT.KeyReady)
            CheckKey(ExpecEnc4[i], i);                        
    end


    $display("\n\n\tAES-128 Decryption");
    for (int i = 0; i <= Nr; i++) begin
        @(posedge DUT.KeyReady)
            CheckKey(ExpecDec4[i], i);                        
    end


   #(5*clk_period);
    $stop;
end





task Initialize();
    KeyValid = 1'b0;
    Key = 'b0;
    Nk = 'b0;           
    Nr = 'b0;           
    InTxt = 'b0;             
endtask 


task Reset();    
    #(clk_period);
    rst = 1'b1;    
    #(clk_period);
endtask




// task CheckKey;
//     input   reg     [0:127]     ExpecOut;    
//     input   reg     [3:0]       Round;

//     begin
//         @(negedge clk)
//         $timeformat(-9, 0, " ns");
//         if (DUT.AddRoundKey_Out == ExpecOut) begin
//             $display("Test Passed for Round: %2d at %0t",  Round, $realtime);
//         end
//         else begin
//             $display("Test Failed for Round: %2d, Actual = %x & Expec = %x at %0t",  Round, DUT.AddRoundKey_Out, ExpecOut, $realtime);
//         end
//     end
// endtask 



task CheckKey;
    input   reg     [0:127]     ExpecOut;    
    input   reg     [3:0]       Round;

    begin
        #(clk_period)
        @(negedge clk)
            $timeformat(-9, 0, " ns");
            if (DUT.AddRoundKey_Out == ExpecOut) begin
                $display("Test Passed for Round: %2d at %0t",  Round, $realtime);
            end
            else begin
                $display("Test Failed for Round: %2d, Actual = %x & Expec = %x at %0t",  Round, DUT.AddRoundKey_Out, ExpecOut, $realtime);
            end
    end
endtask


endmodule