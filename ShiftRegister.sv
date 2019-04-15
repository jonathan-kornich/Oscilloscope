
//
module ShiftRegister#(
    parameter SIZE = 8,
    DATA_WIDTH = 1
    ) (
    input  logic                  i_clk,
    input  logic                  i_push,
    input  logic [DATA_WIDTH-1:0] i_data,
    output logic [DATA_WIDTH-1:0] o_data [0:SIZE-1]
    );
    always @ (posedge i_clk) begin
        if (i_push) begin
            o_data[1:SIZE-1] <= o_data[0:SIZE-2];
            o_data[0] <= i_data;
        end
    end
endmodule