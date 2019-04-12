
module Trigger#(parameter WIDTH = 8) (
    input  logic [9:0] i_strobe_x,
    input  logic [8:0] i_strobe_y,
    
    input  logic [9:0] i_trigger_x,
    input  logic [8:0] i_trigger_y,
    
    output logic       o_value
    );
//    localparam POS_X = 400;
//    localparam POS_Y = 100;
//    localparam WIDTH = 8;
    
    logic [0:7] bitmap [0:14];
    assign bitmap[0]  = 8'b00000001;
    assign bitmap[1]  = 8'b00000011;
    assign bitmap[2]  = 8'b00000111;
    assign bitmap[3]  = 8'b00001111;
    assign bitmap[4]  = 8'b00011111;
    assign bitmap[5]  = 8'b00111111;
    assign bitmap[6]  = 8'b01111111;
    assign bitmap[7]  = 8'b11111111;
    assign bitmap[8]  = 8'b01111111;
    assign bitmap[9]  = 8'b00111111;
    assign bitmap[10] = 8'b00011111;
    assign bitmap[11] = 8'b00001111;
    assign bitmap[12] = 8'b00000111;
    assign bitmap[13] = 8'b00000011;
    assign bitmap[14] = 8'b00000001;
    
    logic in_frame = (i_trigger_x <= i_strobe_x) && (i_strobe_x < i_trigger_x+WIDTH) &&
                     (i_trigger_y <= i_strobe_y) && (i_strobe_y < i_trigger_y+2*WIDTH-1);
    logic [3:0] frame_x = i_strobe_x - i_trigger_x;
    logic [3:0] frame_y = i_strobe_y - i_trigger_y;
    assign o_value = in_frame ? bitmap[frame_y][frame_x] : 0;
    
endmodule

module DataToPixel(
    input  logic [9:0] i_data,
    output logic [8:0] o_pixel
    );
    assign o_pixel = 480 - (i_data*480)/1024;
endmodule