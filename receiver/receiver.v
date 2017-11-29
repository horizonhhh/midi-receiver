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
	
	wire COUNT, SAMPLE;
	wire[4:0] BIT;
	wire[1:0] BYTE;
	wire MSG;
	wire[2:0] OVF;
	
	reg RECORD;
	reg[7:0] note;
	
	timer t			(COUNT, RESET, SAMPLE, OVF[0]);
	bit_state bis	(OVF[0], RESET, BIT, OVF[1]);
	byte_state bys	(OVF[1], RESET, BYTE, OVF[2]);
	msg_state ms	(OVF[2], RESET, MSG);
	
	assign COUNT = CLK & RECORD;
	assign LED[7] = note[7] & MSG;
	assign LED[6] = note[6] & MSG;
	assign LED[5] = note[5] & MSG;
	assign LED[4] = note[4] & MSG;
	assign LED[3] = note[3] & MSG;
	assign LED[2] = note[2] & MSG;
	assign LED[1] = note[1] & MSG;
	assign LED[0] = note[0] & MSG;
	
	always @(negedge DATA or posedge OVF[1])
	begin
		if (OVF[1]) RECORD <= 1'b0;
		else if (RECORD == 1'b0) RECORD <= 1'b1;
	end
	
	always @ (posedge SAMPLE)
	begin
		if (BIT != 5'h0 && BIT != 5'h9 && BYTE == 2'b1)
		begin
			note[7] <= note[6];
			note[6] <= note[5];
			note[5] <= note[4];
			note[4] <= note[3];
			note[3] <= note[2];
			note[2] <= note[1];
			note[1] <= note[0];
			note[0] <= DATA;
		end
	end
	
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
	
	always @(posedge INC)
	begin
		if (STATE == overflow || !RESET) STATE <= 5'b0;
		else STATE <= STATE + 1;
		
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
