module testbench();

timeunit 10ns;
timeprecision 1ns;

logic[5:0] count = 6'b0;

logic LRCLK;
assign LRCLK = count[5];

logic SCLK;
always begin: CLOCK_GENERATION
#1 SCLK = ~SCLK;
count = count + 1;
end

initial begin: CLOCK_INITIALIZATION
SCLK = 0;
LRCLK = 0;
end

logic play, dout;

I2S_Interface i2s(.PLAYPLEASE(play), .LRCLK(LRCLK), .SCLK(SCLK), .D_OUT(dout));

initial begin: TEST_VECTORS
play = 0;
#10
play = 1;
#11000
play = 0;
end

endmodule