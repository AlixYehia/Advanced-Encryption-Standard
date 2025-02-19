module subbyte_tb;

reg [7:0] in_byte_t;
wire [7:0] out_byte_t;
reg [7:0] SBox [0:255];
integer i;

subbyte DUT ( .in_byte(in_byte_t),
              .out_byte(out_byte_t)
            );

initial begin
    $readmemh("SBox.txt", SBox);
    
    for (i = 'h0; i <= 'hff; i=i+1) begin
        in_byte_t = i;
        #10;
        if (out_byte_t != SBox[i]) begin
            $display("Error at %2x, Actual = %2X, Expec = %2X", i, out_byte_t , SBox[i]);
        end
        
    end

    // Test case 1
    in_byte_t = 8'h00;
    #10;
    if(out_byte_t == 8'h63)
        $display("test case 1 passed");

    // Test case 2
    in_byte_t = 8'h01;
    #10;
    if(out_byte_t == 8'h7c)
        $display("test case 2 passed");

    // Test case 3
    in_byte_t = 8'h7f;
    #10;
    if(out_byte_t == 8'h57)
        $display("test case 3 passed");

    // Test case 4
    in_byte_t = 8'h4f;
    #10;
    if(out_byte_t == 8'h84)
        $display("test case 4 passed");

    // Test case 5
    in_byte_t = 8'h36;
    #10;
    if(out_byte_t == 8'h05)
        $display("test case 5 passed");

   // Test case 6
    in_byte_t = 8'hff;
    #10;
    if(out_byte_t == 8'h16)
        $display("test case 6 passed"); 

    for (i=0;i<10;i=i+1) begin
    in_byte_t = {$random} % 255;
    #10;
    $display("input = %2h, output = %2h",in_byte_t,out_byte_t);
    end

    $stop;

   
end

endmodule