#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>
#include <defs.h>


free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// 参考资料中的宏定义
#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

static unsigned fixsize(unsigned size) {
  size |= size >> 1;
  size |= size >> 2;
  size |= size >> 4;
  size |= size >> 8;
  size |= size >> 16;
  return size+1;
}

struct buddy2
{
    unsigned size;
    unsigned longest;
};
struct buddy2 root[40000]; //存放二叉树的数组，用于内存分配
int total_size=0; //记录总的空闲块数


static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

// 初始化树
void buddy_new( int size ) {
    // size是buddy system的总空闲空间；node_size是对应节点所表示的空闲空间的块数
    unsigned node_size; 
    int i;
    //nr_block=0;
    if (size < 1 || !IS_POWER_OF_2(size))
        return;

    root[0].size = size;
    node_size = size * 2;   // 总结点数是size*2
    // TODO：其实可以在这里手动开辟空间

    // 初始化每个节点管理的空闲空间块数
    for (i = 0; i < 2 * size - 1; ++i) {
        if (IS_POWER_OF_2(i+1)) // 下一层
            node_size /= 2;
        // longest代表该节点所表示的初始空闲空间块数
        root[i].longest = node_size;   
    }
    return;
}

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

    if(IS_POWER_OF_2(n)) { // 如果是2的幂次方，那么就可以用来初始化树
        buddy_new(n);
    }
    else{ // fixsize是大于n的最小2幂次方，不应该大于n
        buddy_new(fixsize(n)>>1);
    }
    total_size=n;
    
}


static int
buddy2_alloc(struct buddy2* self, int size){
    unsigned index = 0;  // 节点在树上的索引
    unsigned node_size;  // 记录一层的大小
    unsigned offset = 0;

    if (self==NULL)
        return -1;
    if (self[index].longest < size) // 根节点的longest内存都不足，直接返回
        return -1;

    // 从根节点开始，向下搜索左右子树，找到合适的节点
    for(node_size = self->size; node_size != size; node_size /= 2 ) {
        if (self[LEFT_LEAF(index)].longest >= size){
            // 参考资料的bug处，应该找最合适的节点
            if(self[RIGHT_LEAF(index)].longest>=size)
                index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
                //找到两个相符合的节点中内存较小的结点
            else
                index=LEFT_LEAF(index);
        }
        else
            index = RIGHT_LEAF(index);
    }
    // 找到节点，标记为已使用
    self[index].longest = 0;
    // 得到最底层链表的便宜量
    offset = (index + 1) * node_size - self->size;  
    // 层层向上回溯，改变父节点的longest值
    while (index) {
        index = PARENT(index);
        self[index].longest = 
        MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
    }
    return offset;
}

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


static void
buddy2_free(struct buddy2* self, int offset){
    unsigned node_size, index;
    unsigned left_longest, right_longest;

    //实际的双链表信息复原后，还要对“二叉树”里面的节点信息进行更新
    node_size = 1;
    index = offset + self->size - 1;   //从原始的分配节点的最底节点开始改变longest
    self[index].longest = node_size;   //这里应该是node_size，也就是从1那层开始改变
    while (index) {//向上合并，修改父节点的记录值
        index = PARENT(index);
        node_size *= 2;
        left_longest = self[LEFT_LEAF(index)].longest;
        right_longest = self[RIGHT_LEAF(index)].longest;
        
        if (left_longest + right_longest == node_size) 
            self[index].longest = node_size;
        else
            self[index].longest = MAX(left_longest, right_longest);
    }
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    struct buddy2* self=root;
    list_entry_t *le=&free_list;
    struct Page *base_page = le2page(list_next(le), page_link); // 拿到page头
    unsigned int offset= base - base_page; // 释放块的偏移量
    cprintf("free page offset %d\n),",offset);

    if(!IS_POWER_OF_2(n))
        n=fixsize(n);
    assert(self&&offset >= 0&&offset < self->size); // 是否合法
    
    struct Page *p = base;
    for (; p != base + n; p ++) { // 释放每一页
        // if(PageProperty(p))
        //     cprintf("free page %d\n",p-base); // test
        //assert(!PageReserved(p)&&!PageProperty(p)); // flag位对算法来说没用，root里已经有了；维护成本还高
        assert(!PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = 0; // 当前页不再管辖任何空闲块
    //SetPageProperty(base);
    nr_free += n;

    buddy2_free(self, offset); // 释放空闲块
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}


static void
buddy_check(void) {
    // struct Page  *A, *B;
    // A = B  =NULL;

    // assert((A = alloc_page()) != NULL);
    // assert((B = alloc_page()) != NULL);

    // assert( A != B);
    // assert(page_ref(A) == 0 && page_ref(B) == 0);
    // //free page就是free pages(A,1)
    // free_page(A);
    // free_page(B);
    
    
    // cprintf("*******************************Check begin***************************\n");
    // //A=alloc_pages(500);     //alloc_pages返回的是开始分配的那一页的地址
    // A=alloc_pages(70);
    // //B=alloc_pages(500);
    // B=alloc_pages(35);
    // cprintf("A %p\n",A);
    // cprintf("B %p\n",B);
    // cprintf("********************************Check End****************************\n");

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
    //注意，一个结构体指针是20个字节，有3个int,3*4，还有一个双向链表,两个指针是8。加载一起是20。
    cprintf("p0 %p\n",p0);
    cprintf("p1 %p\n",p1);
    cprintf("p1-p0 equal %p ?=128\n",p1-p0);//应该差128
    
    p2=alloc_pages(257);
    cprintf("p2 %p\n",p2);
    cprintf("p2-p1 equal %p ?=128+256\n",p2-p1);//应该差384
    
    p3=alloc_pages(63);
    cprintf("p3 %p\n",p3);
    cprintf("p3-p1 equal %p ?=64\n",p3-p1);//应该差64
    
    free_pages(p0,70);    
    cprintf("free p0!\n");
    free_pages(p1,35);
    cprintf("free p1!\n");
    free_pages(p3,63);    
    cprintf("free p3!\n");
    
    p4=alloc_pages(255);
    cprintf("p4 %p\n",p4);
    cprintf("p2-p4 equal %p ?=512\n",p2-p4);//应该差512
    
    p5=alloc_pages(255);
    cprintf("p5 %p\n",p5);
    cprintf("p5-p4 equal %p ?=256\n",p5-p4);//应该差256
        free_pages(p2,257);    
    cprintf("free p2!\n");
        free_pages(p4,255);    
    cprintf("free p4!\n"); 
            free_pages(p5,255);    
    cprintf("free p5!\n");   
    cprintf("CHECK DONE!\n") ;

}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

