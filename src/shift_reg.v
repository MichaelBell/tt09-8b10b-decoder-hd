`default_nettype none

// A shift register with delay gates for different cell libraries
module shift_reg #(
    parameter WIDTH=8
) (
    input wire clk,

    input wire data_in,

    output wire [WIDTH-1:0] data_out
);

    reg [WIDTH-1:0] register;

    wire [WIDTH-1:1] reg_buf;
    `ifdef SIM
    /* verilator lint_off ASSIGNDLY */
    buf #1 i_regbuf[WIDTH-1:1] (reg_buf, register[WIDTH-2:0]);
    /* verilator lint_on ASSIGNDLY */
    `elsif ICE40
    assign reg_buf = register[WIDTH-2:0];
    `elsif SCL_sky130_fd_sc_hd
    sky130_fd_sc_hd__clkbuf_2 i_regbuf[WIDTH-1:1] ( .X(reg_buf), .A(register[WIDTH-2:0]) );
    `elsif SCL_sky130_fd_sc_hs
    sky130_fd_sc_hs__clkbuf_2 i_regbuf[WIDTH-1:1] ( .X(reg_buf), .A(register[WIDTH-2:0]) );
    `else
    // On SG13G2 no buffer is required, use direct assignment
    assign reg_buf = register[WIDTH-2:0];
    `endif
    always @(posedge clk) register <= {reg_buf, data_in};

    assign data_out = register;

endmodule