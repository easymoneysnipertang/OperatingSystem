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
