module generic_timer (
    input clk,
    input start,
    input [3:0] target,
    input rst_n,
    output reg done
);

    reg [3:0] count;

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 4'd0;
            done  <= 1'b0;
        end
        else begin
           count <= 4'd1;
           if(count == target) begin
            done <=1'b1;
            end
                else begin
                count <= count+1;
                end
           
        end
    end

endmodule