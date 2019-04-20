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
    
//    SevenSegmentDisplay(
//        .i_number(SW[15:12]),
//        .i_dot(SW[11]),
//        .i_enable(SW[7:0]),
//        .p_cathodes({CA, CB, CC, CD, CE, CF, CG, DP}),
//        .p_anodes(AN)
//    );


    
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
    
    
    logic shift_register_clk;
    ClockDivisor#(20)(
        .i_clk(CLK100MHZ),
        .o_clk(shift_register_clk)
    );
    
    logic [9:0] values0 [0:639];
    ShiftRegister#(640, 10)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(data0),
        .o_data(values0)
    );
    
    logic [9:0] values1 [0:639];
    ShiftRegister#(640, 10)(
        .i_clk(shift_register_clk),
        .i_push(1'b1),
        .i_data(data1),
        .o_data(values1)
    );
    
    logic [9:0] vga_x;
    logic [8:0] vga_y;
    
    logic [8:0] signal0_y;
    DataToPixel(.i_data(values0[vga_x]), .o_pixel(signal0_y));
    logic [2:0] signal0_color = (vga_y==signal0_y) ? 3'b011 : 3'b000;
    
    logic [8:0] signal1_y;
    DataToPixel(.i_data(values1[vga_x]), .o_pixel(signal1_y));
    logic [2:0] signal1_color  = (vga_y==signal1_y) ? 3'b110 : 3'b000;
    
    logic [2:0] color;
    assign color = signal0_color | signal1_color;
    
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
    
    logic [3:0] numbers[0:7];
    logic dots[0:7];
    
    logic [5:0] voltage0 = (data0*33)/1024;
    logic [5:0] voltage1 = (data1*33)/1024;
    
    assign numbers[7] = 4'hC;
    assign numbers[6] = 4'h1;
    assign numbers[5] = voltage0/10;//data0[9:6];//SW[15:12];
    assign numbers[4] = voltage0%10;//data0[5:2];//SW[11:8];
    assign numbers[3] = 4'hC;
    assign numbers[2] = 4'h2;
    assign numbers[1] = voltage1/10;//data1[9:6];//SW[7:4];
    assign numbers[0] = voltage1%10;//data1[5:2];//SW[3:0];
    
    assign dots[7] = 0;
    assign dots[6] = 0;
    assign dots[5] = 1;
    assign dots[4] = 0;
    assign dots[3] = 0;
    assign dots[2] = 0;
    assign dots[1] = 1;
    assign dots[0] = 0;
    
    
    MultipleSevenSegmentDisplays(
        .i_clk(adc_clk),
        .i_numbers(numbers),
        .i_dots(dots),
//        .i_enable(SW[7:0]),
        .p_cathodes({CA, CB, CC, CD, CE, CF, CG, DP}),
        .p_anodes(AN)
    );
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
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
