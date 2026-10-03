module generic_timer #(
    parameter width = 4
)(
    input wire clk,
    input wire start,
    input wire [width-1:0] target,
    input wire rst_n,
    output reg done
);

    reg [width-1:0] count;
    reg running;

    always @(posedge clk ) begin
        if (!rst_n) begin
            count   <= {width-1{1'b0}};
            done    <= 1'b0;
            running <= 1'b0;
        end else begin
            if (start) begin
                count   <= {{width-1{1'b0}}, 1'b1};
                done    <= 1'b0;
                running <= 1'b1;
            end else if (running) begin
                if (count == target) begin
                    done    <= 1'b1;
                    running <= 1'b0;
                end else begin
                    count   <= count + {{width-1{1'b0}}, 1'b1};
                    done    <= 1'b0;
                end
            end else begin
                done <= 1'b0;
            end
        end
    end

endmodule
