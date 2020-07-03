.data
writedata:  .space 32 #32 bytes of space needed
dataadr:    .space 32
memwrite:   .space 1
pc:	    .space 32
instr:	    .space 32
readdata:   .space 32
memtoreg:   .space 1
pcsrc:	    .space 1
zero:	    .space 1
alusrc:     .space 1
regdst:     .space 1
regwrite:   .space 1
jump:	    .space 1
alucontrol: .space 3
aluop:	    .space 2
branch:	    .space 1
addr:	    .space 6
writereg:   .space 5
pcnext:     .space 32 
pcnextbr:   .space 32 
pcplus4:    .space 32 
pcbranch:   .space 32
signimm:    .space 32 
signimmsh:  .space 32 
srca:       .space 32 
srcb:       .space 32 
result:     .space 32


.text

#// Top level system including MIPS and memories
#
#
#module top  (input   logic 	 clk, reset,            
#	     output  logic[31:0] writedata, dataadr,            
#	     output  logic       memwrite);   
#   mips mips (clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);  
#   imem imem (pc[7:2], instr);  
#   dmem dmem (clk, memwrite, dataadr, writedata, readdata);
#
#endmodule

top:
	subu $sp, $sp, 4
	sw   $s0, ($sp)
	addi $s0, $s0, 1 #s0 is to hold the number of registers there is?
	
	li $t0, 0 #initialize pc, instr, readdata
	sw $t0, pc
	sw $t0, instr
	sw $t0, readdata
	
	subu $sp, $sp, 4
	sw $ra, ($sp) #to jump and then come back
	jal mips
	
	subu $sp, $sp, 4
	sw $ra, ($sp)
	jal imem
	
	subu $sp, $sp, 4
	sw $ra, ($sp)
	jal dmem

mips:
	subu $sp, $sp, 4
	sw $ra, ($sp)
	jal controller
	
	subu $sp, $sp, 4
	sw $ra, ($sp)
	jal datapath
	
	lw $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
imem:
	#pc[7:2] = addr
	subu $sp, $sp, 4
	sw $s2, ($sp)
	
	la $s2, pc
	srl $s2, $s2, 3 #shift right to 3 bits, so that we get the same binary value except for the last 3
	sll $s2, $s2, 2 #now shift right by 2 bits so the last 2 bits are 2'b00
	sw $s2, addr #now addr holds the value we want
		    #we dont really need addr, but i held it to check on its value	
	subu $sp, $sp, 4
	sw $s1, ($sp)
	
	beq $s2, 0x00, imemcase00
	beq $s2, 0x04, imemcase04
	beq $s2, 0x08, imemcase08
	beq $s2, 0x0c, imemcase0c
	beq $s2, 0x10, imemcase10
	beq $s2, 0x14, imemcase14
	beq $s2, 0x18, imemcase18
	beq $s2, 0x1c, imemcase1c
	beq $s2, 0x20, imemcase20
	beq $s2, 0x24, imemcase24
	beq $s2, 0x28, imemcase28
	beq $s2, 0x2c, imemcase2c
	beq $s2, 0x30, imemcase30
	beq $s2, 0x34, imemcase34
	beq $s2, 0x38, imemcase38
	beq $s2, 0x3c, imemcase3c
	beq $s2, 0x40, imemcase40
	beq $s2, 0x44, imemcase44
	beq $s2, 0x48, imemcase48
	j imemCaseDefault
imemcase00:
	lw $s1, 0x20020005
	sw $s1, instr
	j goBackFromImem
imemcase04:
	lw $s1, 0x2003000c
	sw $s1, instr
	j goBackFromImem
imemcase08:
	lw $s1, 0x2067fff7
	sw $s1, instr
	j goBackFromImem
imemcase0c:
	lw $s1, 0x00e22025
	sw $s1, instr
	j goBackFromImem
imemcase10:
	lw $s1, 0x00642824
	sw $s1, instr
	j goBackFromImem
imemcase14:
	lw $s1, 0x00a42820
	sw $s1, instr
	j goBackFromImem
imemcase18:
	lw $s1, 0x10a7000a
	sw $s1, instr
	j goBackFromImem
imemcase1c:
	lw $s1, 0x0064202a
	sw $s1, instr
	j goBackFromImem
imemcase20:
	lw $s1, 0x10800001
	sw $s1, instr
	j goBackFromImem
imemcase24:
	lw $s1, 0x20050000
	sw $s1, instr
	j goBackFromImem
imemcase28:
	lw $s1, 0x00e2202a
	sw $s1, instr
	j goBackFromImem
