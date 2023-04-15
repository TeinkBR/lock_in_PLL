module signal_generator (
    input clk,             // System clock
    input reset,           // Reset signal
    output reg signed [7:0] signal    // Output signal
);

parameter PERIOD = 32;    // Period of output signal (in system clock cycles)
parameter WIDTH = 8;      // Width of output signal

reg [7:0] phase;          // Phase accumulator
reg [7:0] delta;          // Phase increment
reg [7:0] amplitude;      // Amplitude of output signal

// Set initial values of phase and amplitude
initial begin
    phase = 0;
    amplitude = 127;      // Half of the maximum value (255) to prevent overflow
end

// Calculate delta (phase increment)
always @* begin
    delta = $signed($pow(2, WIDTH-1)) * 2 * $sin((2 * $pi * PERIOD) / $pow(2, WIDTH));
end

// Generate output signal
always @(posedge clk or posedge reset) begin
    if (reset) begin
        phase <= 0;
        signal <= 0;
    end
    else begin
        phase <= phase + delta;
        signal <= $signed(amplitude * $sin(phase));
    end
end

endmodule
