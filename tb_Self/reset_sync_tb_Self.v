
`timescale 1ns/1ps

module reset_sync_tb_Self;

    reg clk;
    reg rst_n_async;
    wire rst_n_sync;

    integer errors;

    // DUT instantiation
    reset_sync dut (
        .clk(clk),
        .rst_n_async(rst_n_async),
        .rst_n_sync(rst_n_sync)
    );

    // 20 ns clock period
    always #10 clk = ~clk;

    // Self-checking task
    task check_output;
        input expected;
        input [8*40-1:0] test_name;
        begin
            if (rst_n_sync !== expected) begin
                $display(
                    "FAIL: %0s | Expected=%b, Actual=%b at time %0t",
                    test_name, expected, rst_n_sync, $time
                );
                errors = errors + 1;
            end else begin
                $display(
                    "PASS: %0s | Output=%b at time %0t",
                    test_name, rst_n_sync, $time
                );
            end
        end
    endtask

    initial begin
        clk         = 0;
        rst_n_async = 0;
        errors      = 0;

        $display("----------------------------------------");
        $display(" RESET SYNC SELF-CHECKING TESTBENCH");
        $display("----------------------------------------");

        // TEST 1: Initial asynchronous reset assertion
        #1;
        check_output(1'b0, "Initial asynchronous reset");

        // TEST 2: Reset release
        // Release between clock edges
        #19;
        rst_n_async = 1;

        // First rising edge: sync_ff1 becomes 1
        @(posedge clk);
        #1;
        check_output(1'b0, "First clock after reset release");

        // Second rising edge: sync_ff2 becomes 1
        @(posedge clk);
        #1;
        check_output(1'b1, "Second clock after reset release");

        // TEST 3: Normal operation
        repeat (3) @(posedge clk);
        #1;
        check_output(1'b1, "Normal operation");

        // TEST 4: Asynchronous reset assertion
        // Assert reset between clock edges
        #5;
        rst_n_async = 0;
        #1;
        check_output(1'b0, "Asynchronous reset assertion");

        // TEST 5: Keep reset asserted
        repeat (2) @(posedge clk);
        #1;
        check_output(1'b0, "Reset held low");

        // TEST 6: Release reset again
        @(negedge clk);
        rst_n_async = 1;

        @(posedge clk);
        #1;
        check_output(1'b0, "Repeated release - first clock");

        @(posedge clk);
        #1;
        check_output(1'b1, "Repeated release - second clock");

        // TEST 7: Reset asserted again during operation
        #5;
        rst_n_async = 0;
        #1;
        check_output(1'b0, "Second asynchronous reset");

        // TEST 8: Final reset release
        @(negedge clk);
        rst_n_async = 1;

        @(posedge clk);
        #1;
        check_output(1'b0, "Final release - first clock");

        @(posedge clk);
        #1;
        check_output(1'b1, "Final release - second clock");

        // FINAL SUMMARY
        $display("----------------------------------------");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("TESTS FAILED: %0d error(s)", errors);
        end

        $display("----------------------------------------");

        $finish;
    end

endmodule
