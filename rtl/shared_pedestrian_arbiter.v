`timescale 1ns / 1ps

module shared_pedestrian_arbiter(
    input clk,
    input rst_n,
    input [1:0] ped_req_A,
    input [1:0] ped_req_B,
    input ped_done_A,
    input ped_done_B,
    input emergency_active,
    output reg grant_A,
    output reg grant_B,
    output reg prio_sel
);

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            grant_A <= 1'b0;
            grant_B <= 1'b0;
            prio_sel <= 1'b0;
        end

        else if (emergency_active) begin
            grant_A <= 1'b0;
            grant_B <= 1'b0;
        end

        else if (grant_A) begin
            if (ped_done_A) begin
                grant_A <= 1'b0;
                prio_sel <= 1'b1;
            end
        end

        else if (grant_B) begin
            if (ped_done_B) begin
                grant_B <= 1'b0;
                prio_sel <= 1'b0;
            end
        end

        else begin

            if (ped_req_A != 2'b00 && ped_req_B != 2'b00) begin

                if (prio_sel == 1'b0)
                    grant_A <= 1'b1;
                else
                    grant_B <= 1'b1;

            end

            else if (ped_req_A != 2'b00) begin
                grant_A <= 1'b1;
            end

            else if (ped_req_B != 2'b00) begin
                grant_B <= 1'b1;
            end

        end

    end

endmodule