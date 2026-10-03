module generic_timer_tb;
 reg clk;
 reg start;
 reg rst_n;
 reg [7:0] target;
 wire done;
 generic_timer #(.width(8)) dut ( .clk(clk), .start(start) , .rst_n(rst_n) , .target(target) , .done(done));
     
     always #10 clk = ~clk;
   initial begin 
     $monitor ("time =%0t | start =%b | rst_n =% b | target =%b(%0d) | done =% b",$time,clk,start,rst_n , target , done );
    clk    = 0;
        start  = 0;
        rst_n  = 0;
        target = 0;

       
        // Scenario 1: Active Reset Test
     
        #20;
        start  = 1;
        target = 4;
        #20;
        start  = 0;
        target = 0;

      
        // Scenario 2: Basic Single-Cycle Target Match (target = 1)
        
        #20;
        rst_n = 1;

        @(negedge clk);
        start  = 1;
        target = 1;

        @(negedge clk);
        start  = 0;

     
        // Scenario 3: Multi-Cycle Target Match (target = 9)
        
        #40;
        @(negedge clk);
        start  = 1;
        target = 9;

        @(negedge clk);
        start  = 0;

        #200;

        // Scenario 4: Maximum Target Boundary Test (target = 15)
        @(negedge clk);
        start  = 1;
        target = 25;

        @(negedge clk);
        start  = 0;

        #500;
        // Scenario 5: Zero Target Edge Case (target = 0)
        @(negedge clk);
        start  = 1;
        target = 0;

        @(negedge clk);
        start  = 0;

        #340;

        // Scenario 6: Mid-Count Reset
        @(negedge clk);
        start  = 1;
        target = 10;

        @(negedge clk);
        start  = 0;

        #100; // Wait for timer to reach mid-count
        rst_n  = 0;

        #40;
        rst_n  = 1;

        // Scenario 7: Restart During Active Count
        @(negedge clk);
        start  = 1;
        target = 8;

        @(negedge clk);
        start  = 0;

        #80; // Wait until count reaches 4
        @(negedge clk);
        start  = 1;
        target = 3; // Restart with new target

        @(negedge clk);
        start  = 0;

        #100;

        
        // Scenario 8: Idle Stability Check

        #100;
    
    
    
    $finish;
    end
endmodule
