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
		output reg [7:0] RGB
    );

wire [9:0] x, y;
wire blank;

vga v(.CLK (CLK), .HS (HS), .VS (VS), .x (x), .y (y), .blank (blank));

//Debounce input switches
wire start;
reg game_start = 1'b1;
debouncer start_button(.CLK (CLK), .switch_input(start_btn), .trans_dn(start));

always @(posedge CLK)
 begin
	if(start)
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
paddle p1(.CLK(CLK), .prescaler(prescaler), .x(x), .y(y), .x_pos(left_paddle), .up_button(up_button), .down_button(down_button), .paddle_on(bar_on), .bar_rgb(bar_rgb),
			.BAR_X_L(BAR_X_L), .BAR_X_R(BAR_X_R), .BAR_Y_T(BAR_Y_T), .BAR_Y_B(BAR_Y_B));

//right paddle		
paddle p2(.CLK(CLK), .prescaler(prescaler), .x(x), .y(y), .x_pos(right_paddle), .up_button(p2_up_button), .down_button(p2_down_button), .paddle_on(bar2_on), .bar_rgb(bar2_rgb),
			.BAR_X_L(BAR2_X_L), .BAR_X_R(BAR2_X_R), .BAR_Y_T(BAR2_Y_T), .BAR_Y_B(BAR2_Y_B));

//---------------------------------
//Ball Instances
//---------------------------------

ball ball(.CLK(CLK), .start(game_start) , .prescaler(prescaler), .x(x), .y(y), .BAR_X_L(BAR_X_L), .BAR_X_R(BAR_X_R), .BAR_Y_T(BAR_Y_T), .BAR_Y_B(BAR_Y_B),
			 .BAR2_Y_T(BAR2_Y_T), .BAR2_Y_B(BAR2_Y_B), .BAR2_X_R(BAR2_X_R), .BAR2_X_L(BAR2_X_L), .rd_ball_on(rd_ball_on), .ball_rgb(ball_rgb));


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
		if (bar_on)
			RGB <= bar_rgb;
			
		else if (rd_ball_on)
			RGB <= ball_rgb;
		
		else if (bar2_on)
			RGB <= bar_rgb;
			
		else 
			RGB <= 8'd0;
	 end
end					  

endmodule
