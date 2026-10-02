module generic_timer_tb;
 reg clk;
 reg start;
 reg rst_n;
 reg [3:0] target;
 wire done;
     generic_timer dut ( .clk(clk), .start(start) , .rst_n(rst_n) , .target(target) , .done(done));
     
     always #10 clk = ~clk;
   initial begin 
     $monitor ("time =%0t | start =%b | rst_n =% b | target =%b(%0d) | done =% b",$time,clk,start,rst_n , target , done );
    
    clk = 0 ;
    rst_n =0;
    #20;
    rst_n = 1;
    start = 1;
    target = 14;
    #10 ;
    start = 0 ;
    #400;
   
    $finish;
    end
endmodule
