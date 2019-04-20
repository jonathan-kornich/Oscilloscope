module HexToSevenSeg(
    input  logic [3:0] i_number,
    output logic [6:0] o_segments
    );
    always_comb begin
        case (i_number)        // ABCDEFG
            4'h0: o_segments = 7'b1111110;
            4'h1: o_segments = 7'b0110000;
            4'h2: o_segments = 7'b1101101;
            4'h3: o_segments = 7'b1111001;
            4'h4: o_segments = 7'b0110011;
            4'h5: o_segments = 7'b1011011;
            4'h6: o_segments = 7'b1011111;
            4'h7: o_segments = 7'b1110000;
            4'h8: o_segments = 7'b1111111;
            4'h9: o_segments = 7'b1110011;
            4'hA: o_segments = 7'b1110111;
            4'hB: o_segments = 7'b0011111;
            4'hC: o_segments = 7'b1001110;
            4'hD: o_segments = 7'b0111101;
            4'hE: o_segments = 7'b1001111;
            4'hF: o_segments = 7'b1000111;
        endcase
    end
endmodule

module SevenSegmentDisplay(
    input  logic [3:0] i_number,    // Number to display.
    input  logic       i_dot,
    input  logic [2:0] i_enable,   // Digit to light up.
    
    output logic [7:0] p_cathodes, // Cathodes.
    output logic [7:0] p_anodes    // Anodes.
    );
    logic [6:0] inverted;
    assign p_cathodes[7:1] = ~inverted; // Cathodes need to be low to light up segment.
    assign p_cathodes[0]   = ~i_dot;
    assign p_anodes   = ~(1 << i_enable); // Anode need to be high for light up digit.
    HexToSevenSeg(.i_number(i_number), .o_segments(inverted)); 
endmodule

module MultipleSevenSegmentDisplays(
    input  logic       i_clk,
    
    input  logic [3:0] i_numbers[0:7],    // Number to display.
    input  logic       i_dots[0:7],
//    input  logic [2:0] i_enable,   // Digit to light up.
    
    output logic [7:0] p_cathodes, // Cathodes.
    output logic [7:0] p_anodes    // Anodes.
    );
    logic [2:0] enable;
    
    always @ (posedge i_clk) begin
        enable <= enable + 1;
    end
    
    SevenSegmentDisplay(
        .i_number(i_numbers[enable]),
        .i_dot(i_dots[enable]),
        .i_enable(enable),
        .p_cathodes(p_cathodes),
        .p_anodes(p_anodes)
    );
endmodule