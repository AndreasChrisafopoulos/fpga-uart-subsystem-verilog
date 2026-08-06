module LEDdecoder(
    input [3:0] char,     
    output CA, CB, CC, CD, CE, CF, CG 
);

reg CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r;

always @(char) begin
    case(char)
        4'h0: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0000001;
        4'h1: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b1001111;
        4'h2: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0010010;
        4'h3: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0000110;
        4'h4: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b1001100;
        4'h5: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0100100;///
        4'h6: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0100000;
        4'h7: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0001111;
        4'h8: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0000000;
        4'h9: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0000100;
        4'hA: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0001000;
        4'hB: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b1100000;// b
        4'hC: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0110001;
        4'hD: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b1000010;// d
        4'hE: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0110000;
        4'hF: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b0111000;
        default: {CA_r, CB_r, CC_r, CD_r, CE_r, CF_r, CG_r} = 7'b1111111;
    endcase
end

assign CA = CA_r;
assign CB = CB_r;
assign CC = CC_r;
assign CD = CD_r;
assign CE = CE_r;
assign CF = CF_r;
assign CG = CG_r;

endmodule

