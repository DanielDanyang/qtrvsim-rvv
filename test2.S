.globl _start

.text


_start:

# 初始化 A 矩阵
    li x1, 0             # A 矩阵的起始地址
    li x2, 920           # A 矩阵元素数量 (20 x 46)
    li x3, 2             # 要存入的值

Loop_A_Init:
    bgez x2, Init_A_Body # 如果 x2 >= 0，进入初始化主体
    j Init_B             # 否则跳转到初始化 B 矩阵
Init_A_Body:
    sw x3, 0x423(x1)     # 将 1 存入当前地址
    addi x1, x1, 4       # 地址后移 4 字节
    addi x2, x2, -1      # 计数器递减
    j Loop_A_Init        # 跳回循环

# 初始化 B 矩阵
Init_B:
    li x4, 0x400        # B 矩阵的起始地址
    li x5, 2300          # B 矩阵元素数量 (46 x 50)
    li x6, 3             # 要存入的值

Loop_B_Init:
    bgez x5, Init_B_Body # 如果 x5 >= 0，进入初始化主体
    j End_init        # 否则跳转到程序结束
Init_B_Body:
    sw x6, 0x423(x4)     # 将 1 存入当前地址
    addi x4, x4, 4       # 地址后移 4 字节
    addi x5, x5, -1      # 计数器递减
    j Loop_B_Init        # 跳回循环

End_init:

li x1, 0x843          # 向量1的起始地址
    vlw.v v1, 0(x11) 

li x10, 0x423
li x11, 0x823

li x8, 0


# 点乘模块
# 输入：
#   x10 - 向量1的起始地址
#   x11 - 向量2的起始地址
#   x9  - 向量长度（需要用 vsetvl 设置）
# 输出：
#   x8  - 存储点积结果
DotProduct:
    li x8, 0                  # 初始化点积结果为 0
    li t0, 32                 # 最大向量寄存器支持的长度

# 处理前32个元素
DotProduct_First32:
    vsetvl t1, t0, t0         # 设置向量长度为 32
    vlw.v v1, 0(x10)          # 从地址 x10 加载向量1到 v1
    vlw.v v2, 0(x11)          # 从地址 x11 加载向量2到 v2
    vmul.vv v3, v1, v2        # 逐元素相乘，结果存储到 v3
    li x1, 0x2900
    vsw.v v3, 0(x1)           # 存储 v3 到 x4

    # 累加前32个元素的点积
    li t2, 0                  # 临时累加器
    li t3, 0                  # 循环索引
DotProduct_Accumulation_32:
    bge t3, t0, DotProduct_Next14 # 如果索引 >= 32，跳转到处理后14个元素
    slli t4, t3, 2            # 偏移量 = 索引 * 4
    add t5, x1, t4            # 临时存储地址
    lw t6, 0(t5)              # 加载 v3 的元素
    add t2, t2, t6            # 累加到临时累加器
    addi t3, t3, 1            # 索引递增
    j DotProduct_Accumulation_32

DotProduct_Next14:
    add x8, x8, t2            # 将前32个元素的结果累加到 x8
    addi x10, x10, 128        # 向量1地址后移 32 个元素
    addi x11, x11, 128        # 向量2地址后移 32 个元素
    li t0, 14                 # 剩余14个元素

# 处理后14个元素
DotProduct_Last14:
    vsetvl t1, t0, t0         # 设置向量长度为 14
    vlw.v v1, 0(x10)          # 加载向量1剩余部分到 v1
    vlw.v v2, 0(x11)          # 加载向量2剩余部分到 v2
    vmul.vv v3, v1, v2        # 逐元素相乘，结果存储到 v3
    li x1, 0x2900
    vsw.v v3, 0(x1)           # 存储 v3 到 x4

    # 累加后14个元素的点积
    li t2, 0                  # 临时累加器
    li t3, 0                  # 循环索引
DotProduct_Accumulation_14:
    bge t3, t0, DotProduct_End # 如果索引 >= 14，结束点积计算
    slli t4, t3, 2            # 偏移量 = 索引 * 4
    add t5, x1, t4            # 临时存储地址
    lw t6, 0(t5)              # 加载 v3 的元素
    add t2, t2, t6            # 累加到临时累加器
    addi t3, t3, 1            # 索引递增
    j DotProduct_Accumulation_14

DotProduct_End:
    add x8, x8, t2            # 将后14个元素的结果累加到 x8






    nop
    nop
    ebreak

.data
