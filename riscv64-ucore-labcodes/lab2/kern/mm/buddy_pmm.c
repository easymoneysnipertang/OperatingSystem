#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_pmm.h>
#include <sbi.h>

// offset=(index+1)*node_size – size。
// 式中索引的下标均从0开始，size为内存总大小，node_size为内存块对应大小。
#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define UINT32_SHR_OR(a,n)      ((a)|((a)>>(n)))//右移n位  

#define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//大于a的一个最小的2^k
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))//小于a的最大的2^k

static unsigned fixsize(unsigned size) 
{
    size |= size >> 1;
    size |= size >> 2;
    size |= size >> 4;
    size |= size >> 8;
    size |= size >> 16;
    return size+1;
}


struct buddy2 {
  unsigned size;//表明管理内存
  unsigned len; 
};
struct buddy2 root[40000];//存放二叉树的数组，用于内存分配

int nr_block;//已分配的块数
free_area_t free_area; // 待分配区域
struct Page* page_base;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
buddy_init(void){
    list_init(&free_list);
    nr_free = 0;
}

//初始化二叉树上的节点
void buddy2_new( int size ) {
    unsigned node_size;
    int i;
    nr_block=0;
    if (size < 1 || !IS_POWER_OF_2(size)) //规格不对
        return;

    root[0].size = size;
    node_size = size * 2;

    for (i = 0; i < 2 * size - 1; ++i) 
    {
        if (IS_POWER_OF_2(i+1))
            node_size /= 2;
        root[i].len = node_size;
    }
}


static void
buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    n = UINT32_ROUND_DOWN(n);
    // 检查页面的使用情况
    struct Page *p = page_base = base;
    for (; p != base + n; p ++) 
    {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    list_add(&free_list, &(base->page_link));
    buddy2_new(n);
}


//内存分配
void buddy2_alloc(struct buddy2* root, int size, int* page_num, int* parent_page_num) {
    unsigned index = 0;//节点的标号
    unsigned node_size;

    if (root==NULL)//无法分配
        return;

    if (size <= 0)//分配不合理
        return;
    if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
        size = fixsize(size);

    if (root[index].len < size)//可分配内存不足
        return;

    
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

    //向上刷新，修改先祖结点的数值
    while (index) 
    {
        index = PARENT(index);
        root[index].len = MAX(root[LEFT_LEAF(index)].len, root[RIGHT_LEAF(index)].len);
    }
}

static struct Page *
buddy_alloc_pages(size_t n) 
{
    // n大于0
    assert(n>0);
    // n小于剩余块
    if(n>nr_free)
        return NULL;
    // n为2整数次幂
    if(!IS_POWER_OF_2(n))
        n=fixsize(n);
    // 要分配的page，以及parent_page
    struct Page* page, *parent_page;
    //页的序号
    int page_num, parent_page_num;

    // 记录偏移量
    //buddy2_alloc(root, n, rec[nr_block].offset,parent_page_num);    //rec暂时没懂要干啥
    buddy2_alloc(root, n, &page_num, &parent_page_num);

    // 从这个页开始分配
    page = page_base + page_num;
    parent_page = page_base + parent_page_num;
    cprintf("in alloc pages: page_num:%d, parent_page_num:%d\n",page_num,parent_page_num);

    //根据需求n得到块大小
    nr_block++;

    if (page->property != n ) //还有剩余
    {
        if (page == parent_page) //说明page是parent_page的左孩子
        {
            // 将右节点连入链表
            struct Page *right_page = page + n;
            right_page->property = n;
            list_entry_t *prev = list_prev(&(page->page_link));
            list_del(&page->page_link);
            list_add(prev, &(right_page->page_link));
            if(right_page-page_base == 1)
                cprintf("in alloc pages:--------------------set--------------------\n");
            SetPageProperty(right_page);
        }
        else // page>parent_page，说明page是parent_page的右孩子
        {
            // 更改左节点property
            parent_page -> property /= 2;
        }
    }
    else //说明全部分配
    {
        list_del(&page->page_link);
    }
    if(page-page_base == 1)
        cprintf("in alloc pages:--------------------clear--------------------\n");
    ClearPageProperty(page);
    cprintf("in alloc: page_num:%d , property:%d \n",page-page_base, PageProperty(page));

    nr_free -= n;//减去已被分配的页数
    return page; 
}

int in_freelist(struct Page* p)
{
    if (list_prev(&p->page_link) == NULL) //不在表中
        return 0;
    
    return list_next(list_prev(&p->page_link))==&p->page_link;
}

static void
buddy_free_pages(struct Page *base, size_t n)
{
    assert(n>0);
    if (!IS_POWER_OF_2(n))
        n = fixsize(n);
    assert(base >= page_base && base < page_base + root->size);
    //对base其实也有约束    
    int div_seg_num = root->size/n;
    int page_num = base - page_base;//第几页
    cprintf("in free: page_num: %d div_seg_num: %d, n:%d\n",page_num,div_seg_num,n);
    assert(page_num % n == 0); //必须在分位点上

    // 像default一样做一些检查
    struct Page *p = base;
    for (; p != base + n; p ++) {
        cprintf("in free: n->%d, property:%d, page_property:%d, page_num:%d\n",n,PageProperty(p),p->property, p - page_base);
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    if(base-page_base == 1)
        cprintf("in free:--------------------set--------------------\n");
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) 
    {
        list_add(&free_list, &(base->page_link));
    }
    else
    {
        int buddy_index = root->size - 1 + page_num; //该页所对应的树节点
        int node_size = n;
        root[buddy_index].len = n;
        cprintf("------------------in free here1----------------------\n");
        cprintf("in free:buddy_index:%d\n",buddy_index);
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
    }
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void) {
/*
整个测试流程如下:
首先申请 p0 p1 p2 p3
其大小为 70 35 257 63
从前向后分配的块以及其大小 |64+64|64|64|128+128|512|
其对应的页                 |p0   |p1|p3|空     |p2|
然后释放p0\p1\p3
这时候前512个页已经空了
然后我们申请 p4 p5
其大小为     255 255
那么这时候系统的内存空间是这样的
|256|256|256|
|p4 |p5 |p2 | 
最后释放。
注意，指针的地址都是块的首地址。
通过计算验证，然后将结果打印出来，较为直观。也可以通过断言机制assert()判定。
*/
cprintf(
"-----------------------------------------------------"
"\n\nThe test process is as follows:\n"
"First,alloc   p0 p1 p2  p3\n"
"sizes of them 70 35 257 63\n"
"the buddy block:    |64+64|64|64|128+128|512|\n"
"the pages we alloc: |p0   |p1|p3|empty  |p2|\n"
"then,free. p0 p1 p3\n"
"now,the first 512 pages are free\n"
"then alloc:     p4  p5\n"
"sizes of the:   255 255\n"
"now,the distribution in memory space are below:\n"
"|256|256|256|\n"
"|p4 |p5 |p2 |\n"
"Last,free all buddy blocks.\n"
"Notice!addr of pointer is the base addr of the buddy block\n"
"we use cprintf() show the progress and if you want, you can use assert() to judge.\n\n"
"------------------------------------------------------\n");

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
    cprintf("CHECK DONE!\n"
"-----------------------------------------------------\n") ;
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