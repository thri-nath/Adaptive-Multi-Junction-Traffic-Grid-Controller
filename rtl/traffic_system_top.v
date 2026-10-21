module traffic_system_top #(
    parameter GREEN_WAVE_DELAY = 7
) (
    input wire clk,
    input wire rst_n,

    input wire emergency_in,

    input wire sens_A_NS,
    input wire sens_A_EW,
    input wire sens_B_NS,
    input wire sens_B_EW,

    input wire [2:0] traffic_density_A_NS,
    input wire [2:0] traffic_density_A_EW,
    input wire [2:0] traffic_density_B_NS,
    input wire [2:0] traffic_density_B_EW,

    input wire ped_req_A_NS,
    input wire ped_req_A_EW,
    input wire ped_req_B_NS,
    input wire ped_req_B_EW,

    output wire [2:0] light_A_NS,
    output wire [2:0] light_A_EW,

    output wire [2:0] light_B_NS,
    output wire [2:0] light_B_EW,

    output wire [1:0] ped_walk_A,
    output wire [1:0] ped_walk_B,

    output wire emergency_active
);

    wire rst_n_sync;

    wire sens_A_NS_sync;
    wire sens_A_EW_sync;
    wire sens_B_NS_sync;
    wire sens_B_EW_sync;

    wire [2:0] density_A_NS_sync;
    wire [2:0] density_A_EW_sync;
    wire [2:0] density_B_NS_sync;
    wire [2:0] density_B_EW_sync;

    wire emergency_in_sync;

    wire [1:0] ped_req_A_sync;
    wire [1:0] ped_req_B_sync;

    wire ped_grant_A;
    wire ped_grant_B;

    wire ped_done_A;
    wire ped_done_B;

    wire green_wave_A;
    wire green_wave_B;

    wire green_wave_trigger_B;

    reset_sync reset_inst (
        .clk         (clk),
        .rst_n_async (rst_n),
        .rst_n_sync  (rst_n_sync)
    );

    input_sync #(
        .WIDTH(1)
    ) sens_A_NS_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (sens_A_NS),
        .sync_out (sens_A_NS_sync)
    );

    input_sync #(
        .WIDTH(1)
    ) sens_A_EW_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (sens_A_EW),
        .sync_out (sens_A_EW_sync)
    );

    input_sync #(
        .WIDTH(1)
    ) sens_B_NS_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (sens_B_NS),
        .sync_out (sens_B_NS_sync)
    );

    input_sync #(
        .WIDTH(1)
    ) sens_B_EW_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (sens_B_EW),
        .sync_out (sens_B_EW_sync)
    );

    input_sync #(
        .WIDTH(3)
    ) density_A_NS_sync_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (traffic_density_A_NS),
        .sync_out (density_A_NS_sync)
    );

    input_sync #(
        .WIDTH(3)
    ) density_A_EW_sync_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (traffic_density_A_EW),
        .sync_out (density_A_EW_sync)
    );

    input_sync #(
        .WIDTH(3)
    ) density_B_NS_sync_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (traffic_density_B_NS),
        .sync_out (density_B_NS_sync)
    );

    input_sync #(
        .WIDTH(3)
    ) density_B_EW_sync_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (traffic_density_B_EW),
        .sync_out (density_B_EW_sync)
    );

    input_sync #(
        .WIDTH(1)
    ) emergency_sync_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in (emergency_in),
        .sync_out (emergency_in_sync)
    );

    input_sync #(
        .WIDTH(2)
    ) ped_A_sync_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in ({ped_req_A_NS, ped_req_A_EW}),
        .sync_out (ped_req_A_sync)
    );

    input_sync #(
        .WIDTH(2)
    ) ped_B_sync_inst (
        .clk      (clk),
        .rst_n    (rst_n_sync),
        .async_in ({ped_req_B_NS, ped_req_B_EW}),
        .sync_out (ped_req_B_sync)
    );

    emergency_controller #(
        .HOLD_CYCLES(7),
        .width(3)
    ) emergency_inst (
        .clk              (clk),
        .rst_n            (rst_n_sync),
        .emergency_in     (emergency_in_sync),
        .emergency_active (emergency_active)
    );

    shared_pedestrian_arbiter pedestrian_arbiter (
        .clk             (clk),
        .rst_n           (rst_n_sync),
        .ped_req_A       (ped_req_A_sync),
        .ped_req_B       (ped_req_B_sync),
        .ped_done_A      (ped_done_A),
        .ped_done_B      (ped_done_B),
        .emergency_active (emergency_active),
        .grant_A         (ped_grant_A),
        .grant_B         (ped_grant_B),
        .prio_sel        ()
    );

    junction_fsm #(
        .IS_MASTER    (1),
        .MIN_GREEN    (10),
        .MAX_GREEN    (30),
        .GREEN_EXTENSION (4),
        .YELLOW_TIME  (3),
        .ALL_RED_TIME (2),
        .PED_TIME     (5),
        .SYNC_TIMEOUT (50)
    ) junction_A (
        .clk                (clk),
        .rst_n              (rst_n_sync),
        .sens_NS            (sens_A_NS_sync),
        .sens_EW            (sens_A_EW_sync),
        .traffic_density_NS (density_A_NS_sync),
        .traffic_density_EW (density_A_EW_sync),
        .ped_req            (ped_req_A_sync),
        .ped_grant          (ped_grant_A),
        .green_wave_trigger (1'b0),
        .emergency_active   (emergency_active),
        .light_NS           (light_A_NS),
        .light_EW           (light_A_EW),
        .green_wave_out     (green_wave_A),
        .ped_walk           (ped_walk_A),
        .ped_done           (ped_done_A),
        .state              ()
    );

    green_wave_delay #(
        .HOLD_CYCLES(GREEN_WAVE_DELAY)
    ) green_wave_inst (
        .clk       (clk),
        .rst_n     (rst_n_sync),
        .pulse_in  (green_wave_A),
        .clear     (emergency_active),
        .pulse_out (green_wave_trigger_B)
    );

    junction_fsm #(
        .IS_MASTER    (0),
        .MIN_GREEN    (10),
        .MAX_GREEN    (30),
        .GREEN_EXTENSION (4),
        .YELLOW_TIME  (3),
        .ALL_RED_TIME (2),
        .PED_TIME     (5),
        .SYNC_TIMEOUT (50)
    ) junction_B (
        .clk                (clk),
        .rst_n              (rst_n_sync),
        .sens_NS            (sens_B_NS_sync),
        .sens_EW            (sens_B_EW_sync),
        .traffic_density_NS (density_B_NS_sync),
        .traffic_density_EW (density_B_EW_sync),
        .ped_req            (ped_req_B_sync),
        .ped_grant          (ped_grant_B),
        .green_wave_trigger (green_wave_trigger_B),
        .emergency_active   (emergency_active),
        .light_NS           (light_B_NS),
        .light_EW           (light_B_EW),
        .green_wave_out     (green_wave_B),
        .ped_walk           (ped_walk_B),
        .ped_done           (ped_done_B),
        .state              ()
    );

endmodule