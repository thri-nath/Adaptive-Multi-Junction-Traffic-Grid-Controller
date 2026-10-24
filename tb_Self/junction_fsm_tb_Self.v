`timescale 1ns/1ps

module junction_fsm_tb_Self;

    reg clk, rst_n;
    reg sens_NS, sens_EW;
    reg [2:0] traffic_density_NS, traffic_density_EW;
    reg [1:0] ped_req;
    reg ped_grant;
    reg green_wave_trigger, emergency_active;

    wire [2:0] light_NS, light_EW;
    wire green_wave_out;
    wire [1:0] ped_walk;
    wire ped_done;
    wire [3:0] state;

    integer errors = 0;
    integer checks = 0;
    reg green_wave_seen = 0;

    localparam S_NS_GREEN  = 4'b0000;
    localparam S_NS_YELLOW = 4'b0001;
    localparam S_AR_NS2EW  = 4'b0010;
    localparam S_EW_GREEN  = 4'b0011;
    localparam S_EW_YELLOW = 4'b0100;
    localparam S_AR_EW2NS  = 4'b0101;
    localparam S_PED       = 4'b0110;
    localparam S_WAIT_SYNC = 4'b0111;
    localparam S_EMERGENCY = 4'b1000;

    localparam RED    = 3'b001;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b100;

    // Short simulation timings
    junction_fsm #(
        .IS_MASTER(1),
        .MIN_GREEN(5),
        .MAX_GREEN(10),
        .GREEN_EXTENSION(2),
        .YELLOW_TIME(2),
        .ALL_RED_TIME(2),
        .PED_TIME(3),
        .SYNC_TIMEOUT(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .sens_NS(sens_NS),
        .sens_EW(sens_EW),
        .traffic_density_NS(traffic_density_NS),
        .traffic_density_EW(traffic_density_EW),
        .ped_req(ped_req),
        .ped_grant(ped_grant),
        .green_wave_trigger(green_wave_trigger),
        .emergency_active(emergency_active),
        .light_NS(light_NS),
        .light_EW(light_EW),
        .green_wave_out(green_wave_out),
        .ped_walk(ped_walk),
        .ped_done(ped_done),
        .state(state)
    );

    always #10 clk = ~clk;

    // Observe the green-wave pulse
    always @(posedge clk) begin
        if (rst_n && green_wave_out)
            green_wave_seen = 1'b1;
    end

    // Common PASS/FAIL checker
    task check;
        input condition;
        input [8*120-1:0] message;
        begin
            checks = checks + 1;
            if (condition === 1'b1)
                $display("PASS: %0s", message);
            else begin
                errors = errors + 1;
                $display("FAIL: %0s | state=%b NS=%b EW=%b",
                         message, state, light_NS, light_EW);
            end
        end
    endtask

    // Wait for a state, but never longer than max_cycles
    task wait_for_state;
        input [3:0] expected_state;
        input integer max_cycles;
        input [8*120-1:0] message;

        integer i;
        reg found;

        begin
            found = 1'b0;

            begin : WAIT_LOOP
                for (i = 0; i < max_cycles; i = i + 1) begin
                    @(negedge clk);

                    if (state === expected_state) begin
                        found = 1'b1;
                        disable WAIT_LOOP;
                    end
                end
            end

            check(found, message);
        end
    endtask

    // Allow registered light outputs to settle after a state change
    task settle_outputs;
        begin
            @(negedge clk);
        end
    endtask

    // Reset and check initial outputs
    task reset_dut;
        begin
            @(negedge clk);
            rst_n = 1'b0;

            sens_NS = 0;
            sens_EW = 0;
            traffic_density_NS = 0;
            traffic_density_EW = 0;
            ped_req = 0;
            ped_grant = 0;
            green_wave_trigger = 0;
            emergency_active = 0;

            repeat (3) @(negedge clk);

            check(state == S_AR_EW2NS,
                  "Reset selects initial all-red state");

            check(light_NS == RED && light_EW == RED,
                  "Reset sets both lights to red");

            check(ped_walk == 2'b00 && ped_done == 1'b0,
                  "Reset clears pedestrian outputs");

            check(green_wave_out == 1'b0,
                  "Reset clears green-wave output");

            rst_n = 1'b1;
            repeat (2) @(negedge clk);
        end
    endtask

    // Independent safety monitor
    always @(negedge clk) begin
        if (rst_n === 1'b1) begin

            if ((light_NS === GREEN) &&
                (light_EW === GREEN)) begin
                errors = errors + 1;
                $display("FAIL: Both directions green simultaneously");
            end

            if ((^light_NS === 1'bx) ||
                (^light_EW === 1'bx)) begin
                errors = errors + 1;
                $display("FAIL: Unknown traffic-light output");
            end
        end
    end

    initial begin
        clk = 0;
        rst_n = 0;

        sens_NS = 0;
        sens_EW = 0;
        traffic_density_NS = 0;
        traffic_density_EW = 0;
        ped_req = 0;
        ped_grant = 0;
        green_wave_trigger = 0;
        emergency_active = 0;

        $display("");
        $display("============================================");
        $display(" JUNCTION FSM SELF-CHECKING REGRESSION");
        $display("============================================");

        // TEST 1: Reset
        $display("\nTEST 1: Reset");
        reset_dut();

        // TEST 2: Normal traffic sequence and density
        $display("\nTEST 2: Traffic sequencing and density");

        // NS density = 3:
        // MIN_GREEN + density * GREEN_EXTENSION = 5 + 3*2 = 11
        // MAX_GREEN clamps this to 10.
        traffic_density_NS = 3'd3;
        traffic_density_EW = 3'd2;

        wait_for_state(S_NS_GREEN, 15,
                       "FSM enters NS green");

        settle_outputs();

        check(light_NS == GREEN && light_EW == RED,
              "NS green, EW red");

        check(dut.phase_target == 10,
              "NS green target is clamped to MAX_GREEN");

        wait_for_state(S_NS_YELLOW, 15,
                       "NS green transitions to NS yellow");

        settle_outputs();

        check(light_NS == YELLOW && light_EW == RED,
              "NS yellow, EW remains red");

        wait_for_state(S_AR_NS2EW, 10,
                       "All-red between NS and EW");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Both directions red during transition");

        wait_for_state(S_EW_GREEN, 10,
                       "FSM enters EW green");

        settle_outputs();

        check(light_NS == RED && light_EW == GREEN,
              "EW green, NS red");

        // EW density = 2: target = 5 + 2*2 = 9
        check(dut.phase_target == 9,
              "EW green target reflects traffic density");

        wait_for_state(S_EW_YELLOW, 15,
                       "EW green transitions to EW yellow");

        settle_outputs();

        check(light_NS == RED && light_EW == YELLOW,
              "EW yellow, NS remains red");

        wait_for_state(S_AR_EW2NS, 10,
                       "All-red before returning to NS");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Both directions red before NS resumes");

        wait_for_state(S_NS_GREEN, 15,
                       "FSM completes a full traffic cycle");

        settle_outputs();

        check(green_wave_seen,
              "Green-wave output pulse observed in master mode");

        check(state != S_WAIT_SYNC,
              "Master does not wait for slave synchronization");

        
        // TEST 3: Pedestrian request and grant
        $display("\nTEST 3: Pedestrian service");

        reset_dut();

        // Assert request early so it becomes pending.
        @(negedge clk);
        ped_req = 2'b01;
        ped_grant = 1'b0;

        // Wait until the FSM reaches the pedestrian decision point.
        wait_for_state(S_AR_EW2NS, 40,
                       "Reach all-red before pedestrian decision");

        // Keep request pending and grant service.
        @(negedge clk);
        ped_grant = 1'b1;

        wait_for_state(S_PED, 10,
                       "Granted pedestrian request enters PED state");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Both vehicle directions red during pedestrian phase");

        check(ped_walk == 2'b01,
              "Requested pedestrian crossing receives walk");

        // Release request and grant after entry.
        @(negedge clk);
        ped_req = 2'b00;
        ped_grant = 1'b0;

        begin : PED_DONE_WAIT
            integer i;
            reg done_seen;

            done_seen = 1'b0;

            for (i = 0; i < 8; i = i + 1) begin
                @(negedge clk);

                if (ped_done === 1'b1) begin
                    done_seen = 1'b1;
                    disable PED_DONE_WAIT;
                end
            end

            check(done_seen,
                  "Pedestrian completion pulse is generated");
        end

        wait_for_state(S_NS_GREEN, 10,
                       "Traffic resumes after pedestrian service");

        // TEST 4: Emergency handling
        $display("\nTEST 4: Emergency handling");

        @(negedge clk);
        emergency_active = 1'b1;

        wait_for_state(S_NS_YELLOW, 10,
                       "Emergency causes NS green to turn yellow");

        wait_for_state(S_EMERGENCY, 10,
                       "FSM enters emergency state");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Emergency state holds both directions red");

        check(ped_walk == 2'b00,
              "Emergency state clears pedestrian walk");

        @(negedge clk);
        emergency_active = 1'b0;

        wait_for_state(S_AR_EW2NS, 10,
                       "FSM returns to all-red after emergency");

        // TEST 5: Reset during operation
        $display("\nTEST 5: Reset during operation");

        wait_for_state(S_NS_GREEN, 10,
                       "Reach NS green before operational reset");

        reset_dut();

        check(ped_walk == 2'b00,
              "Pedestrian output remains clear after reset");

        // FINAL SUMMARY
               $display("----------------------------------------");
        $display("REGRESSION SUMMARY");
        $display("Checks performed: %0d", checks);
        $display("Errors detected : %0d", errors);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED");

        $display("----------------------------------------");

        #20;
        $finish;
    end

    // Global simulation watchdog
    initial begin
        #20000;
        $display("FAIL: Global simulation timeout");
        $finish;
    end

endmodule

