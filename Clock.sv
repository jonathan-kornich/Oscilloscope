
module ClockDivisor#(parameter DIVISIONS = 2) (
    input  logic i_clk,
    output logic o_clk
    );
    logic [DIVISIONS-1:0] counter;
    always @(posedge i_clk)
        counter <= counter + 1;
    assign o_clk = counter[DIVISIONS-1];
endmodule