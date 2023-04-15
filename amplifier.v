module feedback_lockin_amplifier (
  input clk,                     // clock signal
  input reset_n,                 // reset signal
  input signal_in,               // input signal to be phase shifted
  input feedback_in,             // feedback signal from the output
  output reg signal_out          // output signal with 90 degree phase shift
);

reg [7:0] phase_reg;             // 8-bit register to store phase shift
reg [7:0] feedback_accumulator;  // 8-bit register to accumulate feedback signal
reg [7:0] feedback_gain;         // 8-bit register to store feedback gain
wire feedback_out;               // output feedback signal

// initialize registers
initial begin
  phase_reg = 8'b00000000;
  feedback_accumulator = 8'b00000000;
  feedback_gain = 8'b00001000;   // set initial feedback gain to 8
  signal_out = 1'b0;
end

// calculate feedback signal
assign feedback_out = $signed({1'b1, signal_out}) * $signed({1'b0, feedback_gain});

// lock-in amplifier module instantiation
lockin_amplifier lockin_amp (
  .clk(clk),
  .reset_n(reset_n),
  .signal_in(signal_in),
  .signal_out(signal_out)
);

// feedback loop
always @(posedge clk) begin
  if (reset_n) begin
    feedback_accumulator <= feedback_accumulator + feedback_out;
    feedback_gain <= feedback_gain + feedback_accumulator;
  end
end

endmodule
