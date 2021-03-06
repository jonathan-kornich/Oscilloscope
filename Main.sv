// VCC GND   OUT    IN    CS   CLK
// Red Black Yellow Green Blue White



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
    input  logic JA4_OUT,
    
    output  logic CA, CB, CC, CD, CE, CF, CG, DP,
    output  logic [7:0] AN
    );
    
 ////////////////////////////////////////////////////////////////////////////////    
//                                                                            ADC
        
    logic adc_clk;
    ClockDivisor#(9)(
        .i_clk(CLK100MHZ),
        .o_clk(adc_clk)
    );
    
    logic [9:0] data0;
    logic [9:0] data1;
    ADC(
        .p_clk(JA1_CLK),
        .p_cs(JA2_CS),
        .p_in(JA3_IN),
        .p_out(JA4_OUT),
        
        .i_clk(adc_clk),
        .o_data0(data0),
        .o_data1(data1)
    );
    
////////////////////////////////////////////////////////////////////////////////    
//                                                               Data Collection
    
    // Determines how fast new data replaces the old data.
    logic shift_register_clk;
    ClockDivisor#(20)(
        .i_clk(CLK100MHZ),
        .o_clk(shift_register_clk)
    );
    
    // Contains analog channel 1.
    logic [9:0] values0 [0:639];
    ShiftRegister#(640, 10)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(data0),
        .o_data(values0)
    );
    
    // Contains analog channel 2.
    logic [9:0] values1 [0:639];
    ShiftRegister#(640, 10)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(data1),
        .o_data(values1)
    );
    
    // Contains digital channel 1.
    logic d_values1 [0:639];
    ShiftRegister#(640, 1)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(SW[0]),
        .o_data(d_values1)
    );
    
    // Contains digital channel 2.
    logic d_values2 [0:639];
    ShiftRegister#(640, 1)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(SW[1]),
        .o_data(d_values2)
    );
    
    // Contains digital channel 3.
    logic d_values3 [0:639];
    ShiftRegister#(640, 1)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(SW[2]),
        .o_data(d_values3)
    );
    
    // Contains digital channel 4.
    logic d_values4 [0:639];
    ShiftRegister#(640, 1)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(SW[3]),
        .o_data(d_values4)
    );
    
////////////////////////////////////////////////////////////////////////////////    
//                                                     VGA clock and coordinates
    
    logic [9:0] vga_x;
    logic [8:0] vga_y;
    
    logic clk25mhz;
    ClockDivisor#(2)(
        .i_clk(CLK100MHZ),
        .o_clk(clk25mhz)
    );
    
////////////////////////////////////////////////////////////////////////////////    
//                                                              Trigger Triangle

    logic [9:0] trigger_x = 600;
    logic [8:0] trigger_y;
    
    // How fast buttons are sampled.
    logic clktrigger;
    ClockDivisor#(20)(
        .i_clk(CLK100MHZ),
        .o_clk(clktrigger)
    );
    
    // Moving logic.
    always @ (posedge clktrigger) begin
        if          (BTNU) begin
            if (trigger_y > 1)
                trigger_y <= trigger_y-1;
        end else if (BTND) begin
            if (trigger_y < 479)
                trigger_y <= trigger_y+1;
        end
    end

    // Drawing the trigger.
    logic trigger;
    Trigger#(8)(
        .i_strobe_x(vga_x),
        .i_strobe_y(vga_y),
        
        .i_trigger_x(trigger_x),
        .i_trigger_y(trigger_y),
        
        .o_value(trigger)
    );
    logic [11:0] trigger_color = trigger ? 12'hFFF : 12'h000;
    
