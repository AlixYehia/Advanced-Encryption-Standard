module InvShiftRows (
    input  clk, rst,
    input [0:127] state_in,  // 128-bit input state
    input          InvShiftRowsEN,
    output reg     InvShiftRowsValid,
    output reg [0:127] state_out  // 128-bit output state after ShiftRows
);

    // Extract bytes from column-major ordered input state
    wire [0:7] state [0:3][0:3];

    assign state[0][0] = (InvShiftRowsEN)? state_in[0:7]   : 'bx;   // Byte 0
    assign state[1][0] = (InvShiftRowsEN)? state_in[8:15]  : 'bx;   // Byte 1
    assign state[2][0] = (InvShiftRowsEN)? state_in[16:23] : 'bx;   // Byte 2
    assign state[3][0] = (InvShiftRowsEN)? state_in[24:31] : 'bx;   // Byte 3

    assign state[0][1] = state_in[32:39];    // Byte 4
    assign state[1][1] = state_in[40:47];    // Byte 5
    assign state[2][1] = state_in[48:55];    // Byte 6
    assign state[3][1] = state_in[56:63];    // Byte 7

    assign state[0][2] = state_in[64:71];    // Byte 8
    assign state[1][2] = state_in[72:79];    // Byte 9
    assign state[2][2] = state_in[80:87];    // Byte 10
    assign state[3][2] = state_in[88:95];    // Byte 11

    assign state[0][3] = state_in[96:103];    // Byte 12
    assign state[1][3] = state_in[104:111];    // Byte 13
    assign state[2][3] = state_in[112:119];     // Byte 14
    assign state[3][3] = state_in[120:127];      // Byte 15

    // Apply inverse ShiftRows
    /* Row 0 (No shift)
       Row 1 (Shift right by 1)
       Row 2 (Shift right by 2)
       Row 3 (Shift right by 3)*/
    // assign state_out = {
    //     state[0][0], state[1][3], state[2][2], state[3][1],  
    //     state[0][1], state[1][0], state[2][3], state[3][2],  
    //     state[0][2], state[1][1], state[2][0], state[3][3],  
    //     state[0][3], state[1][2], state[2][1], state[3][0]   
    // };



always @(posedge clk or negedge rst) begin
  if (!rst) begin
    state_out <= 'b0;
    InvShiftRowsValid <= 1'b0;
  end
  else if (InvShiftRowsEN) begin
    state_out = {
        state[0][0], state[1][3], state[2][2], state[3][1],  
        state[0][1], state[1][0], state[2][3], state[3][2],  
        state[0][2], state[1][1], state[2][0], state[3][3],  
        state[0][3], state[1][2], state[2][1], state[3][0]   
    };
    InvShiftRowsValid <= 1'b1;
  end
  else begin
    InvShiftRowsValid <= 1'b0;
  end
end 

endmodule

