`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:43:57 01/11/2021 
// Design Name: 
// Module Name:    paddle 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pong(
		input CLK, //Elbert V2 12MHz
		input up_button,
		input down_button,
		output HS,
		output VS,
		output reg [7:0] RGB
    );

wire [9:0] x, y;
wire blank;
vga v(.CLK (CLK), .HS (HS), .VS (VS), .x (x), .y (y), .blank (blank));

//Debounce input switches
wire up_btn , down_btn;
//debouncer up_inst(.CLK (CLK), .switch_input(up_button), .trans_dn(up_btn));
//debouncer down_inst(.CLK (CLK), .switch_input(down_button), .trans_dn(down_btn));


//---------------------------------
//				constants
//---------------------------------
localparam MAX_X = 640;
localparam MAX_Y = 480;
localparam prescaler = 200000; //slow movement to only update once every 60Hz
wire tick; // will toggle once every 60HZ

// wall left, right boundary
localparam WALL_X_L = 32;
localparam WALL_X_R = 35;

//---------------------------------
//paddle
//---------------------------------
localparam BAR_X_L = 580;
localparam BAR_X_R = 583;

//bar top, bottom boundary
localparam BAR_Y_SIZE = 72;
reg [9:0] BAR_Y_T = MAX_Y/2-BAR_Y_SIZE/2; //204
wire [9:0] BAR_Y_B;
assign BAR_Y_B = BAR_Y_T+BAR_Y_SIZE-1;
localparam BAR_V = 4;

//---------------------------------
//square ball
//---------------------------------
localparam BALL_SIZE = 8;
localparam BALL_V_P = 2;
localparam BALL_V_N = -2;
// BALL LEFT, RIGHT BOUNDARY
reg [9:0] BALL_X_L = 500;
wire [9:0] BALL_X_R;
reg [9:0] BALL_Y_T = 238;
wire [9:0] BALL_Y_B;
reg [9:0] x_delta = BALL_V_P; 
reg [9:0] y_delta;
//assign BALL_X_L = 500;
assign BALL_X_R = BALL_X_L+BALL_SIZE-1;
//ball top, bottom boundary
//assign BALL_Y_T = 238;
assign BALL_Y_B = BALL_Y_T+BALL_SIZE-1;

reg [9:0] p_x_del = BALL_V_P;
reg [9:0] p_y_del;

//---------------------------------
//object signals
//---------------------------------
wire wall_on, bar_on, sq_ball_on;
wire [7:0] wall_rgb, bar_rgb, ball_rgb;

//---------------------------------
//					body
//---------------------------------

assign tick = (y==481) && (x ==0);
//---------------------------------
//Wall Logic
//---------------------------------
//pixel within wall 
assign wall_on = (WALL_X_L <= x) && (x <= WALL_X_R);
//wall rgb output 
assign wall_rgb = 8'b000_000_11; //blue 

//---------------------------------
//Paddle Logic
//---------------------------------
assign bar_on = (BAR_X_L <= x) && (x <= BAR_X_R) &&
					 (BAR_Y_T <= y) && (y <= BAR_Y_B);
//bar rgb output 
assign bar_rgb = 8'b000_111_00;
reg [21:0] counter;
always @(posedge CLK)
 begin
	counter <= counter + 1;
	if (counter == prescaler)
	begin
	counter <= 0;
	if (~up_button & (BAR_Y_T > BAR_V))
	 begin
		BAR_Y_T <= BAR_Y_T - BAR_V;
	 end
	 
	else if (~down_button & (BAR_Y_B <(MAX_Y-1-BAR_V)))
	 begin
		BAR_Y_T <= BAR_Y_T + BAR_V;
	 end
	 end
 end

//---------------------------------
//Ball Logic
//---------------------------------
//square ball
//rom for ball
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
assign rom_addr = y[2:0] - BALL_Y_T[2:0];
assign rom_col = x[2:0] - BALL_X_L[2:0];
assign rom_bit = rom_data[rom_col];
//pixel within ball
assign rd_ball_on = sq_ball_on & rom_bit;				 		  
assign ball_rgb = 8'b111_000_00;	

reg [21:0] ball_counter;
always @(posedge CLK)
 begin
	ball_counter <= ball_counter + 1;
	if (ball_counter == prescaler)
	begin
		ball_counter <= 0;
	 
		if (BALL_Y_T < 1) //reach top
		 begin
			//y_delta <= BALL_V_P;
			BALL_Y_T <= BALL_Y_T + BALL_V_P;
			p_y_del <= BALL_V_P;
		 end
		
		else if (BALL_Y_B > (MAX_Y -1 )) //reach bottom 
		 begin
			//y_delta <= BALL_V_N;
			BALL_Y_T <= BALL_Y_T + BALL_V_N;
			p_y_del <= BALL_V_N;
		 end
			
		else if (BALL_X_L <= WALL_X_R) //reach wall
		 begin
			//x_delta <= BALL_V_P;
			BALL_X_L <= BALL_X_L + BALL_V_P;
			p_x_del <= BALL_V_P;
		 end
			
		else if ((BAR_X_L <= BALL_X_R) && (BALL_X_R <= BAR_X_R) && (BAR_Y_T <= BALL_Y_B) && (BALL_Y_T <= BAR_Y_B))
		 begin
			//x_delta <= BALL_V_N;
			BALL_X_L <= BALL_X_L + BALL_V_N;
			p_x_del <= BALL_V_N;
			//BALL_X_L
			//BALL_Y_T
		 end
		 
		else 
		 begin
			BALL_Y_T <= BALL_Y_T + p_y_del;
			BALL_X_L <= BALL_X_L + p_x_del;
		 end
		
	 end
 end

//---------------------------------
//			Multiplexing Circuit
//---------------------------------
//rgb multiplexing circuit 
always @*
begin
	if (blank)
		RGB <= 8'd0;
	else
	 begin
		if(wall_on)
			RGB <= wall_rgb;
		
		else if (bar_on)
			RGB <= bar_rgb;
			
		else if (rd_ball_on)
			RGB <= ball_rgb;
			
		else 
			RGB <= 8'd0;
	 end
end					  

endmodule