imemcase2c:
	lw $s1, 0x00853820
	sw $s1, instr
	j goBackFromImem
imemcase30:
	lw $s1, 0x00e23822
	sw $s1, instr
	j goBackFromImem
imemcase34:
	lw $s1, 0xac670044
	sw $s1, instr
	j goBackFromImem
imemcase38:
	lw $s1, 0x8c020050
	sw $s1, instr
	j goBackFromImem
imemcase3c:
	lw $s1, 0x08000011
	sw $s1, instr
	j goBackFromImem
imemcase40:
	lw $s1, 0x20020001
	sw $s1, instr
	j goBackFromImem
imemcase44:
	lw $s1, 0xac020054
	sw $s1, instr
	j goBackFromImem
imemcase48:
	lw $s1, 0x08000012
	sw $s1, instr
	j goBackFromImem
imemCaseDefault:
	lw $s1, 1
	sw $s1, instr
	j goBackFromImem
goBackFromImem: #pop all the temp registers
	lw $s1, ($sp)
	addu $sp, $sp, 4
	lw $s2, ($sp)
	addu $sp, $sp, 4
	lw $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
	
dmem:
	lw $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
controller:
	#logic [1:0] aluop;
   	#logic       branch;
   	li $t0, 0 #initialize as 0
   	sw $t0, aluop
   	sw $t0, branch
   	
	subu $sp, $sp, 4
	sw $ra, ($sp)
	
	#instr[31:26] = op
	subu $sp, $sp, 4
	sw   $s1, ($sp)
	
	lw   $s1, instr
	srl  $s1, $s1, 26 #shift 26 bits to the right to get the first 6 bits
	sw   $s1, op
	
	jal maindec
	
	subu $sp, $sp, 4
	sw   $ra, ($sp)
	#instr[5:0] = funct
	subu $sp, $sp, 4
	sw   $s2, ($sp)
	
	lw   $s2, instr
	and  $s2, $s2, 0x3f #last 6 bits
	sw   $s2, funct
	
	jal aludec
	
	lw $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
datapath:
	subu $sp, $sp, 4
	sw $ra, ($sp)
	jal regfile

	lw $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
regfile:
	li $t0, 0
	sw $t0, pcnext
	jal flopr #flopr is pc = pcnext on every posedge clock
	
	lw   $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
flopr:
	
maindec: #s1 = op
	beq  $s1, 0,  maindecCase1
	beq  $s1, 35, maindecCase2
	beq  $s1, 43, maindecCase3
	beq  $s1, 4,  maindecCase4
	beq  $s1, 8,  maindecCase5
	beq  $s1, 2,  maindecCase6
	j maindecDefault
maindecCase1: #R-TYPE
	li $t0, 1
	lw $t0, regwrite
	li $t0, 1
	lw $t0, regdst
	li $t0, 0
	lw $t0, alusrc
	li $t0, 0
	lw $t0, branch
	li $t0, 0
	lw $t0, memwrite
	li $t0, 0
	lw $t0, memtoreg
	li $t0, 2
	lw $t0, aluop
	li $t0, 0
	lw $t0, jump
	j maindecGoBack
maindecCase2: #LW
	li $t0, 1
	lw $t0, regwrite
	li $t0, 0
	lw $t0, regdst
	li $t0, 1
	lw $t0, alusrc
	li $t0, 0
	lw $t0, branch
	li $t0, 0
	lw $t0, memwrite
	li $t0, 1
	lw $t0, memtoreg
	li $t0, 0
	lw $t0, aluop
	li $t0, 0
	lw $t0, jump
	j maindecGoBack
maindecCase3: #SW
	li $t0, 0
	lw $t0, regwrite
	li $t0, 0
	lw $t0, regdst
	li $t0, 1
	lw $t0, alusrc
	li $t0, 0
	lw $t0, branch
	li $t0, 1
	lw $t0, memwrite
	li $t0, 0
	lw $t0, memtoreg
	li $t0, 0
	lw $t0, aluop
	li $t0, 0
	lw $t0, jump
	j maindecGoBack
maindecCase4: #BEQ
	li $t0, 0
	lw $t0, regwrite
	li $t0, 0
	lw $t0, regdst
	li $t0, 0
	lw $t0, alusrc
	li $t0, 1
	lw $t0, branch
	li $t0, 0
	lw $t0, memwrite
	li $t0, 0
	lw $t0, memtoreg
	li $t0, 1
	lw $t0, aluop
	li $t0, 0
	lw $t0, jump
	j maindecGoBack
