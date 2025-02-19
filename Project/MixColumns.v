// File: MixColumns.v
`timescale 1ns / 1ps
`include "Multiplier.v"

module MixColumns (
    input  clk, rst,
    input  wire [0:127] ShiftRows_Matrix,  // 128-bit input (bytes 0..15 arranged in order)
    input  wire         MixColumnsEN,
    output reg          MixColumnsValid,
    output reg [0:127]  MixColumns_Matrix    // 128-bit output in standard order
);

  // Fixed MixColumns matrix coefficients (each row of the fixed matrix)
  localparam [31:0] FIXED0 = 32'h02_03_01_01;
  localparam [31:0] FIXED1 = 32'h01_02_03_01;
  localparam [31:0] FIXED2 = 32'h01_01_02_03;
  localparam [31:0] FIXED3 = 32'h03_01_01_02;

  // Break the 128-bit state into 4 columns (each 32 bits).
  // Standard ordering: 
  //   Column 0: bytes [0:31]  → {in0, in1, in2, in3}
  //   Column 1: bytes [32:63] → {in4, in5, in6, in7}
  //   Column 2: bytes [64:95] → {in8, in9, in10, in11}
  //   Column 3: bytes [96:127]→ {in12, in13, in14, in15}
  wire [31:0] state [0:3];
  assign state[0] = (MixColumnsEN)? ShiftRows_Matrix[0:31]   : 'bx;    // Column 0: d4, bf, 5d, 30
  assign state[1] = (MixColumnsEN)? ShiftRows_Matrix[32:63]  : 'bx;   // Column 1: e0, b4, 52, ae
  assign state[2] = (MixColumnsEN)? ShiftRows_Matrix[64:95]  : 'bx;   // Column 2: b8, 41, 11, f1
  assign state[3] = (MixColumnsEN)? ShiftRows_Matrix[96:127] : 'bx;  // Column 3: 1e, 27, 98, e5

  // Internal signal to hold the new state after MixColumns processing.
  wire [31:0] new_state [0:3];

  // Process each column: for each column c and for each output row r,
  // multiply the corresponding byte by the fixed coefficient (from the MixColumns matrix)
  // and XOR the 4 products.
  genvar c, r;
  generate
    for (c = 0; c < 4; c = c + 1) begin : col_loop
      for (r = 0; r < 4; r = r + 1) begin : row_loop
        wire [7:0] prod0, prod1, prod2, prod3;
        
        // Reversed order: use the lower-order bytes first.
        Multiplier mult0 (
          .Multiplicand( state[c][31 -:8] ),          
          .Multiplier(   (r==0) ? FIXED0[31 -:8] : 
                         (r==1) ? FIXED1[31 -:8] : 
                         (r==2) ? FIXED2[31 -:8] : FIXED3[31 -:8] ),
          .Product(prod0)
        );
        Multiplier mult1 (
          .Multiplicand( state[c][23 -:8] ),          
          .Multiplier(   (r==0) ? FIXED0[23 -:8] : 
                         (r==1) ? FIXED1[23 -:8] : 
                         (r==2) ? FIXED2[23 -:8] : FIXED3[23 -:8] ),
          .Product(prod1)
        );
        Multiplier mult2 (
          .Multiplicand( state[c][15 -:8] ),          
          .Multiplier(   (r==0) ? FIXED0[15 -:8] : 
                         (r==1) ? FIXED1[15 -:8] : 
                         (r==2) ? FIXED2[15 -:8] : FIXED3[15 -:8] ),
          .Product(prod2)
        );
        Multiplier mult3 (
          .Multiplicand( state[c][7 -:8] ),          
          .Multiplier(   (r==0) ? FIXED0[7 -:8] : 
                         (r==1) ? FIXED1[7 -:8] : 
                         (r==2) ? FIXED2[7 -:8] : FIXED3[7 -:8] ),
          .Product(prod3)
        );
        
        // XOR the four products to produce the output byte for row r of column c.
        assign new_state[c][31-(r*8) -: 8] = prod0 ^ prod1 ^ prod2 ^ prod3;
      end
    end
  endgenerate

  // Reassemble the 128-bit output in standard order:
  // Column 0 (new_state[0]), then Column 1, Column 2, and Column 3.
  // assign MixColumns_Matrix = { new_state[0], new_state[1], new_state[2], new_state[3] };

always @(posedge clk or negedge rst) begin
  if (!rst) begin
    MixColumns_Matrix <= 'b0;
    MixColumnsValid <= 1'b0;
  end
  else if (MixColumnsEN) begin
    MixColumns_Matrix <= { new_state[0], new_state[1], new_state[2], new_state[3] };
    MixColumnsValid <= 1'b1;
  end
  else begin
    MixColumnsValid <= 1'b0;
  end
end

endmodule
