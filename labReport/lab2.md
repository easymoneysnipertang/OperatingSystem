# Lab2

## 理解 first-fit 连续物理内存分配算法（思考题）

> first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合 kern/mm/default_pmm.c 中的相关代码，认真分析 default_init，default_init_memmap，default_alloc_pages，default_free_pages 等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。请在实验报告中简要说明你的设计实现过程。  
first fit 算法是否有进一步的改进空间？

ucore中采用面向对象编程的思想，将物理内存管理的内容抽象成若干个特定的函数，并以结构体pmm_manager作为物理内存管理器封装各个内存管理函数的指针  
这样在管理物理内存时只需调用结构体内封装的函数，从而可将内存管理功能的具体实现与系统中其他部分隔离开。pmm_manager中保存的函数及其功能如下所述：

```c
struct pmm_manager {
    const char *name;                                 //物理内存管理器的名称
    void (*init)(void);                               //物理内存管理器初始化
    void (*init_memmap)(struct Page *base, size_t n); //初始化空闲页，
    struct Page *(*alloc_pages)(size_t n);            //申请分配指定数量的物理页
    void (*free_pages)(struct Page *base, size_t n);  //申请释放若干指定物理页
    size_t (*nr_free_pages)(void);                    //查询当前空闲页总数
    void (*check)(void);                              //检查物理内存管理器的正确性
};
```

另外，使用了一些标志位来标识一个页的分配情况以及保留情况:

```c
#define PG_reserved                 0
#define PG_property                 1

struct Page {
    int ref;                        // page frame's reference counter
    uint32_t flags;                 //描述物理页帧状态的标志位
    unsigned int property;          //只在空闲块内第一页中用于记录该块中页数，其他页都是0
    list_entry_t page_link;         //空闲物理内存块双向链表
};
```

reserved位表示是否将页保留给操作系统，property位表示页的分配情况当为1时是空闲块开头，0时为分配块或者空闲块的块身。  
default_pmm.c中实现的几个函数的作用如下：

- default_init：初始化pmm
- default_init_memmap：初始化内存映射
- default_alloc_pages：申请多个页
- default_free_pages: 申请释放多个页

以下是具体介绍  
**default_init：**

```c
free_area_t free_area; /*allocate blank memory for the doublely linked list*/

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

default_init函数比较简单，作用为初始化双向链表，将空闲页总数nr_free初始化为0。  
**default_init_memmap：**

```c
static void 
default_init_memmap(struct Page *base, size_t n) {   
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
        if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) { //添加到末尾的情况
                list_add(le, &(base->page_link));
            }
        }
    }
}
```

遍历base以及n所确定的Page检查页面是否被内核reserved，如果reserved说明该页面是可用的，否则说明以及分初始化了，或者是非法页。  
接下来，将块内各个页的flags置为0以标记物理页帧有效，property成员置零。使用SetPageProperty宏置PG_Property标志位来标记空闲块首页，将首页property置为块内总页数，然后将全局总页数nr_free加上块内总页数，并用page_link这个双链表结点指针集合将块首页连接到空闲块链表里。  
最后一步分为两种情况：如果freelist中无空闲块，就直接加入；如果有空闲块，就要考虑加入的顺序，让小地址的块排在前面。

**default_alloc_pages(size_t n)：**

```c
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n; //操作的还是实际上地址处的page
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

分配页的函数default_alloc_pages从起始位置开始顺序搜索空闲块链表  
找到第一个页数不小于所申请页数n的块（p->property >= n），如果这个块所对应的页数正好等于申请的页数（p->property == n），则可直接分配；  
如果块页数比申请的页数多（p->property > n）就要将块分裂，将找到的页分配出去，分裂出来的页链接到freelist中，分配完成后重新计算全局空闲页数；  
若遍历整个空闲链表仍找不到足够大的块，则返回NULL表示分配失败。

**default_free_pages(struct Page *base, size_t n)：**

```c
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```

释放页的函数default_free_pages根据参数提供的块基址，遍历freelist找到待插入位置，插入这些页  
然后将property置为块内页数，使用SetPageProperty宏置PG_Property标志位来标记空闲块首页，将首页property置为块内总页数  
将全局总页数nr_free加上块内总页数，并用page_link这个双链表结点指针集合将块首页连接到空闲块链表里

最后一步分为两种情况：freelist中的空闲块，正好与加入的块相接，就删除freelist中原有的块，将这些块合并成一个大块，整体加入到freelist中。

