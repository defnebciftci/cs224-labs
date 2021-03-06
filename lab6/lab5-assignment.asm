.data
dimension:	.space 4
size:		.space 4
array:	        .space 4
stringfirstInput: .asciiz "Enter the matrix size: "
stringsecInput: .asciiz "Enter the row of the number you want to get: "
string3rdInput: .asciiz "Enter the column of the number you want to get: "
firstOutput:	.asciiz "The number on the (row, column) you wanted: "
rowSum:		.space 4
colSum:		.space 4
comma:		.asciiz ", "
ikinokta:	.asciiz ": "
rowSumPrint:	.asciiz "The summation result done through row-major summation: "
colSumPrint:	.asciiz "The summation result done through column-major summation: "
.text
main:	la $a0, stringfirstInput
	li $v0, 4
	syscall
	li   $v0, 5
	syscall	#gets input for matrix dimension
	sw   $v0, dimension
check:	ble  $v0, 0, main	
	addi $sp, $sp, -8
	sw   $s0, ($sp) #s0 is a temp for dimension
	sw   $s1, 4($sp) #s0 is a temp for size
	lw   $s0, dimension

	multu $s0, $s0
	mflo  $s1 
	sll   $s1, $s1, 2
	sw    $s1, size
	
	li   $v0, 9
	lw   $a0, size
	syscall
	sw   $v0, array
	
	lw   $t0, dimension #column
	addi $t0, $t0, 1
	lw   $a0, array #address
	li   $s1, 0
	j    addValuesToCol
goBack:
	la $a0, stringsecInput
	li $v0, 4
	syscall
	li   $v0, 5
	syscall
	move $t0, $v0 #row
	
	la $a0, string3rdInput
	li $v0, 4
	syscall
	li   $v0, 5
	syscall
	move $t1, $v0 #column
	
	#address is ((column - 1) x N  + (row - 1))*4
	addi $t1, $t1, -1 #column - 1
	lw   $t2, dimension
	mult $t1, $t2
	mflo $t1 #(column - 1) * N
	addi $t0, $t0, -1 #row - 1
	add  $t0, $t0, $t1 #(column - 1) x N  + (row - 1)
	sll  $t0, $t0, 2   #times 4
	
	lw   $a0, array #we get the array address
	add  $a0, $a0, $t0 #the address of the element wanted
	lw   $t0, ($a0)
	la   $a0, firstOutput
	li   $v0, 4
	syscall
	move $a0, $t0
	li   $v0, 1
	syscall
	
rowMajorsumm:
	lw   $a0, array #get the array address
	addi $a0, $a0, -4
	li   $a1, 0
	li   $t0, 0 #row
	addi $t0, $t0, -1
	lw   $t2, dimension
	mul $t3, $t2, 4 #this is how many we will go up every time inside row major summation
	li   $s0, 0 #for sum
	li   $s1, 0 #for each number
	j    rowMajorLoopUpper

colMajorsumm:
	lw   $a0, array #get the array address
	li   $t0, 0 #col
	addi $t0, $t0, -1
	lw   $t2, dimension
	li   $s0, 0 #for sum
	li   $s1, 0 #for each number
	j    colMajorLoopUpper

goBackToSum:
	sw   $s0, rowSum
	la $a0, rowSumPrint
	li $v0, 4
	syscall
	
	move $a0, $s0
	li $v0, 1
	syscall
	
	lw   $a0, array
	addi $a0, $a0, -4
	j colMajorsumm
goBackToColSum:
	sw $s0, colSum
	la $a0, colSumPrint
	li $v0, 4
	syscall
	
	move $a0, $s0
	li $v0, 1
	syscall
	
	j  display

rowMajorLoopUpper: #buray� tekrar yap
	li   $t1, 0 #column
	addi $t0, $t0, 1
	addi $a0, $a0, 4
	move $a1, $a0
	
	bne  $t0, $t2, rowMajorLoopInner
	beq  $t0, $t2, goBackToSum
	rowMajorLoopInner:
		lw   $s1, ($a1)
		add  $s0, $s0, $s1
		add  $a1, $a1, $t3
		addi $t1, $t1, 1
		bne  $t1, $t2, rowMajorLoopInner
		beq  $t1, $t2, rowMajorLoopUpper
		
colMajorLoopUpper: #row keeps repeating, col is increasing
	li   $t1, 0 #row
	addi $t0, $t0, 1
	bne  $t0, $t2, colMajorLoopInner
	beq  $t0, $t2, goBackToColSum
	colMajorLoopInner:
		lw   $s1, ($a0)
		add  $s0, $s0, $s1
		addi $a0, $a0, 4
		addi $t1, $t1, 1
		bne  $t1, $t2, colMajorLoopInner
		beq  $t1, $t2, colMajorLoopUpper
		
display:
	lw   $a1, array #get the address
	lw   $t2, dimension
	li   $t0, 0 #row
	addi $sp, $sp, -12
	sw   $s0, ($sp)
	sw   $s1, ($sp)
	sw   $s2, ($sp)
	addi $s2, $t2, 1
#	ikinokta comma line
	loop:
		li   $t1, 1 #column
		addi $t0, $t0, 1
		bne  $t0, $s2, innerloop
		beq  $t0, $s2, end
		innerloop:
			move $s0, $t0
			move $s1, $t1
			jal  calcAddr #address is passed in s0
			
			li $a0, 0xA #to get a new line
        		li $v0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
        		syscall
			move $a0, $t0
			li   $v0, 1
			syscall
			la   $a0, comma
			li   $v0, 4
			syscall
			move $a0, $t1
			li   $v0, 1
			syscall
			la   $a0, ikinokta
			li   $v0, 4
			syscall
			
			add $s0, $s0, $a1
			
			lw   $a0, ($s0)
			li   $v0, 1
			syscall
			
			addi $t1, $t1, 1
			bne  $t1, $s2, innerloop
			beq  $t1, $s2, loop
calcAddr:
	#address is ((column - 1) x N  + (row - 1))*4
	addi $s1, $s1, -1 #column - 1
	mul $s1, $s1, $t2 #(column - 1) * N
	addi $s0, $s0, -1 #row - 1
	add  $s0, $s0, $s1 #(column - 1) x N  + (row - 1)
	sll  $s0, $s0, 2   #times 4
	jr $ra

end:	li $v0, 10
	syscall