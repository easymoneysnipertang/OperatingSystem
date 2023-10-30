#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>
#include <sbi.h>


list_entry_t pra_list_head;

static int
_lru_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
     //cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
     return 0;
}

static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation

    list_add(head, entry);
    return 0;
}

static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */

    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}

static int
_lru_check_swap(void) {
    //pte_t* ptep = get_pte()
    // 页面状态：d1 c1 b1 a1
    // 假设发生一次时钟中断，导致lru
    swap_tick_event(check_mm_struct);
    // 页面状态：a0 b0 c0 d0

    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);

    // 页面状态：e1 a0 b0 c0
    cprintf("write Virt Page c and set Access bit\n");
    pte_t *ptep = get_pte(check_mm_struct->pgdir, 0x3000, 0);
    *ptep |= PTE_A;
    // 页面状态：e1 a0 b0 c1

    // 假设发生一次时钟中断，导致lru
    swap_tick_event(check_mm_struct);
    // 页面状态：c0 e0 a0 b0

    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0e;
    assert(pgfault_num==6);
    // 页面状态：d1 c0 e0 a0

    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0e;
    assert(pgfault_num==7);

    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ 
    list_entry_t* head = (list_entry_t*)mm->sm_priv;
    list_entry_t* cur = head;
    while (cur->next != head)
    {
        cur = cur->next;
        struct Page* page = le2page(cur, pra_page_link);
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
        if (*ptep & PTE_A)      //页面在一段时间内被访问了，拿到最前，置零
        {
            list_entry_t* temp = cur->prev;
            list_del(cur);
            *ptep &= ~PTE_A;
            list_add(head, cur);
            cur = temp;
        }
        // cprintf("here in lru_tick_event\n");
    }
    return 0;
}


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
};