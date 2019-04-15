

module Main(
    input  logic       CLK100MHZ,
    
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic       VGA_HS,
    output logic       VGA_VS,

    input  logic       BTNC, BTNU, BTNL, BTNR, BTND,
    output logic [15:0] LED,
    input  logic [15:0] SW,
    
    output logic JA1_CLK, JA2_CS, JA3_IN,
    input  logic JA4_OUT
    );
    
    logic adc_clk;
    logic [9:0] adc_data;
    
    ClockDivisor#(9)(
        .i_clk(CLK100MHZ),
        .o_clk(adc_clk)
    );
    
    ADC(
        .p_clk(JA1_CLK),
        .p_cs(JA2_CS),
        .p_in(JA3_IN),
        .p_out(JA4_OUT),
        
        .i_clk(adc_clk),
        .o_data(adc_data)
    );
    
    assign LED[9:0] = adc_data;
    
///////////////////////////////////////////////////////////////////////////
    
    
    
//    logic [9:0] latest_value;
//    FakeADC(
//        .i_clk(CLK100MHZ),
//        .i_fake_in(SW[9:0]),
//        .o_out(latest_value)
//    );
////    logic [8:0] lvy = 480 - (latest_value*480)/1024;
////    assign LED[8:0] = lvy;
    
    logic shift_register_clk;
    ClockDivisor#(22)(
        .i_clk(CLK100MHZ),
        .o_clk(shift_register_clk)
    );
    
    logic [9:0] values [0:639];
    ShiftRegister#(640, 10)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(adc_data),
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
