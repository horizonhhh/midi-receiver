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
	input CLK, DATA, RESET;
	output wire[7:0] LED;
	
	wire EN_BIT, EN_BYTE, EN_MSG;
	wire SAMPLE;
	wire[3:0] BIT;
	wire[1:0] BYTE;
	wire MSG;
	
	reg EN_CLK;
	reg[7:0] note;
	
	timer t			(CLK, EN_CLK, RESET, SAMPLE, EN_BIT);
	bit_state bis	(CLK, EN_BIT, RESET, BIT, EN_BYTE);
	byte_state bys	(CLK, EN_BYTE, RESET, BYTE, EN_MSG);
	msg_state ms	(CLK, EN_MSG, RESET, MSG);
	
	assign LED = note & { MSG, MSG, MSG, MSG, MSG, MSG, MSG, MSG };
		
	always @(negedge DATA or posedge EN_BYTE) begin
		if (EN_BYTE) EN_CLK <= 1'b0;
		else EN_CLK <= 1'b1;
	end
	
	always @(posedge SAMPLE) begin
		if (!MSG && BIT != 4'h0 && BIT != 4'h9 && BYTE == 2'b1) begin
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

module timer (CLK, EN, RESET, SAMPLE, OVF);
	input wire CLK, EN, RESET;
	output reg SAMPLE;
	output reg OVF;
		
	reg[6:0] count;
	
	always @(posedge CLK or negedge RESET) begin
		if (!RESET) begin
			count <= 7'b0;
			//SAMPLE <= 1'b0;
			//OVF <= 1'b0;
		end
		else if (EN) begin
			count <= (count + 1'b1);
			//SAMPLE <= (count == 7'b1000000);
			//OVF <= (count == 7'b1111111);
		end
	end
	
	always @(posedge count[6] or negedge RESET) begin
		if (!RESET) SAMPLE <= 0;
		else SAMPLE <= 1;
	end
	
	always @(negedge count[6] or negedge RESET) begin
		if (!RESET) OVF <= 0;
		else OVF <= 1;
	end
endmodule

module bit_state (CLK, EN, RESET, STATE, OVF);
	input wire CLK, EN, RESET;
	output reg[3:0] STATE;
	output reg OVF;
	
	parameter overflow = 5'h9;
	
	always @(posedge CLK or negedge RESET) begin
		if (!RESET) begin
			STATE <= 4'b0;
		end
		else if (EN) begin
			if (STATE == overflow) STATE <= 4'b0;
			else STATE <= (STATE + 1'b1);
		end
	end
	
	always @(negedge STATE[3] or posedge STATE[0] or negedge RESET) begin
		if (STATE[0] || !RESET) OVF <= 1'b0;
		else OVF <= 1'b1;
	end
endmodule

module byte_state (CLK, EN, RESET, STATE, OVF);
	input wire CLK, EN, RESET;
	output reg[1:0] STATE;
	output reg OVF;
	
	parameter overflow = 2'h2;
	
	always @(posedge CLK or negedge RESET) begin
		if (!RESET) STATE <= 2'b0;
		else if (EN) begin
			if (STATE == overflow) STATE <= 2'b0;
			else STATE <= (STATE + 1'b1);
		end
	end
	
	always @(negedge STATE[1] or posedge STATE[0] or negedge RESET) begin
		if (STATE[0] || !RESET) OVF <= 1'b0;
		else OVF <= 1'b1;
	end
endmodule

module msg_state (CLK, EN, RESET, STATE);
	input wire CLK, EN, RESET;
	output reg STATE;
	
	always @(posedge CLK or negedge RESET) begin
		if (!RESET) STATE <= 1'b0;
		else if (EN) STATE <= (STATE + 1'b1);
	end
endmodule












