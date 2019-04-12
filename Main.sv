
module ClockDivisor#(parameter DIVISIONS = 2) (
    input  logic i_clk,
    output logic o_clk
    );
    logic [DIVISIONS-1:0] counter;
    always @(posedge i_clk)
        counter <= counter + 1;
    assign o_clk = counter[DIVISIONS-1];
endmodule

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

module FakeADC(
    input  logic       i_clk,
    input  logic [9:0] i_fake_in,
    output logic [9:0] o_out
    );
    always @ (posedge i_clk)
            o_out <= i_fake_in;
endmodule

module ShiftRegister#(parameter SIZE = 8, DATA_WIDTH = 1) (
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

module DataToPixel(
    input  logic [9:0] i_data,
    output logic [8:0] o_pixel
    );
    assign o_pixel = 480 - (i_data*480)/1024;
endmodule

module Main(
    input  logic       CLK100MHZ,
    
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic       VGA_HS,
    output logic       VGA_VS,

    input  logic       BTNC, BTNU, BTNL, BTNR, BTND,
    output logic [15:0] LED,
    input  logic [15:0] SW
    );
    
    logic [9:0] latest_value;
    FakeADC(
        .i_clk(CLK100MHZ),
        .i_fake_in(SW[9:0]),
        .o_out(latest_value)
    );
//    logic [8:0] lvy = 480 - (latest_value*480)/1024;
//    assign LED[8:0] = lvy;
    
    logic shift_register_clk;
    ClockDivisor#(22)(
        .i_clk(CLK100MHZ),
        .o_clk(shift_register_clk)
    );
    
    logic [9:0] values [0:639];
    ShiftRegister#(640, 10)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(latest_value),
        .o_data(values)
    );
    
    logic input_clk;
    ClockDivisor#(20)(
        .i_clk(CLK100MHZ),
        .o_clk(input_clk)
    );
    
    logic [9:0] cursor_x;
    logic [8:0] cursor_y;
    
    always @ (posedge input_clk) begin
        if          (BTNR) begin
            if (cursor_x < 639)
                cursor_x <= cursor_x+1;
        end else if (BTNL) begin
            if (cursor_x > 1)
                cursor_x <= cursor_x-1;
        end
        
        if          (BTNU) begin
            if (cursor_y > 1)
                cursor_y <= cursor_y-1;
        end else if (BTND) begin
            if (cursor_y < 479)
                cursor_y <= cursor_y+1;
        end
    end
    
    
    logic [9:0] trigger_x = 600;
    logic [8:0] trigger_y;
    
    always @ (posedge input_clk) begin
        if          (SW[15]) begin
            if (trigger_y > 1)
                trigger_y <= trigger_y-1;
        end else if (SW[14]) begin
            if (trigger_y < 479)
                trigger_y <= trigger_y+1;
        end
    end
    
    logic [9:0] vga_x;
    logic [8:0] vga_y;
    
    logic trigger;
    Trigger#(8)(
        .i_strobe_x(vga_x),
        .i_strobe_y(vga_y),
        
        .i_trigger_x(trigger_x),
        .i_trigger_y(trigger_y),
        
        .o_value(trigger)
    );

    logic [2:0] color;
    logic [2:0] sketch_color;
    logic [2:0] trigger_color = 3'b110;
    
    logic [8:0] signal_pixel;
    DataToPixel(.i_data(values[vga_x]), .o_pixel(signal_pixel));
    
    logic [2:0] signal_color  = (vga_y==signal_pixel) ? 3'b011 : 3'b000;
//    assign color = trigger ? trigger_color : sketch_color;
    assign color = signal_color;
    
    RAM#(19, 3, 2**19)(
        .i_clk(CLK100MHZ),
        
        .i_addr({cursor_x, cursor_y}),
        .i_data(SW[2:0]),
        
        .o_addr({vga_x, vga_y}),
        .o_data(sketch_color)
    );

    logic clk25mhz;
    ClockDivisor#(2)(
        .i_clk(CLK100MHZ),
        .o_clk(clk25mhz)
    );

    VGA(
        .i_clk(CLK100MHZ),
        .i_pixel_clk(clk25mhz),
        .i_color({{4{color[2]}},{4{color[1]}},{4{color[0]}}}),
        
        .o_coord_x(vga_x),
        .o_coord_y(vga_y),
        
        .o_h_sync(VGA_HS),
        .o_v_sync(VGA_VS),
        .o_vga_r(VGA_R),
        .o_vga_g(VGA_G),
        .o_vga_b(VGA_B)
    );
    
endmodule
