# lab4
- [lab4](#lab4)
  - [练习1：分配并初始化一个进程控制块](#练习1分配并初始化一个进程控制块)
    - [proc\_struct中context和trapframe成员变量含义及作用](#proc_struct中context和trapframe成员变量含义及作用)
  - [练习2：为新创建的内核线程分配资源](#练习2为新创建的内核线程分配资源)
    - [ucore是否做到给每个新fork的线程一个唯一的id](#ucore是否做到给每个新fork的线程一个唯一的id)
  - [练习3：编写proc\_run函数](#练习3编写proc_run函数)
    - [在本实验的执行过程中，创建且运行了几个内核线程](#在本实验的执行过程中创建且运行了几个内核线程)
  - [Challenge](#challenge)

## 练习1：分配并初始化一个进程控制块
`alloc_proc`函数负责分配并返回一个新的`struct proc_struct`结构，用于存储新建立的内核线程的管理信息。本次实验主要完善该函数对`proc_struct`结构体的初始化工作。  
实现并不复杂，特别是在`proc_int`函数中对`proc_struct`的检查已经将初始化值列出，只需要对照进行赋值即可。
```c
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
    ){
        cprintf("alloc_proc() correct!\n");
    }
```

```c
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {

    //LAB4:EXERCISE1 YOUR CODE
    proc->state = PROC_UNINIT;
    proc->pid = -1;
    proc->runs = 0;
    proc->kstack = 0;
    proc->need_resched = 0;
    proc->parent = NULL;
    proc->mm = NULL;
    memset(&(proc->context), 0, sizeof(struct context));
    proc->tf = NULL;
    proc->cr3 = boot_cr3;
    proc->flags = 0;
    memset(proc->name, 0, PROC_NAME_LEN);
    }
    return proc;
}
```

### proc_struct中context和trapframe成员变量含义及作用
`context`保存了`ra`、`sp`、`s0-s11`共十四个寄存器。这些只是`caller-saved`寄存器，而`callee-saved`寄存器在调用`switch_to`函数时，由编译器自动帮助保存。  
本次实验中，`context`的作用是保存`forkret`函数的返回地址，以及`forkret`函数的参数`struct trapframe`。  
在`copy_thread`函数里，有如下代码：
```c
    proc->context.ra = (uintptr_t)forkret;  // switch_to后返回到forkret，forkret再去trapret
    proc->context.sp = (uintptr_t)(proc->tf);  // switch_to将context的寄存器复原，但这里其实冗余了，因为forkret会传参给sp
```

`switch_to`函数执行后，`ra`寄存器值变为`context.ra`，接着就会跳转到`forkret`函数。  
到了`forkret`就意味着这次**进程切换已经完成**，`context`的使命结束，接着就是进入`trapret`恢复用户态/中断恢复。  

`trapframe`保存了**进程的中断帧**，是从用户态进入内核态时进程的状态，包含通用寄存器和中断时的特殊系统寄存器。

```c
struct trapframe {
    struct pushregs gpr;
    uintptr_t status;
    uintptr_t epc;
    uintptr_t badvaddr;
    uintptr_t cause;
};
```

在本次实验中，`trapframe`的作用是保存`kernel_thread_entry`函数的地址以及参数，即`fn`和`arg`。  
在`kernel_thread`函数中，将通用寄存器`s0`和`s1`赋值为了`fn`和`arg`，`epc`设置为`kernel_thread_entry`的返回地址，并设置了`status`寄存器调整中断设置。
```c
    // 设置内核线程要执行的函数指针及参数
    tf.gpr.s0 = (uintptr_t)fn;  // 函数指针
    tf.gpr.s1 = (uintptr_t)arg;  // 函数参数
    // 设置SSTATUS寄存器：supervisor，启用中断(回到U态/中断结束)，关闭中断(S态下/中断时)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    // 设置入口点，会去调用fn
    tf.epc = (uintptr_t)kernel_thread_entry;
```

`forkret`函数会将`trapframe`放到栈顶，接着进入`trapret`函数。`trapret`进行一次`RESTORE_ALL`操作，把`trapframe`中的值恢复到CPU寄存器中。然后通过`epc`跳转到`kernel_thread_entry`函数，调用`s0`寄存器里保存的`fn`函数，至此就**完成了中断恢复**，CPU接着在对应态下执行`fn`函数。


## 练习2：为新创建的内核线程分配资源

### ucore是否做到给每个新fork的线程一个唯一的id

## 练习3：编写proc_run函数

### 在本实验的执行过程中，创建且运行了几个内核线程

## Challenge