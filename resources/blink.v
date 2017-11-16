module blink (clk, rst_n, LED_out);

input clk;
input rst_n;
output [7:0] LED_out;

reg[20:0] cnt;
wire[20:0] cnt_nxt;

assign LED_out[7:4] = cnt[20:17]; //count div by 128k
assign LED_out[3:0] = cnt[6:3];   //count div by 8
assign cnt_nxt = cnt + 1'b1;

always @(posedge clk) begin
	if (!rst_n) begin
		cnt <= 21'b0;
	end
	else begin
		cnt <= cnt_nxt;
	end
end
	
endmodule