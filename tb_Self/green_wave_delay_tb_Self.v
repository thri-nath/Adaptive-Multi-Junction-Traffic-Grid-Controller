`timescale 1ns/1ps

module green_wave_delay_tb;

    reg clk;
    reg rst_n;
    reg pulse_in;
    reg clear;
    wire pulse_out;

    integer i;
    integer errors;
    integer cycle_count;
    reg detected;

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

    task start_delay;
        begin
            @(negedge clk);
            pulse_in = 1'b1;
            @(negedge clk);
            pulse_in = 1'b0;
        end
    endtask

    task clear_delay;
        begin
            @(negedge clk);
            clear = 1'b1;
            @(negedge clk);
            clear = 1'b0;
        end
    endtask

    task check_delay;
        begin
            detected = 0;
            cycle_count = 0;

            for (i = 1; i <= 12; i = i + 1) begin
                @(posedge clk);
                #1;
                cycle_count = i;

                if (pulse_out === 1'b1) begin
                    detected = 1;

                    if (i < 8) begin
                        $display("FAIL: Output arrived too early at cycle %0d", i);
                        errors = errors + 1;
                    end
                    else begin
                        $display("PASS: Output detected at cycle %0d", i);
                    end

                    i = 13;
                end
            end

            if (!detected) begin
                $display("FAIL: Output did not arrive within 12 cycles");
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        pulse_in = 0;
        clear = 0;
        errors = 0;
        detected = 0;
        cycle_count = 0;

        $display("-----------------------------------");
        $display(" GREEN WAVE DELAY TESTBENCH");
        $display("-----------------------------------");

        // Test 1: Reset
        repeat (2) @(posedge clk);
        #1;

        if (pulse_out === 1'b0)
            $display("PASS: Reset");
        else begin
            $display("FAIL: Reset");
            errors = errors + 1;
        end

        @(negedge clk);
        rst_n = 1'b1;

        // Test 2: Normal delay
        $display("TEST 2: Normal delay");
        start_delay();
        check_delay();

        // Test 3: Clear after output
        $display("TEST 3: Clear output");
        clear_delay();

        @(posedge clk);
        #1;

        if (pulse_out === 1'b0)
            $display("PASS: Clear resets output");
        else begin
            $display("FAIL: Output remains high after clear");
            errors = errors + 1;
        end

        // Test 4: Clear during an active delay
        $display("TEST 4: Clear during delay");
        start_delay();

        repeat (3) @(negedge clk);
        clear = 1'b1;

        @(posedge clk);
        #1;

        if (pulse_out === 1'b0)
            $display("PASS: Clear cancels pending output");
        else begin
            $display("FAIL: Output asserted during clear");
            errors = errors + 1;
        end

        @(negedge clk);
        clear = 1'b0;

        // Ensure no delayed output from the cancelled request
        repeat (10) begin
            @(posedge clk);
            #1;

            if (pulse_out !== 1'b0) begin
                $display("FAIL: Output appeared after cancellation");
                errors = errors + 1;
            end
        end

        // Test 5: Restart after clear
        $display("TEST 5: Restart after clear");
        start_delay();
        check_delay();

        // Final result
        $display("-----------------------------------");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d error(s)", errors);

        $display("-----------------------------------");

        $finish;
    end

endmodule