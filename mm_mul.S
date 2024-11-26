.globl _start

.text

_start:

    li x1, 0            
    li x2, 920           
    li x3, 2             

Loop_A_Init:
    bgez x2, Init_A_Body 
    j Init_B             
Init_A_Body:
    sw x3, 0x423(x1)     
    addi x1, x1, 4       
    addi x2, x2, -1      
    j Loop_A_Init        

Init_B:
    li x4, 0x843       
    li x5, 2300          
    li x6, 4             

Loop_B_Init:
    bgez x5, Init_B_Body 
  
    j Matrix_Multiply    
Init_B_Body:
    sw x6, 0(x4)     
    addi x4, x4, 4       
    addi x5, x5, -1      
    j Loop_B_Init      


Matrix_Multiply:
    li x7, 20             
    li x8, 50             
    li x9, 46             
    li x12, 0 
    li x20, 0x2503         


Loop_i:
    bge x12, x7, End_Program 
    li x13, 0              

Loop_j:
    bge x13, x8, Next_i    

    li x10, 0x423          
    mul x14, x12, x9       
    slli x14, x14, 2       
    add x10, x10, x14      

    li x11, 0x2003         
    li x15, 0              

Loop_Column:
    blt x15, x9, Column_Body   
    j End_Column               

Column_Body:
    li x16, 0                
    mul x16, x13, x8           
    add x16, x16, x15          
    slli x16, x16, 2           
    li x17, 0x843              
    add x16, x16, x17          
    lw x18, 0(x16)             
    sw x18, 0(x11)             
    addi x11, x11, 4           
    addi x15, x15, 1           
    j Loop_Column              

End_Column:
    j Compute_DotProduct       

Compute_DotProduct:
    li x11, 0x2003             

DotProduct:
    li x8, 0                  
    li t0, 32                 

DotProduct_First32:
    vsetvl t1, t0, t0         
    vlw.v v1, 0(x10)          
    vlw.v v2, 0(x11)          
    vmul.vv v3, v1, v2        
    li x1, 0x3903
    vsw.v v3, 0(x1)           

    li t2, 0                  
    li t3, 0                  
DotProduct_Accumulation_32:
    bge t3, t0, DotProduct_Next14 
    slli t4, t3, 2            
    add t5, x1, t4            
    lw t6, 0(t5)              
    add t2, t2, t6            
    addi t3, t3, 1            
    j DotProduct_Accumulation_32

DotProduct_Next14:
    add x8, x8, t2            
    addi x10, x10, 128        
    addi x11, x11, 128        
    li t0, 14                 

DotProduct_Last14:
    vsetvl t1, t0, t0         
    vlw.v v1, 0(x10)          
    vlw.v v2, 0(x11)          
    vmul.vv v3, v1, v2        
    li x1, 0x3903
    vsw.v v3, 0(x1)           

    li t2, 0                  
    li t3, 0                  
DotProduct_Accumulation_14:
    bge t3, t0, DotProduct_End 
    slli t4, t3, 2            
    add t5, x1, t4            
    lw t6, 0(t5)              
    add t2, t2, t6            
    addi t3, t3, 1            
    j DotProduct_Accumulation_14

DotProduct_End:
    add x8, x8, t2            

    sw x8, 0(x20)          

    vlw.v v9, 0(x20)       

    addi x20, x20, 4       

    addi x13, x13, 1       
    j Loop_j

Next_i:
    addi x12, x12, 1       
    j Loop_i

End_Program:
    nop
    nop
    ebreak

.data
