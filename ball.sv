//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input Reset, frame_clk, collided,
					input [1:0] game,
					input [7:0] keycode,
               output [9:0]  BallX, BallY, BallS,
			   output startRandom );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
	 logic [1:0] game_state; //00 normal, 01 inverted, 10 flappy bird, 11 zigzag
	 assign game_state = game;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
	
	 parameter [9:0] floor = 429;
	 parameter [9:0] ceiling = 50;
	 
	 logic [9:0] gravity;
	 
    assign Ball_Size = 8;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 
	 always_ff @ (posedge frame_clk) begin
		unique case (game_state)
			2'b00: begin
				gravity = 2;
			end
			2'b01: begin
				gravity = -2;
			end
		endcase
	 end
	 
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= floor;
				Ball_X_Pos <= 9;
        end
           
        else 
        begin 
				 if ( (Ball_Y_Pos) >= floor || (Ball_Y_Pos) <= ceiling)  // Ball is at the floor, dont move
				 begin
					  Ball_Y_Motion <= 0;  // 2's complement
				 end
				 else if ( (Ball_Y_Pos) < floor && (Ball_Y_Pos) > ceiling )  // Ball is not at floor, gravity
					  Ball_Y_Motion <= Ball_Y_Motion + gravity;
					  
				 if ( (Ball_X_Pos ) <= 210 )  // Ball is at the middle place stop
				 begin
					  //Ball_X_Motion <= 0;  // 2's complement.
					  startRandom <= 0;
					  if(keycode == 8'h07)
					  	begin
								  Ball_X_Motion <= 5;//D
								  Ball_Y_Motion <= 0;
								  //game_state <= 2'b01;
						end
				 end
				 else if (Ball_Y_Pos == floor && !collided) begin	 
					Ball_X_Motion <= 0;
					startRandom <= 1;
					 case (keycode)
						8'h2c : begin
								  Ball_Y_Motion <= -20;//space
								  Ball_X_Motion <= 0;
								 end	  
						default: begin
						// 	if(Ball_Y_Motion != 10'b0 && Ball_X_Motion != 10'b0)
						// 		Ball_X_Motion <= 10'b0;
						
						//   Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
						//   Ball_X_Motion <= Ball_X_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
						  end
					
					endcase
				end
				else if (Ball_Y_Pos == ceiling && !collided) begin	 
					Ball_X_Motion <= 0;
					startRandom <= 1;
					case (keycode)
						8'h2c : begin
								  Ball_Y_Motion <= 20;//space
								  Ball_X_Motion <= 0;
								 end	  
					endcase
				end
				else if(collided)
					startRandom = 0;

				if((Ball_Y_Pos) > floor)
					Ball_Y_Pos <= floor;
				else if ((Ball_Y_Pos) < ceiling)
					Ball_Y_Pos <= ceiling;
				else
				 	Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position

				 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
			
			
	  /**************************************************************************************
	    ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
		 Hidden Question #2/2:
          Note that Ball_Y_Motion in the above statement may have been changed at the same clock edge
          that is causing the assignment of Ball_Y_pos.  Will the new value of Ball_Y_Motion be used,
          or the old?  How will this impact behavior of the ball during a bounce, and how might that 
          interact with a response to a keypress?  Can you fix it?  Give an answer in your Post-Lab.
      **************************************************************************************/
      
			
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule
