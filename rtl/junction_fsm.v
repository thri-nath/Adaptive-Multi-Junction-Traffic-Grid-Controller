module junction_fsm #(
    parameter IS_MASTER    = 1,
    parameter MIN_GREEN    = 10,
    parameter MAX_GREEN    = 30,
    parameter YELLOW_TIME  = 3,
    parameter ALL_RED_TIME = 2,
    parameter PED_TIME     = 5,
    parameter SYNC_TIMEOUT = 50
) (
    input wire       clk,
    input wire       rst_n,

    input wire       sens_NS,
    input wire       sens_EW,

    input wire [1:0] ped_req,
    input wire       ped_grant,

    input wire       green_wave_trigger,
    input wire       emergency_active,

    output reg [2:0] light_NS,
    output reg [2:0] light_EW,

    output reg       green_wave_out,
    output reg [1:0] ped_walk,
    output reg       ped_done,

    output reg [3:0] state
);

    localparam S_NS_GREEN  = 4'b0000;
    localparam S_NS_YELLOW = 4'b0001;
    localparam S_AR_NS2EW  = 4'b0010;
    localparam S_EW_GREEN  = 4'b0011;
    localparam S_EW_YELLOW = 4'b0100;
    localparam S_AR_EW2NS  = 4'b0101;
    localparam S_PED       = 4'b0110;
    localparam S_WAIT_SYNC = 4'b0111;
    localparam S_EMERGENCY = 4'b1000;

    localparam RED    = 3'b001;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b100;

    localparam TIMER_WIDTH = 16;

    reg [3:0] next_state;
    reg [3:0] previous_state;

    reg [1:0] ped_pending;
    reg [1:0] ped_service;

    reg       emergency_pending;

    reg [TIMER_WIDTH-1:0] phase_target;

    wire timer_start;
    wire timer_done;

    assign timer_start = (state != previous_state);

    generic_timer #(
        .width(TIMER_WIDTH)
    ) phase_timer (
        .clk    (clk),
        .start  (timer_start),
        .target (phase_target),
        .rst_n  (rst_n),
        .done   (timer_done)
    );

    always @(*) begin

        next_state = state;

        case (state)

            S_NS_GREEN: begin
                if (emergency_active)
                    next_state = S_NS_YELLOW;
                else if (timer_done)
                    next_state = S_NS_YELLOW;
            end

            S_NS_YELLOW: begin
                if (timer_done) begin
                    if (emergency_active || emergency_pending)
                        next_state = S_EMERGENCY;
                    else
                        next_state = S_AR_NS2EW;
                end
            end

            S_AR_NS2EW: begin
                if (emergency_active)
                    next_state = S_EMERGENCY;
                else if (timer_done)
                    next_state = S_EW_GREEN;
            end

            S_EW_GREEN: begin
                if (emergency_active)
                    next_state = S_EW_YELLOW;
                else if (timer_done)
                    next_state = S_EW_YELLOW;
            end

            S_EW_YELLOW: begin
                if (timer_done) begin
                    if (emergency_active || emergency_pending)
                        next_state = S_EMERGENCY;
                    else
                        next_state = S_AR_EW2NS;
                end
            end

            S_AR_EW2NS: begin
                if (emergency_active)
                    next_state = S_EMERGENCY;
                else if (timer_done) begin
                    if (ped_grant && |ped_pending)
                        next_state = S_PED;
                    else if (IS_MASTER)
                        next_state = S_NS_GREEN;
                    else
                        next_state = S_WAIT_SYNC;
                end
            end

            S_PED: begin
                if (emergency_active)
                    next_state = S_EMERGENCY;
                else if (timer_done)
                    next_state = S_NS_GREEN;
            end

            S_WAIT_SYNC: begin
                if (emergency_active)
                    next_state = S_EMERGENCY;
                else if (green_wave_trigger || timer_done)
                    next_state = S_NS_GREEN;
            end

            S_EMERGENCY: begin
                if (!emergency_active)
                    next_state = S_AR_EW2NS;
            end

            default: begin
                next_state = S_AR_EW2NS;
            end

        endcase
    end

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state              <= S_AR_EW2NS;
            previous_state     <= 4'b1111;

            ped_pending        <= 2'b00;
            ped_service        <= 2'b00;

            emergency_pending  <= 1'b0;

            phase_target       <= ALL_RED_TIME;

            light_NS           <= RED;
            light_EW           <= RED;

            green_wave_out     <= 1'b0;
            ped_walk           <= 2'b00;
            ped_done           <= 1'b0;
        end

        else begin

            previous_state <= state;
            state          <= next_state;

            green_wave_out <= 1'b0;
            ped_done       <= 1'b0;

            ped_pending <= ped_pending | ped_req;

            if (state == S_NS_GREEN && emergency_active)
                emergency_pending <= 1'b1;

            if (state == S_EW_GREEN && emergency_active)
                emergency_pending <= 1'b1;

            if (state == S_NS_YELLOW && emergency_active)
                emergency_pending <= 1'b1;

            if (state == S_EW_YELLOW && emergency_active)
                emergency_pending <= 1'b1;

            if (state == S_EMERGENCY && !emergency_active)
                emergency_pending <= 1'b0;

            if (state != next_state) begin

                case (next_state)

                    S_NS_GREEN: begin
                        if (sens_NS && !sens_EW)
                            phase_target <= MAX_GREEN;
                        else
                            phase_target <= MIN_GREEN;
                    end

                    S_NS_YELLOW:
                        phase_target <= YELLOW_TIME;

                    S_AR_NS2EW:
                        phase_target <= ALL_RED_TIME;

                    S_EW_GREEN: begin
                        if (sens_EW && !sens_NS)
                            phase_target <= MAX_GREEN;
                        else
                            phase_target <= MIN_GREEN;
                    end

                    S_EW_YELLOW:
                        phase_target <= YELLOW_TIME;

                    S_AR_EW2NS:
                        phase_target <= ALL_RED_TIME;

                    S_PED:
                        phase_target <= PED_TIME;

                    S_WAIT_SYNC:
                        phase_target <= SYNC_TIMEOUT;

                    S_EMERGENCY:
                        phase_target <= 16'd1;

                    default:
                        phase_target <= ALL_RED_TIME;

                endcase

            end

            case (state)

                S_NS_GREEN: begin
                    light_NS <= GREEN;
                    light_EW <= RED;
                    ped_walk <= 2'b00;

                    if (state != previous_state)
                        green_wave_out <= 1'b1;
                end

                S_NS_YELLOW: begin
                    light_NS <= YELLOW;
                    light_EW <= RED;
                    ped_walk <= 2'b00;
                end

                S_AR_NS2EW: begin
                    light_NS <= RED;
                    light_EW <= RED;
                    ped_walk <= 2'b00;
                end

                S_EW_GREEN: begin
                    light_NS <= RED;
                    light_EW <= GREEN;
                    ped_walk <= 2'b00;
                end

                S_EW_YELLOW: begin
                    light_NS <= RED;
                    light_EW <= YELLOW;
                    ped_walk <= 2'b00;
                end

                S_AR_EW2NS: begin
                    light_NS <= RED;
                    light_EW <= RED;
                    ped_walk <= 2'b00;

                    if (state != next_state &&
                        next_state == S_PED) begin
                        ped_service <= ped_pending;
                        ped_pending <= ped_req;
                    end
                end

                S_PED: begin
                    light_NS <= RED;
                    light_EW <= RED;

                    if (state != previous_state)
                        ped_walk <= ped_service;
                    else
                        ped_walk <= ped_service;

                    if (emergency_active) begin
                        ped_walk <= 2'b00;
                        ped_done <= 1'b1;
                        ped_service <= 2'b00;
                    end
                    else if (timer_done) begin
                        ped_walk <= 2'b00;
                        ped_done <= 1'b1;
                        ped_service <= 2'b00;
                    end
                end

                S_WAIT_SYNC: begin
                    light_NS <= RED;
                    light_EW <= RED;
                    ped_walk <= 2'b00;
                end

                S_EMERGENCY: begin
                    light_NS <= RED;
                    light_EW <= RED;
                    ped_walk <= 2'b00;
                    ped_service <= 2'b00;
                end

                default: begin
                    light_NS <= RED;
                    light_EW <= RED;
                    ped_walk <= 2'b00;
                end

            endcase

        end
    end

endmodule