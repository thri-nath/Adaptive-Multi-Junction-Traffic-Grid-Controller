module reset_sync (
    input  wire clk,
    input  wire rst_n_async,
    output wire rst_n_sync
);

    reg sync_ff1;
    reg sync_ff2;

    always @(posedge clk or negedge rst_n_async) begin
        if (!rst_n_async) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= 1'b1;
            sync_ff2 <= sync_ff1;
        end
    end

    assign rst_n_sync = sync_ff2;

endmodule