// ============================================================================
// InvSubBytes Module
// This module instantiates 16 copies of your InvSubByte LUT-based module.
// ============================================================================
module InvSubBytes (
    input  clk, rst,
    input  [127:0] state_in,
    input  wire    InvSubByteEN,
    output reg         InvSubByteValid,
    output reg [127:0] InvSubByte_Out
);

    wire [127:0] state_out;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : invsub_loop
            InvSubByte u_invsubbyte (
                .in_byte ( state_in[i*8 +: 8] ),
                .out_byte( state_out[i*8 +: 8] )
            );
        end
    endgenerate


always @(posedge clk or negedge rst) begin
  if (!rst) begin
    InvSubByteValid <= 'b0;
    InvSubByte_Out <= 1'b0;
  end
  else if (InvSubByteEN) begin
    InvSubByte_Out <= state_out;
    InvSubByteValid <= 1'b1;
  end
  else begin
    InvSubByteValid <= 1'b0;
  end
end  

endmodule
