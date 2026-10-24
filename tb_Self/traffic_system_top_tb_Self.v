`timescale 1ns / 1ps


module traffic_system_top_tb_Self;



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

    integer checks;
    integer errors;
    integer i;
    integer found;
    integer emergency_seen;
    integer pedestrian_seen;
    //for measuring the exact green-wave offset
    integer cycle_count;
integer cycle_A_NS_green;
integer cycle_B_NS_green;
integer measured_offset;

  localparam RED    = 3'b001;
localparam YELLOW = 3'b010;
localparam GREEN  = 3'b100;

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

    // Reusable self-checking task
    task check;
        input condition;
        input [8*100-1:0] message;
        begin
            checks = checks + 1;

            if (condition === 1'b1)
                $display("PASS: %0s | time=%0t", message, $time);
            else begin
                errors = errors + 1;
                $display("FAIL: %0s | time=%0t", message, $time);
            end
        end
    endtask

    // Wait for a specified number of clock cycles
    task wait_cycles;
        input integer cycles;
        integer k;
        begin
            for (k = 0; k < cycles; k = k + 1)
                @(posedge clk);
            #1;
        end
    endtask

    // Check that neither junction has conflicting green signals.
    // Also verify vehicle signals remain red during pedestrian walk.
   
task check_safety;
    begin
        if ((light_A_NS === GREEN) &&
            (light_A_EW === GREEN)) begin
            errors = errors + 1;
            checks = checks + 1;
            $display(
                "FAIL: Junction A conflicting greens: NS=%b EW=%b",
                light_A_NS, light_A_EW
            );
        end
        else begin
            checks = checks + 1;
            $display(
                "PASS: Junction A safety: NS=%b EW=%b",
                light_A_NS, light_A_EW
            );
        end

        if ((light_B_NS === GREEN) &&
            (light_B_EW === GREEN)) begin
            errors = errors + 1;
            checks = checks + 1;
            $display(
                "FAIL: Junction B conflicting greens: NS=%b EW=%b",
                light_B_NS, light_B_EW
            );
        end
        else begin
            checks = checks + 1;
            $display(
                "PASS: Junction B safety: NS=%b EW=%b",
                light_B_NS, light_B_EW
            );
        end

        if ((|ped_walk_A) === 1'b1) begin
            check(
                (light_A_NS === RED) &&
                (light_A_EW === RED),
                "Junction A vehicles red during pedestrian walk"
            );
        end

        if ((|ped_walk_B) === 1'b1) begin
            check(
                (light_B_NS === RED) &&
                (light_B_EW === RED),
                "Junction B vehicles red during pedestrian walk"
            );
        end
    end
endtask

    // Wait up to 100 clock cycles for a pedestrian walk indication.
    task wait_for_pedestrian_A;
        begin
            pedestrian_seen = 0;

            for (i = 0; i < 100; i = i + 1) begin
                @(posedge clk);
                #1;
                if (|ped_walk_A)
                    pedestrian_seen = 1;
            end

            check(
                pedestrian_seen == 1,
                "Pedestrian request at A receives walk indication"
            );
        end
    endtask

    task wait_for_pedestrian_B;
        begin
            pedestrian_seen = 0;

            for (i = 0; i < 100; i = i + 1) begin
                @(posedge clk);
                #1;
                if (|ped_walk_B)
                    pedestrian_seen = 1;
            end

            check(
                pedestrian_seen == 1,
                "Pedestrian request at B receives walk indication"
            );
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

        checks = 0;
        errors = 0;
        found = 0;
        emergency_seen = 0;
        pedestrian_seen = 0;
        cycle_count = 0;
cycle_A_NS_green = -1;
cycle_B_NS_green = -1;
measured_offset = -1;

        $display("");
        $display("============================================");
        $display(" TRAFFIC SYSTEM TOP SELF-CHECKING REGRESSION");
        $display("============================================");

        // TEST 1: Reset
        $display("");
        $display("TEST 1: Initial reset");

        wait_cycles(5);

        check(
            (light_A_NS === RED) && (light_A_EW === RED),
            "Junction A starts with both directions red"
        );

        check(
            (light_B_NS === RED) && (light_B_EW === RED),
            "Junction B starts with both directions red"
        );

        check(
            (ped_walk_A === 2'b00) && (ped_walk_B === 2'b00),
            "Pedestrian walk outputs are cleared during reset"
        );

        check(
            emergency_active === 1'b0,
            "Emergency output is inactive during reset"
        );

        rst_n = 1;
        wait_cycles(5);

       // TEST 2: Measure exact green-wave offset
$display("");
$display("TEST 2: Exact green-wave offset");

sens_A_NS = 1;
sens_B_NS = 1;

cycle_count = 0;
cycle_A_NS_green = -1;
cycle_B_NS_green = -1;

// Monitor both junctions during the same clock cycles.
for (i = 0; i < 100; i = i + 1) begin
    @(posedge clk);
    #1;

    cycle_count = cycle_count + 1;

    if ((light_A_NS === GREEN) &&
        (cycle_A_NS_green == -1))
        cycle_A_NS_green = cycle_count;

    if ((light_B_NS === GREEN) &&
        (cycle_B_NS_green == -1))
        cycle_B_NS_green = cycle_count;

    // Stop once both first green transitions are recorded.
    if ((cycle_A_NS_green != -1) &&
        (cycle_B_NS_green != -1))
        i = 100;
end

if ((cycle_A_NS_green != -1) &&
    (cycle_B_NS_green != -1)) begin

    measured_offset =
        cycle_B_NS_green - cycle_A_NS_green;

    $display("Junction A NS green cycle: %0d",
             cycle_A_NS_green);

    $display("Junction B NS green cycle: %0d",
             cycle_B_NS_green);

    $display("Measured green-wave offset: %0d cycles",
             measured_offset);

    check(measured_offset > 0,
          "Junction B starts NS green after Junction A");

end
else begin
    check(1'b0,
          "Both junctions reach NS green within timeout");
end

        // TEST 3: Cross-direction traffic
        $display("");
        $display("TEST 3: Cross-direction traffic");

        sens_A_NS = 0;
        sens_A_EW = 1;
        sens_B_NS = 0;
        sens_B_EW = 1;

        wait_cycles(40);
        check_safety();

        // TEST 4: Pedestrian request at junction A
        $display("");
        $display("TEST 4: Pedestrian service at A");

        ped_req_A_NS = 1;
        wait_cycles(3);
        ped_req_A_NS = 0;

        wait_for_pedestrian_A();
        check_safety();

        // Allow the pedestrian phase and arbiter to complete.
        wait_cycles(40);

        // TEST 5: Pedestrian request at junction B
        $display("");
        $display("TEST 5: Pedestrian service at B");

        ped_req_B_NS = 1;
        wait_cycles(3);
        ped_req_B_NS = 0;

        wait_for_pedestrian_B();
        check_safety();

        wait_cycles(40);

        // TEST 6: Simultaneous pedestrian requests
        $display("");
        $display("TEST 6: Simultaneous pedestrian requests");

        ped_req_A_EW = 1;
        ped_req_B_EW = 1;

        wait_cycles(3);

        ped_req_A_EW = 0;
        ped_req_B_EW = 0;

        wait_cycles(100);

        check_safety();

        check(
            !((|ped_walk_A) && (|ped_walk_B)),
            "Shared arbiter prevents simultaneous pedestrian walks"
        );

        
        // TEST 7: Emergency activation and response
        $display("");
        $display("TEST 7: Emergency handling");

        emergency_in = 1;
        wait_cycles(3);
        emergency_in = 0;

        emergency_seen = 0;
        found = 0;

        for (i = 0; i < 20; i = i + 1) begin
            @(posedge clk);
            #1;

            if (emergency_active === 1'b1) begin
                emergency_seen = 1;

                $display(
                    "INFO: Emergency active | A_NS=%b A_EW=%b B_NS=%b B_EW=%b",
                    light_A_NS, light_A_EW,
                    light_B_NS, light_B_EW
                );

                if ((light_A_NS === RED) &&
                    (light_A_EW === RED) &&
                    (light_B_NS === RED) &&
                    (light_B_EW === RED))
                    found = 1;
            end
        end

        check(
            emergency_seen == 1,
            "Emergency input activates emergency controller"
        );

        check(
            found == 1,
            "Both junctions reach all-red while emergency is active"
        );

        // TEST 8: Emergency recovery
        $display("");
        $display("TEST 8: Recovery after emergency");

        wait_cycles(15);

        sens_A_NS = 1;
        sens_A_EW = 0;
        sens_B_NS = 1;
        sens_B_EW = 0;

        found = 0;

        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk);
            #1;

            if ((light_A_NS === GREEN) ||
                (light_A_EW === GREEN))
                found = 1;
        end

        check(found == 1, "Junction A resumes traffic after emergency");

        // TEST 9: Density changes
        $display("");
        $display("TEST 9: Traffic density changes");

        traffic_density_A_NS = 0;
        traffic_density_A_EW = 7;
        traffic_density_B_NS = 0;
        traffic_density_B_EW = 7;

        wait_cycles(40);
        check_safety();

        traffic_density_A_NS = 7;
        traffic_density_A_EW = 0;
        traffic_density_B_NS = 7;
        traffic_density_B_EW = 0;

        wait_cycles(40);
        check_safety();

        traffic_density_A_NS = 7;
        traffic_density_A_EW = 7;
        traffic_density_B_NS = 7;
        traffic_density_B_EW = 7;

        wait_cycles(40);
        check_safety();

        traffic_density_A_NS = 3;
        traffic_density_A_EW = 4;
        traffic_density_B_NS = 5;
        traffic_density_B_EW = 6;

        wait_cycles(40);
        check_safety();

        check(
            (light_A_NS !== 3'bxxx) &&
            (light_A_EW !== 3'bxxx) &&
            (light_B_NS !== 3'bxxx) &&
            (light_B_EW !== 3'bxxx),
            "Traffic outputs remain known during density changes"
        );

        // TEST 10: Reset during operation
        $display("");
        $display("TEST 10: Reset during operation");

        rst_n = 0;
        wait_cycles(5);

        check(
            (light_A_NS === RED) && (light_A_EW === RED) &&
            (light_B_NS === RED) && (light_B_EW === RED),
            "Operational reset returns both junctions to all-red"
        );

        check(
            (ped_walk_A === 2'b00) && (ped_walk_B === 2'b00),
            "Operational reset clears pedestrian walk outputs"
        );

        check(
            emergency_active === 1'b0,
            "Operational reset clears emergency output"
        );

        rst_n = 1;
        wait_cycles(10);

        sens_A_NS = 1;
        sens_A_EW = 0;
        sens_B_NS = 1;
        sens_B_EW = 0;

        found = 0;

        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk);
            #1;

            if (light_A_NS === GREEN)
                found = 1;
        end

        check(found == 1, "System resumes normal operation after reset");

        check_safety();

               // Final summary
        $display("");
        $display("============================================");
        $display(" TRAFFIC SYSTEM TOP TEST SUMMARY");
        $display(" Checks performed : %0d", checks);
        $display(" Errors detected  : %0d", errors);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED");

        $display("============================================");

        if (errors != 0)
            $fatal(1, "Traffic system top regression failed.");

        $finish;
    end

endmodule
