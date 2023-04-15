module amplifier (
    input clk,                       // System clock
    input reset,                     // Reset signal
    input signed [7:0] in_signal,    // Input signal from signal generator
    output reg signed [7:0] out_signal// Output signal
);

parameter F_REF = 50;                // Reference frequency (in MHz)
parameter F_OUT = 100;               // Desired output frequency (in MHz)
parameter K_P = 0.05;                // Proportional gain
parameter K_I = 0.005;               // Integral gain

reg [7:0] phase;                     // Phase accumulator
reg [7:0] delta;                     // Phase increment
reg [15:0] error_accum;              // Error accumulator for PI controller
reg [7:0] proportional;              // Proportional term of PI controller
reg [7:0] integral;                  // Integral term of PI controller

// Calculate delta (phase increment)
always @* begin
    delta = $signed($pow(2, 8)) * 2 * $sin((2 * $pi * F_OUT / F_REF) / $pow(2, 8));
end

// Generate output signal with phase lock and amplification
always @(posedge clk or posedge reset) begin
    if (reset) begin
        phase <= 0;
        out_signal <= 0;
        error_accum <= 0;
        proportional <= 0;
        integral <= 0;
    end
    else begin
        // Calculate error and update error accumulator
        reg [7:0] error = in_signal - out_signal;
        error_accum <= error_accum + error;
        
        // Calculate proportional and integral terms of PI controller
        proportional <= K_P * error;
        integral <= K_I * error_accum;
        
        // Calculate phase increment with feedback from PI controller
        reg [7:0] feedback = proportional + integral;
        delta <= delta + feedback;
        
        // Update phase accumulator and output signal
        phase <= phase + delta;
        out_signal <= $signed(2 * in_signal * $cos(phase));
    end
end

endmodule
 
