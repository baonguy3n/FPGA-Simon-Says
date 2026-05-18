module debounce #(
    parameter DELAY = 2_500_000   // ~25 ms at 100 MHz
)(
    input wire clk,
    input wire reset,
    input wire noisy,             // raw button input
    output reg clean              // debounced output
);

    reg [21:0] counter;
    reg sync_0, sync_1;

    // =========================
    // Synchronize to clock domain
    // =========================
    always @(posedge clk) begin
        sync_0 <= noisy;
        sync_1 <= sync_0;
    end

    // =========================
    // Debounce Logic
    // =========================
    always @(posedge clk) begin
        if (reset) begin
            clean   <= 1'b0;
            counter <= 22'd0;
        end else begin
            // If input matches current clean state, reset counter
            if (sync_1 == clean) begin
                counter <= 22'd0;
            end else begin
                // Input is trying to change, count stable time
                counter <= counter + 1'b1;

                if (counter == DELAY) begin
                    clean   <= sync_1;
                    counter <= 22'd0;
                end
            end
        end
    end

endmodule