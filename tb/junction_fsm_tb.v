
`timescale 1ns/1ps

module junction_fsm_tb;

    reg clk;
    reg rst_n;

    reg sens_NS;
    reg sens_EW;

    reg [2:0] traffic_density_NS;
    reg [2:0] traffic_density_EW;

    reg [1:0] ped_req;
    reg ped_grant;

    reg green_wave_trigger;
    reg emergency_active;

    wire [2:0] light_NS;
    wire [2:0] light_EW;

    wire green_wave_out;
    wire [1:0] ped_walk;
    wire ped_done;

    wire [3:0] state;

    junction_fsm #(
        .IS_MASTER(1),
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

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        sens_NS = 0;
        sens_EW = 0;

        traffic_density_NS = 0;
        traffic_density_EW = 0;

        ped_req = 2'b00;
        ped_grant = 0;

        green_wave_trigger = 0;
        emergency_active = 0;

        // T1: Reset
        #40;
        rst_n = 1;

        // T2: Normal NS traffic, minimum density
        sens_NS = 1;
        sens_EW = 0;
        traffic_density_NS = 0;
        traffic_density_EW = 0;

        #200;

        // T3: EW traffic, high EW density
        sens_NS = 0;
        sens_EW = 1;
        traffic_density_NS = 0;
        traffic_density_EW = 7;

        #250;

        // T4: Pedestrian request
        ped_req = 2'b01;
        #20;
        ped_req = 2'b00;

        // Allow FSM to reach all-red
        #100;

        // T5: Pedestrian grant
        ped_grant = 1;
        #20;
        ped_grant = 0;

        #100;

        // T6: Emergency activation
        emergency_active = 1;
        #100;

        // T7: Emergency release
        emergency_active = 0;
        #100;

        // T8: Green-wave trigger
        green_wave_trigger = 1;
        #20;
        green_wave_trigger = 0;

        #100;

        // T9: NS green with density 1
        traffic_density_NS = 1;
        traffic_density_EW = 1;
        #250;

        // T10: NS green with density 3
        traffic_density_NS = 3;
        #250;

        // T11: NS green with density 5
        traffic_density_NS = 5;
        #250;

        // T12: Maximum NS density
        traffic_density_NS = 7;
        #300;

        // T13: Minimum EW density
        traffic_density_EW = 0;
        #250;

        // T14: Maximum density in both directions
        traffic_density_NS = 7;
        traffic_density_EW = 7;
        #400;

        // T15: Density changes during operation
        traffic_density_NS = 2;
        traffic_density_EW = 2;
        #40;

        traffic_density_NS = 7;
        traffic_density_EW = 7;
        #300;

        // T16: Return to minimum density
        traffic_density_NS = 0;
        traffic_density_EW = 0;
        #300;

        // T17: Reset during operation
        rst_n = 0;
        #40;
        rst_n = 1;

        // T18: Verify operation after reset
        traffic_density_NS = 7;
        traffic_density_EW = 3;
        sens_NS = 1;
        sens_EW = 0;

        #300;

        $finish;
    end

endmodule