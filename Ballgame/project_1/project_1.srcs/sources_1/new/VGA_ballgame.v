`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/30 15:54:23
// Design Name: 
// Module Name: VGA_ballgame
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module VGA_ballgame(

	//////////// CLOCK //////////
	input 		          		CLOCK_100,

	//////////// LED //////////
	output		     [5:0]		num,


	//////////// KEY //////////
	input 		     [1:0]		KEY,
    
	//////////// SW //////////
	input 		     [3:0]		SW,

	//////////// VGA //////////

	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS
);


wire lose;
wire CLOCK_50;
wire Rst;


assign Rst = SW[4];


clk_wiz_0 u_clk(.clk_out1(CLOCK_50),.clk_in1(CLOCK_100));

	
	VGA_Dispay u_VGA_Disp(
	.clk(CLOCK_50),
	.to_left(KEY[1]),
	.to_right(KEY[0]),
	.bar_move_speed(SW[3:0]),
	.hs(VGA_HS),
	.Hcnt(),
	.Vcnt(),
	.Blue(VGA_B),
	.Green(VGA_G),
	.Red(VGA_R),
	.vs(VGA_VS),
	.lose(lose)
	);
	

	
LED u_score_board(
    .lose(lose),
	 .rst(Rst),
	 .num(num)
	);
	

endmodule