maindecCase5: #ADDI
	li $t0, 1
	lw $t0, regwrite
	li $t0, 0
	lw $t0, regdst
	li $t0, 1
	lw $t0, alusrc
	li $t0, 0
	lw $t0, branch
	li $t0, 0
	lw $t0, memwrite
	li $t0, 0
	lw $t0, memtoreg
	li $t0, 0
	lw $t0, aluop
	li $t0, 0
	lw $t0, jump
	j maindecGoBack
maindecCase6: #J
	li $t0, 0
	lw $t0, regwrite
	li $t0, 0
	lw $t0, regdst
	li $t0, 0
	lw $t0, alusrc
	li $t0, 0
	lw $t0, branch
	li $t0, 0
	lw $t0, memwrite
	li $t0, 0
	lw $t0, memtoreg
	li $t0, 0
	lw $t0, aluop
	li $t0, 1
	lw $t0, jump
maindecDefault:
	j  maindecGoBack
maindecGoBack:
	lw   $s1, ($sp)
	addu $sp, $sp, 4
	lw   $ra, ($sp)
	addu $sp, $sp, 4
	jr   $ra
aludec:
	subu $sp, $sp, 4
	sw   $s1, ($sp)
	lw   $s1, aluop #s1 will hold aluop temporarily
	
	beq  $s1, 0, aludecCase1
	beq  $s1, 1, aludecCase2
	j    aludecDefault
aludecCase1:
	li $t0, 2
	sw $t0, alucontrol
	j aludecGoBack
aludecCase2:
	li $t0, 6
	sw $t0, alucontrol
	j aludecGoBack
aludecDefault:
	lw $t0, funct
	beq $t0, 32, aludecFunct1
	beq $t0, 34, aludecFunct2
	beq $t0, 36, aludecFunct3
	beq $t0, 37, aludecFunct4
	beq $t0, 42, aludecFunct5
	j   aludecFunctDef
aludecFunct1: #ADD
	li  $t0, 2 #since we dont need t0 anymore
	sw  $t0, alucontrol
	j   aludecGoBack
aludecFunct2: #SUB
	li  $t0, 6 #since we dont need t0 anymore
	sw  $t0, alucontrol
	j   aludecGoBack
aludecFunct3: #AND
	li  $t0, 0 #since we dont need t0 anymore
	sw  $t0, alucontrol
	j   aludecGoBack
aludecFunct4: #OR
	li  $t0, 1 #since we dont need t0 anymore
	sw  $t0, alucontrol
	j   aludecGoBack
aludecFunct5: #SLT
	li  $t0, 7 #since we dont need t0 anymore
	sw  $t0, alucontrol
aludecFunctDef:
	j   aludecGoBack
aludecGoBack:
	lw   $s1, ($sp)
	addu $sp, $sp, 4
	lw   $s2, ($sp)
	addu $sp, $sp, 4
	lw   $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
#// External data memory used by MIPS single-cycle processor
#
#module dmem (input  logic        clk, reset,
#             input  logic[31:0]  a, wd,
#             output logic[31:0]  rd);
#   logic  [31:0] RAM[63:0];
#   assign rd = RAM[a[31:2]];    // word-aligned  read (for lw)
#   always_ff @(posedge clk)
#     if (we)
#       RAM[a[31:2]] <= wd;      // word-aligned write (for sw)
#endmodule



#// External instruction memory used by MIPS single-cycle
#// processor. It models instruction memory as a stored-program 
#// ROM, with address as input, and instruction as output

#// single-cycle MIPS processor, with controller and datapath

#module mips (input  logic        clk, reset,
#             output logic[31:0]  pc,
#             input  logic[31:0]  instr,
#             output logic        memwrite,
#             output logic[31:0]  aluout, writedata,
#             input  logic[31:0]  readdata);
#aluout = dataadr
#  logic        memtoreg, pcsrc, zero, alusrc, regdst, regwrite, jump;
#  logic [2:0]  alucontrol;
#
#  controller c (instr[31:26], instr[5:0], zero, memtoreg, memwrite, pcsrc,
#                        alusrc, regdst, regwrite, jump, alucontrol);
#
#  datapath dp (clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,
#                          alucontrol, zero, pc, instr, dataadr, writedata, readdata);
#
#endmodule

#module controller(input  logic[5:0] op, funct,
#                  input  logic     zero,
#                  output logic     memtoreg, memwrite,
#                  output logic     pcsrc, alusrc,
#                  output logic     regdst, regwrite,
#                  output logic     jump,
#                  output logic[2:0] alucontrol);
#
#   logic [1:0] aluop;
#   logic       branch;
#
#   maindec md (op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, 
#		 jump, aluop);
#
#   aludec  ad (funct, aluop, alucontrol);
#
#   assign pcsrc = branch & zero;
#
#endmodule

