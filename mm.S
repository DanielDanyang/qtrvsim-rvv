    .data
    .align 4

m:      .word 20              # Number of rows in A and C
n:      .word 46              # Number of columns in A and rows in B
p:      .word 50              # Number of columns in B and C

A:      .space 20*46*4        # Matrix A (20x46)
B:      .space 46*50*4        # Matrix B (46x50)
BT:     .space 50*46*4        # Transposed Matrix B (50x46)
C:      .space 20*50*4        # Result Matrix C (20x50)
vtemp:  .space 46*4           # Temporary buffer for vector elements

    .text
    .global _start

_start:
    # Initialize matrices A and B
    la      s0, A             # Load address of A into s0
    la      s1, B             # Load address of B into s1

    li      t0, 0             # i = 0
init_A:
    li      t1, 0             # k = 0
init_A_row:
    # A[i][k] = i + k
    add     t2, t0, t1
    sw      t2, 0(s0)
    addi    s0, s0, 4         # Move to next element
    addi    t1, t1, 1
    li      t3, 46
    blt     t1, t3, init_A_row
    addi    t0, t0, 1
    li      t4, 20
    blt     t0, t4, init_A

    li      t0, 0             # k = 0
init_B:
    li      t1, 0             # j = 0
init_B_row:
    # B[k][j] = k + j
    add     t2, t0, t1
    sw      t2, 0(s1)
    addi    s1, s1, 4         # Move to next element
    addi    t1, t1, 1
    li      t3, 50
    blt     t1, t3, init_B_row
    addi    t0, t0, 1
    li      t4, 46
    blt     t0, t4, init_B

    # Transpose matrix B into BT
    la      s0, B
    la      s1, BT
    li      t0, 0             # k = 0
transpose_B:
    li      t1, 0             # j = 0
transpose_B_row:
    # Calculate source address in B
    li      t2, 50
    mul     t3, t0, t2        # t3 = k * 50
    add     t3, t3, t1        # t3 = k * 50 + j
    slli    t3, t3, 2         # t3 *= 4 (byte offset)
    add     s2, s0, t3        # s2 = &B[k][j]
    lw      t4, 0(s2)         # t4 = B[k][j]
    # Calculate destination address in BT
    li      t5, 46
    mul     t6, t1, t5        # t6 = j * 46
    add     t6, t6, t0        # t6 = j * 46 + k
    slli    t6, t6, 2         # t6 *= 4
    add     s3, s1, t6        # s3 = &BT[j][k]
    sw      t4, 0(s3)
    addi    t1, t1, 1
    li      t7, 50
    blt     t1, t7, transpose_B_row
    addi    t0, t0, 1
    li      t8, 46
    blt     t0, t8, transpose_B

    # Perform matrix multiplication C = A * B
    li      t0, 0             # i = 0
mat_mul_i:
    li      t1, 0             # j = 0
mat_mul_j:
    li      s4, 0             # sum = 0
    li      t2, 0             # k = 0
mat_mul_k:
    # Set vector length
    li      t3, 46            # Total elements in k dimension
    sub     t4, t3, t2        # Remaining elements
    li      t5, 8             # Max vector length
    blt     t4, t5, set_vl
    mv      t6, t5
    j       set_vl_done
set_vl:
    mv      t6, t4
set_vl_done:
    li      t7, 32            # Element width (32-bit)
    # Set vector length and type (element width)
    vsetvl  zero, t6, t7

    # Load vector from A
    la      s5, A
    li      t8, 46            # Columns in A
    mul     t9, t0, t8        # t9 = i * 46
    add     t9, t9, t2        # t9 += k
    slli    t9, t9, 2         # Byte offset
    add     s6, s5, t9        # s6 = &A[i][k]
    vlw.v   v0, (s6)

    # Load vector from BT
    la      s7, BT
    li      t10, 46           # Columns in BT
    mul     t11, t1, t10      # t11 = j * 46
    add     t11, t11, t2      # t11 += k
    slli    t11, t11, 2       # Byte offset
    add     s8, s7, t11       # s8 = &BT[j][k]
    vlw.v   v1, (s8)

    # Perform element-wise multiplication
    vmul.vv v2, v0, v1        # v2 = v0 * v1

    # Store v2 to memory
    la      s9, vtemp         # Load address of temporary buffer
    vsw.v   v2, (s9)          # Store v2 to memory

    # Sum up the elements of v2
    li      t17, 0            # Index i = 0
    li      t18, 0            # temp_sum = 0
sum_loop:
    lw      t19, 0(s9)        # Load element vtemp[i]
    add     t18, t18, t19     # temp_sum += vtemp[i]
    addi    s9, s9, 4         # Move to next element
    addi    t17, t17, 1
    blt     t17, t6, sum_loop # Loop until i < vl

    # Accumulate sum
    add     s4, s4, t18       # sum += temp_sum

    # Increment k
    add     t2, t2, t6        # k += vl
    li      t12, 46
    blt     t2, t12, mat_mul_k

    # Store result in C[i][j]
    la      s10, C
    li      t13, 50
    mul     t14, t0, t13      # t14 = i * 50
    add     t14, t14, t1      # t14 += j
    slli    t14, t14, 2       # Byte offset
    add     s11, s10, t14     # s11 = &C[i][j]
    sw      s4, 0(s11)

    # Increment j
    addi    t1, t1, 1
    li      t15, 50
    blt     t1, t15, mat_mul_j

    # Increment i
    addi    t0, t0, 1
    li      t16, 20
    blt     t0, t16, mat_mul_i

    # Exit program
    li      a0, 0
    li      a7, 93
    ecall
