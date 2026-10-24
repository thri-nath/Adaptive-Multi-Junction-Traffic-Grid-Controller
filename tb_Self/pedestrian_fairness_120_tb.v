
`timescale 1ns / 1ps

module pedestrian_fairness_120_tb;

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

    integer errors;
    integer grants_A;
    integer grants_B;
    integer request_count;
    integer i;

    shared_pedestrian_arbiter dut (
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

    task check_grants;
        begin
            if (grant_A && grant_B) begin
                $display("FAIL: Both junctions granted simultaneously");
                errors = errors + 1;
            end
        end
    endtask

    task complete_grant;
        begin
            // Allow the registered grant to settle.
            @(negedge clk);
            check_grants();

            if (grant_A) begin
                grants_A = grants_A + 1;
                ped_done_A = 1'b1;
            end
            else if (grant_B) begin
                grants_B = grants_B + 1;
                ped_done_B = 1'b1;
            end
            else begin
                $display("FAIL: No grant for pending requests");
                errors = errors + 1;
            end

            @(negedge clk);
            ped_done_A = 1'b0;
            ped_done_B = 1'b0;

            // Allow the arbiter to issue the next grant.
            @(negedge clk);
            check_grants();
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        ped_req_A = 0;
        ped_req_B = 0;
        ped_done_A = 0;
        ped_done_B = 0;
        emergency_active = 0;

        errors = 0;
        grants_A = 0;
        grants_B = 0;
        request_count = 120;

        $display("------------------------------------");
        $display(" PEDESTRIAN FAIRNESS TEST: 120");
        $display("------------------------------------");

        repeat (3) @(negedge clk);
        rst_n = 1;

        // Both junctions keep requesting service.
        ped_req_A = 2'b01;
        ped_req_B = 2'b01;

        // Complete 120 grants and check mutual exclusion.
        for (i = 0; i < request_count; i = i + 1)
            complete_grant();

        // Final grant accounting.
        if ((grants_A + grants_B) != request_count) begin
            $display("FAIL: Expected %0d grants, observed %0d",
                     request_count, grants_A + grants_B);
            errors = errors + 1;
        end

        // With continuous simultaneous requests, neither
        // junction should be starved.
        if (grants_A == 0 || grants_B == 0) begin
            $display("FAIL: One junction received no grants");
            errors = errors + 1;
        end

        if ((grants_A > grants_B + 1) ||
            (grants_B > grants_A + 1)) begin
            $display("FAIL: Unexpected grant imbalance A=%0d B=%0d",
                     grants_A, grants_B);
            errors = errors + 1;
        end

        $display("Junction A grants: %0d", grants_A);
        $display("Junction B grants: %0d", grants_B);

        if (errors == 0)
            $display("PASS: 120-request fairness test");
        else
            $display("FAIL: Errors=%0d", errors);

        $finish;
    end

    initial begin
        #100000;
        $display("FAIL: Testbench timeout");
        $finish;
    end

endmodule
