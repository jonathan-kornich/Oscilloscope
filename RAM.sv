
module RAM #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 8, DEPTH = 256) (
    input  logic                  i_clk,
    input  logic [ADDR_WIDTH-1:0] i_addr,
    input  logic [ADDR_WIDTH-1:0] o_addr,
    input  logic [DATA_WIDTH-1:0] i_data,
    output logic [DATA_WIDTH-1:0] o_data 
    );

    logic [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 

    always @ (posedge i_clk) begin
        memory_array[i_addr] <= i_data;
        o_data <= memory_array[o_addr];   
    end
endmodule