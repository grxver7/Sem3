.data
size: .space 4
i: .word 2
j: .space 4
min_idx: .space 4
startaddress: .space 4
tmp: .float 1

string_input: .asciiz "Enter the number of elements <size>."
output_printArr: .asciiz "Array: \n"
endl: .asciiz "\n"
space: .asciiz " "

# float inputs
const1: .float 0.0 # arr[0]
const2: .float -1.0 # arr[1]
conss3: .float 2.0  # pow(-1, i) / 2.0;
const4: .float -1.0 # pow(-1, i)
const5: .float 1.0 # pow(-1, i)

.text
.globl main

main:
    #registrys
    #$s1 = size
    #$s2 = startaddress
    #$s3 = i
    #$s4 = j

    #Input Introductionstring
    li $v0, 4
    la $a0, string_input
    syscall

    li $v0, 4
    la $a0, endl
    syscall

    #Input Read float x
    li $v0, 5           # Read float (6)
    syscall
    sw $v0, size        # Store integer input in 'size' variable

    # allocate memory for arr[size]
    lw $s1, size        # get size
    mul $s1, $s1, 4   # 4*size 

    li $v0, 9           # allocate memory
    move $a0, $s1       # pass size of 'size'
    syscall
    move $s2, $v0       # startaddress of arr[size]
    addi $s2, $s2, 4
    sw $s2, startaddress

    # call methods
    jal fillArray
    jal printArray
    jal selectionSort
    jal printArray

    j exit              # end programm

fillArray:
    l.s $f1, const1     # arr[0] = +0.0
    swc1 $f1, ($s2)     

    l.s $f2, const2
    swc1 $f2, 4($s2)    # arr[1] = -1.0

    lw $s3, i
    lw $s1, size
    lw $s2, startaddress

for0: # (int i=2; i<size; i++)
    bge $s3, $s1, end   # for i<size

    # address[i]
    mul $t4, $s3, 4   # address=i*4

    add $t4, $s2, $t4   # adress arr[0] + 4*i

    # arr[i-1] + arr[i-2]=$f6
    l.s $f4,  -4($t4)         # $f4 = arr[i-1]
    l.s $f5, -8($t4)          # $f5 = arr[i-2]
    add.s $f6, $f4, $f5        # arr[i-1] + arr[i-2]

    li $t5, 0
    l.s $f1, const5             # =-1, is possible because $f1 is free now
    j pow

pow:
    # pow(-1, i) / 2.0
    l.s $f7, const4               # =-1
    bge $t5, $s3, continue0
    mul.s $f1, $f1, $f7           # -1^i

    addi $t5, $t5, 1
    j pow

continue0: 
    l.s $f8, conss3             # =2.0
    div.s $f8, $f1, $f8         # (-1^i)/2.0

    mul.s $f8, $f6, $f8        # (arr[i-1] + arr[i-2]) * pow(-1, i) / 2.0;
    # store arr[i]
    swc1 $f8, ($t4)     # store under adress i
    addi $s3, $s3, 1    # i++
    j for0
    
printArray:
    li $v0, 4
    la $a0, output_printArr   # print Array:
    syscall

    li $s3, 0
    sw $s3, i                 # safe new i-value in memory
    lw $s1, size              # load size from memory  
    lw $s2, startaddress       # load startaddress from memory
    j for1

for1: #(i = 0; i < size; i++) 
    bge $s3, $s1, continue1   # for i<size

    # arr[i]
    move $t4, $s3
    mul $t4, $s3, 4     # address=i*4
    add $t4, $s2, $t4   # adress arr[0] + 4*i

    lwc1 $f9, 0($t4)     # get value arr[i]

    li $v0, 2
    mov.s $f12, $f9     # print arr[i]
    syscall

    li $v0, 4
    la $a0, space       # print " "
    syscall

    addi $s3, $s3, 1    # i++
    j for1

continue1:
    li $v0, 4
    la $a0, endl        # print endl
    syscall
    j end

selectionSort:
    lw $s3, i               # load i from memory
    lw $s2, startaddress     # load startaddress from memory
    lw $s1, size            # load size from memory
    subi $t5, $s1, 1        # size-1
    j for2

for2: # (int i = 0; i < size - 1; i++) 
    bgt $s3, $t5, end   # for i<size-1

    sw $s3, min_idx           # min_idx = 1

    # start subFor
    sw $s3, j               # i=j
    lw $s4, j               # safe j
    j subFor2

subFor2: # (int j = i + 1; j < size; j++) 
    bge $s4, $s1, continueFor2   # for j<size

    # arr[j]
    move $t7, $s4
    mul $t7, $t7, 4   # address=j*4
    add $t7, $s2, $t7   # adress arr[0] + 4*j
    lwc1 $f1, 0($t7)     # get value arr[j]

    # arr[min_idx]
    lw $t6, min_idx       # $t6 is unused --> load min_idx from memory
    mul $t6, $t6, 4       # address=min_idx*4
    add $t6, $s2, $t6     # adress arr[0] + 4*min_idx
    lwc1 $f2, 0($t6)      # get value arr[min_idx]

    c.lt.s $f1, $f2
    bc1t if0SubFor2 #if (arr[j] < arr[min_idx])
    addi $s4, $s4, 1    # i++
    j subFor2

if0SubFor2:
    sw $s4, min_idx     # min_idx = j
    addi $s4, $s4, 1    # j++
    j subFor2

continueFor2:
    lw $t6, min_idx         # load min_idx from memory
    bne $t6, $s3, if0For2   # if (min_idx != i)   
    addi $s3, $s3, 1        # i=j+1
    j for2

if0For2: #if (min_idx != i)
    lw $t6, min_idx       # $t6 is unused --> write min_idx in it
    mul $t6, $t6, 4       # address=min_idx*4
    add $t6, $s2, $t6     # adress arr[0] + 4*min_idx
    lwc1 $f1, 0($t6)      # get value arr[min_idx]

    s.s $f1, tmp          # float tmp = arr[min_idx];

    move $t7, $s3         # $t7 is unused --> write i (still $s3) in $t7
    mul $t7, $t7, 4       # address=min_idx*4
    add $t7, $s2, $t7     # adress arr[0] + 4*min_idx
    lwc1 $f2, 0($t7)      # get value arr[i]

    swc1 $f2, 0($t6)       #arr[min_idx] = arr[i];
    l.s $f1, tmp
    swc1 $f1, 0($t7)       #arr[i] = tmp;   

    addi $s3, $s3, 1       # i=j+1
    j for2

end:
    jr $ra

exit:
    # Exit program
    li $v0, 10
    syscall