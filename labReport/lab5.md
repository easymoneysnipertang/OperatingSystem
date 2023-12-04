# lab5 <!-- omit in toc -->

- [练习 1: 加载应用程序并执行](#练习-1-加载应用程序并执行)
  - [请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。](#请简要描述这个用户态进程被ucore选择占用cpu执行running态到具体执行应用程序第一条指令的整个经过)
- [练习 2: 父进程复制自己的内存空间给子进程](#练习-2-父进程复制自己的内存空间给子进程)
- [练习 3: 分析fork/exec/wait/exit和系统调用的实现](#练习-3-分析forkexecwaitexit和系统调用的实现)
  - [函数分析](#函数分析)
  - [函数执行流程](#函数执行流程)
- [扩展练习 Challenge](#扩展练习-challenge)
  - [实现 Copy on Write （COW）机制](#实现-copy-on-write-cow机制)
  - [用户程序是何时被预先加载到内存中的](#用户程序是何时被预先加载到内存中的)
  - [与常用操作系统加载的区别与原因](#与常用操作系统加载的区别与原因)


## 练习 1: 加载应用程序并执行
根据提示，设置应用进程的中断帧，使得进程后续能够正常返回用户态执行。具体的代码如下：
```C
    // 设置进程的中断帧，执行sret返回用户态，按系统调用路径原路返回：ebreak？
    //(6) setup trapframe for user environment
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 YOUR CODE
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */
    tf->gpr.sp = USTACKTOP;  // 用户栈顶
    tf->epc = elf->e_entry;  // 用户程序入口
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP & ~SSTATUS_SPIE);  // 用户态
```

### 请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。
1. 当init进程将用户进程创建完毕后，进入`do_wait`阶段。接着ucore会调度选择用户进程执行，进入`user_main`。  
2. `user_main`调用`kernel_exe`，在内核态触发`ebreak`中断。目的是通过与`trap`协作，调用`sys_exec`，完成进程加载，并最后通过中断返回回到用户态。
3. `sys_exec`调用`do_execve`：回收当前进程的内存空间，然后调用`load_icode`，根据elf文件的信息，将用户程序加载到内存中。
4. 如实验指导手册所写，`load_icode`会执行一系列操作为用户进程建立能够运行的用户环境，报告建立`mm`、建立页目录表、分配各个段、设置用户栈、设置中断帧等。
5. `load_icode`最后一步设置了用户栈，`epc`和`status`。中断处理完毕后，会通过`trapret`回到用户态，执行用户进程`entry_point`处的指令。


## 练习 2: 父进程复制自己的内存空间给子进程

## 练习 3: 分析fork/exec/wait/exit和系统调用的实现

用户态程序的fork/exec/wait/exit系统调用到最后实际调用的是kern/syscall/syscall.c中的sys_fork/sys_exec/sys_exit/sys_wait，故下面首先对于这四个函数进行分析。

### 函数分析

**sys_fork函数**

下面是具体的sys_fork函数：

```c
static int
sys_fork(uint64_t arg[]) {
    struct trapframe *tf = current->tf;
    uintptr_t stack = tf->gpr.sp;
    return do_fork(0, stack, tf);
}
```

可见sys_fork函数将当前进程的中断帧以及中断帧中esp寄存器值作为参数传给do_fork，由do_fork完成具体的fork工作

do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存
储位置不同。实际需要”fork”的东西就是 stack 和 trapframe。在do_fork中给新内核线程分配资源，并且复制原进程的状态即可，具体的代码如下：

```c
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;

    //    1. call alloc_proc to allocate a proc_struct
    if((proc = alloc_proc()) == NULL){
        goto fork_out;
    }

    // set child proc's parent to current process
    proc->parent = current;
    // make sure current process's wait_state is 0
    assert(current->wait_state == 0);

    //    2. call setup_kstack to allocate a kernel stack for child process
    if(setup_kstack(proc) != 0){
        goto bad_fork_cleanup_proc;  // 释放刚刚alloc的proc_struct
    }
    //    3. call copy_mm to dup OR share mm according clone_flag
    if(copy_mm(clone_flags, proc) != 0){
        goto bad_fork_cleanup_kstack;  // 释放刚刚setup的kstack
    }
    //    4. call copy_thread to setup tf & context in proc_struct
    copy_thread(proc, stack, tf);  // 复制trapframe，设置context

    //    5. insert proc_struct into hash_list && proc_list
    // insert proc_struct into hash_list && proc_list, set the relation links of process
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);  // 插入hash_list
        set_links(proc);  // 设置进程间的关系
    }
    local_intr_restore(intr_flag)
    // set_links里已经做了
    //list_add(&proc_list, &(proc->list_link));  // 插入proc_list
    //nr_process ++;

    //    6. call wakeup_proc to make the new child process RUNNABLE
    wakeup_proc(proc);  // 设置为RUNNABLE
    //    7. set ret vaule using child proc's pid
    ret = proc->pid;
 
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

在第一步中加入了assert语句，确保当前进程不处于等待状态，在第五步中由于还要维护兄弟指针等变量，需要在插入hash list后调用set_links函数来设置这些指针。其他方面的实现上，与lab4中相同，此处不再赘述。

**sys_exec函数**

下面是具体的sys_exec函数：

```c
static int
sys_exec(uint64_t arg[]) {
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    return do_execve(name, len, binary, size);
}
```

可见sys_fork函数从参数中得到进程名，名字长度，程序首地址以及程序的大小信息，将他们作为参数传给do_execve从而完成让程序执行另一个程序的操作。


do_execve首先回收自身所占用户空间：
```c
    if (mm != NULL) {  // 用户进程
        cputs("mm != NULL");
        // 设置页表为内核空间页表，接下来在内核空间执行
        lcr3(boot_cr3);     // 这里是启动一个进程为什么要回收内核的页表项？
        // 判断 mm 的引用计数
        if (mm_count_dec(mm) == 0) {
            // 回收当前进程的内存空间？
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
            // 重新分配内存
        }
        current->mm = NULL;
    }
```

然后调用 load_icode，用新的程序覆盖内存空间，从而形成一个执行新程序的新进程，load_icode部分的分析可以参考练习一中的讲解。

### 函数执行流程

fork/exec/wait/exit 函数的实现都是借助user/libs/ulib.c中的库来实现的，以fork为例，其执行的流程如下：
``` c
// user/libs/ulib.c中
fork(void) {
    return sys_fork();
}

// user/libs/syscall.c中
int
sys_fork(void) {
  return syscall(SYS_fork);
}
``` 
可以看到用户可以通过`user/libs/ulib.c`中的fork函数调用sys_fork函数，从而将系统调用交给syscall函数来处理：

```c
// user/libs/syscall.c中
static inline int
syscall(int64_t num, ...) {
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {  // 依次取出参数
        a[i] = va_arg(ap, uint64_t);
    }
    va_end(ap);

    asm volatile (
        "ld a0, %1\n"
        "ld a1, %2\n"
        "ld a2, %3\n"
        "ld a3, %4\n"
        "ld a4, %5\n"
    	"ld a5, %6\n"
        "ecall\n"
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
```

在syscall函数中依次读取传入的参数后，通过调用ecall触发异常，陷入到内核态

```c
// kern/trap/trap.c的exception_handler函数
case CAUSE_USER_ECALL:
    //cprintf("Environment call from U-mode\n");
    // 处理用户态调用syscall
    tf->epc += 4;  // 指向下一条指令
    syscall();	// kern/syscall/syscall.c中的syscall
    break;
```

在trap中经过trap_dispatch时，通过读取cause寄存器确定了这是由于用户态调用ecall触发的中断，于是调用`kern/syscall/syscall.c`中的syscall函数（内核态执行系统调用的函数）来对系统调用进行处理

```c
// kern/syscall/syscall.c中
static int (*syscalls[])(uint64_t arg[]) = {
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
};

void
syscall(void) {
    struct trapframe *tf = current->tf;
    uint64_t arg[5];
    int num = tf->gpr.a0;  // a0寄存器存放系统调用号
    if (num >= 0 && num < NUM_SYSCALLS) {  // 防止数组越界
        if (syscalls[num] != NULL) {
            // 取出系统调用参数，转发给对于的系统调用函数处理
            arg[0] = tf->gpr.a1;
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
            return ;
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
```

该函数从中断帧中取出系统调用的参数，通过传入的num来把系统调用分配到对应的函数。

这一分配过程则是通过函数指针数组syscalls来实现，这里用到了**指定初始化器**的语法，例如当传入的num是SYS_kill，那么syscalls[num]就是sys_kill的函数指针，从而实现了对于系统调用的分配。

接着，对应的系统调用便可正常执行，故可以总结fork/exec/wait/exit的执行流程如下：

1. 用户通过user/libs/ulib.c进行系统调用（fork/exec/wait/exit函数）
2. 转到user/libs/syscall.c中的sys_fork/sys_exec/sys_exit/sys_wait
3. 转到user/libs/syscall.c中的syscall，调用ecall
4. 陷入到trap，通过exception_handler处理
5. 调用kern/syscall/syscall.c中的syscall
6. 通过num不同分配到具体的函数进行处理（kern/syscall/syscall.c中的sys_fork/sys_exec/sys_exit/sys_wait）

## 扩展练习 Challenge

### 实现 Copy on Write （COW）机制

### 用户程序是何时被预先加载到内存中的

### 与常用操作系统加载的区别与原因