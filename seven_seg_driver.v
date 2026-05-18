module seven_seg_driver (
    input wire clk,
    input wire reset,
    input wire [4:0] value,      // supports 0-16
    input wire show_win,
    input wire show_lose,
    
    output reg [6:0] seg,
    output reg [7:0] an
);

    reg [17:0] refresh_counter;

    wire [1:0] digit_select;
    assign digit_select = refresh_counter[17:16];
    
    reg [3:0] tens;
    reg [3:0] ones;

    // =========================
    // Refresh Counter
    // =========================
    always @(posedge clk) begin
        if (reset) begin
            refresh_counter <= 16'd0;
        end else begin
            refresh_counter <= refresh_counter + 1'b1;
        end
    end

    // =========================
    // Convert Value to Digits
    // =========================
    always @(*) begin
        if (value >= 5'd10) begin
            tens = 4'd1;
            ones = value - 5'd10;
        end else begin
            tens = 4'd0;
            ones = value[3:0];
        end
    end

    // =========================
    // Select Active Digit
    // =========================
    reg [4:0] symbol;
    // 0-9 = digits, 10=L, 11=O, 12=S, 13=E, 14=W, 15=I, 16=N, 17=blank
    
    always @(*) begin
        an = 8'b11111111;
        symbol = 5'd17;
    
        if (show_lose) begin
            case (digit_select)
                2'd0: begin an = 8'b11111110; symbol = 5'd13; end // E
                2'd1: begin an = 8'b11111101; symbol = 5'd12; end // S
                2'd2: begin an = 8'b11111011; symbol = 5'd11; end // O
                2'd3: begin an = 8'b11110111; symbol = 5'd10; end // L
            endcase
        end else if (show_win) begin
            case (digit_select)
                2'd0: begin an = 8'b11111110; symbol = 5'd12; end // S
                2'd1: begin an = 8'b11111101; symbol = 5'd12; end // S
                2'd2: begin an = 8'b11111011; symbol = 5'd15; end // A
                2'd3: begin an = 8'b11110111; symbol = 5'd14; end // P
            endcase
        end else begin 
            if (digit_select[0] == 1'b0) begin
                an = 8'b11111110;
                symbol = {1'b0, ones};
            end else begin
                an = 8'b11111101;
                symbol = {1'b0, tens};
            end
        end
    end
    // =========================
    // Digit to Segment Encoding
    // =========================
   always @(*) begin
    case (symbol)
        5'd0:  seg = 7'b1000000;
        5'd1:  seg = 7'b1111001;
        5'd2:  seg = 7'b0100100;
        5'd3:  seg = 7'b0110000;
        5'd4:  seg = 7'b0011001;
        5'd5:  seg = 7'b0010010;
        5'd6:  seg = 7'b0000010;
        5'd7:  seg = 7'b1111000;
        5'd8:  seg = 7'b0000000;
        5'd9:  seg = 7'b0010000;

        5'd10: seg = 7'b1000111; // L
        5'd11: seg = 7'b1000000; // O
        5'd12: seg = 7'b0010010; // S
        5'd13: seg = 7'b0000110; // E
        5'd14: seg = 7'b0001100; // P
        5'd15: seg = 7'b0001000; // A

        default: seg = 7'b1111111; // blank
    endcase
end

endmodule