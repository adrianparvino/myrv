count:
li x2, 1024
li x3, 1024
1:
sb  x1, 0(x2)
addi x1, x1, 1
blt x1, x3, 1b
sub x1, x1, x1
sb  x1, 0(x2)
2:
beq x0, x0, 2b

shift:
li x1, 1024
li x2, 1
1:
sb x2, 0(x1)
slli x2, x2, 1
bne x2, x0, 1b
2:
beq x0, x0, 2b

asr:
li x1, 1024
li x2, 0x80000000
li x3, -1
1:
sb x2, 0(x1)
srai x2, x2, 1
bne x2, x3, 1b
2:
j 2b