#module aludec (input    logic[5:0] funct,
#               input    logic[1:0] aluop,
#               output   logic[2:0] alucontrol);
#  always_comb
#    case(aluop)
#      2'b00: alucontrol  = 3'b010;  // add  (for lw/sw/addi)
#      2'b01: alucontrol  = 3'b110;  // sub   (for beq)
#      default: case(funct)          // R-TYPE instructions
#          6'b100000: alucontrol  = 3'b010; // ADD
#          6'b100010: alucontrol  = 3'b110; // SUB
#          6'b100100: alucontrol  = 3'b000; // AND
#          6'b100101: alucontrol  = 3'b001; // OR
#          6'b101010: alucontrol  = 3'b111; // SLT
#          default:   alucontrol  = 3'bxxx; // ???
#        endcase
#    endcase
#endmodule

#module datapath (input  logic clk, reset, memtoreg, pcsrc, alusrc, regdst,
#                 input  logic regwrite, jump, 
#		 input  logic[2:0]  alucontrol, 
#                 output logic zero, 
#		 output logic[31:0] pc, 
#	         input  logic[31:0] instr,
#                 output logic[31:0] aluout, writedata, 
#	         input  logic[31:0] readdata);
#
#  logic [4:0]  writereg;
#  logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
#  logic [31:0] signimm, signimmsh, srca, srcb, result;
# 
#  // next PC logic
#  flopr #(32) pcreg(clk, reset, pcnext, pc);
#  adder       pcadd1(pc, 32'b100, pcplus4);
#  sl2         immsh(signimm, signimmsh);
#  adder       pcadd2(pcplus4, signimmsh, pcbranch);
#  mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc,
#                      pcnextbr);
#  mux2 #(32)  pcmux(pcnextbr, {pcplus4[31:28], 
#                    instr[25:0], 2'b00}, jump, pcnext);
#
#// register file logic
#   regfile     rf (clk, regwrite, instr[25:21], instr[20:16], writereg,
#                   result, srca, writedata);
#
#   mux2 #(5)    wrmux (instr[20:16], instr[15:11], regdst, writereg);
#   mux2 #(32)  resmux (aluout, readdata, memtoreg, result);
#   signext         se (instr[15:0], signimm);
#
#  // ALU logic
#   mux2 #(32)  srcbmux (writedata, signimm, alusrc, srcb);
#   alu         alu (srca, srcb, alucontrol, aluout, zero);
#
#endmodule


#module regfile (input    logic clk, we3, 
#                input    logic[4:0]  ra1, ra2, wa3, 
#                input    logic[31:0] wd3, 
#                output   logic[31:0] rd1, rd2);
#
#  logic [31:0] rf [31:0];
#
#  // three ported register file: read two ports combinationally
#  // write third port on rising edge of clock. Register0 hardwired to 0.
#
#  always_ff
#     if (we3) 
#         rf [wa3] <= wd3;	
#
#  assign rd1 = (ra1 != 0) ? rf [ra1] : 0;
#  assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;
#
#endmodule


#module alu(input  logic [31:0] a, b, 
#           input  logic [2:0]  alucont, 
#           output logic [31:0] result,
#           output logic zero);
#
#  // details of the model need to be 
#  // filled in by you, the designer !
#endmodule


#module adder (input  logic[31:0] a, b,
#              output logic[31:0] y);
#     
#     assign y = a + b;
#endmodule

#module sl2 (input  logic[31:0] a,
#            output logic[31:0] y);
#     
#     assign y = {a[29:0], 2'b00}; // shifts left by 2
#endmodule

#module signext (input  logic[15:0] a,
#                output logic[31:0] y);
#              
#  assign y = {{16{a[15]}}, a};    // sign-extends 16-bit a
#endmodule

#// parameterized register
#module flopr #(parameter WIDTH = 8)
#              (input logic clk, reset, 
#	       input logic[WIDTH-1:0] d, 
#               output logic[WIDTH-1:0] q);

#  always_ff@(posedge clk, posedge reset)
#    if (reset) q <= 0; 
#    else       q <= d;
#endmodule


#// paramaterized 2-to-1 MUX
#module mux2 #(parameter WIDTH = 8)
#             (input  logic[WIDTH-1:0] d0, d1,  
#              input  logic s, 
#              output logic[WIDTH-1:0] y);
#  
#  assign y = s ? d1 : d0; 
#endmodule

