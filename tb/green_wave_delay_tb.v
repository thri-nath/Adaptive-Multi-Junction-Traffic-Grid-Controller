`timescale 1ns/1ps

module green_wave_delay_tb;

    reg clk;
    reg rst_n;
    reg pulse_in;
    reg clear;
    wire pulse_out;

    green_wave_delay #(
        .HOLD_CYCLES(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .pulse_in(pulse_in),
        .clear(clear),
        .pulse_out(pulse_out)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        pulse_in = 0;
        clear = 0;

        #20;
        rst_n = 1;

        #20;
        pulse_in = 1;

        #20;
        pulse_in = 0;

        #180;

       
        clear = 1;
        #20;
        clear = 0;

        #100;

        $finish;
    end

endmodule