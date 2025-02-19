`timescale 1ns / 1ps
module AES_TB;

reg    clk;
reg    rst;
reg    KeyValid;
reg    [0:127] InTxt;
reg    [0:255]  Key;
reg    [3:0]    Nk;     // External Input, 4, 6, 8
reg    [3:0]     Nr;    // External Input, 10, 12, 14
wire   [0:127]   OutTxt;
wire   EncFinish;
wire   DecFinish;
reg [0:255] keys [0:5];
reg [0:127] cipher_text [0:5];
reg [0:127] Input_text [0:1];

parameter clk_period = 20;
integer i;

AES_TOP DUT (
    .clk(clk),
    .rst(rst),
    .KeyValid(KeyValid),
    .InTxt(InTxt),
    .Key(Key),
    .Nk(Nk),
    .Nr(Nr),                 
    .OutTxt(OutTxt),
    .EncFinish(EncFinish),
    .DecFinish(DecFinish)
    );

always #(clk_period/2) clk = ~clk;

initial begin
    initialize();
    reset();
    $readmemh("keys.txt",keys);
    $readmemh("cipher_text.txt",cipher_text);
    $readmemh("input_text.txt",Input_text);

    //test AES-128
    Nk = 4'd4;
    Nr = 4'd10;
    $display("AES-128 check");
    for (i=0;i<2;i=i+1) begin
    Key [0:127] = keys [i];
    InTxt = Input_text[i];
    KeyValid = 1'b1;
    #(clk_period);
    KeyValid = 1'b0;
    $display("Test no.%0d",i+1);
    AES_check (cipher_text[i],InTxt);
    #(clk_period);
    end

    //test AES-192
    Nk = 4'd6;
    Nr = 4'd12;
    $display("AES-192 check");
    for (i=2;i<4;i=i+1) begin
    Key [0:191] = keys[i];
    InTxt = Input_text[i-2];
    KeyValid = 1'b1;
    #(clk_period);
    KeyValid = 1'b0;
    $display("Test no.%0d",i+1);
    AES_check (cipher_text[i],InTxt);
    #(clk_period);
    end

    //test AES-256
    Nk = 4'd8;
    Nr = 4'd14;
    $display("AES-256 check");
    for(i=4;i<6;i=i+1) begin
    Key  = keys[i];
    InTxt = Input_text[i-4];
    KeyValid = 1'b1;
    #(clk_period);
    KeyValid = 1'b0;
    $display("Test no.%0d",i+1);
    AES_check (cipher_text[i],InTxt);
    #(clk_period);
    end

    #(5*clk_period);
    $stop;
end

task initialize;
begin
clk = 0;
rst = 1;
Key = 'b0;
Nk = 'b0;
Nr = 'b0;
InTxt = 'b0;
KeyValid = 1'b0;
end
endtask

task reset;
begin
rst = 1'b0;
#(clk_period);
rst = 1'b1;
#(clk_period);
end
endtask

task AES_check;
input reg [0:127] Expected_Cipher;
input reg [0:127] Expected_output;
begin
    $timeformat(-9, 0, " ns");
    @(posedge EncFinish)
    if(Expected_Cipher == OutTxt) begin
        $display ("Encryption done successfully at %0t",$time);
    end
    else begin
        $display ("Encryption failed at %0t...Output = %x, Expected output = %x",$time,OutTxt,Expected_Cipher);
    end

    @(posedge DecFinish)
    if(Expected_output == OutTxt) begin
        $display ("Decryption done successfully at %0t",$time);
    end
    else begin
        $display ("Decryption failed at %0t...Output = %x, Expected output = %x",$time,OutTxt,Expected_output);
    end
end
endtask



endmodule