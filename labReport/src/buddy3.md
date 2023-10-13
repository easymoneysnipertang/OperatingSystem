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
