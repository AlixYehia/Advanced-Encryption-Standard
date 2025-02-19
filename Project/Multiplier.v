module Multiplier (
    input  wire [7:0] Multiplicand,
    input  wire [7:0] Multiplier,
    output reg  [7:0] Product
);

// GF(2^8) multiplication with irreducible polynomial 0x11B (x^8 + x^4 + x^3 + x + 1)
integer i;
reg [15:0] temp;

always @(*) begin
    temp = 16'h0000; // Initialize to zero
    
    // Perform bitwise multiplication
    for (i = 0; i < 8; i = i + 1) begin
        if (Multiplier[i]) begin
            temp = temp ^ (Multiplicand << i); // XOR with shifted multiplicand
        end
    end
    
    // Reduce modulo 0x11B (apply XOR for each bit in the modulus)
    for (i = 15; i >= 8; i = i - 1) begin
        if (temp[i]) begin
            // XOR with 0x11B shifted to the appropriate position
            temp = temp ^ (16'h1B << (i - 8));
        end
    end
    
    // Final product is the lower 8 bits
    Product = temp[7:0];
end

endmodule