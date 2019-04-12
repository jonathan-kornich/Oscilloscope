
module FakeADC(
    input  logic       i_clk,
    input  logic [9:0] i_fake_in,
    output logic [9:0] o_out
    );
    always @ (posedge i_clk)
            o_out <= i_fake_in;
endmodule
