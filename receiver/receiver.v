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
	assign LED = note & { MSG, MSG, MSG, MSG, MSG, MSG, MSG, MSG };
		
	always @(negedge DATA or posedge OVF[1]) begin
		if (OVF[1]) RECORD <= 1'b0;
		else RECORD <= 1'b1;
	end
	
	always @ (posedge SAMPLE) begin
		if (!MSG && BIT != 5'h0 && BIT != 5'h9 && BYTE == 2'b1) begin
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
	
	always @(posedge CLK or negedge RESET) begin
		if (!RESET) begin
			count <= 7'b0;
			SAMPLE <= 1'b0;
			OVF <= 1'b0;
		end
		else begin
			count <= (count + 1'b1);
			SAMPLE <= (count == 7'b1000000);
			OVF <= (count == 7'b1111111);
		end
	end
endmodule

module bit_state (INC, RESET, STATE, OVF);
	input wire INC, RESET;
	output reg[4:0] STATE;
	output reg OVF;
	
	parameter overflow = 5'h9;
	
	always @(posedge INC or negedge RESET) begin
		if (!RESET) begin
			STATE <= 5'b0;
			OVF <= 0;
		end
		else begin
			if (STATE == overflow) begin
				STATE <= 0;
				OVF <= 1;
			end
			else begin
				STATE <= (STATE + 1'b1);
				OVF <= 0;
			end
		end
	end
endmodule

module byte_state (INC, RESET, STATE, OVF);
	input wire INC, RESET;
	output reg[1:0] STATE;
	output reg OVF;
	
	parameter overflow = 2'h2;
	
	always @(posedge INC or negedge RESET) begin
		if (!RESET) begin
			STATE <= 2'b0;
			OVF <= 0;
		end
		else begin
			if (STATE == overflow) begin
				STATE <= 0;
				OVF <= 1;
			end
			else begin
				STATE <= (STATE + 1'b1);
				OVF <= 0;
			end
		end
	end
endmodule

module msg_state (INC, RESET, STATE);
	input wire INC, RESET;
	output reg STATE;
	
	always @(posedge INC or negedge RESET) begin
		if (!RESET) STATE <= 1'b0;
		else STATE <= (STATE + 1'b1);
	end
endmodule
