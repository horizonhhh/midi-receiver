/*
** ECE 353: Computer Systems Lab I
** Lab 4: MIDI Receiver in Verilog
**
** Ryan Lagasse, Perveshwer Jaswal, Ricardo Henriquez
*/

/**********************
**  Receiver Module  **
***********************/

module receiver (CLK, DATA, RESET, LED, CLK_EN, NOTE_SAMPLE, SAMPLE, BIT, BYTE, MSG);
	input wire CLK, DATA, RESET;
	output wire[7:0] LED;
	
	output reg CLK_EN;
	output wire NOTE_SAMPLE;
	
	output wire SAMPLE;
	output wire[3:0] BIT;
	output wire[1:0] BYTE;
	output wire MSG;
	wire[7:0] NOTE;
	
	timer t	(CLK, CLK_EN, RESET, SAMPLE, BIT, BYTE, MSG);
	note n	(CLK, NOTE_SAMPLE, DATA, RESET, NOTE);
	
	assign DISABLE = BIT[0] & BIT[3];
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
	
	parameter TIME_SAMPLE = 7'b1000000;
	parameter OVF_TIME = 7'b1111111;
	parameter OVF_BIT = 4'b1001;
	parameter OVF_BYTE = 2'b10;
	
	always @(posedge CLK or negedge RESET) begin
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
			
			if (BIT == OVF_BIT) begin
				BIT <= 4'b0;
				BYTE <= BYTE + 1'b1;
			end
			
			if (BYTE == OVF_BYTE) begin
				BYTE <= 2'b0;
				MSG <= MSG + 1'b1;
			end
		end
	end
endmodule

module note (CLK, SAMPLE, DATA, RESET, NOTE);
	input wire CLK, DATA, SAMPLE, RESET;
	output reg[7:0] NOTE;
	
	always @(posedge CLK or negedge RESET) begin
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
