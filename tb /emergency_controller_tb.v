`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2026 21:06:02
// Design Name: 
// Module Name: emergency_controller_tb
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


module emergency_controller_tb;
     
     reg clk;
     reg rst_n;
     reg emergency_in ;
     wire emergency_active;
     
     emergency_controller #(14,4) dut(.clk(clk) , .rst_n(rst_n),.emergency_in(emergency_in) , .emergency_active(emergency_active) );
     
     always #10 clk = ~clk ;//each cycle takes 20 units of time 
     initial begin 
     $monitor ("time =%0t | rst_n =%0b | emergency_in =%0b | emergency_active =%0b" , $time , rst_n , emergency_in , emergency_active);
     // Initial State
        clk          = 0;
        rst_n        = 0;
        emergency_in = 0;

        // Case 1: Active Reset Test
        #40;
        rst_n = 1;
        #20;

        // Case 2: Emergency active for 3 cycles (60ns), total active = 3 + 14 = 17 cycles
        @(negedge clk);
        emergency_in = 1;
        #60;
        @(negedge clk);
        emergency_in = 0;
        #300; // Wait for HOLD_CYCLES (14 * 20ns = 280ns) to finish and deassert

        // Case 3: Reset asserted during active emergency
        @(negedge clk);
        emergency_in = 1;
        #60;
        rst_n = 0;        // Assert reset mid-emergency
        emergency_in = 0;  // Clear emergency request during reset
        #40;
        rst_n = 1;        // Release reset to observe clean recovery
        #400;
     $finish;
     end
 
endmodule
