`timescale 1ns / 1ps

module ball(
		input CLK,
		input start,
		input [21:0] prescaler,
		input [9:0] x,
		input [9:0] y,
		input [9:0] BAR_X_L,
		input [9:0] BAR_X_R,
		input [9:0] BAR_Y_T,
		input [9:0] BAR_Y_B,
		input [9:0] BAR2_Y_T,
		input [9:0] BAR2_Y_B,
		input [9:0] BAR2_X_R,
		input [9:0] BAR2_X_L,
		output rd_ball_on,
		output [7:0] ball_rgb,
		output reg [3:0] p1_score,
		output reg [3:0] p2_score,
		output reg gamestop
		//output reg start
    );
	 
localparam MAX_Y = 480;
localparam MAX_X = 640;
localparam BALL_SIZE = 8;
localparam BALL_V_P = 2; //positive velocity 
localparam BALL_V_N = -2; //negative velocity

wire sq_ball_on;

// BALL LEFT, RIGHT BOUNDARY
reg [9:0] BALL_X_L = MAX_X/2 - 40; //left x of ball init to middle 
wire [9:0] BALL_X_R; //right x of ball
reg [9:0] BALL_Y_T = MAX_Y/2; //top y of ball init to center
wire [9:0] BALL_Y_B; //bottom y of ball
assign BALL_X_R = BALL_X_L+BALL_SIZE-1;
assign BALL_Y_B = BALL_Y_T+BALL_SIZE-1;

//store previous directions
reg [9:0] p_x_del = BALL_V_P; 
reg [9:0] p_y_del;

//---------------------------------
//Ball Logic
//---------------------------------
//rom for round ball
wire [2:0] rom_addr;
reg [7:0] rom_data;
wire [2:0] rom_col;
always @*
case(rom_addr) //Pattern ROM to make round ball
	3'h0: rom_data = 8'b00111100;
	3'h1: rom_data = 8'b01111110;
	3'h2: rom_data = 8'b11111111;
	3'h3: rom_data = 8'b11111111;
	3'h4: rom_data = 8'b11111111;
	3'h5: rom_data = 8'b11111111;
	3'h6: rom_data = 8'b01111110;
	3'h7: rom_data = 8'b00111100;
endcase

//pixel within squareball
assign sq_ball_on = (BALL_X_L<= x) && (x <= BALL_X_R) &&
						  (BALL_Y_T<= y) && (y <= BALL_Y_B);

//map current pixel location to rom addr/col
assign rom_addr = y[2:0] - BALL_Y_T[2:0]; //gets ROM row
assign rom_col = x[2:0] - BALL_X_L[2:0];  //gets ROM col
assign rom_bit = rom_data[rom_col];
//pixel within ball
assign rd_ball_on = sq_ball_on & rom_bit;				 		  
assign ball_rgb = 8'b111_000_00;	

reg [21:0] ball_counter;
always @(posedge CLK)
 begin
	if(start)
	 begin
		ball_counter <= ball_counter + 1;
		if (ball_counter == prescaler)
		begin
			ball_counter <= 0;
			gamestop <= 1'b0; //gamestop fas
			if (BALL_Y_T < 1) //reach top
			begin
				BALL_Y_T <= BALL_Y_T + BALL_V_P;
				p_y_del <= BALL_V_P;
			end
		
			else if (BALL_Y_B > (MAX_Y -1 )) //reach bottom 
			begin
				BALL_Y_T <= BALL_Y_T + BALL_V_N;
				p_y_del <= BALL_V_N;
			end
			
			else if ((BAR_X_L <= BALL_X_R) && (BALL_X_R <= BAR_X_R) && (BAR_Y_T <= BALL_Y_B) && (BALL_Y_T <= BAR_Y_B)) //hit left paddle
			begin
				BALL_X_L <= BALL_X_L + BALL_V_N;
				p_x_del <= BALL_V_N;
			end
		 
			else if ((BAR2_Y_T <= BALL_Y_T) & (BALL_Y_B <= BAR2_Y_B) & (BALL_X_L <= BAR2_X_R) & (BALL_X_L >= BAR2_X_L)) //hit right paddle	
			begin
				BALL_X_L <= BALL_X_L + BALL_V_P;
				p_x_del <= BALL_V_P;
			end
			
			else if (BALL_X_R > BAR_X_R)// go past the right paddle
			begin
				p1_score <= p1_score + 1; //increment player 1 score. 
				//recenter the ball
				BALL_X_L <= MAX_X/2 - 40;
				BALL_Y_T <= MAX_Y/2;
				if (p1_score == 4'd4) //game over p1 wins
				begin
					gamestop <= 1'b1; //stop the game reset score
					p1_score <= 0;
					p2_score <= 0;
				end	
			end
			
			else if (BALL_X_L < BAR2_X_L)// go past the left paddle
			begin
				p2_score <= p2_score + 1; //increment player 2 score. 
				//recenter the ball
				BALL_X_L <= MAX_X/2 - 40;
				BALL_Y_T <= MAX_Y/2;
				if (p2_score == 4'd4) //game over p2 wins
				begin
					gamestop <= 1'b1; //stop the game
					p1_score <= 0;
					p2_score <= 0;
				end	
			end
		 
			else //continue with previous motion direction 
			begin
				BALL_Y_T <= BALL_Y_T + p_y_del;
				BALL_X_L <= BALL_X_L + p_x_del;
			end
		end
	end
 end
endmodule
