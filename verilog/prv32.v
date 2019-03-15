// file: cpu.v
// author: @shalan

`timescale 1ns/1ns

`define		sync_begin(X)	always @ (posedge clk or posedge rst) if(rst)	X <= 0; else begin
`define		sync_end		end

//`include "defines.v"
// file: defines.v
// author: @shalan

`define     IR_rs1          19:15
`define     IR_rs2          24:20
`define     IR_rd           11:7
`define     IR_opcode       6:2
`define     IR_funct3       14:12
`define     IR_funct7       31:25
`define     IR_shamt        24:20
`define     IR_csr          31:20

`define     OPCODE_Branch   5'b11_000
`define     OPCODE_Load     5'b00_000
`define     OPCODE_Store    5'b01_000
`define     OPCODE_JALR     5'b11_001
`define     OPCODE_JAL      5'b11_011
`define     OPCODE_Arith_I  5'b00_100
`define     OPCODE_Arith_R  5'b01_100
`define     OPCODE_AUIPC    5'b00_101
`define     OPCODE_LUI      5'b01_101
`define     OPCODE_SYSTEM   5'b11_100
`define     OPCODE_Custom   5'b10_001

`define     F3_ADD          3'b000
`define     F3_SLL          3'b001
`define     F3_SLT          3'b010
`define     F3_SLTU         3'b011
`define     F3_XOR          3'b100
`define     F3_SRL          3'b101
`define     F3_OR           3'b110
`define     F3_AND          3'b111

`define     BR_BEQ          3'b000
`define     BR_BNE          3'b001
`define     BR_BLT          3'b100
`define     BR_BGE          3'b101
`define     BR_BLTU         3'b110
`define     BR_BGEU         3'b111

`define     OPCODE          IR[`IR_opcode]

`define     ALU_ADD         4'b00_00
`define     ALU_SUB         4'b00_01
`define     ALU_PASS        4'b00_11
`define     ALU_OR          4'b01_00
`define     ALU_AND         4'b01_01
`define     ALU_XOR         4'b01_11
`define     ALU_SRL         4'b10_00
`define     ALU_SRA         4'b10_10
`define     ALU_SLL         4'b10_01
`define     ALU_SLT         4'b11_01
`define     ALU_SLTU        4'b11_11




module prv32_ID (
    input   wire [31:0] IR,
    output  wire        Imux_sel,
    output  wire [1:0]  WBmux_sel,
    output  wire        Cmux_sel,
    output  wire        SHmux_sel,
    output  wire        PCmux2_sel,
    output  wire        RAmux,
    output  wire        rfWr,
    output  wire        mWr,
    output  reg  [3:0]  ALU_sel,
    output  reg  [1:0]  ctrl,
    output              store,
    output              instr_w_rd,
    output              instr_w_rs1,
    output              instr_w_rs2
    //output       [2:0]  func3
);
    
    wire [4:0] opcode = `OPCODE;
    wire [2:0] func3 = IR[`IR_funct3];
    wire [6:0] func7 = IR[`IR_funct7];
    
    wire I = (opcode == `OPCODE_Arith_I);
	wire R = (opcode == `OPCODE_Arith_R);
	wire IorR =  I | R;
	wire instr_logic = ((IorR==1'b1) && ((func3==`F3_XOR) || (func3==`F3_AND) || (func3==`F3_OR)));
	wire instr_shift = ((IorR==1'b1) && ((func3==`F3_SLL) || (func3==`F3_SRL) ));
	wire instr_slt = ((IorR==1'b1) && (func3==`F3_SLT));
	wire instr_sltu = ((IorR==1'b1) && (func3==`F3_SLTU));
	wire instr_store = (opcode == `OPCODE_Store);
	wire instr_load = (opcode == `OPCODE_Load);
	wire instr_add = R & (func3 == `F3_ADD) & (~func7[5]);
	wire instr_sub = R & (func3 == `F3_ADD) & (func7[5]);
	wire instr_addi = I & (func3 == `F3_ADD);
	wire instr_lui = (opcode == `OPCODE_LUI);
	wire instr_auipc = (opcode == `OPCODE_AUIPC);
	wire instr_branch = (opcode == `OPCODE_Branch);
	wire instr_jalr = (IR[`IR_opcode]==`OPCODE_JALR);
	wire instr_jal = (IR[`IR_opcode]==`OPCODE_JAL);
	wire instr_sll = ((IorR==1'b1) && (func3==`F3_SLL) && (func7 == 7'b0)); 
	wire instr_srl = ((IorR==1'b1) && (func3==`F3_SRL) && (func7 == 7'b0));
	wire instr_sra = ((IorR==1'b1) && (func3==`F3_SRL) && (func7 != 7'b0));
	wire instr_and = ((IorR==1'b1) && (func3==`F3_AND));
	wire instr_or = ((IorR==1'b1) && (func3==`F3_OR));
	wire instr_xor = ((IorR==1'b1) && (func3==`F3_XOR));
	
	assign instr_w_rd = (I | R | instr_auipc | instr_lui | instr_jalr | instr_jal | instr_load );
	assign instr_w_rs2 = IorR | instr_branch | instr_store;
	assign instr_w_rs1 = ~(instr_auipc | instr_lui | instr_jal);
	
	assign PCmux2_sel   =   instr_jalr;
	
    assign Cmux_sel     =   1'b1;     // update to support compression
    assign WBmux_sel    =   instr_load ? 2'b11 :
                            (instr_jalr | instr_jal | instr_auipc) ? 2'b01 : 2'b00; 
    assign Imux_sel     =   instr_load  |
                            instr_store |
                        //    instr_branch|
                            instr_lui   |
                            I           |
                            instr_jalr;
    assign SHmux_sel    =   I;
    assign rfWr = instr_load | IorR | instr_jalr | instr_jal | instr_lui |instr_auipc;
    assign RAmux = instr_auipc;
  
    assign mWr = instr_store;
    
    assign store = instr_store;
    
    //assign mSize = func3[2:0];
    /*
    always @ * begin
        case (func3[1:0])
            2'b00   : mSize = 4'b0001;
            2'b01   : mSize = 4'b0011;
            2'b10   : mSize = 4'b1111;
            default : mSize = 4'b0000;
        endcase
    end*/
  
    always @ * begin
        case (1'b1)
            instr_load  :   ALU_sel = `ALU_ADD;
            instr_addi  :   ALU_sel = `ALU_ADD;
            instr_store :   ALU_sel = `ALU_ADD;
            instr_add   :   ALU_sel = `ALU_ADD; 
            instr_jalr  :   ALU_sel = `ALU_ADD;
            
            instr_lui   :   ALU_sel = `ALU_PASS;
            
            instr_sll   :   ALU_sel = `ALU_SLL;
            instr_srl   :   ALU_sel = `ALU_SRL;
            instr_sra   :   ALU_sel = `ALU_SRA;
            
            instr_slt   :   ALU_sel = `ALU_SLT;
            instr_sltu  :   ALU_sel = `ALU_SLTU;
            
            instr_and   :   ALU_sel = `ALU_AND;
            instr_or    :   ALU_sel = `ALU_OR;
            instr_xor   :   ALU_sel = `ALU_XOR;
            
            default     :   ALU_sel = `ALU_SUB;
        endcase
    end
    
    always @ * begin
        case (1'b1)
            instr_jalr  :   ctrl = 2'd1;
            instr_jal   :   ctrl = 2'd2;
            instr_branch:   ctrl = 2'd3;
            default     :   ctrl = 2'd0;
        endcase
    end
    
endmodule

module prv32_HazardsUnit (
    input wire [4:0] rs1, rs2,
    input wire [4:0] rd,
    input wire rd_valid, rs1_valid, rs2_valid,
    output fwd1, fwd2
);

    assign fwd1 = rd_valid & rs1_valid & ((rd == rs1) && (rs1 != 0));
    assign fwd2 = rd_valid & rs2_valid & ((rd == rs2) && (rs2 != 0));

endmodule

module prv32_ControlHazardUnit (
	input cf, zf, vf, sf,
	input[2:0] func3,
	input[1:0] ctrl,
	output reg taken
);
	always @ * begin
		taken = 1'b0;
		case (ctrl)
		    2'd0   :   taken = 1'b0;
		    2'd1   :   taken = 1'b1;
		    2'd2   :   taken = 1'b1;
		    2'd3   :   begin
                    		(* full_case *)
                    		(* parallel_case *)
                    		case(func3)
                    			`BR_BEQ :   taken = zf;          // BEQ
                    			`BR_BNE :   taken = ~zf;         // BNE
                    			`BR_BLT :   taken = (sf != vf);  // BLT
                    			`BR_BGE :   taken = (sf == vf);  // BGE
                    			`BR_BLTU:   taken = (~cf);      // BLTU
                    			`BR_BGEU:   taken = (cf);       // BGEU
                    			default :   taken = 1'b0;
                    		endcase
                        end
        endcase
	end
endmodule

module prv32_ImmGen (
    input  wire [31:0]  IR,
    output reg  [31:0]  Imm
);

always @(*) begin
	case (`OPCODE)
		`OPCODE_Arith_I   : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Store     :     Imm = { {21{IR[31]}}, IR[30:25], IR[11:8], IR[7] };
		`OPCODE_LUI       :     Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_AUIPC     :     Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		`OPCODE_JAL       : 	Imm = { {12{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21], 1'b0 };
		`OPCODE_JALR      : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		`OPCODE_Branch    : 	Imm = { {20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
		default           : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // IMM_I
	endcase // case (imm_type)
end

endmodule


/*
    00_00: Add
    00_01: sub
    00_11: passthrough
    01_00: or
    01_01: and
    01_11: xor
    10_00: srl
    10_10: sra
    10_01: srl
    11_01: slt
    11_11: sltu
*/
module prv32_ALU(
	input   wire [31:0] a, b,
	input   wire [4:0]  shamt,
	output  reg  [31:0] r,
	output  wire        cf, zf, vf, sf,
	input   wire [3:0]  alufn
);

    wire [31:0] add, sub, op_b;
    wire cfa, cfs;
    
    assign op_b = (~b);// + 1'b1;
    
    //assign {cf, add} = a + (alufn[0] ? op_b : b);
    assign {cf, add} = alufn[0] ? (a + op_b + 1'b1) : (a + b);
    
    assign zf = (add == 0);
    assign sf = add[31];
    assign vf = (a[31] ^ (op_b[31]) ^ add[31] ^ cf);
    
    wire[31:0] sh;
    shifter shifter0(.a(a), .shamt(shamt), .type(alufn[1:0]),  .r(sh));
    
    always @ * begin
        r = 0;
        (* parallel_case *)
        case (alufn)
            // arithmetic
            4'b00_00 : r = add;
            4'b00_01 : r = add;
            4'b00_11 : r = b;
            // logic
            4'b01_00:  r = a | b;
            4'b01_01:  r = a & b;
            4'b01_11:  r = a ^ b;
            // shift
            4'b10_00:  r=sh;
            4'b10_01:  r=sh;
            4'b10_10:  r=sh;
            // slt & sltu
            4'b11_01:  r = {31'b0,(sf != vf)}; 
            4'b11_11:  r = {31'b0,(~cf)};            	
        endcase
    end
endmodule



module prv32_memData(
    input wire [2:0] func3,
    input wire [31:0] di,
    output reg [31:0] do
);

    always @ * begin
        case (func3)
        3'b100  : do = {24'b0,di[7:0]};
        3'b000  : do = { {24{di[7]}}, di[7:0] };
        3'b101  : do = {16'b0,di[15:0]};
        3'b001  : do = { {16{di[15]} },di[15:0]};
        default : do = di;
        endcase
    end

endmodule

module prv32_CPU(
	input clk, 
	input rst, 
	
	output 	[31:0] 	mAddr, 
	output 	[31:0] 	mDo, 
	input 	[31:0] 	mDi, 
	output  [1:0]   mSize,
	output 			mWr,

	output 	[4:0] 	rfRS1, 
	output 	[4:0] 	rfRS2, 
	output 	[4:0] 	rfRD, 
	input 	[31:0] 	rfD1, 
	input 	[31:0] 	rfD2,
	output	[31:0]	rfWD,
	output			rfWr

);

    // control signals
    wire            PCmux1_sel;
    wire            PCmux2_sel;
    wire            MAmux_sel;
    wire            Imux_sel;
    //wire            FWDmux1_sel; 
    //wire            FWDmux2_sel;
    wire            Fmux_sel;
    wire [1:0]      WBmux_sel;
    wire            Cmux_sel;
    wire            SHmux_sel;
    wire            rf_Wr;
    wire            RAmux;
    wire            m_Wr;
    wire            store;
    wire            instr_w_rd;
    wire            instr_w_rs1;
    wire            instr_w_rs2;

    //wire [1:0]      m_Size;

	// Pipeline Phases
	reg				ph;
    `sync_begin (ph)
        ph <= ~ph;
    `sync_end

    // Program Counter
    wire taken;
    wire [31:0] PCAdder;
     
    reg [31:0] PC;
    
    `sync_begin(PC)
	    if(ph) 
	        if(taken) 
	            PC <= (PCmux2_sel_1) ? ALUres : PCAdder; // add support for JALR!!
	        else 
	            PC <= PC+4;
	`sync_end
	
	
	// Stage 1
	reg		[31:0]	IR;
	
	// stage 1-2 pipeline registers
	reg		[31:0]	PC_1;
	reg		[31:0]	R1_1, R2_1, I_1;
	reg		[4:0]	rd_1, rs1_1, rs2_1;
    reg     [4:0]   shamt_1;
    reg     [2:0]   func3_1;
    reg     [1:0]   ctrl_1;
    
    wire    [1:0]   ctrl;
    
    reg Imux_sel_1, Cmux_sel_1, SHmux_sel_1, RAmux_1, rf_Wr_1, m_Wr_1;
    reg PCmux2_sel_1;
    reg [1:0] WBmux_sel_1;
    reg [3:0] ALU_sel_1;
    reg store_1;
    reg instr_w_rd_1, instr_w_rs1_1, instr_w_rs2_1;
    
    //reg [1:0] m_Size_1;
    
    assign rfRS1 = IR[`IR_rs1];
    assign rfRS2 = IR[`IR_rs2];

    wire [31:0] imm;
    wire [3:0] ALU_sel;
    
    prv32_ImmGen IG0    (
                            .IR(IR),
                            .Imm(imm)
                        );
                        
    prv32_ID ID0    (   .IR(IR),
                        .Imux_sel(Imux_sel),
                        .WBmux_sel(WBmux_sel),
                        .Cmux_sel(Cmux_sel),
                        .SHmux_sel(SHmux_sel),
                        .PCmux2_sel(PCmux2_sel),
                        .RAmux(RAmux),
                        .rfWr(rf_Wr),
                        .ALU_sel(ALU_sel), 
                        .ctrl(ctrl),
                        .mWr(m_Wr),
                        .store(store),
                        .instr_w_rd(instr_w_rd),
                        .instr_w_rs1(instr_w_rs1),
                        .instr_w_rs2(instr_w_rs2)
                        //.func3(m_Size)
                    );
    
	`sync_begin(IR)
	    if(~ph) IR <= mDi;
	`sync_end
	
	`sync_begin(rd_1)
        if(ph) rd_1 <= IR[`IR_rd];		
	`sync_end
	
	`sync_begin(rs1_1)
        if(ph) rs1_1 <= IR[`IR_rs1];		
	`sync_end
	
	`sync_begin(rs2_1)
        if(ph) rs2_1 <= IR[`IR_rs2];		
	`sync_end
	
	`sync_begin(func3_1)
        if(ph) func3_1 <= IR[`IR_funct3];		
	`sync_end
	
	`sync_begin(shamt_1)
        if(ph) shamt_1 <= SHmux_sel ? IR[`IR_shamt] : rfD2[4:0];		
	`sync_end

	`sync_begin(ALU_sel_1)
	    if(ph)  ALU_sel_1 <= ALU_sel;
	`sync_end
	
	// control signals
	`sync_begin(Imux_sel_1)
	    if(ph) Imux_sel_1 <= Imux_sel;
	`sync_end
	
	`sync_begin(WBmux_sel_1)
	    if(ph)  WBmux_sel_1 <= WBmux_sel;
	`sync_end
	
	`sync_begin(Cmux_sel_1)
	    if(ph)  Cmux_sel_1 <= Cmux_sel;
	`sync_end
	
	`sync_begin(SHmux_sel_1)
	    if(ph)  SHmux_sel_1 <= SHmux_sel;
	`sync_end
	
	`sync_begin(RAmux_1)
	    if(ph)  RAmux_1 <= RAmux;
	`sync_end
	
	`sync_begin(store_1)
	    if(ph)  store_1 <= store;
	`sync_end
	
	`sync_begin(instr_w_rd_1)
	    if(ph)  instr_w_rd_1 <= instr_w_rd;
	`sync_end
	
	`sync_begin(instr_w_rs1_1)
	    if(ph)  instr_w_rs1_1 <= instr_w_rs1;
	`sync_end
	
	`sync_begin(instr_w_rs2_1)
	    if(ph)  instr_w_rs2_1 <= instr_w_rs2;
	`sync_end
	
	`sync_begin(PCmux2_sel_1)
	    if(ph)  PCmux2_sel_1 <= PCmux2_sel;
	`sync_end
	
	
	`sync_begin(rf_Wr_1)
	    if(ph)  rf_Wr_1 <= (rf_Wr & ~taken);
	`sync_end
    
    `sync_begin(m_Wr_1)
	    if(ph)  m_Wr_1 <= (m_Wr & ~taken);
	    //else m_Wr_1 <= 1'b0;
	`sync_end
	
//	`sync_begin(m_Size_1)
//	    if(ph)  m_Size_1 <= m_Size;
//	`sync_end
	
    `sync_begin(ctrl_1)
	    if(ph)  ctrl_1 <= (ctrl & {~taken, ~taken});
	`sync_end	
	
	// 
	
	`sync_begin(R1_1)
	    if(ph) R1_1 <= rfD1;
	`sync_end
	
    `sync_begin(R2_1)
	    if(ph) R2_1 <= rfD2;
	`sync_end
	
	`sync_begin(PC_1)
	    if(ph) PC_1 <= PC;
	`sync_end
	
	`sync_begin(I_1)
	    if(ph) I_1 <= imm;
	`sync_end
	
	
    // Stage 2
    // stage 2 wires and busses
    wire [31:0] FWDmux1, FWDmux2, Imux;
    wire [31:0] ALUres;
    wire FWDmux1_sel, FWDmux2_sel;
    //wire taken;
    wire sf, vf, zf, cf;
    
    // stage 2-3 pipeline registers
    reg [31:0] R_2, MD_2;
    reg [1:0] WBmux_sel_2;
    reg [4:0] rd_2;
    reg rf_Wr_2;
    reg [31:0] RA_2;
    reg instr_w_rd_2;

    // memory data unit
    wire [31:0] mData;
    prv32_memData MD0 (
        .func3(func3_1),
        .di(mDi),
        .do(mData)
    );
    
    assign Imux = Imux_sel_1 ? I_1 : R2_1;
    
    // The ALU
    prv32_ALU ALU0(.a(FWDmux1), .b(FWDmux2), .shamt(shamt_1),.r(ALUres), .cf(cf), .zf(zf), .vf(vf), .sf(sf), .alufn(ALU_sel_1));  
    
    // PC Adder
    assign PCAdder = PC_1 + I_1;
    
    // Forwarding
    prv32_HazardsUnit HZ0 ( .rs1(rs1_1), 
                            .rs2(rs2_1), 
                            .rd(rd_2), 
                            .rd_valid(instr_w_rd_2), 
                            .rs1_valid(instr_w_rs1_1), 
                            .rs2_valid(instr_w_rs2_1), 
                            .fwd1(FWDmux1_sel), 
                            .fwd2(FWDmux2_sel) );
    
    assign FWDmux1 = (FWDmux1_sel) ? WBmux : R1_1;
    assign FWDmux2 = (FWDmux2_sel & ~store_1) ? WBmux : Imux;       // don't forward unless it is not store instr!
    
    // Branch Unit
    prv32_ControlHazardUnit BU0(.cf(cf), .zf(zf), .vf(vf), .sf(sf), .func3(func3_1), .ctrl(ctrl_1), .taken(taken));
    
    `sync_begin(R_2)
	    if(ph) R_2 <= ALUres;
	`sync_end
	
	`sync_begin(MD_2)
	    if(ph) MD_2 <= mData;
	`sync_end
	
	// control signals
	`sync_begin(rd_2)
        if(ph) rd_2 <= rd_1;		
	`sync_end
	
	`sync_begin(instr_w_rd_2)
        if(ph) instr_w_rd_2 <= instr_w_rd_1;		
	`sync_end
	
	`sync_begin(rf_Wr_2)
        if(ph) rf_Wr_2 <= rf_Wr_1;		
	`sync_end
	
	`sync_begin(WBmux_sel_2)
        if(ph) WBmux_sel_2 <= WBmux_sel_1;		
	`sync_end
	
	`sync_begin(RA_2)
        if(ph) RA_2 <= RAmux_1 ? PCAdder : (PC_1+32'd4);		
	`sync_end
	
    // stage 3
    wire [31:0] WBmux = (WBmux_sel_2==2'b11) ? MD_2 : 
                        (WBmux_sel_2==2'b01) ? RA_2 : R_2;
    assign rfWD =  WBmux;
    assign rfRD = rd_2;
    assign rfWr = rf_Wr_2 & ~ph;
    
    
    
    // Memory Interface
	assign mAddr = ph ? ALUres : PC;        // change the address only in case of data rd/wr to save power
	assign mSize = ph ? func3_1[1:0] : 2'b10;
	assign mWr = m_Wr_1 & ph;
	assign mDo = (FWDmux2_sel & store_1) ? WBmux : R2_1;
	
endmodule




module mirror (input [31:0] in, output reg [31:0] out);
    integer i;
    always @ *
        for(i=0; i<32; i=i+1)
            out[i] = in[31-i];
endmodule

module shr(input [31:0] a, output [31:0] r, input [4:0] shamt, input ar);
    
    wire [31:0] r1, r2, r3, r4;
    
    wire fill = ar ? a[31] : 1'b0;
    assign r1 = shamt[0] ? {fill, a[31:1]} : a;
    assign r2 = shamt[1] ? {fill, fill, r1[31:2]} : r1;
    assign r3 = shamt[2] ? {{4{fill}}, r2[31:4]} : r2;
    assign r4 = shamt[3] ? {{8{fill}}, r3[31:8]} : r3;
    assign r = shamt[4] ? {{16{fill}}, r4[31:16]} : r4;
    
endmodule 

// type[0] sll or srl
// type[1] sra
// 00 : srl
// 10 : sra
// 01 : sll
module shifter(input[31:0] a, input [4:0] shamt, input[1:0] type,  output [31:0] r);
    wire [31 : 0] ma, my, y, x, sy;
    
    mirror m1(.in(a), .out(ma));
    mirror m2(.in(y), .out(my));
    
    assign x = type[0] ? ma : a;
    shr sh0(.a(x), .r(y), .shamt(shamt), .ar(type[1]));
    
    assign r = type[0] ? my : y;
    
endmodule


