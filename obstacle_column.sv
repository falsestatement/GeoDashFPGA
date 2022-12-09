//module obstacle_column
//(
//    input       is_flip_column, // indicates whether going past this column will flip gravity
//    input       Player_Y, Player_size,
//    input       Reset, frame_clk,
//	input       [9:0] Column_X,
//	output      will_collide, will_flip
//);
//
//// 210 is the hardcoded X position of the Column
//logic [9:0] PlayerColumn_center, Column_X_Pos, Column_X_Motion, Column_Size, Safebox_Center_Height, Safebox_size_h, Safebox_size_v;
//
//// The player column will be hardcoded(center of column is at 210 and will have a width equal to player model)
//assign PlayerColumn_center = 210;
//
//// hardcoded column size into the module
//assign Column_size = 8;  // assigns the value 8 as a 10-digit binary number, ie "0000001000"
//// The center of the column is a random integer within a certain distance from a surface that the Player will be able to pass through(a "safebox")
//// For some reason the unsigned integer random generator has parameter order as max num then min num in range
//assign Safebox_Center_Dist = $urandom_range(INSERT_MAX_HEIGHT_HERE, INSERT_MIN_HEIGHT_HERE);
//
//// Width of hitbox is same as width of column
//assign Safebox_size_h = Column_Size;
//// Height of hitbox is 1.5 times the height of the player
//assign Safebox_size_v = 12;
//
//assign Safebox_Center_bottom = 311 - Safebox_Center_Dist;
//assign Safebox_Center_top = 20 + Safebox_Center_Dist;
//
//always_comb
//begin
//    // Check if the Obstacle overlaps with the Player Column
//    if ((Column_X - Column_size <= PlayerColumn_center + Player_size) &&    // right side
//    (Column_X + Column_size <= PlayerColumn_center - Player_size))
//        // Now do vertical check
//        case(is_flip_column)
//            1'b0:
//                begin
//                    if ((Safebox_Center_bottom - Safebox_size_v >= Player_Y - Player_size) ||
//                    (Safebox_Center_bottom + Safebox_size_v >= Player_Y + Player_size)
//                        will_collide = 1'b1;
//                        Column_X_Motion <= 10'd0;
//                    else
//                        will_collide = 1'b0;
//                end
//            1'b1:
//                begin
//                    if ((Safebox_Center_top - Safebox_size_v >= Player_Y - Player_size) ||
//                    (Safebox_Center_top + Safebox_size_v >= Player_Y + Player_size)
//                        will_collide = 1'b1;
//                        Column_X_Motion <= 10'd0;
//                    else
//                        will_collide = 1'b0;
//                end
//        endcase
//    // now check if the column successfully passed by the player
//    else if ((Column_X + Column_size < PlayerColumn_center - Player_size) && is_flip_column)
//        begin
//            will_flip = 1'b1
//        end
//    else
//        // The triangle isn't overlapping with the player column
//        will_collide = 1'b0
//end	
//
//always_ff @ (posedge Reset or posedge frame_clk )
//begin: Move_Column
//    if (Reset)  // Asynchronous Reset
//    begin 
//            Column_X_Motion <= 10'd0;
//            Column_X_Pos <= TODO_INSERT_VALUE_HERE;
//    end
//    else 
//        Column_X_Pos <= (Column_X - Column_X_Motion); // doing a subtraction here since it's moving left
//    end 
//end 
//       
//assign Column_X = Column_X_Pos;
//assign Column_Y = Column_Y_Pos;
//
    

module obstacle_column
(
    input       start_moving,
    output       [1:0] game_state,
    input       [9:0] Player_Y, Player_size,
    input       Reset, frame_clk,
	output      [10:0] Column_X,
	output      will_collide, passed_through
);

// 210 is the hardcoded X position of the Column
logic [10:0] Column_X_Pos, Column_X_Motion;

// The player column will be hardcoded(center of column is at 210 and will have a width equal to player model)
parameter [9:0] PlayerColumn_center = 210;

// // The center of the safe area of the column will be 
// parameter [9:0] Safebox_Center_dist = 6;

// Hitbox is a rectangle. 
// Width of Safebox in both left and right directions 
parameter [9:0] Safebox_size_h = 4;
// Height of Safebox in both up and down directions
parameter [9:0] Safebox_size_v = 90;

parameter [9:0] Safebox_Center = 240;

// The center of the hitbox will be 6 away from the floor or ceiling based on inversion
// assign Hitbox_Center_bottom = 311 - 6;
// assign Hitbox_Center_top = 100 + 6;  // Set ceiling height to be 50

always_comb
begin
    if ( ( start_moving || ( (Column_X <= 635) && (Column_X >= 5) ) && will_collide == 0) )
        Column_X_Motion <= 10'd5;
    else
        Column_X_Motion <= 10'd0;
end


always_comb 
begin: passed_through_check
    if (Column_X  <  190 && Column_X > 0)
        passed_through = 1'b1;
    else
        passed_through = 1'b0;
end

always_ff @  (posedge passed_through)
begin
    if(game_state > 0)
        game_state <= 0;
    else
        game_state <= 1;
end

always_comb
begin: collision_check
// Check if the Obstacle overlaps with the Player Column
if (
    // Horizontal overlap check
    (((Column_X - Safebox_size_h <= PlayerColumn_center + Player_size) &&    // left of triangle goes into right side of column
    (Column_X + Safebox_size_h >= PlayerColumn_center + Player_size)) ||
    ((Column_X - Safebox_size_h >= PlayerColumn_center - Player_size) &&    // triangle within column
    (Column_X + Safebox_size_h <= PlayerColumn_center + Player_size)) ||
    ((Column_X - Safebox_size_h <= PlayerColumn_center - Player_size) &&    // right of triangle is within bounds of column
    (Column_X + Safebox_size_h >= PlayerColumn_center - Player_size))) 
// && 
//     // Vertical check
//     (((Player_Y - Player_size <= Column_Y - Safebox_size_v) &&    // top part of player collision
//     (Player_Y + Player_size >= Column_Y - Safebox_size_v)) ||
//     ((Player_Y - Player_size >= Column_Y - Safebox_size_v) &&    // middle part of collision
//     (Player_Y + Player_size <= Column_Y + Safebox_size_v)) ||
//     ((Player_Y - Player_size <= Column_Y + Safebox_size_v) &&    // bottom part of collision
//     (Player_Y + Player_size >= Column_Y + Safebox_size_v)))
    &&
    !((Player_Y - Player_size >= Safebox_Center - Safebox_size_v) && (Player_Y + Player_size <= Safebox_Center + Safebox_size_v))
)
    will_collide = 1'b1;
    // Column_X_Motion <= 10'd0;
else
    will_collide = 1'b0;
end

always_ff @ (posedge Reset or posedge frame_clk )
begin: Move_Column
    if (Reset)  // Asynchronous Reset
    begin 
            // Column_X_Motion <= 10'd0;
            // TODO: Initialize Triangle on the right side of the screen out of view(horizontal stuff)
            Column_X <= 640;
    end
    else if(Column_X < 10 || Column_X_Pos > 640)
        Column_X <= 640;
    else
        Column_X <= (Column_X - Column_X_Motion); // doing a subtraction here since it's moving left
end 
       
assign Column_Y = Safebox_Center;

// assign Column_X = 500;
// assign Column_Y = 317;

// assign Column_X = Column_X_Pos;
// assign Column_Y = Column_Y_Pos;

endmodule