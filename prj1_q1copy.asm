#Marcus Ensley 1574206 456Frodo

#memoization 

.data 
inputString: .asciiz "user input value = "
outputString: .asciiz "the Fibonacci number is "
endString: .asciiz "\n"

.text
.globl main

main:
addi $sp, $sp, -4
sw $ra, 0($sp) 

#parse string from console
addi $a0, $gp, 4 #set string 1 away from gp
addi $a1, $zero, 5 #set string length to 3
addi $v0, $zero, 8 # 8 syscall code for reading string
syscall

#change string to int and put in a0
addi $t0, $gp, 4 #set t0 to point to string
addi $s0, $zero, 10 #set s0 to ten for mult 
add $a0, $zero, $zero
load:
lbu $t1, 0($t0) #load byte from string in t1
beq $t1, 10, stringDone 
mult $a0, $s0 #a0 times 10
mflo $a0 #move product into a0
addi $t2, $t1, -48 #t2 decimal value of number
add $a0, $a0, $t2 #add value to a0
addi $t0, $t0, 1 #incrument gp pointer
j load

stringDone:
#call inputString
add $t0, $a0, $zero #protect a0 in t0
la $a0, inputString #store string in a0
addi $v0, $zero, 4 #syscall for print string
syscall
add $a0, $t0, $zero #put t0 in a0
addi $v0, $zero, 1
syscall 
la $a0, endString #store endString in a0
addi $v0, $zero, 4 #syscall for print string
syscall
add $a0, $t0, $zero #put t0 in a0

#check to see overflow if not call fibo
slti $t0, $a0, 48 #if input is less than 48 return 1
beq $t0, $zero, overflow #if input is greater than 48 return -1

#no overflow call fibo
jal fibo #jump to fibo and put ra in the stack
#printOutput
la $a0, outputString #load string in a0
addi $v0, $zero, 4 #syscall for print string
syscall
add $a0, $v1, $zero #set a0 to return value
addi $v0, $zero, 1 #syscall value
syscall
la $a0, endString #store string in a0
addi $v0, $zero, 4 #syscall value for print string
syscall

lw $ra, 0($sp) 
addi $sp, $sp, 4
jr $ra 

#if overflow return -1
overflow: 
#print -1
la $a0, outputString #load string in a0
addi $v0, $zero, 4 #syscall for print string
syscall
addi $a0, $zero, -1
addi $v0, $zero, 1 
syscall
la $a0, endString #store string in a0
addi $v0, $zero, 4 #syscall value for print string
syscall
lw $ra 0($sp)
addi $sp, $sp, 4
jr $ra 

fibo: 
#f(n) = f(n-1) + f(n-2) 
# 1 add 1
# 0 add 0
#set up stack
addi $sp, $sp, -24 #move stack pointer down 12
sw $ra, 0($sp) #store ra in the stack
sw $s3, 4($sp) # store s3 in the stack
sw $s4, 8($sp) # store s4 in the stack
sw $t0, 12($sp) #store t0 in the stack	
sw $t1, 16($sp)#store t1 in the stack
sw $t2, 20($sp) #store t2 in the stack

#check to see if f(n) has been completed
add $s3, $a0, $zero #s3 is equal to input n
sll $t0, $s3, 2 #t0 is the byte amount of input n
add $t1, $gp, $t0 #location of the nth fib number
addi $t1, $t1, 20 #offset gp by ten 
lw $t2, 0($t1)
bne $t2, $zero, getResult

beq $s3, 2, two #if input is equal to 1 add 1
beq $s3, 1 , one #if input is equal to 0 add 0

addi $a0, $s3, -1 #decrement s3 by one, make it input
jal fibo 

add $s4, $v1, $zero #s4 is equal to fib(n-1)

addi $a0, $s3, -2 #decrement s3 by two, make it an input
jal fibo

add $v1, $v1, $s4 #v0 is equal to fib(n-2) + fib(n-1)
sw $v1, 0($t1) #store result in table 
j return 

two:
addi $v1, $zero, 1 #make return value 1
j return

one:
add $v1, $zero, $zero #make return value 0
j return

getResult:
add $v1, $t2, $zero #return f(n) 
j return

return: 
#restore stack
lw $ra, 0($sp) #load ra from stack
lw $s3, 4($sp) #load s3 from stack
lw $s4, 8($sp) #load s4 from stack
lw $t0, 12($sp)
lw $t1, 16($sp)
lw $t2, 20($sp) 
addi $sp, $sp, 24 #restore stack pointer 
jr $ra #jump to previous call


