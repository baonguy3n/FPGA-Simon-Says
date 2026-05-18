module lfsr_random (
    input wire clk,
    input wire reset,
    input wire enable,
    output wire [1:0] rand
);

    reg [3:0] lfsr;

    always @(posedge clk) begin
        if (reset) begin
            lfsr <= 4'b0001;      // nonzero seed
        end else if (enable) begin
            lfsr <= {lfsr[2:0], lfsr[3] ^ lfsr[2]};
        end
    end

    assign rand = lfsr[1:0];

endmodule