`timescale 1ns/1ps

module MixColumns_tb;

    ///////////////////////////////////////////////////////////////
    //////////////////////// DUT Signals //////////////////////////
    ///////////////////////////////////////////////////////////////
    reg  [0:127] ShiftRows_Matrix;
    wire [0:127] MixColumns_Matrix;

    integer test_num;
    integer error_count;

    ///////////////////////////////////////////////////////////////
    //////////////////// DUT Instantiation ////////////////////////
    ///////////////////////////////////////////////////////////////
    
    MixColumns DUT (
        .ShiftRows_Matrix(ShiftRows_Matrix),
        .MixColumns_Matrix(MixColumns_Matrix)
    );

    ///////////////////////////////////////////////////////////////
    /////////////////////////// Tasks /////////////////////////////
    ///////////////////////////////////////////////////////////////

    task check_mixcolumns;
        input [0:127] expected;
        begin
            test_num = test_num + 1; // Increment test counter inside the task
            $display("\n****** TEST_CASE %0d ******\n", test_num);
            #10; // Wait for computation
            if (MixColumns_Matrix !== expected) begin
                $display("Test %0d FAILED: Expected = 0x%032h, Got = 0x%032h", 
                         test_num, expected, MixColumns_Matrix);
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
        $dumpfile("MixColumns.vcd");
        $dumpvars;

        // --------------------------------------------------
        // Test Case 1: (From Appendix B)
        // --------------------------------------------------
        // Input State (after ShiftRows) in row order:
        //   Column 0: d4 e0 b8 1e
        //   Column 1: bf b4 41 27
        //   Column 2: 5d 52 11 98
        //   Column 3: 30 ae f1 e5
        ShiftRows_Matrix = 128'hd4_bf_5d_30_e0_b4_52_ae_b8_41_11_f1_1e_27_98_e5;
        // Expected Output in row order:
        //   Column 0: 04 e0 48 28
        //   Column 1: 66 cb f8 06
        //   Column 2: 81 19 d3 26
        //   Column 3: e5 9a 7a 4c
        check_mixcolumns(128'h04_66_81_e5_e0_cb_19_9a_48_f8_d3_7a_28_06_26_4c);


        // --------------------------------------------------
        // Test Case 2: (From Appendix B)
        // --------------------------------------------------
        // Input State (after ShiftRows) in row order:
        //   Column 0: 49 45 7f 77
        //   Column 1: db 39 02 de
        //   Column 2: 87 53 d2 96
        //   Column 3: 3b 89 f1 1a
        ShiftRows_Matrix = 128'h49_db_87_3b_45_39_53_89_7f_02_d2_f1_77_de_96_1a;
        check_mixcolumns(128'h58_4d_ca_f1_1b_4b_5a_ac_db_e7_ca_a8_1b_6b_b0_e5);


        // --------------------------------------------------
        // Test Case 3: (From Appendix B)
        // --------------------------------------------------
        // Input State (after ShiftRows) in row order:
        //   Column 0: ac ef 13 45
        //   Column 1: c1 b5 23 73
        //   Column 2: d6 5a cf 11
        //   Column 3: b8 7b df b5
        ShiftRows_Matrix = 128'hac_c1_d6_b8_ef_b5_5a_7b_13_23_cf_df_45_73_11_b5;
        // Expected Output in row order:
        //   Column 0: 75 20 53 bb
        //   Column 1: ec 0b c0 25
        //   Column 2: 09 63 cf d0
        //   Column 3: 93 33 7c dc
        check_mixcolumns(128'h75_ec_09_93_20_0b_63_33_53_c0_cf_7c_bb_25_d0_dc);


        // --------------------------------------------------
        // Summary
        // --------------------------------------------------
        $display("\nTests completed with %0d errors.", error_count);
        $stop;
    end

endmodule
