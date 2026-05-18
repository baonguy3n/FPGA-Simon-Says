`timescale 1ns / 1ps

module sequence_player (
    input wire clk,
    input wire reset,
    input wire tick,
    input wire start,
    input wire [4:0] length,

    input wire [1:0] seq_data,

    output reg [3:0] addr,
    output reg [1:0] led_val,
    output reg led_on,
    output reg done
);

    reg playing;
    reg off_phase;
    reg last_was_shown;

    always @(posedge clk) begin
        if (reset) begin
            addr <= 4'd0;
            led_val <= 2'd0;
            led_on <= 1'b0;
            done <= 1'b0;
            playing <= 1'b0;
            off_phase <= 1'b0;
            last_was_shown <= 1'b0;
        end else begin
            done <= 1'b0;

            if (start && !playing) begin
                addr <= 4'd0;
                playing <= 1'b1;
                led_on <= 1'b0;
                off_phase <= 1'b0;
                last_was_shown <= 1'b0;
            end

            else if (playing && tick) begin

                if (!off_phase) begin
                    // ON phase: show current memory value
                    led_val <= seq_data;
                    led_on <= 1'b1;
                    off_phase <= 1'b1;

                    if ({1'b0, addr} == length - 1'b1)
                        last_was_shown <= 1'b1;
                    else
                        last_was_shown <= 1'b0;
                end

                else begin
                    // OFF phase: blank LEDs so repeats are visible
                    led_on <= 1'b0;
                    off_phase <= 1'b0;

                    if (last_was_shown) begin
                        playing <= 1'b0;
                        done <= 1'b1;
                    end else begin
                        addr <= addr + 1'b1;
                    end
                end
            end
        end
    end

endmodule