`timescale 1ns/1ps

module generic_timer_tb_Self;

    reg clk;
    reg start;
    reg rst_n;
    reg [7:0] target;
    wire done;

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;

    generic_timer #(.width(8)) dut (
        .clk(clk),
        .start(start),
        .rst_n(rst_n),
        .target(target),
        .done(done)
    );

    always #10 clk = ~clk;

    task check;
        input expected;
        input [8*80-1:0] test_name;
        begin
            if (done === expected) begin
                $display("PASS: %0s | expected=%b actual=%b",
                         test_name, expected, done);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s | expected=%b actual=%b",
                         test_name, expected, done);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task reset_timer;
        begin
            @(negedge clk);
            rst_n = 0;
            start = 0;
            target = 0;

            @(posedge clk);
            #1;
            check(0, "Reset clears done");

            @(negedge clk);
            rst_n = 1;
        end
    endtask

    task run_timer;
        input [7:0] test_target;
        input integer expected_cycles;
        input [8*80-1:0] test_name;
        begin
            @(negedge clk);
            target = test_target;
            start = 1;

            @(posedge clk);
            #1;
            check(0, "done is low after start");

            @(negedge clk);
            start = 0;

            for (i = 1; i <= expected_cycles; i = i + 1) begin
                @(posedge clk);
                #1;

                if (i < expected_cycles)
                    check(0, "done remains low before target");
                else
                    check(1, test_name);
            end

            @(negedge clk);
            start = 0;

            @(posedge clk);
            #1;
            check(0, "done clears after completion");
        end
    endtask

    initial begin
        clk = 0;
        start = 0;
        rst_n = 0;
        target = 0;

       

        $display("====================================");
        $display("GENERIC TIMER SELF-CHECKING TEST");
        $display("====================================");

        repeat (2) @(posedge clk);
        #1;
        check(0, "Initial reset");

        @(negedge clk);
        start = 1;
        target = 32;

        repeat (2) @(posedge clk);
        #1;
        check(0, "Start ignored during reset");

        @(negedge clk);
        start = 0;
        rst_n = 1;

        run_timer(1,   1,   "Target 1");
        run_timer(9,   9,   "Target 9");
        run_timer(25,  25,  "Target 25");
        run_timer(32,  32,  "Target 32");
        run_timer(10,  10,  "Target 10");
        run_timer(8,   8,   "Target 8");
        run_timer(3,   3,   "Target 3");
        run_timer(255, 255, "Maximum target 255");

        run_timer(0, 256, "Target 0 counter wraparound");

        reset_timer();

        @(negedge clk);
        target = 10;
        start = 1;
        @(posedge clk);
        #1;
        check(0, "Reset test started");

        @(negedge clk);
        start = 0;

        repeat (3) @(posedge clk);
        #1;
        check(0, "Timer still counting");

        @(negedge clk);
        rst_n = 0;

        @(posedge clk);
        #1;
        check(0, "Reset cancels active timer");

        @(negedge clk);
        rst_n = 1;

        repeat (12) @(posedge clk);
        #1;
        check(0, "Timer stays idle after reset");

        reset_timer();

        @(negedge clk);
        target = 8;
        start = 1;

        repeat (3) @(posedge clk);
        #1;
        check(0, "Held start keeps done low");

        @(negedge clk);
        start = 0;

        repeat (7) @(posedge clk);
        #1;
        check(0, "Held start restarts counter");

        @(posedge clk);
        #1;
        check(1, "Held start timer completes after release");

        @(negedge clk);
        start = 0;

        reset_timer();

        @(negedge clk);
        target = 8;
        start = 1;

        @(posedge clk);
        #1;

        @(negedge clk);
        start = 0;

        repeat (2) @(posedge clk);
        #1;
        check(0, "Active timer before restart");

        @(negedge clk);
        target = 3;
        start = 1;

        @(posedge clk);
        #1;
        check(0, "Restart clears done");

        @(negedge clk);
        start = 0;

        repeat (2) @(posedge clk);
        #1;
        check(0, "Restarted timer still counting");

        @(posedge clk);
        #1;
        check(1, "Restart with target 3 completes");

        reset_timer();

        @(negedge clk);
        target = 8;
        start = 1;

        @(posedge clk);
        #1;

        @(negedge clk);
        start = 0;

        repeat (2) @(posedge clk);

        @(negedge clk);
        target = 4;

        repeat (1) @(posedge clk);
        #1;
        check(0, "Changed target not reached yet");

        @(posedge clk);
        #1;
        check(1, "Changed target completes at 4");

        $display("====================================");
        $display("TEST SUMMARY");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);
        $display("====================================");

        if (fail_count == 0)
            $display("OVERALL RESULT: PASS");
        else
            $display("OVERALL RESULT: FAIL");

        $finish;
    end

endmodule