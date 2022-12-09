//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( 
    input       is_flipped, will_collide, is_column_flipped,
    input       [9:0] BallX, BallY, DrawX, DrawY, Ball_size, 
    input       [10:0] Triangle_X, Triangle_Y, Column_X,
    output logic [7:0]  Red, Green, Blue 
);
    
    logic ball_on;
    logic column_on;
    logic floor_on;
	logic ceiling_on;
    logic triangle_on;

    logic [9:0] Local_Y0, Local_Y1;
    // assign Triangle_X  = 320;
    // assign Triangle_Y = 240;
	 
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
    // int DistX, DistY, Size;
	// assign DistX = DrawX - BallX;
    // assign DistY = DrawY - BallY;
    // assign Size = Ball_size;
	  
    always_comb
    begin:Ball_on_proc
        if ((DrawX >= BallX - Ball_size) &&
            (DrawX <= BallX + Ball_size) &&
            (DrawY >= BallY - Ball_size) &&
            (DrawY <= BallY + Ball_size))
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
    end 
    

    // localy = DrawY - Triangle_y + 4

    // if Triangle_y - 4 <= y <= triangle_y+8
    //      if localy in [0,1] and x in [trianglex-1, trianglex+1]
    //            triangle_on=1
    //      if localy in [2,3] and x in [trianglex-2, trianglex+2)
    //            triangle_on=1
    //      if localy in [2,3] and x in [trianglex-2, trianglex+2)
    //            triangle_on=1

    // use switch unique case
    assign Local_Y0 = DrawY - Triangle_Y + 4;
    assign Local_Y1 = DrawY - Triangle_Y + 8;

    always_comb
    begin:Triangle_on_proc
        if (is_flipped)
            unique case (Local_Y1)
                0: 
                begin
                    if ((DrawX >= Triangle_X-7) && (DrawX <= Triangle_X+8))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                1: 
                begin
                    if ((DrawX >= Triangle_X-7) && (DrawX <= Triangle_X+7))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                2,3: 
                begin
                    if ((DrawX >= Triangle_X-6) && (DrawX <= Triangle_X+6))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                4,5: 
                begin
                    if ((DrawX >= Triangle_X-5) && (DrawX <= Triangle_X+5))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                6: 
                begin
                    
                    if ((DrawX >= Triangle_X-4) && (DrawX <= Triangle_X+4))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                7,8: 
                begin
                    if ((DrawX >= Triangle_X-3) && (DrawX <= Triangle_X+3))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                9,10: 
                begin
                    if ((DrawX >= Triangle_X-2) && (DrawX <= Triangle_X+2))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                11,12: 
                begin
                    if ((DrawX >= Triangle_X-1) && (DrawX <= Triangle_X+1))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                default:
                    triangle_on = 0;
            endcase
        else
            unique case (Local_Y0)
                0,1: 
                begin
                    if ((DrawX >= Triangle_X-1) && (DrawX <= Triangle_X+1))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                2,3: 
                begin
                    if ((DrawX >= Triangle_X-2) && (DrawX <= Triangle_X+2))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                4,5: 
                begin
                    if ((DrawX >= Triangle_X-3) && (DrawX <= Triangle_X+3))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                6: 
                begin
                    if ((DrawX >= Triangle_X-4) && (DrawX <= Triangle_X+4))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                7,8: 
                begin
                    if ((DrawX >= Triangle_X-5) && (DrawX <= Triangle_X+5))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                9,10: 
                begin
                    if ((DrawX >= Triangle_X-6) && (DrawX <= Triangle_X+6))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                11: 
                begin
                    if ((DrawX >= Triangle_X-7) && (DrawX <= Triangle_X+7))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                12: 
                begin
                    if ((DrawX >= Triangle_X-7) && (DrawX <= Triangle_X+8))
                        triangle_on=1;
                    else
                        triangle_on=0;
                end
                default:
                    triangle_on = 0;
            endcase
    end 
       
    always_comb
    begin:Column_on_proc
        if ((((DrawX >= Column_X - 4) &&
         (DrawX <= Column_X + 4) )
          &&
         ((DrawY <= 240 - 90) ||
         (DrawY >= 240 + 90)))
          &&
          (!floor_on && !ceiling_on)

        )
            column_on = 1'b1;
        else 
            column_on = 1'b0;
    end 
       
    always_comb
    begin:floor_on_proc
        if ((DrawY <= 42))
            ceiling_on = 1'b1;
        else 
            ceiling_on = 1'b0;
    end 
	 
	 always_comb
    begin:ceiling_on_proc
        if ((DrawY >= 437))
            floor_on = 1'b1;
        else 
            floor_on = 1'b0;
    end 

    always_comb
    begin:RGB_Display
        if ((triangle_on || column_on)) 
        begin 
            // if(will_collide) begin
            // Red = 8'hff;
            // Green = 8'h00;
            // Blue = 8'h00;
            // end
            // else begin
            Red = 8'h0;
            Green = 8'hf9;
            Blue = 8'hff;
            // end
        end     
        // else if( (DrawY == Triangle_Y - 4 ) || (DrawY == Triangle_Y + 4 ) || (DrawX == Triangle_X - 8) || (DrawX == Triangle_X + 8))
        // begin
        //     Red = 8'h0;
        //     Green = 8'hff;
        //     Blue = 8'h0;
        // end
        else if (floor_on || ceiling_on) 
        begin 
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
        else if (ball_on)
		  begin
            Red = 8'hff;
            Green = 8'h55;
            Blue = 8'h00;
        end 
        else 
        begin 
            Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'h00;
        end      
    end 
    
endmodule
