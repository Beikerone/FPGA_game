`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/30 15:52:45
// Design Name: 
// Module Name: VGA_Display
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



`include "Definition.h"

module VGA_Dispay(
    input clk,
	 input to_left,
	 input to_right,
	 input [3:0] bar_move_speed,
    output reg hs=0,
    output reg vs=0,
    output reg [3:0] Red,
    output reg [3:0] Green,
    output reg [3:0] Blue,
	 output reg lose,
	 output reg [9:0]Hcnt,
	 output reg [9:0]Vcnt
    );
	
	//parameter definition
	parameter PAL = 640;		//Pixels/Active Line (pixels)
	parameter LAF = 480;		//Lines/Active Frame (lines)
	parameter PLD = 800;	    //Pixel/Line Divider
	parameter LFD = 521;		//Line/Frame Divider
	parameter HPW = 96;			//Horizontal synchro Pulse Width (pixels)
	parameter HFP = 16;			//Horizontal synchro Front Porch (pixels)
	parameter VPW = 2;			//Verical synchro Pulse Width (lines)
	parameter VFP = 10;			//Verical synchro Front Porch (lines)
	
	parameter UP_BOUND = 20;
   parameter DOWN_BOUND = 470;  
   parameter LEFT_BOUND = 20;  
   parameter RIGHT_BOUND = 620;
	
	// Radius of the ball
	parameter ball_r = 10;
	
	
	/*register definition*/

	reg clk_25M = 0;     //25MHz frequency	
	reg h_speed = `RIGHT;
	reg v_speed = `UP; 
	
	// The position of the downside bar
	reg [9:0] up_pos = 400;
	reg [9:0] down_pos = 430;
	reg [9:0] left_pos = 230;
	reg [9:0] right_pos = 430;  
		
	// The circle heart position of the ball
	reg [9:0] ball_x_pos = 330;
	reg [9:0] ball_y_pos = 390;
	
	reg [2:0]oRed;
	reg [2:0]oGreen;
	reg [1:0]oBlue;
	
	always@(*)
	begin
	 Red <= {oRed,1'b0};
	 Green <= {oGreen,1'b0};
	 Blue <= {oBlue,2'b00};
	end
	
	//generate a half frequency clock of 25MHz
	always@(posedge clk)
	begin
		clk_25M <= ~clk_25M;
	end
	
	/*generate the hs && vs timing*/
	always@(posedge clk_25M) 
	begin
		/*conditions of reseting Hcnter && Vcnter*/
		if( Hcnt == PLD-1 ) //have reached the edge of one line
		begin
			Hcnt <= 10'b0; //reset the horizontal counter
			if( Vcnt == LFD-1 ) //only when horizontal pointer reach the edge can the vertical counter ++
				Vcnt <=10'b0;
			else
				Vcnt <= Vcnt + 10'b1;
		end
		else
			Hcnt <= Hcnt + 10'b1;
	end		


	always@(posedge clk_25M) 
	begin		
		/*generate hs timing*/
		if( Hcnt == PAL - 1 + HFP)
			hs <= 1'b0;
		else if( Hcnt == PAL - 1 + HFP + HPW )
			hs <= 1'b1;
	end
	
		always@(posedge clk_25M) 
	begin
		/*generate vs timing*/		
		if( Vcnt == LAF - 1 + VFP ) 
			vs <= 1'b0;
		else if( Vcnt == LAF - 1 + VFP + VPW )
			vs <= 1'b1;					
	end
	
	
	//Display the downside bar and the ball
	always @ (posedge clk_25M)   
	begin  
		// Display the downside bar
		if (Vcnt>=up_pos && Vcnt<=down_pos && Hcnt>=left_pos && Hcnt<=right_pos) 
		begin  
			oRed <= 3'b000;  
			oGreen <= 3'b101;  
			oBlue <= 2'b11; 
		end  
		
		// Display the ball
		else if ( (Hcnt - ball_x_pos)*(Hcnt - ball_x_pos) + (Vcnt - ball_y_pos)*(Vcnt - ball_y_pos) <= (ball_r * ball_r))  
		begin  
			oRed <= 3'b000;  
			oGreen <= 3'b000;  
			oBlue <= 2'b10;  
		end  
		// Display the border
		else if((Hcnt <= LEFT_BOUND-10)| ( Vcnt <= UP_BOUND-10)| (Hcnt >= RIGHT_BOUND+10)| (Vcnt >= DOWN_BOUND))
		begin
			oRed <= 3'b011;  
			oGreen <= 3'b111;  
			oBlue <= 2'b00;  
		end
		else 
		begin  
			oRed <= 3'b000;  
			oGreen <= 3'b000;  
			oBlue <= 2'b00;  
		end		 
		
	end
	
	
	//flush the image every zhen = =||
	always @ (posedge vs)  
   begin  		
		// movement of the bar
      if (to_left && left_pos >= LEFT_BOUND) 
		begin  
			left_pos <= left_pos - bar_move_speed;  
			right_pos <= right_pos - bar_move_speed;  
      end  
      else if(to_right && right_pos <= RIGHT_BOUND)
		begin  		
			left_pos <= left_pos + bar_move_speed; 
			right_pos <= right_pos + bar_move_speed;  
      end  
		
		//movement of the ball
		if (v_speed == `UP) // go up 
			ball_y_pos <= ball_y_pos - bar_move_speed;  
      else //go down
			ball_y_pos <= ball_y_pos + bar_move_speed;  
		if (h_speed == `RIGHT) // go right 
			ball_x_pos <= ball_x_pos + bar_move_speed;  
      else //go down
			ball_x_pos <= ball_x_pos - bar_move_speed;  	
   end 
	
	//change directions when reach the edge or crush the bar
	always @ (negedge vs)  
   begin
		if (ball_y_pos <= UP_BOUND)   // Here, all the jugement should use >= or <= instead of ==
		begin	
			v_speed <= 1;              // Because when the offset is more than 1, the axis may step over the line
			lose <= 0;
		end
		else if (ball_y_pos >= (up_pos - ball_r) && ball_x_pos <= right_pos && ball_x_pos >= left_pos)  
         v_speed <= 0;  
		else if (ball_y_pos >= down_pos && ball_y_pos < (DOWN_BOUND - ball_r))
		begin
			// Ahhh!!! What the fuck!!! I miss the ball!!!
			//Do what you want when lose
			lose <= 1;
		end
		else if (ball_y_pos >= (DOWN_BOUND - ball_r + 1))
			v_speed <= 0; 
      else  
         v_speed <= v_speed;  
              
      if (ball_x_pos <= LEFT_BOUND)  
         h_speed <= 1;  
      else if (ball_x_pos >= RIGHT_BOUND)  
         h_speed <= 0;  
      else  
         h_speed <= h_speed;  
  end 
  

endmodule

