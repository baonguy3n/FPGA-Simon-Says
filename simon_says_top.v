module simon_says_top (
    input wire clk,              // 100 MHz clock
    input wire btn_reset,        // CPU_RESETN, active-low
    input wire btn_start,
    input wire [3:0] btn,
    input wire [15:0] sw,

    output wire [3:0] led,
    output wire [6:0] seg,
    output wire [7:0] an
);
    //allow user to pick starting level by flipping the switch
    reg [4:0] selected_level;
    
    always @(*) begin
        if      (sw[15]) selected_level = 5'd16;
        else if (sw[14]) selected_level = 5'd15;
        else if (sw[13]) selected_level = 5'd14;
        else if (sw[12]) selected_level = 5'd13;
        else if (sw[11]) selected_level = 5'd12;
        else if (sw[10]) selected_level = 5'd11;
        else if (sw[9])  selected_level = 5'd10;
        else if (sw[8])  selected_level = 5'd9;
        else if (sw[7])  selected_level = 5'd8;
        else if (sw[6])  selected_level = 5'd7;
        else if (sw[5])  selected_level = 5'd6;
        else if (sw[4])  selected_level = 5'd5;
        else if (sw[3])  selected_level = 5'd4;
        else if (sw[2])  selected_level = 5'd3;
        else if (sw[1])  selected_level = 5'd2;
        else if (sw[0])  selected_level = 5'd1;
        else             selected_level = 5'd1;
    end
    
    // =========================
    // Reset
    // =========================
    wire reset;
    assign reset = ~btn_reset;

    // =========================
    // Internal Signals
    // =========================
    wire write_en;
    wire [3:0] gen_addr;

    wire play_start;
    wire input_enable;
    wire [3:0] input_index;

    wire [4:0] level;
    wire game_over;
    wire show_win;
    wire show_lose;

    wire player_done;
    wire input_valid;

    wire [1:0] rand_val;
    wire [1:0] led_val;
    wire [1:0] input_val;
    wire led_on;

    wire [3:0] player_addr;

    wire [1:0] play_seq_data;
    wire [1:0] expected_seq_data;

    wire display_tick;

    wire start_clean;
    wire [3:0] btn_clean;

    // =========================
    // Tick Generator
    // =========================
    tick_generator #(50_000_000) tick_gen (
        .clk(clk),
        .reset(reset),
        .tick(display_tick)
    );

    // =========================
    // Debounce Start Button
    // =========================
    debounce db_start (
        .clk(clk),
        .reset(reset),
        .noisy(btn_start),
        .clean(start_clean)
    );

    // =========================
    // Debounce Game Buttons
    // =========================
    genvar i;

    generate
        for (i = 0; i < 4; i = i + 1) begin : db_loop
            debounce db_btn (
                .clk(clk),
                .reset(reset),
                .noisy(btn[i]),
                .clean(btn_clean[i])
            );
        end
    endgenerate

    // =========================
    // FSM Controller
    // =========================
    fsm_controller fsm (
        .clk(clk),
        .reset(reset),
        .start_btn(start_clean),
        .start_level(selected_level),

        .player_done(player_done),
        .input_valid(input_valid),
        .input_val(input_val),
        .expected_val(expected_seq_data),

        .write_en(write_en),
        .gen_addr(gen_addr),

        .play_start(play_start),
        .input_enable(input_enable),
        .input_index(input_index),

        .level(level),
        .game_over(game_over),
        .show_win(show_win),
        .show_lose(show_lose)
    );

    // =========================
    // Random Generator
    // =========================
    lfsr_random lfsr (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),
        .rand(rand_val)
    );

    // =========================
    // Sequence Memory
    // =========================
    sequence_mem mem (
        .clk(clk),
        .write_en(write_en),
        .write_addr(gen_addr),
        .write_data(rand_val),

        .play_read_addr(player_addr),
        .play_read_data(play_seq_data),

        .input_read_addr(input_index),
        .input_read_data(expected_seq_data)
    );

    // =========================
    // Sequence Player
    // =========================
    sequence_player player (
        .clk(clk),
        .reset(reset),
        .tick(display_tick),
        .start(play_start),
        .length(level),
        .seq_data(play_seq_data),
        .addr(player_addr),
        .led_val(led_val),
        .led_on(led_on),
        .done(player_done)
    );

    // =========================
    // Input Handler
    // =========================
    input_handler input_mod (
        .clk(clk),
        .reset(reset),
        .enable(input_enable),
        .btn(btn_clean),
        .input_val(input_val),
        .valid(input_valid)
    );

    // =========================
    // LED Output Logic
    // =========================
    
    /*
    assign led = input_enable ?
        ((expected_seq_data == 2'b00) ? 4'b0001 :
         (expected_seq_data == 2'b01) ? 4'b0010 :
         (expected_seq_data == 2'b10) ? 4'b0100 :
                                        4'b1000)
        :
        ((led_val == 2'b00) ? 4'b0001 :
         (led_val == 2'b01) ? 4'b0010 :
         (led_val == 2'b10) ? 4'b0100 :
                              4'b1000);
    */
    
    
    reg [3:0] led_reg;

    always @(*) begin
        if (game_over)
            led_reg = 4'b1111;
        else if (input_enable)
            led_reg = 4'b0000;
        else if (led_on)
            led_reg = (led_val == 2'b00) ? 4'b0001 :
                      (led_val == 2'b01) ? 4'b0010 :
                      (led_val == 2'b10) ? 4'b0100 :
                                           4'b1000;
        else
            led_reg = 4'b0000;
    end

    assign led = led_reg;
    
    
    // =========================
    // 7-Segment Display
    // =========================
    seven_seg_driver ssd (
        .clk(clk),
        .reset(reset),
        .value(level),
        .show_win(show_win),
        .show_lose(show_lose),
        .seg(seg),
        .an(an)
    );

endmodule