`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/30 15:52:59
// Design Name: 
// Module Name: LED
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

module LED(
    input lose,
	 input rst,
	 output	[5:0]num
    );

reg [5:0] num = 6'b0;


// Flush data each time you lose
always@(posedge lose or posedge rst)
begin
	if(rst)
		num<=6'b0;
	else if(num == 6'b111111)
		num <= 6'b0;
	else
		num <= num + 6'b1;		
end



endmodule