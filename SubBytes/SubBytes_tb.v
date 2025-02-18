`timescale 1ns/1ps

module SubBytes_tb;

    ///////////////////////////////////////////////////////////////
    //////////////////////// DUT Signals //////////////////////////
    ///////////////////////////////////////////////////////////////
    reg  [0:127] in_vector;
    wire [0:127] out_vector;

    integer test_num;
    integer error_count;

    ///////////////////////////////////////////////////////////////
    //////////////////// DUT Instantiation ////////////////////////
    ///////////////////////////////////////////////////////////////
    SubBytes DUT (
        .in_vector(in_vector),
        .out_vector(out_vector)
    );

    ///////////////////////////////////////////////////////////////
    /////////////////////////// Tasks /////////////////////////////
    ///////////////////////////////////////////////////////////////
    task check_subbytes;
        input [0:127] expected;
        begin
            test_num = test_num + 1;
            $display("\n****** TEST_CASE %0d ******\n", test_num);
            #10; // Wait for computation
            if (out_vector !== expected) begin
                $display("Test %0d FAILED: Expected = 0x%032h, Got = 0x%032h", 
                         test_num, expected, out_vector);
                error_count = error_count + 1;
            end else begin
                $display("Test %0d PASSED", test_num);
            end
        end
    endtask

    ///////////////////////////////////////////////////////////////
    //////////////////////// Initial Block ////////////////////////
    ///////////////////////////////////////////////////////////////
    initial begin
        error_count = 0;
        test_num = 0;
        $dumpfile("SubBytes.vcd");
        $dumpvars;

        // --------------------------------------------------
        // Test Case 1:
        // --------------------------------------------------
        // Input State (in row order):
        in_vector = { 8'h19, 8'h3d, 8'he3, 8'hbe,
                      8'ha0, 8'hf4, 8'he2, 8'h2b,
                      8'h9a, 8'hc6, 8'h8d, 8'h2a,
                      8'he9, 8'hf8, 8'h48, 8'h08 };
                      
        // Expected Output (after S-box substitution):
        check_subbytes({ 8'hd4, 8'h27, 8'h11, 8'hae,
                         8'he0, 8'hbf, 8'h98, 8'hf1,
                         8'hb8, 8'hb4, 8'h5d, 8'he5,
                         8'h1e, 8'h41, 8'h52, 8'h30 });


        // --------------------------------------------------
        // Summary
        // --------------------------------------------------
        $display("\nTests completed with %0d errors.", error_count);
        $stop;
    end

endmodule
