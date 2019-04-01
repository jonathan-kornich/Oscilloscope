
module Main(
    input  logic       CLK100MHZ,
    
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic       VGA_HS,
    output logic       VGA_VS

    );
    
    logic [1:0] counter4;
    always @(posedge CLK100MHZ) begin
        counter4 <= counter4 + 1;
    end
    logic clk25mhz = counter4[1];
    
//    assign {VGA_R, VGA_G, VGA_B} = 12'h000;
    
    logic [9:0] x;
    logic [9:0] y;
    VGA display(
        .i_clk(clk25mhz),
        .o_h_sync(VGA_HS),
        .o_v_sync(VGA_VS),
//        .o_visible_area(),
        .o_coord_x(x),
        .o_coord_y(y)
    );
    
    logic sq_a,sq_b,sq_c,sq_d;
    assign sq_a = (x >= 0) & (y >=  0) & (x < 100) & (y < 100);
    assign sq_b = (x > 200) & (y > 120) & (x < 360) & (y < 280);
    assign sq_c = (x > 280) & (y > 200) & (x < 440) & (y < 360);
    assign sq_d = (x >= 540) & (y > 380) & (x < 640) & (y < 480);

    assign VGA_R[3] = sq_b;         // square b is red
    assign VGA_G[3] = sq_a | sq_d;  // squares a and d are green
    assign VGA_B[3] = sq_c;         // square c is blue

endmodule
