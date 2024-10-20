/*
 * Copyright (c) 2024 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_MichaelBell_hs_mul (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Bidi output enable based on ui_in[7]
  assign uio_oe  = {{8{!rst_n || ui_in[7]}}};

  // Decoders for inputs
  /* verilator lint_off SYNCASYNCNET */
  wire [7:0] val_a;
  wire valid_a;
  wire updated_a;
  decoder i_decoder_a (
    .clk(clk),
    .rst_n(rst_n),

    .data_in(ui_in[0]),

    .valid(valid_a),
    .data_out(val_a),
    .updated(updated_a)
  );
  
  wire [7:0] val_b;
  wire valid_b;
  wire updated_b;
  decoder i_decoder_b (
    .clk(clk),
    .rst_n(rst_n),

    .data_in(ui_in[1]),

    .valid(valid_b),
    .data_out(val_b),
    .updated(updated_b)
  );

  // Multiplier
  wire [15:0] mul_result;
  assign mul_result = val_a * val_b;

  reg [15:0] result;
  always @(posedge clk) begin
    if (!rst_n) result <= 0;
    else if (ui_in[3] || (ui_in[4] && updated_a && updated_b)) result <= mul_result;
    else if (ui_in[5]) result <= {val_b, val_a};
  end

  // Outputs
  assign uo_out = !rst_n ? {~ui_in[3], ui_in[3], ~ui_in[2], ui_in[2], ~ui_in[1], ui_in[1], ~ui_in[0], ui_in[0]} :
                  ui_in[2] ? {4'b0000, updated_b, valid_b, updated_a, valid_a} :
                  ui_in[6] ? val_a :
                  result[7:0];
  assign uio_out = !rst_n ? {~ui_in[7], ui_in[7], ~ui_in[6], ui_in[6], ~ui_in[5], ui_in[5], ~ui_in[4], ui_in[4]} :
                  ui_in[2] ? 8'h00 :
                  ui_in[6] ? val_b :
                  result[15:8];

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

endmodule
