/* The filter scratch pad used inside the PE
    Its a 224 sized linear 16 bit SRAM
    Its is negative edged
    addr: the address to read/write data depending on we
    we: write enable. If its one at the negative edge then it writes to address
        otherwise it reads from address
    data_in- input to the spad to be written to the addr if write enable is high
    data_out- the output of the spad that is result of a read
*/
module filter_spad(clk, addr, we, data_in, data_out);
    input             clk;
    input       [7:0] addr;
    input             we;          // write enable signal, 0: Read; 1: Write
    input      [15:0] data_in;
    output reg [15:0] data_out;
    reg        [15:0] mem [223:0]; // 224 * 16bit
    initial begin
        data_out = mem[addr];
    end
    always @ (negedge clk) begin
        if (we)
            mem[addr] <= data_in;
        else
            data_out <= mem[addr];
    end
endmodule
