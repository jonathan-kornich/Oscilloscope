
module ClockDivisor#(parameter DIVISIONS = 2) (
    input  logic i_clk,
    output logic o_clk
    );
    logic [DIVISIONS-1:0] counter;
    always @(posedge i_clk)
        counter <= counter + 1;
    assign o_clk = counter[DIVISIONS-1];
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

    logic [11:0] color_code;
    logic [9:0] cursor_x;
    logic [8:0] cursor_y;
    logic [9:0] vga_x;
    logic [8:0] vga_y;

    RAM#(19, 3, 2**19)(
        .i_clk(CLK100MHZ),
        
        .i_addr({cursor_x, cursor_y}),
        .i_data(SW[2:0]),
        
        .o_addr({vga_x, vga_y}),
        .o_data(color_code)
    );

    logic clk25mhz;
    ClockDivisor#(2)(
        .i_clk(CLK100MHZ),
        .o_clk(clk25mhz)
    );

    VGA(
        .i_clk(CLK100MHZ),
        .i_pixel_clk(clk25mhz),
        .i_color({{4{color_code[2]}},{4{color_code[1]}},{4{color_code[0]}}}),
        
        .o_coord_x(vga_x),
        .o_coord_y(vga_y),
        
        .o_h_sync(VGA_HS),
        .o_v_sync(VGA_VS),
        .o_vga_r(VGA_R),
        .o_vga_g(VGA_G),
        .o_vga_b(VGA_B)
    );
    
    logic button_clk;
    ClockDivisor#(20)(
        .i_clk(CLK100MHZ),
        .o_clk(button_clk)
    );
    
    always @ (posedge button_clk) begin
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

endmodule
