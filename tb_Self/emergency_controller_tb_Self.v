`timescale 1ns / 1ps

module emergency_controller_tb_Self;

    parameter HOLD_CYCLES = 7;
    parameter WIDTH = 3;

    reg clk;
    reg rst_n;
    reg emergency_in;

    wire emergency_active;

    integer pass_count;
    integer fail_count;
    integer i;

    emergency_controller #(
        .HOLD_CYCLES(HOLD_CYCLES),
        .width(WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .emergency_in(emergency_in),
        .emergency_active(emergency_active)
    );

    always #10 clk = ~clk;

    // Check expected emergency_active value
    task check_output;
        input expected;
        input [255:0] test_name;
        begin
            if (emergency_active === expected) begin
                $display("PASS: %0s | emergency_active=%b | time=%0t",
                         test_name, emergency_active, $time);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: %0s | expected=%b, actual=%b | time=%0t",
                         test_name, expected, emergency_active, $time);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Wait for a rising edge and allow nonblocking assignments to settle
    task next_cycle;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        emergency_in = 0;
        pass_count = 0;
        fail_count = 0;

        $display("----------------------------------------");
        $display(" EMERGENCY CONTROLLER SELF-CHECKING TB");
        $display("----------------------------------------");

        // Test 1: Reset
        #1;
        check_output(1'b0, "Initial reset");
        repeat (2) next_cycle;
        rst_n = 1;
        next_cycle;
        check_output(1'b0, "Inactive after reset release");

        // Test 2: Short emergency pulse
        // One-cycle input should activate and hold the output
        emergency_in = 1;
        next_cycle;
        check_output(1'b1, "Short emergency activates output");
        emergency_in = 0;

        // The controller keeps active high for the configured hold period.
        // After the activation edge, seven low-input clock edges are needed
        // for the output to clear with the supplied RTL.
        for (i = 1; i <= HOLD_CYCLES - 1; i = i + 1) begin
            next_cycle;
            check_output(1'b1, "Emergency hold interval");
        end
        next_cycle;
        check_output(1'b0, "Output clears after hold interval");

        // Test 3: Long emergency input
        emergency_in = 1;
        repeat (3) next_cycle;
        check_output(1'b1, "Long emergency remains active");
        emergency_in = 0;

        // A new low-input hold interval begins after the input is removed.
        repeat (HOLD_CYCLES - 1) next_cycle;
        check_output(1'b1, "Long emergency hold interval");
        next_cycle;
        check_output(1'b0, "Long emergency eventually clears");

        // Test 4: Emergency held high
        emergency_in = 1;
        repeat (HOLD_CYCLES + 3) next_cycle;
        check_output(1'b1, "Output remains active while input is high");
        emergency_in = 0;
        repeat (HOLD_CYCLES - 1) next_cycle;
        check_output(1'b1, "Hold after sustained emergency");
        next_cycle;
        check_output(1'b0, "Sustained emergency eventually clears");

        // Test 5: Repeated emergency events
        emergency_in = 1;
        next_cycle;
        check_output(1'b1, "First repeated emergency");
        emergency_in = 0;
        repeat (2) next_cycle;

        emergency_in = 1;
        next_cycle;
        check_output(1'b1, "Second emergency reactivates/extends output");
        emergency_in = 0;

        repeat (HOLD_CYCLES - 1) next_cycle;
        check_output(1'b1, "Repeated emergency hold interval");
        next_cycle;
        check_output(1'b0, "Repeated emergency eventually clears");

        // Test 6: Reset during emergency
        emergency_in = 1;
        next_cycle;
        check_output(1'b1, "Active before reset");

        #2 rst_n = 0;
        #1;
        check_output(1'b0, "Asynchronous reset clears output");
        emergency_in = 0;

        repeat (2) next_cycle;
        check_output(1'b0, "Output remains cleared during reset");

        rst_n = 1;
        next_cycle;
        check_output(1'b0, "Inactive after second reset release");

        // Test 7: Emergency after reset
        emergency_in = 1;
        next_cycle;
        check_output(1'b1, "Emergency activates after reset");
        emergency_in = 0;

        repeat (HOLD_CYCLES - 1) next_cycle;
        check_output(1'b1, "Post-reset hold interval");
        next_cycle;
        check_output(1'b0, "Post-reset emergency clears");

        // Test 8: Idle operation
        repeat (3) next_cycle;
        check_output(1'b0, "Idle output remains inactive");

        $display("----------------------------------------");
        $display("TOTAL PASS: %0d", pass_count);
        $display("TOTAL FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED");

        $display("----------------------------------------");
        $finish;
    end

endmodule

