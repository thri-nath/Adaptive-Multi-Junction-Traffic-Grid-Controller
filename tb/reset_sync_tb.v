`timescale 1ns/1ps

module reset_sync_tb;

    reg clk;
    reg rst_n_async;
    wire rst_n_sync;

    reset_sync dut (
        .clk(clk),
        .rst_n_async(rst_n_async),
        .rst_n_sync(rst_n_sync)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n_async = 0;

        #20;
        rst_n_async = 1;

        #100;
        rst_n_async = 0;

        #20;
        rst_n_async = 1;

        #100;
        $finish;
    end

endmodule