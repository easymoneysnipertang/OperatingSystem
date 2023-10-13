
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00028617          	auipc	a2,0x28
ffffffffc0200042:	71a60613          	addi	a2,a2,1818 # ffffffffc0228758 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	650010ef          	jal	ra,ffffffffc020169e <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	65a50513          	addi	a0,a0,1626 # ffffffffc02016b0 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	673000ef          	jal	ra,ffffffffc0200edc <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	0e6010ef          	jal	ra,ffffffffc0201190 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	0b2010ef          	jal	ra,ffffffffc0201190 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00001517          	auipc	a0,0x1
ffffffffc0200144:	5c050513          	addi	a0,a0,1472 # ffffffffc0201700 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0201720 <etext+0x70>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	54e58593          	addi	a1,a1,1358 # ffffffffc02016b0 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	5d650513          	addi	a0,a0,1494 # ffffffffc0201740 <etext+0x90>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	5e250513          	addi	a0,a0,1506 # ffffffffc0201760 <etext+0xb0>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00028597          	auipc	a1,0x28
ffffffffc020018e:	5ce58593          	addi	a1,a1,1486 # ffffffffc0228758 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	5ee50513          	addi	a0,a0,1518 # ffffffffc0201780 <etext+0xd0>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00029597          	auipc	a1,0x29
ffffffffc02001a2:	9b958593          	addi	a1,a1,-1607 # ffffffffc0228b57 <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00001517          	auipc	a0,0x1
ffffffffc02001c4:	5e050513          	addi	a0,a0,1504 # ffffffffc02017a0 <etext+0xf0>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00001617          	auipc	a2,0x1
ffffffffc02001d4:	50060613          	addi	a2,a2,1280 # ffffffffc02016d0 <etext+0x20>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	50c50513          	addi	a0,a0,1292 # ffffffffc02016e8 <etext+0x38>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00001617          	auipc	a2,0x1
ffffffffc02001f0:	6c460613          	addi	a2,a2,1732 # ffffffffc02018b0 <commands+0xe0>
ffffffffc02001f4:	00001597          	auipc	a1,0x1
ffffffffc02001f8:	6dc58593          	addi	a1,a1,1756 # ffffffffc02018d0 <commands+0x100>
ffffffffc02001fc:	00001517          	auipc	a0,0x1
ffffffffc0200200:	6dc50513          	addi	a0,a0,1756 # ffffffffc02018d8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00001617          	auipc	a2,0x1
ffffffffc020020e:	6de60613          	addi	a2,a2,1758 # ffffffffc02018e8 <commands+0x118>
ffffffffc0200212:	00001597          	auipc	a1,0x1
ffffffffc0200216:	6fe58593          	addi	a1,a1,1790 # ffffffffc0201910 <commands+0x140>
ffffffffc020021a:	00001517          	auipc	a0,0x1
ffffffffc020021e:	6be50513          	addi	a0,a0,1726 # ffffffffc02018d8 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00001617          	auipc	a2,0x1
ffffffffc020022a:	6fa60613          	addi	a2,a2,1786 # ffffffffc0201920 <commands+0x150>
ffffffffc020022e:	00001597          	auipc	a1,0x1
ffffffffc0200232:	71258593          	addi	a1,a1,1810 # ffffffffc0201940 <commands+0x170>
ffffffffc0200236:	00001517          	auipc	a0,0x1
ffffffffc020023a:	6a250513          	addi	a0,a0,1698 # ffffffffc02018d8 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00001517          	auipc	a0,0x1
ffffffffc0200274:	5a850513          	addi	a0,a0,1448 # ffffffffc0201818 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00001517          	auipc	a0,0x1
ffffffffc0200296:	5ae50513          	addi	a0,a0,1454 # ffffffffc0201840 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	528c8c93          	addi	s9,s9,1320 # ffffffffc02017d0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	5b898993          	addi	s3,s3,1464 # ffffffffc0201868 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	5b890913          	addi	s2,s2,1464 # ffffffffc0201870 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	5b6b0b13          	addi	s6,s6,1462 # ffffffffc0201878 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	606a8a93          	addi	s5,s5,1542 # ffffffffc02018d0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	246010ef          	jal	ra,ffffffffc020151c <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	398010ef          	jal	ra,ffffffffc0201680 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	4d2d0d13          	addi	s10,s10,1234 # ffffffffc02017d0 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	34a010ef          	jal	ra,ffffffffc0201656 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	336010ef          	jal	ra,ffffffffc0201656 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	2fa010ef          	jal	ra,ffffffffc0201680 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	4fa50513          	addi	a0,a0,1274 # ffffffffc0201898 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06430313          	addi	t1,t1,100 # ffffffffc0206410 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72023          	sw	a5,64(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00001517          	auipc	a0,0x1
ffffffffc02003e2:	57250513          	addi	a0,a0,1394 # ffffffffc0201950 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	d6450513          	addi	a0,a0,-668 # ffffffffc0202158 <commands+0x988>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	1d2010ef          	jal	ra,ffffffffc02015f6 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	53e50513          	addi	a0,a0,1342 # ffffffffc0201970 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	1aa0106f          	j	ffffffffc02015f6 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	1840106f          	j	ffffffffc02015da <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	1b80106f          	j	ffffffffc0201612 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00001517          	auipc	a0,0x1
ffffffffc0200488:	60450513          	addi	a0,a0,1540 # ffffffffc0201a88 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00001517          	auipc	a0,0x1
ffffffffc0200498:	60c50513          	addi	a0,a0,1548 # ffffffffc0201aa0 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00001517          	auipc	a0,0x1
ffffffffc02004a6:	61650513          	addi	a0,a0,1558 # ffffffffc0201ab8 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00001517          	auipc	a0,0x1
ffffffffc02004b4:	62050513          	addi	a0,a0,1568 # ffffffffc0201ad0 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00001517          	auipc	a0,0x1
ffffffffc02004c2:	62a50513          	addi	a0,a0,1578 # ffffffffc0201ae8 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00001517          	auipc	a0,0x1
ffffffffc02004d0:	63450513          	addi	a0,a0,1588 # ffffffffc0201b00 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00001517          	auipc	a0,0x1
ffffffffc02004de:	63e50513          	addi	a0,a0,1598 # ffffffffc0201b18 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00001517          	auipc	a0,0x1
ffffffffc02004ec:	64850513          	addi	a0,a0,1608 # ffffffffc0201b30 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00001517          	auipc	a0,0x1
ffffffffc02004fa:	65250513          	addi	a0,a0,1618 # ffffffffc0201b48 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00001517          	auipc	a0,0x1
ffffffffc0200508:	65c50513          	addi	a0,a0,1628 # ffffffffc0201b60 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00001517          	auipc	a0,0x1
ffffffffc0200516:	66650513          	addi	a0,a0,1638 # ffffffffc0201b78 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00001517          	auipc	a0,0x1
ffffffffc0200524:	67050513          	addi	a0,a0,1648 # ffffffffc0201b90 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00001517          	auipc	a0,0x1
ffffffffc0200532:	67a50513          	addi	a0,a0,1658 # ffffffffc0201ba8 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	68450513          	addi	a0,a0,1668 # ffffffffc0201bc0 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00001517          	auipc	a0,0x1
ffffffffc020054e:	68e50513          	addi	a0,a0,1678 # ffffffffc0201bd8 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00001517          	auipc	a0,0x1
ffffffffc020055c:	69850513          	addi	a0,a0,1688 # ffffffffc0201bf0 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00001517          	auipc	a0,0x1
ffffffffc020056a:	6a250513          	addi	a0,a0,1698 # ffffffffc0201c08 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00001517          	auipc	a0,0x1
ffffffffc0200578:	6ac50513          	addi	a0,a0,1708 # ffffffffc0201c20 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00001517          	auipc	a0,0x1
ffffffffc0200586:	6b650513          	addi	a0,a0,1718 # ffffffffc0201c38 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00001517          	auipc	a0,0x1
ffffffffc0200594:	6c050513          	addi	a0,a0,1728 # ffffffffc0201c50 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00001517          	auipc	a0,0x1
ffffffffc02005a2:	6ca50513          	addi	a0,a0,1738 # ffffffffc0201c68 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00001517          	auipc	a0,0x1
ffffffffc02005b0:	6d450513          	addi	a0,a0,1748 # ffffffffc0201c80 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00001517          	auipc	a0,0x1
ffffffffc02005be:	6de50513          	addi	a0,a0,1758 # ffffffffc0201c98 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00001517          	auipc	a0,0x1
ffffffffc02005cc:	6e850513          	addi	a0,a0,1768 # ffffffffc0201cb0 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00001517          	auipc	a0,0x1
ffffffffc02005da:	6f250513          	addi	a0,a0,1778 # ffffffffc0201cc8 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00001517          	auipc	a0,0x1
ffffffffc02005e8:	6fc50513          	addi	a0,a0,1788 # ffffffffc0201ce0 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00001517          	auipc	a0,0x1
ffffffffc02005f6:	70650513          	addi	a0,a0,1798 # ffffffffc0201cf8 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00001517          	auipc	a0,0x1
ffffffffc0200604:	71050513          	addi	a0,a0,1808 # ffffffffc0201d10 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00001517          	auipc	a0,0x1
ffffffffc0200612:	71a50513          	addi	a0,a0,1818 # ffffffffc0201d28 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00001517          	auipc	a0,0x1
ffffffffc0200620:	72450513          	addi	a0,a0,1828 # ffffffffc0201d40 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00001517          	auipc	a0,0x1
ffffffffc020062e:	72e50513          	addi	a0,a0,1838 # ffffffffc0201d58 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00001517          	auipc	a0,0x1
ffffffffc0200640:	73450513          	addi	a0,a0,1844 # ffffffffc0201d70 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	73650513          	addi	a0,a0,1846 # ffffffffc0201d88 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00001517          	auipc	a0,0x1
ffffffffc020066e:	73650513          	addi	a0,a0,1846 # ffffffffc0201da0 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	73e50513          	addi	a0,a0,1854 # ffffffffc0201db8 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	74650513          	addi	a0,a0,1862 # ffffffffc0201dd0 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	74a50513          	addi	a0,a0,1866 # ffffffffc0201de8 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	2d070713          	addi	a4,a4,720 # ffffffffc020198c <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	35250513          	addi	a0,a0,850 # ffffffffc0201a20 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	32650513          	addi	a0,a0,806 # ffffffffc0201a00 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	2da50513          	addi	a0,a0,730 # ffffffffc02019c0 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	34e50513          	addi	a0,a0,846 # ffffffffc0201a40 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d2a78793          	addi	a5,a5,-726 # ffffffffc0206430 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bb23          	sd	a5,-746(a3) # ffffffffc0206430 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	33e50513          	addi	a0,a0,830 # ffffffffc0201a68 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	2aa50513          	addi	a0,a0,682 # ffffffffc02019e0 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	30c50513          	addi	a0,a0,780 # ffffffffc0201a58 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <init>:
struct buddy2 self;

struct Page * pages_base;

void init(void){
    size=0;
ffffffffc020082a:	00028797          	auipc	a5,0x28
ffffffffc020082e:	ee07bf23          	sd	zero,-258(a5) # ffffffffc0228728 <size>
    nr_free=0;
ffffffffc0200832:	00028797          	auipc	a5,0x28
ffffffffc0200836:	ee07b723          	sd	zero,-274(a5) # ffffffffc0228720 <nr_free>
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <buddy2_alloc>:
    

}

