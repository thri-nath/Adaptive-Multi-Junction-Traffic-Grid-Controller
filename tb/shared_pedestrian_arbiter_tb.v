
`timescale 1ns / 1ps

module shared_pedestrian_arbiter_tb;

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

initial begin

    clk = 0;
    rst_n = 0;
    ped_req_A = 2'b00;
    ped_req_B = 2'b00;
    ped_done_A = 0;
    ped_done_B = 0;
    emergency_active = 0;

    // Reset
    #20;
    rst_n = 1;

    // A requests
    #20;
    ped_req_A = 2'b10;

    // A completes
    #20;
    ped_req_A = 2'b00;
    ped_done_A = 1;

    #20;
    ped_done_A = 0;

    // B requests
    #20;
    ped_req_B = 2'b01;

    // B completes
    #20;
    ped_req_B = 2'b00;
    ped_done_B = 1;

    #20;
    ped_done_B = 0;

    // Both request
    #20;
    ped_req_A = 2'b10;
    ped_req_B = 2'b01;

    // A completes
    #20;
    ped_req_A = 2'b00;
    ped_done_A = 1;

    #20;
    ped_done_A = 0;

    // B completes
    #20;
    ped_req_B = 2'b00;
    ped_done_B = 1;

    #20;
    ped_done_B = 0;

    // Emergency
    #20;
    ped_req_A = 2'b11;

    #20;
    emergency_active = 1;

    #20;
    emergency_active = 0;
    ped_req_A = 2'b00;

    #20;

    $finish;

end

endmodule


