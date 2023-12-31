# lab8
- [lab8](#lab8)
  - [练习1: 完成读文件操作的实现（需要编码）](#练习1-完成读文件操作的实现需要编码)
  - [练习2: 完成基于文件系统的执行程序机制的实现（需要编码）](#练习2-完成基于文件系统的执行程序机制的实现需要编码)
  - [扩展练习Challenge1：完成基于“UNIX 的 PIPE 机制”的设计方案](#扩展练习challenge1完成基于unix-的-pipe-机制的设计方案)
  - [扩展练习Challenge2：完成基于“UNIX 的软连接和硬连接机制”的设计方案](#扩展练习challenge2完成基于unix-的软连接和硬连接机制的设计方案)


## 练习1: 完成读文件操作的实现（需要编码）
打开文件的流程如下：
1. 用户进程要打开打开文件首先需要通过`syscall`进入内核态，执行`sysfile_open()`函数，将位于用户空间的路径字符串`path`拷贝到内核空间，然后调用`file_open()`函数，`file_open`通过使用VFS的接口`vfs_open`进入到文件系统抽象层。
2. 在文件系统抽象层中，首先分配一个空闲的file数据结构，然后通过`vfs_lookup`找到path对应文件的VFS索引节点。
3. `vfs_lookup`会调用用vop_lookup函数进入到SFS文件系统，将`path`路径从左至右逐一分解`path`获得各个子目录和最终文件的inode节点(本次实验中仅在根目录下查找)。  

读文件的过程也类似，首先通过`syscall`进入内核态，执行`sys_read()`函数，将位于用户空间的文件描述符`fd`和缓冲区`base`拷贝到内核空间，然后调用`sysfile_read()`函数，进入到文件系统抽象层。  

在`sysfile_read()`函数中，每次读取`buffer`大小，循环的读取文件，调用`file_read()`函数将文件内容读取到`buffer`中，
`file_read()`函数首先通过`fd2file`找到对应的`file`结构，并检查是否可读，将这个文件的计数加1，然后通过`vop_read`将文件内容读到缓存中。 

`vop_read`实际上是对`sfs_read`的封装，`sfs_read`会调用`sfs_io`，首先找到`inode`对应的`sfs`和`sin`，然后调用`sfs_io_nolock`进行读取文件的操作。  

`sfs_io_nolock`函数的填写如下:
```c
    if ((blkoff = offset % SFS_BLKSIZE) != 0) {
        size = (nblks != 0) ? (SFS_BLKSIZE - blkoff) : (endpos - offset);
        //找到磁盘块号
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        //进行相应的读写操作
        if ((ret = sfs_buf_op(sfs, buf, size, ino, blkoff)) != 0) {
            goto out;
        }
        //更新后续读写需要的参数
        alen += size;
        buf += size;
        if (nblks == 0) {
            goto out;
        }
        blkno++;
        nblks--;
    }

    if (nblks > 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_block_op(sfs, buf, ino, nblks)) != 0) {
            goto out;
        }
        alen += nblks * SFS_BLKSIZE;
        buf += nblks * SFS_BLKSIZE;
        blkno += nblks;
        nblks -= nblks;
    }

    //处理末尾
    if ((size = endpos % SFS_BLKSIZE) != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        alen += size;
    }
```
在上述过程中，首先检查读写位置是否与`block`大小对齐，如果不对齐，需要先读写开头一部分，然后再读写中间部分，最后处理末尾剩余部分文件内容。每次读写时，首先通过`bmap_load_nolock`找到对应的磁盘块号，然后中间部分通过`sfs_block_op`直接进行多个块的读写操作，开头与末尾与`block`大小未对齐部分通过`sfs_buf_op`在块内进行读写。


## 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）

在 Lab 5 的基础上进行修改，读 elf 文件变成从磁盘上读，而不是直接在内存中读。

1. `alloc_proc`函数

在 proc.c 中，首先我们需要先初始化 fs 中的进程控制结构，即在 alloc_proc 函数中我们需要做—下修改，加上—句 proc->ﬁlesp = NULL; 从而完成初始化。一个文件需要在 VFS 中变为一个进程才能被执行。

```c
// kern/process/proc.c中
// 初始化filesp
proc->filesp = NULL;
```

2. `load_icode`函数

首先，已经实现了文件系统，所以将原来lab5中的从内存中读取用户elf文件头以及程序文件头的方式改为通过文件系统来完成：

```c
// ... some codes here ...
//(3) copy TEXT/DATA/BSS parts in binary to memory space of process
struct elfhdr __elf, *elf = &__elf;
if ((ret = load_icode_read(fd, elf, sizeof(struct elfhdr), 0)) != 0) {
    goto bad_elf_cleanup_pgdir;
}

if (elf->e_magic != ELF_MAGIC) {
    ret = -E_INVAL_ELF;
    goto bad_elf_cleanup_pgdir;
}

struct proghdr __ph, *ph = &__ph;
uint32_t vm_flags, perm, phnum;
for (phnum = 0; phnum < elf->e_phnum; phnum ++) {
    off_t phoff = elf->e_phoff + sizeof(struct proghdr) * phnum;
    if ((ret = load_icode_read(fd, ph, sizeof(struct proghdr), phoff)) != 0) {
// ... some codes here ...
```

上面的代码使用`load_icode_read`来完成对elfhdr和proghdr的读取工作，而`load_icode_read`本质上是调用了文件系统的接口。后续的代码中还有对于这个函数的调用，这里不再赘述。  

另外，由于还需要对用户栈中的参数argc和argv进行初始化，所以还需要计算传入参数的长度，将这两个参数压入用户栈。

```c
//(6) setup uargc and uargv in user stacks
uint32_t argv_size=0, i;
//计算参数总长度
for (i = 0; i < argc; i ++) {
    argv_size += strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
}
// 为agrv指向的字符串分配空间，对齐
uintptr_t stacktop = USTACKTOP - (argv_size/sizeof(long)+1)*sizeof(long);
char** uargv=(char **)(stacktop  - argc * sizeof(char *));

argv_size = 0;
//存储参数
for (i = 0; i < argc; i ++) {
    //uargv[i]保存了kargv[i]在栈中的起始位置
    uargv[i] = strcpy((char *)(stacktop + argv_size), kargv[i]);
    argv_size +=  strnlen(kargv[i],EXEC_MAX_ARG_LEN + 1)+1;
}
//由于栈地址从高向低增长，所以第一个参数的地址即为栈顶地址，同时压入一个int用于保存argc
stacktop = (uintptr_t)uargv - sizeof(int);
//在栈顶存储参数数量
*(int *)stacktop = argc;
```

这个过程通过四步完成：

- 首先通过遍历计算出argv指向的字符串的总长度，然后通过将栈顶指针减去这个长度并对齐，**为这些字符串分配空间。**

- 其次将栈顶减去argc * sizeof(char*)**为agrv指针数组本身分配空间**
- 然后利用循环把uargv中的字符串参数拷贝到对应的位置
- 最后**为argc参数分配空间**，给argc赋值即可



通过这两步即可完成基于文件系统的执行，make qemu后可以执行相应的用户程序。

## 扩展练习Challenge1：完成基于“UNIX 的 PIPE 机制”的设计方案
管道是由内核管理的一个缓冲区：管道的一端连接一个进程的输出，这个进程会向管道中放入信息。管道的另一端连接一个进程的输入，这个进程取出被放入管道的信息。  
```
process1 -[write]-> pipe(in kernel) -[read]-> process2
```

当管道的缓冲区没有信息时，尝试从管道中读取信息的进程会等待，直到另一端的进程放入信息。  
当管道的缓冲区被填满时，尝试放入信息的进程会等待，直到另一端的进程取出信息。  
当两个进程都终结的时候，管道也自动消失。

实现上，可以借助文件系统的file结构和VFS的索引节点inode。  
将两个file结构指向同一个**临时的VFS索引节点**，而这个VFS索引节点指向一个物理数据页。
```
file1.inode   ---> inode <---   file2.inode
       write         ↓         read
                  data page
```

当进程向管道写入时，利用标准库函数`write()`，系统根据库函数传递的文件描述符找到文件的file结构。  
file结构拿到特定函数地址进行写入，写入时锁定内存，接着将进程地址空间的数据复制到内存。  
若不能获取到锁或不能写入，则休眠，进入等待队列。  
当有空间可以写入或内存解锁时，读取进程唤醒写入进程。  
写入进程收到信号，写入数据后，唤醒休眠的读取进程进行读取。

## 扩展练习Challenge2：完成基于“UNIX 的软连接和硬连接机制”的设计方案
> **UNIX硬链接**  
硬链接是一个目录条目，它指具有同一个i-node(硬盘上的物理位置)的另一个文件。事实上只存在一个文件，指向硬盘上同一个物理数据的有多个目录条目。  
> **UNIX软链接**   
UNIX软链接也称符号连接或symlinks，相当于Windows系统中的快捷方式。和硬链接不同的是，软链接是一个独立的文件，在硬件上有属于自己的i-node。软链接只是一个文件，其中包含指向另一个文件的指针。

保存在磁盘上的inode信息均存在一个 nlinks 变量用于表示当前文件的被链接的计数：  
- 如果在磁盘上创建一个文件A的软链接B，那么将B当成正常的文件，创建inode。接着将TYPE域设置为链接，使用剩余的域中的一个指向A的inode位置，再额外使用一个位来标记当前的链接是软链接还是硬链接
- 当访问到文件B（read，write 等系统调用），判断如果B是一个链接，则实际是将对B指向的文件A进行操作
- 当删除一个软链接B的时候，直接将其在磁盘上的inode删掉即可
- 如果在磁盘上创建文件A的硬链接B，将A的inode赋给B，然后将A中的被链接的计数加1
- 访问硬链接的方式与访问软链接一致
- 当删除一个硬链接B的时候，将文件A的被链接计数减1，如果减到了0，则将A删除掉