////////////////////////////////////////////////////////////////////////////////    
//                                                                   VGA Monitor
    
    // Drawing signals.
    
    logic [11:0] a_sig1_col;
    Color_AnalogSignal(
        .i_data(values0),
        .i_color(12'h0FF),
        .i_vga_x(vga_x), .i_vga_y(vga_y), .o_color(a_sig1_col)
    );
    
    logic [11:0] a_sig2_col;
    Color_AnalogSignal(
        .i_data(values1),
        .i_color(12'hFF0),
        .i_vga_x(vga_x), .i_vga_y(vga_y), .o_color(a_sig2_col)
    );
    
    logic [11:0] d_sig1_col;
    Color_DigitalSignal#(460,20)(
        .i_data(d_values1),
        .i_color(12'hF00),
        .i_vga_x(vga_x), .i_vga_y(vga_y), .o_color(d_sig1_col)
    );
    
    logic [11:0] d_sig2_col;
    Color_DigitalSignal#(420,20)(
        .i_data(d_values2),
        .i_color(12'hD02),
        .i_vga_x(vga_x), .i_vga_y(vga_y), .o_color(d_sig2_col)
    );
    
    logic [11:0] d_sig3_col;
    Color_DigitalSignal#(380,20)(
        .i_data(d_values3),
        .i_color(12'hB04),
        .i_vga_x(vga_x), .i_vga_y(vga_y), .o_color(d_sig3_col)
    );
    
    logic [11:0] d_sig4_col;
    Color_DigitalSignal#(340,20)(
        .i_data(d_values4),
        .i_color(12'h906),
        .i_vga_x(vga_x), .i_vga_y(vga_y), .o_color(d_sig4_col)
    );
    
    // Final color of pixel.
    logic [11:0] color;
    assign color = a_sig1_col | a_sig2_col | d_sig1_col | d_sig2_col | d_sig3_col | d_sig4_col | trigger_color;
    
    // Send data to monitor.
    VGA(
        .i_clk(CLK100MHZ),
        .i_pixel_clk(clk25mhz),
        .i_color(color),
        
        .o_coord_x(vga_x),
        .o_coord_y(vga_y),
        
        .o_h_sync(VGA_HS),
        .o_v_sync(VGA_VS),
        .o_vga_r(VGA_R),
        .o_vga_g(VGA_G),
        .o_vga_b(VGA_B)
    );
    
////////////////////////////////////////////////////////////////////////////////    
//                                                         Seven Segment Display
    
    logic [3:0] numbers[0:7];
    logic dots[0:7];
    
    // Convert ADC 10-bit value to voltage number.
    VoltageToSevenSegment(
        .reading1(data0),
        .reading2(data1),
        .numbers(numbers),
        .dots(dots)
    );
    
    // Send data to decoder.
    MultipleSevenSegmentDisplays(
        .i_clk(adc_clk),
        .i_numbers(numbers),
        .i_dots(dots),
        .p_cathodes({CA, CB, CC, CD, CE, CF, CG, DP}),
        .p_anodes(AN)
    );


    
////////////////////////////////////////////////////////////////////////////////    
//                                                             Old Etch-a-Sketch
    
////    logic input_clk;
////    ClockDivisor#(20)(
////        .i_clk(CLK100MHZ),
////        .o_clk(input_clk)
////    );
    
////    logic [9:0] cursor_x;
////    logic [8:0] cursor_y;
    
////    always @ (posedge input_clk) begin
////        if          (BTNR) begin
////            if (cursor_x < 639)
////                cursor_x <= cursor_x+1;
////        end else if (BTNL) begin
////            if (cursor_x > 1)
////                cursor_x <= cursor_x-1;
////        end
        
////        if          (BTNU) begin
////            if (cursor_y > 1)
////                cursor_y <= cursor_y-1;
////        end else if (BTND) begin
////            if (cursor_y < 479)
////                cursor_y <= cursor_y+1;
////        end
////    end
    
    
////    logic [9:0] trigger_x = 600;
////    logic [8:0] trigger_y;
    
////    always @ (posedge input_clk) begin
////        if          (SW[15]) begin
////            if (trigger_y > 1)
////                trigger_y <= trigger_y-1;
////        end else if (SW[14]) begin
////            if (trigger_y < 479)
////                trigger_y <= trigger_y+1;
////        end
////    end
    
//    logic [9:0] vga_x;
//    logic [8:0] vga_y;
    
////    logic trigger;
////    Trigger#(8)(
////        .i_strobe_x(vga_x),
////        .i_strobe_y(vga_y),
        
////        .i_trigger_x(trigger_x),
////        .i_trigger_y(trigger_y),
        
////        .o_value(trigger)
////    );

//    logic [2:0] color;
////    logic [2:0] sketch_color;
////    logic [2:0] trigger_color = 3'b110;
    
//    logic [8:0] signal_pixel;
//    DataToPixel(.i_data(values[vga_x]), .o_pixel(signal_pixel));
    
//    logic [2:0] signal_color  = (vga_y==signal_pixel) ? 3'b011 : 3'b000;
////    assign color = trigger ? trigger_color : sketch_color;
//    assign color = signal_color;
    
////    RAM#(19, 3, 2**19)(
////        .i_clk(CLK100MHZ),
        
////        .i_addr({cursor_x, cursor_y}),
////        .i_data(SW[2:0]),
        
////        .o_addr({vga_x, vga_y}),
////        .o_data(sketch_color)
////    );

//    logic clk25mhz;
//    ClockDivisor#(2)(
//        .i_clk(CLK100MHZ),
//        .o_clk(clk25mhz)
//    );

//    VGA(
//        .i_clk(CLK100MHZ),
//        .i_pixel_clk(clk25mhz),
//        .i_color({{4{color[2]}},{4{color[1]}},{4{color[0]}}}),
        
//        .o_coord_x(vga_x),
//        .o_coord_y(vga_y),
        
//        .o_h_sync(VGA_HS),
//        .o_v_sync(VGA_VS),
//        .o_vga_r(VGA_R),
//        .o_vga_g(VGA_G),
//        .o_vga_b(VGA_B)
//    );
    
endmodule
