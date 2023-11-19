# lab4
- [lab4](#lab4)
  - [练习1：分配并初始化一个进程控制块](#练习1分配并初始化一个进程控制块)
    - [proc\_struct中context和trapframe成员变量含义及作用](#proc_struct中context和trapframe成员变量含义及作用)
  - [练习2：为新创建的内核线程分配资源](#练习2为新创建的内核线程分配资源)
    - [ucore是否做到给每个新fork的线程一个唯一的id](#ucore是否做到给每个新fork的线程一个唯一的id)
  - [练习3：编写proc\_run函数](#练习3编写proc_run函数)
    - [在本实验的执行过程中，创建且运行了几个内核线程](#在本实验的执行过程中创建且运行了几个内核线程)
  - [Challenge](#challenge)
  - [知识点分析](#知识点分析)
    - [重要知识点](#重要知识点)
    - [额外知识点](#额外知识点)

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
`context`保存了`ra`、`sp`、`s0-s11`共十四个寄存器。这些只是`callee-saved`寄存器，而`caller-saved`寄存器在调用`switch_to`函数时，由编译器自动帮助保存。  
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

```C
int 
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    // 进程数目超过了最大值，返回错误
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //1. call alloc_proc to allocate a proc_struct
    if((proc = alloc_proc()) == NULL){
        goto fork_out;
    }

    //2. call setup_kstack to allocate a kernel stack for child process
    if(setup_kstack(proc) != 0){
        goto bad_fork_cleanup_proc;  // 释放刚刚alloc的proc_struct
    }

    //3. call copy_mm to dup OR share mm according clone_flag
    if(copy_mm(clone_flags, proc) != 0){
        goto bad_fork_cleanup_kstack;  // 释放刚刚setup的kstack
    }

    //4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc, stack, tf);  // 复制trapframe，设置context

    //5. insert proc_struct into hash_list && proc_list
    proc->pid = get_pid();
    hash_proc(proc);  // 插入hash_list
    list_add(&proc_list, &(proc->list_link));  // 插入proc_list
    nr_process ++;

    //6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);  // 设置为RUNNABLE

    // 7. set ret vaule using child proc's pid
    ret=proc->pid;

fork_out:
    return ret;
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```
首先使用`alloc_proc`函数分配一个`proc_struct`结构体，然后使用`setup_kstack`函数为新进程分配内核栈，接着使用`copy_mm`函数复制父进程的内存管理信息，然后使用`copy_thread`函数复制父进程的`trapframe`，并设置`context`。最后使用`get_pid`函数为新进程分配一个唯一的进程号，将新进程插入到进程列表和哈希表中，并设置为`RUNNABLE`状态，返回新进程的进程号。

### ucore是否做到给每个新fork的线程一个唯一的id
ucore使用`get_pid`函数为新进程分配一个唯一的进程号。在其中使用了两个静态变量`last_pid`和`next_safe`。
`last_pid`用于记录上一个进程的进程号，`next_safe`用于维护最小的一个不可用进程号。
每一次进入`get_pid`后，可以直接从(`last_pid`,`next_safe`)这个开区间中直接获得一个可用的进程号，也就是`last_pid+1`，直到这个区间中不存在进程号，也就是`last_pid+1==next_safe`。此时，不断地在整个进程号空间中循环寻找可用进程号，直到找到一个可用的进程号，然后更新`last_pid`和`next_safe`，返回这个可用的进程号。

## 练习3：编写proc_run函数
编写的`proc_run`函数如下：
```c
void
proc_run(struct proc_struct *proc) {
    // 如果相同则不需要切换
    if (proc != current) {
        // 禁用中断
        bool intr_flag;
        struct proc_struct *prev = current;  // prev指向当前正在运行的进程
        local_intr_save(intr_flag);
        {
            // 切换当前进程为要运行的进程
            current = proc;
            // 切换页表
            lcr3(proc->cr3);
            // 切换上下文，只切换context，不使用tf
            switch_to(&(prev->context), &(proc->context));
        }
        local_intr_restore(intr_flag);

    }
}
```
首先需要判断要切换的进程是否正是当前运行的进程，如果是则不需要切换。  
随后记录当前运行的进程，通过`local_intr_save`禁用中断，为切换上下文做准备。  
接着将当前进程指针切换，再切换页表及上下文，即可运行新的进程。

### 在本实验的执行过程中，创建且运行了几个内核线程

运行了两个内核线程：

1. idle：这个内核线程的工作就是不停地查询，看是否有其他内核线程可以执行了，如果有，马上让调度器选择那个内核线程执行。在这个实验中，先启动idle，后设置init为runnable，便可以将运行权交给init进程。
2. init：该内核线程的工作就是显示“Hello World”，表明自己存在且能正常工作了，表明初始化进程的工作成功了。

## Challenge

查询到sync.h中，local_intr_save以及local_intr_restore的定义如下：
```c
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);
```

local_intr_save宏首先调用__intr_save()函数，这个函数会检查当前的中断状态（通过读取CSR寄存器的sstatus位）。如果中断是开启的（SSTATUS_SIE位为1），那么它会关闭中断（通过调用intr_disable()函数）并返回1；否则，它会返回0。这个返回值会被保存到intr_flag变量中。

local_intr_restore宏检查flag参数。如果flag为1表明的是原本中断时开启状态，那么它会开启中断（通过调用intr_enable()函数）。

所以，通过先调用local_intr_save，后调用local_intr_restore，从而在两者之间形成了临界区，临界区前保存中断位，临界区的代码在中断关闭的状态下运行，并在临界区代码执行完毕后恢复原来的中断状态。

## 知识点分析

### 重要知识点

- 上下文切换: 通过保存和恢复寄存器的值，实现进程的切换。在ucore中，上下文切换的实现是通过`switch_to`函数实现的。`switch_to`函数的参数是两个`struct context`结构体指针，分别指向当前进程和要切换的进程的`context`成员变量。
- 中断恢复: 通过保存和恢复寄存器的值，实现中断的恢复。中断恢复的实现是通过`trapret`函数实现的。
  
### 额外知识点

本次实验仅涉及启动进程，未涉及进程的调度，没有对一般的进程切换进行实现，仅仅实现了idle进程切换到其他进程的功能。另外，本实验还未设计进程的通信，隔离相关的知识。

- 进程调度策略：实际上进程的调度策略有很多种，比如先来先服务、短作业优先、时间片轮转等等。例如时间片轮转调度策略，每个进程都有一个时间片，当时间片用完后，进程会被挂起，然后调度器会选择另一个进程执行。
- 进程通信：进程通信的方式也有很多种，比如管道、消息队列、共享内存等等。例如管道，管道是一种半双工的通信方式，它可以实现父子进程之间的通信。 
