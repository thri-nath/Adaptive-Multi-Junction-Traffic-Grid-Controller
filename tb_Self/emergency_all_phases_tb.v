
`timescale 1ns / 1ps

module emergency_all_phases_tb;

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
    integer tests_passed;

    localparam RED        = 3'b001;
    localparam S_NS_GREEN = 4'b0000;
    localparam S_NS_YELLOW= 4'b0001;
    localparam S_EW_GREEN = 4'b0011;
    localparam S_EW_YELLOW= 4'b0100;
    localparam S_PED      = 4'b0110;
    localparam S_EMERGENCY= 4'b1000;

    traffic_system_top #(
        .GREEN_WAVE_DELAY(7)
    ) dut (
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

    // Wait until junction A reaches the requested phase.
    task wait_for_phase;
        input [3:0] target_state;
        input [255:0] phase_name;
        integer i;
        begin
            i = 0;
            while ((dut.junction_A.state !== target_state)
                   && (i < 300)) begin
                @(negedge clk);
                i = i + 1;
            end

            if (dut.junction_A.state !== target_state) begin
                $display("FAIL: Timeout waiting for %0s",
                         phase_name);
                errors = errors + 1;
            end
            else begin
                $display("INFO: Reached %0s at cycle %0d",
                         phase_name, i);
            end
        end
    endtask

    // Check emergency response in the selected phase.
    task emergency_test;
        input [3:0] target_state;
        input [255:0] phase_name;
        integer i;
        reg reached_emergency_A;
        reg reached_emergency_B;
        reg safety_ok;
        begin
            wait_for_phase(target_state, phase_name);

            if (dut.junction_A.state === target_state) begin
                // Assert emergency long enough for input synchronization.
                @(negedge clk);
                emergency_in = 1'b1;

                repeat (3) @(negedge clk);
                emergency_in = 1'b0;

                reached_emergency_A = 1'b0;
                reached_emergency_B = 1'b0;
                safety_ok = 1'b0;

                // Allow yellow clearance and emergency transitions.
                for (i = 0; i < 40; i = i + 1) begin
                    @(negedge clk);

                    if (dut.junction_A.state == S_EMERGENCY)
                        reached_emergency_A = 1'b1;

                    if (dut.junction_B.state == S_EMERGENCY)
                        reached_emergency_B = 1'b1;

                    if (light_A_NS === RED &&
                        light_A_EW === RED &&
                        light_B_NS === RED &&
                        light_B_EW === RED &&
                        ped_walk_A === 2'b00 &&
                        ped_walk_B === 2'b00 &&
                        reached_emergency_A &&
                        reached_emergency_B) begin
                        safety_ok = 1'b1;
                        i = 40;
                    end
                end

                if (safety_ok) begin
                    $display(
                        "PASS: %0s -> both junctions emergency/all-red; pedestrian walks clear",
                        phase_name
                    );
                    tests_passed = tests_passed + 1;
                end
                else begin
                    $display(
                        "FAIL: %0s emergency response. A state=%b B state=%b lights A(NS,EW)=%b,%b B(NS,EW)=%b,%b ped A=%b B=%b",
                        phase_name,
                        dut.junction_A.state,
                        dut.junction_B.state,
                        light_A_NS, light_A_EW,
                        light_B_NS, light_B_EW,
                        ped_walk_A, ped_walk_B
                    );
                    errors = errors + 1;
                end

                // Wait for the emergency hold period to finish.
                i = 0;
                while (emergency_active && i < 30) begin
                    @(negedge clk);
                    i = i + 1;
                end

                // Verify normal operation resumes on both FSMs.
                i = 0;
                while ((dut.junction_A.state == S_EMERGENCY ||
                        dut.junction_B.state == S_EMERGENCY) &&
                       i < 20) begin
                    @(negedge clk);
                    i = i + 1;
                end

                if (!emergency_active &&
                    dut.junction_A.state != S_EMERGENCY &&
                    dut.junction_B.state != S_EMERGENCY) begin
                    $display("PASS: %0s recovery; normal FSM operation resumed",
                             phase_name);
                    tests_passed = tests_passed + 1;
                end
                else begin
                    $display("FAIL: %0s recovery failed", phase_name);
                    errors = errors + 1;
                end

                // Leave time for the FSMs to restart their sequence.
                repeat (2) @(negedge clk);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        emergency_in = 0;

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
        tests_passed = 0;

        $display("----------------------------------------------");
        $display(" EMERGENCY ALL-PHASE SELF-CHECKING TESTBENCH");
        $display("----------------------------------------------");

        repeat (5) @(negedge clk);
        rst_n = 1;
        repeat (5) @(negedge clk);

        // Test 1: NS Green
        emergency_test(S_NS_GREEN, "NS GREEN");

        // Test 2: NS Yellow
        emergency_test(S_NS_YELLOW, "NS YELLOW");

        // Test 3: EW Green
        emergency_test(S_EW_GREEN, "EW GREEN");

        // Test 4: EW Yellow
        emergency_test(S_EW_YELLOW, "EW YELLOW");

        // Request a pedestrian crossing and wait for walk phase.
        // Requests are synchronized inside the top module.
        ped_req_A_NS = 1'b1;
        ped_req_B_NS = 1'b1;

        wait_for_phase(S_PED, "PEDESTRIAN WALK");

        if (dut.junction_A.state == S_PED) begin
            // Ensure the walk output has become active before interruption.
            repeat (2) @(negedge clk);

            if (ped_walk_A == 2'b00 &&
                ped_walk_B == 2'b00) begin
                $display("WARNING: Pedestrian phase reached but no walk output observed");
            end

            emergency_test(S_PED, "PEDESTRIAN WALK");
        end

        ped_req_A_NS = 0;
        ped_req_B_NS = 0;

        $display("----------------------------------------------");
        $display(" TESTS PASSED : %0d", tests_passed);
        $display(" ERRORS       : %0d", errors);
        $display("----------------------------------------------");

        if (errors == 0)
            $display("REGRESSION RESULT: PASS");
        else
            $display("REGRESSION RESULT: FAIL");

        $finish;
    end

    initial begin
        #200000;
        $display("FAIL: GLOBAL TESTBENCH TIMEOUT");
        $finish;
    end

endmodule
