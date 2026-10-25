
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

    // ------------------------------------------
    // SELF-CHECKING TASK
    // ------------------------------------------
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

    // ------------------------------------------
    // RESET TASK
    // ------------------------------------------
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

    // ------------------------------------------
    // NORMAL TIMER TEST
    // expected_cycles counts edges AFTER
    // the initial start edge.
    // ------------------------------------------
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
            check(0, "Done is low after nonzero start");

            @(negedge clk);
            start = 0;

            for (i = 1; i <= expected_cycles; i = i + 1) begin
                @(posedge clk);
                #1;

                if (i < expected_cycles)
                    check(0, "Done remains low before target");
                else
                    check(1, test_name);
            end

            @(negedge clk);
            start = 0;

            @(posedge clk);
            #1;
            check(0, "Done clears after completion");
        end
    endtask

    // ------------------------------------------
    // TARGET ZERO TEST
    // Target zero completes on the start edge.
    // ------------------------------------------
    task run_zero_target;
        begin
            @(negedge clk);
            target = 0;
            start = 1;

            @(posedge clk);
            #1;
            check(1, "Target zero completes immediately");

            // Keep start asserted: done stays high.
            @(negedge clk);

            @(posedge clk);
            #1;
            check(1, "Target zero remains done while start is high");

            // Release start.
            @(negedge clk);
            start = 0;

            @(posedge clk);
            #1;
            check(0, "Target zero done clears after start release");
        end
    endtask

    // ==========================================
    // MAIN TEST SEQUENCE
    // ==========================================
    initial begin
        clk = 0;
        start = 0;
        rst_n = 0;
        target = 0;

        $display("==========================================");
        $display(" GENERIC TIMER SELF-CHECKING TESTBENCH");
        $display("==========================================");

        // --------------------------------------
        // 1. Initial reset
        // --------------------------------------
        repeat (2) @(posedge clk);
        #1;
        check(0, "Initial reset");

        // Start must be ignored during reset.
        @(negedge clk);
        start = 1;
        target = 32;

        repeat (2) @(posedge clk);
        #1;
        check(0, "Start ignored during reset");

        @(negedge clk);
        start = 0;
        rst_n = 1;

        // --------------------------------------
        // 2. Normal target values
        // --------------------------------------
        run_timer(1,   1,   "Target 1");
        run_timer(9,   9,   "Target 9");
        run_timer(25,  25,  "Target 25");
        run_timer(32,  32,  "Target 32");
        run_timer(10,  10,  "Target 10");
        run_timer(8,   8,   "Target 8");
        run_timer(3,   3,   "Target 3");
        run_timer(255, 255, "Maximum target 255");

        // --------------------------------------
        // 3. Target zero
        // --------------------------------------
        run_zero_target();

        // --------------------------------------
        // 4. Reset during active counting
        // --------------------------------------
        reset_timer();

        @(negedge clk);
        target = 10;
        start = 1;

        @(posedge clk);
        #1;
        check(0, "Reset test timer started");

        @(negedge clk);
        start = 0;

        repeat (3) @(posedge clk);
        #1;
        check(0, "Timer still counting before reset");

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

        // --------------------------------------
        // 5. Start held high
        // --------------------------------------
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
        check(0, "Timer counts after held start release");

        @(posedge clk);
        #1;
        check(1, "Held start timer completes after release");

        @(negedge clk);
        start = 0;

        // --------------------------------------
        // 6. Restart while timer is counting
        // --------------------------------------
        reset_timer();

        @(negedge clk);
        target = 8;
        start = 1;

        @(posedge clk);
        #1;
        check(0, "Initial timer started for restart test");

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

        // --------------------------------------
        // 7. Change target during counting
        // --------------------------------------
        reset_timer();

        @(negedge clk);
        target = 8;
        start = 1;

        @(posedge clk);
        #1;
        check(0, "Timer started for target-change test");

        @(negedge clk);
        start = 0;

        repeat (2) @(posedge clk);

        @(negedge clk);
        target = 4;

        @(posedge clk);
        #1;
        check(0, "Changed target not reached yet");

        @(posedge clk);
        #1;
        check(1, "Changed target completes at 4");

        // --------------------------------------
        // 8. Final summary
        // --------------------------------------
        $display("");
        $display("==========================================");
        $display(" TEST SUMMARY");
        $display("==========================================");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("OVERALL RESULT: PASS");
        else
            $display("OVERALL RESULT: FAIL");

        $display("==========================================");

        $finish;
    end

endmodule
