# Lab3
- [Lab3](#lab3)
  - [练习1：理解基于 FIFO 的页面替换算法](#练习1理解基于-fifo-的页面替换算法)
    - [换入](#换入)
    - [换出](#换出)
  - [练习2：深入理解不同分页模式的工作原理](#练习2深入理解不同分页模式的工作原理)
  - [练习3：给未被映射的地址映射上物理页](#练习3给未被映射的地址映射上物理页)
  - [练习4：补充完成 Clock 页替换算法](#练习4补充完成-clock-页替换算法)
    - [Clock算法与FIFO算法比较](#clock算法与fifo算法比较)
  - [练习5：阅读代码和实现手册，理解页表映射方式相关知识](#练习5阅读代码和实现手册理解页表映射方式相关知识)
    - [大页表优势](#大页表优势)
    - [大页表劣势](#大页表劣势)
  - [Challenge：实现不考虑实现开销和效率的 LRU 页替换算法](#challenge实现不考虑实现开销和效率的-lru-页替换算法)
    - [代码设计](#代码设计)
    - [问题分析](#问题分析)
    - [算法测试](#算法测试)
  - [知识点分析](#知识点分析)
    - [重要知识点](#重要知识点)
    - [额外知识点](#额外知识点)


## 练习1：理解基于 FIFO 的页面替换算法
### 换入
内存页的换入是在缺页中断处理程序中完成的，即由`do_pgfault`处理。该函数首先确定缺页的vma，接着调用`get_pte`得到该页对应的页表项。查看页表项是否存在过，没有则用`pgdir_alloc_page`新建页表项和其映射关系；否则调用`swap_in`从硬盘交换区中将该页读入内存中，然后`page_insert`更新页表项的内容。 

下面具体介绍一页被换入经过的处理：
1. `swap_in`函数首先调用`alloc_page`为即将被换入的页分配一页物理内存，该函数将在后续详细介绍，在此不赘述。
2. 接着调用`get_pte`函数根据给定的虚拟地址逐级找到对应的页表项，并返回页表项的地址。在这里由于是换入，所以之前已经存在页表项，故`create`设置为0，即不会在过程中新建页表。
3. 在`get_pte`逐级寻找时，涉及到换入页的主要是`PDX1`、`PDX0`、`PTX`等宏，这些宏负责从换入页的虚拟地址中拿出页目录项和页表项的索引。
4. 拿到页表项后，将页表项作为`swapfs_read`函数的参数传入，该函数接着调用`ide_read_secs`将交换区中的内存页`memcpy`进前面新分配的物理页。
5. 一个页在换出以后其页表项会保存`swap_entry`，便于换入的时候直接寻道磁盘。`swapfs_read`函数会通过`swap_offset`宏将`swap_entry`转为对应的偏移量。
6. 换入后还需要经过`page_insert`更新页表项：覆盖原来的页表项，保存新的映射关系。
7. 最后调用`swap_map_swappable`设置新换入的页是可以交换的。实际是调用`swap_mannager`对应的函数，在FIFO中即是将其插入到链表尾部，即最后一个进入的页面。

### 换出
内存页的换出是在`alloc_pages`函数里调用的：不管是新分配一页内存，还是新建页表，还是换入交换区中的一页，只要调用了`alloc_page`（宏，限定`alloc_pages`一次只能分配一页）且`pmm_manager`因为物理内存不足而无法正常分配，就需要调用`swap_out`换出内存页以留出物理页空间。  

下面具体介绍一页被换出经过的处理：  
1. `swap_out`函数首先调用`swap_manager`的`swap_out_victim`函数获取需要被置换出去的页。在FIFO的实现中，是拿出链表最后一个页（`list_prev(head)`，头指针的前一个）将其赋值给二级指针参数。
2. 接着调用`get_pte`拿到该页对应的页表项，使用了一个`assert((*ptep & PTE_V) != 0)`来确保该页是一个有效页。
3. 确定了选出的页是可以被换出的以后，调用`swapfs_write`函数将该页写入磁盘的交换区。该函数同前一样，实际是调用`ide_write_secs`函数将其`memcpy`进交换区。
4. 写入后，将页表项更新为`swap_entry`，方便换入的时候磁盘寻道。
5. 最后，调用`tlb_invalidate`刷新TLB。

## 练习2：深入理解不同分页模式的工作原理

> get_pte() 函数（位于 kern/mm/pmm.c）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。  
函数`get_pte()`的定义如下：

```c
    pde_t *pdep1 = &pgdir[PDX1(la)];
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V); //创建一个pte表项
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
```

可见该函数主要完成的工作是根据给出的 PDT 基地址以及虚拟地址，找到对应的 PTE ，完成的方式为通过从虚拟地址中提取页目录索引 PDX 以及页表索引 PTX，从而依次找到页目录项 PDE 以及页表项 PTE。

> get_pte() 函数中有两段形式类似的代码，结合 sv32，sv39，sv48 的异同，解释这两段代码为什么如此相像。

`get_pte()`函数中的两段代码看起来非常相似，因为它们都在执行基本相似操作：检查页目录项 PDE （或页表项 PTE）是否存在，如果不存在并且`create`参数为1，则分配一个新的 PDE (或 PTE)，并设置新的PDE（或PTE）的值。对于页目录表的操作同页表的操作是类似的。  
这两段代码之间的主要区别在于它们操作的页目录级别不同。第一段代码处理的是第一级页目录，而第二段代码处理的是第二级页目录（也即页表）。  

在Sv32、Sv39和Sv48这三种虚拟内存方案中，都使用了多级页表来实现虚拟地址到物理地址的映射。Sv32使用两级页表，Sv39使用三级页表，而Sv48使用四级页表。每一级的页表都有一个对应的页目录，这些页目录项存储了下一级页表的物理地址整体的结构都是类似的，都是每个表有一些表项，每个表项指向下一级的表，所以，就会让每级之间的页表查询访问方式相似。

> 目前 get_pte() 函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

`get_pte()`函数中，首先查询页目录表，再查询页表，从而得到一个 PTE ，在查询页目录表以及页表的过程中，如果表项不为valid，就会根据参数create来决定是否在缺失处创建一个新的表项，以此同时实现查询与分配页表项的功能。  

如果将查询以及分配的功能分开，可以想到，在分配一个页表项时，就需要对该页表项的位置进行查询，所以需要调用查询相关的函数。而查询函数可能会返回一个空的表项，而这个表项可能是 PTE ，也有可能是 PDE ，因为可能此时想要创建的页表项的页表所对应的页目录表项还未建立。这样，其返回结果既可能是需要创建的页表项，也有可能是其上一级的页目录表。从而需要做额外判断，造成逻辑上的复杂性。  
因此如果将函数拆分，最好创建一个函数单独在页目录表中搜索以及一个函数单独在页表中搜索。这样的逻辑是复杂的，我们也往往不需要单独搜索页目录表，而是同时搜索页目录表及其对应的页表。  
所以我们认为这样的写法很好，没有必要把两个函数拆开。

## 练习3：给未被映射的地址映射上物理页
> 补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页面所在VMA的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。

当程序访问一个未被映射的地址时，此时就会产生缺页异常，这时需要在内核中处理这个异常，给这个地址映射上物理页。这个过程需要完成以下几个步骤：
1. 通过`find_vma`函数找到包含这个地址的`vma`结构，如果找不到，或者找到的`vma`结构的起始地址大于这个地址，说明这个地址不在任何一个`vma`结构的范围内，程序访问了一个非法地址，此时直接返回`-E_INVAL`。
2. 根据该地址所在`vma`的权限，设置需要分配的内存页的权限。
3. 利用`ROUNDDOWN`宏将这个地址向下对齐到页的边界，根据页的首地址，利用`get_pte`函数找到该页对应的页表项。
   - 如果页表项不存在，说明这个页还没有被映射，利用`pgdir_alloc_page`分配一个物理页，然后将这个物理页映射到这个页表项上。
   - 若页表项存在，则说明该页被置换到了硬盘上，通过`swap_in`将其写入内存，然后用`page_insert`将其映射到这个页表项上，最后用`swap_map_swappable`将其加入到`swap_manager`的管理中。
4. 成功映射，则最后返回`0`。
```C
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;

    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;


    ptep = get_pte(mm->pgdir, addr, 1);  

    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        if (swap_init_ok) {
            struct Page *page = NULL;
            swap_in(mm, addr, &page); 
            page_insert(mm->pgdir, page, addr, perm);
            swap_map_swappable(mm, addr, page, 1);
            page->pra_vaddr = addr;
            
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;

failed:
    return ret;
}
```

> 请描述页目录项（PageDirectoryEntry）和页表项（PageTableEntry）中组成部分对ucore实现页替换算法的潜在用处。
- 页表项记录了虚拟地址到物理地址的映射，mmu需要通过页表项才能获得虚拟地址对应的物理地址。
- 页表项被用来维护该物理页与swap磁盘上扇区的映射关系，当虚拟页被换出到磁盘时，页表项或页目录项中的低8位置0，然后在高24位保存其在硬盘上的位置。页替换涉及到换入换出，换入时通过`do_pgfault`将某个虚拟地址对应于磁盘的一页内容读入到内存中，换出时需要将某个虚拟页的内容写到磁盘中的某个位置，页表项了记录该虚拟页在磁盘中的位置，为换入换出提供磁盘位置信息。
- 页目录项和页表项中的Accessed位保存了页是否被访问，Dirty位是否被修改，通过这些位可以设计更合理的页替换算法。

>  如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

此时会固定的跳转到初始化stvec时设置好的处理程序地址，也即__alltraps处，进行上下文保存，以及将发生缺页中断的地址保存到`trapframe`中。然后跳转到中断处理函数trap()，具体由`do_pgfault`处理，解决完毕返回到__trapret恢复保存的寄存器，也即上下文，通过sret跳转回原程序。


> 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？
如果有，其对应关系是啥？

数据结构Page的全局变量是一个用于管理物理内存页的数组，每个Page结构体记录了一个物理页的属性和状态。页表中的页目录项和页表项是用于实现虚拟地址到物理地址的映射关系的数据结构，每个页目录项或页表项记录了一个虚拟页对应的物理页的起始地址和一些标志位等信息。  
数据结构Page的全局变量与页表中的页目录项和页表项之间没有直接的对应关系，但是它们都涉及到物理内存页的管理和使用。数据结构Page的全局变量可以通过物理地址找到对应的Page结构体，而页表中的页目录项和页表项可以通过其高20位的虚拟地址找到对应的物理地址。通过物理地址可以确定物理页号，从而找到对应的Page结构体。

## 练习4：补充完成 Clock 页替换算法
按照给出的代码框架补充完成Clock页替换算法：  
Clock的初始化函数与FIFO的差别并不大，初始化`pra_list_head`链表，让mm的`sm_priv`指向`pra_list_head`，方便后续的算法调用。唯一的区别是初始化`curr_ptr`指针，让其指向当前的队列头。
```C
static int
_clock_init_mm(struct mm_struct *mm)
{     
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    // 初始化pra_list_head为空链表
    list_init(&pra_list_head);
    // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
    curr_ptr = &pra_list_head;
    // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
    mm->sm_priv = &pra_list_head;
    return 0;
}
```

`swappable`函数目的是将一页插入置换页链表，Clock算法在此处的实现并不困难，像FIFO一样把页插入到链表尾部，只需将其标志位置为1。  
在这里我们使用`PTE_A`来标识页面最近被访问，因为我们期望硬件在访问页时，能够自动将`swap_out`刷新掉的`PTE_A`置位，以达到真正的Clock置换的目的。这将在后面详细介绍。
```C
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    list_entry_t *head=(list_entry_t*) mm->sm_priv;

    // 将页面page插入到页面链表pra_list_head的末尾
    list_add(head->prev, entry);

    // 将页面的visited标志置为1，表示该页面已被访问
    pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
    //page->visited = 1;  // 用啥做标志都行
    *ptep |= PTE_A;

    curr_ptr = entry;
    cprintf("curr_ptr %px\n", curr_ptr);  // 打印了 make grade才能通过
    return 0;
}
```

在`swap_out`时，需要查找最早未被访问的页面。我们从`curr_ptr`往后循环遍历，确认页的`PTE_A`访问位是否置1，若已经被置1则刷新该位置，查看链表上的下一页，直到找到`PTE_A`位为0的页。确定该页即是将被换出的页，将其摘出链表。
```C
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick==0);
    
    while (1) {
        /*LAB3 EXERCISE 4: YOUR CODE*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        if(list_next(curr_ptr) == head)
            curr_ptr = head->next;
        else
            curr_ptr = list_next(curr_ptr);

        // 获取当前页面对应的Page结构指针
        struct Page *page = le2page(curr_ptr, pra_page_link);

        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
        if((*ptep & PTE_A) == 0) {
            list_del(curr_ptr);
            *ptr_page = page;
            break;
        }

        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        else {
            *ptep &= ~PTE_A;
        }
    }
    return 0;
}
```

### Clock算法与FIFO算法比较
Clock算法与FIFO算法整体上有些类似，Clock是换出最先找到的`PTE_A`标志位为0的页。如果链表上所有页该标志位都为1，扫描一遍后，Clock并不会置换任何页，而是进行第二遍扫描。如果在进行第二次扫描之前，对应页又被访问了，则该页不会被置换出去，这即是Clock与FIFO最大的不同。  
值得注意的是，在这里我们使用的是`PTE_A`作为标志位，因为我们期望硬件在访问过程中会改变它的值。而如果使用`visited`字段来标识的话，该字段只有在缺页异常时才会进行更新，在扫描过后无法恢复，达不到Clock算法的目的，效果上等同于FIFO。  
但`PTE_A`标志位的有效性仍有待商榷，这我们将在LRU实现里进行讨论。


## 练习5：阅读代码和实现手册，理解页表映射方式相关知识
### 大页表优势
1. 简化了页表的层次结构，可以更高效地查找和缓存页表项，提高内存访问性能。
2. 减少了所需页表项的数量，减小了内存管理开销。
3. 对于需要大量连续内存的应用程序，如数据库和深度学习等，能很好地满足其内存需要与性能要求。

### 大页表劣势
1. 内存浪费：多级页表只有在对应的页需要时才会建立页表，而使用大页表的话，即使进程只需很小的内存，也需要分配完整的页表空间。
2. 大页表占据大量内存空间，进程切换需要改变虚拟地址空间，可能导致内存页频繁换入换出，影响性能。
3. 如果使用大页表的话，一页只能存512个页表项，难免会使用比页更大的内存分配单位，容易造成内存碎片问题。

## Challenge：实现不考虑实现开销和效率的 LRU 页替换算法

### 代码设计
LRU目的是寻找最近最少访问的页面，最精确的设计需要**实时监控哪些内存页被访问**，并将其移动到链表前端。  
在本次实验中，没有相应的硬件支持，我们无法获悉内存页被访问的具体时间，只有当发生pageFault的时候才能够确认。但如果仅靠pageFault时来进行检查访问情况以调整链表，效果上又和FIFO没有太大区别了。  
为了最好的设计出近似LRU的效果，不考虑开销和效率，我们想到了**利用时钟中断**。  

因为内存页被访问时，其`PTE_A`位会被相应的置位（硬件上存在问题，后续进行讨论），我们可以**借助时钟中断，确认在两次时钟中断期间，哪些页面被进行了访问，进而调整其在置换链表中的位置**。理论上，只要时钟中断频率够高，该设计就越近似于LRU。  

代码实现上，其他函数均能复用FIFO的代码，但需重写`tick_event`：  
下面的函数将被逐层封装，在时钟中断时会进行调用，遍历整个置换页链表，找出在两次时钟中断期间被访问了的页，将其移动到链表头部，并改变它的`PTE_A`位。
```C
static int
_lru_tick_event(struct mm_struct *mm)
{ 
    list_entry_t* head = (list_entry_t*)mm->sm_priv;
    list_entry_t* cur = head;
    while (cur->next != head)  // 遍历链表
    {
        cur = cur->next;
        struct Page* page = le2page(cur, pra_page_link);
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
        if (*ptep & PTE_A)      // 页面在一段时间内被访问了，拿到最前，置零
        {
            list_entry_t* temp = cur->prev;
            list_del(cur);
            *ptep &= ~PTE_A;  // 清0
            list_add(head, cur);  // 移动位置
            cur = temp;
        }
        // cprintf("here in lru_tick_event\n");
    }
    return 0;
}
```

### 问题分析

### 算法测试

## 知识点分析

### 重要知识点
- 缺页异常：当程序访问一个不存在于物理内存中的虚拟页面时，会触发缺页异常，由操作系统负责处理。处理过程包括找到所需页面的磁盘位置，选择一个合适的物理帧进行置换，将所需页面加载到物理内存中，更新页表和帧表，恢复程序执行。
- 页面置换：当物理内存不足时，需要将某些物理页面换出到外存中，以腾出空间给新的页面。页面置换算法决定了哪些页面应该被换出，以达到最小化缺页次数和最大化内存利用率的目的。
- 页面置换算法：有多种页面置换算法，例如FIFO, LRU, Clock, 工作集, 缺页率等。不同的算法有不同的优缺点和实现难度。一些算法可能会出现Belady现象，即增加物理页面数反而导致缺页次数增加。
- uCore虚拟内存机制：uCore实现了基于工作集的页面置换算法，使用mm_struct结构体管理虚拟内存空间，使用vma_struct结构体描述虚拟内存区域，使用swap_manager接口实现交换机制。

### 额外知识点
本次实验并未设计页面置换算法的评价标准和性能比较，页面置换算法的目标是尽量减少缺页异常的发生次数，提高内存利用率和程序运行效率。页面置换算法的评价标准主要有缺页率和置换开销。 
- 缺页率：指发生缺页异常的次数与程序访问内存次数的比值。 
- 置换开销：指进行页面置换所需的时间和资源消耗。 
