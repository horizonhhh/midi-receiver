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
	
	reg CLK_EN;
	wire NOTE_SAMPLE;
	
	wire SAMPLE;
	wire[3:0] BIT;
	wire[1:0] BYTE;
	wire MSG;
	
	wire[7:0] NOTE;
	
	wire DISABLE;
	
	timer t	(CLK, CLK_EN, RESET, SAMPLE, BIT, BYTE, MSG);
	note n	(CLK, NOTE_SAMPLE, DATA, RESET, NOTE);
	
	assign DISABLE = BIT[0] & BIT[3] & DATA;
	assign NOTE_SAMPLE = SAMPLE && (BIT != 4'b0 && BIT != 4'b1001) && (BYTE == 2'b1) && !MSG;
	assign LED = NOTE & { MSG, MSG, MSG, MSG, MSG, MSG, MSG, MSG };
	
	always @(negedge DATA or posedge DISABLE or negedge RESET) begin
		if (!RESET || DISABLE) CLK_EN <= 0;
		else CLK_EN <= 1;
	end
	
endmodule

/*****************
**  Submodules  **
******************/

module timer (CLK, EN, RESET, SAMPLE, BIT, BYTE, MSG);
	input wire CLK, EN, RESET;
	output reg SAMPLE;
	reg[6:0] TIME;
	output reg[3:0] BIT;
	output reg[1:0] BYTE;
	output reg MSG;
	
	parameter TIME_START = 7'b0000000;
	parameter TIME_SAMPLE = 7'b1000000;
	parameter OVF_TIME = 7'b1111111;
	parameter OVF_BIT = 4'b1001;
	parameter OVF_BYTE = 2'b10;
	
	always @(negedge CLK or negedge RESET) begin
		if (!RESET) begin
			TIME <= 7'b0;
			BIT <= 4'b0;
			BYTE <= 2'b0;
			MSG <= 1'b0;
		end
		else if (EN) begin
			TIME <= TIME + 1'b1;
			
			if (TIME == TIME_SAMPLE) SAMPLE <= 1;
			else SAMPLE <= 0;
			
			if (TIME == OVF_TIME) BIT <= BIT + 1'b1;
			
			if (TIME == TIME_START) begin
				if (BIT == OVF_BIT) begin
					BIT <= 4'b0;
					if (BYTE == OVF_BYTE) begin 
						BYTE <= 2'b0;
						MSG <= MSG + 1'b1;
					end
					else BYTE <= BYTE + 1'b1;
				end
			end			
		end
	end
endmodule

module note (CLK, SAMPLE, DATA, RESET, NOTE);
	input wire CLK, DATA, SAMPLE, RESET;
	output reg[0:7] NOTE;
	
	always @(negedge CLK or negedge RESET) begin
		if (!RESET) NOTE <= 8'b0;
		else if (SAMPLE) begin
			NOTE[7] <= NOTE[6];
			NOTE[6] <= NOTE[5];
			NOTE[5] <= NOTE[4];
			NOTE[4] <= NOTE[3];
			NOTE[3] <= NOTE[2];
			NOTE[2] <= NOTE[1];
			NOTE[1] <= NOTE[0];
			NOTE[0] <= DATA;
		end
	end
endmodule
