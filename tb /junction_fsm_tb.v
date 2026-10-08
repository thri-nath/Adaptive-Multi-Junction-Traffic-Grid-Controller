`timescale 1ns/1ps

module junction_fsm_tb;

    reg clk;
    reg rst_n;

    reg sens_NS;
    reg sens_EW;

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
    //this is for junction A
    junction_fsm #(
        .IS_MASTER(1),
        .MIN_GREEN(5),
        .MAX_GREEN(10),
        .YELLOW_TIME(2),
        .ALL_RED_TIME(2),
        .PED_TIME(3),
        .SYNC_TIMEOUT(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),

        .sens_NS(sens_NS),
        .sens_EW(sens_EW),

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

        ped_req = 2'b00;
        ped_grant = 0;

        green_wave_trigger = 0;
        emergency_active = 0;

        // Reset
        #40;
        rst_n = 1;

        // NS traffic
        sens_NS = 1;
        sens_EW = 0;

        #200;

        // EW traffic
        sens_NS = 0;
        sens_EW = 1;

        #200;

        // Pedestrian request
        ped_req = 2'b01;

        #20;
        ped_req = 2'b00;

        // Allow FSM to reach all-red
        #100;

        // Pedestrian grant
        ped_grant = 1;

        #20;
        ped_grant = 0;

        #100;

        // Emergency
        emergency_active = 1;

        #100;

        // Release emergency
        emergency_active = 0;

        #100;

        // Green wave trigger
        green_wave_trigger = 1;

        #20;
        green_wave_trigger = 0;

        #100;

        // Reset during operation
        rst_n = 0;

        #40;
        rst_n = 1;

        #200;

        $finish;

    end

endmodule



