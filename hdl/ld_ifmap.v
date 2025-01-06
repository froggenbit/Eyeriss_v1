/*
    This module is for ifmap bank. It loads the values into ifmap spads of the PEs through 25 output wires.
    clk : input clock signal
    en : input enable signal indicating to start loading
    filer_widthfiler_width: input, no of columns in filter
    filter_height : input, no of rows in filter
    ic : input, no of different channels processed by a PE
    icb: input, no of different channels processed by PE sets
    ifm_height : input, height of the feature map
    ifm_width : input, width of the feature map
    w0,w1 .....w24 : output wires connecting feature map bank to the 2-D pe array diagonally
    12*14 array has 25 diagonal
*/
module ld_ifmap (
    clk, en, icb, ic,filter_width,
    filter_height, ifm_height, ifm_width,
    w0,w1,w2,w3,w4,w5,w6,w7,w8,
    w9,w10,w11,w12,w13,w14,w15,
    w16,w17,w18,w19,w20,w21,w22,w23,w24
);
input           clk;
input           en;
input [4:0]     icb; // number of PE set processing different icb
input [4:0]     ic; // ic: icb in a PE set
input [15:0]    ifm_width;
input [15:0]    ifm_height;
input [4:0]     filter_width;
input [4:0]     filter_height;
// 25 output wires assigned to the PE-2D array diagonally.
output reg [15:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w20,w21,w22,w23,w24;

// because 3x3 PE's need work with ifm diagonally, PE00 needs w0, PE01,PE10
// needs w1, PE02,PE11,PE20 needs w2, PE12,PE21 needs w3, PE22 needs w4
reg [9:0] count_ifm_height  = 10'd0; // control output 5 w per cycle, always equal to ifm_height per cycle

// the first en calc row0 called window0 in horizon, the second en calc row1 called window1
// the last en calc row2 called window 2.
reg [9:0] count_stride   = 10'h3ff; // base value of the sliding window of the ifmap

// count_ic        :   0   1   0   1   0   1   0   1   0   1   0   1
// count_ifm_width :   0   0   1   1   2   2   0   0   1   1   2   2
// count_icb       :   0   0   0   0   0   0   1   1   1   1   1   1
// w               :   wo~w4                 , w3~w7
reg [9:0] count_ic = 10'd0; // to keep record of parameter ic traversed
reg [9:0] count_filter_width = 10'd0; // to keep record of parameter s traversed
reg [9:0] count_icb = 10'd0; // to keep record of parameter icb traversed

reg [9:0] temp    = 10'd0;
reg [15:0]  ifmap[10000:0];
reg [3:0]   pe_set_base = 4'b0000; // PE set base value which gets incremented by icb after each icb*filter_width cycles
always @(posedge en) begin
    count_stride = count_stride + 1;
    pe_set_base = 4'b0000;
    if (count_stride == ifm_width-filter_width+1) // ofm width
        count_stride = 0;
end
always @(posedge clk) begin
    if (en) begin
        // we assign all the 25 wires according to the division of different PE sets
        // declare temp and count_ifm_height
        count_ifm_height  = 4'b0000;
        // PE00,10,20,30,40 works, then PE30,40,50,60,70 works
        temp    = pe_set_base;
        if (temp == 0) begin
            if (count_ifm_height < ifm_height) begin
                // ifmap[icb-ic,h,w]:[0-0,0,0],[0-1,0,0],[0-0,0,1],[0-1,0,1],[0-0,0,2],[0-0,0,2],[0-1,0,2]
                w0      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w0      = 0;
        end
        else begin
            w0 = 0;
        end
        if (temp == 1) begin
            if (count_ifm_height<ifm_height) begin
                w1      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w1      = 0;
        end
        else begin
            w1 = 0;
        end
        if (temp == 2) begin
            if (count_ifm_height<ifm_height) begin
                 w2     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w2      = 0;
        end
        else begin
            w2 = 0;
        end
        if (temp == 3) begin
            if (count_ifm_height<ifm_height) begin
                w3      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w3      = 0;
        end
        else begin
            w3 = 0;
        end
        if (temp == 4) begin
            if (count_ifm_height<ifm_height) begin
                w4      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w4      = 0;
        end
        else begin
            w4 = 0;
        end
        if (temp == 5) begin
            if (count_ifm_height<ifm_height) begin
                w5      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w5      = 0;
        end
        else begin
            w5 = 0;
        end
        if (temp == 6) begin
            if (count_ifm_height<ifm_height) begin
                w6      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w6      = 0;
        end
        else begin
            w6 = 0;
        end
        if (temp == 7) begin
            if (count_ifm_height<ifm_height) begin
                w7      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w7      = 0;
        end
        else begin
            w7 = 0;
        end
        if (temp == 8) begin
            if (count_ifm_height<ifm_height) begin
                w8      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w8      = 0;
        end
        else begin
            w8 = 0;
        end
        if (temp == 9) begin
            if (count_ifm_height<ifm_height) begin
                w9      = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w9      = 0;
        end
        else begin
            w9 = 0;
        end
        if (temp == 10) begin
            if (count_ifm_height<ifm_height) begin
                w10     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w10 = 0;
        end
        else begin
            w10 = 0;
        end
        if (temp == 11) begin
            if (count_ifm_height<ifm_height) begin
                w11     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w11 = 0;
        end
        else begin
            w11 = 0;
        end
        if (temp == 12) begin
            if (count_ifm_height<ifm_height) begin
                w12     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w12     = 0;
        end
        else begin
            w12 = 0;
        end
        if (temp == 13) begin
            if (count_ifm_height<ifm_height) begin
                w13     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w13     = 0;
        end
        else begin
            w13 = 0;
        end
        if (temp == 14) begin
            if (count_ifm_height<ifm_height) begin
                w14     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w14     = 0;
        end
        else begin
            w14 = 0;
        end
        if (temp == 15) begin
            if (count_ifm_height<ifm_height) begin
                w15     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w15     = 0;
        end
        else begin
            w15 = 0;
        end
        if (temp == 16) begin
            if (count_ifm_height<ifm_height) begin
                w16     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w16     = 0;
        end
        else begin
            w16 = 0;
        end
        if (temp == 17) begin
            if (count_ifm_height<ifm_height) begin
                w17     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w17     = 0;
        end
        else begin
            w17 = 0;
        end
        if (temp == 18) begin
            if (count_ifm_height<ifm_height) begin
                w18     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w18     = 0;
        end
        else begin
            w18 = 0;
        end
        if (temp == 19) begin
            if (count_ifm_height<ifm_height) begin
                w19     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w19     = 0;
        end
        else begin
            w19 = 0;
        end
        if (temp == 20) begin
            if (count_ifm_height<ifm_height) begin
                w20     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w20     = 0;
        end
        else begin
            w20         = 0;
        end
        if (temp == 21) begin
            if (count_ifm_height<ifm_height) begin
                w21     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w21     = 0;
        end
        else begin
            w21 = 0;
        end
        if (temp == 22) begin
            if (count_ifm_height<ifm_height) begin
                w22     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w22     = 0;
        end
        else begin
            w22 = 0;
        end
        if (temp == 23) begin
            if (count_ifm_height<ifm_height) begin
                w23     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w23     = 0;
        end
        else begin
            w23 = 0;
        end
        if (temp == 24) begin
            if (count_ifm_height<ifm_height) begin
                w24     = ifmap[count_icb*ic*ifm_height*ifm_width + count_ic*ifm_width*ifm_height + count_ifm_height*ifm_width + count_filter_width + count_stride];
                count_ifm_height  = count_ifm_height+1;
                temp    = temp+1;
            end
            else
                w24 = 0;
        end
        else begin
            w24 = 0;
        end
        count_ic = count_ic + 1;
        if (count_ic == ic) begin
            count_ic = 0;
            count_filter_width = count_filter_width + 1;
        end
        if (count_filter_width == filter_width) begin
            count_filter_width = 0;
            count_icb = count_icb + 1;
            pe_set_base = pe_set_base + filter_height;
        end
        if (count_icb == icb) begin
            count_icb = 0;
        end
    end
    else begin
        count_ic = 4'b0000; // reset all these parameters when enable is turned off.
        count_icb = 4'b0000;
        count_filter_width = 4'b0000;
    end
end
endmodule
