module input_handler (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [3:0] btn,

    output reg [1:0] input_val,
    output reg valid
);

    reg [3:0] prev_btn;
    reg pending_valid;

    wire one_button_pressed;

    assign one_button_pressed =
        (btn == 4'b0001) ||
        (btn == 4'b0010) ||
        (btn == 4'b0100) ||
        (btn == 4'b1000);

    // =========================
    // Button Input Capture
    // =========================
    always @(posedge clk) begin
        if (reset) begin
            prev_btn      <= 4'b0000;
            input_val     <= 2'b00;
            valid         <= 1'b0;
            pending_valid <= 1'b0;
        end else begin
            valid <= 1'b0;

            if (!enable) begin
                pending_valid <= 1'b0;
            end else begin

                // One clock later, assert valid after input_val is stable
                if (pending_valid) begin
                    valid         <= 1'b1;
                    pending_valid <= 1'b0;
                end

                // Detect a new single-button press
                else if (one_button_pressed && prev_btn == 4'b0000) begin
                    case (btn)
                        4'b0001: input_val <= 2'b00;
                        4'b0010: input_val <= 2'b01;
                        4'b0100: input_val <= 2'b10;
                        4'b1000: input_val <= 2'b11;
                        default: input_val <= 2'b00;
                    endcase

                    pending_valid <= 1'b1;
                end
            end

            prev_btn <= btn;
        end
    end

endmodule