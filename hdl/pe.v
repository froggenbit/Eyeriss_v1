/* PE - the main fuctional block of interest
    ifmap: the load line to get data for loading 16 bit ifmap
    filt: the load line to get data for loading 16 bit filters
    ipsum: the load line to get the ipsum for doing vertical sum from the MUX in PE array
    opsum: the wire to transfer the calculated psums summed with psums from lower PE's to the top of the PE set
    clk : clock for synchronisation
    filter_width : the filter width size
    load: load signal indication some type (ifmap/filt) is taking place
    load2: load signal to specify ifmap loading is taking place
    load3: load signal to specift filter loading is taking place
    start: control signal from pe_array_control (Master Control) to start computation as all PE sets are loaded
            sequentially but work parallely a common start signal is required
    complete: signal to tell the comutation assigned has completed. Helps in loading new data from Memory Banks
            for next calculation cycle and store the calculated psums into the shift registers
*/
module pe (
    ifmap, filt, ipsum, opsum, clk,
    filter_width, load, load2, load3,
    oc, ic, start, complete
);
input                   clk;
input                   start;
input [4:0]             filter_width; // Filter Size in range 1-12, the filter width
input [4:0]             oc; // The no of filters used together. Max = 24, which are interleaved while giving input to a PE set
input [4:0]             ic; // No of channels together Max = 4, Channels are interleaved after interleaving the ’p’ filters.
input                   load;
input                   load2;    // used along with load ie load = load2 = 1  when only ifmap is to be updated
input                   load3;    // used along with load ie load = load3 = 1  when only filt needs to be updated
// [0,0,0],[1,0,0],[0,0,1],[1,0,1],[0,0,2],[1,0,2]
input [15:0]            ifmap;
// [0,0,0,0],[1,0,0,0],[2,0,0,0],[0,1,0,0],[1,1,0,0],[2,1,0,0],
// [0,0,0,1],[1,0,0,1],[2,0,0,1],[0,1,0,1],[1,1,0,1],[2,1,0,1],
// [0,0,0,2],[1,0,0,2],[2,0,0,2],[0,1,0,2],[1,1,0,2],[2,1,0,2]
input [15:0]            filt;
input [15:0]            ipsum;
output reg [15:0]       opsum;
output                  complete;

reg [3:0] addr_ifmap;        // Needs to update at the end of every 4*oc cycles
reg [7:0] addr_filter;        // Need to continuously update when 4 cycles complete as earlier
reg [4:0] addr_ipsum;        // Now need to update it at the after every 4 cycles with a modulo of p
reg [15:0] ifmap_spad_dout_d1,filter_spad_dout_d1,ipsum_spad_dout_d1;
reg signed [15:0] r6;     // r6 found after the MUX2 lower one

// intermidiate wires
wire [15:0] ifmap_spad_dout,filter_spad_dout,ipsum_spad_dout,d,f;
reg signed [15:0] ipsum_spad_din;
reg signed [15:0] e;
wire ifw, fsw, psw, M1, M2, adw, adw2, ifw2, ifa, fsw2;
reg en2 = 1'b0;

//  so that only when load2 equal zero we have to write in the feature spad
assign fsw2   = fsw & ~load2 & load3;
//  so that we dont go out ot bound
assign ifw2   = ifw & ~load3 & load2;
ifmap_spad u_ifmap_spad (
    .clk(clk),
    .addr(addr_ifmap),
    .we(ifw2),
    .data_out(ifmap_spad_dout),
    .data_in(ifmap)
);
filter_spad u_filter_spad (
    .clk(clk),
    .addr(addr_filter),
    .we(fsw2),
    .data_out(filter_spad_dout),
    .data_in(filt)
); // Input will get braodvasted from the mesh in the outer circuit
psum_spad u_psum_spad (
    .clk(clk),
    .addr(addr_ipsum),
    .we(adw&start),
    .data_out(ipsum_spad_dout),
    .data_in(ipsum_spad_din)
);  // and start to avoid
always @(negedge clk) begin
    ifmap_spad_dout_d1 <= ifmap_spad_dout;
    filter_spad_dout_d1 <= filter_spad_dout;
    ipsum_spad_dout_d1 <= ipsum_spad_dout;
    r6  <= f;
