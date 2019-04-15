
// Divides clock by a power of 2.
module ClockDivisor#(
    parameter DIVISIONS = 2 // Power of 2 to divide by.
    ) (
    input  logic i_clk, // Clock to divide.
    output logic o_clk  // Divided clock.
    );
    logic [DIVISIONS-1:0] counter;
    always @(posedge i_clk)
        counter <= counter + 1;
    assign o_clk = counter[DIVISIONS-1];
endmodule