
module Main(
    input  logic       CLK100MHZ,
    
    output logic [3:0] VGA_R,
    output logic [3:0] VGA_G,
    output logic [3:0] VGA_B,
    output logic       VGA_HS,
    output logic       VGA_VS,

    input  logic       BTNC, BTNU, BTNL, BTNR, BTND,
    output logic [15:0] LED
    );
    
    logic [31:0] counter;
    always @(posedge CLK100MHZ) begin
        counter <= counter + 1;
    end
    logic clk25mhz = counter[1];
    
    logic [9:0] x;
    logic [9:0] y;
    logic active;
    VGA display(
        .i_clk(clk25mhz),
        .o_h_sync(VGA_HS),
        .o_v_sync(VGA_VS),
        .o_active(active),
        .o_coord_x(x),
        .o_coord_y(y)
    );
    
//    logic sq_a,sq_b,sq_c,sq_d;
//    assign sq_a = (x >= 0) & (y >=  0) & (x < 100) & (y < 100);
//    assign sq_b = (x > 200) & (y > 120) & (x < 360) & (y < 280);
//    assign sq_c = (x > 280) & (y > 200) & (x < 440) & (y < 360);
//    assign sq_d = (x >= 540) & (y > 380) & (x < 640) & (y < 480);

    logic [9:0] pen_x;
    logic [9:0] pen_y;
    logic [19:0] i_addr = pen_y*640 + pen_x;
    logic [19:0] o_addr = y*640+x;
    logic i_ink = 1'b1;
    logic o_ink;
    RAM#(19, 1, 480*640)(
        .i_clk(CLK100MHZ),
        .i_addr(i_addr),
        .o_addr(o_addr),
        .i_data(i_ink),
        .o_data(o_ink)
    );
    always @ (posedge counter[20]) begin
        if          (BTNR) begin
            if (pen_x < 639)
                pen_x <= pen_x+1;
        end else if (BTNL) begin
            if (pen_x > 1)
                pen_x <= pen_x-1;
        end
        
        if          (BTNU) begin
            if (pen_y > 1)
                pen_y <= pen_y-1;
        end else if (BTND) begin
            if (pen_y < 479)
                pen_y <= pen_y+1;
        end
    end    
    
    always @ (posedge clk25mhz) begin
        if (active) begin
//            VGA_R[3] <= sq_b;         // square b is red
//            VGA_G[3] <= sq_a | sq_d;  // squares a and d are green
//            VGA_B[3] <= sq_c;         // square c is blue
              {VGA_R, VGA_G, VGA_B} = o_ink==1'b1 ? {x[3:0], x[3:0]*y[3:0], y[3:0]} : 12'h111;
        end else begin
            {VGA_R, VGA_G, VGA_B} = 12'h000;
        end
    end
    




endmodule
