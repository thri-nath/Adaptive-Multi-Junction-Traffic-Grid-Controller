
`timescale 1ns/1ps

module input_sync_tb_Self;

    parameter WIDTH = 4;

    reg clk;
    reg rst_n;
    reg [WIDTH-1:0] async_in;
    wire [WIDTH-1:0] sync_out;

    integer errors;

    input_sync #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .async_in(async_in),
        .sync_out(sync_out)
    );

    always #10 clk = ~clk;

    task check_output;
        input [WIDTH-1:0] expected;
        input [8*40-1:0] test_name;
        begin
            if (sync_out !== expected) begin
                $display("FAIL: %0s | Expected=%b Got=%b",
                         test_name, expected, sync_out);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s", test_name);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        async_in = 0;
        errors = 0;

        $display("-----------------------------------");
        $display(" INPUT SYNC AUTOMATED TESTBENCH");
        $display("-----------------------------------");

        // Test 1: Reset
        repeat (2) @(posedge clk);
        #1;
        check_output(4'b0000, "Reset");

        // Release reset
        @(negedge clk);
        rst_n = 1;

        // Test 2: Rising input
        async_in = 4'b0001;

        @(posedge clk);
        #1;
        check_output(4'b0000, "Rising input - Stage 1");

        @(posedge clk);
        #1;
        check_output(4'b0001, "Rising input - Stage 2");

        // Test 3: Falling input
        @(negedge clk);
        async_in = 4'b0000;

        @(posedge clk);
        #1;
        check_output(4'b0001, "Falling input - Stage 1");

        @(posedge clk);
        #1;
        check_output(4'b0000, "Falling input - Stage 2");

        // Test 4: Multiple-bit synchronization
        @(negedge clk);
        async_in = 4'b1011;

        @(posedge clk);
        #1;
        check_output(4'b0000, "Multiple bits - Stage 1");

        @(posedge clk);
        #1;
        check_output(4'b1011, "Multiple bits - Stage 2");

        // Test 5: Clear output using reset
        @(negedge clk);
        rst_n = 0;

        @(posedge clk);
        #1;
        check_output(4'b0000, "Reset clears output");

        // Final result
        $display("-----------------------------------");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED: %0d errors", errors);

        $display("-----------------------------------");
        $finish;
    end

endmodule
