module fsm_controller (
    input wire clk,
    input wire reset,
    input wire start_btn,
    input wire [4:0] start_level,

    input wire player_done,
    input wire input_valid,
    input wire [1:0] input_val,
    input wire [1:0] expected_val,

    output reg write_en,
    output reg [3:0] gen_addr,

    output reg play_start,
    output reg input_enable,
    output reg [3:0] input_index,

    output reg [4:0] level,
    output reg game_over,
    output reg show_win,
    output reg show_lose
);

    // =========================
    // State Encoding
    // =========================
    localparam IDLE          = 4'd0;
    localparam GENERATE      = 4'd1;
    localparam START_DISPLAY = 4'd2;
    localparam DISPLAY       = 4'd3;
    localparam INPUT         = 4'd4;
    localparam SUCCESS       = 4'd5;
    localparam FAIL          = 4'd6;
    localparam WIN           = 4'd7;
    
    reg [3:0] state;
    reg [3:0] gen_count;
    
    reg [27:0] message_count;
    localparam MESSAGE_TIME = 28'd150_000_000; // about 1 second at 100 MHz

    // =========================
    // FSM
    // =========================
    always @(posedge clk) begin
        if (reset) begin
            state       <= IDLE;
            level       <= 5'd1;
            gen_addr    <= 4'd0;
            gen_count   <= 4'd0;
            input_index <= 4'd0;

            write_en     <= 1'b0;
            play_start   <= 1'b0;
            input_enable <= 1'b0;
            game_over    <= 1'b0;
            show_win      <= 1'b0;
            show_lose     <= 1'b0;
            message_count <= 28'd0;
        end else begin
            // Default outputs
            write_en     <= 1'b0;
            play_start   <= 1'b0;
            input_enable <= 1'b0;
            game_over    <= 1'b0;
            show_win      <= 1'b0;
            show_lose     <= 1'b0;
            message_count <= 28'd0;

            case (state)

                IDLE: begin
                    gen_count   <= 4'd0;
                    input_index <= 4'd0;
                
                    level <= start_level;
                
                    if (start_btn) begin
                        level <= start_level;
                        state <= GENERATE;
                    end
                end

                GENERATE: begin
                    write_en <= 1'b1;
                    gen_addr <= gen_count;

                    if ({1'b0, gen_count} == level - 1'b1) begin
                        gen_count <= 4'd0;
                        state     <= START_DISPLAY;
                    end else begin
                        gen_count <= gen_count + 1'b1;
                    end
                end

                START_DISPLAY: begin
                    play_start   <= 1'b1;   // one-clock pulse
                    input_index  <= 4'd0;
                    state        <= DISPLAY;
                end

                DISPLAY: begin
                    if (player_done) begin
                        state <= INPUT;
                    end
                end

                INPUT: begin
                    input_enable <= 1'b1;

                    if (input_valid) begin
                        if (input_val == expected_val) begin
                            if ({1'b0, input_index} == level - 1'b1) begin
                                state <= SUCCESS;
                            end else begin
                                input_index <= input_index + 1'b1;
                            end
                        end else begin
                            message_count <= 28'd0;
                            state <= FAIL;
                        end
                    end
                end

             SUCCESS: begin
                gen_count   <= 4'd0;
                input_index <= 4'd0;
            
                if (level == 5'd16) begin
                    message_count <= 28'd0;
                    state <= WIN;
                end else begin
                    level <= level + 1'b1;
                    state <= GENERATE;
                end
            end
            
            WIN: begin
                show_win <= 1'b1;
            
                if (message_count == MESSAGE_TIME - 1) begin
                    message_count <= 28'd0;
                    state <= IDLE;
                end else begin
                    message_count <= message_count + 1'b1;
                end
            end
            
            FAIL: begin
                game_over <= 1'b1;
                show_lose <= 1'b1;
            
                if (message_count == MESSAGE_TIME - 1) begin
                    message_count <= 28'd0;
                    state <= IDLE;
                end else begin
                    message_count <= message_count + 1'b1;
                end
            end 
            endcase
        end
    end

endmodule