`timescale 1ns/1ps

module input_sync_tb;

    reg clk;
    reg rst_n;
    reg [3:0] async_in;
    wire [3:0] sync_out;

    input_sync #(
        .WIDTH(4)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .async_in(async_in),
        .sync_out(sync_out)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        async_in = 4'b0000;

        #20;
        rst_n = 1;

        #20;
        async_in = 4'b1010;

        #40;
        async_in = 4'b0101;

        #40;
        async_in = 4'b1111;

        #40;
        async_in = 4'b0011;

        #40;
        async_in = 4'b0000;

        #40;
        rst_n = 0;

        #20;
        rst_n = 1;

        #40;
        $finish;
    end

endmodule
