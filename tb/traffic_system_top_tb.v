`timescale 1ns/1ps

module traffic_system_top_tb;

    reg clk;
    reg rst_n;

    reg emergency_in;

    reg sens_A_NS;
    reg sens_A_EW;
    reg sens_B_NS;
    reg sens_B_EW;

    reg ped_req_A_NS;
    reg ped_req_A_EW;
    reg ped_req_B_NS;
    reg ped_req_B_EW;

    wire [2:0] light_A_NS;
    wire [2:0] light_A_EW;
    wire [2:0] light_B_NS;
    wire [2:0] light_B_EW;

    wire [1:0] ped_walk_A;
    wire [1:0] ped_walk_B;

    wire emergency_active;

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

    initial begin

        clk = 0;
        rst_n = 0;

        emergency_in = 0;

        sens_A_NS = 0;
        sens_A_EW = 0;
        sens_B_NS = 0;
        sens_B_EW = 0;

        ped_req_A_NS = 0;
        ped_req_A_EW = 0;
        ped_req_B_NS = 0;
        ped_req_B_EW = 0;

        // T1: Power-up reset
        #100;
        rst_n = 1;

        // T3/T4: Normal traffic
        sens_A_NS = 1;
        sens_A_EW = 0;

        sens_B_NS = 1;
        sens_B_EW = 0;

        #600;

        // Cross-direction traffic
        sens_A_NS = 0;
        sens_A_EW = 1;

        sens_B_NS = 0;
        sens_B_EW = 1;

        #600;

        // T14: Pedestrian request at A
        ped_req_A_NS = 1;
        #40;
        ped_req_A_NS = 0;

        #300;

        // T16: Both crossings at A
        ped_req_A_NS = 1;
        ped_req_A_EW = 1;
        #40;
        ped_req_A_NS = 0;
        ped_req_A_EW = 0;

        #500;

        // T15: Pedestrian request at B
        ped_req_B_NS = 1;
        #40;
        ped_req_B_NS = 0;

        #500;

        // T17: Simultaneous A/B requests
        ped_req_A_NS = 1;
        ped_req_B_NS = 1;

        #40;

        ped_req_A_NS = 0;
        ped_req_B_NS = 0;

        #600;

        // T8: Green-wave operation
        sens_A_NS = 1;
        sens_A_EW = 0;

        sens_B_NS = 1;
        sens_B_EW = 0;

        #1000;

        // T22/T24: Emergency
        emergency_in = 1;
        #40;
        emergency_in = 0;

        #300;

        // T26: Emergency recovery
        sens_A_NS = 0;
        sens_A_EW = 1;

        sens_B_NS = 0;
        sens_B_EW = 1;

        #500;

        // T27: Pedestrian request after emergency
        ped_req_A_EW = 1;
        #40;
        ped_req_A_EW = 0;

        #500;

        // T2: Reset during operation
        rst_n = 0;
        #100;
        rst_n = 1;

        #500;

        $finish;

    end

endmodule