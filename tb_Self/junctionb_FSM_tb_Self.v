

module junctionb_FSM_tb_Self;

 

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

    integer errors;
    integer checks;

    reg green_wave_seen;
    reg ped_done_seen;

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

    // Junction B: slave mode
    junction_fsm #(
        .IS_MASTER(0),
        .MIN_GREEN(5),
        .MAX_GREEN(10),
        .GREEN_EXTENSION(1),
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

    // 20 ns clock period
    always #10 clk = ~clk;

    // Record pulses that may occur between test checkpoints
    always @(posedge clk) begin
        if (!rst_n) begin
            green_wave_seen = 0;
            ped_done_seen = 0;
        end
        else begin
            if (green_wave_out)
                green_wave_seen = 1;

            if (ped_done)
                ped_done_seen = 1;
        end
    end

    // PASS/FAIL checker
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

    // Wait for a state with a bounded timeout
    task wait_for_state;
        input [3:0] expected_state;
        input integer max_cycles;
        input [8*120-1:0] message;

        integer i;
        reg found;

        begin
            found = 0;

            begin : WAIT_LOOP
                for (i = 0; i < max_cycles; i = i + 1) begin
                    @(negedge clk);

                    if (state === expected_state) begin
                        found = 1;
                        disable WAIT_LOOP;
                    end
                end
            end

            check(found, message);
        end
    endtask

    // Allow registered outputs to update after a state transition
    task settle_outputs;
        begin
            @(negedge clk);
        end
    endtask

    // Reset DUT and clear all input stimuli
    task reset_dut;
        begin
            @(negedge clk);
            rst_n = 0;

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
                  "Reset sets both directions red");

            check(ped_walk == 0 && ped_done == 0,
                  "Reset clears pedestrian outputs");

            check(green_wave_out == 0,
                  "Reset clears green-wave output");

            rst_n = 1;
            repeat (2) @(negedge clk);
        end
    endtask

    // Independent traffic-light safety monitor
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

        errors = 0;
        checks = 0;
        green_wave_seen = 0;
        ped_done_seen = 0;

        $display("");
        $display("============================================");
        $display(" JUNCTION B FSM SELF-CHECKING REGRESSION");
        $display(" Slave mode: IS_MASTER = 0");
        $display("============================================");

        // TEST 1: Reset
        $display("\nTEST 1: Reset");
        reset_dut();

        // TEST 2: Slave synchronization
        $display("\nTEST 2: Green-wave synchronization");

        wait_for_state(S_WAIT_SYNC, 15,
                       "Slave enters synchronization wait");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Both directions red while waiting for synchronization");

        @(negedge clk);
        green_wave_trigger = 1;

        @(negedge clk);
        green_wave_trigger = 0;

        wait_for_state(S_NS_GREEN, 5,
                       "Green-wave trigger releases slave");

        settle_outputs();

        check(light_NS == GREEN && light_EW == RED,
              "NS green after synchronization trigger");

        check(green_wave_seen,
              "Green-wave output pulse observed");

        // TEST 3: Traffic sequencing and density
        $display("\nTEST 3: Traffic sequencing and density");

        traffic_density_NS = 3'd0;
        traffic_density_EW = 3'd7;

        // Allow the current NS green phase to complete.
        wait_for_state(S_NS_YELLOW, 15,
                       "NS green transitions to yellow");

        settle_outputs();

        check(light_NS == YELLOW && light_EW == RED,
              "NS yellow output is correct");

        wait_for_state(S_AR_NS2EW, 10,
                       "All-red before EW green");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "All-red transition is safe");

        wait_for_state(S_EW_GREEN, 10,
                       "FSM enters EW green");

        settle_outputs();

        check(light_NS == RED && light_EW == GREEN,
              "EW green output is correct");

        check(dut.phase_target == 10,
              "EW maximum density is clamped to MAX_GREEN");

        wait_for_state(S_EW_YELLOW, 15,
                       "EW green transitions to yellow");

        settle_outputs();

        check(light_NS == RED && light_EW == YELLOW,
              "EW yellow output is correct");

        wait_for_state(S_AR_EW2NS, 10,
                       "All-red before NS decision");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Both directions red before synchronization");

        // TEST 4: Trigger synchronization again
        $display("\nTEST 4: Synchronization recovery");

        wait_for_state(S_WAIT_SYNC, 10,
                       "Slave waits for next green-wave trigger");

        @(negedge clk);
        green_wave_trigger = 1;

        @(negedge clk);
        green_wave_trigger = 0;

        wait_for_state(S_NS_GREEN, 5,
                       "Slave returns to NS green");

        // TEST 5: Pedestrian request and grant
        $display("\nTEST 5: Pedestrian service");

        // Latch request before reaching the all-red decision.
        @(negedge clk);
        ped_req = 2'b01;

        wait_for_state(S_EW_GREEN, 20,
                       "Reach EW green before pedestrian service");

        wait_for_state(S_EW_YELLOW, 15,
                       "EW transitions to yellow");

        wait_for_state(S_AR_EW2NS, 10,
                       "Reach all-red pedestrian decision");

        // Keep grant active so it is present at the decision edge.
        @(negedge clk);
        ped_grant = 1;

        wait_for_state(S_PED, 5,
                       "Granted request enters pedestrian state");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Both vehicle directions red during pedestrian phase");

        check(ped_walk == 2'b01,
              "Requested pedestrian crossing receives walk");

        @(negedge clk);
        ped_req = 0;
        ped_grant = 0;

        begin : PED_COMPLETION_WAIT
            integer i;
            reg found_done;

            found_done = 0;

            begin : DONE_LOOP
                for (i = 0; i < 8; i = i + 1) begin
                    @(negedge clk);

                    if (ped_done_seen || ped_done) begin
                        found_done = 1;
                        disable DONE_LOOP;
                    end
                end
            end

            check(found_done,
                  "Pedestrian completion pulse observed");
        end

        // TEST 6: Emergency activation
        $display("\nTEST 6: Emergency handling");

        wait_for_state(S_NS_GREEN, 10,
                       "Traffic resumes after pedestrian phase");

        @(negedge clk);
        emergency_active = 1;

        wait_for_state(S_NS_YELLOW, 5,
                       "Emergency causes NS green to turn yellow");

        wait_for_state(S_EMERGENCY, 10,
                       "FSM enters emergency state");

        settle_outputs();

        check(light_NS == RED && light_EW == RED,
              "Emergency state holds both directions red");

        check(ped_walk == 0,
              "Emergency state clears pedestrian walk");

        @(negedge clk);
        emergency_active = 0;

        wait_for_state(S_AR_EW2NS, 10,
                       "Emergency release returns to all-red");

        // TEST 7: Density calculation across several values
        $display("\nTEST 7: Density calculation");

        // Density 2: MIN_GREEN + 2*GREEN_EXTENSION = 7
        traffic_density_NS = 2;
        traffic_density_EW = 3;

        wait_for_state(S_WAIT_SYNC, 10,
                       "Slave enters synchronization wait");

        @(negedge clk);
        green_wave_trigger = 1;

        @(negedge clk);
        green_wave_trigger = 0;

        wait_for_state(S_NS_GREEN, 5,
                       "NS green begins after trigger");

        check(dut.phase_target == 7,
              "NS density 2 selects green target 7");

        // TEST 8: Reset during operation
        $display("\nTEST 8: Reset during operation");

        reset_dut();

        check(ped_walk == 0 && ped_done == 0,
              "Pedestrian outputs cleared after operational reset");

        // TEST 9: Post-reset synchronization
        $display("\nTEST 9: Operation after reset");

        wait_for_state(S_WAIT_SYNC, 10,
                       "Slave returns to synchronization wait");

        @(negedge clk);
        traffic_density_NS = 7;
        green_wave_trigger = 1;

        @(negedge clk);
        green_wave_trigger = 0;

        wait_for_state(S_NS_GREEN, 5,
                       "NS green resumes after reset");

        check(dut.phase_target == 10,
              "Post-reset density target clamps at MAX_GREEN");

        // FINAL SUMMARY
        $display("");
        $display("============================================");
        $display(" REGRESSION SUMMARY");
        $display(" Checks performed: %0d", checks);
        $display(" Errors detected : %0d", errors);

        if (errors == 0)
            $display(" RESULT: ALL CHECKS PASSED");
        else
            $display(" RESULT: REGRESSION FAILED");

        $display("============================================");

        #20;
        $finish;
    end

    // Global watchdog
    initial begin
        #30000;
        $display("FAIL: Global simulation timeout");
        $finish;
    end

endmodule
