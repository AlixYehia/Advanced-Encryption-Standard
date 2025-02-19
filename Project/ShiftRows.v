module ShiftRows (
    input  clk, rst,
    input [0:127]  state_in,  // 128-bit input state
    input          ShiftRowsEN,
    output reg     ShiftRowsValid,
    output reg [0:127] state_out  // 128-bit output state after ShiftRows
);

    // Extract bytes from column-major ordered input state
    wire [0:7] state [0:3][0:3];

    assign state[0][0] = (ShiftRowsEN)? state_in[0:7]   : 'bx;   // Byte 0
    assign state[1][0] = (ShiftRowsEN)? state_in[8:15]  : 'bx;   // Byte 1
    assign state[2][0] = (ShiftRowsEN)? state_in[16:23] : 'bx;   // Byte 2
    assign state[3][0] = (ShiftRowsEN)? state_in[24:31] : 'bx;   // Byte 3

    assign state[0][1] = (ShiftRowsEN)? state_in[32:39] : 'bx;    // Byte 4
    assign state[1][1] = (ShiftRowsEN)? state_in[40:47] : 'bx;    // Byte 5
    assign state[2][1] = (ShiftRowsEN)? state_in[48:55] : 'bx;    // Byte 6
    assign state[3][1] = (ShiftRowsEN)? state_in[56:63] : 'bx;    // Byte 7

    assign state[0][2] = (ShiftRowsEN)? state_in[64:71] : 'bx;    // Byte 8
    assign state[1][2] = (ShiftRowsEN)? state_in[72:79] : 'bx;    // Byte 9
    assign state[2][2] = (ShiftRowsEN)? state_in[80:87] : 'bx;    // Byte 10
    assign state[3][2] = (ShiftRowsEN)? state_in[88:95] : 'bx;    // Byte 11

    assign state[0][3] = (ShiftRowsEN)? state_in[96:103]  : 'bx;    // Byte 12
    assign state[1][3] = (ShiftRowsEN)? state_in[104:111] : 'bx;    // Byte 13
    assign state[2][3] = (ShiftRowsEN)? state_in[112:119] : 'bx;    // Byte 14
    assign state[3][3] = (ShiftRowsEN)? state_in[120:127] : 'bx;    // Byte 15

    // Apply ShiftRows
    /* Row 0 (No shift)
       Row 1 (Shift left by 1)
       Row 2 (Shift left by 2)
       Row 3 (Shift left by 3)*/
    // assign state_out = {
    //     state[0][0], state[1][1], state[2][2], state[3][3],  
    //     state[0][1], state[1][2], state[2][3], state[3][0],  
    //     state[0][2], state[1][3], state[2][0], state[3][1],  
    //     state[0][3], state[1][0], state[2][1], state[3][2]   
    // };


always @(posedge clk or negedge rst) begin
  if (!rst) begin
    state_out <= 'b0;
    ShiftRowsValid <= 1'b0;
  end
  else if (ShiftRowsEN) begin
    state_out <= {
        state[0][0], state[1][1], state[2][2], state[3][3],  
        state[0][1], state[1][2], state[2][3], state[3][0],  
        state[0][2], state[1][3], state[2][0], state[3][1],  
        state[0][3], state[1][0], state[2][1], state[3][2]   
    };
    ShiftRowsValid <= 1'b1;
  end
  else begin
    ShiftRowsValid <= 1'b0;
  end
end 

endmodule

