# Lab1


## 练习1
load address，将栈指针（sp）的值设置为 bootstacktop 标签的地址  
为内核设置初始栈，以便内核代码可以使用栈来执行操作和保存状态  

tail 尾调用指令，与普通的 jal 指令不同，主要特点是在调用函数之前，将当前函数的返回地址设置为目标函数的地址  
在执行 tail kern_init 后，不会在当前函数的返回地址寄存器 ra 中保存返回地址，而是直接跳转到 kern_init 函数，从而避免了额外的返回地址保存和加载操作（不再返回，不占用栈）

## 练习2  
```C
clock_set_next_event();
if(++ticks % TICK_NUM == 0) {
    print_ticks();
    num++;
    if(num==10){
        sbi_shutdown();
    }
}
```

## Challenge1
以时钟中断为例，调用clock_init()函数->调用set_csr()函数将sie中的时钟中断使能打开->调用sbi_set_timer()函数，在time达到timebase时发生中断，进入中断入口->先保存现场，然后进入trap.c执行trap_dispatch()函数->恢复现场->结束  

将栈顶指针做为参数放入a0，传入trap函数，让trap函数读取trapframe  

struct结构体连续存储，地址连续，从栈顶/首地址指针通过偏移寻址

不需要，在恢复现场的时候，对于控制状态寄存器的四个寄存器status,epc,badaddr,cause只恢复了其中的status和epc寄存器  
因为badaddr寄存器和cause寄存器中保存的分别是出错的地址以及出错的原因，处理完这个中断后，不再需要这两个寄存器中保存的值，所以可以不用恢复这两个寄存器  
另外x0->Hard-wired zero永远保存的是0，也可以不用保存/恢复


## Challenge2
CSR Write将SP保存进临时寄存器，后续从临时器读出sp给s0用于store并把临时寄存器置0  
目的是将x2寄存器/sp的值存入trapframe中，以便恢复现场  

badaddr寄存器和cause寄存器中保存的分别是出错的地址以及出错的原因，处理完这个中断后，不再需要这两个寄存器中保存的值  
store存进trapframe里是为了让内核读取这些CSR（trap.c调用进而分发异常/中断）


## Challenge3