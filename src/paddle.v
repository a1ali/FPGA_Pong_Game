`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:52:59 01/13/2021 
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
module paddle(
		input CLK,
		input [21:0] prescaler,
		input [9:0] x,
		input [9:0] y,
		input [9:0] x_pos,
		input up_button,
		input down_button,
		output paddle_on,
		output [7:0] bar_rgb,
		output [9:0] BAR_X_L,
		output [9:0] BAR_X_R,
		output [9:0] BAR_Y_T,
		output [9:0] BAR_Y_B
    );

localparam MAX_Y = 480;
localparam PADDLE_WIDTH = 3;	
assign BAR_X_L = x_pos;
assign BAR_X_R = BAR_X_L + PADDLE_WIDTH;

//bar top, bottom boundary
localparam BAR_Y_SIZE = 72;
reg [9:0] BAR_Y_T_P = MAX_Y/2-BAR_Y_SIZE/2; //204
assign BAR_Y_T = BAR_Y_T_P;
assign BAR_Y_B = BAR_Y_T_P+BAR_Y_SIZE-1;
localparam BAR_V = 4;

//---------------------------------
//Paddle Logic
//---------------------------------
assign paddle_on = (BAR_X_L <= x) && (x <= BAR_X_R) &&
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
		
		if (~up_button & (BAR_Y_T_P > BAR_V))
		 begin
			BAR_Y_T_P <= BAR_Y_T_P - BAR_V;
		 end
		 
		else if (~down_button)
		 begin
			if (BAR_Y_B < (MAX_Y-1-BAR_V))
				BAR_Y_T_P <= BAR_Y_T_P + BAR_V;
		 end
	end
 end


endmodule
