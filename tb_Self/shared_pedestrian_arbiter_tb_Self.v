
`timescale 1ns / 1ps

module shared_pedestrian_arbiter_tb_Self;

    reg clk;
    reg rst_n;
    reg [1:0] ped_req_A;
    reg [1:0] ped_req_B;
    reg ped_done_A;
    reg ped_done_B;
    reg emergency_active;

    wire grant_A;
    wire grant_B;
    wire prio_sel;

    integer pass_count = 0;
    integer fail_count = 0;

    shared_pedestrian_arbiter uut (
        .clk(clk),
        .rst_n(rst_n),
        .ped_req_A(ped_req_A),
        .ped_req_B(ped_req_B),
        .ped_done_A(ped_done_A),
        .ped_done_B(ped_done_B),
        .emergency_active(emergency_active),
        .grant_A(grant_A),
        .grant_B(grant_B),
        .prio_sel(prio_sel)
    );

    always #10 clk = ~clk;

    task check_outputs;
        input expected_A;
        input expected_B;
        input expected_prio;
        input [8*70-1:0] test_name;
        begin
            if (grant_A === expected_A &&
                grant_B === expected_B &&
                prio_sel === expected_prio) begin
                $display(
                    "PASS: %0s | A=%b B=%b Priority=%b",
                    test_name, grant_A, grant_B, prio_sel
                );
                pass_count = pass_count + 1;
            end
            else begin
                $display(
                    "FAIL: %0s | Expected A=%b B=%b Priority=%b, Got A=%b B=%b Priority=%b",
                    test_name, expected_A, expected_B, expected_prio,
                    grant_A, grant_B, prio_sel
                );
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Change inputs away from the active clock edge.
    // Check outputs after nonblocking assignments have settled.
    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        ped_req_A = 2'b00;
        ped_req_B = 2'b00;
        ped_done_A = 0;
        ped_done_B = 0;
        emergency_active = 0;

        $display("-----------------------------------------------");
        $display(" SHARED PEDESTRIAN ARBITER SELF-CHECKING TB");
        $display("-----------------------------------------------");

        // 1. Reset
        tick;
        check_outputs(0, 0, 0, "Reset clears grants and priority");

        rst_n = 1;
        tick;
        check_outputs(0, 0, 0, "No requests after reset");

        // 2. Request from A only
        ped_req_A = 2'b10;
        tick;
        check_outputs(1, 0, 0, "A-only request grants A");

        // 3. A grant remains active until completion
        ped_req_A = 2'b00;
        tick;
        check_outputs(1, 0, 0, "A grant remains until done");

        ped_done_A = 1;
        tick;
        check_outputs(0, 0, 1, "A completion clears grant and selects B priority");

        ped_done_A = 0;
        tick;
        check_outputs(0, 0, 1, "No grant while idle");

        // 4. Request from B only
        ped_req_B = 2'b01;
        tick;
        check_outputs(0, 1, 1, "B-only request grants B");

        ped_req_B = 2'b00;
        ped_done_B = 1;
        tick;
        check_outputs(0, 0, 0, "B completion clears grant and selects A priority");

        ped_done_B = 0;
        tick;
        check_outputs(0, 0, 0, "Idle after B completion");

        // 5. Both request: priority A
        ped_req_A = 2'b10;
        ped_req_B = 2'b01;
        tick;
        check_outputs(1, 0, 0, "Both request with A priority grants A");

        // Complete A; priority should switch to B
        ped_req_A = 2'b00;
        ped_done_A = 1;
        tick;
        check_outputs(0, 0, 1, "A completion switches priority to B");

        ped_done_A = 0;
        tick;
        check_outputs(0, 1, 1, "Pending B request receives grant");

        // Complete B; priority should switch back to A
        ped_req_B = 2'b00;
        ped_done_B = 1;
        tick;
        check_outputs(0, 0, 0, "B completion switches priority to A");

        ped_done_B = 0;
        tick;
        check_outputs(0, 0, 0, "Idle after alternating grants");

        // 6. Both requests with B priority
        ped_req_A = 2'b01;
        ped_req_B = 2'b10;
        tick;
        check_outputs(0, 1, 0, "Both request with B priority grants B");

        ped_req_A = 2'b00;
        ped_req_B = 2'b00;
        ped_done_B = 1;
        tick;
        check_outputs(0, 0, 0, "B completion returns priority to A");

        ped_done_B = 0;
        tick;

        // 7. Emergency clears active grants
        ped_req_A = 2'b11;
        tick;
        check_outputs(1, 0, 0, "A granted before emergency");

        emergency_active = 1;
        tick;
        check_outputs(0, 0, 0, "Emergency clears both grants");

        // While emergency remains active, grants must stay cleared.
        ped_req_B = 2'b01;
        tick;
        check_outputs(0, 0, 0, "Emergency blocks new grants");

        // Release emergency. Pending B request can now be granted.
        emergency_active = 0;
        ped_req_A = 2'b00;
        tick;
        check_outputs(0, 1, 0, "B request granted after emergency");

        ped_req_B = 2'b00;
        ped_done_B = 1;
        tick;
        check_outputs(0, 0, 0, "B completion after emergency");

        ped_done_B = 0;
        tick;

        // 8. Reset while a grant is active
        ped_req_A = 2'b01;
        tick;
        check_outputs(1, 0, 0, "A grant before reset");

        rst_n = 0;
        tick;
        check_outputs(0, 0, 0, "Reset clears grants and priority");

        rst_n = 1;
        ped_req_A = 2'b00;
        tick;
        check_outputs(0, 0, 0, "Idle after reset release");

        // 9. No requests should leave both grants inactive
        repeat (3) begin
            tick;
            check_outputs(0, 0, 0, "Idle operation");
        end

        $display("-----------------------------------------------");
        $display("TOTAL PASS: %0d", pass_count);
        $display("TOTAL FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $display("-----------------------------------------------");
        $finish;
    end

endmodule