> 你的 first fit 算法是否有进一步的改进空间？

first fit算法的优点是实现简单，缺点是会产生很多小的空闲块，导致内存碎片化严重。  
可以考虑加入碎片化的内存整理算法，将多个小的空闲块合并成一个大的空闲块，从而减少内存碎片化。

## best fit的实现

best_fit_pmm.c中要实现的几个函数功能与default_pmm.c大致相同：

- best_fit_init：初始化pmm
- best_fit_init_memmap：初始化内存映射
- best_fit_alloc_pages：申请多个页
- best_fit_free_pages: 申请释放多个页

其中best_fit_init、best_fit_init_memmap以及best_fit_free_pages函数的实现与default_pmm.c中的函数完全相同，可以参考其中的代码即可。

**best_fit_alloc_pages:**

对于best_fit_alloc_pages函数，只需使用同default_alloc_pages函数中类似的方法，遍历freelist链表，找到满足要求的最小页并用指针记录即可。  
代码如下：

```c
while ((le = list_next(le)) != &free_list) {
    struct Page *p = le2page(le, page_link);
    if (p->property >= n && p->property < min_size) {
        min_size = p->property;
        page = p;
    }
}
```

> 你的 best fit 算法是否有进一步的改进空间？

best fit算法同first fit算法的特点相似，实现简单，但会产生很多小的空闲块  
所以也可以考虑加入碎片化的内存整理算法，将多个小的空闲块合并成一个大的空闲块

