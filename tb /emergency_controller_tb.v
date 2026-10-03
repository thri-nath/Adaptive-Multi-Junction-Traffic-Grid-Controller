`timescale 1ns / 1ps

module emergency_controller_tb;

    parameter HOLD_CYCLES = 7;
    parameter WIDTH = 3;

    reg clk;
    reg rst_n;
    reg emergency_in;

    wire emergency_active;

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

    initial begin
        $monitor(
            "TIME=%0t | rst_n=%b | emergency_in=%b | emergency_active=%b | count=%0d",
            $time,
            rst_n,
            emergency_in,
            emergency_active,
            dut.count
        );
    end

    initial begin

        clk = 0;
        rst_n = 0;
        emergency_in = 0;

        // Test 1: Reset
        #40;
        rst_n = 1;
        #40;

        // Test 2: Short emergency pulse
        #20;
        emergency_in = 1;
        #20;
        emergency_in = 0;
        #160;

        // Test 3: Long emergency
        #20;
        emergency_in = 1;
        #100;
        emergency_in = 0;
        #160;

        // Test 4: Emergency held high
        #20;
        emergency_in = 1;
        #300;
        emergency_in = 0;
        #160;

        // Test 5: Repeated emergency
        emergency_in = 1;
        #20;
        emergency_in = 0;
        #60;
        emergency_in = 1;
        #20;
        emergency_in = 0;
        #200;

        // Test 6: Reset during emergency
        emergency_in = 1;
        #40;
        rst_n = 0;
        #40;
        rst_n = 1;
        emergency_in = 0;
        #60;

        // Test 7: Emergency after reset
        emergency_in = 1;
        #40;
        emergency_in = 0;
        #160;

        // Test 8: Idle
        emergency_in = 0;
        #100;

        $display("ALL TESTS COMPLETED");
        $finish;

    end

endmodule