end
// just for testing
always @( posedge adw) begin
    addr_filter <= addr_filter+1;
end
reg comp=0;
reg comp2;
always@(negedge adw) begin // posedge adw2
    if(addr_ipsum == oc-1 && comp != 1 )
        addr_ipsum = 5'b00000;
    else if (comp != 1)
        addr_ipsum <= addr_ipsum+1;
end
always @( posedge ifa) begin
    addr_ifmap <= addr_ifmap+1;
end
always@(posedge load2) begin
    addr_ifmap <= 4'b0000;
    addr_filter <= 8'b00000000 ;
    addr_ipsum <= 5'b00000;
    en2 <=0;
end
always@(posedge load3) begin
    addr_ifmap <= 4'b0000;
    addr_filter <= 8'b00000000 ;
    addr_ipsum <= 5'b00000;
end
always @(posedge load) begin
    addr_ifmap <= 4'b0000;
    addr_filter <= 8'b00000000 ;
    addr_ipsum <= 5'b00000;
    //comp <= 0;
    en2 = 0;
end
reg [15:0] mux2_control = 16'h0000;
always @(posedge start) begin
    addr_ifmap <= 4'b0000;
    addr_filter <= 8'b00000000 ;
    addr_ipsum <= 5'b00000;
    comp <= 0;
    mux2_control <= mux2_control + 1 ;
end
always @(negedge load) begin
    addr_ifmap <= 4'b0000;
    addr_filter <= 8'b00000000;
    addr_ipsum <= 5'b00000;
    comp <= 0;
end
reg [15:0] tempo=16'h0000;
always @(*)
    opsum = tempo + ipsum;
always @(posedge complete) begin
    addr_ipsum = 5'b00000;
    comp <=1;
end
// register t1(
//     .clk(clk),
//     .in0(comp),
//     .out(comp2)
// );
always@(negedge clk) begin
    comp2 <= comp;
end
always @(negedge clk) begin
    if((comp == 1 ) && addr_ipsum < oc-1) begin
        addr_ipsum <= addr_ipsum+1;
    end
    else if(comp == 1 && addr_ipsum == oc-1) begin
        comp <= 0;
    end
end
always @(posedge clk) begin
    if(comp2 == 1 && addr_ipsum <= oc)
        tempo = ipsum_spad_dout;
end
always @(negedge clk) begin
    if(load == 1'b1) begin
        addr_filter <= addr_filter+1;
        if(addr_ifmap < 4'hc && en2 == 0) begin // when it becomes 12 en2 will become one and at the same time 12 will go to 11 and stay // only for simulation
            en2   <= 0;
            addr_ifmap  <= addr_ifmap+1;      // addr_ifmap corresponds to a 12 size memeory and
        end
        else begin
            en2 <= 1;
            addr_ifmap<= addr_ifmap -1;
        end
    end
end
pe_control u_pe_control (.clk(clk), .ifw(ifw), .fsw(fsw), .psw(psw), .Mux1(M1), .Mux2(M2) ,.adw(adw), .adw2(adw2), .ifa(ifa),.complete(complete) , .load(load), .oc(oc), .ic(ic), .filter_width(filter_width),  .start(start));
mult_pipe2 u_mult_pipe2 (.a(ifmap_spad_dout_d1), .b(filter_spad_dout_d1), .clk(clk), .pdt(d));
// mux2X1 Mux1     (.in0(d),.in1(ipsum),.sel(M1),.out(e));
// sum S1          (.x(r6), .y(e), .sume(ipsum_spad_din));
// mux2X1 Mux2     (.in0(ipsum_spad_dout_d1), .in1(16'b0000000000000000), .sel(M2 ),.out(f));
assign e = M1 ? ipsum : d;
assign ipsum_spad_din = r6+e;
assign f = M2 ? 16'h0 : ipsum_spad_dout_d1;
endmodule
