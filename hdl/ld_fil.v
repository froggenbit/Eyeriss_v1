/*
    ld_fil is the module for filter bank. It loads the filter values to all the PEs
    clk : input clock signal
    en : input enable signal which indicates to start loading
    oc : input, no of different filters processes by a PE
    ic : input, no of different channels processed by a PE
    icb : input, no of different channels processed by PE sets
    ocb : input, no of different filters processed by PE sets
    filter_height : input, no of rows in the filter
    filter_width : input, no of colums in the filter
    w0,w1,......w11 : output wires connecting the filter bank to the 2-D PE array. These wires load the filter vaules into the PEs
*/
module ld_fil (
    clk, en,  oc, ic, icb, ocb, filter_height, filter_width,
    w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11
);
input               clk;
input               en;
input      [4:0]    oc,ic,icb,ocb,filter_height,filter_width;
output reg [15:0]   w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11; // 12 output wires to the 12 rows of the PE array

reg [15:0] filter [1000:0]; // 1-D array, filter buffer memory
reg [9:0] count_ocb = 10'd0; // To keep record of parameter ocb traversed
reg [9:0] count_icb = 10'd0; // To keep record of parameter icb traversed
reg [9:0] count_oc = 10'd0; // To keep record of parameter oc traversed
reg [9:0] count_ic = 10'd0; // To keep record of parameter ic traversed
reg [9:0] count_filter_width = 10'd0; // To keep record of parameter filter_width traversed
reg [9:0] count_filter_height = 10'd0; // To keep record of the filter row being assigned
wire [4:0]    filt_size;
assign filt_size = filter_height * filter_width;

always @(posedge clk) begin // To assign values to the wires according the interleaving
    if (en) begin
        count_ocb = 0;
        count_icb = 0;
        count_filter_height = 0;
        if (count_filter_height == filter_height) begin
            count_icb = count_icb + 1;
            count_filter_height = 0;
        end
        if (count_icb == icb) begin
            count_ocb = count_ocb + 1;
            count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w0 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 0
            // $display("[%0t]w0 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w1 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 1
            // $display("[%0t]w1 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w2 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 2
            // $display("[%0t]w2 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w3 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 3
            // $display("[%0t]w3 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w4= filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 4
            // $display("[%0t]w4 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w5= filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 5
            // $display("[%0t]w5 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w6= filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 6
            // $display("[%0t]w6 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w7 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 7
            // $display("[%0t]w7 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w8 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 8
            // $display("[%0t]w8 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w9 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 9
            // $display("[%0t]w9 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w10= filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 10
            // $display("[%0t]w10 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        if (count_ocb*icb + count_icb < ocb*icb) begin
            w11 = filter[count_ocb*oc*ic*icb*filt_size+count_oc*ic*icb*filt_size+count_icb*ic*filt_size+count_ic*filt_size+count_filter_height*filter_width+count_filter_width]; // 11
            // $display("[%0t]w11 index is :ocb=%d, oc=%d, icb=%d, ic=%d, h=%d, w=%d", $time, count_ocb, count_oc, count_icb, count_ic, count_filter_height, count_filter_width);
        end
        count_filter_height = count_filter_height + 1;
        if (count_filter_height == filter_height) begin
          count_icb = count_icb + 1;
          count_filter_height = 0;
        end
        if (count_icb == icb) begin
          count_ocb = count_ocb+1;
          count_icb = 0;
        end

        count_oc = count_oc+1;
        if (count_oc == oc) begin
          count_oc = 0;
          count_ic = count_ic+1;
        end
        if (count_ic == ic) begin
          count_ic = 0;
          count_filter_width = count_filter_width+1;
        end
    end
    else begin
        count_oc = 0;
        count_ic = 0;
        count_filter_width = 0;
    end
end

endmodule
