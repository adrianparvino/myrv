li x1, 1024
li x2, 0
li x3, 1
1:
add x2, x2, x3
sw x2, 0(x1)
add x3, x3, x2
sw x3, 0(x1)
beq x0, x0, 1b

