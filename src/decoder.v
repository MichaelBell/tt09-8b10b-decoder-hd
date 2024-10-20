/*
 * Copyright (c) 2024 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

/* An 8b10 decoder.
 * See https://en.wikipedia.org/wiki/8b/10b_encoding for the encoding scheme
 * Initially looks for a K.28.7 symbol to find framing, when that is found valid goes high
 * and data_out is reset to 0.
 * After that valid data symbols cause data_out to be updated, and the updated signal
 * goes high for one clock each time a data symbol is decoded.
 * When valid, K.28.7 and K.29.7 symbols are ignored (data_out is not updated and 
 * updated is not pulsed).  Any other symbol causes valid to go low and K.28.7 must
 * be sent to reynchronize the stream. */
module decoder (
    input wire clk,
    input wire rst_n,

    input wire data_in,

    output reg valid,
    output reg [7:0] data_out,
    output reg updated
);

    // Symbols here use negative running disparity encoding
    localparam [5:0] D_0 = 6'b100111;
    localparam [5:0] D_1 = 6'b011101;
    localparam [5:0] D_2 = 6'b101101;
    localparam [5:0] D_3 = 6'b110001;
    localparam [5:0] D_4 = 6'b110101;
    localparam [5:0] D_5 = 6'b101001;
    localparam [5:0] D_6 = 6'b011001;
    localparam [5:0] D_7 = 6'b111000;
    localparam [5:0] D_7n = 6'b000111;

    localparam [5:0] D_8 = 6'b111001;
    localparam [5:0] D_9 = 6'b100101;
    localparam [5:0] D_10 = 6'b010101;
    localparam [5:0] D_11 = 6'b110100;
    localparam [5:0] D_12 = 6'b001101;
    localparam [5:0] D_13 = 6'b101100;
    localparam [5:0] D_14 = 6'b011100;
    localparam [5:0] D_15 = 6'b010111;

    localparam [5:0] D_16 = 6'b011011;
    localparam [5:0] D_17 = 6'b100011;
    localparam [5:0] D_18 = 6'b010011;
    localparam [5:0] D_19 = 6'b110010;
    localparam [5:0] D_20 = 6'b001011;
    localparam [5:0] D_21 = 6'b101010;
    localparam [5:0] D_22 = 6'b011010;
    localparam [5:0] D_23 = 6'b111010;

    localparam [5:0] D_24 = 6'b110011;
    localparam [5:0] D_25 = 6'b100110;
    localparam [5:0] D_26 = 6'b010110;
    localparam [5:0] D_27 = 6'b110110;
    localparam [5:0] D_28 = 6'b001110;
    localparam [5:0] D_29 = 6'b101110;
    localparam [5:0] D_30 = 6'b011110;
    localparam [5:0] D_31 = 6'b101011;

    localparam [3:0] D_x_0 = 4'b1011;
    localparam [3:0] D_x_1 = 4'b1001;
    localparam [3:0] D_x_2 = 4'b0101;
    localparam [3:0] D_x_3 = 4'b1100;
    localparam [3:0] D_x_3n = 4'b0011;
    localparam [3:0] D_x_4 = 4'b1101;
    localparam [3:0] D_x_5 = 4'b1010;
    localparam [3:0] D_x_6 = 4'b0110;
    localparam [3:0] D_x_P7 = 4'b1110;
    localparam [3:0] D_x_A7 = 4'b0111;

    localparam [9:0] K_28_5 = 10'b0011111010;

    wire [9:0] raw_data;
    wire [9:0] inv_raw_data;
    shift_reg #(.WIDTH(10)) i_raw_data(
        .clk(clk),
        .data_in(data_in),
        .data_out(raw_data) 
    );
    assign inv_raw_data = ~raw_data;

    reg [3:0] count;
    wire [3:0] next_count;
    assign next_count = count + 4'h1;

    wire [2:0] ones_6b = $countones(raw_data[9:4]);
    wire [2:0] ones_4b = $countones(raw_data[3:0]);

    reg [4:0] decoded_6b;
    reg decoded_6b_valid;
    reg [2:0] decoded_4b;
    reg decoded_4b_valid;
    wire decoded_valid;
    wire is_sync = (raw_data == K_28_5 || inv_raw_data == K_28_5);
    
    always @(*) begin
        decoded_6b_valid = 1;
        decoded_6b = 5'dx;
        case (ones_6b == 3'd2 ? inv_raw_data[9:4] : raw_data[9:4])
            D_0: decoded_6b = 5'd0;
            D_1: decoded_6b = 5'd1;
            D_2: decoded_6b = 5'd2;
            D_3: decoded_6b = 5'd3;
            D_4: decoded_6b = 5'd4;
            D_5: decoded_6b = 5'd5;
            D_6: decoded_6b = 5'd6;
            D_7: decoded_6b = 5'd7;
            D_7n: decoded_6b = 5'd7;

            D_8: decoded_6b = 5'd8;
            D_9: decoded_6b = 5'd9;
            D_10: decoded_6b = 5'd10;
            D_11: decoded_6b = 5'd11;
            D_12: decoded_6b = 5'd12;
            D_13: decoded_6b = 5'd13;
            D_14: decoded_6b = 5'd14;
            D_15: decoded_6b = 5'd15;

            D_16: decoded_6b = 5'd16;
            D_17: decoded_6b = 5'd17;
            D_18: decoded_6b = 5'd18;
            D_19: decoded_6b = 5'd19;
            D_20: decoded_6b = 5'd20;
            D_21: decoded_6b = 5'd21;
            D_22: decoded_6b = 5'd22;
            D_23: decoded_6b = 5'd23;

            D_24: decoded_6b = 5'd24;
            D_25: decoded_6b = 5'd25;
            D_26: decoded_6b = 5'd26;
            D_27: decoded_6b = 5'd27;
            D_28: decoded_6b = 5'd28;
            D_29: decoded_6b = 5'd29;
            D_30: decoded_6b = 5'd30;
            D_31: decoded_6b = 5'd31;

            default: decoded_6b_valid = 0;
        endcase
    end

    always @(*) begin
        decoded_4b_valid = 1;
        decoded_4b = 3'dx;
        case (ones_4b == 3'd1 ? inv_raw_data[3:0] : raw_data[3:0])
            D_x_0: decoded_4b = 3'd0;
            D_x_1: decoded_4b = 3'd1;
            D_x_2: decoded_4b = 3'd2;
            D_x_3: decoded_4b = 3'd3;
            D_x_3n: decoded_4b = 3'd3;
            D_x_4: decoded_4b = 3'd4;
            D_x_5: decoded_4b = 3'd5;
            D_x_6: decoded_4b = 3'd6;
            D_x_P7: decoded_4b = 3'd7;
            D_x_A7: decoded_4b = 3'd7;

            default: decoded_4b_valid = 0;
        endcase
    end

    assign decoded_valid = decoded_6b_valid && decoded_4b_valid;

    always @(posedge clk) begin
        if (!rst_n) begin
            valid <= 0;
            count <= 5; 
            updated <= 0;
        end else if (!valid) begin
            valid <= 0;
            updated <= 0;
            if (count != 4'hf) begin
                count <= next_count;
            end else if (is_sync) begin
                // Got a K.28.5 symbol - go valid
                valid <= 1;
                count <= 0;
            end
        end else begin
            valid <= 1;
            updated <= 0;
            count <= next_count;

            if (count == 4'd9) begin
                if (decoded_valid) begin
                    data_out <= {decoded_4b, decoded_6b};
                    count <= 0;
                    updated <= 1;
                end else if (is_sync) begin
                    count <= 0;
                end else begin
                    valid <= 0;
                    count <= 5;
                end
            end
        end
    end

endmodule