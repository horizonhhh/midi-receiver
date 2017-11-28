/*
** ECE 353: Computer Systems Lab I
** Lab 4: MIDI Receiver in Verilog
**
** Ryan Lagasse, Perveshwer Jaswal, Ricardo Henriquez
*/

/**********************
**  Receiver Module  **
***********************/

module receiver (CLK, DATA, RESET, LED);
	input wire CLK, DATA, RESET;
	output wire[7:0] LED;
	
	reg[7:0] note_number;
	
endmodule

/*****************
**  Submodules  **
******************/

module timer (CLK, RESET, SAMPLE, OVF);
	input wire CLK, RESET;
	output reg SAMPLE, OVF;
		
	reg[6:0] count;
	wire[6:0] count_next;
	
	assign count_next = count + 1'b1;
	
	always @(posedge CLK)
	begin
		if (!RESET) count <= 7'b0;
		else count <= count_next;
		
		SAMPLE <= count == 7'b1000000;
		OVF <= count == 7'b0;
	end
endmodule

module bit_state (INC, RESET, STATE, OVF);
	input wire INC, RESET;
	output reg[4:0] STATE;
	output reg OVF;

	wire[6:0] state_next;
	
	parameter overflow = 5'h9;
	
	assign state_next = STATE + 1'b1;
	
	always @(posedge INC)
	begin
		if (STATE == overflow || !RESET) STATE <= 5'b0;
		else STATE <= state_next;
		
		OVF <= STATE == 5'b0; // Fix w/ a non-blocking statement
	end
endmodule

module byte_state (INC, RESET, STATE, OVF);
	input wire INC, RESET;
	output reg[1:0] STATE;
	output reg OVF;
	
	wire [1:0] state_next;
	
	parameter overflow = 2'h2;
	
	assign state_next = STATE + 1'b1;
	
	always @(posedge INC)
	begin
		if (STATE == overflow || !RESET) STATE <= 2'b0;
		else STATE <= state_next;
		
		OVF <= STATE == 2'b0;  // Fix w/ a non-blocking statement
	end

endmodule

module msg_state (INC, RESET, STATE);
	input INC, RESET;
	output STATE;
	wire INC, RESET, STATE;

endmodule
