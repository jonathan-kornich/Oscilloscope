
module ADC(
    output logic p_clk,
    output logic p_cs,
    output logic p_in,
    input  logic p_out,
    
    input  logic       i_clk,
    output logic [9:0] o_data0,
    output logic [9:0] o_data1,
    output logic       o_done
    );
    
    assign p_clk = i_clk;
    
    logic channel;

    logic [0:3] code = {2'b11, channel, 1'b1};
    
    logic [4:0] counter;
    
    always @ (negedge i_clk) begin
        counter <= counter + 1;
    end
    
    
    always @ (negedge i_clk) begin
        if (counter == 31)
            p_cs <= 1'b1;
        else
            p_cs <= 1'b0;
    end
    
    always @ (negedge i_clk) begin
        if (counter == 31)
            channel <= ~channel;
    end
    
    
    always @ (negedge i_clk) begin
        if (counter < 4)
            p_in <= code[counter];
        else
            p_in <= 1'b0;
    end
    
    
    logic [9:0] data;
    
    always @ (posedge i_clk) begin
        if ((6 <= counter) && (counter < 16)) begin
            data[9:1] <= data[8:0];
            data[0] <= p_out;
        end
    end
    
    always @ (negedge i_clk) begin
        if (counter == 15) begin
            if (channel == 0)
                o_data0 <= data;
            else
                o_data1 <= data;
            o_done <= 1'b1;
        end
    end
    
    always @ (negedge i_clk) begin
        if (counter == 16) begin
            o_done <= 1'b0;
        end
    end
    
endmodule