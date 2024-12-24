`timescale 1ns/10ps
//PC1
module PC_1 (
  input [63:0] address,
  output[55:0]y
);

assign y[55] = address[7];
assign y[54] = address[15];
assign y[53] = address[23];
assign y[52] = address[31];
assign y[51] = address[39];
assign y[50] = address[47];
assign y[49] = address[55];
assign y[48] = address[63];
assign y[47] = address[6];
assign y[46] = address[14];
assign y[45] = address[22];
assign y[44] = address[30];
assign y[43] = address[38];
assign y[42] = address[46];
assign y[41] = address[54];
assign y[40] = address[62];
assign y[39] = address[5];
assign y[38] = address[13];
assign y[37] = address[21];
assign y[36] = address[29];
assign y[35] = address[37];
assign y[34] = address[45];
assign y[33] = address[53];
assign y[32] = address[61];
assign y[31] = address[4];
assign y[30] = address[12];
assign y[29] = address[20];
assign y[28] = address[28];
assign y[27] = address[1];
assign y[26] = address[9];
assign y[25] = address[17];
assign y[24] = address[25];
assign y[23] = address[33];
assign y[22] = address[41];
assign y[21] = address[49];
assign y[20] = address[57];
assign y[19] = address[2];
assign y[18] = address[10];
assign y[17] = address[18];
assign y[16] = address[26];
assign y[15] = address[34];
assign y[14] = address[42];
assign y[13] = address[50];
assign y[12] = address[58];
assign y[11] = address[3];
assign y[10] = address[11];
assign y[9] = address[19];
assign y[8] = address[27];
assign y[7] = address[35];
assign y[6] = address[43];
assign y[5] = address[51];
assign y[4] = address[59];
assign y[3] = address[36];
assign y[2] = address[44];
assign y[1] = address[52];
assign y[0] = address[60];
endmodule


//PC2
module PC_2 (
  input [55:0]address,
  output[47:0]y
);
assign y[47] = address[42];
assign y[46] = address[39];
assign y[45] = address[45];
assign y[44] = address[32];
assign y[43] = address[55];
assign y[42] = address[51];
assign y[41] = address[53];
assign y[40] = address[28];
assign y[39] = address[41];
assign y[38] = address[50];
assign y[37] = address[35];
assign y[36] = address[46];
assign y[35] = address[33];
assign y[34] = address[37];
assign y[33] = address[44];
assign y[32] = address[52];
assign y[31] = address[30];
assign y[30] = address[48];
assign y[29] = address[40];
assign y[28] = address[49];
assign y[27] = address[29];
assign y[26] = address[36];
assign y[25] = address[43];
assign y[24] = address[54];
assign y[23] = address[15];
assign y[22] = address[4];
assign y[21] = address[25];
assign y[20] = address[19];
assign y[19] = address[9];
assign y[18] = address[1];
assign y[17] = address[26];
assign y[16] = address[16];
assign y[15] = address[5];
assign y[14] = address[11];
assign y[13] = address[23];
assign y[12] = address[8];
assign y[11] = address[12];
assign y[10] = address[7];
assign y[9]  = address[17];
assign y[8]  = address[0];
assign y[7]  = address[22];
assign y[6]  = address[3];
assign y[5]  = address[10];
assign y[4]  = address[14];
assign y[3]  = address[6];
assign y[2]  = address[20];
assign y[1]  = address[27];
assign y[0]  = address[24];

endmodule

//Initial Permutation
module INITIAL_PERMUTATION (
  input [63:0] address,
  output[63:0]y
);
assign y[63] = address[6];
assign y[62] = address[14];
assign y[61] = address[22];
assign y[60] = address[30];
assign y[59] = address[38];
assign y[58] = address[46];
assign y[57] = address[54];
assign y[56] = address[62];
assign y[55] = address[4];
assign y[54] = address[12];
assign y[53] = address[20];
assign y[52] = address[28];
assign y[51] = address[36];
assign y[50] = address[44];
assign y[49] = address[52];
assign y[48] = address[60];
assign y[47] = address[2];
assign y[46] = address[10];
assign y[45] = address[18];
assign y[44] = address[26];
assign y[43] = address[34];
assign y[42] = address[42];
assign y[41] = address[50];
assign y[40] = address[58];
assign y[39] = address[0];
assign y[38] = address[8];
assign y[37] = address[16];
assign y[36] = address[24];
assign y[35] = address[32];
assign y[34] = address[40];
assign y[33] = address[48];
assign y[32] = address[56];
assign y[31] = address[7];
assign y[30] = address[15];
assign y[29] = address[23];
assign y[28] = address[31];
assign y[27] = address[39];
assign y[26] = address[47];
assign y[25] = address[55];
assign y[24] = address[63];
assign y[23] = address[5];
assign y[22] = address[13];
assign y[21] = address[21];
assign y[20] = address[29];
assign y[19] = address[37];
assign y[18] = address[45];
assign y[17] = address[53];
assign y[16] = address[61];
assign y[15] = address[3];
assign y[14] = address[11];
assign y[13] = address[19];
assign y[12] = address[27];
assign y[11] = address[35];
assign y[10] = address[43];
assign y[9]  = address[51];
assign y[8]  = address[59];
assign y[7]  = address[1];
assign y[6]  = address[9];
assign y[5]  = address[17];
assign y[4]  = address[25];
assign y[3]  = address[33];
assign y[2]  = address[41];
assign y[1]  = address[49];
assign y[0]  = address[57];


endmodule
//Final permutation
module FINAL_PERMUTATION (
  input [63:0] address,
  output[63:0]y
);
assign y[63]  = address[24];
assign y[62] = address[56];
assign y[61] = address[16];
assign y[60] = address[48];
assign y[59] = address[8];
assign y[58] = address[40];
assign y[57] = address[0];
assign y[56] = address[32];
assign y[55] = address[25];
assign y[54] = address[57];
assign y[53] = address[17];
assign y[52] = address[49];
assign y[51] = address[9];
assign y[50] = address[41];
assign y[49] = address[1];
assign y[48] = address[33];
assign y[47] = address[26];
assign y[46] = address[58];
assign y[45] = address[18];
assign y[44] = address[50];
assign y[43] = address[10];
assign y[42] = address[42];
assign y[41] = address[2];
assign y[40] = address[34];
assign y[39] = address[27];
assign y[38] = address[59];
assign y[37] = address[19];
assign y[36] = address[51];
assign y[35] = address[11];
assign y[34] = address[43];
assign y[33] = address[3];
assign y[32] = address[35];
assign y[31] = address[28];
assign y[30] = address[60];
assign y[29] = address[20];
assign y[28] = address[52];
assign y[27] = address[12];
assign y[26] = address[44];
assign y[25] = address[4];
assign y[24] = address[36];
assign y[23] = address[29];
assign y[22] = address[61];
assign y[21] = address[21];
assign y[20] = address[53];
assign y[19] = address[13];
assign y[18] = address[45];
assign y[17] = address[5];
assign y[16] = address[37];
assign y[15] = address[30];
assign y[14] = address[62];
assign y[13] = address[22];
assign y[12] = address[54];
assign y[11] = address[14];
assign y[10] = address[46];
assign y[9]  = address[6];
assign y[8]  = address[38];
assign y[7]  = address[31];
assign y[6]  = address[63];
assign y[5]  = address[23];
assign y[4]  = address[55];
assign y[3]  = address[15];
assign y[2]  = address[47];
assign y[1]  = address[7];
assign y[0]  = address[39];

endmodule


module EXPANSION (
  input [31:0] address,
  output[47:0]y
);
assign y[47] = address[0];
assign y[46] = address[31];
assign y[45] = address[30];
assign y[44] = address[29];
assign y[43] = address[28];
assign y[42] = address[27];
assign y[41] = address[28];
assign y[40] = address[27];
assign y[39] = address[26];
assign y[38] = address[25];
assign y[37] = address[24];
assign y[36] = address[23];
assign y[35] = address[24];
assign y[34] = address[23];
assign y[33] = address[22];
assign y[32] = address[21];
assign y[31] = address[20];
assign y[30] = address[19];
assign y[29] = address[20];
assign y[28] = address[19];
assign y[27] = address[18];
assign y[26] = address[17];
assign y[25] = address[16];
assign y[24] = address[15];
assign y[23] = address[16];
assign y[22] = address[15];
assign y[21] = address[14];
assign y[20] = address[13];
assign y[19] = address[12];
assign y[18] = address[11];
assign y[17] = address[12];
assign y[16] = address[11];
assign y[15] = address[10];
assign y[14] = address[9];
assign y[13] = address[8];
assign y[12] = address[7];
assign y[11] = address[8];
assign y[10] = address[7];
assign y[9]  = address[6];
assign y[8]  = address[5];
assign y[7]  = address[4];
assign y[6]  = address[3];
assign y[5]  = address[4];
assign y[4]  = address[3];
assign y[3]  = address[2];
assign y[2]  = address[1];
assign y[1]  = address[0];
assign y[0]  = address[31];


endmodule

//P for F function
module P (
  input [31:0] address,
  output[31:0]y
);
assign y[31] = address[16];
assign y[30] = address[25];
assign y[29] = address[12];
assign y[28] = address[11];
assign y[27] = address[3];
assign y[26] = address[20];
assign y[25] = address[4];
assign y[24] = address[15];
assign y[23] = address[31];
assign y[22] = address[17];
assign y[21] = address[9];
assign y[20] = address[6];
assign y[19] = address[27];
assign y[18] = address[14];
assign y[17] = address[1];
assign y[16] = address[22];
assign y[15] = address[30];
assign y[14] = address[24];
assign y[13] = address[8];
assign y[12] = address[18];
assign y[11] = address[0];
assign y[10] = address[5];
assign y[9]  = address[29];
assign y[8]  = address[23];
assign y[7]  = address[13];
assign y[6]  = address[19];
assign y[5]  = address[2];
assign y[4]  = address[26];
assign y[3]  = address[10];
assign y[2]  = address[21];
assign y[1]  = address[28];
assign y[0]  = address[7];

endmodule


module S_1 (
  input [5:0] address,
  output reg[3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd14;
                4'd1: y = 4'd4;
                4'd2: y = 4'd13;
                4'd3: y = 4'd1;
                4'd4: y = 4'd2;
                4'd5: y = 4'd15;
                4'd6: y = 4'd11;
                4'd7: y = 4'd8;
                4'd8: y = 4'd3;
                4'd9: y = 4'd10;
                4'd10: y = 4'd6;
                4'd11: y = 4'd12;
                4'd12: y = 4'd5;
                4'd13: y = 4'd9;
                4'd14: y = 4'd0;
                4'd15: y = 4'd7;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd0;
                4'd1: y = 4'd15;
                4'd2: y = 4'd7;
                4'd3: y = 4'd4;
                4'd4: y = 4'd14;
                4'd5: y = 4'd2;
                4'd6: y = 4'd13;
                4'd7: y = 4'd1;
                4'd8: y = 4'd10;
                4'd9: y = 4'd6;
                4'd10: y = 4'd12;
                4'd11: y = 4'd11;
                4'd12: y = 4'd9;
                4'd13: y = 4'd5;
                4'd14: y = 4'd3;
                4'd15: y = 4'd8;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd4;
                4'd1: y = 4'd1;
                4'd2: y = 4'd14;
                4'd3: y = 4'd8;
                4'd4: y = 4'd13;
                4'd5: y = 4'd6;
                4'd6: y = 4'd2;
                4'd7: y = 4'd11;
                4'd8: y = 4'd15;
                4'd9: y = 4'd12;
                4'd10: y = 4'd9;
                4'd11: y = 4'd7;
                4'd12: y = 4'd3;
                4'd13: y = 4'd10;
                4'd14: y = 4'd5;
                4'd15: y = 4'd0;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd15;
                4'd1: y = 4'd12;
                4'd2: y = 4'd8;
                4'd3: y = 4'd2;
                4'd4: y = 4'd4;
                4'd5: y = 4'd9;
                4'd6: y = 4'd1;
                4'd7: y = 4'd7;
                4'd8: y = 4'd5;
                4'd9: y = 4'd11;
                4'd10: y = 4'd3;
                4'd11: y = 4'd14;
                4'd12: y = 4'd10;
                4'd13: y = 4'd0;
                4'd14: y = 4'd6;
                4'd15: y = 4'd13;
            endcase
        end
    endcase
end
endmodule





module S_2 (
  input [5:0] address,
  output reg [3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd15;
                4'd1: y = 4'd1;
                4'd2: y = 4'd8;
                4'd3: y = 4'd14;
                4'd4: y = 4'd6;
                4'd5: y = 4'd11;
                4'd6: y = 4'd3;
                4'd7: y = 4'd4;
                4'd8: y = 4'd9;
                4'd9: y = 4'd7;
                4'd10: y = 4'd2;
                4'd11: y = 4'd13;
                4'd12: y = 4'd12;
                4'd13: y = 4'd0;
                4'd14: y = 4'd5;
                4'd15: y = 4'd10;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd3;
                4'd1: y = 4'd13;
                4'd2: y = 4'd4;
                4'd3: y = 4'd7;
                4'd4: y = 4'd15;
                4'd5: y = 4'd2;
                4'd6: y = 4'd8;
                4'd7: y = 4'd14;
                4'd8: y = 4'd12;
                4'd9: y = 4'd0;
                4'd10: y = 4'd1;
                4'd11: y = 4'd10;
                4'd12: y = 4'd6;
                4'd13: y = 4'd9;
                4'd14: y = 4'd11;
                4'd15: y = 4'd5;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd0;
                4'd1: y = 4'd14;
                4'd2: y = 4'd7;
                4'd3: y = 4'd11;
                4'd4: y = 4'd10;
                4'd5: y = 4'd4;
                4'd6: y = 4'd13;
                4'd7: y = 4'd1;
                4'd8: y = 4'd5;
                4'd9: y = 4'd8;
                4'd10: y = 4'd12;
                4'd11: y = 4'd6;
                4'd12: y = 4'd9;
                4'd13: y = 4'd3;
                4'd14: y = 4'd2;
                4'd15: y = 4'd15;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd13;
                4'd1: y = 4'd8;
                4'd2: y = 4'd10;
                4'd3: y = 4'd1;
                4'd4: y = 4'd3;
                4'd5: y = 4'd15;
                4'd6: y = 4'd4;
                4'd7: y = 4'd2;
                4'd8: y = 4'd11;
                4'd9: y = 4'd6;
                4'd10: y = 4'd7;
                4'd11: y = 4'd12;
                4'd12: y = 4'd0;
                4'd13: y = 4'd5;
                4'd14: y = 4'd14;
                4'd15: y = 4'd9;
            endcase
        end
    endcase
end

endmodule


module S_3 (
  input [5:0] address,
  output reg [3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd10;
                4'd1: y = 4'd0;
                4'd2: y = 4'd9;
                4'd3: y = 4'd14;
                4'd4: y = 4'd6;
                4'd5: y = 4'd3;
                4'd6: y = 4'd15;
                4'd7: y = 4'd5;
                4'd8: y = 4'd1;
                4'd9: y = 4'd13;
                4'd10: y = 4'd12;
                4'd11: y = 4'd7;
                4'd12: y = 4'd11;
                4'd13: y = 4'd4;
                4'd14: y = 4'd2;
                4'd15: y = 4'd8;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd13;
                4'd1: y = 4'd7;
                4'd2: y = 4'd0;
                4'd3: y = 4'd9;
                4'd4: y = 4'd3;
                4'd5: y = 4'd4;
                4'd6: y = 4'd6;
                4'd7: y = 4'd10;
                4'd8: y = 4'd2;
                4'd9: y = 4'd8;
                4'd10: y = 4'd5;
                4'd11: y = 4'd14;
                4'd12: y = 4'd12;
                4'd13: y = 4'd11;
                4'd14: y = 4'd15;
                4'd15: y = 4'd1;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd13;
                4'd1: y = 4'd6;
                4'd2: y = 4'd4;
                4'd3: y = 4'd9;
                4'd4: y = 4'd8;
                4'd5: y = 4'd15;
                4'd6: y = 4'd3;
                4'd7: y = 4'd0;
                4'd8: y = 4'd11;
                4'd9: y = 4'd1;
                4'd10: y = 4'd2;
                4'd11: y = 4'd12;
                4'd12: y = 4'd5;
                4'd13: y = 4'd10;
                4'd14: y = 4'd14;
                4'd15: y = 4'd7;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd1;
                4'd1: y = 4'd10;
                4'd2: y = 4'd13;
                4'd3: y = 4'd0;
                4'd4: y = 4'd6;
                4'd5: y = 4'd9;
                4'd6: y = 4'd8;
                4'd7: y = 4'd7;
                4'd8: y = 4'd4;
                4'd9: y = 4'd15;
                4'd10: y = 4'd14;
                4'd11: y = 4'd3;
                4'd12: y = 4'd11;
                4'd13: y = 4'd5;
                4'd14: y = 4'd2;
                4'd15: y = 4'd12;
            endcase
        end
    endcase
end

endmodule


module S_4 (
  input [5:0] address,
  output reg [3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd7;
                4'd1: y = 4'd13;
                4'd2: y = 4'd14;
                4'd3: y = 4'd3;
                4'd4: y = 4'd0;
                4'd5: y = 4'd6;
                4'd6: y = 4'd9;
                4'd7: y = 4'd10;
                4'd8: y = 4'd1;
                4'd9: y = 4'd2;
                4'd10: y = 4'd8;
                4'd11: y = 4'd5;
                4'd12: y = 4'd11;
                4'd13: y = 4'd12;
                4'd14: y = 4'd4;
                4'd15: y = 4'd15;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd13;
                4'd1: y = 4'd8;
                4'd2: y = 4'd11;
                4'd3: y = 4'd5;
                4'd4: y = 4'd6;
                4'd5: y = 4'd15;
                4'd6: y = 4'd0;
                4'd7: y = 4'd3;
                4'd8: y = 4'd4;
                4'd9: y = 4'd7;
                4'd10: y = 4'd2;
                4'd11: y = 4'd12;
                4'd12: y = 4'd1;
                4'd13: y = 4'd10;
                4'd14: y = 4'd14;
                4'd15: y = 4'd9;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd10;
                4'd1: y = 4'd6;
                4'd2: y = 4'd9;
                4'd3: y = 4'd0;
                4'd4: y = 4'd12;
                4'd5: y = 4'd11;
                4'd6: y = 4'd7;
                4'd7: y = 4'd13;
                4'd8: y = 4'd15;
                4'd9: y = 4'd1;
                4'd10: y = 4'd3;
                4'd11: y = 4'd14;
                4'd12: y = 4'd5;
                4'd13: y = 4'd2;
                4'd14: y = 4'd8;
                4'd15: y = 4'd4;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd3;
                4'd1: y = 4'd15;
                4'd2: y = 4'd0;
                4'd3: y = 4'd6;
                4'd4: y = 4'd10;
                4'd5: y = 4'd1;
                4'd6: y = 4'd13;
                4'd7: y = 4'd8;
                4'd8: y = 4'd9;
                4'd9: y = 4'd4;
                4'd10: y = 4'd5;
                4'd11: y = 4'd11;
                4'd12: y = 4'd12;
                4'd13: y = 4'd7;
                4'd14: y = 4'd2;
                4'd15: y = 4'd14;
            endcase
        end
    endcase
end

endmodule


module S_5 (
  input [5:0] address,
  output reg [3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd2;
                4'd1: y = 4'd12;
                4'd2: y = 4'd4;
                4'd3: y = 4'd1;
                4'd4: y = 4'd7;
                4'd5: y = 4'd10;
                4'd6: y = 4'd11;
                4'd7: y = 4'd6;
                4'd8: y = 4'd8;
                4'd9: y = 4'd5;
                4'd10: y = 4'd3;
                4'd11: y = 4'd15;
                4'd12: y = 4'd13;
                4'd13: y = 4'd0;
                4'd14: y = 4'd14;
                4'd15: y = 4'd9;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd14;
                4'd1: y = 4'd11;
                4'd2: y = 4'd2;
                4'd3: y = 4'd12;
                4'd4: y = 4'd4;
                4'd5: y = 4'd7;
                4'd6: y = 4'd13;
                4'd7: y = 4'd1;
                4'd8: y = 4'd5;
                4'd9: y = 4'd0;
                4'd10: y = 4'd15;
                4'd11: y = 4'd10;
                4'd12: y = 4'd3;
                4'd13: y = 4'd9;
                4'd14: y = 4'd8;
                4'd15: y = 4'd6;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd4;
                4'd1: y = 4'd2;
                4'd2: y = 4'd1;
                4'd3: y = 4'd11;
                4'd4: y = 4'd10;
                4'd5: y = 4'd13;
                4'd6: y = 4'd7;
                4'd7: y = 4'd8;
                4'd8: y = 4'd15;
                4'd9: y = 4'd9;
                4'd10: y = 4'd12;
                4'd11: y = 4'd5;
                4'd12: y = 4'd6;
                4'd13: y = 4'd3;
                4'd14: y = 4'd0;
                4'd15: y = 4'd14;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd11;
                4'd1: y = 4'd8;
                4'd2: y = 4'd12;
                4'd3: y = 4'd7;
                4'd4: y = 4'd1;
                4'd5: y = 4'd14;
                4'd6: y = 4'd2;
                4'd7: y = 4'd13;
                4'd8: y = 4'd6;
                4'd9: y = 4'd15;
                4'd10: y = 4'd0;
                4'd11: y = 4'd9;
                4'd12: y = 4'd10;
                4'd13: y = 4'd4;
                4'd14: y = 4'd5;
                4'd15: y = 4'd3;
            endcase
        end
    endcase
end

endmodule


module S_6 (
  input [5:0] address,
  output reg [3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd12;
                4'd1: y = 4'd1;
                4'd2: y = 4'd10;
                4'd3: y = 4'd15;
                4'd4: y = 4'd9;
                4'd5: y = 4'd2;
                4'd6: y = 4'd6;
                4'd7: y = 4'd8;
                4'd8: y = 4'd0;
                4'd9: y = 4'd13;
                4'd10: y = 4'd3;
                4'd11: y = 4'd4;
                4'd12: y = 4'd14;
                4'd13: y = 4'd7;
                4'd14: y = 4'd5;
                4'd15: y = 4'd11;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd10;
                4'd1: y = 4'd15;
                4'd2: y = 4'd4;
                4'd3: y = 4'd2;
                4'd4: y = 4'd7;
                4'd5: y = 4'd12;
                4'd6: y = 4'd9;
                4'd7: y = 4'd5;
                4'd8: y = 4'd6;
                4'd9: y = 4'd1;
                4'd10: y = 4'd13;
                4'd11: y = 4'd14;
                4'd12: y = 4'd0;
                4'd13: y = 4'd11;
                4'd14: y = 4'd3;
                4'd15: y = 4'd8;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd9;
                4'd1: y = 4'd14;
                4'd2: y = 4'd15;
                4'd3: y = 4'd5;
                4'd4: y = 4'd2;
                4'd5: y = 4'd8;
                4'd6: y = 4'd12;
                4'd7: y = 4'd3;
                4'd8: y = 4'd7;
                4'd9: y = 4'd0;
                4'd10: y = 4'd4;
                4'd11: y = 4'd10;
                4'd12: y = 4'd1;
                4'd13: y = 4'd13;
                4'd14: y = 4'd11;
                4'd15: y = 4'd6;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd4;
                4'd1: y = 4'd3;
                4'd2: y = 4'd2;
                4'd3: y = 4'd12;
                4'd4: y = 4'd9;
                4'd5: y = 4'd5;
                4'd6: y = 4'd15;
                4'd7: y = 4'd10;
                4'd8: y = 4'd11;
                4'd9: y = 4'd14;
                4'd10: y = 4'd1;
                4'd11: y = 4'd7;
                4'd12: y = 4'd6;
                4'd13: y = 4'd0;
                4'd14: y = 4'd8;
                4'd15: y = 4'd13;
            endcase
        end
    endcase
end

endmodule


module S_7 (
  input [5:0] address,
  output reg [3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd4;
                4'd1: y = 4'd11;
                4'd2: y = 4'd2;
                4'd3: y = 4'd14;
                4'd4: y = 4'd15;
                4'd5: y = 4'd0;
                4'd6: y = 4'd8;
                4'd7: y = 4'd13;
                4'd8: y = 4'd3;
                4'd9: y = 4'd12;
                4'd10: y = 4'd9;
                4'd11: y = 4'd7;
                4'd12: y = 4'd5;
                4'd13: y = 4'd10;
                4'd14: y = 4'd6;
                4'd15: y = 4'd1;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd13;
                4'd1: y = 4'd0;
                4'd2: y = 4'd11;
                4'd3: y = 4'd7;
                4'd4: y = 4'd4;
                4'd5: y = 4'd9;
                4'd6: y = 4'd1;
                4'd7: y = 4'd10;
                4'd8: y = 4'd14;
                4'd9: y = 4'd3;
                4'd10: y = 4'd5;
                4'd11: y = 4'd12;
                4'd12: y = 4'd2;
                4'd13: y = 4'd15;
                4'd14: y = 4'd8;
                4'd15: y = 4'd6;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd1;
                4'd1: y = 4'd4;
                4'd2: y = 4'd11;
                4'd3: y = 4'd13;
                4'd4: y = 4'd12;
                4'd5: y = 4'd3;
                4'd6: y = 4'd7;
                4'd7: y = 4'd14;
                4'd8: y = 4'd10;
                4'd9: y = 4'd15;
                4'd10: y = 4'd6;
                4'd11: y = 4'd8;
                4'd12: y = 4'd0;
                4'd13: y = 4'd5;
                4'd14: y = 4'd9;
                4'd15: y = 4'd2;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd6;
                4'd1: y = 4'd11;
                4'd2: y = 4'd13;
                4'd3: y = 4'd8;
                4'd4: y = 4'd1;
                4'd5: y = 4'd4;
                4'd6: y = 4'd10;
                4'd7: y = 4'd7;
                4'd8: y = 4'd9;
                4'd9: y = 4'd5;
                4'd10: y = 4'd0;
                4'd11: y = 4'd15;
                4'd12: y = 4'd14;
                4'd13: y = 4'd2;
                4'd14: y = 4'd3;
                4'd15: y = 4'd12;
            endcase
        end
    endcase
end

endmodule


module S_8 (
  input [5:0] address,
  output reg [3:0] y
);

always @(*) begin
    case({address[5], address[0]})
        2'b00: begin
            case(address[4:1])
                4'd0: y = 4'd13;
                4'd1: y = 4'd2;
                4'd2: y = 4'd8;
                4'd3: y = 4'd4;
                4'd4: y = 4'd6;
                4'd5: y = 4'd15;
                4'd6: y = 4'd11;
                4'd7: y = 4'd1;
                4'd8: y = 4'd10;
                4'd9: y = 4'd9;
                4'd10: y = 4'd3;
                4'd11: y = 4'd14;
                4'd12: y = 4'd5;
                4'd13: y = 4'd0;
                4'd14: y = 4'd12;
                4'd15: y = 4'd7;
            endcase
        end
        2'b01: begin
            case(address[4:1])
                4'd0: y = 4'd1;
                4'd1: y = 4'd15;
                4'd2: y = 4'd13;
                4'd3: y = 4'd8;
                4'd4: y = 4'd10;
                4'd5: y = 4'd3;
                4'd6: y = 4'd7;
                4'd7: y = 4'd4;
                4'd8: y = 4'd12;
                4'd9: y = 4'd5;
                4'd10: y = 4'd6;
                4'd11: y = 4'd11;
                4'd12: y = 4'd0;
                4'd13: y = 4'd14;
                4'd14: y = 4'd9;
                4'd15: y = 4'd2;
            endcase
        end
        2'b10: begin
            case(address[4:1])
                4'd0: y = 4'd7;
                4'd1: y = 4'd11;
                4'd2: y = 4'd4;
                4'd3: y = 4'd1;
                4'd4: y = 4'd9;
                4'd5: y = 4'd12;
                4'd6: y = 4'd14;
                4'd7: y = 4'd2;
                4'd8: y = 4'd0;
                4'd9: y = 4'd6;
                4'd10: y = 4'd10;
                4'd11: y = 4'd13;
                4'd12: y = 4'd15;
                4'd13: y = 4'd3;
                4'd14: y = 4'd5;
                4'd15: y = 4'd8;
            endcase
        end
        2'b11: begin
            case(address[4:1])
                4'd0: y = 4'd2;
                4'd1: y = 4'd1;
                4'd2: y = 4'd14;
                4'd3: y = 4'd7;
                4'd4: y = 4'd4;
                4'd5: y = 4'd10;
                4'd6: y = 4'd8;
                4'd7: y = 4'd13;
                4'd8: y = 4'd15;
                4'd9: y = 4'd12;
                4'd10: y = 4'd9;
                4'd11: y = 4'd0;
                4'd12: y = 4'd3;
                4'd13: y = 4'd5;
                4'd14: y = 4'd6;
                4'd15: y = 4'd11;
            endcase
        end
    endcase
end

endmodule

module IOTDF( clk, rst, in_en, iot_in, fn_sel, busy, valid, iot_out);
input          clk;
input          rst;
input          in_en;
input  [7:0]   iot_in;
input  [2:0]   fn_sel;
output         busy;
output         valid;
output [127:0] iot_out;



parameter ENCRYPT = 3'd1;
parameter DECRYPT = 3'd2;
parameter CRCGEN  = 3'd3;
parameter Top2Max= 3'd4;
parameter Last2Min= 3'd5;

parameter IDLE		= 2'd0;
parameter READ		= 2'd1;
parameter OPERATION	= 2'd2;
parameter OUTPUT		= 2'd3;

reg busy_r,busy_w;
reg valid_r;
//reg [2:0] fn;
//reg [7:0] iot_data_8;
//reg in_en_r;
reg [127:0]iot_out_r,iot_out_w;
reg [127:0]data_r;
wire [55:0]cipher_key;
reg [27:0]cipher_key_up_r,cipher_key_up_w,cipher_key_up;
reg [27:0]cipher_key_down_r,cipher_key_down_w,cipher_key_down;
reg [127:0] max2;
reg flag;
reg [3:0] counter_8;

reg [4:0] counter_32;
reg [1:0] state, n_state;

wire [47:0]key;
reg [31:0]R_r,L_r;
reg [31:0]R_w,L_w;
reg [10:0] shift_w_extension;
integer i;
reg valid_w;
reg [3:0]shift_r;
reg [2:0]result,result_r;
reg [7:0]shift_w;



assign busy =busy_r;
assign valid=valid_r;
assign iot_out=iot_out_r;


PC_1 PC_1 (
  .address(data_r[127:64]),
  .y(cipher_key) 
);

assign p12=(fn_sel==DECRYPT||fn_sel==ENCRYPT);
assign p45=(fn_sel==Top2Max)||(fn_sel==Last2Min);
always@(posedge clk or posedge rst) begin
	if(rst) begin
		//fn	        <= 0;
		data_r	<= 0;
	end

	else if(state==OUTPUT && (p12||fn_sel==CRCGEN))begin
		//fn	<= fn_sel;
		data_r<= max2;
            // 0~  7 <-> 1st IOT data	//
            // 8~ 15 <-> 2nd IOT data	//
            // ...					//
            //120~127 <-> 16th IOT data	//
	end	
	else if(in_en &&state==READ)begin
		//fn	<= fn_sel;
		data_r[((counter_32)*8)+:8]<= iot_in;
            // 0~  7 <-> 1st IOT data	//
            // 8~ 15 <-> 2nd IOT data	//
            // ...					//
            //120~127 <-> 16th IOT data	//
	end	
end

always@(posedge clk or posedge rst) begin
	if(rst) begin
        shift_w<= 0;
	end
    else if(state==OPERATION && fn_sel==CRCGEN)begin
        shift_w <= data_r[((16-counter_32)*8)-1 -: 8];

    end

end

//Finite State Machine


always@(*) begin
	n_state = state;
	case(state)
		IDLE:n_state = READ;
        READ:begin //read data and generate key k1~k16
             if(counter_32==16 &&(p12||p45))begin
                    n_state = OPERATION; 
             end
             else if(counter_32!=16 &&p12)begin
                    n_state = READ; 
             end
             else if(counter_32==16 && fn_sel==CRCGEN)begin
                    n_state = OPERATION; 
             end
            //  else if(counter_32==16 && fn_sel==BINTOGRAY)begin
            //         n_state = OUTPUT; 
            //  end
            // else if(counter_32==16 && fn_sel==GRAYTOBIN)begin
            //         n_state = OUTPUT; 
            //  end
            else begin
                    n_state = READ; 
             end
        end
		OPERATION:begin	// encrypt or decrypt .....
            if(counter_32==16 &&(p12||(fn_sel==CRCGEN)))begin
                n_state = OUTPUT;   
             end
            else if(counter_32!=16 &&(p12||(fn_sel==CRCGEN)))
                n_state=OPERATION;

            else if(counter_8==8 &&p45)
                n_state=OPERATION;
            // else if(counter_8==7 &&((fn_sel==Top2Max)))
            //     n_state=OUTPUT;
            else begin
                n_state=READ;
            end
        end
		OUTPUT:begin 
            // if (fn_sel== Top2Max&& counter_8!=0)
            // begin
            //     n_state = OUTPUT;
                
            // end
            // else
            // if(fn_sel==CRCGEN)
            //     n_state=READ;    
            // else    
                n_state = OPERATION;
        end
    endcase
end
always@(posedge clk or posedge rst) begin
	if(rst)	state <= IDLE;
	else	state <= n_state;	
end
// Control Signal
always@(*) begin
    busy_w=1;
    valid_w=0;
	case(state)
        READ:begin
            if(p12||fn_sel==CRCGEN)begin
                if(counter_32>=15)
                    busy_w=0; 
                else if(counter_32>=14)
                    busy_w=1;
                // else if((counter_32==14||counter_32==15)&&(fn_sel==BINTOGRAY||fn_sel==GRAYTOBIN))
                //     busy_w=1;

                else 
                    busy_w=0;
            end


            else begin
                if(counter_32>=14)
                    busy_w=1;
                // else if((counter_32==14||counter_32==15)&&(fn_sel==BINTOGRAY||fn_sel==GRAYTOBIN))
                //     busy_w=1;
                else 
                    busy_w=0;
            end
        end
		OPERATION:begin 





            busy_w=1;
            valid_w=0;
            if(fn_sel==CRCGEN &&counter_32==16)
                valid_w=1;
            else 
                valid_w=0;


            if(p45)
            busy_w=0;

            else if(p12||(fn_sel==CRCGEN))begin
                busy_w=0;

                if(counter_32==16)
                    busy_w=0; 
                else if(counter_32>=14)
                    busy_w=1;
            
            
            end


        end
		OUTPUT:begin	
            if(fn_sel==CRCGEN)begin
                valid_w=0;
                busy_w=0;
            end
            if(p12)begin
                busy_w=0;
            valid_w=1;

            end

            else begin
            busy_w=0;
            valid_w=0;
            end
        end
        default:begin
            busy_w=1;
            valid_w=0;
        end
	endcase
end

wire [2:0] generator = 3'b110;

PC_2 PC_2 (
  .address({cipher_key_down_r,cipher_key_up_r}),
  .y(key) 
);
wire [63:0]plaintext,ciphertext;

INITIAL_PERMUTATION INITIAL_PERMUTATION(
  .address(data_r[63:0]),
  .y(plaintext) 
);
FINAL_PERMUTATION FINAL_PERMUTATION(
  .address({L_r,R_r}),
  .y(ciphertext) 
);
wire [47:0]R_expansion;
EXPANSION EXPANSION (
  .address(R_r),
  .y(R_expansion) 
);

reg  [47:0]RK_xor;
wire [3:0]P1_before,P2_before,P3_before,P4_before,P5_before,P6_before,P7_before,P8_before;
S_1 S_1 (
  .address(RK_xor[47:42]),
  .y(P1_before) 
);
S_2 S_2 (
  .address(RK_xor[41:36]),
  .y(P2_before) 
);
S_3 S_3 (
  .address(RK_xor[35:30]),
  .y(P3_before) 
);

S_4 S_4 (
  .address(RK_xor[29:24]),
  .y(P4_before) 
);

S_5 S_5 (
  .address(RK_xor[23:18]),
  .y(P5_before) 
);
S_6 S_6 (
  .address(RK_xor[17:12]),
  .y(P6_before) 
);
S_7 S_7 (
  .address(RK_xor[11:6]),
  .y(P7_before) 
);

S_8 S_8 (
  .address(RK_xor[5:0]),
  .y(P8_before) 
);
wire [31:0]F_out;
P P (
  .address({P1_before,P2_before,P3_before,P4_before,P5_before,P6_before,P7_before,P8_before}),
  .y(F_out) 
);
reg [5:0]index;
always@(*) begin
    cipher_key_up_w=0;
    cipher_key_down_w=0;
    R_w=0;
    L_w=0;
    RK_xor=0;
    iot_out_w=0;
    index=0;
    shift_r=0;
    result=0;
    if((fn_sel==ENCRYPT)||(fn_sel==DECRYPT))begin
	case(state)
        OPERATION:begin
            if(counter_32>=0 && counter_32<=15)begin
                R_w=plaintext[31:0];
                L_w=plaintext[63:32];
                cipher_key_up=cipher_key[27:0];
                cipher_key_down=cipher_key[55:28];
                if(fn_sel==ENCRYPT)begin
                    case(counter_32)
                    0:begin
                        cipher_key_up_w={cipher_key_up[26:0],cipher_key_up[27]};
                        cipher_key_down_w={cipher_key_down[26:0],cipher_key_down[27]};
                    end
                    1:begin
                        cipher_key_up_w={cipher_key_up[25:0],cipher_key_up[27:26]};
                        cipher_key_down_w={cipher_key_down[25:0],cipher_key_down[27:26]};
                    end
                    2:begin
                        cipher_key_up_w={cipher_key_up[23:0],cipher_key_up[27:24]};
                        cipher_key_down_w={cipher_key_down[23:0],cipher_key_down[27:24]};
                    end
                    3:begin
                        cipher_key_up_w={cipher_key_up[21:0],cipher_key_up[27:22]};
                        cipher_key_down_w={cipher_key_down[21:0],cipher_key_down[27:22]};
                    end
                    4:begin
                        cipher_key_up_w={cipher_key_up[19:0],cipher_key_up[27:20]};
                        cipher_key_down_w={cipher_key_down[19:0],cipher_key_down[27:20]};
                    end
                    5:begin
                        cipher_key_up_w={cipher_key_up[17:0],cipher_key_up[27:18]};
                        cipher_key_down_w={cipher_key_down[17:0],cipher_key_down[27:18]};
                    end
                    6:begin
                        cipher_key_up_w={cipher_key_up[15:0],cipher_key_up[27:16]};
                        cipher_key_down_w={cipher_key_down[15:0],cipher_key_down[27:16]};
                    end
                    7:begin
                        cipher_key_up_w={cipher_key_up[13:0],cipher_key_up[27:14]};
                        cipher_key_down_w={cipher_key_down[13:0],cipher_key_down[27:14]};
                    end
                    8:begin
                        cipher_key_up_w={cipher_key_up[12:0],cipher_key_up[27:13]};
                        cipher_key_down_w={cipher_key_down[12:0],cipher_key_down[27:13]};
                    end
                    9:begin
                        cipher_key_up_w={cipher_key_up[10:0],cipher_key_up[27:11]};
                        cipher_key_down_w={cipher_key_down[10:0],cipher_key_down[27:11]};
                    end
                    10:begin
                        cipher_key_up_w={cipher_key_up[8:0],cipher_key_up[27:9]};
                        cipher_key_down_w={cipher_key_down[8:0],cipher_key_down[27:9]};
                    end
                    11:begin
                        cipher_key_up_w={cipher_key_up[6:0],cipher_key_up[27:7]};
                        cipher_key_down_w={cipher_key_down[6:0],cipher_key_down[27:7]};
                    end
                    12:begin
                        cipher_key_up_w={cipher_key_up[4:0],cipher_key_up[27:5]};
                        cipher_key_down_w={cipher_key_down[4:0],cipher_key_down[27:5]};
                    end
                    13:begin
                        cipher_key_up_w={cipher_key_up[2:0],cipher_key_up[27:3]};
                        cipher_key_down_w={cipher_key_down[2:0],cipher_key_down[27:3]};
                    end
                    14:begin
                        cipher_key_up_w={cipher_key_up[0],cipher_key_up[27:1]};
                        cipher_key_down_w={cipher_key_down[0],cipher_key_down[27:1]};
                    end
                    15:begin
                        cipher_key_up_w=cipher_key_up;
                        cipher_key_down_w=cipher_key_down;
                    end
                    endcase


                end
                else if(fn_sel==DECRYPT)begin
                    case(counter_32)
                    0:begin
                        cipher_key_up_w=cipher_key_up;
                        cipher_key_down_w=cipher_key_down;
                    end
                    1:begin
                        cipher_key_up_w={cipher_key_up[0],cipher_key_up[27:1]};
                        cipher_key_down_w={cipher_key_down[0],cipher_key_down[27:1]};
                    end
                    2:begin
                        cipher_key_up_w={cipher_key_up[2:0],cipher_key_up[27:3]};
                        cipher_key_down_w={cipher_key_down[2:0],cipher_key_down[27:3]};
                    end
                    3:begin
                        cipher_key_up_w={cipher_key_up[4:0],cipher_key_up[27:5]};
                        cipher_key_down_w={cipher_key_down[4:0],cipher_key_down[27:5]};
                    end
                    4:begin
                        cipher_key_up_w={cipher_key_up[6:0],cipher_key_up[27:7]};
                        cipher_key_down_w={cipher_key_down[6:0],cipher_key_down[27:7]};
                    end
                    5:begin
                        cipher_key_up_w={cipher_key_up[8:0],cipher_key_up[27:9]};
                        cipher_key_down_w={cipher_key_down[8:0],cipher_key_down[27:9]};
                    end
                    6:begin
                        cipher_key_up_w={cipher_key_up[10:0],cipher_key_up[27:11]};
                        cipher_key_down_w={cipher_key_down[10:0],cipher_key_down[27:11]};
                    end
                    7:begin
                        cipher_key_up_w={cipher_key_up[12:0],cipher_key_up[27:13]};
                        cipher_key_down_w={cipher_key_down[12:0],cipher_key_down[27:13]};
                    end
                    8:begin
                        cipher_key_up_w={cipher_key_up[13:0],cipher_key_up[27:14]};
                        cipher_key_down_w={cipher_key_down[13:0],cipher_key_down[27:14]};
                    end
                    9:begin
                        cipher_key_up_w={cipher_key_up[15:0],cipher_key_up[27:16]};
                        cipher_key_down_w={cipher_key_down[15:0],cipher_key_down[27:16]};
                    end
                    10:begin
                        cipher_key_up_w={cipher_key_up[17:0],cipher_key_up[27:18]};
                        cipher_key_down_w={cipher_key_down[17:0],cipher_key_down[27:18]};
                    end
                    11:begin
                        cipher_key_up_w={cipher_key_up[19:0],cipher_key_up[27:20]};
                        cipher_key_down_w={cipher_key_down[19:0],cipher_key_down[27:20]};
                    end
                    12:begin
                        cipher_key_up_w={cipher_key_up[21:0],cipher_key_up[27:22]};
                        cipher_key_down_w={cipher_key_down[21:0],cipher_key_down[27:22]};
                    end
                    13:begin
                        cipher_key_up_w={cipher_key_up[23:0],cipher_key_up[27:24]};
                        cipher_key_down_w={cipher_key_down[23:0],cipher_key_down[27:24]};
                    end
                    14:begin
                        cipher_key_up_w={cipher_key_up[25:0],cipher_key_up[27:26]};
                        cipher_key_down_w={cipher_key_down[25:0],cipher_key_down[27:26]};
                    end
                    15:begin
                        cipher_key_up_w={cipher_key_up[26:0],cipher_key_up[27]};
                        cipher_key_down_w={cipher_key_down[26:0],cipher_key_down[27]};
                    end
                endcase

                end
                if(counter_32>=1 && counter_32<=15)begin
                    RK_xor=key ^ R_expansion;
                    R_w=F_out ^L_r;
                    L_w=R_r;
                end

            end
            else if(counter_32==16)
            begin
                RK_xor=key ^ R_expansion;
                R_w=R_r;
                L_w=F_out ^L_r;
            end
        end
        OUTPUT:begin
            if(counter_32==17 &&p12)begin
                iot_out_w={data_r[127:64],ciphertext};
            end
            else begin
                iot_out_w=0;
            end

        end
        
    default:begin
            cipher_key_up_w=0;
            cipher_key_up=0;
            cipher_key_down=0;
            cipher_key_down_w=0;
        end
	endcase
    end
    else if(fn_sel==CRCGEN)
    begin

        if(state==OPERATION)begin
            if(counter_32==16)begin
                shift_w_extension={shift_w,3'd0};
                shift_r={result_r[2:0],shift_w_extension[10]};
                for(i=10;i>0;i=i-1)begin
                if (shift_r[3]) begin
                    result = shift_r[2:0] ^ generator;
                end
                else 
                    result = shift_r;
                shift_r={result,shift_w_extension[i-1]};
                end


                if (shift_r[3]) begin
                    result = shift_r[2:0] ^ generator;
                end
                else 
                    result = shift_r;
                iot_out_w={125'd0,result};

            end
            else begin

                //shift_w=data_r[((17-counter_32)*8)-1 -: 8];

                if(counter_32==1)begin
                    //temp=shift_w[7:4];

                    for(i=7;i>3;i=i-1)begin
                    if(i==7)begin
                        if (shift_w[7]) begin
                            result = shift_w[6:4] ^ generator;
                        end
                        else 
                            result = shift_w[7:4];
                    end
                    else begin
                        if (shift_r[3]) begin
                            result = shift_r[2:0] ^ generator;
                        end
                        else 
                            result = shift_r;
                    end
                    shift_r={result,shift_w[i-4]};
                    end


                    if (shift_r[3]) begin
                        result = shift_r[2:0] ^ generator;
                    end
                    else 
                        result = shift_r;
                    
                end
                else if(counter_32>=2)begin
                    shift_r={result_r,shift_w[7]};


                    for(i=7;i>0;i=i-1)begin
                    if (shift_r[3]) begin
                        result = shift_r[2:0] ^ generator;
                    end
                    else 
                        result = shift_r;
                    shift_r={result,shift_w[i-1]};

                    end
                    if (shift_r[3]) begin
                        result = shift_r[2:0] ^ generator;
                    end
                    else 
                        result = shift_r & 4'b1111;

                end

            end


        end


    end



end


always@(posedge clk or posedge rst) begin
	if(rst)	begin	
        counter_8<=0;
    end
    else if(state==READ &&counter_32==16)
        counter_8<=counter_8+1;
    else if(state==OPERATION &&counter_8==8)
        counter_8<=counter_8+1;
    else if(state==OPERATION &&counter_8==9)
        counter_8<=0;
    // else if(state==OPERATION)
    //     counter_8<=counter_8+1;
end

always@(posedge clk or posedge rst) begin
	if(rst)	begin	
        R_r<=0;
        L_r<=0;
        valid_r<=0;
        iot_out_r<=0;
        result_r<=0;
        busy_r<=1;
        // max1<=0;
        max2<=0;
    end
    else if(state==READ && p45&&counter_32==16)begin
        if(counter_8==0 &&counter_32==16)begin
            if(fn_sel==Top2Max)begin
                iot_out_r<=data_r;
                max2<=0;
            end
            else if(fn_sel==Last2Min)begin
                iot_out_r<=data_r;               
                max2<=128'hffffffffffffffffffffffffffffffff;
            end
        end
        // else if(counter_8==0)begin

        // end
        else begin
            if(fn_sel==Top2Max)begin
                if(data_r>=iot_out_r)begin
                    iot_out_r<=data_r;
                    max2<=iot_out_r;
                end 
                else if(data_r<iot_out_r &&data_r>=max2 )
                    max2<=data_r;
            end
            else if(fn_sel==Last2Min) begin
                if(data_r<=iot_out_r)begin
                    iot_out_r<=data_r;
                    max2<=iot_out_r;
                end 
                else if(data_r>iot_out_r &&data_r<=max2 )
                    max2<=data_r;


            end
        end
    end
    else if(state==OPERATION &&p12)
    begin
        R_r<=R_w;
        L_r<=L_w;
        valid_r<=valid_w;        
        busy_r<=busy_w;
        max2[((counter_32)*8)+:8]<= iot_in;


    end

    else if(state==OPERATION &&fn_sel==CRCGEN &&counter_32==16)
    begin
        iot_out_r<=iot_out_w;
        valid_r<=valid_w;       
        busy_r<=busy_w;


    end
    else if(state==OPERATION &&fn_sel==CRCGEN)
    begin
       result_r<=result;        
       busy_r<=busy_w;
        valid_r<=valid_w;        
        max2[((counter_32)*8)+:8]<= iot_in;


    end
     else if(state==OPERATION &&p45)
    begin
        if(counter_8==8)begin
            // iot_out_r<=max1;
            valid_r<=1;        

        end
        else if(counter_8==9)begin
            iot_out_r<=max2;
            valid_r<=1;        

        end
        busy_r<=busy_w;


    end

    else if(state==OUTPUT&&fn_sel!=CRCGEN)begin
            iot_out_r<=iot_out_w;
            valid_r<=valid_w;        
            busy_r<=busy_w;

    end
    else begin    
        valid_r<=valid_w;        
        busy_r<=busy_w;

    end


end
always@(posedge clk or posedge rst) begin
	if(rst)	begin	
        counter_32 <= 0;
        flag<=0;
        cipher_key_up_r<=0;
        cipher_key_down_r<=0;
    end
	else if(state==READ &&in_en &&flag==0)begin
        counter_32 <= counter_32+1;
        flag<=1;
    end
    else if(state==READ &&flag==1)begin
        counter_32 <= counter_32+1;

        if(counter_32==16)begin
                counter_32<=0;
        end
    end
    else if (state==OUTPUT &&counter_32==17)begin
                cipher_key_up_r<=cipher_key_up_w;
                cipher_key_down_r<=cipher_key_down_w;
                counter_32<=0;
    end
    else if(state==OPERATION &&(p12))begin
        flag<=0;
        counter_32 <= counter_32+1;
        if(counter_32<17)begin
        cipher_key_up_r<=cipher_key_up_w;
        cipher_key_down_r<=cipher_key_down_w;
        end
        // else if(counter_32==17)begin
        //         cipher_key_up_r<=cipher_key_up_w;
        //         cipher_key_down_r<=cipher_key_down_w;
        //         counter_32<=0;
        // end

    end
    else if(state==OPERATION &&((fn_sel==CRCGEN)))begin
        flag<=0;

        counter_32 <= counter_32+1;
    end
    else if(state==OPERATION &&(p45))begin
        // counter_32 <= counter_32+1;

            flag<=0;

    end
	else
        flag<=0;


end








// always @(*) begin
//     shift_reg = {data_r, 3'b000};
//     for (i = 0; i < 128; i = i + 1) begin 
//         if (shift_reg[130]) 
//             shift_reg[130:127] = shift_reg[130:127] ^ generator;

//         // Shift the register to the left by 1
//         shift_reg = shift_reg << 1;
//     end

//     // The remainder is the CRC
//     crc_out = shift_reg[130:128]; // Adjusted for 11-bit shift_reg
// end


endmodule