static struct Page *
buddy2_alloc(size_t size) {
ffffffffc020083c:	85aa                	mv	a1,a0
    struct Page *page = NULL;
    unsigned int index = 0;
    unsigned int node_size;
    unsigned int offset = 0;

    if (size <= 0)
ffffffffc020083e:	10050263          	beqz	a0,ffffffffc0200942 <buddy2_alloc+0x106>
        size = 1;
    else if (!IS_POWER_OF_2(size))
ffffffffc0200842:	fff50793          	addi	a5,a0,-1
ffffffffc0200846:	8fe9                	and	a5,a5,a0
ffffffffc0200848:	10079a63          	bnez	a5,ffffffffc020095c <buddy2_alloc+0x120>
            size = fixsize(size);
    if (self.longest[index] < size)
ffffffffc020084c:	00006797          	auipc	a5,0x6
ffffffffc0200850:	bf07e783          	lwu	a5,-1040(a5) # ffffffffc020643c <self+0x4>
ffffffffc0200854:	00006617          	auipc	a2,0x6
ffffffffc0200858:	be460613          	addi	a2,a2,-1052 # ffffffffc0206438 <self>
ffffffffc020085c:	0eb7ee63          	bltu	a5,a1,ffffffffc0200958 <buddy2_alloc+0x11c>
        return NULL;
    for(node_size = self.size; node_size != size; node_size /= 2 ) {
ffffffffc0200860:	00062e03          	lw	t3,0(a2)
ffffffffc0200864:	00028797          	auipc	a5,0x28
ffffffffc0200868:	ebc78793          	addi	a5,a5,-324 # ffffffffc0228720 <nr_free>
ffffffffc020086c:	639c                	ld	a5,0(a5)
ffffffffc020086e:	020e1713          	slli	a4,t3,0x20
ffffffffc0200872:	9301                	srli	a4,a4,0x20
ffffffffc0200874:	40b78333          	sub	t1,a5,a1
ffffffffc0200878:	10e58263          	beq	a1,a4,ffffffffc020097c <buddy2_alloc+0x140>
ffffffffc020087c:	86f2                	mv	a3,t3
    unsigned int index = 0;
ffffffffc020087e:	4781                	li	a5,0
        if (self.longest[LEFT_LEAF(index)] >= size)
ffffffffc0200880:	0017951b          	slliw	a0,a5,0x1
ffffffffc0200884:	0015079b          	addiw	a5,a0,1
ffffffffc0200888:	02079713          	slli	a4,a5,0x20
ffffffffc020088c:	8379                	srli	a4,a4,0x1e
ffffffffc020088e:	9732                	add	a4,a4,a2
ffffffffc0200890:	00476883          	lwu	a7,4(a4)
    for(node_size = self.size; node_size != size; node_size /= 2 ) {
ffffffffc0200894:	0016d71b          	srliw	a4,a3,0x1
ffffffffc0200898:	02071813          	slli	a6,a4,0x20
ffffffffc020089c:	02085813          	srli	a6,a6,0x20
        if (self.longest[LEFT_LEAF(index)] >= size)
ffffffffc02008a0:	00b8f463          	bleu	a1,a7,ffffffffc02008a8 <buddy2_alloc+0x6c>
            index = LEFT_LEAF(index);
        else
            index = RIGHT_LEAF(index);
ffffffffc02008a4:	0025079b          	addiw	a5,a0,2
    for(node_size = self.size; node_size != size; node_size /= 2 ) {
ffffffffc02008a8:	0007069b          	sext.w	a3,a4
ffffffffc02008ac:	fcb81ae3          	bne	a6,a1,ffffffffc0200880 <buddy2_alloc+0x44>
    }
    //将buddysystem页数更新
    nr_free-=size;
    self.longest[index] = 0;

    offset = (index + 1) * node_size - self.size;
ffffffffc02008b0:	0017871b          	addiw	a4,a5,1
ffffffffc02008b4:	02d706bb          	mulw	a3,a4,a3
    self.longest[index] = 0;
ffffffffc02008b8:	02079513          	slli	a0,a5,0x20
ffffffffc02008bc:	8179                	srli	a0,a0,0x1e
ffffffffc02008be:	9532                	add	a0,a0,a2
ffffffffc02008c0:	00052223          	sw	zero,4(a0)
    nr_free-=size;
ffffffffc02008c4:	00028817          	auipc	a6,0x28
ffffffffc02008c8:	e4683e23          	sd	t1,-420(a6) # ffffffffc0228720 <nr_free>
    offset = (index + 1) * node_size - self.size;
ffffffffc02008cc:	41c686bb          	subw	a3,a3,t3
ffffffffc02008d0:	1682                	slli	a3,a3,0x20
ffffffffc02008d2:	9281                	srli	a3,a3,0x20
ffffffffc02008d4:	00269513          	slli	a0,a3,0x2
ffffffffc02008d8:	9536                	add	a0,a0,a3
ffffffffc02008da:	00351e93          	slli	t4,a0,0x3
    while (index) {
ffffffffc02008de:	e781                	bnez	a5,ffffffffc02008e6 <buddy2_alloc+0xaa>
ffffffffc02008e0:	a0a1                	j	ffffffffc0200928 <buddy2_alloc+0xec>
ffffffffc02008e2:	0017871b          	addiw	a4,a5,1
        index = PARENT(index);
ffffffffc02008e6:	0017579b          	srliw	a5,a4,0x1
ffffffffc02008ea:	37fd                	addiw	a5,a5,-1
        self.longest[index] =
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
ffffffffc02008ec:	0017969b          	slliw	a3,a5,0x1
ffffffffc02008f0:	9b79                	andi	a4,a4,-2
ffffffffc02008f2:	2685                	addiw	a3,a3,1
ffffffffc02008f4:	1682                	slli	a3,a3,0x20
ffffffffc02008f6:	1702                	slli	a4,a4,0x20
ffffffffc02008f8:	9281                	srli	a3,a3,0x20
ffffffffc02008fa:	9301                	srli	a4,a4,0x20
ffffffffc02008fc:	068a                	slli	a3,a3,0x2
ffffffffc02008fe:	070a                	slli	a4,a4,0x2
ffffffffc0200900:	9732                	add	a4,a4,a2
ffffffffc0200902:	96b2                	add	a3,a3,a2
ffffffffc0200904:	00472883          	lw	a7,4(a4)
ffffffffc0200908:	0046a803          	lw	a6,4(a3)
        self.longest[index] =
ffffffffc020090c:	02079713          	slli	a4,a5,0x20
ffffffffc0200910:	8379                	srli	a4,a4,0x1e
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
ffffffffc0200912:	00080e1b          	sext.w	t3,a6
ffffffffc0200916:	0008831b          	sext.w	t1,a7
        self.longest[index] =
ffffffffc020091a:	9732                	add	a4,a4,a2
        MAX(self.longest[LEFT_LEAF(index)], self.longest[RIGHT_LEAF(index)]);
ffffffffc020091c:	006e7363          	bleu	t1,t3,ffffffffc0200922 <buddy2_alloc+0xe6>
ffffffffc0200920:	8846                	mv	a6,a7
        self.longest[index] =
ffffffffc0200922:	01072223          	sw	a6,4(a4)
    while (index) {
ffffffffc0200926:	ffd5                	bnez	a5,ffffffffc02008e2 <buddy2_alloc+0xa6>
    }
    page=offset+pages_base;
ffffffffc0200928:	00028797          	auipc	a5,0x28
ffffffffc020092c:	e0878793          	addi	a5,a5,-504 # ffffffffc0228730 <pages_base>
ffffffffc0200930:	6388                	ld	a0,0(a5)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200932:	57f5                	li	a5,-3
ffffffffc0200934:	9576                	add	a0,a0,t4
ffffffffc0200936:	00850713          	addi	a4,a0,8
ffffffffc020093a:	60f7302f          	amoand.d	zero,a5,(a4)

    ClearPageProperty(page);
    
    page->property=size;
ffffffffc020093e:	c90c                	sw	a1,16(a0)

    return page;
ffffffffc0200940:	8082                	ret
        size = 1;
ffffffffc0200942:	4585                	li	a1,1
    if (self.longest[index] < size)
ffffffffc0200944:	00006797          	auipc	a5,0x6
ffffffffc0200948:	af87e783          	lwu	a5,-1288(a5) # ffffffffc020643c <self+0x4>
ffffffffc020094c:	00006617          	auipc	a2,0x6
ffffffffc0200950:	aec60613          	addi	a2,a2,-1300 # ffffffffc0206438 <self>
ffffffffc0200954:	f0b7f6e3          	bleu	a1,a5,ffffffffc0200860 <buddy2_alloc+0x24>
        return NULL;
ffffffffc0200958:	4501                	li	a0,0
}
ffffffffc020095a:	8082                	ret
            size = fixsize(size);
ffffffffc020095c:	0005059b          	sext.w	a1,a0
    while ((1 << m) <size) {
ffffffffc0200960:	4785                	li	a5,1
ffffffffc0200962:	feb7f0e3          	bleu	a1,a5,ffffffffc0200942 <buddy2_alloc+0x106>
    unsigned int m = 0;
ffffffffc0200966:	4781                	li	a5,0
    while ((1 << m) <size) {
ffffffffc0200968:	4705                	li	a4,1
        m++;
ffffffffc020096a:	2785                	addiw	a5,a5,1
    while ((1 << m) <size) {
ffffffffc020096c:	00f7153b          	sllw	a0,a4,a5
ffffffffc0200970:	feb56de3          	bltu	a0,a1,ffffffffc020096a <buddy2_alloc+0x12e>
ffffffffc0200974:	02051593          	slli	a1,a0,0x20
ffffffffc0200978:	9181                	srli	a1,a1,0x20
ffffffffc020097a:	bdc9                	j	ffffffffc020084c <buddy2_alloc+0x10>
    nr_free-=size;
ffffffffc020097c:	00028797          	auipc	a5,0x28
ffffffffc0200980:	da67b223          	sd	t1,-604(a5) # ffffffffc0228720 <nr_free>
    self.longest[index] = 0;
ffffffffc0200984:	00006797          	auipc	a5,0x6
ffffffffc0200988:	aa07ac23          	sw	zero,-1352(a5) # ffffffffc020643c <self+0x4>
ffffffffc020098c:	4e81                	li	t4,0
ffffffffc020098e:	bf69                	j	ffffffffc0200928 <buddy2_alloc+0xec>

ffffffffc0200990 <buddy2_nr_free>:
    buddy2_free_ac(pg);
}


size_t buddy2_nr_free() {
    return nr_free;
ffffffffc0200990:	00028797          	auipc	a5,0x28
ffffffffc0200994:	d9078793          	addi	a5,a5,-624 # ffffffffc0228720 <nr_free>
}
ffffffffc0200998:	6388                	ld	a0,0(a5)
ffffffffc020099a:	8082                	ret

ffffffffc020099c <buddy2_free>:
    unsigned int offset=(pg-pages_base);
ffffffffc020099c:	00028797          	auipc	a5,0x28
ffffffffc02009a0:	d9478793          	addi	a5,a5,-620 # ffffffffc0228730 <pages_base>
ffffffffc02009a4:	639c                	ld	a5,0(a5)
ffffffffc02009a6:	00002717          	auipc	a4,0x2
ffffffffc02009aa:	85a70713          	addi	a4,a4,-1958 # ffffffffc0202200 <commands+0xa30>
ffffffffc02009ae:	6318                	ld	a4,0(a4)
ffffffffc02009b0:	40f507b3          	sub	a5,a0,a5
ffffffffc02009b4:	878d                	srai	a5,a5,0x3
ffffffffc02009b6:	02e787b3          	mul	a5,a5,a4
    bool temp= offset >= 0 && offset < size;
ffffffffc02009ba:	00028717          	auipc	a4,0x28
ffffffffc02009be:	d6e70713          	addi	a4,a4,-658 # ffffffffc0228728 <size>
    assert(temp);
ffffffffc02009c2:	6318                	ld	a4,0(a4)
static void buddy2_free(struct Page *pg,size_t n){
ffffffffc02009c4:	1141                	addi	sp,sp,-16
ffffffffc02009c6:	e406                	sd	ra,8(sp)
    bool temp= offset >= 0 && offset < size;
ffffffffc02009c8:	02079693          	slli	a3,a5,0x20
ffffffffc02009cc:	9281                	srli	a3,a3,0x20
    assert(temp);
ffffffffc02009ce:	10e6fe63          	bleu	a4,a3,ffffffffc0200aea <buddy2_free+0x14e>
    index = offset + self.size - 1;
ffffffffc02009d2:	00006617          	auipc	a2,0x6
ffffffffc02009d6:	a6660613          	addi	a2,a2,-1434 # ffffffffc0206438 <self>
ffffffffc02009da:	4218                	lw	a4,0(a2)
ffffffffc02009dc:	2781                	sext.w	a5,a5
ffffffffc02009de:	377d                	addiw	a4,a4,-1
ffffffffc02009e0:	9fb9                	addw	a5,a5,a4
    for (; self.longest[index] ; index = PARENT(index)) {
ffffffffc02009e2:	02079713          	slli	a4,a5,0x20
ffffffffc02009e6:	8379                	srli	a4,a4,0x1e
ffffffffc02009e8:	9732                	add	a4,a4,a2
ffffffffc02009ea:	4358                	lw	a4,4(a4)
ffffffffc02009ec:	cb71                	beqz	a4,ffffffffc0200ac0 <buddy2_free+0x124>
        node_size *= 2;
ffffffffc02009ee:	4589                	li	a1,2
        if (index == 0)
ffffffffc02009f0:	e789                	bnez	a5,ffffffffc02009fa <buddy2_free+0x5e>
ffffffffc02009f2:	a0e1                	j	ffffffffc0200aba <buddy2_free+0x11e>
        node_size *= 2;
ffffffffc02009f4:	0015959b          	slliw	a1,a1,0x1
        if (index == 0)
ffffffffc02009f8:	c3e9                	beqz	a5,ffffffffc0200aba <buddy2_free+0x11e>
    for (; self.longest[index] ; index = PARENT(index)) {
ffffffffc02009fa:	2785                	addiw	a5,a5,1
ffffffffc02009fc:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200a00:	37fd                	addiw	a5,a5,-1
ffffffffc0200a02:	02079713          	slli	a4,a5,0x20
ffffffffc0200a06:	8379                	srli	a4,a4,0x1e
ffffffffc0200a08:	9732                	add	a4,a4,a2
ffffffffc0200a0a:	4358                	lw	a4,4(a4)
ffffffffc0200a0c:	f765                	bnez	a4,ffffffffc02009f4 <buddy2_free+0x58>
ffffffffc0200a0e:	02059813          	slli	a6,a1,0x20
ffffffffc0200a12:	02085813          	srli	a6,a6,0x20
ffffffffc0200a16:	00281713          	slli	a4,a6,0x2
ffffffffc0200a1a:	9742                	add	a4,a4,a6
ffffffffc0200a1c:	070e                	slli	a4,a4,0x3
    self.longest[index] = node_size;
ffffffffc0200a1e:	02079693          	slli	a3,a5,0x20
ffffffffc0200a22:	82f9                	srli	a3,a3,0x1e
ffffffffc0200a24:	96b2                	add	a3,a3,a2
ffffffffc0200a26:	c2cc                	sw	a1,4(a3)
    for (; p != pg + node_size; p ++) {
ffffffffc0200a28:	972a                	add	a4,a4,a0
ffffffffc0200a2a:	02e50863          	beq	a0,a4,ffffffffc0200a5a <buddy2_free+0xbe>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a2e:	6514                	ld	a3,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200a30:	8a85                	andi	a3,a3,1
ffffffffc0200a32:	eec1                	bnez	a3,ffffffffc0200aca <buddy2_free+0x12e>
ffffffffc0200a34:	6514                	ld	a3,8(a0)
ffffffffc0200a36:	8285                	srli	a3,a3,0x1
ffffffffc0200a38:	8a85                	andi	a3,a3,1
ffffffffc0200a3a:	ca81                	beqz	a3,ffffffffc0200a4a <buddy2_free+0xae>
ffffffffc0200a3c:	a079                	j	ffffffffc0200aca <buddy2_free+0x12e>
ffffffffc0200a3e:	6514                	ld	a3,8(a0)
ffffffffc0200a40:	8a85                	andi	a3,a3,1
ffffffffc0200a42:	e6c1                	bnez	a3,ffffffffc0200aca <buddy2_free+0x12e>
ffffffffc0200a44:	6514                	ld	a3,8(a0)
ffffffffc0200a46:	8a89                	andi	a3,a3,2
ffffffffc0200a48:	e2c9                	bnez	a3,ffffffffc0200aca <buddy2_free+0x12e>
        p->flags = 0;
ffffffffc0200a4a:	00053423          	sd	zero,8(a0)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a4e:	00052023          	sw	zero,0(a0)
    for (; p != pg + node_size; p ++) {
ffffffffc0200a52:	02850513          	addi	a0,a0,40
ffffffffc0200a56:	fee514e3          	bne	a0,a4,ffffffffc0200a3e <buddy2_free+0xa2>
    nr_free+=node_size;
ffffffffc0200a5a:	00028717          	auipc	a4,0x28
ffffffffc0200a5e:	cc670713          	addi	a4,a4,-826 # ffffffffc0228720 <nr_free>
ffffffffc0200a62:	6318                	ld	a4,0(a4)
ffffffffc0200a64:	9742                	add	a4,a4,a6
ffffffffc0200a66:	00028697          	auipc	a3,0x28
ffffffffc0200a6a:	cae6bd23          	sd	a4,-838(a3) # ffffffffc0228720 <nr_free>
    while (index){
ffffffffc0200a6e:	c7b1                	beqz	a5,ffffffffc0200aba <buddy2_free+0x11e>
    index = PARENT(index);
ffffffffc0200a70:	2785                	addiw	a5,a5,1
ffffffffc0200a72:	0017d71b          	srliw	a4,a5,0x1
ffffffffc0200a76:	377d                	addiw	a4,a4,-1
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a78:	0017169b          	slliw	a3,a4,0x1
ffffffffc0200a7c:	2685                	addiw	a3,a3,1
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a7e:	9bf9                	andi	a5,a5,-2
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a80:	1682                	slli	a3,a3,0x20
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a82:	1782                	slli	a5,a5,0x20
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a84:	9281                	srli	a3,a3,0x20
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a86:	9381                	srli	a5,a5,0x20
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a88:	068a                	slli	a3,a3,0x2
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a8a:	078a                	slli	a5,a5,0x2
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a8c:	96b2                	add	a3,a3,a2
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a8e:	97b2                	add	a5,a5,a2
    left_longest = self.longest[LEFT_LEAF(index)];
ffffffffc0200a90:	42c8                	lw	a0,4(a3)
    right_longest = self.longest[RIGHT_LEAF(index)];
ffffffffc0200a92:	43d4                	lw	a3,4(a5)
    index = PARENT(index);
ffffffffc0200a94:	0007079b          	sext.w	a5,a4
        self.longest[index] = node_size;
ffffffffc0200a98:	1702                	slli	a4,a4,0x20
    node_size *= 2;
ffffffffc0200a9a:	0015959b          	slliw	a1,a1,0x1
        self.longest[index] = node_size;
ffffffffc0200a9e:	8379                	srli	a4,a4,0x1e
    if (left_longest + right_longest == node_size)
ffffffffc0200aa0:	00d508bb          	addw	a7,a0,a3
    node_size *= 2;
ffffffffc0200aa4:	882e                	mv	a6,a1
        self.longest[index] = node_size;
ffffffffc0200aa6:	9732                	add	a4,a4,a2
    if (left_longest + right_longest == node_size)
ffffffffc0200aa8:	00b88663          	beq	a7,a1,ffffffffc0200ab4 <buddy2_free+0x118>
        self.longest[index] = MAX(left_longest, right_longest);
ffffffffc0200aac:	882a                	mv	a6,a0
ffffffffc0200aae:	00d57363          	bleu	a3,a0,ffffffffc0200ab4 <buddy2_free+0x118>
ffffffffc0200ab2:	8836                	mv	a6,a3
ffffffffc0200ab4:	01072223          	sw	a6,4(a4)
    while (index){
ffffffffc0200ab8:	ffc5                	bnez	a5,ffffffffc0200a70 <buddy2_free+0xd4>
}
ffffffffc0200aba:	60a2                	ld	ra,8(sp)
ffffffffc0200abc:	0141                	addi	sp,sp,16
ffffffffc0200abe:	8082                	ret
    for (; self.longest[index] ; index = PARENT(index)) {
ffffffffc0200ac0:	4805                	li	a6,1
ffffffffc0200ac2:	02800713          	li	a4,40
    node_size = 1;
ffffffffc0200ac6:	4585                	li	a1,1
ffffffffc0200ac8:	bf99                	j	ffffffffc0200a1e <buddy2_free+0x82>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200aca:	00001697          	auipc	a3,0x1
ffffffffc0200ace:	77668693          	addi	a3,a3,1910 # ffffffffc0202240 <commands+0xa70>
ffffffffc0200ad2:	00001617          	auipc	a2,0x1
ffffffffc0200ad6:	73e60613          	addi	a2,a2,1854 # ffffffffc0202210 <commands+0xa40>
ffffffffc0200ada:	09f00593          	li	a1,159
ffffffffc0200ade:	00001517          	auipc	a0,0x1
ffffffffc0200ae2:	74a50513          	addi	a0,a0,1866 # ffffffffc0202228 <commands+0xa58>
ffffffffc0200ae6:	8c7ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(temp);
ffffffffc0200aea:	00001697          	auipc	a3,0x1
ffffffffc0200aee:	71e68693          	addi	a3,a3,1822 # ffffffffc0202208 <commands+0xa38>
ffffffffc0200af2:	00001617          	auipc	a2,0x1
ffffffffc0200af6:	71e60613          	addi	a2,a2,1822 # ffffffffc0202210 <commands+0xa40>
ffffffffc0200afa:	09000593          	li	a1,144
ffffffffc0200afe:	00001517          	auipc	a0,0x1
ffffffffc0200b02:	72a50513          	addi	a0,a0,1834 # ffffffffc0202228 <commands+0xa58>
ffffffffc0200b06:	8a7ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b0a <buddy2_init>:
    while ((1 << m) <= n) {
ffffffffc0200b0a:	c9cd                	beqz	a1,ffffffffc0200bbc <buddy2_init+0xb2>
    unsigned int m = 0;
ffffffffc0200b0c:	4601                	li	a2,0
    while ((1 << m) <= n) {
ffffffffc0200b0e:	4805                	li	a6,1
ffffffffc0200b10:	a011                	j	ffffffffc0200b14 <buddy2_init+0xa>
        m++;
ffffffffc0200b12:	863e                	mv	a2,a5
ffffffffc0200b14:	0016079b          	addiw	a5,a2,1
    while ((1 << m) <= n) {
ffffffffc0200b18:	00f8173b          	sllw	a4,a6,a5
ffffffffc0200b1c:	fee5fbe3          	bleu	a4,a1,ffffffffc0200b12 <buddy2_init+0x8>
    return 1 << (m - 1);
ffffffffc0200b20:	00c8183b          	sllw	a6,a6,a2
    for (; p != base + n; p ++) {
ffffffffc0200b24:	00259693          	slli	a3,a1,0x2
ffffffffc0200b28:	96ae                	add	a3,a3,a1
    size=closestPowerOfTwo(n);
ffffffffc0200b2a:	02081893          	slli	a7,a6,0x20
ffffffffc0200b2e:	0208d893          	srli	a7,a7,0x20
    for (; p != base + n; p ++) {
ffffffffc0200b32:	068e                	slli	a3,a3,0x3
    size=closestPowerOfTwo(n);
ffffffffc0200b34:	00028797          	auipc	a5,0x28
ffffffffc0200b38:	bf17ba23          	sd	a7,-1036(a5) # ffffffffc0228728 <size>
    nr_free=size;
ffffffffc0200b3c:	00028797          	auipc	a5,0x28
ffffffffc0200b40:	bf17b223          	sd	a7,-1052(a5) # ffffffffc0228720 <nr_free>
    for (; p != base + n; p ++) {
ffffffffc0200b44:	96aa                	add	a3,a3,a0
    return 1 << (m - 1);
ffffffffc0200b46:	0008031b          	sext.w	t1,a6
    for (; p != base + n; p ++) {
ffffffffc0200b4a:	02d50463          	beq	a0,a3,ffffffffc0200b72 <buddy2_init+0x68>
ffffffffc0200b4e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200b50:	87aa                	mv	a5,a0
ffffffffc0200b52:	8b05                	andi	a4,a4,1
ffffffffc0200b54:	e709                	bnez	a4,ffffffffc0200b5e <buddy2_init+0x54>
ffffffffc0200b56:	a8b5                	j	ffffffffc0200bd2 <buddy2_init+0xc8>
ffffffffc0200b58:	6798                	ld	a4,8(a5)
ffffffffc0200b5a:	8b05                	andi	a4,a4,1
ffffffffc0200b5c:	cb3d                	beqz	a4,ffffffffc0200bd2 <buddy2_init+0xc8>
        p->flags = p->property = 0;
ffffffffc0200b5e:	0007a823          	sw	zero,16(a5)
ffffffffc0200b62:	0007b423          	sd	zero,8(a5)
ffffffffc0200b66:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200b6a:	02878793          	addi	a5,a5,40
ffffffffc0200b6e:	fed795e3          	bne	a5,a3,ffffffffc0200b58 <buddy2_init+0x4e>
    base->property = n;
ffffffffc0200b72:	c90c                	sw	a1,16(a0)
    if (size < 1 || !IS_POWER_OF_2(size))
ffffffffc0200b74:	04030e63          	beqz	t1,ffffffffc0200bd0 <buddy2_init+0xc6>
ffffffffc0200b78:	fff88793          	addi	a5,a7,-1
ffffffffc0200b7c:	0117f7b3          	and	a5,a5,a7
ffffffffc0200b80:	eba1                	bnez	a5,ffffffffc0200bd0 <buddy2_init+0xc6>
    self.size = size;
ffffffffc0200b82:	00006717          	auipc	a4,0x6
ffffffffc0200b86:	8b072b23          	sw	a6,-1866(a4) # ffffffffc0206438 <self>
    node_size = size * 2;
ffffffffc0200b8a:	4709                	li	a4,2
    for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200b8c:	0886                	slli	a7,a7,0x1
    node_size = size * 2;
ffffffffc0200b8e:	00c7163b          	sllw	a2,a4,a2
    for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200b92:	18fd                	addi	a7,a7,-1
ffffffffc0200b94:	00006717          	auipc	a4,0x6
ffffffffc0200b98:	8a870713          	addi	a4,a4,-1880 # ffffffffc020643c <self+0x4>
        if (IS_POWER_OF_2(i+1))
ffffffffc0200b9c:	00178693          	addi	a3,a5,1
ffffffffc0200ba0:	8ff5                	and	a5,a5,a3
ffffffffc0200ba2:	e399                	bnez	a5,ffffffffc0200ba8 <buddy2_init+0x9e>
            node_size /= 2;
ffffffffc0200ba4:	0016561b          	srliw	a2,a2,0x1
        self.longest[i] = node_size;
ffffffffc0200ba8:	c310                	sw	a2,0(a4)
ffffffffc0200baa:	87b6                	mv	a5,a3
ffffffffc0200bac:	0711                	addi	a4,a4,4
    for (i = 0; i < 2 * size - 1; ++i) {
ffffffffc0200bae:	ff1697e3          	bne	a3,a7,ffffffffc0200b9c <buddy2_init+0x92>
    pages_base=base;
ffffffffc0200bb2:	00028797          	auipc	a5,0x28
ffffffffc0200bb6:	b6a7bf23          	sd	a0,-1154(a5) # ffffffffc0228730 <pages_base>
ffffffffc0200bba:	8082                	ret
    size=closestPowerOfTwo(n);
ffffffffc0200bbc:	00028797          	auipc	a5,0x28
ffffffffc0200bc0:	b607b623          	sd	zero,-1172(a5) # ffffffffc0228728 <size>
    nr_free=size;
ffffffffc0200bc4:	00028797          	auipc	a5,0x28
ffffffffc0200bc8:	b407be23          	sd	zero,-1188(a5) # ffffffffc0228720 <nr_free>
    base->property = n;
ffffffffc0200bcc:	00052823          	sw	zero,16(a0)
    if (size < 1 || !IS_POWER_OF_2(size))
ffffffffc0200bd0:	8082                	ret
void buddy2_init(struct Page *base, size_t n) {
ffffffffc0200bd2:	1141                	addi	sp,sp,-16
        assert(PageReserved(p));
ffffffffc0200bd4:	00001697          	auipc	a3,0x1
ffffffffc0200bd8:	69468693          	addi	a3,a3,1684 # ffffffffc0202268 <commands+0xa98>
ffffffffc0200bdc:	00001617          	auipc	a2,0x1
ffffffffc0200be0:	63460613          	addi	a2,a2,1588 # ffffffffc0202210 <commands+0xa40>
ffffffffc0200be4:	04800593          	li	a1,72
ffffffffc0200be8:	00001517          	auipc	a0,0x1
ffffffffc0200bec:	64050513          	addi	a0,a0,1600 # ffffffffc0202228 <commands+0xa58>
void buddy2_init(struct Page *base, size_t n) {
ffffffffc0200bf0:	e406                	sd	ra,8(sp)
        assert(PageReserved(p));
ffffffffc0200bf2:	fbaff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200bf6 <basic_check>:

    free_page(p1);
    free_page(p2);
}

static void basic_check(void) {
ffffffffc0200bf6:	7179                	addi	sp,sp,-48
|p4 |p5 |p2 | 
最后释放。
注意，指针的地址都是块的首地址。
通过计算验证，然后将结果打印出来，较为直观。也可以通过断言机制assert()判定。
*/
cprintf(
ffffffffc0200bf8:	00001517          	auipc	a0,0x1
ffffffffc0200bfc:	20850513          	addi	a0,a0,520 # ffffffffc0201e00 <commands+0x630>
static void basic_check(void) {
ffffffffc0200c00:	f406                	sd	ra,40(sp)
ffffffffc0200c02:	f022                	sd	s0,32(sp)
ffffffffc0200c04:	ec26                	sd	s1,24(sp)
ffffffffc0200c06:	e84a                	sd	s2,16(sp)
ffffffffc0200c08:	e44e                	sd	s3,8(sp)
ffffffffc0200c0a:	e052                	sd	s4,0(sp)
cprintf(
ffffffffc0200c0c:	caaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>

    struct Page *p0, *p1,*p2;
    p0 = p1 = NULL;
    p2=NULL;
    struct Page *p3, *p4,*p5;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c10:	4505                	li	a0,1
ffffffffc0200c12:	240000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200c16:	1c050e63          	beqz	a0,ffffffffc0200df2 <basic_check+0x1fc>
ffffffffc0200c1a:	842a                	mv	s0,a0
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c1c:	4505                	li	a0,1
ffffffffc0200c1e:	234000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200c22:	892a                	mv	s2,a0
ffffffffc0200c24:	20050763          	beqz	a0,ffffffffc0200e32 <basic_check+0x23c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c28:	4505                	li	a0,1
ffffffffc0200c2a:	228000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200c2e:	84aa                	mv	s1,a0
ffffffffc0200c30:	1e050163          	beqz	a0,ffffffffc0200e12 <basic_check+0x21c>
    free_page(p0);
ffffffffc0200c34:	8522                	mv	a0,s0
ffffffffc0200c36:	4585                	li	a1,1
ffffffffc0200c38:	25e000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    free_page(p1);
ffffffffc0200c3c:	854a                	mv	a0,s2
ffffffffc0200c3e:	4585                	li	a1,1
ffffffffc0200c40:	256000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    free_page(p2);
ffffffffc0200c44:	4585                	li	a1,1
ffffffffc0200c46:	8526                	mv	a0,s1
ffffffffc0200c48:	24e000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    
    p0=alloc_pages(70);
ffffffffc0200c4c:	04600513          	li	a0,70
ffffffffc0200c50:	202000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200c54:	8a2a                	mv	s4,a0
    p1=alloc_pages(35);
ffffffffc0200c56:	02300513          	li	a0,35
ffffffffc0200c5a:	1f8000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200c5e:	84aa                	mv	s1,a0
    //注意，一个结构体指针是20个字节，有3个int,3*4，还有一个双向链表,两个指针是8。加载一起是20。
    cprintf("p0 %p\n",p0);
ffffffffc0200c60:	85d2                	mv	a1,s4
ffffffffc0200c62:	00001517          	auipc	a0,0x1
ffffffffc0200c66:	47e50513          	addi	a0,a0,1150 # ffffffffc02020e0 <commands+0x910>
ffffffffc0200c6a:	c4cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p1 %p\n",p1);
ffffffffc0200c6e:	85a6                	mv	a1,s1
ffffffffc0200c70:	00001517          	auipc	a0,0x1
ffffffffc0200c74:	47850513          	addi	a0,a0,1144 # ffffffffc02020e8 <commands+0x918>
ffffffffc0200c78:	c3eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p1-p0 equal %p ?=128\n",p1-p0);//应该差128
ffffffffc0200c7c:	00001797          	auipc	a5,0x1
ffffffffc0200c80:	58478793          	addi	a5,a5,1412 # ffffffffc0202200 <commands+0xa30>
ffffffffc0200c84:	6380                	ld	s0,0(a5)
ffffffffc0200c86:	414485b3          	sub	a1,s1,s4
ffffffffc0200c8a:	858d                	srai	a1,a1,0x3
ffffffffc0200c8c:	028585b3          	mul	a1,a1,s0
ffffffffc0200c90:	00001517          	auipc	a0,0x1
ffffffffc0200c94:	46050513          	addi	a0,a0,1120 # ffffffffc02020f0 <commands+0x920>
ffffffffc0200c98:	c1eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    p2=alloc_pages(257);
ffffffffc0200c9c:	10100513          	li	a0,257
ffffffffc0200ca0:	1b2000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200ca4:	892a                	mv	s2,a0
    cprintf("p2 %p\n",p2);
ffffffffc0200ca6:	85aa                	mv	a1,a0
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	46050513          	addi	a0,a0,1120 # ffffffffc0202108 <commands+0x938>
ffffffffc0200cb0:	c06ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p2-p1 equal %p ?=128+256\n",p2-p1);//应该差384
ffffffffc0200cb4:	409905b3          	sub	a1,s2,s1
ffffffffc0200cb8:	858d                	srai	a1,a1,0x3
ffffffffc0200cba:	028585b3          	mul	a1,a1,s0
ffffffffc0200cbe:	00001517          	auipc	a0,0x1
ffffffffc0200cc2:	45250513          	addi	a0,a0,1106 # ffffffffc0202110 <commands+0x940>
ffffffffc0200cc6:	bf0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    p3=alloc_pages(63);
ffffffffc0200cca:	03f00513          	li	a0,63
ffffffffc0200cce:	184000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200cd2:	89aa                	mv	s3,a0
    cprintf("p3 %p\n",p3);
ffffffffc0200cd4:	85aa                	mv	a1,a0
ffffffffc0200cd6:	00001517          	auipc	a0,0x1
ffffffffc0200cda:	45a50513          	addi	a0,a0,1114 # ffffffffc0202130 <commands+0x960>
ffffffffc0200cde:	bd8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p3-p1 equal %p ?=64\n",p3-p1);//应该差64
ffffffffc0200ce2:	409985b3          	sub	a1,s3,s1
ffffffffc0200ce6:	858d                	srai	a1,a1,0x3
ffffffffc0200ce8:	028585b3          	mul	a1,a1,s0
ffffffffc0200cec:	00001517          	auipc	a0,0x1
ffffffffc0200cf0:	44c50513          	addi	a0,a0,1100 # ffffffffc0202138 <commands+0x968>
ffffffffc0200cf4:	bc2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    free_pages(p0,70);    
ffffffffc0200cf8:	04600593          	li	a1,70
ffffffffc0200cfc:	8552                	mv	a0,s4
ffffffffc0200cfe:	198000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    cprintf("free p0!\n");
ffffffffc0200d02:	00001517          	auipc	a0,0x1
ffffffffc0200d06:	44e50513          	addi	a0,a0,1102 # ffffffffc0202150 <commands+0x980>
ffffffffc0200d0a:	bacff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p1,35);
ffffffffc0200d0e:	02300593          	li	a1,35
ffffffffc0200d12:	8526                	mv	a0,s1
ffffffffc0200d14:	182000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    cprintf("free p1!\n");
ffffffffc0200d18:	00001517          	auipc	a0,0x1
ffffffffc0200d1c:	44850513          	addi	a0,a0,1096 # ffffffffc0202160 <commands+0x990>
ffffffffc0200d20:	b96ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p3,63);    
ffffffffc0200d24:	03f00593          	li	a1,63
ffffffffc0200d28:	854e                	mv	a0,s3
ffffffffc0200d2a:	16c000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    cprintf("free p3!\n");
ffffffffc0200d2e:	00001517          	auipc	a0,0x1
ffffffffc0200d32:	44250513          	addi	a0,a0,1090 # ffffffffc0202170 <commands+0x9a0>
ffffffffc0200d36:	b80ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    p4=alloc_pages(255);
ffffffffc0200d3a:	0ff00513          	li	a0,255
ffffffffc0200d3e:	114000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200d42:	84aa                	mv	s1,a0
    cprintf("p4 %p\n",p4);
ffffffffc0200d44:	85aa                	mv	a1,a0
ffffffffc0200d46:	00001517          	auipc	a0,0x1
ffffffffc0200d4a:	43a50513          	addi	a0,a0,1082 # ffffffffc0202180 <commands+0x9b0>
ffffffffc0200d4e:	b68ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p2-p4 equal %p ?=512\n",p2-p4);//应该差512
ffffffffc0200d52:	409905b3          	sub	a1,s2,s1
ffffffffc0200d56:	858d                	srai	a1,a1,0x3
ffffffffc0200d58:	028585b3          	mul	a1,a1,s0
ffffffffc0200d5c:	00001517          	auipc	a0,0x1
ffffffffc0200d60:	42c50513          	addi	a0,a0,1068 # ffffffffc0202188 <commands+0x9b8>
ffffffffc0200d64:	b52ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    
    p5=alloc_pages(255);
ffffffffc0200d68:	0ff00513          	li	a0,255
ffffffffc0200d6c:	0e6000ef          	jal	ra,ffffffffc0200e52 <alloc_pages>
ffffffffc0200d70:	89aa                	mv	s3,a0
    cprintf("p5 %p\n",p5);
ffffffffc0200d72:	85aa                	mv	a1,a0
ffffffffc0200d74:	00001517          	auipc	a0,0x1
ffffffffc0200d78:	42c50513          	addi	a0,a0,1068 # ffffffffc02021a0 <commands+0x9d0>
ffffffffc0200d7c:	b3aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("p5-p4 equal %p ?=256\n",p5-p4);//应该差256
ffffffffc0200d80:	409985b3          	sub	a1,s3,s1
ffffffffc0200d84:	858d                	srai	a1,a1,0x3
ffffffffc0200d86:	028585b3          	mul	a1,a1,s0
ffffffffc0200d8a:	00001517          	auipc	a0,0x1
ffffffffc0200d8e:	41e50513          	addi	a0,a0,1054 # ffffffffc02021a8 <commands+0x9d8>
ffffffffc0200d92:	b24ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        free_pages(p2,257);    
ffffffffc0200d96:	10100593          	li	a1,257
ffffffffc0200d9a:	854a                	mv	a0,s2
ffffffffc0200d9c:	0fa000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    cprintf("free p2!\n");
ffffffffc0200da0:	00001517          	auipc	a0,0x1
ffffffffc0200da4:	42050513          	addi	a0,a0,1056 # ffffffffc02021c0 <commands+0x9f0>
ffffffffc0200da8:	b0eff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        free_pages(p4,255);    
ffffffffc0200dac:	0ff00593          	li	a1,255
ffffffffc0200db0:	8526                	mv	a0,s1
ffffffffc0200db2:	0e4000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    cprintf("free p4!\n"); 
ffffffffc0200db6:	00001517          	auipc	a0,0x1
ffffffffc0200dba:	41a50513          	addi	a0,a0,1050 # ffffffffc02021d0 <commands+0xa00>
ffffffffc0200dbe:	af8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            free_pages(p5,255);    
ffffffffc0200dc2:	854e                	mv	a0,s3
ffffffffc0200dc4:	0ff00593          	li	a1,255
ffffffffc0200dc8:	0ce000ef          	jal	ra,ffffffffc0200e96 <free_pages>
    cprintf("free p5!\n");   
ffffffffc0200dcc:	00001517          	auipc	a0,0x1
ffffffffc0200dd0:	41450513          	addi	a0,a0,1044 # ffffffffc02021e0 <commands+0xa10>
ffffffffc0200dd4:	ae2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("CHECK DONE!\n") ;
}
ffffffffc0200dd8:	7402                	ld	s0,32(sp)
ffffffffc0200dda:	70a2                	ld	ra,40(sp)
ffffffffc0200ddc:	64e2                	ld	s1,24(sp)
ffffffffc0200dde:	6942                	ld	s2,16(sp)
ffffffffc0200de0:	69a2                	ld	s3,8(sp)
ffffffffc0200de2:	6a02                	ld	s4,0(sp)
    cprintf("CHECK DONE!\n") ;
ffffffffc0200de4:	00001517          	auipc	a0,0x1
ffffffffc0200de8:	40c50513          	addi	a0,a0,1036 # ffffffffc02021f0 <commands+0xa20>
}
ffffffffc0200dec:	6145                	addi	sp,sp,48
    cprintf("CHECK DONE!\n") ;
ffffffffc0200dee:	ac8ff06f          	j	ffffffffc02000b6 <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200df2:	00001697          	auipc	a3,0x1
ffffffffc0200df6:	28e68693          	addi	a3,a3,654 # ffffffffc0202080 <commands+0x8b0>
ffffffffc0200dfa:	00001617          	auipc	a2,0x1
ffffffffc0200dfe:	41660613          	addi	a2,a2,1046 # ffffffffc0202210 <commands+0xa40>
ffffffffc0200e02:	10800593          	li	a1,264
ffffffffc0200e06:	00001517          	auipc	a0,0x1
ffffffffc0200e0a:	42250513          	addi	a0,a0,1058 # ffffffffc0202228 <commands+0xa58>
ffffffffc0200e0e:	d9eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e12:	00001697          	auipc	a3,0x1
ffffffffc0200e16:	2ae68693          	addi	a3,a3,686 # ffffffffc02020c0 <commands+0x8f0>
ffffffffc0200e1a:	00001617          	auipc	a2,0x1
ffffffffc0200e1e:	3f660613          	addi	a2,a2,1014 # ffffffffc0202210 <commands+0xa40>
ffffffffc0200e22:	10a00593          	li	a1,266
ffffffffc0200e26:	00001517          	auipc	a0,0x1
ffffffffc0200e2a:	40250513          	addi	a0,a0,1026 # ffffffffc0202228 <commands+0xa58>
ffffffffc0200e2e:	d7eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e32:	00001697          	auipc	a3,0x1
ffffffffc0200e36:	26e68693          	addi	a3,a3,622 # ffffffffc02020a0 <commands+0x8d0>
ffffffffc0200e3a:	00001617          	auipc	a2,0x1
ffffffffc0200e3e:	3d660613          	addi	a2,a2,982 # ffffffffc0202210 <commands+0xa40>
ffffffffc0200e42:	10900593          	li	a1,265
ffffffffc0200e46:	00001517          	auipc	a0,0x1
ffffffffc0200e4a:	3e250513          	addi	a0,a0,994 # ffffffffc0202228 <commands+0xa58>
ffffffffc0200e4e:	d5eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200e52 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e52:	100027f3          	csrr	a5,sstatus
ffffffffc0200e56:	8b89                	andi	a5,a5,2
ffffffffc0200e58:	eb89                	bnez	a5,ffffffffc0200e6a <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e5a:	00028797          	auipc	a5,0x28
ffffffffc0200e5e:	8e678793          	addi	a5,a5,-1818 # ffffffffc0228740 <pmm_manager>
ffffffffc0200e62:	639c                	ld	a5,0(a5)
ffffffffc0200e64:	0187b303          	ld	t1,24(a5)
ffffffffc0200e68:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0200e6a:	1141                	addi	sp,sp,-16
ffffffffc0200e6c:	e406                	sd	ra,8(sp)
ffffffffc0200e6e:	e022                	sd	s0,0(sp)
ffffffffc0200e70:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200e72:	df2ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200e76:	00028797          	auipc	a5,0x28
ffffffffc0200e7a:	8ca78793          	addi	a5,a5,-1846 # ffffffffc0228740 <pmm_manager>
ffffffffc0200e7e:	639c                	ld	a5,0(a5)
ffffffffc0200e80:	8522                	mv	a0,s0
ffffffffc0200e82:	6f9c                	ld	a5,24(a5)
ffffffffc0200e84:	9782                	jalr	a5
ffffffffc0200e86:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e88:	dd6ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e8c:	8522                	mv	a0,s0
ffffffffc0200e8e:	60a2                	ld	ra,8(sp)
ffffffffc0200e90:	6402                	ld	s0,0(sp)
ffffffffc0200e92:	0141                	addi	sp,sp,16
ffffffffc0200e94:	8082                	ret

ffffffffc0200e96 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e96:	100027f3          	csrr	a5,sstatus
ffffffffc0200e9a:	8b89                	andi	a5,a5,2
ffffffffc0200e9c:	eb89                	bnez	a5,ffffffffc0200eae <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e9e:	00028797          	auipc	a5,0x28
ffffffffc0200ea2:	8a278793          	addi	a5,a5,-1886 # ffffffffc0228740 <pmm_manager>
ffffffffc0200ea6:	639c                	ld	a5,0(a5)
ffffffffc0200ea8:	0207b303          	ld	t1,32(a5)
ffffffffc0200eac:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0200eae:	1101                	addi	sp,sp,-32
ffffffffc0200eb0:	ec06                	sd	ra,24(sp)
ffffffffc0200eb2:	e822                	sd	s0,16(sp)
ffffffffc0200eb4:	e426                	sd	s1,8(sp)
ffffffffc0200eb6:	842a                	mv	s0,a0
ffffffffc0200eb8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200eba:	daaff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200ebe:	00028797          	auipc	a5,0x28
ffffffffc0200ec2:	88278793          	addi	a5,a5,-1918 # ffffffffc0228740 <pmm_manager>
ffffffffc0200ec6:	639c                	ld	a5,0(a5)
ffffffffc0200ec8:	85a6                	mv	a1,s1
ffffffffc0200eca:	8522                	mv	a0,s0
ffffffffc0200ecc:	739c                	ld	a5,32(a5)
ffffffffc0200ece:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200ed0:	6442                	ld	s0,16(sp)
ffffffffc0200ed2:	60e2                	ld	ra,24(sp)
ffffffffc0200ed4:	64a2                	ld	s1,8(sp)
ffffffffc0200ed6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200ed8:	d86ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0200edc <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200edc:	00001797          	auipc	a5,0x1
ffffffffc0200ee0:	39c78793          	addi	a5,a5,924 # ffffffffc0202278 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ee4:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200ee6:	7139                	addi	sp,sp,-64
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	3e050513          	addi	a0,a0,992 # ffffffffc02022c8 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0200ef0:	fc06                	sd	ra,56(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200ef2:	00028717          	auipc	a4,0x28
ffffffffc0200ef6:	84f73723          	sd	a5,-1970(a4) # ffffffffc0228740 <pmm_manager>
void pmm_init(void) {
ffffffffc0200efa:	f822                	sd	s0,48(sp)
ffffffffc0200efc:	f04a                	sd	s2,32(sp)
ffffffffc0200efe:	e456                	sd	s5,8(sp)
ffffffffc0200f00:	e05a                	sd	s6,0(sp)
ffffffffc0200f02:	f426                	sd	s1,40(sp)
ffffffffc0200f04:	ec4e                	sd	s3,24(sp)
ffffffffc0200f06:	e852                	sd	s4,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200f08:	00028917          	auipc	s2,0x28
ffffffffc0200f0c:	83890913          	addi	s2,s2,-1992 # ffffffffc0228740 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200f10:	9a6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200f14:	00093783          	ld	a5,0(s2)
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200f18:	4445                	li	s0,17
ffffffffc0200f1a:	046e                	slli	s0,s0,0x1b
    pmm_manager->init();
ffffffffc0200f1c:	679c                	ld	a5,8(a5)
    npage = maxpa / PGSIZE;
ffffffffc0200f1e:	00005a97          	auipc	s5,0x5
ffffffffc0200f22:	4faa8a93          	addi	s5,s5,1274 # ffffffffc0206418 <npage>
ffffffffc0200f26:	00028b17          	auipc	s6,0x28
ffffffffc0200f2a:	82ab0b13          	addi	s6,s6,-2006 # ffffffffc0228750 <pages>
    pmm_manager->init();
ffffffffc0200f2e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f30:	57f5                	li	a5,-3
ffffffffc0200f32:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200f34:	00001517          	auipc	a0,0x1
ffffffffc0200f38:	3ac50513          	addi	a0,a0,940 # ffffffffc02022e0 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200f3c:	00028717          	auipc	a4,0x28
ffffffffc0200f40:	80f73623          	sd	a5,-2036(a4) # ffffffffc0228748 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200f44:	972ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200f48:	40100613          	li	a2,1025
ffffffffc0200f4c:	0656                	slli	a2,a2,0x15
ffffffffc0200f4e:	fff40693          	addi	a3,s0,-1
ffffffffc0200f52:	07e005b7          	lui	a1,0x7e00
ffffffffc0200f56:	00001517          	auipc	a0,0x1
ffffffffc0200f5a:	3a250513          	addi	a0,a0,930 # ffffffffc02022f8 <buddy_pmm_manager+0x80>
ffffffffc0200f5e:	958ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  maxpa: 0x%016lx\n", maxpa);
ffffffffc0200f62:	85a2                	mv	a1,s0
ffffffffc0200f64:	00001517          	auipc	a0,0x1
ffffffffc0200f68:	3c450513          	addi	a0,a0,964 # ffffffffc0202328 <buddy_pmm_manager+0xb0>
ffffffffc0200f6c:	94aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f70:	777d                	lui	a4,0xfffff
ffffffffc0200f72:	00028797          	auipc	a5,0x28
ffffffffc0200f76:	7e578793          	addi	a5,a5,2021 # ffffffffc0229757 <end+0xfff>
ffffffffc0200f7a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200f7c:	000886b7          	lui	a3,0x88
    cprintf("  end: 0x%016lx\n", (void *)end);
ffffffffc0200f80:	00027597          	auipc	a1,0x27
ffffffffc0200f84:	7d858593          	addi	a1,a1,2008 # ffffffffc0228758 <end>
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	3b850513          	addi	a0,a0,952 # ffffffffc0202340 <buddy_pmm_manager+0xc8>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200f90:	00027717          	auipc	a4,0x27
ffffffffc0200f94:	7cf73023          	sd	a5,1984(a4) # ffffffffc0228750 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200f98:	00005617          	auipc	a2,0x5
ffffffffc0200f9c:	48d63023          	sd	a3,1152(a2) # ffffffffc0206418 <npage>
    cprintf("  end: 0x%016lx\n", (void *)end);
ffffffffc0200fa0:	916ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200fa4:	000ab703          	ld	a4,0(s5)
ffffffffc0200fa8:	000807b7          	lui	a5,0x80
ffffffffc0200fac:	02f70963          	beq	a4,a5,ffffffffc0200fde <pmm_init+0x102>
ffffffffc0200fb0:	4681                	li	a3,0
ffffffffc0200fb2:	4701                	li	a4,0
ffffffffc0200fb4:	00027b17          	auipc	s6,0x27
ffffffffc0200fb8:	79cb0b13          	addi	s6,s6,1948 # ffffffffc0228750 <pages>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200fbc:	4585                	li	a1,1
ffffffffc0200fbe:	fff80637          	lui	a2,0xfff80
        SetPageReserved(pages + i);
ffffffffc0200fc2:	000b3783          	ld	a5,0(s6)
ffffffffc0200fc6:	97b6                	add	a5,a5,a3
ffffffffc0200fc8:	07a1                	addi	a5,a5,8
ffffffffc0200fca:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200fce:	000ab783          	ld	a5,0(s5)
ffffffffc0200fd2:	0705                	addi	a4,a4,1
ffffffffc0200fd4:	02868693          	addi	a3,a3,40 # 88028 <BASE_ADDRESS-0xffffffffc0177fd8>
ffffffffc0200fd8:	97b2                	add	a5,a5,a2
ffffffffc0200fda:	fef764e3          	bltu	a4,a5,ffffffffc0200fc2 <pmm_init+0xe6>
    cprintf("  nbase: 0x%016lx\n", nbase*PGSIZE);
ffffffffc0200fde:	4585                	li	a1,1
ffffffffc0200fe0:	05fe                	slli	a1,a1,0x1f
ffffffffc0200fe2:	00001517          	auipc	a0,0x1
ffffffffc0200fe6:	37650513          	addi	a0,a0,886 # ffffffffc0202358 <buddy_pmm_manager+0xe0>
ffffffffc0200fea:	8ccff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fee:	000ab703          	ld	a4,0(s5)
ffffffffc0200ff2:	000b3683          	ld	a3,0(s6)
ffffffffc0200ff6:	00271793          	slli	a5,a4,0x2
ffffffffc0200ffa:	97ba                	add	a5,a5,a4
ffffffffc0200ffc:	078e                	slli	a5,a5,0x3
ffffffffc0200ffe:	96be                	add	a3,a3,a5
ffffffffc0201000:	fec007b7          	lui	a5,0xfec00
ffffffffc0201004:	96be                	add	a3,a3,a5
ffffffffc0201006:	c02007b7          	lui	a5,0xc0200
ffffffffc020100a:	0cf6e963          	bltu	a3,a5,ffffffffc02010dc <pmm_init+0x200>
ffffffffc020100e:	00027a17          	auipc	s4,0x27
ffffffffc0201012:	73aa0a13          	addi	s4,s4,1850 # ffffffffc0228748 <va_pa_offset>
ffffffffc0201016:	000a3403          	ld	s0,0(s4)
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020101a:	6485                	lui	s1,0x1
ffffffffc020101c:	14fd                	addi	s1,s1,-1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020101e:	40868433          	sub	s0,a3,s0
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201022:	75fd                	lui	a1,0xfffff
ffffffffc0201024:	94a2                	add	s1,s1,s0
ffffffffc0201026:	8ced                	and	s1,s1,a1
    cprintf("  mem_begin: 0x%016lx\n", mem_begin);
ffffffffc0201028:	85a6                	mv	a1,s1
ffffffffc020102a:	00001517          	auipc	a0,0x1
ffffffffc020102e:	37e50513          	addi	a0,a0,894 # ffffffffc02023a8 <buddy_pmm_manager+0x130>
ffffffffc0201032:	884ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  mem_end: 0x%016lx\n", mem_end);
ffffffffc0201036:	49c5                	li	s3,17
ffffffffc0201038:	01b99593          	slli	a1,s3,0x1b
ffffffffc020103c:	00001517          	auipc	a0,0x1
ffffffffc0201040:	38450513          	addi	a0,a0,900 # ffffffffc02023c0 <buddy_pmm_manager+0x148>
    if (freemem < mem_end) {
ffffffffc0201044:	09ee                	slli	s3,s3,0x1b
    cprintf("  mem_end: 0x%016lx\n", mem_end);
ffffffffc0201046:	870ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (freemem < mem_end) {
ffffffffc020104a:	07346063          	bltu	s0,s3,ffffffffc02010aa <pmm_init+0x1ce>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020104e:	00093783          	ld	a5,0(s2)
ffffffffc0201052:	7b9c                	ld	a5,48(a5)
ffffffffc0201054:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201056:	00001517          	auipc	a0,0x1
ffffffffc020105a:	3b250513          	addi	a0,a0,946 # ffffffffc0202408 <buddy_pmm_manager+0x190>
ffffffffc020105e:	858ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	f9e68693          	addi	a3,a3,-98 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020106a:	00005797          	auipc	a5,0x5
ffffffffc020106e:	3ad7bb23          	sd	a3,950(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201072:	c02007b7          	lui	a5,0xc0200
ffffffffc0201076:	06f6ef63          	bltu	a3,a5,ffffffffc02010f4 <pmm_init+0x218>
ffffffffc020107a:	000a3783          	ld	a5,0(s4)
}
ffffffffc020107e:	7442                	ld	s0,48(sp)
ffffffffc0201080:	70e2                	ld	ra,56(sp)
ffffffffc0201082:	74a2                	ld	s1,40(sp)
ffffffffc0201084:	7902                	ld	s2,32(sp)
ffffffffc0201086:	69e2                	ld	s3,24(sp)
ffffffffc0201088:	6a42                	ld	s4,16(sp)
ffffffffc020108a:	6aa2                	ld	s5,8(sp)
ffffffffc020108c:	6b02                	ld	s6,0(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020108e:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0201090:	8e9d                	sub	a3,a3,a5
ffffffffc0201092:	00027797          	auipc	a5,0x27
ffffffffc0201096:	6ad7b323          	sd	a3,1702(a5) # ffffffffc0228738 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020109a:	00001517          	auipc	a0,0x1
ffffffffc020109e:	38e50513          	addi	a0,a0,910 # ffffffffc0202428 <buddy_pmm_manager+0x1b0>
ffffffffc02010a2:	8636                	mv	a2,a3
}
ffffffffc02010a4:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02010a6:	810ff06f          	j	ffffffffc02000b6 <cprintf>
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02010aa:	000ab703          	ld	a4,0(s5)
ffffffffc02010ae:	00c4d793          	srli	a5,s1,0xc
ffffffffc02010b2:	04e7fd63          	bleu	a4,a5,ffffffffc020110c <pmm_init+0x230>
    pmm_manager->init_memmap(base, n);
ffffffffc02010b6:	00093683          	ld	a3,0(s2)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02010ba:	fff80737          	lui	a4,0xfff80
ffffffffc02010be:	973e                	add	a4,a4,a5
ffffffffc02010c0:	00271793          	slli	a5,a4,0x2
ffffffffc02010c4:	000b3503          	ld	a0,0(s6)
ffffffffc02010c8:	97ba                	add	a5,a5,a4
ffffffffc02010ca:	6a98                	ld	a4,16(a3)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02010cc:	409989b3          	sub	s3,s3,s1
ffffffffc02010d0:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02010d2:	00c9d593          	srli	a1,s3,0xc
ffffffffc02010d6:	953e                	add	a0,a0,a5
ffffffffc02010d8:	9702                	jalr	a4
ffffffffc02010da:	bf95                	j	ffffffffc020104e <pmm_init+0x172>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02010dc:	00001617          	auipc	a2,0x1
ffffffffc02010e0:	29460613          	addi	a2,a2,660 # ffffffffc0202370 <buddy_pmm_manager+0xf8>
ffffffffc02010e4:	07200593          	li	a1,114
ffffffffc02010e8:	00001517          	auipc	a0,0x1
ffffffffc02010ec:	2b050513          	addi	a0,a0,688 # ffffffffc0202398 <buddy_pmm_manager+0x120>
ffffffffc02010f0:	abcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02010f4:	00001617          	auipc	a2,0x1
ffffffffc02010f8:	27c60613          	addi	a2,a2,636 # ffffffffc0202370 <buddy_pmm_manager+0xf8>
ffffffffc02010fc:	08f00593          	li	a1,143
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	29850513          	addi	a0,a0,664 # ffffffffc0202398 <buddy_pmm_manager+0x120>
ffffffffc0201108:	aa4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020110c:	00001617          	auipc	a2,0x1
ffffffffc0201110:	2cc60613          	addi	a2,a2,716 # ffffffffc02023d8 <buddy_pmm_manager+0x160>
ffffffffc0201114:	06b00593          	li	a1,107
ffffffffc0201118:	00001517          	auipc	a0,0x1
ffffffffc020111c:	2e050513          	addi	a0,a0,736 # ffffffffc02023f8 <buddy_pmm_manager+0x180>
ffffffffc0201120:	a8cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201124 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201124:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201128:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020112a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020112e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201130:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201134:	f022                	sd	s0,32(sp)
ffffffffc0201136:	ec26                	sd	s1,24(sp)
ffffffffc0201138:	e84a                	sd	s2,16(sp)
ffffffffc020113a:	f406                	sd	ra,40(sp)
ffffffffc020113c:	e44e                	sd	s3,8(sp)
ffffffffc020113e:	84aa                	mv	s1,a0
ffffffffc0201140:	892e                	mv	s2,a1
ffffffffc0201142:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201146:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201148:	03067e63          	bleu	a6,a2,ffffffffc0201184 <printnum+0x60>
ffffffffc020114c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020114e:	00805763          	blez	s0,ffffffffc020115c <printnum+0x38>
ffffffffc0201152:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201154:	85ca                	mv	a1,s2
ffffffffc0201156:	854e                	mv	a0,s3
ffffffffc0201158:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020115a:	fc65                	bnez	s0,ffffffffc0201152 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020115c:	1a02                	slli	s4,s4,0x20
ffffffffc020115e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201162:	00001797          	auipc	a5,0x1
ffffffffc0201166:	49678793          	addi	a5,a5,1174 # ffffffffc02025f8 <error_string+0x38>
ffffffffc020116a:	9a3e                	add	s4,s4,a5
}
ffffffffc020116c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020116e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201172:	70a2                	ld	ra,40(sp)
ffffffffc0201174:	69a2                	ld	s3,8(sp)
ffffffffc0201176:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201178:	85ca                	mv	a1,s2
ffffffffc020117a:	8326                	mv	t1,s1
}
ffffffffc020117c:	6942                	ld	s2,16(sp)
ffffffffc020117e:	64e2                	ld	s1,24(sp)
ffffffffc0201180:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201182:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201184:	03065633          	divu	a2,a2,a6
ffffffffc0201188:	8722                	mv	a4,s0
ffffffffc020118a:	f9bff0ef          	jal	ra,ffffffffc0201124 <printnum>
ffffffffc020118e:	b7f9                	j	ffffffffc020115c <printnum+0x38>

ffffffffc0201190 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201190:	7119                	addi	sp,sp,-128
ffffffffc0201192:	f4a6                	sd	s1,104(sp)
ffffffffc0201194:	f0ca                	sd	s2,96(sp)
ffffffffc0201196:	e8d2                	sd	s4,80(sp)
ffffffffc0201198:	e4d6                	sd	s5,72(sp)
ffffffffc020119a:	e0da                	sd	s6,64(sp)
ffffffffc020119c:	fc5e                	sd	s7,56(sp)
ffffffffc020119e:	f862                	sd	s8,48(sp)
ffffffffc02011a0:	f06a                	sd	s10,32(sp)
ffffffffc02011a2:	fc86                	sd	ra,120(sp)
ffffffffc02011a4:	f8a2                	sd	s0,112(sp)
ffffffffc02011a6:	ecce                	sd	s3,88(sp)
ffffffffc02011a8:	f466                	sd	s9,40(sp)
ffffffffc02011aa:	ec6e                	sd	s11,24(sp)
ffffffffc02011ac:	892a                	mv	s2,a0
ffffffffc02011ae:	84ae                	mv	s1,a1
ffffffffc02011b0:	8d32                	mv	s10,a2
ffffffffc02011b2:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02011b4:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011b6:	00001a17          	auipc	s4,0x1
ffffffffc02011ba:	2b2a0a13          	addi	s4,s4,690 # ffffffffc0202468 <buddy_pmm_manager+0x1f0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02011be:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02011c2:	00001c17          	auipc	s8,0x1
ffffffffc02011c6:	3fec0c13          	addi	s8,s8,1022 # ffffffffc02025c0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011ca:	000d4503          	lbu	a0,0(s10)
ffffffffc02011ce:	02500793          	li	a5,37
ffffffffc02011d2:	001d0413          	addi	s0,s10,1
ffffffffc02011d6:	00f50e63          	beq	a0,a5,ffffffffc02011f2 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02011da:	c521                	beqz	a0,ffffffffc0201222 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011dc:	02500993          	li	s3,37
ffffffffc02011e0:	a011                	j	ffffffffc02011e4 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02011e2:	c121                	beqz	a0,ffffffffc0201222 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02011e4:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011e6:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02011e8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02011ea:	fff44503          	lbu	a0,-1(s0)
ffffffffc02011ee:	ff351ae3          	bne	a0,s3,ffffffffc02011e2 <vprintfmt+0x52>
ffffffffc02011f2:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02011f6:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02011fa:	4981                	li	s3,0
ffffffffc02011fc:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02011fe:	5cfd                	li	s9,-1
ffffffffc0201200:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201202:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201206:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201208:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020120c:	0ff6f693          	andi	a3,a3,255
ffffffffc0201210:	00140d13          	addi	s10,s0,1
ffffffffc0201214:	20d5e563          	bltu	a1,a3,ffffffffc020141e <vprintfmt+0x28e>
ffffffffc0201218:	068a                	slli	a3,a3,0x2
ffffffffc020121a:	96d2                	add	a3,a3,s4
ffffffffc020121c:	4294                	lw	a3,0(a3)
ffffffffc020121e:	96d2                	add	a3,a3,s4
ffffffffc0201220:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201222:	70e6                	ld	ra,120(sp)
ffffffffc0201224:	7446                	ld	s0,112(sp)
ffffffffc0201226:	74a6                	ld	s1,104(sp)
ffffffffc0201228:	7906                	ld	s2,96(sp)
ffffffffc020122a:	69e6                	ld	s3,88(sp)
ffffffffc020122c:	6a46                	ld	s4,80(sp)
ffffffffc020122e:	6aa6                	ld	s5,72(sp)
ffffffffc0201230:	6b06                	ld	s6,64(sp)
ffffffffc0201232:	7be2                	ld	s7,56(sp)
ffffffffc0201234:	7c42                	ld	s8,48(sp)
ffffffffc0201236:	7ca2                	ld	s9,40(sp)
ffffffffc0201238:	7d02                	ld	s10,32(sp)
ffffffffc020123a:	6de2                	ld	s11,24(sp)
ffffffffc020123c:	6109                	addi	sp,sp,128
ffffffffc020123e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201240:	4705                	li	a4,1
ffffffffc0201242:	008a8593          	addi	a1,s5,8
ffffffffc0201246:	01074463          	blt	a4,a6,ffffffffc020124e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020124a:	26080363          	beqz	a6,ffffffffc02014b0 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020124e:	000ab603          	ld	a2,0(s5)
ffffffffc0201252:	46c1                	li	a3,16
ffffffffc0201254:	8aae                	mv	s5,a1
ffffffffc0201256:	a06d                	j	ffffffffc0201300 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201258:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020125c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020125e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201260:	b765                	j	ffffffffc0201208 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201262:	000aa503          	lw	a0,0(s5)
ffffffffc0201266:	85a6                	mv	a1,s1
ffffffffc0201268:	0aa1                	addi	s5,s5,8
ffffffffc020126a:	9902                	jalr	s2
            break;
ffffffffc020126c:	bfb9                	j	ffffffffc02011ca <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020126e:	4705                	li	a4,1
ffffffffc0201270:	008a8993          	addi	s3,s5,8
ffffffffc0201274:	01074463          	blt	a4,a6,ffffffffc020127c <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201278:	22080463          	beqz	a6,ffffffffc02014a0 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020127c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201280:	24044463          	bltz	s0,ffffffffc02014c8 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0201284:	8622                	mv	a2,s0
ffffffffc0201286:	8ace                	mv	s5,s3
ffffffffc0201288:	46a9                	li	a3,10
ffffffffc020128a:	a89d                	j	ffffffffc0201300 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020128c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201290:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201292:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0201294:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201298:	8fb5                	xor	a5,a5,a3
ffffffffc020129a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020129e:	1ad74363          	blt	a4,a3,ffffffffc0201444 <vprintfmt+0x2b4>
ffffffffc02012a2:	00369793          	slli	a5,a3,0x3
ffffffffc02012a6:	97e2                	add	a5,a5,s8
ffffffffc02012a8:	639c                	ld	a5,0(a5)
ffffffffc02012aa:	18078d63          	beqz	a5,ffffffffc0201444 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02012ae:	86be                	mv	a3,a5
ffffffffc02012b0:	00001617          	auipc	a2,0x1
ffffffffc02012b4:	3f860613          	addi	a2,a2,1016 # ffffffffc02026a8 <error_string+0xe8>
ffffffffc02012b8:	85a6                	mv	a1,s1
ffffffffc02012ba:	854a                	mv	a0,s2
ffffffffc02012bc:	240000ef          	jal	ra,ffffffffc02014fc <printfmt>
ffffffffc02012c0:	b729                	j	ffffffffc02011ca <vprintfmt+0x3a>
            lflag ++;
ffffffffc02012c2:	00144603          	lbu	a2,1(s0)
ffffffffc02012c6:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02012ca:	bf3d                	j	ffffffffc0201208 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02012cc:	4705                	li	a4,1
ffffffffc02012ce:	008a8593          	addi	a1,s5,8
ffffffffc02012d2:	01074463          	blt	a4,a6,ffffffffc02012da <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02012d6:	1e080263          	beqz	a6,ffffffffc02014ba <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02012da:	000ab603          	ld	a2,0(s5)
ffffffffc02012de:	46a1                	li	a3,8
ffffffffc02012e0:	8aae                	mv	s5,a1
ffffffffc02012e2:	a839                	j	ffffffffc0201300 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02012e4:	03000513          	li	a0,48
ffffffffc02012e8:	85a6                	mv	a1,s1
ffffffffc02012ea:	e03e                	sd	a5,0(sp)
ffffffffc02012ec:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02012ee:	85a6                	mv	a1,s1
ffffffffc02012f0:	07800513          	li	a0,120
ffffffffc02012f4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02012f6:	0aa1                	addi	s5,s5,8
ffffffffc02012f8:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02012fc:	6782                	ld	a5,0(sp)
ffffffffc02012fe:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201300:	876e                	mv	a4,s11
ffffffffc0201302:	85a6                	mv	a1,s1
ffffffffc0201304:	854a                	mv	a0,s2
ffffffffc0201306:	e1fff0ef          	jal	ra,ffffffffc0201124 <printnum>
            break;
ffffffffc020130a:	b5c1                	j	ffffffffc02011ca <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020130c:	000ab603          	ld	a2,0(s5)
ffffffffc0201310:	0aa1                	addi	s5,s5,8
ffffffffc0201312:	1c060663          	beqz	a2,ffffffffc02014de <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201316:	00160413          	addi	s0,a2,1
ffffffffc020131a:	17b05c63          	blez	s11,ffffffffc0201492 <vprintfmt+0x302>
ffffffffc020131e:	02d00593          	li	a1,45
ffffffffc0201322:	14b79263          	bne	a5,a1,ffffffffc0201466 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201326:	00064783          	lbu	a5,0(a2)
ffffffffc020132a:	0007851b          	sext.w	a0,a5
ffffffffc020132e:	c905                	beqz	a0,ffffffffc020135e <vprintfmt+0x1ce>
ffffffffc0201330:	000cc563          	bltz	s9,ffffffffc020133a <vprintfmt+0x1aa>
ffffffffc0201334:	3cfd                	addiw	s9,s9,-1
ffffffffc0201336:	036c8263          	beq	s9,s6,ffffffffc020135a <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020133a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020133c:	18098463          	beqz	s3,ffffffffc02014c4 <vprintfmt+0x334>
ffffffffc0201340:	3781                	addiw	a5,a5,-32
ffffffffc0201342:	18fbf163          	bleu	a5,s7,ffffffffc02014c4 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201346:	03f00513          	li	a0,63
ffffffffc020134a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020134c:	0405                	addi	s0,s0,1
ffffffffc020134e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201352:	3dfd                	addiw	s11,s11,-1
ffffffffc0201354:	0007851b          	sext.w	a0,a5
ffffffffc0201358:	fd61                	bnez	a0,ffffffffc0201330 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020135a:	e7b058e3          	blez	s11,ffffffffc02011ca <vprintfmt+0x3a>
ffffffffc020135e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201360:	85a6                	mv	a1,s1
ffffffffc0201362:	02000513          	li	a0,32
ffffffffc0201366:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201368:	e60d81e3          	beqz	s11,ffffffffc02011ca <vprintfmt+0x3a>
ffffffffc020136c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020136e:	85a6                	mv	a1,s1
ffffffffc0201370:	02000513          	li	a0,32
ffffffffc0201374:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201376:	fe0d94e3          	bnez	s11,ffffffffc020135e <vprintfmt+0x1ce>
ffffffffc020137a:	bd81                	j	ffffffffc02011ca <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020137c:	4705                	li	a4,1
ffffffffc020137e:	008a8593          	addi	a1,s5,8
ffffffffc0201382:	01074463          	blt	a4,a6,ffffffffc020138a <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0201386:	12080063          	beqz	a6,ffffffffc02014a6 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020138a:	000ab603          	ld	a2,0(s5)
ffffffffc020138e:	46a9                	li	a3,10
ffffffffc0201390:	8aae                	mv	s5,a1
ffffffffc0201392:	b7bd                	j	ffffffffc0201300 <vprintfmt+0x170>
ffffffffc0201394:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0201398:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020139c:	846a                	mv	s0,s10
ffffffffc020139e:	b5ad                	j	ffffffffc0201208 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02013a0:	85a6                	mv	a1,s1
ffffffffc02013a2:	02500513          	li	a0,37
ffffffffc02013a6:	9902                	jalr	s2
            break;
ffffffffc02013a8:	b50d                	j	ffffffffc02011ca <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02013aa:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02013ae:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02013b2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013b4:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02013b6:	e40dd9e3          	bgez	s11,ffffffffc0201208 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02013ba:	8de6                	mv	s11,s9
ffffffffc02013bc:	5cfd                	li	s9,-1
ffffffffc02013be:	b5a9                	j	ffffffffc0201208 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02013c0:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02013c4:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013c8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02013ca:	bd3d                	j	ffffffffc0201208 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02013cc:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02013d0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013d4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02013d6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02013da:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02013de:	fcd56ce3          	bltu	a0,a3,ffffffffc02013b6 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02013e2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02013e4:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02013e8:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02013ec:	0196873b          	addw	a4,a3,s9
ffffffffc02013f0:	0017171b          	slliw	a4,a4,0x1
ffffffffc02013f4:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02013f8:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02013fc:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201400:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201404:	fcd57fe3          	bleu	a3,a0,ffffffffc02013e2 <vprintfmt+0x252>
ffffffffc0201408:	b77d                	j	ffffffffc02013b6 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020140a:	fffdc693          	not	a3,s11
ffffffffc020140e:	96fd                	srai	a3,a3,0x3f
ffffffffc0201410:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201414:	00144603          	lbu	a2,1(s0)
ffffffffc0201418:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020141a:	846a                	mv	s0,s10
ffffffffc020141c:	b3f5                	j	ffffffffc0201208 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020141e:	85a6                	mv	a1,s1
ffffffffc0201420:	02500513          	li	a0,37
ffffffffc0201424:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201426:	fff44703          	lbu	a4,-1(s0)
ffffffffc020142a:	02500793          	li	a5,37
ffffffffc020142e:	8d22                	mv	s10,s0
ffffffffc0201430:	d8f70de3          	beq	a4,a5,ffffffffc02011ca <vprintfmt+0x3a>
ffffffffc0201434:	02500713          	li	a4,37
ffffffffc0201438:	1d7d                	addi	s10,s10,-1
ffffffffc020143a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020143e:	fee79de3          	bne	a5,a4,ffffffffc0201438 <vprintfmt+0x2a8>
ffffffffc0201442:	b361                	j	ffffffffc02011ca <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201444:	00001617          	auipc	a2,0x1
ffffffffc0201448:	25460613          	addi	a2,a2,596 # ffffffffc0202698 <error_string+0xd8>
ffffffffc020144c:	85a6                	mv	a1,s1
ffffffffc020144e:	854a                	mv	a0,s2
ffffffffc0201450:	0ac000ef          	jal	ra,ffffffffc02014fc <printfmt>
ffffffffc0201454:	bb9d                	j	ffffffffc02011ca <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201456:	00001617          	auipc	a2,0x1
ffffffffc020145a:	23a60613          	addi	a2,a2,570 # ffffffffc0202690 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020145e:	00001417          	auipc	s0,0x1
ffffffffc0201462:	23340413          	addi	s0,s0,563 # ffffffffc0202691 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201466:	8532                	mv	a0,a2
ffffffffc0201468:	85e6                	mv	a1,s9
ffffffffc020146a:	e032                	sd	a2,0(sp)
ffffffffc020146c:	e43e                	sd	a5,8(sp)
ffffffffc020146e:	1c2000ef          	jal	ra,ffffffffc0201630 <strnlen>
ffffffffc0201472:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201476:	6602                	ld	a2,0(sp)
ffffffffc0201478:	01b05d63          	blez	s11,ffffffffc0201492 <vprintfmt+0x302>
ffffffffc020147c:	67a2                	ld	a5,8(sp)
ffffffffc020147e:	2781                	sext.w	a5,a5
ffffffffc0201480:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201482:	6522                	ld	a0,8(sp)
ffffffffc0201484:	85a6                	mv	a1,s1
ffffffffc0201486:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201488:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020148a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020148c:	6602                	ld	a2,0(sp)
ffffffffc020148e:	fe0d9ae3          	bnez	s11,ffffffffc0201482 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201492:	00064783          	lbu	a5,0(a2)
ffffffffc0201496:	0007851b          	sext.w	a0,a5
ffffffffc020149a:	e8051be3          	bnez	a0,ffffffffc0201330 <vprintfmt+0x1a0>
ffffffffc020149e:	b335                	j	ffffffffc02011ca <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02014a0:	000aa403          	lw	s0,0(s5)
ffffffffc02014a4:	bbf1                	j	ffffffffc0201280 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02014a6:	000ae603          	lwu	a2,0(s5)
ffffffffc02014aa:	46a9                	li	a3,10
ffffffffc02014ac:	8aae                	mv	s5,a1
ffffffffc02014ae:	bd89                	j	ffffffffc0201300 <vprintfmt+0x170>
ffffffffc02014b0:	000ae603          	lwu	a2,0(s5)
ffffffffc02014b4:	46c1                	li	a3,16
ffffffffc02014b6:	8aae                	mv	s5,a1
ffffffffc02014b8:	b5a1                	j	ffffffffc0201300 <vprintfmt+0x170>
ffffffffc02014ba:	000ae603          	lwu	a2,0(s5)
ffffffffc02014be:	46a1                	li	a3,8
ffffffffc02014c0:	8aae                	mv	s5,a1
ffffffffc02014c2:	bd3d                	j	ffffffffc0201300 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02014c4:	9902                	jalr	s2
ffffffffc02014c6:	b559                	j	ffffffffc020134c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02014c8:	85a6                	mv	a1,s1
ffffffffc02014ca:	02d00513          	li	a0,45
ffffffffc02014ce:	e03e                	sd	a5,0(sp)
ffffffffc02014d0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02014d2:	8ace                	mv	s5,s3
ffffffffc02014d4:	40800633          	neg	a2,s0
ffffffffc02014d8:	46a9                	li	a3,10
ffffffffc02014da:	6782                	ld	a5,0(sp)
ffffffffc02014dc:	b515                	j	ffffffffc0201300 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02014de:	01b05663          	blez	s11,ffffffffc02014ea <vprintfmt+0x35a>
ffffffffc02014e2:	02d00693          	li	a3,45
ffffffffc02014e6:	f6d798e3          	bne	a5,a3,ffffffffc0201456 <vprintfmt+0x2c6>
ffffffffc02014ea:	00001417          	auipc	s0,0x1
ffffffffc02014ee:	1a740413          	addi	s0,s0,423 # ffffffffc0202691 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02014f2:	02800513          	li	a0,40
ffffffffc02014f6:	02800793          	li	a5,40
ffffffffc02014fa:	bd1d                	j	ffffffffc0201330 <vprintfmt+0x1a0>

ffffffffc02014fc <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02014fc:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02014fe:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201502:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201504:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201506:	ec06                	sd	ra,24(sp)
ffffffffc0201508:	f83a                	sd	a4,48(sp)
ffffffffc020150a:	fc3e                	sd	a5,56(sp)
ffffffffc020150c:	e0c2                	sd	a6,64(sp)
ffffffffc020150e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201510:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201512:	c7fff0ef          	jal	ra,ffffffffc0201190 <vprintfmt>
}
ffffffffc0201516:	60e2                	ld	ra,24(sp)
ffffffffc0201518:	6161                	addi	sp,sp,80
ffffffffc020151a:	8082                	ret

ffffffffc020151c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020151c:	715d                	addi	sp,sp,-80
ffffffffc020151e:	e486                	sd	ra,72(sp)
ffffffffc0201520:	e0a2                	sd	s0,64(sp)
ffffffffc0201522:	fc26                	sd	s1,56(sp)
ffffffffc0201524:	f84a                	sd	s2,48(sp)
ffffffffc0201526:	f44e                	sd	s3,40(sp)
ffffffffc0201528:	f052                	sd	s4,32(sp)
ffffffffc020152a:	ec56                	sd	s5,24(sp)
ffffffffc020152c:	e85a                	sd	s6,16(sp)
ffffffffc020152e:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201530:	c901                	beqz	a0,ffffffffc0201540 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201532:	85aa                	mv	a1,a0
ffffffffc0201534:	00001517          	auipc	a0,0x1
ffffffffc0201538:	17450513          	addi	a0,a0,372 # ffffffffc02026a8 <error_string+0xe8>
ffffffffc020153c:	b7bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201540:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201542:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201544:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201546:	4aa9                	li	s5,10
ffffffffc0201548:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020154a:	00005b97          	auipc	s7,0x5
ffffffffc020154e:	ac6b8b93          	addi	s7,s7,-1338 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201552:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201556:	bd9fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020155a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020155c:	00054b63          	bltz	a0,ffffffffc0201572 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201560:	00a95b63          	ble	a0,s2,ffffffffc0201576 <readline+0x5a>
ffffffffc0201564:	029a5463          	ble	s1,s4,ffffffffc020158c <readline+0x70>
        c = getchar();
ffffffffc0201568:	bc7fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020156c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020156e:	fe0559e3          	bgez	a0,ffffffffc0201560 <readline+0x44>
            return NULL;
ffffffffc0201572:	4501                	li	a0,0
ffffffffc0201574:	a099                	j	ffffffffc02015ba <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201576:	03341463          	bne	s0,s3,ffffffffc020159e <readline+0x82>
ffffffffc020157a:	e8b9                	bnez	s1,ffffffffc02015d0 <readline+0xb4>
        c = getchar();
ffffffffc020157c:	bb3fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201580:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201582:	fe0548e3          	bltz	a0,ffffffffc0201572 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201586:	fea958e3          	ble	a0,s2,ffffffffc0201576 <readline+0x5a>
ffffffffc020158a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020158c:	8522                	mv	a0,s0
ffffffffc020158e:	b5dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201592:	009b87b3          	add	a5,s7,s1
ffffffffc0201596:	00878023          	sb	s0,0(a5)
ffffffffc020159a:	2485                	addiw	s1,s1,1
ffffffffc020159c:	bf6d                	j	ffffffffc0201556 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020159e:	01540463          	beq	s0,s5,ffffffffc02015a6 <readline+0x8a>
ffffffffc02015a2:	fb641ae3          	bne	s0,s6,ffffffffc0201556 <readline+0x3a>
            cputchar(c);
ffffffffc02015a6:	8522                	mv	a0,s0
ffffffffc02015a8:	b43fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02015ac:	00005517          	auipc	a0,0x5
ffffffffc02015b0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0206010 <edata>
ffffffffc02015b4:	94aa                	add	s1,s1,a0
ffffffffc02015b6:	00048023          	sb	zero,0(s1) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
            return buf;
        }
    }
}
ffffffffc02015ba:	60a6                	ld	ra,72(sp)
ffffffffc02015bc:	6406                	ld	s0,64(sp)
ffffffffc02015be:	74e2                	ld	s1,56(sp)
ffffffffc02015c0:	7942                	ld	s2,48(sp)
ffffffffc02015c2:	79a2                	ld	s3,40(sp)
ffffffffc02015c4:	7a02                	ld	s4,32(sp)
ffffffffc02015c6:	6ae2                	ld	s5,24(sp)
ffffffffc02015c8:	6b42                	ld	s6,16(sp)
ffffffffc02015ca:	6ba2                	ld	s7,8(sp)
ffffffffc02015cc:	6161                	addi	sp,sp,80
ffffffffc02015ce:	8082                	ret
            cputchar(c);
ffffffffc02015d0:	4521                	li	a0,8
ffffffffc02015d2:	b19fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02015d6:	34fd                	addiw	s1,s1,-1
ffffffffc02015d8:	bfbd                	j	ffffffffc0201556 <readline+0x3a>

ffffffffc02015da <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02015da:	00005797          	auipc	a5,0x5
ffffffffc02015de:	a2e78793          	addi	a5,a5,-1490 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02015e2:	6398                	ld	a4,0(a5)
ffffffffc02015e4:	4781                	li	a5,0
ffffffffc02015e6:	88ba                	mv	a7,a4
ffffffffc02015e8:	852a                	mv	a0,a0
ffffffffc02015ea:	85be                	mv	a1,a5
ffffffffc02015ec:	863e                	mv	a2,a5
ffffffffc02015ee:	00000073          	ecall
ffffffffc02015f2:	87aa                	mv	a5,a0
}
ffffffffc02015f4:	8082                	ret

ffffffffc02015f6 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02015f6:	00005797          	auipc	a5,0x5
ffffffffc02015fa:	e3278793          	addi	a5,a5,-462 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02015fe:	6398                	ld	a4,0(a5)
ffffffffc0201600:	4781                	li	a5,0
ffffffffc0201602:	88ba                	mv	a7,a4
ffffffffc0201604:	852a                	mv	a0,a0
ffffffffc0201606:	85be                	mv	a1,a5
ffffffffc0201608:	863e                	mv	a2,a5
ffffffffc020160a:	00000073          	ecall
ffffffffc020160e:	87aa                	mv	a5,a0
}
ffffffffc0201610:	8082                	ret

ffffffffc0201612 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201612:	00005797          	auipc	a5,0x5
ffffffffc0201616:	9ee78793          	addi	a5,a5,-1554 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc020161a:	639c                	ld	a5,0(a5)
ffffffffc020161c:	4501                	li	a0,0
ffffffffc020161e:	88be                	mv	a7,a5
ffffffffc0201620:	852a                	mv	a0,a0
ffffffffc0201622:	85aa                	mv	a1,a0
ffffffffc0201624:	862a                	mv	a2,a0
ffffffffc0201626:	00000073          	ecall
ffffffffc020162a:	852a                	mv	a0,a0
ffffffffc020162c:	2501                	sext.w	a0,a0
ffffffffc020162e:	8082                	ret

ffffffffc0201630 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201630:	c185                	beqz	a1,ffffffffc0201650 <strnlen+0x20>
ffffffffc0201632:	00054783          	lbu	a5,0(a0)
ffffffffc0201636:	cf89                	beqz	a5,ffffffffc0201650 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201638:	4781                	li	a5,0
ffffffffc020163a:	a021                	j	ffffffffc0201642 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020163c:	00074703          	lbu	a4,0(a4) # fffffffffff80000 <end+0x3fd578a8>
ffffffffc0201640:	c711                	beqz	a4,ffffffffc020164c <strnlen+0x1c>
        cnt ++;
ffffffffc0201642:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201644:	00f50733          	add	a4,a0,a5
ffffffffc0201648:	fef59ae3          	bne	a1,a5,ffffffffc020163c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020164c:	853e                	mv	a0,a5
ffffffffc020164e:	8082                	ret
    size_t cnt = 0;
ffffffffc0201650:	4781                	li	a5,0
}
ffffffffc0201652:	853e                	mv	a0,a5
ffffffffc0201654:	8082                	ret

ffffffffc0201656 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201656:	00054783          	lbu	a5,0(a0)
ffffffffc020165a:	0005c703          	lbu	a4,0(a1) # fffffffffffff000 <end+0x3fdd68a8>
ffffffffc020165e:	cb91                	beqz	a5,ffffffffc0201672 <strcmp+0x1c>
ffffffffc0201660:	00e79c63          	bne	a5,a4,ffffffffc0201678 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201664:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201666:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020166a:	0585                	addi	a1,a1,1
ffffffffc020166c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201670:	fbe5                	bnez	a5,ffffffffc0201660 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201672:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201674:	9d19                	subw	a0,a0,a4
ffffffffc0201676:	8082                	ret
ffffffffc0201678:	0007851b          	sext.w	a0,a5
ffffffffc020167c:	9d19                	subw	a0,a0,a4
ffffffffc020167e:	8082                	ret

ffffffffc0201680 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201680:	00054783          	lbu	a5,0(a0)
ffffffffc0201684:	cb91                	beqz	a5,ffffffffc0201698 <strchr+0x18>
        if (*s == c) {
ffffffffc0201686:	00b79563          	bne	a5,a1,ffffffffc0201690 <strchr+0x10>
ffffffffc020168a:	a809                	j	ffffffffc020169c <strchr+0x1c>
ffffffffc020168c:	00b78763          	beq	a5,a1,ffffffffc020169a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201690:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201692:	00054783          	lbu	a5,0(a0)
ffffffffc0201696:	fbfd                	bnez	a5,ffffffffc020168c <strchr+0xc>
    }
    return NULL;
ffffffffc0201698:	4501                	li	a0,0
}
ffffffffc020169a:	8082                	ret
ffffffffc020169c:	8082                	ret

ffffffffc020169e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020169e:	ca01                	beqz	a2,ffffffffc02016ae <memset+0x10>
ffffffffc02016a0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02016a2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02016a4:	0785                	addi	a5,a5,1
ffffffffc02016a6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02016aa:	fec79de3          	bne	a5,a2,ffffffffc02016a4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02016ae:	8082                	ret
