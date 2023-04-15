module pll(input clk, input reset, input signed [7:0] k, input signed [7:0] N, input signed [7:0] A, input signed [7:0] theta, output reg [7:0] phase);
    reg [7:0] phase_inc;
    reg [7:0] phase_est;
    reg [7:0] theta_hat;
    reg [7:0] phase_dif;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase <= 0;
            phase_est <= 0;
        end else begin
            phase_inc <= round(k * 256.0 / N);
            phase_est <= phase_est + phase_inc;
            theta_hat <= theta_hat + phase_dif;
            phase_dif <= (A * $cos((2 * $pi * (k * $past(256) / N + phase_est)) / 256) - A * $cos((2 * $pi * (k * 256 / N + phase_est)) / 256));
            phase <= phase_est + theta_hat;
        end
    end
endmodule

module my_design();
    wire clk, reset;
    wire signed [7:0] k, N, A, theta;
    wire signed [7:0] phase;
    pll my_pll(.clk(clk), .reset(reset), .k(k), .N(N), .A(A), .theta(theta), .phase(phase));
    // rest of your Verilog design here
endmodule
