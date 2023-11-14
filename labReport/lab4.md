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


## 练习2：为新创建的内核线程分配资源

### ucore是否做到给每个新fork的线程一个唯一的id

## 练习3：编写proc_run函数

### 在本实验的执行过程中，创建且运行了几个内核线程

## Challenge