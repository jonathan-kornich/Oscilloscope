
module VGA(
    input  logic       i_clk,
    output logic       o_h_sync,
    output logic       o_v_sync,
    output logic       o_active,
    output logic [9:0] o_coord_x,
    output logic [9:0] o_coord_y
    );
    localparam d_H_ACTIVE      = 640;
    localparam d_H_FRONT_PORCH = 16;
    localparam d_H_SYNC        = 96;
    localparam d_H_BACK_PORCH  = 48;
    localparam d_H_BLANKING    = d_H_FRONT_PORCH + d_H_SYNC + d_H_BACK_PORCH;
    localparam d_H_TOTAL       = d_H_ACTIVE + d_H_BLANKING;
    
    localparam d_V_ACTIVE      = 480;
    localparam d_V_FRONT_PORCH = 10;
    localparam d_V_SYNC        = 2;
    localparam d_V_BACK_PORCH  = 33;
    localparam d_V_BLANKING    = d_V_FRONT_PORCH + d_V_SYNC + d_V_BACK_PORCH;
    localparam d_V_TOTAL       = d_V_ACTIVE + d_V_BLANKING;
    
    
    logic coord_x_lim = (o_coord_x == d_H_TOTAL);
    logic coord_y_lim = (o_coord_y == d_V_TOTAL);
    
    always @ (posedge i_clk) begin
        if (coord_x_lim) o_coord_x <= 0;
        else             o_coord_x <= o_coord_x + 1;
    end
    
    always @ (posedge i_clk) begin
        if (coord_x_lim) begin
            if (coord_y_lim) o_coord_y <= 0;
            else             o_coord_y <= o_coord_y + 1;
        end
    end
    
    logic h_sync, v_sync;
    always @ (posedge i_clk) begin
        h_sync <= (o_coord_x > d_H_ACTIVE + d_H_FRONT_PORCH) &&
                  (o_coord_x < d_H_ACTIVE + d_H_FRONT_PORCH + d_H_SYNC);
        v_sync <= (o_coord_y > d_V_ACTIVE + d_V_FRONT_PORCH) &&
                  (o_coord_y < d_V_ACTIVE + d_V_FRONT_PORCH + d_V_SYNC);
    end
    
    assign {o_h_sync, o_v_sync} = ~{h_sync, v_sync};
    
    always @ (posedge i_clk) begin
        o_active = (o_coord_x < d_H_ACTIVE) &&
                   (o_coord_y < d_V_ACTIVE);
    end
endmodule