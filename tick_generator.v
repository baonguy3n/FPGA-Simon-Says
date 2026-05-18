module tick_generator #(
    parameter COUNT_MAX = 50_000_000
)(
    input wire clk,
    input wire reset,
    output reg tick
);

    reg [31:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= 32'd0;
            tick  <= 1'b0;
        end else begin
            // Default: no tick
            tick <= 1'b0;

            // Generate a one-clock pulse every COUNT_MAX cycles
            if (count == COUNT_MAX - 1) begin
                count <= 32'd0;
                tick  <= 1'b1;
            end else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule