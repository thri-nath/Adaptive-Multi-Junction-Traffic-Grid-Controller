module generic_timer (
    input wire clk,
    input wire start,
    input wire [3:0] target,
    input wire rst_n,
    output reg done
);

    reg [3:0] count;
    reg running;

    always @(posedge clk ) begin
        if (!rst_n) begin
            count   <= 4'd0;
            done    <= 1'b0;
            running <= 1'b0;
        end else begin
            if (start) begin
                count   <= 4'd1;
                done    <= 1'b0;
                running <= 1'b1;
            end else if (running) begin
                if (count == target) begin
                    done    <= 1'b1;
                    running <= 1'b0;
                end else begin
                    count   <= count + 4'd1;
                    done    <= 1'b0;
                end
            end else begin
                done <= 1'b0;
            end
        end
    end

endmodule
