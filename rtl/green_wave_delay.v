module green_wave_delay
#(parameter HOLD_CYCLES = 7)
(
    input clk,
    input rst_n,
    input pulse_in,
    input clear,
    output reg pulse_out
);

   parameter TIMER_WIDTH = (HOLD_CYCLES < 2) ? 1 : $clog2(HOLD_CYCLES + 1);

    wire timer_done;
    wire timer_rst_n;

    assign timer_rst_n = rst_n & ~clear;

    generic_timer #(
        .width(TIMER_WIDTH)
    ) timer_inst (
        .clk    (clk),
        .start  (pulse_in),
        .target (HOLD_CYCLES),
        .rst_n  (timer_rst_n),
        .done   (timer_done)
    );

    always @(posedge clk) begin
        if (!rst_n || clear)
            pulse_out <= 1'b0;
        else
            pulse_out <= timer_done;
    end

endmodule