## challenge1
> Buddy System 算法把系统中的可用存储空间划分为存储块 (Block) 来进行管理, 每个存储块的大小必须是 2 的 n 次幂 (Pow(2, n)), 即 1, 2, 4, 8, 16, 32, 64, 128…  
参考[伙伴分配器的一个极简实现](https://github.com/wuwenbin/buddy2)，在 ucore 中实现 buddy system 分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

伙伴分配的实质就是一种特殊的“分离适配”，即将内存按2的幂进行划分，相当于分离出若干个块大小一致的空闲链表，搜索该链表并给出同需求最佳匹配的大小。其优点是可以快速搜索合并（O(logN)时间复杂度）以及低外部碎片（与最佳适配best-fit的优点类似）；其缺点是内部碎片，因为按2的幂划分块，如果碰上66单位大小，那么必须划分128单位大小的块。Buddy System的内存管理机制如下。


![mhartid](src/lab2_tree.png)  
**分配内存：**  
在Buddy System中整个分配器的大小就是满二叉树节点数目，即所需管理内存单元数目的2倍。一个节点对应4个字节，longest记录了节点所对应的的内存块大小。  

对于内存分配，需要寻找大小合适的内存块，找到一个刚好大于所需内存大小的2的次幂大小的空闲内存块，如果没有将更大的内存块对半分离。  

对于内存分配的alloc函数实现，入参是需要分配的大小，返回值是内存块索引。alloc函数首先将size调整到2的幂大小，并检查是否超过最大限度。然后进行适配搜索，深度优先遍历，当找到对应节点后，将其longest标记为0，即分离适配的块出来，并转换为内存块索引offset返回，依据二叉树排列序号，offset = (index + 1) * size - self->size，那么分配内存块就从索引offset开始往后size个单位。  

最后，在函数返回之前需要回溯，因为小块内存被占用，大块就不能分配了

```C
int buddy2_alloc(int size){
    size = fixsize(size);
    for(node_size = self->size; node_size != size; node_size /= 2 ) {
        if (self->longest[LEFT_LEAF(index)] >= size)
        index = LEFT_LEAF(index);
        else
        index = RIGHT_LEAF(index);
    }
    self->longest[index] = 0;
    offset = (index + 1) * node_size - self->size;
    while (index) {
        index = PARENT(index);
        self->longest[index] =
        MAX(self->longest[LEFT_LEAF(index)], self->longest[RIGHT_LEAF(index)]);
    }
    return offset;
}
```


**释放内存：**  
1. 寻找相邻的块，看其是否释放了。  
2. 如果相邻块也释放了，合并这两个块，重复上述步骤直到遇上未释放的相邻块，或者达到最高上限（即所有内存都释放了）。   

对于在内存释放的free函数的实现，传入之前分配的内存地址索引，并确保它是有效值。之后就跟alloc做反向回溯，从最后的节点开始一直往上找到longest为0的节点，即当初分配块所适配的大小和位置。我们将longest恢复到原来满状态的值。继续向上回溯，检查是否存在合并的块，依据就是左右子树longest的值相加是否等于原空闲块满状态的大小，如果能够合并，就将父节点longest标记为相加的和。

```C
void buddy2_free( int offset) {
  node_size = 1;
  index = offset + self->size - 1;
  for (; self->longest[index] ; index = PARENT(index)) {
    node_size *= 2;
    if (index == 0)
      return;
  }
  self->longest[index] = node_size;
  while (index) {
    index = PARENT(index);
    node_size *= 2;
    left_longest = self->longest[LEFT_LEAF(index)];
    right_longest = self->longest[RIGHT_LEAF(index)];
    if (left_longest + right_longest == node_size)
      self->longest[index] = node_size;
    else
      self->longest[index] = MAX(left_longest, right_longest);
  }
}
```

### buddy_system实现1 -- 朱世豪实现
从default_pmm.c所给出的示例出发，依然使用freelist的结构将空闲块记录下来，用PG_property标志位代表块是否为块首，用属性property表示该空闲块内的空闲页数。

所实现架构的的特点在于对freelist的管理：

> buddy_init_memmap 初始化时

将整个块加入freelist，像default一样只设置块首的标志位以及属性位。  
该部分与default过程比较相似，不再予以展示。

> buddy_alloc_pages 分配页时

随着查找大小合适的块，不断将freelist中的块进行分割，直到找到合适大小的块，然后将所分配的页的PG_property位清零，表示已经分配。

```c
// 从根向下分裂
for(node_size = root->size; node_size != size; node_size /= 2 )
{
    int page_num = (index + 1) * node_size - root->size;
    struct Page *left_page = page_base + page_num;
    struct Page *right_page = left_page + node_size/2;
    // 分裂节点
    if(left_page->property == node_size && PageProperty(left_page)) //当且仅当整个大页都是空闲页的时候，才分裂
    {
        left_page->property /= 2;
        right_page->property = left_page->property;
        if(right_page-page_base == 1)
            cprintf("in alloc:--------------------set--------------------\n");
        SetPageProperty(right_page);
        // cprintf("in allc: node_size:%d, page_num:%d, left_page->property:%d, right_page->property:%d\n",node_size, page_num, left_page->property, right_page->property);
        list_add(&(left_page->page_link), &(right_page->page_link));
    }

    //选择下一个子节点
    if (root[LEFT_LEAF(index)].len >= size && root[RIGHT_LEAF(index)].len>=size)
    {
        index = root[LEFT_LEAF(index)].len <= root[RIGHT_LEAF(index)].len ? LEFT_LEAF(index) : RIGHT_LEAF(index);
    }
    else
    {
        index = root[LEFT_LEAF(index)].len < root[RIGHT_LEAF(index)].len ? RIGHT_LEAF(index) : LEFT_LEAF(index);
    }
    
}

root[index].len = 0;//标记节点为已使用
// page上的偏移，表示第几个页
*page_num = (index + 1) * node_size - root->size;
*parent_page_num = (PARENT(index) + 1) * node_size*2 - root->size;
```
> buddy_free_pages 释放页时

将对应页的PG_property置位，然后从树节点向上合并freelist中的页，将左右孩子节点合并为一个大节点。  
以上过程在代码上的体现如下：

``` c
while (buddy_index) // 向上合并
{
    buddy_index = PARENT(buddy_index);
    node_size *= 2;
    int left_longest = root[LEFT_LEAF(buddy_index)].len;
    int right_longest = root[RIGHT_LEAF(buddy_index)].len;
    if (left_longest + right_longest == node_size) // 进行合并
    {
        root[buddy_index].len = node_size;
        int left_page_num = (LEFT_LEAF(buddy_index) + 1) * node_size/2 - root->size; //左边的页号
        int right_page_num = (RIGHT_LEAF(buddy_index) + 1) * node_size/2 - root->size; //右边的页号
        struct Page* left_page = page_base + left_page_num;  //左边的页
        struct Page* right_page = page_base + right_page_num; //右边的页
        
        if (!in_freelist(left_page))
        {
            list_add_before(&(right_page->page_link), &(left_page->page_link));
        }
        if (!in_freelist(right_page))
        {
            list_add(&(left_page->page_link), &(right_page->page_link));
        }
        // 将两个节点融合
        left_page->property += right_page->property;
        right_page->property = 0;
        list_del(&right_page->page_link);
        if(right_page-page_base == 1)
            cprintf("in free:--------------------clear--------------------\n");
        cprintf("in free:right_page:%d\n",right_page - page_base);
        ClearPageProperty(right_page);
    }
    else    // 没有操作
        root[buddy_index].len = MAX(left_longest, right_longest);
}
```

基本的实现参考了给出的参考链接，可以参见上文对于buddy system的分析。

### buddy_system实现2 -- 唐明昊实现
充分复用[参考资料](https://github.com/wuwenbin/buddy2)所给代码，略微调整封装好的`buddy2_new`，`buddy2_alloc`，`buddy2_free`等函数，在自己实现的`buddy_pmm_manager`中进行调用以完成对应的`buddy_init_memmap`，`buddy_alloc_pages`，`buddy_free_pages`函数功能。  

#### init
`buddy_init_memmap`函数用于初始化Pages结构体，初始化buddy系统，即其对应的树结构。  
函数前面部分基本上复用了`default_pmm`的代码，在最后调整n为2的幂并调用`buddy2_new`函数初始化buddy系统。  
`buddy2_new`函数即是参考资料中用来初始化buddy对应树形结构的函数，设置**buddy树**中每个位置longest字段的值。  

```C
static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) { // 初始化每一页
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = 0; // base是空闲块的第一页，property记录了空闲块的大小->不需要了，我用property记录管辖大小
    //SetPageProperty(base);
    nr_free += n; // 空闲块总数

    if (list_empty(&free_list)) { // freelist只加了base
        list_add(&free_list, &(base->page_link));
    } 
    else { // freelist不为空，找到合适的位置插入
        list_entry_t* le = &free_list; // 从头开始遍历
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link); // le2page是一个宏，用来把list_entry转换成Page
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    if(IS_POWER_OF_2(n)) // 如果是2的幂次方，那么就可以用来初始化树
        buddy_new(n);
    else // fixsize是大于n的最小2幂次方，不应该大于n
        buddy_new(fixsize(n)>>1);
    total_size=n;
}
```

前面提到基本复用`default_pmm`代码，但仍然有所更改：因为有了buddy树(数组)来控制每一页的状态，所以原来的Pages结构体很多字段对于系统来说并没有意义而不用维护。具体来说，**空闲块的状态确定、寻址完全可以交由buddy树来完成**，所以不需要维护free_list，进而也不需要维护flag字段，因为并不需要确定是否是某块的第一页。  
free_list的维护还使用了property字段，用来记录空闲块的大小。为了方便`buddy_free_pages`时不用去buddy树中确认块大小，我**复用**了该字段用来记录该块占用的页数。另外，free_list指针在我的实现里也被**复用**用来负责指向第一页(base)，主要是为了方便分配时找到对应页，回收时计算偏移量，具体见后文介绍。

#### alloc
相比`default_alloc_pages`函数，因为有了`buddy2_alloc`管理buddy树，buddy分配函数更加简洁。  
首先，将需要分配的页大小调整到2的幂次方，然后调用`buddy2_alloc`函数得到合适的**空闲块偏移量**。（`buddy2_alloc`函数已经在buddy树里对块进行了划分管理）  
接着将pages的第一页base加上偏移量，即可得到pages结构体中需要管理的空闲块的第一页，然后将空闲块大小记录在property字段中，最后返回该页。

```C
static struct Page *
buddy_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    // 把n调整到合适大小，本来在buddy2_alloc里，拿出来
    if (n <= 0)
        n = 1;
    else if (!IS_POWER_OF_2(n)) // 不为2的幂时，向上取
        n = fixsize(n);
    // 找到合适的空闲块
    unsigned long offset = buddy2_alloc(root, n);

    list_entry_t *le = &free_list;
    struct Page *base = le2page(list_next(le), page_link);
    struct Page *page = base+offset; // 找到空闲块的第一页
    cprintf("alloc page offset %ld\n",offset);

    // 如果找到了合适的空闲块，就从空闲块中分配出需要的页
    nr_free -= n; // 总的空闲块数减少
    page->property = n; // 记录空闲块的大小
    //ClearPageProperty(page);
    return page;
}
```

#### free
释放内存时，由给定块首页page的property字段得到块的大小，然后依次释放后续n页。  
接着由page减去pages的第一页base得到偏移量，**调用`buddy2_free`函数调整buddy树的节点信息**。
```C
static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    n = base->property; // 释放块的大小

    struct buddy2* self=root;
    list_entry_t *le=&free_list;
    struct Page *base_page = le2page(list_next(le), page_link); // 拿到page头
    unsigned int offset= base - base_page; // 释放块的偏移量
    cprintf("free page offset %d\n),",offset);
    assert(self&&offset >= 0&&offset < self->size); // 是否合法
    
    struct Page *p = base;
    for (; p != base + n; p ++) { // 释放每一页
        //assert(!PageReserved(p)&&!PageProperty(p)); // flag位对算法来说没用，root里已经有了；维护成本还高
        assert(!PageReserved(p));
        //p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = 0; // 当前页不再管辖任何空闲块
    //SetPageProperty(base);
    nr_free += n;

    buddy2_free(self, offset); // 释放空闲块
}
```

实现的完整代码见[GitHub对应分支](https://github.com/easymoneysnipertang/OperatingSystem/tree/tang/riscv64-ucore-labcodes/lab2/kern/mm)。



### buddy_system实现3 -- 姜永韩实现
利用[参考资料](https://github.com/wuwenbin/buddy2)所给代码，在其基础上修改`buddy2_new`生成初始化Buddy System二叉树函数，修改`buddy2_alloc`生成内存分配函数，修改`buddy2_free`生成内存释放函数，从而在ucore上实现Buddy System。  

首先在buddy_pmm.c中声明一个全局的数据结构为buddy2的变量self，其包含了一个数组longest记录每个节点可用page数，和整个内存分配空间的page总数。

1. **对于buddy2_init初始化函数**，首先将给定的page总数n，通过closestPowerOfTwo(n)计算得到最接近n的2的次幂size，从而构建二叉树，由于共有size个page，所以二叉树共有2*size个节点。

```C
void buddy2_init(struct Page *base, size_t n) {
    unsigned int node_size;
    //创建一个2的整数次幂的二叉树
    size=closestPowerOfTwo(n);
    nr_free=size;
    struct Page *p = base;
    // 初始化每一页
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }

    base->property = n;
    size_t i;
    if (size < 1 || !IS_POWER_OF_2(size))
        return;
    
    self.size = size;
    node_size = size * 2;
    for (i = 0; i < 2 * size - 1; ++i) {
        if (IS_POWER_OF_2(i+1))
            node_size /= 2;
        self.longest[i] = node_size;
    }
    //初始化内存管理的首个page
    pages_base=base;
}
```

2. **对于buddy2_alloc分配函数**，通过需要的page数量，计算最接近且大于其的2的次幂，然后在二叉树寻找适合的节点，通过该节点的index，计算得到该节点对应的首个page的offset，将offset加上pages_base，得到最终分配的首个page地址，然后向上更新父节点可以利用page大小，知道根节点。
```C
static struct Page *
buddy2_alloc(size_t size) {
    struct Page *page = NULL;
    unsigned int index = 0;
    unsigned int node_size;
    unsigned int offset = 0;

    if (size <= 0)
        size = 1;
    else if (!IS_POWER_OF_2(size))
            size = fixsize(size);
    if (self.longest[index] < size)
        return NULL;
    for(node_size = self.size; node_size != size; node_size /= 2 ) {
        if (self.longest[LEFT_LEAF(index)] >= size)
            index = LEFT_LEAF(index);
        else
            index = RIGHT_LEAF(index);
    }
    //将buddysystem页数更新
    nr_free-=size;
    self.longest[index] = 0;

    offset = (index + 1) * node_size - self.size;
    while (index) {
        index = PARENT(index);
        self.longest[index] =
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
    }
    page=offset+pages_base;
    ClearPageProperty(page);
    page->property=size;
    return page;
}
```

3. **对于buddy2_free释放函数**，首先可以根据首个Page的地址计算出相对pages_base的偏移，通过该偏移得到对应该page的二叉树的叶子节点，通过该叶子节点，向上查找，直到找到一个节点其可分配page数为0，该节点即为需要释放的内存，更新该节点的size，从而释放掉这些page，然后不断更新父节点的可分配page数。

```C
static void buddy2_free(struct Page *pg) {
    //计算给定页数的偏移
    unsigned int offset=(pg-pages_base);
    unsigned int node_size, index = 0;
    unsigned int left_longest, right_longest;
    bool temp= offset >= 0 && offset < size;
    assert(temp);
    node_size = 1;
    index = offset + self.size - 1;

    for (; self.longest[index] ; index = PARENT(index)) {
        node_size *= 2;
        if (index == 0)
            return;
    }
    self.longest[index] = node_size;
    struct Page *p = pg;
    
    for (; p != pg + node_size; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    //将buddysystem页数更新
    nr_free+=node_size;

    while (index){
    index = PARENT(index);
    node_size *= 2;
    left_longest = self.longest[LEFT_LEAF(index)];
    right_longest = self.longest[RIGHT_LEAF(index)];
    if (left_longest + right_longest == node_size)
        self.longest[index] = node_size;
    else
        self.longest[index] = MAX(left_longest, right_longest);
    }
}
```


### buddy_system测试

**测试用例设计如下：**  
1. 首先申请 p0 p1 p2 p3，其大小为 70 35 257 63，
从前向后分配的块及其大小，以及对应的页如下所示：
 
| 64+64 | 64 | 64 | 256 | 512 |
| ----- | ----- | ----- | ----- | ----- |
| p0    | p1 | p3 |     | p2  |   

2. 然后释放p0、p1、p3，这时候前512个页已经空了。  

3. 然后我们申请 p4 p5，其大小为 255 255，那么这时候系统的内存空间是这样的：

|256 |256 |256 |
|-----|-----|-----|
| p4 | p5 | p2 |


4. 最后释放所有page，通过断言机制assert()判定不同块的首地址。
```C
static void basic_check(void){
    struct Page *p0, *p1,*p2;
    p0 = p1 = NULL;
    p2=NULL;
    struct Page *p3, *p4,*p5;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);
    free_page(p0);
    free_page(p1);
    free_page(p2);
    
    p0=alloc_pages(70);
    p1=alloc_pages(35);
    assert((p1-p0)==128);  // 通过分配策略可知两个page相差128
    
    p2=alloc_pages(257);
    cprintf("p2 %p\n",p2);
    assert((p2-p1)==384);  // p2和p1应当相差256+128
    
    p3=alloc_pages(63);
    cprintf("p3 %p\n",p3);
     assert((p3-p1)==64);  // p3和p1相差64
    
    free_pages(p0,70);    
    cprintf("free p0!\n");
    free_pages(p1,35);
    cprintf("free p1!\n");
    free_pages(p3,63);    
    cprintf("free p3!\n");
    
    p4=alloc_pages(255);
    cprintf("p4 %p\n",p4);
    assert((p2-p4)==512);  // p2和p4差512
    
    p5=alloc_pages(255);
    cprintf("p5 %p\n",p5);
    assert((p5-p4)==256);  // p5和p6应该差256
        free_pages(p2,257);    
    cprintf("free p2!\n");
        free_pages(p4,255);    
    cprintf("free p4!\n"); 
            free_pages(p5,255);    
    cprintf("free p5!\n");   
    cprintf("CHECK DONE!\n") ;
```


## challenge2
### 80386时代

- 早期由CPU主动探测：向它认为可能有内存的地址写55aa序列，接着扫描读取，如果读回来的仍是55aa，说明此处内存可用，更新内存表格。
- 后续转由BIOS来进行内存探测，系统调用int15，也是通过写入55aa，读取来判断内存是否可用。
- 再后来主板厂商开始与内存厂商约定，使用SPD芯片来记录内存信息：   
   1. BIOS扫描内存插槽确定内存模块。
   2. 接着BIOS读取SPD芯片的信息来获取内存信息并将其存储在内存表中。  
   3. BIOS将保存了内存模块起始地址、大小等属性的内存表传递给操作系统。

### RISCV
一种路线：  
1. 不依赖BIOS，由硬件开发者编写device tree source code，描述硬件配置包括内存布局。  
2. 该文件通常为树形结构，不同节点描述不同的硬件组件。  
3. 使用DT compiler将其编译成device tree blob二进制格式。  
4. Bootloader将DTB加载到内存某个特定位置，或将位置传递给内核。  
5. 内核通过解析DTB来获取硬件信息，包括内存布局。

查看qemu源码，发现在pc-bios文件夹下有[dts文件](src/bamboo.dts)：可以看到QEMU虚拟化了AMCC Bamboo硬件平台，该设备树文件描述了CPU、内存、中断控制器、PCI控制器、以太网接口等硬件信息。  

另一种路线：  
- SBI提供sbi_query_memory接口，类似于BIOS提供的内存检测功能。

