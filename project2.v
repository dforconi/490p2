`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		Darryl Forconi	darrylfo
// 
// Create Date:    00:22:54 06/20/2016 
// Design Name: 
// Module Name:    project2 
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

module project2(clk, switch, p2turn_switch, p2guess_switch, led, btn, cathodes, anodes);

	input clk;
	input [3:0] switch;		// switches 3-0 for number input
	input p2turn_switch;		// switch 4, when hi signals player 2's turn
	input p2guess_switch;	// switch 5, up then down signals guess from p2 done
	input [3:0] btn;			// 4 buttons to select display digit for input
	
	output [7:0] led; 		// 8 LEDs to flash when game ends
	output [7:0] cathodes;	// cathodes used to display digits on displays
	output [3:0] anodes;		// anodes to control which display active

	reg [7:0] cathodes; 	// for cathodes
	reg [3:0] anodes;		// for anodes
	reg [7:0] led;			// for 8 LEDs
	reg [4:0] dig;			// 5 bits used to pass into calc_cathode_value to choose display output
	reg slow_clock;		// used for slow clock to strobe
	reg led_clock;			// used to flash LEDs
	reg [4:0] p1in3;		// 1st bit enable then 4 bits input from player 1 into button 3
	reg [4:0] p1in2;		// 1st bit enable then 4 bits input from player 1 into button 2
	reg [4:0] p1in1;		// 1st bit enable then 4 bits input from player 1 into button 1
	reg [4:0] p1in0;		// 1st bit enable then 4 bits input from player 1 into button 0
	reg [4:0] p2guess3;	// 1st bit enable then 4 bits input from player 2's guess for button 3
	reg [4:0] p2guess2;	// 1st bit enable then 4 bits input from player 2's guess for button 2
	reg [4:0] p2guess1;	// 1st bit enable then 4 bits input from player 2's guess for button 1
	reg [4:0] p2guess0;	// 1st bit enable then 4 bits input from player 2's guess for button 0
	reg [15:0] p1full;	// all 16 bits for p1 from btn 3-0
	reg [15:0] p2full;	// all 16 bits for p2 from btn 3-0
	reg p2enable;			// enable for p2 when switch 4 hi
	
	integer state;						// state to keep track of whose turn it is, state = 0 means p1's turn, state = 1 means p2's turn	
	integer num_guesses;				// int to keep track of # guess player 2 makes, display when game ends
	integer count;						// int for slow_clock
	integer ledcount;					// int for led_clock
	integer d3, d2, d1, d0;			// ints for each display used to calculate value to display for number of guesses
	integer stimer0, stimer2, stimer4, stimer5;		// used to create a timer for timed states to move to next state
	integer ledenable;				// to enable LEDs when game is won
	integer guess_check_enable;	// used to signal guess is in
	integer sw5hi;						// used with guess_check_enable to send back to state 3 after incorrect guess
	
always @(posedge clk)
	begin
		create_slow_clock(clk, slow_clock);
	end
	
		
always @(posedge slow_clock)
	begin
		
		if (state == 0)				// begins in state 0 displaying 'PL 1' for short time then switching to state 1
			begin
				if (stimer0 > 500)
					begin
						state = 1;
						stimer0 = 0;
					end
				else
					begin
						stimer0 = stimer0 + 1;
					end
			end
						
		if (p2enable == 1'b1 & state == 1)		// in state 1 when sw4 (p2enable) hi it means p1 done and it's p2's turn, go to state 2
			begin
				state = 2;
			end
		
		if (state == 2)					// state 2 displays 'PL 2' for short time then sends to state 3
			begin
				if (stimer2 > 500)
					begin
						state = 3;
						stimer2 = 0;
					end
				else
					begin
						stimer2 = stimer2 + 1;
					end
			end

		if (guess_check_enable != sw5hi & state ==3 & sw5hi > 0)		// in state 3 after 1st flip of switch 5 when switch 4 and switch 5 opposite then guess is in
			begin
				if (p2full > p1full)		
					begin
						state = 4;	
					end
				if (p2full < p1full)
					begin
						state = 5;
					end
				if (p2full == p1full)
					begin
						state = 6;
					end
			end
			
		if (state == 4)			// guess too hi, display '2 HI' for short time then go back to state 3
			begin
				if (stimer4 > 400)	
					begin
						state = 3;
						stimer4 = 0;
					end
				else
					begin
						stimer4 = stimer4 + 1;
					end
			end

		if (state == 5)				// guess too low, display '2 LO' for short time then back to state 3
			begin
				if (stimer5 > 400) 	
					begin
						state = 3;		
						stimer5 = 0;		
					end
				else
					begin
						stimer5 = stimer5 + 1;	
					end
			end
			
		if (state == 6)		// guess correct, enable LEDs
			begin
				ledenable = 1;
			end

		if (ledenable == 0)	// LEDs aren't enabled
			begin
				ledcount = 0;
				led[0] = 0;	// each LED will be off when not enabled
				led[1] = 0;
				led[2] = 0;
				led[3] = 0;
				led[4] = 0;
				led[5] = 0;
				led[6] = 0;
				led[7] = 0;	
			end
		else			// LEDs are enabled
			begin
				if (ledcount > 250)	
					begin
						ledcount = 0;	
						led[0] = ~led[0];	// each LED will go on or off after ledcount reaches 50000000
						led[1] = ~led[1];
						led[2] = ~led[2];
						led[3] = ~led[3];
						led[4] = ~led[4];
						led[5] = ~led[5];
						led[6] = ~led[6];
						led[7] = ~led[7];
					end
				ledcount = ledcount + 1;	
			end
			
		case (anodes)	// strobing
			4'b 1110: anodes=4'b 1101;	// 0 enabled, send to 1
			4'b 1101: anodes=4'b 1011;	// 1 enabled, send to 2
			4'b 1011: anodes=4'b 0111;	// 2 enabled, send to 3
			4'b 0111: anodes=4'b 1110;	// 3 enabled, send to 0
			4'b 1111: anodes=4'b 1110;	// none enabled, send to 0
			default: anodes=1111;		// default none enabled
		endcase
		
		case (anodes)	// what each segment should display when it's enabled, 6 possible states: 0 = start of game, display 'PL 1', 1 = p1's turn, display input above buttons, 2 = display 'PL 2', 3 = p2's turn display input guesses, 4 = p2 guess in but too hi display '2 HI', 5 = guess in but too low, display '2 LO', 6 = guess correct, display num_guesses
			4'b 0111: 	begin
								case (state)					// state determines what to display in each place
									0: begin						// game beginning, display 'P' on disp3	
											dig[4] = 1'b 1;	// display 'P' on disp3
											dig[3] = 1'b 0;
											dig[2] = 1'b 0;
											dig[1] = 1'b 0;
											dig[0] = 1'b 1;
										end		
									1:	begin 						// state = 1, player 1's turn, display their current guess for each button
											dig[4] = p1in3[4];	// used for enable after 1st press of btn 3
											dig[3] = p1in3[3];	// displaying p1's input for btn 3 
											dig[2] = p1in3[2];
											dig[1] = p1in3[1];
											dig[0] = p1in3[0];
										end
									2:	begin							// p2's turn, display 'P' on disp3	
											dig = 5'b 10001;		// display 'P' on disp3								
										end
									3:	begin								// state = 3 so player 2's turn
											dig[4] = p2guess3[4];	// used for enable after p2 presses btn 3
											dig[3] = p2guess3[3];	// displaying p2's guess for btn 3
											dig[2] = p2guess3[2];
											dig[1] = p2guess3[1];
											dig[0] = p2guess3[0];
										end
									4:	begin							// p2's guess too high, display '2' on disp 3
											dig = 5'b 00010;		// display 2
										end
									5:	begin							// p2's guess too low, display '2' on disp 3
											dig = 5'b 00010;		// display 2
										end
									6:	begin							// game over, disp 3 needs to display num_guesses 1000s place
											case (d3)
												0:	dig = 5'b 00000;	// display 0 in 1000s place
												1:	dig = 5'b 00001;	// display 1 in 1000s place
												2:	dig = 5'b 00010;	// display 3
												3:	dig = 5'b 00011;
												4:	dig = 5'b 00100;
												5:	dig = 5'b 00101;
												6:	dig = 5'b 00110;
												7:	dig = 5'b 00111;
												8:	dig = 5'b 01000;
												9:	dig = 5'b 01001;	// display 9
											endcase
										end
							endcase
						end
			
			4'b 1011: 	begin
								case (state)
									0:	begin						// game beginning, display 'L' on disp2	
											dig[4] = 1'b 1;	// display 'L' on disp2
											dig[3] = 1'b 0;
											dig[2] = 1'b 0;
											dig[1] = 1'b 1;
											dig[0] = 1'b 0;
										end	
									1:	begin			 				// state = 1, player 1's turn
											dig[4] = p1in2[4];	// used for enable after 1st press of btn 2
											dig[3] = p1in2[3];	// displaying p1's input for btn 2 
											dig[2] = p1in2[2];
											dig[1] = p1in2[1];
											dig[0] = p1in2[0];
										end
									2:	begin							// p2's turn, display 'L' on disp2	
											dig = 5'b 10010;		// display 'L' on disp2								
										end
									3:	begin								// state = 3 so player 2's turn
											dig[4] = p2guess2[4];	// used for enable after p2 presses btn 2
											dig[3] = p2guess2[3];	// displaying p2's guess for btn 2
											dig[2] = p2guess2[2];
											dig[1] = p2guess2[1];
											dig[0] = p2guess2[0];
										end
									4:	begin							// p2's guess too high, disp 2 off
											dig = 5'b 11111;		// disp2 off
										end
									5:	begin							// p2's guess too low, disp 2 off
											dig = 5'b 11111;		// disp2 off
										end
									6:	begin							// game over, disp 2 needs to display num_guesses 100s place
											case (d2)
												0:	dig = 5'b 00000;	// display 0 in 100s place
												1:	dig = 5'b 00001;	// display 1 in 100s place
												2:	dig = 5'b 00010;	// display 3
												3:	dig = 5'b 00011;
												4:	dig = 5'b 00100;
												5:	dig = 5'b 00101;
												6:	dig = 5'b 00110;
												7:	dig = 5'b 00111;
												8:	dig = 5'b 01000;
												9:	dig = 5'b 01001;	// display 9
											endcase
										end
								endcase
							end
			
			4'b 1101: 	begin
								case (state)
									0:	begin						// game beginning, disp1 off	
											dig[4] = 1'b 1;	// disp1 off
											dig[3] = 1'b 1;
											dig[2] = 1'b 1;
											dig[1] = 1'b 1;
											dig[0] = 1'b 1;
										end
									1:	begin			 				// state = 1, player 1's turn
											dig[4] = p1in1[4];	// used for enable after 1st press of btn 1
											dig[3] = p1in1[3];	// displaying p1's input for btn 1
											dig[2] = p1in1[2];
											dig[1] = p1in1[1];
											dig[0] = p1in1[0];
										end
									2:	begin							// p2's turn, disp1 off	
											dig = 5'b 11111;		// display off								
										end
									3:	begin								// state = 3 so player 2's turn
											dig[4] = p2guess1[4];	// used for enable after p2 presses btn 1
											dig[3] = p2guess1[3];	// displaying p2's guess for btn 1
											dig[2] = p2guess1[2];
											dig[1] = p2guess1[1];
											dig[0] = p2guess1[0];
										end
									4:	begin							// p2's guess too high, display 'H' on disp 1
											dig = 5'b 10011;		// display H
										end
									5:	begin							// p2's guess too low, display 'L' on disp 1
											dig = 5'b 10010;		// display L
										end
									6:	begin							// game over, disp 1 needs to display num_guesses 10s place
											case (d1)
												0:	dig = 5'b 00000;	// display 0 in 10s place
												1:	dig = 5'b 00001;	// display 1 in 10s place
												2:	dig = 5'b 00010;	// display 3
												3:	dig = 5'b 00011;
												4:	dig = 5'b 00100;
												5:	dig = 5'b 00101;
												6:	dig = 5'b 00110;
												7:	dig = 5'b 00111;
												8:	dig = 5'b 01000;
												9:	dig = 5'b 01001;	// display 9
											endcase
										end
								endcase				
							end
			
			4'b 1110: 	begin
								case (state)
									0:	begin						// game beginning, display '1' on disp0	
											dig[4] = 1'b0;		// display 1
											dig[3] = 1'b0;
											dig[2] = 1'b0;
											dig[1] = 1'b0;
											dig[0] = 1'b1;
										end
									1:	begin			 				// state = 1, player 1's turn
											dig[4] = p1in0[4];	// used for enable after 1st press of btn 0
											dig[3] = p1in0[3];	// displaying p1's input for btn 0 
											dig[2] = p1in0[2];
											dig[1] = p1in0[1];
											dig[0] = p1in0[0];
										end
									2:	begin							// p2's turn, display '2' on disp0	
											dig = 5'b 00010;		// display '2' on disp0							
										end
									3:	begin								// state = 3 so player 2's turn
											dig[4] = p2guess0[4];	// used for enable after p2 presses btn 0
											dig[3] = p2guess0[3];	// displaying p2's guess for btn 0
											dig[2] = p2guess0[2];
											dig[1] = p2guess0[1];
											dig[0] = p2guess0[0];
										end
									4:	begin								// p2's guess too high, display 'I' on disp 0
											dig = 5'b 00001;			// display 1 for I
										end
									5:	begin								// p2's guess too low, display 'O' on disp 0
											dig = 5'b 00000;			// display 0 for O
										end
									6:	begin								// game over, disp 0 needs to display num_guesses 1s place
											case (d0)
												0:	dig = 5'b 00000;	// display 0 in 1s place
												1:	dig = 5'b 00001;	// display 1 in 1s place
												2:	dig = 5'b 00010;	// display 3
												3:	dig = 5'b 00011;
												4:	dig = 5'b 00100;
												5:	dig = 5'b 00101;
												6:	dig = 5'b 00110;
												7:	dig = 5'b 00111;
												8:	dig = 5'b 01000;
												9:	dig = 5'b 01001;	// display 9
											endcase
										end
								endcase		
							end
				endcase
		
		cathodes=calc_cathode_value(dig);
	end
	
always @(btn)
	case (btn) 							// determine which button pressed and which p1in/p2guess to update with switch info
		4'b 1000: 	begin
							if (p2enable == 1'b1)
								begin
									p2guess3[4] = 1'b 0;			// enable display 3 for p2
									p2guess3[3] = switch[3];	// btn 3 pressed, update p2guess3 w/ value of p2's guess for btn 3
									p2guess3[2] = switch[2];
									p2guess3[1] = switch[1];
									p2guess3[0] = switch[0];
								end
							else 
								begin
									p1in3[4] = 1'b 0;			// to enable display 3 for p1
									p1in3[3] = switch[3];	// button 3 pressed, update p1in3 with p1's input value for btn 3 from switchs
									p1in3[2] = switch[2];
									p1in3[1] = switch[1];
									p1in3[0] = switch[0];
								end
							end
		4'b 0100:	begin 
							if (p2enable == 1'b1)				// player 1's turn
								begin
									p2guess2[4] = 1'b 0;			// enable display 2 for p2
									p2guess2[3] = switch[3];	// btn 2 pressed, update p2guess2 w/ value of p2's guess for btn 2
									p2guess2[2] = switch[2];
									p2guess2[1] = switch[1];
									p2guess2[0] = switch[0];
								end
							else
								begin
									p1in2[4] = 1'b 0;			// to enable display 2
									p1in2[3] = switch[3];	// button 2 pressed, update p1in2 with p1's input value for btn 2 from switchs
									p1in2[2] = switch[2];
									p1in2[1] = switch[1];
									p1in2[0] = switch[0];
								end
							end

		4'b 0010: 	begin
							if (p2enable == 1'b1)				// player 1's turn
								begin
									p2guess1[4] = 1'b 0;			// enable display 1 for p2
									p2guess1[3] = switch[3];	// btn 1 pressed, update p2guess1 w/ value of p2's guess for btn 1
									p2guess1[2] = switch[2];
									p2guess1[1] = switch[1];
									p2guess1[0] = switch[0];
								end
							else
								begin
									p1in1[4] = 1'b 0;				// to enable display 1
									p1in1[3] = switch[3];		// button 1 pressed, update p1in1 with p1's input value for btn 1 from switchs
									p1in1[2] = switch[2];
									p1in1[1] = switch[1];
									p1in1[0] = switch[0];
								end
							end
		
		4'b 0001: 	begin
							if (p2enable == 1'b1)				// player 1's turn
								begin
									p2guess0[4] = 1'b 0;			// enable display 0 for p2
									p2guess0[3] = switch[3];	// btn 0 pressed, update p2guess0 w/ value of p2's guess for btn 0
									p2guess0[2] = switch[2];
									p2guess0[1] = switch[1];
									p2guess0[0] = switch[0];
								end
							else
								begin
									p1in0[4] = 1'b 0;				// to enable display 0
									p1in0[3] = switch[3];		// button 0 pressed, update p1in0 with p1's input value for btn 0 from switchs
									p1in0[2] = switch[2];
									p1in0[1] = switch[1];
									p1in0[0] = switch[0];		
								end
							end
	endcase
			
		
function [7:0] calc_cathode_value;
	input [4:0] dig;	
	begin
		case (dig)	
		5'b00000: calc_cathode_value = 8'b 11000000;	// 0, 1st bit for decimal, output 0 to cathodes 
		5'b00001: calc_cathode_value = 8'b 11111001;	// 1
		5'b00010: calc_cathode_value = 8'b 10100100;	// 2
		5'b00011: calc_cathode_value = 8'b 10110000;	// 3
		5'b00100: calc_cathode_value = 8'b 10011001;	// 4
		5'b00101: calc_cathode_value = 8'b 10010010;	// 5
		5'b00110: calc_cathode_value = 8'b 10000010;	// 6
		5'b00111: calc_cathode_value = 8'b 11111000;	// 7
		5'b01000: calc_cathode_value = 8'b 10000000;	// 8
		5'b01001: calc_cathode_value = 8'b 10010000;	// 9
		5'b01010: calc_cathode_value = 8'b 10001000;	// a
		5'b01011: calc_cathode_value = 8'b 10000011;	// b
		5'b01100: calc_cathode_value = 8'b 11000110;	// c
		5'b01101: calc_cathode_value = 8'b 10100001;	// d
		5'b01110: calc_cathode_value = 8'b 10000110;	// e
		5'b01111: calc_cathode_value = 8'b 10001110;	// f
			
		5'b10000: calc_cathode_value = 8'b 11111111;	// 1st bit 1 = display off except for cases used to display letters below
		5'b10001: calc_cathode_value = 8'b 10001100;	// use to display 'P', need to adjust 8'b value
		5'b10010: calc_cathode_value = 8'b 11000111;	// use to display 'L', need to adjust 8'b value
		5'b10011: calc_cathode_value = 8'b 10001001;	// use to display 'H'
		5'b10100: calc_cathode_value = 8'b 11111111;
		5'b10101: calc_cathode_value = 8'b 11111111;
		5'b10110: calc_cathode_value = 8'b 11111111;
		5'b10111: calc_cathode_value = 8'b 11111111;
		5'b11000: calc_cathode_value = 8'b 11111111;
		5'b11001: calc_cathode_value = 8'b 11111111;
		5'b11010: calc_cathode_value = 8'b 11111111;
		5'b11011: calc_cathode_value = 8'b 11111111;
		5'b11100: calc_cathode_value = 8'b 11111111;
		5'b11101: calc_cathode_value = 8'b 11111111;
		5'b11110: calc_cathode_value = 8'b 11111111;
		5'b11111: calc_cathode_value = 8'b 11111111;	// display off when dig = 11111
		endcase
	end
endfunction
	
task create_slow_clock;
	
	input clock;
	inout slow_clock;
	integer count;
	
		begin
			if (count > 100000)
			begin
				count = 0;
				slow_clock = ~slow_clock;
			end
			count = count + 1;
		end
endtask

always @(posedge p2turn_switch)		// switch 4, when switched hi changes to p2's turn
	begin
		p2enable = 1'b1;					// used to signal p2's turn
		
		p1full[15] = p1in3[3];			// assign p1's 4 inputs to one full 16 bit number
		p1full[14] = p1in3[2];
		p1full[13] = p1in3[1];
		p1full[12] = p1in3[0];
		
		p1full[11] = p1in2[3];
		p1full[10] = p1in2[2];
		p1full[9] = p1in2[1];
		p1full[8] = p1in2[0];

		p1full[7] = p1in1[3];
		p1full[6] = p1in1[2];
		p1full[5] = p1in1[1];
		p1full[4] = p1in1[0];

		p1full[3] = p1in0[3];
		p1full[2] = p1in0[2];
		p1full[1] = p1in0[1];
		p1full[0] = p1in0[0];
	end


always @(negedge p2guess_switch)			// switch 5 turned hi then low, indicates p2guess is in
	begin

		guess_check_enable = guess_check_enable + 1;		// used with sw5hi, when low guess is in, when hi goes back to state 3

		p2full[15] = p2guess3[3];		// assign p2's 4 inputs to one full 16 bit number
		p2full[14] = p2guess3[2];
		p2full[13] = p2guess3[1];
		p2full[12] = p2guess3[0];

		p2full[11] = p2guess2[3];
		p2full[10] = p2guess2[2];
		p2full[9] = p2guess2[1];
		p2full[8] = p2guess2[0];

		p2full[7] = p2guess1[3];
		p2full[6] = p2guess1[2];
		p2full[5] = p2guess1[1];
		p2full[4] = p2guess1[0];

		p2full[3] = p2guess0[3];
		p2full[2] = p2guess0[2];
		p2full[1] = p2guess0[1];
		p2full[0] = p2guess0[0];		// p2full now has 16 bit # of p2's guess
		
	end


always @(posedge p2guess_switch)
	begin
		sw5hi = sw5hi + 1;			// synchronizes with guess_check_enable to send to state 4 or 5 then go back to 3 after next up/down
	
		num_guesses = num_guesses + 1;		// guess submitted, num_guesses goes up by 1
		d0 = num_guesses;

		if (d0 == 10)
			begin
				d1 = d1 + 1;
				num_guesses = 0;
				d0 = 0;
			end
			
		if (d1 == 10)
			begin
				d2 = d2 + 1;
				d1 = 0;
			end
			
		if (d2 == 10)
			begin
				d3 = d3 + 1;
				d2 = 0;
			end
	end

initial					// initial set up
	begin
		
		p2enable = 1'b0;
		num_guesses = 0;			// initialize guess counter to 0
		ledenable = 0;				// LEDs disabled to start
		state = 0;					// start game in state 0
		guess_check_enable = 1;
		sw5hi = 0;
	
		d0 = 0;
		d1 = 0;
		d2 = 0;
		d3 = 0;
		
		p1in3 = 5'b 11111;
		p1in2 = 5'b 11111;
		p1in1 = 5'b 11111;
		p1in0 = 5'b 11111;
		
		p2guess3 = 5'b 11101;
		p2guess2 = 5'b 11101;
		p2guess1 = 5'b 11101;
		p2guess0 = 5'b 11101;

	end
		
endmodule
