`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2026 20:25:39
// Design Name: 
// Module Name: emergency_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module emergency_controller
    #(parameter HOLD_CYCLES = 7 ,
         parameter width =3)
    
(
    input clk,
    input rst_n,
    input emergency_in,
    output reg emergency_active
    );
    reg [width-1:0] count;
    always@(posedge clk or negedge rst_n) begin 
        if(!rst_n) begin 
            count <= {width{1'b0}};
            emergency_active <= 1'b0;
        end
        else begin 
            if(emergency_in)begin
                emergency_active <= 1'b1;
                count <= {width{1'b0}};
                end
           else begin 
            if (emergency_active) begin
                if (count < HOLD_CYCLES -1 ) begin
                    count <= count + 1'b1;
                end 
                else begin
                    emergency_active <= 1'b0;
                    count  <= {width{1'b0}};
                end
          end
          else begin 
            count <= {width{1'b0}};
            emergency_active <= 1'b0;
           end
        
        end
       end
    end
endmodule
