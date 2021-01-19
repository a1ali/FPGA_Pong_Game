`timescale 1ns / 1ps

module pong(
		input CLK, //Elbert V2 12MHz
		input start_btn,
		input up_button,
		input down_button,
		input p2_up_button,
		input p2_down_button,
		output HS,
		output VS,
		output reg [7:0] RGB,
		output [3:0] p1_score, //first one to reach 3 wins 
		output [3:0] p2_score,
		output [7:0] SEG,
		output [2:0] ENABLE
    );

//---------------------------------
//VGA Instance
//---------------------------------
wire [9:0] x, y;
wire blank;

vga v(.CLK (CLK), .HS (HS), .VS (VS), .x (x), .y (y), .blank (blank));

//---------------------------------
//Debounce Instance
//---------------------------------
//Debounce input switches
wire start;
reg game_start = 1'b1;
debouncer start_button(.CLK (CLK), .switch_input(start_btn), .trans_dn(start));
wire gamestop; //if one of the player wins set to 1

//if start button pressed toggle game_start
always @(posedge CLK)
 begin
	if(start)
		game_start <= ~game_start;
	else if (gamestop)
		game_start <= ~game_start;
 end
//debouncer down_inst(.CLK (CLK), .switch_input(down_button), .trans_dn(down_btn));


//------------------------------------------------------------------
//										constants
//------------------------------------------------------------------
localparam MAX_X = 640;
localparam MAX_Y = 480;
localparam prescaler = 200000; //slow movement to only update once every 60Hz

//---------------------------------
//object signals for VGA
//---------------------------------
wire wall_on, bar_on, rd_ball_on, bar2_on;
wire [7:0] wall_rgb, bar_rgb, bar2_rgb, ball_rgb;

//------------------------------------------------------------------
//										body
//------------------------------------------------------------------

//---------------------------------
//Paddle Instances
//---------------------------------

//left x of paddles
localparam left_paddle = 580;
localparam right_paddle = 20;

wire [9:0] BAR_X_L, BAR_X_R, BAR_Y_T, BAR_Y_B;
wire [9:0] BAR2_X_L, BAR2_X_R, BAR2_Y_T, BAR2_Y_B;

//left paddle
paddle p1(.CLK(CLK), .prescaler(prescaler), .x(x), .y(y), 
			 .x_pos(left_paddle), .up_button(up_button), .down_button(down_button), .paddle_on(bar_on), .bar_rgb(bar_rgb),
			.BAR_X_L(BAR_X_L), .BAR_X_R(BAR_X_R), .BAR_Y_T(BAR_Y_T), .BAR_Y_B(BAR_Y_B));

//right paddle		
paddle p2(.CLK(CLK), .prescaler(prescaler), .x(x), .y(y), 
			 .x_pos(right_paddle), .up_button(p2_up_button), .down_button(p2_down_button), .paddle_on(bar2_on), .bar_rgb(bar2_rgb),
			.BAR_X_L(BAR2_X_L), .BAR_X_R(BAR2_X_R), .BAR_Y_T(BAR2_Y_T), .BAR_Y_B(BAR2_Y_B));

//---------------------------------
//Ball Instance
//---------------------------------

ball ball(.CLK(CLK), .start(game_start) , .prescaler(prescaler), .x(x), .y(y), 
			 .BAR_X_L(BAR_X_L), .BAR_X_R(BAR_X_R), .BAR_Y_T(BAR_Y_T), .BAR_Y_B(BAR_Y_B),
			 .BAR2_Y_T(BAR2_Y_T), .BAR2_Y_B(BAR2_Y_B), .BAR2_X_R(BAR2_X_R), .BAR2_X_L(BAR2_X_L),
			 .rd_ball_on(rd_ball_on), .ball_rgb(ball_rgb), .p1_score(p1_score), .p2_score(p2_score), .gamestop(gamestop));

//---------------------------------
//7 Segment Score Instance
//---------------------------------

refresh_7_seg seg(.CLK(CLK), .p1_score(p1_score), .p2_score(p2_score), .SEG(SEG), .ENABLE(ENABLE));


//---------------------------------
//Font to display instance
//---------------------------------
wire text_bit_on, number_on_left, number_on_right, start_region_on;

font2display font(
		.CLK(CLK),
		.p1_score(p1_score),
		.p2_score(p2_score),
		.x(x),
		.y(y),
		//output HS,
		//output VS,
		//output reg [7:0] RGB
		.text_bit_on(text_bit_on),
		.number_on(number_on_left),
		.number_on_right(number_on_right),
		.start_region_on(start_region_on)
    );

//------------------------------------------------------------------
//									Multiplexing Circuit
//------------------------------------------------------------------
//rgb multiplexing circuit 
always @*
begin
	if (blank)
		RGB <= 8'd0;
	else
	 begin
	 
	 if(game_start == 1'b0)
		if (start_region_on)
			RGB <= 8'b000_111_11;
		else 
			RGB <= 8'd0;
	else	
	 begin
			if (bar_on)
				RGB <= bar_rgb;
			
			else if (rd_ball_on)
				RGB <= ball_rgb;
		
			else if (bar2_on)
				RGB <= bar_rgb;
				
			else if (text_bit_on)
				RGB <= 8'b000_111_11;

			else if (number_on_left)
				RGB <= 8'b000_111_11;

			else if (number_on_right)
				RGB <= 8'b000_111_11;
			
			else 
				RGB <= 8'd0;
		
		
		end	
	 end
end					  

endmodule
