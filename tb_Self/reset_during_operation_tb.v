
`timescale 1ns/1ps

module reset_during_operation_tb;

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
    integer checks;

    localparam RED = 3'b001;

    localparam S_NS_GREEN  = 4'b0000;
    localparam S_EW_GREEN  = 4'b0011;
    localparam S_PED       = 4'b0110;
    localparam S_EMERGENCY = 4'b1000;

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

    task check_reset_outputs;
    begin
        checks = checks + 1;

        if ((light_A_NS !== RED) ||
            (light_A_EW !== RED) ||
            (light_B_NS !== RED) ||
            (light_B_EW !== RED) ||
            (ped_walk_A !== 2'b00) ||
            (ped_walk_B !== 2'b00)) begin

            errors = errors + 1;
            $display("FAIL: Reset outputs at time %0t", $time);
            $display(" A_NS=%b A_EW=%b B_NS=%b B_EW=%b",
                     light_A_NS, light_A_EW,
                     light_B_NS, light_B_EW);
            $display(" PedA=%b PedB=%b",
                     ped_walk_A, ped_walk_B);
        end
        else begin
            $display("PASS: Reset outputs are safe at time %0t",
                     $time);
        end
    end
    endtask

    task apply_reset;
    begin
        @(negedge clk);
        rst_n = 1'b0;

        // Allow reset to propagate through the design.
        repeat (4) @(posedge clk);
        #1;
        check_reset_outputs;

        @(negedge clk);
        rst_n = 1'b1;

        // Allow normal operation to resume.
        repeat (3) @(posedge clk);
        #1;
    end
    endtask

    task wait_for_A_state;
        input [3:0] target_state;
        input integer timeout_cycles;
        integer k;
        begin : WAIT_STATE
            k = 0;

            while ((dut.junction_A.state !== target_state) &&
                   (k < timeout_cycles)) begin
                @(posedge clk);
                #1;
                k = k + 1;
            end

            if (dut.junction_A.state !== target_state) begin
                errors = errors + 1;
                $display("FAIL: Junction A state %b not reached",
                         target_state);
            end
            else begin
                $display("INFO: Junction A reached state %b at %0t",
                         target_state, $time);
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
        checks = 0;

        $display("------------------------------------------");
        $display(" RESET DURING OPERATION SELF-CHECKING TB");
        $display("------------------------------------------");

        // Initial reset.
        repeat (4) @(posedge clk);
        #1;
        check_reset_outputs;

        @(negedge clk);
        rst_n = 1;

        // Test 1: Reset during North-South green.
        wait_for_A_state(S_NS_GREEN, 100);
        apply_reset;

        // Test 2: Reset during East-West green.
        wait_for_A_state(S_EW_GREEN, 150);
        apply_reset;

        // Test 3: Request pedestrian service, then reset
        // when Junction A reaches its pedestrian state.
        @(negedge clk);
        ped_req_A_NS = 1'b1;
        ped_req_B_NS = 1'b1;

        wait_for_A_state(S_PED, 250);
        apply_reset;

        @(negedge clk);
        ped_req_A_NS = 1'b0;
        ped_req_B_NS = 1'b0;

        // Test 4: Reset during emergency state.
        @(negedge clk);
        emergency_in = 1'b1;

        wait_for_A_state(S_EMERGENCY, 100);
        apply_reset;

        @(negedge clk);
        emergency_in = 1'b0;

        // Confirm that the design continues operating after reset.
        wait_for_A_state(S_NS_GREEN, 150);

               $display("------------------------------------------");
        $display("RESET TEST SUMMARY");
        $display("Checks performed: %0d", checks);
        $display("Errors detected : %0d", errors);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED");

        $display("------------------------------------------");

        $finish;
    end

    initial begin
        #200000;
        $display("FAIL: Global timeout");
        $finish;
    end

endmodule
