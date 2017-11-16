module fsm (clk, s1, s2, rst_n, out);

input			clk,s1,s2,rst_n;
output[1:0]		out;

wire	        clk,s1,s2,rst_n;
wire[1:0]		out;
reg[1:0]		state, state_nxt;

/* Combinational */
assign out = state;

/* Sequential (Updates on clk) */
always @(posedge clk) begin
	if (!rst_n)  begin
		state <= 2'b00;
	end
	else begin
		state <= state_nxt;
	end
end

/* Combinational (Updates always) */
always @(*) begin
	case(state)
	2'b00: begin
		if (s1 == 1'b1) begin
			state_nxt = 2'b01;
		end
		else begin
			state_nxt = 2'b00;
		end
	end

	2'b01: begin
		if (s2 == 1'b1) begin
			state_nxt = 2'b10;
		end 
		else begin
			state_nxt = 2'b01;
		end
	end

	2'b10: begin
		state_nxt = 2'b00;
	end

	default: begin
		state_nxt = 2'b00;
	end

	endcase
end

endmodule