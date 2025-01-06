module pe_control(clk, ifw, fsw, psw, Mux1,Mux2, adw,adw2,ifa,complete, load, oc, ic, filter_width, start);
    input start;
    input clk;
    input load;
    input [4:0] oc;
    input [4:0] ic;
    input [4:0] filter_width;
    output reg ifw;
    output reg fsw;
    output reg psw ;
    output reg adw;
    output reg adw2;
    output reg ifa;
    output reg Mux1;
    output reg Mux2;
    output reg complete;

    reg [1:0] cnt_4;
    reg [2:0] w_add3;
    reg [9:0] cnt_calc;          // Overall Completion
    reg [6:0] cnt_ifmap;         // Completion of address of ifmap counter
    wire [9:0] s3;
    wire [6:0] p4;
    // reg [5:0] temp =4;
    reg [4:0] count = 5'b00000;   // To let Mux2 be a one for only the first p cycles
    reg idle=1'b0;
    reg rstc3;
    wire rstc1,rstc2;

    always @(posedge start) begin
        count = 5'b00000;
        idle = 1'b0;
    end
    always@(posedge complete) begin
       idle <= 1'b1;
    end

    assign s3 = filter_width * oc * ic * 6'd4;
    assign p4 = oc * 6'd4;
    assign rstc1= ~load & start & ~idle;
    assign rstc2= ~load & start;

    // counter C1      (.clk(clk), .rstn(rstc1),  .out(cnt_4));            // Every fourth cycle
    always @ (negedge clk) begin
        if (!rstc1)
            cnt_4 <= 2'h0;
        else // 0,1,2,3,0,1,2,3,...
            cnt_4 <= cnt_4 + 1;
    end
    // counter2 C2     (.clk(clk), .rstn (rstc2), .out(cnt_calc) );            // till 4 * oc * ic * filter_width
    always @ (negedge clk) begin
        if (!rstc2)
            cnt_calc <= 10'h0;
        else // 0,1,2,3,0,1,2,3,...
            cnt_calc <= cnt_calc + 1;
    end
    // counter4p C3    (.clk(clk), .rstn (rstc3), .out(cnt_ifmap));           // to count till 4*p
    always @ (negedge clk) begin
        if (!rstc3)
            cnt_ifmap <= 7'h0;
        else // 0,1,2,3,0,1,2,3,...
            cnt_ifmap <= cnt_ifmap + 1;
    end
    // counter_add3 C4 (.clk(clk), .rstn(~idle),  .out(w_add3));
    always @ (negedge clk) begin
        if (idle)
            w_add3 <= 3'h0;
        else
            w_add3 <= w_add3 + 1;
    end
    always @(posedge clk) begin
        if(w_add3 == 3'b100)
            w_add3 <= 3'b000;    // asynchronous sort of reset
    end

    always @(*) begin
        if (cnt_4 == 2'b00 && load == 1'b0) begin
            ifw = 1'b0; // we actully need not write to them as they are set initially only
            fsw = 1'b0;
            psw = 1'b1;
        end
        else if (cnt_4 == 2'b00 && load == 1'b1) begin
            ifw = 1'b1; // we actully need not write to them as they are set initially only
            fsw = 1'b1; // ''''''''''''''''''''
            psw = 1'b0;
        end
        else if (load == 1'b1) begin
            ifw = 1'b1; // we actully need not write to them as they are set initially only
            fsw = 1'b1; // ''''''''''''''''''''
            psw = 1'b0;
        end
        else begin
            ifw = 1'b0;
            fsw = 1'b0;
            psw = 1'b0;
        end
        if (cnt_4 == 2'b11 && load == 1'b0)
            adw=1;
        else
            adw=0;
        if (w_add3 == 3'b100 && load == 1'b0)
            adw2=1;
        else
            adw2=0;
        if (cnt_ifmap == (p4-1)  && load == 1'b0) begin
            ifa=1;            // Control signal to increment the address of ifmap
            rstc3=0;          // if does not work need to set a max in the counter4p
        end
        else begin
            ifa=0;
            rstc3= ~load;
        end
        if (cnt_calc > s3) begin
            Mux1 = 1 ;
            complete=0;
        end
        else if (cnt_calc == (s3)) begin
            complete=1;
        end
        else begin
            Mux1=0;
            complete = 0;
        end
        if((cnt_4 == 2'b10 && count < oc)|| load == 1'b1) begin
            Mux2 = 1;
            count = count + 1;
        end
        else
            Mux2 = 0;
    end // end of the always(*) block
endmodule
