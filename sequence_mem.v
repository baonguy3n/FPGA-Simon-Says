module sequence_mem (
    input wire clk,

    input wire write_en,
    input wire [3:0] write_addr,
    input wire [1:0] write_data,

    input wire [3:0] play_read_addr,
    output wire [1:0] play_read_data,

    input wire [3:0] input_read_addr,
    output wire [1:0] input_read_data
);

    reg [1:0] memory [0:15];

    // =========================
    // Write Logic
    // =========================
    always @(posedge clk) begin
        if (write_en) begin
            memory[write_addr] <= write_data;
        end
    end

    // =========================
    // Dual Read Ports
    // =========================
    assign play_read_data  = memory[play_read_addr];
    assign input_read_data = memory[input_read_addr];

endmodule