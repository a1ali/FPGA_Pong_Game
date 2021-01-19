`timescale 1ns / 1ps

module refresh_7_seg(
		input CLK,
		input [3:0] p1_score, p2_score,
		output [7:0] SEG,
		output reg [2:0] ENABLE
    );

localparam refresh_rate = 50000;
reg [3:0] digit_data;
reg [1:0] digit_posn;
reg [23:0] prescaler;	 

to_7_seg decoder(.CLK(CLK), .SEG(SEG), .count (digit_data)); 
 

always @(posedge CLK)
begin
  prescaler <= prescaler + 24'd1;
  if (prescaler == refresh_rate)
  begin
    //ENABLE <= 3'b111;	
    prescaler <= 0;
    digit_posn <= digit_posn + 2'd1;
	 
    if (digit_posn == 0)
    begin
      ENABLE <= 3'b110;
      digit_data <= p2_score;
    end
	 
    else if (digit_posn == 3'd1)
    begin
      ENABLE <= 3'b011;
      digit_data <= p1_score;
		digit_posn <= 0;
    end
	  
  end
end

endmodule
