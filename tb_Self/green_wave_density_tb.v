
`timescale 1ns/1ps

module green_wave_density_tb;

    reg clk;
    reg rst_n;
    reg emergency_in;

    reg sens_A_NS, sens_A_EW;
    reg sens_B_NS, sens_B_EW;

    reg [2:0] traffic_density_A_NS;
    reg [2:0] traffic_density_A_EW;
    reg [2:0] traffic_density_B_NS;
    reg [2:0] traffic_density_B_EW;

    reg ped_req_A_NS, ped_req_A_EW;
    reg ped_req_B_NS, ped_req_B_EW;

    wire [2:0] light_A_NS, light_A_EW;
    wire [2:0] light_B_NS, light_B_EW;
    wire [1:0] ped_walk_A, ped_walk_B;
    wire emergency_active;

    integer errors;
    integer test_count;

    localparam GREEN = 3'b100;

    // State encodings from junction_fsm.
    localparam S_NS_GREEN = 4'b0000;

    traffic_system_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .emergency_in(emergency_in),

        .sens_A_NS(sens_A_NS),
        .sens_A_EW(sens_A_EW),
        .sens_B_NS(sens_B_NS),
        .sens_B_EW(sens_B_EW),

        .traffic_density_A_NS(traffic_density_A_NS),
        .traffic_density_A_EW(traffic_density_A_EW),
        .traffic_density_B_NS(traffic_density_B_NS),
        .traffic_density_B_EW(traffic_density_B_EW),

        .ped_req_A_NS(ped_req_A_NS),
        .ped_req_A_EW(ped_req_A_EW),
        .ped_req_B_NS(ped_req_B_NS),
        .ped_req_B_EW(ped_req_B_EW),

        .light_A_NS(light_A_NS),
        .light_A_EW(light_A_EW),
        .light_B_NS(light_B_NS),
        .light_B_EW(light_B_EW),

        .ped_walk_A(ped_walk_A),
        .ped_walk_B(ped_walk_B),
        .emergency_active(emergency_active)
    );

    always #10 clk = ~clk;

    // Check one density combination.
    // Expected duration = MIN_GREEN + density * GREEN_EXTENSION,
    // limited to MAX_GREEN.
    task run_density_test;
        input integer test_id;
        input [2:0] density_A;
        input [2:0] density_B;
        input integer expected_A_cycles;

        integer timeout;
        integer green_cycles;
        integer cycle;
        integer b_timeout;
        reg b_green_seen;

        begin
            $display("");
            $display("----------------------------------------");
            $display("Density test %0d", test_id);
            $display("A NS density = %0d", density_A);
            $display("B NS density = %0d", density_B);
            $display("Expected A green duration = %0d cycles",
                     expected_A_cycles);

            // Reset between test cases.
            @(negedge clk);
            rst_n = 1'b0;
            emergency_in = 1'b0;

            traffic_density_A_NS = density_A;
            traffic_density_B_NS = density_B;
            traffic_density_A_EW = 3'd0;
            traffic_density_B_EW = 3'd0;

            sens_A_NS = 1'b0;
            sens_A_EW = 1'b0;
            sens_B_NS = 1'b0;
            sens_B_EW = 1'b0;

            ped_req_A_NS = 1'b0;
            ped_req_A_EW = 1'b0;
            ped_req_B_NS = 1'b0;
            ped_req_B_EW = 1'b0;

            repeat (4) @(posedge clk);
            @(negedge clk);
            rst_n = 1'b1;

            // Wait for Junction A's NS green output.
            timeout = 0;
            while ((light_A_NS !== GREEN) && (timeout < 200)) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
            end

            if (light_A_NS !== GREEN) begin
                errors = errors + 1;
                $display("FAIL: A NS green was not reached");
            end
            else begin
                $display("INFO: A NS green observed at %0t", $time);

                // Count consecutive clock samples with NS green.
                green_cycles = 0;
                cycle = 0;

                while ((light_A_NS === GREEN) && (cycle < 100)) begin
                    green_cycles = green_cycles + 1;
                    @(posedge clk);
                    #1;
                    cycle = cycle + 1;
                end

                $display("Measured A NS green = %0d cycles",
                         green_cycles);

                // Allow +/- 2 cycles for registered-output timing.
                if ((green_cycles >= expected_A_cycles - 2) &&
                    (green_cycles <= expected_A_cycles + 2)) begin
                    test_count = test_count + 1;
                    $display("PASS: A green duration is within tolerance");
                end
                else begin
                    errors = errors + 1;
                    $display("FAIL: Expected %0d +/- 2 cycles; measured %0d",
                             expected_A_cycles, green_cycles);
                end
            end

            // Also observe whether Junction B reaches NS green.
            // This observation alone does not prove the exact
            // seven-cycle green-wave delay.
            b_green_seen = 1'b0;
            b_timeout = 0;

            while ((b_timeout < 200) && !b_green_seen) begin
                @(posedge clk);
                #1;
                b_timeout = b_timeout + 1;

                if (light_B_NS === GREEN)
                    b_green_seen = 1'b1;
            end

            if (b_green_seen) begin
                $display("INFO: Junction B NS green observed");
            end
            else begin
                errors = errors + 1;
                $display("FAIL: Junction B NS green not observed");
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        emergency_in = 1'b0;

        sens_A_NS = 0;
        sens_A_EW = 0;
        sens_B_NS = 0;
        sens_B_EW = 0;

        traffic_density_A_NS = 0;
        traffic_density_A_EW = 0;
        traffic_density_B_NS = 0;
        traffic_density_B_EW = 0;

        ped_req_A_NS = 0;
        ped_req_A_EW = 0;
        ped_req_B_NS = 0;
        ped_req_B_EW = 0;

        errors = 0;
        test_count = 0;

        $display("========================================");
        $display(" GREEN-WAVE DENSITY SELF-CHECKING TEST");
        $display("========================================");

        // MIN_GREEN=10, GREEN_EXTENSION=4, MAX_GREEN=30.
        // Expected duration = min(10 + density*4, 30).

        run_density_test(1, 3'd0, 3'd0, 10);
        run_density_test(2, 3'd1, 3'd2, 14);
        run_density_test(3, 3'd2, 3'd1, 18);
        run_density_test(4, 3'd4, 3'd3, 26);
        run_density_test(5, 3'd7, 3'd5, 30);

        $display("");
        $display("========================================");
        $display("Density duration checks passed: %0d/5",
                 test_count);
        $display("Total errors: %0d", errors);

        if (errors == 0)
            $display("GREEN-WAVE DENSITY TEST: PASS");
        else
            $display("GREEN-WAVE DENSITY TEST: FAIL");

        $display("========================================");
        $finish;
    end

    initial begin
        #300000;
        $display("FAIL: Global simulation timeout");
        $finish;
    end

endmodule
