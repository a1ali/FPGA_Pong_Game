`timescale 1ns / 1ps

module font2display(
		input CLK,
		input [3:0] p1_score,
		input [3:0] p2_score,
		input [9:0] x,
		input [9:0] y,
		output text_bit_on,
		output number_on,
		output number_on_right,
		output start_region_on
    );

reg [9:0] buff_x, buff_y;
always @(posedge CLK)
	begin
		buff_x <= x;
		buff_y <= y;
	end

wire [10:0] rom_addr;
wire [6:0] char_addr;
wire [3:0] row_addr;
wire [2:0] bit_addr;
wire [7:0] font_word;
wire font_bit;

reg [6:0] char_addr_l;


font_rom font_unit(.CLK(CLK), .addr(rom_addr), .data(font_word));
//font ROM interface
//assign char_addr = {buff_y[6:5], buff_x[8:4]};
assign row_addr = buff_y[4:1]; //incremtns through the rows in a font
assign rom_addr = {char_addr_l, row_addr};
assign bit_addr = buff_x[3:1]; //increments through individal bit in a column. 

//need the ~ because we need to read the font in asscending order
assign font_bit = font_word[~bit_addr];

// "on" region limited to top-middle
wire logo_on;
assign logo_on = (x >= 272 & x<= 336 & y>0 & y <=32);
assign text_bit_on = (logo_on)? font_bit :1'b0;


//using x[6:4] as a counter that increments every 8th time
//this allows for cycling through tiles 
always @*
	case(x[6:4])
		3'b001: char_addr_l = 7'h50; //P
		3'b010: char_addr_l = 7'h4f; //O
		3'b011: char_addr_l = 7'h4e; //N
		3'b100: char_addr_l = 7'h47; //G
	endcase


/////////////////////////////////////
//
//number on top left 
//
/////////////////////////////////////


wire [10:0] num_rom_addr;
wire [7:0] num_font_word;

font_rom num_unit(.CLK(CLK), .addr(num_rom_addr), .data(num_font_word));


reg [6:0] char_addr_num;
wire num_bit;
assign num_rom_addr = {char_addr_num, row_addr};
wire number_region;
//wire number_on;
assign number_region = (x>16 & x<=32 & y>0 & y<32);
assign number_on = (number_region)? num_bit: 1'b0;
assign num_bit = num_font_word[~bit_addr];


always @(posedge CLK)
	case(p1_score)
		4'd0: char_addr_num <= 7'h30; //0
		4'd1: char_addr_num <= 7'h31; //1
		4'd2: char_addr_num <= 7'h32; //2
		4'd3: char_addr_num <= 7'h33; //3
		4'd4: char_addr_num <= 7'h34; //4
		4'd5: char_addr_num <= 7'h35; //5
		4'd6: char_addr_num <= 7'h36; //6
		4'd7: char_addr_num <= 7'h37; //7
		4'd8: char_addr_num <= 7'h38; //8
		4'd9: char_addr_num <= 7'h39; //9
	endcase
	
/////////////////////////////////////
//
//number on top right
//
/////////////////////////////////////


wire [10:0] num_rom_addr_r;
wire [7:0] num_font_word_r;

font_rom num_unit_2(.CLK(CLK), .addr(num_rom_addr_r), .data(num_font_word_r));


reg [6:0] char_addr_num_2;
wire num_bit_2;
assign num_rom_addr_r = {char_addr_num_2, row_addr};
wire number_region_right;
//wire number_on_right;
assign number_region_right = (x>544& x<=560 & y>0 & y<32);
assign number_on_right = (number_region_right)? num_bit_2: 1'b0;
assign num_bit_2 = num_font_word_r[~bit_addr];

//reg [6:0] char_addr_num;

always @(posedge CLK)
	case(p2_score)
		4'd0: char_addr_num_2 <= 7'h30; //0
		4'd1: char_addr_num_2 <= 7'h31; //1
		4'd2: char_addr_num_2 <= 7'h32; //2
		4'd3: char_addr_num_2 <= 7'h33; //3
		4'd4: char_addr_num_2 <= 7'h34; //4
		4'd5: char_addr_num_2 <= 7'h35; //5
		4'd6: char_addr_num_2 <= 7'h36; //6
		4'd7: char_addr_num_2 <= 7'h37; //7
		4'd8: char_addr_num_2 <= 7'h38; //8
		4'd9: char_addr_num_2 <= 7'h39; //9
	endcase
	
	
/////////////////////////////////////
//
//start screen
//
/////////////////////////////////////


wire [10:0] num_rom_addr_start_screen;
wire [7:0] num_font_word_start_screen;

font_rom start_screen(.CLK(CLK), .addr(num_rom_addr_start_screen), .data(num_font_word_start_screen));


reg [6:0] char_addr_num_start_screen;
wire num_bit_start_screen;
assign num_rom_addr_start_screen = {char_addr_num_start_screen, row_addr};
wire start_region_right;
//wire start_region_on;
assign start_region_right = (x >= 1 & x<= 450 & y>224 & y<256);
//assign start_region_right = (y[9:5] == 0 & x[9:4]<16);
//assign start_region_right = ((x[9:7]==2) && (y[9:6]==2));
assign start_region_on = (start_region_right)? num_bit_start_screen: 1'b0;
assign num_bit_start_screen = num_font_word_start_screen[~bit_addr];

//wire [5:0] rule_rom_addr;
//assign rule_rom_addr = {y[5:4], x[6:3]};



always @*
	case(x[8:4])
		5'b00001: char_addr_num_start_screen = 7'h50;//p
		5'b00010: char_addr_num_start_screen = 7'h52;//r
		5'b00011: char_addr_num_start_screen = 7'h45;//e
		5'b00100: char_addr_num_start_screen = 7'h53;//s
		5'b00101: char_addr_num_start_screen = 7'h53;//s 
		5'b00110: char_addr_num_start_screen = 7'h0; //h0		
		5'b00111: char_addr_num_start_screen = 7'h53; //S
		5'b01000: char_addr_num_start_screen = 7'h57; //W
		5'b01001: char_addr_num_start_screen = 7'h33; //3
		5'b01010: char_addr_num_start_screen = 7'h0; //h0
		5'b01011: char_addr_num_start_screen = 7'h54; //t
		5'b01100: char_addr_num_start_screen = 7'h4f; //0
		5'b01101: char_addr_num_start_screen = 7'h0; //h0
		5'b01110: char_addr_num_start_screen = 7'h53; //s
		5'b01111: char_addr_num_start_screen = 7'h54; //t
		5'b10000: char_addr_num_start_screen = 7'h41; //a
		5'b10001: char_addr_num_start_screen = 7'h52; //r
		5'b10010: char_addr_num_start_screen = 7'h54; //t
	endcase
	
	


endmodule

