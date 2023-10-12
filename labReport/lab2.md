# Lab2


## challenge1
> Buddy System 算法把系统中的可用存储空间划分为存储块 (Block) 来进行管理, 每个存储块的大小必须是 2 的 n 次幂 (Pow(2, n)), 即 1, 2, 4, 8, 16, 32, 64, 128…  
参考[伙伴分配器的一个极简实现](https://github.com/wuwenbin/buddy2)，在 ucore 中实现 buddy system 分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

### buddy_system实现1 -- 朱世豪实现

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

实现的完整代码见GitHub。



### buddy_system实现3 -- 姜永韩实现

### buddy_system测试