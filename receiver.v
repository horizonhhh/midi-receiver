/*
** ECE 353: Computer Systems Lab I
** Lab 4: MIDI Receiver in Verilog
**
** Ryan Lagasse, Perveshwer Jaswal, Ricardo Henriquez
*/

/**********************
**  Receiver Module  **
***********************/

module receiver (in, out);
  input     in;
  output    out;

  assign    out = in;
endmodule

/*****************
**  Submodules  **
******************/

module timer (clk, sample);
  input     clk;
  output    sample;

  // dff_pe t0 ();
  // dff_pe t1 ();
  // dff_pe t2 ();
  // dff_pe t3 ();
  // dff_pe t4 ();
  // dff_pe t5 ();
  // dff_pe t6 ();

  // ha ha0 ();
  // ha ha1 ();
  // ha ha2 ();
  // ha ha3 ();
  // ha ha4 ();
  // ha ha5 ();
  // ha ha6 ();

  assign sample = 0;

endmodule

/***************************
**  Primitive Submodules  **
****************************/

/* Half Adder */
module ha (a, b, s, c);
  input     a, b;
  output    s, c;
  wire      a, b, s, c;

  assign    s = a ^ b;
  assign    c = a & b;
endmodule

/* D Flip-Flop (Positive Edge-Triggered) */
module dff_pe (d, clk, q, reset);
  input     d, clk, reset;
  output    q;
  reg       q;

  always @ (posedge clk or negedge reset)
    if (~reset)     q <= 1'b0;
    else            q <= d;
  end
endmodule

/* D Flip-Flop (Negative Edge-Triggered) */
module dff_ne (d, clk, q, reset);
  input     d, clk, reset;
  output    q;
  reg       q;

  always @ (negedge clk or negedge reset)
    if (~reset)     q <= 1'b0;
    else            q <= d;
    end
  end
endmodule
