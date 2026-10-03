module generic_timer_tb;
    reg        clk;
    reg        start;
    reg        rst_n;
    reg  [7:0] target;
    wire       done;

    generic_timer #(.width(8)) dut (
        .clk   (clk),
        .start (start),
        .rst_n (rst_n),
        .target(target),
        .done  (done)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, generic_timer_tb);

        $monitor("time=%0t | clk=%b | rst_n=%b | start=%b | target=%0d | done=%b",
                 $time, clk, rst_n, start, target, done);

        clk    = 0;
        start  = 0;
        rst_n  = 0;
        target = 0;

        #20;
        start  = 1;
        target = 32;
        #20;
        start  = 0;
        target = 0;

        #20;
        rst_n = 1;

        @(negedge clk);
        start  = 1;
        target = 1;

        @(negedge clk);
        start  = 0;
        target = 0;

        #40;
        @(negedge clk);
        start  = 1;
        target = 9;

        @(negedge clk);
        start  = 0;

        #200;

        @(negedge clk);
        start  = 1;
        target = 25;

        @(negedge clk);
        start  = 0;

        #500;

        @(negedge clk);
        start  = 1;
        target = 0;

        @(negedge clk);
        start  = 0;

        #100;

        @(negedge clk);
        start  = 1;
        target = 10;

        @(negedge clk);
        start  = 0;

        #40;
        rst_n = 0;

        #40;
        rst_n = 1;

        @(negedge clk);
        start  = 1;
        target = 8;

        @(negedge clk);
        start  = 0;

        #40;
        @(negedge clk);
        start  = 1;
        target = 3;

        @(negedge clk);
        start  = 0;

        #100;

        #100;

        $finish;
    end

endmodule