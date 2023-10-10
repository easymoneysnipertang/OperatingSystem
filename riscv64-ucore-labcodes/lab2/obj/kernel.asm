
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
ffffffffc020003e:	00054617          	auipc	a2,0x54
ffffffffc0200042:	64260613          	addi	a2,a2,1602 # ffffffffc0254680 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	047010ef          	jal	ra,ffffffffc0201894 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	85250513          	addi	a0,a0,-1966 # ffffffffc02018a8 <etext+0x2>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	102010ef          	jal	ra,ffffffffc020116c <pmm_init>

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
ffffffffc02000aa:	2dc010ef          	jal	ra,ffffffffc0201386 <vprintfmt>
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
ffffffffc02000de:	2a8010ef          	jal	ra,ffffffffc0201386 <vprintfmt>
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
ffffffffc0200144:	7b850513          	addi	a0,a0,1976 # ffffffffc02018f8 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00001517          	auipc	a0,0x1
ffffffffc020015a:	7c250513          	addi	a0,a0,1986 # ffffffffc0201918 <etext+0x72>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00001597          	auipc	a1,0x1
ffffffffc0200166:	74458593          	addi	a1,a1,1860 # ffffffffc02018a6 <etext>
ffffffffc020016a:	00001517          	auipc	a0,0x1
ffffffffc020016e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0201938 <etext+0x92>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	e9a58593          	addi	a1,a1,-358 # ffffffffc0206010 <edata>
ffffffffc020017e:	00001517          	auipc	a0,0x1
ffffffffc0200182:	7da50513          	addi	a0,a0,2010 # ffffffffc0201958 <etext+0xb2>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00054597          	auipc	a1,0x54
ffffffffc020018e:	4f658593          	addi	a1,a1,1270 # ffffffffc0254680 <end>
ffffffffc0200192:	00001517          	auipc	a0,0x1
ffffffffc0200196:	7e650513          	addi	a0,a0,2022 # ffffffffc0201978 <etext+0xd2>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00055597          	auipc	a1,0x55
ffffffffc02001a2:	8e158593          	addi	a1,a1,-1823 # ffffffffc0254a7f <end+0x3ff>
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
ffffffffc02001c4:	7d850513          	addi	a0,a0,2008 # ffffffffc0201998 <etext+0xf2>
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
ffffffffc02001d4:	6f860613          	addi	a2,a2,1784 # ffffffffc02018c8 <etext+0x22>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00001517          	auipc	a0,0x1
ffffffffc02001e0:	70450513          	addi	a0,a0,1796 # ffffffffc02018e0 <etext+0x3a>
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
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0201aa8 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	8d458593          	addi	a1,a1,-1836 # ffffffffc0201ac8 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	8d450513          	addi	a0,a0,-1836 # ffffffffc0201ad0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	8d660613          	addi	a2,a2,-1834 # ffffffffc0201ae0 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	8f658593          	addi	a1,a1,-1802 # ffffffffc0201b08 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201ad0 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	8f260613          	addi	a2,a2,-1806 # ffffffffc0201b18 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	90a58593          	addi	a1,a1,-1782 # ffffffffc0201b38 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	89a50513          	addi	a0,a0,-1894 # ffffffffc0201ad0 <commands+0x108>
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
ffffffffc0200274:	7a050513          	addi	a0,a0,1952 # ffffffffc0201a10 <commands+0x48>
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
ffffffffc0200296:	7a650513          	addi	a0,a0,1958 # ffffffffc0201a38 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00001c97          	auipc	s9,0x1
ffffffffc02002ac:	720c8c93          	addi	s9,s9,1824 # ffffffffc02019c8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00001997          	auipc	s3,0x1
ffffffffc02002b4:	7b098993          	addi	s3,s3,1968 # ffffffffc0201a60 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00001917          	auipc	s2,0x1
ffffffffc02002bc:	7b090913          	addi	s2,s2,1968 # ffffffffc0201a68 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00001b17          	auipc	s6,0x1
ffffffffc02002c6:	7aeb0b13          	addi	s6,s6,1966 # ffffffffc0201a70 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00001a97          	auipc	s5,0x1
ffffffffc02002ce:	7fea8a93          	addi	s5,s5,2046 # ffffffffc0201ac8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	43c010ef          	jal	ra,ffffffffc0201712 <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	58e010ef          	jal	ra,ffffffffc0201876 <strchr>
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
ffffffffc0200302:	6cad0d13          	addi	s10,s10,1738 # ffffffffc02019c8 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	540010ef          	jal	ra,ffffffffc020184c <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	52c010ef          	jal	ra,ffffffffc020184c <strcmp>
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
ffffffffc0200386:	4f0010ef          	jal	ra,ffffffffc0201876 <strchr>
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
ffffffffc02003a2:	6f250513          	addi	a0,a0,1778 # ffffffffc0201a90 <commands+0xc8>
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
ffffffffc02003e2:	76a50513          	addi	a0,a0,1898 # ffffffffc0201b48 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00001517          	auipc	a0,0x1
ffffffffc02003f8:	5cc50513          	addi	a0,a0,1484 # ffffffffc02019c0 <etext+0x11a>
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
ffffffffc0200424:	3c8010ef          	jal	ra,ffffffffc02017ec <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b323          	sd	zero,6(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	73650513          	addi	a0,a0,1846 # ffffffffc0201b68 <commands+0x1a0>
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
ffffffffc020044c:	3a00106f          	j	ffffffffc02017ec <sbi_set_timer>

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
ffffffffc0200456:	37a0106f          	j	ffffffffc02017d0 <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	3ae0106f          	j	ffffffffc0201808 <sbi_console_getchar>

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
ffffffffc0200488:	7fc50513          	addi	a0,a0,2044 # ffffffffc0201c80 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	80450513          	addi	a0,a0,-2044 # ffffffffc0201c98 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	80e50513          	addi	a0,a0,-2034 # ffffffffc0201cb0 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	81850513          	addi	a0,a0,-2024 # ffffffffc0201cc8 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	82250513          	addi	a0,a0,-2014 # ffffffffc0201ce0 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0201cf8 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	83650513          	addi	a0,a0,-1994 # ffffffffc0201d10 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	84050513          	addi	a0,a0,-1984 # ffffffffc0201d28 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	84a50513          	addi	a0,a0,-1974 # ffffffffc0201d40 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	85450513          	addi	a0,a0,-1964 # ffffffffc0201d58 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	85e50513          	addi	a0,a0,-1954 # ffffffffc0201d70 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	86850513          	addi	a0,a0,-1944 # ffffffffc0201d88 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	87250513          	addi	a0,a0,-1934 # ffffffffc0201da0 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	87c50513          	addi	a0,a0,-1924 # ffffffffc0201db8 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	88650513          	addi	a0,a0,-1914 # ffffffffc0201dd0 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	89050513          	addi	a0,a0,-1904 # ffffffffc0201de8 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	89a50513          	addi	a0,a0,-1894 # ffffffffc0201e00 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	8a450513          	addi	a0,a0,-1884 # ffffffffc0201e18 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0201e30 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	8b850513          	addi	a0,a0,-1864 # ffffffffc0201e48 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201e60 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0201e78 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	8d650513          	addi	a0,a0,-1834 # ffffffffc0201e90 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	8e050513          	addi	a0,a0,-1824 # ffffffffc0201ea8 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201ec0 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	8f450513          	addi	a0,a0,-1804 # ffffffffc0201ed8 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201ef0 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	90850513          	addi	a0,a0,-1784 # ffffffffc0201f08 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	91250513          	addi	a0,a0,-1774 # ffffffffc0201f20 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	91c50513          	addi	a0,a0,-1764 # ffffffffc0201f38 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	92650513          	addi	a0,a0,-1754 # ffffffffc0201f50 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	92c50513          	addi	a0,a0,-1748 # ffffffffc0201f68 <commands+0x5a0>
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
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201f80 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	92e50513          	addi	a0,a0,-1746 # ffffffffc0201f98 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	93650513          	addi	a0,a0,-1738 # ffffffffc0201fb0 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201fc8 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	94250513          	addi	a0,a0,-1726 # ffffffffc0201fe0 <commands+0x618>
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
ffffffffc02006c0:	4c870713          	addi	a4,a4,1224 # ffffffffc0201b84 <commands+0x1bc>
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
ffffffffc02006d2:	54a50513          	addi	a0,a0,1354 # ffffffffc0201c18 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	51e50513          	addi	a0,a0,1310 # ffffffffc0201bf8 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	4d250513          	addi	a0,a0,1234 # ffffffffc0201bb8 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	54650513          	addi	a0,a0,1350 # ffffffffc0201c38 <commands+0x270>
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
ffffffffc020072e:	53650513          	addi	a0,a0,1334 # ffffffffc0201c60 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	4a250513          	addi	a0,a0,1186 # ffffffffc0201bd8 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	50450513          	addi	a0,a0,1284 # ffffffffc0201c50 <commands+0x288>
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

ffffffffc020082a <buddy_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c0e78793          	addi	a5,a5,-1010 # ffffffffc0206438 <free_area>
ffffffffc0200832:	e79c                	sd	a5,8(a5)
ffffffffc0200834:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
buddy_init(void){
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200836:	0007a823          	sw	zero,16(a5)
}
ffffffffc020083a:	8082                	ret

ffffffffc020083c <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020083c:	00006517          	auipc	a0,0x6
ffffffffc0200840:	c0c56503          	lwu	a0,-1012(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200844:	8082                	ret

ffffffffc0200846 <buddy_free_pages>:
{
ffffffffc0200846:	711d                	addi	sp,sp,-96
ffffffffc0200848:	ec86                	sd	ra,88(sp)
ffffffffc020084a:	e8a2                	sd	s0,80(sp)
ffffffffc020084c:	e4a6                	sd	s1,72(sp)
ffffffffc020084e:	e0ca                	sd	s2,64(sp)
ffffffffc0200850:	fc4e                	sd	s3,56(sp)
ffffffffc0200852:	f852                	sd	s4,48(sp)
ffffffffc0200854:	f456                	sd	s5,40(sp)
ffffffffc0200856:	f05a                	sd	s6,32(sp)
ffffffffc0200858:	ec5e                	sd	s7,24(sp)
ffffffffc020085a:	e862                	sd	s8,16(sp)
ffffffffc020085c:	e466                	sd	s9,8(sp)
    assert(n>0);
ffffffffc020085e:	2a058e63          	beqz	a1,ffffffffc0200b1a <buddy_free_pages+0x2d4>
    assert(IS_POWER_OF_2(n));
ffffffffc0200862:	fff58793          	addi	a5,a1,-1
ffffffffc0200866:	8fed                	and	a5,a5,a1
ffffffffc0200868:	892e                	mv	s2,a1
ffffffffc020086a:	28079863          	bnez	a5,ffffffffc0200afa <buddy_free_pages+0x2b4>
    assert(base >= page_base && base < page_base + root->size);
ffffffffc020086e:	00054c17          	auipc	s8,0x54
ffffffffc0200872:	deac0c13          	addi	s8,s8,-534 # ffffffffc0254658 <page_base>
ffffffffc0200876:	000c3783          	ld	a5,0(s8)
ffffffffc020087a:	8baa                	mv	s7,a0
ffffffffc020087c:	24f56f63          	bltu	a0,a5,ffffffffc0200ada <buddy_free_pages+0x294>
ffffffffc0200880:	00006497          	auipc	s1,0x6
ffffffffc0200884:	bd84e483          	lwu	s1,-1064(s1) # ffffffffc0206458 <root>
ffffffffc0200888:	00249713          	slli	a4,s1,0x2
ffffffffc020088c:	9726                	add	a4,a4,s1
ffffffffc020088e:	070e                	slli	a4,a4,0x3
ffffffffc0200890:	973e                	add	a4,a4,a5
ffffffffc0200892:	24e57463          	bleu	a4,a0,ffffffffc0200ada <buddy_free_pages+0x294>
    int div_seg_num = root->size/n;
ffffffffc0200896:	02b4d4b3          	divu	s1,s1,a1
    int page_num = base - page_base;//第几页
ffffffffc020089a:	00002717          	auipc	a4,0x2
ffffffffc020089e:	8fe70713          	addi	a4,a4,-1794 # ffffffffc0202198 <commands+0x7d0>
ffffffffc02008a2:	00073a03          	ld	s4,0(a4)
ffffffffc02008a6:	40f50b33          	sub	s6,a0,a5
ffffffffc02008aa:	403b5b13          	srai	s6,s6,0x3
    cprintf("in free: page_num: %d div_seg_num: %d\n",page_num,div_seg_num);
ffffffffc02008ae:	00002517          	auipc	a0,0x2
ffffffffc02008b2:	97a50513          	addi	a0,a0,-1670 # ffffffffc0202228 <commands+0x860>
    int page_num = base - page_base;//第几页
ffffffffc02008b6:	034b0b3b          	mulw	s6,s6,s4
    int div_seg_num = root->size/n;
ffffffffc02008ba:	2481                	sext.w	s1,s1
    cprintf("in free: page_num: %d div_seg_num: %d\n",page_num,div_seg_num);
ffffffffc02008bc:	8626                	mv	a2,s1
ffffffffc02008be:	85da                	mv	a1,s6
ffffffffc02008c0:	ff6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert(page_num % n == 0); //必须在分位点上
ffffffffc02008c4:	032b77b3          	remu	a5,s6,s2
ffffffffc02008c8:	1e079963          	bnez	a5,ffffffffc0200aba <buddy_free_pages+0x274>
    for (; p != base + n; p ++) {
ffffffffc02008cc:	00291993          	slli	s3,s2,0x2
ffffffffc02008d0:	99ca                	add	s3,s3,s2
ffffffffc02008d2:	098e                	slli	s3,s3,0x3
ffffffffc02008d4:	99de                	add	s3,s3,s7
ffffffffc02008d6:	845e                	mv	s0,s7
        cprintf("in free: n->%d, property:%d, page_property:%d, page_num:%d\n",n,PageProperty(p),p->property, p - page_base);
ffffffffc02008d8:	00002a97          	auipc	s5,0x2
ffffffffc02008dc:	990a8a93          	addi	s5,s5,-1648 # ffffffffc0202268 <commands+0x8a0>
    for (; p != base + n; p ++) {
ffffffffc02008e0:	053b8163          	beq	s7,s3,ffffffffc0200922 <buddy_free_pages+0xdc>
        cprintf("in free: n->%d, property:%d, page_property:%d, page_num:%d\n",n,PageProperty(p),p->property, p - page_base);
ffffffffc02008e4:	000c3703          	ld	a4,0(s8)
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02008e8:	6410                	ld	a2,8(s0)
ffffffffc02008ea:	4814                	lw	a3,16(s0)
ffffffffc02008ec:	40e40733          	sub	a4,s0,a4
ffffffffc02008f0:	870d                	srai	a4,a4,0x3
ffffffffc02008f2:	03470733          	mul	a4,a4,s4
ffffffffc02008f6:	8205                	srli	a2,a2,0x1
ffffffffc02008f8:	8a05                	andi	a2,a2,1
ffffffffc02008fa:	85ca                	mv	a1,s2
ffffffffc02008fc:	8556                	mv	a0,s5
ffffffffc02008fe:	fb8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200902:	641c                	ld	a5,8(s0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200904:	8b85                	andi	a5,a5,1
ffffffffc0200906:	18079a63          	bnez	a5,ffffffffc0200a9a <buddy_free_pages+0x254>
ffffffffc020090a:	641c                	ld	a5,8(s0)
ffffffffc020090c:	8b89                	andi	a5,a5,2
ffffffffc020090e:	18079663          	bnez	a5,ffffffffc0200a9a <buddy_free_pages+0x254>
        p->flags = 0;
ffffffffc0200912:	00043423          	sd	zero,8(s0)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200916:	00042023          	sw	zero,0(s0)
    for (; p != base + n; p ++) {
ffffffffc020091a:	02840413          	addi	s0,s0,40
ffffffffc020091e:	fd3413e3          	bne	s0,s3,ffffffffc02008e4 <buddy_free_pages+0x9e>
    base->property = n;
ffffffffc0200922:	2901                	sext.w	s2,s2
ffffffffc0200924:	012ba823          	sw	s2,16(s7)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200928:	4789                	li	a5,2
ffffffffc020092a:	008b8713          	addi	a4,s7,8
ffffffffc020092e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0200932:	00006797          	auipc	a5,0x6
ffffffffc0200936:	b0678793          	addi	a5,a5,-1274 # ffffffffc0206438 <free_area>
ffffffffc020093a:	4b98                	lw	a4,16(a5)
    if (list_empty(&free_list)) 
ffffffffc020093c:	6794                	ld	a3,8(a5)
    nr_free += n;
ffffffffc020093e:	0127073b          	addw	a4,a4,s2
ffffffffc0200942:	00006617          	auipc	a2,0x6
ffffffffc0200946:	b0e62323          	sw	a4,-1274(a2) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) 
ffffffffc020094a:	12f68f63          	beq	a3,a5,ffffffffc0200a88 <buddy_free_pages+0x242>
        int buddy_index = div_seg_num - 1 + page_num / div_seg_num; //该页所对应的树节点
ffffffffc020094e:	029b4b3b          	divw	s6,s6,s1
ffffffffc0200952:	34fd                	addiw	s1,s1,-1
        root[buddy_index].len = n;
ffffffffc0200954:	00006a97          	auipc	s5,0x6
ffffffffc0200958:	b04a8a93          	addi	s5,s5,-1276 # ffffffffc0206458 <root>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020095c:	5bf5                	li	s7,-3
                    cprintf("in free\n");
ffffffffc020095e:	00002417          	auipc	s0,0x2
ffffffffc0200962:	97240413          	addi	s0,s0,-1678 # ffffffffc02022d0 <commands+0x908>
        int buddy_index = div_seg_num - 1 + page_num / div_seg_num; //该页所对应的树节点
ffffffffc0200966:	016484bb          	addw	s1,s1,s6
        root[buddy_index].len = n;
ffffffffc020096a:	00349793          	slli	a5,s1,0x3
ffffffffc020096e:	97d6                	add	a5,a5,s5
ffffffffc0200970:	0127a223          	sw	s2,4(a5)
        while (buddy_index) // 向上合并
ffffffffc0200974:	c4a1                	beqz	s1,ffffffffc02009bc <buddy_free_pages+0x176>
            buddy_index = PARENT(buddy_index);
ffffffffc0200976:	2485                	addiw	s1,s1,1
ffffffffc0200978:	01f4d79b          	srliw	a5,s1,0x1f
ffffffffc020097c:	9fa5                	addw	a5,a5,s1
ffffffffc020097e:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc0200982:	fff7849b          	addiw	s1,a5,-1
            int left_longest = root[LEFT_LEAF(buddy_index)].len;
ffffffffc0200986:	0014971b          	slliw	a4,s1,0x1
ffffffffc020098a:	0017061b          	addiw	a2,a4,1
            int right_longest = root[RIGHT_LEAF(buddy_index)].len;
ffffffffc020098e:	0027069b          	addiw	a3,a4,2
            int left_longest = root[LEFT_LEAF(buddy_index)].len;
ffffffffc0200992:	060e                	slli	a2,a2,0x3
            int right_longest = root[RIGHT_LEAF(buddy_index)].len;
ffffffffc0200994:	068e                	slli	a3,a3,0x3
            int left_longest = root[LEFT_LEAF(buddy_index)].len;
ffffffffc0200996:	9656                	add	a2,a2,s5
            int right_longest = root[RIGHT_LEAF(buddy_index)].len;
ffffffffc0200998:	96d6                	add	a3,a3,s5
            int left_longest = root[LEFT_LEAF(buddy_index)].len;
ffffffffc020099a:	4250                	lw	a2,4(a2)
            int right_longest = root[RIGHT_LEAF(buddy_index)].len;
ffffffffc020099c:	42cc                	lw	a1,4(a3)
            node_size *= 2;
ffffffffc020099e:	0019191b          	slliw	s2,s2,0x1
            if (left_longest + right_longest == node_size) // 进行合并
ffffffffc02009a2:	00b6053b          	addw	a0,a2,a1
ffffffffc02009a6:	03250863          	beq	a0,s2,ffffffffc02009d6 <buddy_free_pages+0x190>
                root[buddy_index].len = MAX(left_longest, right_longest);
ffffffffc02009aa:	00349793          	slli	a5,s1,0x3
ffffffffc02009ae:	97d6                	add	a5,a5,s5
ffffffffc02009b0:	8732                	mv	a4,a2
ffffffffc02009b2:	00b65363          	ble	a1,a2,ffffffffc02009b8 <buddy_free_pages+0x172>
ffffffffc02009b6:	872e                	mv	a4,a1
ffffffffc02009b8:	c3d8                	sw	a4,4(a5)
        while (buddy_index) // 向上合并
ffffffffc02009ba:	fcd5                	bnez	s1,ffffffffc0200976 <buddy_free_pages+0x130>
}
ffffffffc02009bc:	60e6                	ld	ra,88(sp)
ffffffffc02009be:	6446                	ld	s0,80(sp)
ffffffffc02009c0:	64a6                	ld	s1,72(sp)
ffffffffc02009c2:	6906                	ld	s2,64(sp)
ffffffffc02009c4:	79e2                	ld	s3,56(sp)
ffffffffc02009c6:	7a42                	ld	s4,48(sp)
ffffffffc02009c8:	7aa2                	ld	s5,40(sp)
ffffffffc02009ca:	7b02                	ld	s6,32(sp)
ffffffffc02009cc:	6be2                	ld	s7,24(sp)
ffffffffc02009ce:	6c42                	ld	s8,16(sp)
ffffffffc02009d0:	6ca2                	ld	s9,8(sp)
ffffffffc02009d2:	6125                	addi	sp,sp,96
ffffffffc02009d4:	8082                	ret
                int left_page_num = (LEFT_LEAF(buddy_index) + 1) * node_size/2 - root->size; //左边的页号
ffffffffc02009d6:	032787bb          	mulw	a5,a5,s2
                int right_page_num = (RIGHT_LEAF(buddy_index) + 1) * node_size/2 - root->size; //右边的页号
ffffffffc02009da:	270d                	addiw	a4,a4,3
                int left_page_num = (LEFT_LEAF(buddy_index) + 1) * node_size/2 - root->size; //左边的页号
ffffffffc02009dc:	000aa583          	lw	a1,0(s5)
                struct Page* left_page = page_base + left_page_num;  //左边的页
ffffffffc02009e0:	000c3a03          	ld	s4,0(s8)
                root[buddy_index].len = node_size;
ffffffffc02009e4:	00349613          	slli	a2,s1,0x3
ffffffffc02009e8:	9656                	add	a2,a2,s5
ffffffffc02009ea:	01262223          	sw	s2,4(a2)
                int right_page_num = (RIGHT_LEAF(buddy_index) + 1) * node_size/2 - root->size; //右边的页号
ffffffffc02009ee:	0327073b          	mulw	a4,a4,s2
                struct Page* left_page = page_base + left_page_num;  //左边的页
ffffffffc02009f2:	9f8d                	subw	a5,a5,a1
ffffffffc02009f4:	00279993          	slli	s3,a5,0x2
ffffffffc02009f8:	99be                	add	s3,s3,a5
ffffffffc02009fa:	098e                	slli	s3,s3,0x3
ffffffffc02009fc:	99d2                	add	s3,s3,s4
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc02009fe:	0189b683          	ld	a3,24(s3)
ffffffffc0200a02:	01898b13          	addi	s6,s3,24
                int right_page_num = (RIGHT_LEAF(buddy_index) + 1) * node_size/2 - root->size; //右边的页号
ffffffffc0200a06:	4017571b          	sraiw	a4,a4,0x1
                struct Page* right_page = page_base + right_page_num; //右边的页
ffffffffc0200a0a:	9f0d                	subw	a4,a4,a1
ffffffffc0200a0c:	00271793          	slli	a5,a4,0x2
ffffffffc0200a10:	973e                	add	a4,a4,a5
ffffffffc0200a12:	070e                	slli	a4,a4,0x3
ffffffffc0200a14:	9a3a                	add	s4,s4,a4
ffffffffc0200a16:	018a0c93          	addi	s9,s4,24
    if (list_prev(&p->page_link) == NULL) //不在表中
ffffffffc0200a1a:	c681                	beqz	a3,ffffffffc0200a22 <buddy_free_pages+0x1dc>
                if (!in_freelist(left_page))
ffffffffc0200a1c:	669c                	ld	a5,8(a3)
ffffffffc0200a1e:	01678f63          	beq	a5,s6,ffffffffc0200a3c <buddy_free_pages+0x1f6>
                    cprintf("in free\n");
ffffffffc0200a22:	8522                	mv	a0,s0
ffffffffc0200a24:	e92ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200a28:	018a3783          	ld	a5,24(s4)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200a2c:	016a3c23          	sd	s6,24(s4)
ffffffffc0200a30:	0167b423          	sd	s6,8(a5)
    elm->next = next;
ffffffffc0200a34:	0399b023          	sd	s9,32(s3)
    elm->prev = prev;
ffffffffc0200a38:	00f9bc23          	sd	a5,24(s3)
    return listelm->prev;
ffffffffc0200a3c:	018a3703          	ld	a4,24(s4)
    if (list_prev(&p->page_link) == NULL) //不在表中
ffffffffc0200a40:	cb0d                	beqz	a4,ffffffffc0200a72 <buddy_free_pages+0x22c>
                if (!in_freelist(right_page))
ffffffffc0200a42:	671c                	ld	a5,8(a4)
ffffffffc0200a44:	03979763          	bne	a5,s9,ffffffffc0200a72 <buddy_free_pages+0x22c>
ffffffffc0200a48:	020a3783          	ld	a5,32(s4)
ffffffffc0200a4c:	8b3a                	mv	s6,a4
                left_page->property += right_page->property;
ffffffffc0200a4e:	0109a703          	lw	a4,16(s3)
ffffffffc0200a52:	010a2683          	lw	a3,16(s4)
ffffffffc0200a56:	9f35                	addw	a4,a4,a3
ffffffffc0200a58:	00e9a823          	sw	a4,16(s3)
                right_page->property = 0;
ffffffffc0200a5c:	000a2823          	sw	zero,16(s4)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200a60:	00fb3423          	sd	a5,8(s6)
    next->prev = prev;
ffffffffc0200a64:	0167b023          	sd	s6,0(a5)
ffffffffc0200a68:	008a0793          	addi	a5,s4,8
ffffffffc0200a6c:	6177b02f          	amoand.d	zero,s7,(a5)
ffffffffc0200a70:	b711                	j	ffffffffc0200974 <buddy_free_pages+0x12e>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a72:	0209b783          	ld	a5,32(s3)
    prev->next = next->prev = elm;
ffffffffc0200a76:	0197b023          	sd	s9,0(a5)
ffffffffc0200a7a:	0399b023          	sd	s9,32(s3)
    elm->next = next;
ffffffffc0200a7e:	02fa3023          	sd	a5,32(s4)
    elm->prev = prev;
ffffffffc0200a82:	016a3c23          	sd	s6,24(s4)
ffffffffc0200a86:	b7e1                	j	ffffffffc0200a4e <buddy_free_pages+0x208>
        list_add(&free_list, &(base->page_link));
ffffffffc0200a88:	018b8793          	addi	a5,s7,24
    prev->next = next->prev = elm;
ffffffffc0200a8c:	e29c                	sd	a5,0(a3)
ffffffffc0200a8e:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc0200a90:	02dbb023          	sd	a3,32(s7)
    elm->prev = prev;
ffffffffc0200a94:	00dbbc23          	sd	a3,24(s7)
ffffffffc0200a98:	b715                	j	ffffffffc02009bc <buddy_free_pages+0x176>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200a9a:	00002697          	auipc	a3,0x2
ffffffffc0200a9e:	80e68693          	addi	a3,a3,-2034 # ffffffffc02022a8 <commands+0x8e0>
ffffffffc0200aa2:	00001617          	auipc	a2,0x1
ffffffffc0200aa6:	70660613          	addi	a2,a2,1798 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200aaa:	0f000593          	li	a1,240
ffffffffc0200aae:	00001517          	auipc	a0,0x1
ffffffffc0200ab2:	71250513          	addi	a0,a0,1810 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200ab6:	8f7ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_num % n == 0); //必须在分位点上
ffffffffc0200aba:	00001697          	auipc	a3,0x1
ffffffffc0200abe:	79668693          	addi	a3,a3,1942 # ffffffffc0202250 <commands+0x888>
ffffffffc0200ac2:	00001617          	auipc	a2,0x1
ffffffffc0200ac6:	6e660613          	addi	a2,a2,1766 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200aca:	0ea00593          	li	a1,234
ffffffffc0200ace:	00001517          	auipc	a0,0x1
ffffffffc0200ad2:	6f250513          	addi	a0,a0,1778 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200ad6:	8d7ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(base >= page_base && base < page_base + root->size);
ffffffffc0200ada:	00001697          	auipc	a3,0x1
ffffffffc0200ade:	71668693          	addi	a3,a3,1814 # ffffffffc02021f0 <commands+0x828>
ffffffffc0200ae2:	00001617          	auipc	a2,0x1
ffffffffc0200ae6:	6c660613          	addi	a2,a2,1734 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200aea:	0e500593          	li	a1,229
ffffffffc0200aee:	00001517          	auipc	a0,0x1
ffffffffc0200af2:	6d250513          	addi	a0,a0,1746 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200af6:	8b7ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(IS_POWER_OF_2(n));
ffffffffc0200afa:	00001697          	auipc	a3,0x1
ffffffffc0200afe:	6de68693          	addi	a3,a3,1758 # ffffffffc02021d8 <commands+0x810>
ffffffffc0200b02:	00001617          	auipc	a2,0x1
ffffffffc0200b06:	6a660613          	addi	a2,a2,1702 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200b0a:	0e400593          	li	a1,228
ffffffffc0200b0e:	00001517          	auipc	a0,0x1
ffffffffc0200b12:	6b250513          	addi	a0,a0,1714 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200b16:	897ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n>0);
ffffffffc0200b1a:	00001697          	auipc	a3,0x1
ffffffffc0200b1e:	68668693          	addi	a3,a3,1670 # ffffffffc02021a0 <commands+0x7d8>
ffffffffc0200b22:	00001617          	auipc	a2,0x1
ffffffffc0200b26:	68660613          	addi	a2,a2,1670 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200b2a:	0e300593          	li	a1,227
ffffffffc0200b2e:	00001517          	auipc	a0,0x1
ffffffffc0200b32:	69250513          	addi	a0,a0,1682 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200b36:	877ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b3a <buddy_check>:

static void
buddy_check(void) {
ffffffffc0200b3a:	1101                	addi	sp,sp,-32
    // 开始检查
    cprintf("*******************************Check begin***************************\n");
ffffffffc0200b3c:	00001517          	auipc	a0,0x1
ffffffffc0200b40:	51450513          	addi	a0,a0,1300 # ffffffffc0202050 <commands+0x688>
buddy_check(void) {
ffffffffc0200b44:	ec06                	sd	ra,24(sp)
ffffffffc0200b46:	e822                	sd	s0,16(sp)
ffffffffc0200b48:	e426                	sd	s1,8(sp)
    cprintf("*******************************Check begin***************************\n");
ffffffffc0200b4a:	d6cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    struct Page  *A, *B;
    A = B  = NULL;

    assert((A = alloc_page()) != NULL);
ffffffffc0200b4e:	4505                	li	a0,1
ffffffffc0200b50:	592000ef          	jal	ra,ffffffffc02010e2 <alloc_pages>
ffffffffc0200b54:	10050063          	beqz	a0,ffffffffc0200c54 <buddy_check+0x11a>
    cprintf("in check: page_num: %d, property: %d \n",A - page_base, PageProperty(A));
ffffffffc0200b58:	00054797          	auipc	a5,0x54
ffffffffc0200b5c:	b0078793          	addi	a5,a5,-1280 # ffffffffc0254658 <page_base>
ffffffffc0200b60:	639c                	ld	a5,0(a5)
ffffffffc0200b62:	00001717          	auipc	a4,0x1
ffffffffc0200b66:	63670713          	addi	a4,a4,1590 # ffffffffc0202198 <commands+0x7d0>
ffffffffc0200b6a:	630c                	ld	a1,0(a4)
ffffffffc0200b6c:	40f507b3          	sub	a5,a0,a5
ffffffffc0200b70:	878d                	srai	a5,a5,0x3
ffffffffc0200b72:	02b785b3          	mul	a1,a5,a1
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b76:	6510                	ld	a2,8(a0)
ffffffffc0200b78:	842a                	mv	s0,a0
ffffffffc0200b7a:	00001517          	auipc	a0,0x1
ffffffffc0200b7e:	53e50513          	addi	a0,a0,1342 # ffffffffc02020b8 <commands+0x6f0>
ffffffffc0200b82:	8205                	srli	a2,a2,0x1
ffffffffc0200b84:	8a05                	andi	a2,a2,1
ffffffffc0200b86:	d30ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((B = alloc_page()) != NULL);
ffffffffc0200b8a:	4505                	li	a0,1
ffffffffc0200b8c:	556000ef          	jal	ra,ffffffffc02010e2 <alloc_pages>
ffffffffc0200b90:	84aa                	mv	s1,a0
ffffffffc0200b92:	c14d                	beqz	a0,ffffffffc0200c34 <buddy_check+0xfa>

    assert( A != B);
ffffffffc0200b94:	08a40063          	beq	s0,a0,ffffffffc0200c14 <buddy_check+0xda>
    assert(page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200b98:	401c                	lw	a5,0(s0)
ffffffffc0200b9a:	efa9                	bnez	a5,ffffffffc0200bf4 <buddy_check+0xba>
ffffffffc0200b9c:	411c                	lw	a5,0(a0)
ffffffffc0200b9e:	ebb9                	bnez	a5,ffffffffc0200bf4 <buddy_check+0xba>
    //free page就是free pages(A,1)
    free_page(A);
ffffffffc0200ba0:	8522                	mv	a0,s0
ffffffffc0200ba2:	4585                	li	a1,1
ffffffffc0200ba4:	582000ef          	jal	ra,ffffffffc0201126 <free_pages>
    free_page(B);
ffffffffc0200ba8:	4585                	li	a1,1
ffffffffc0200baa:	8526                	mv	a0,s1
ffffffffc0200bac:	57a000ef          	jal	ra,ffffffffc0201126 <free_pages>


    //A=alloc_pages(500);     //alloc_pages返回的是开始分配的那一页的地址
    A=alloc_pages(70); //
ffffffffc0200bb0:	04600513          	li	a0,70
ffffffffc0200bb4:	52e000ef          	jal	ra,ffffffffc02010e2 <alloc_pages>
ffffffffc0200bb8:	84aa                	mv	s1,a0
    //B=alloc_pages(500);
    B=alloc_pages(35);
ffffffffc0200bba:	02300513          	li	a0,35
ffffffffc0200bbe:	524000ef          	jal	ra,ffffffffc02010e2 <alloc_pages>
ffffffffc0200bc2:	842a                	mv	s0,a0
    cprintf("in check: A %p\n",A);
ffffffffc0200bc4:	85a6                	mv	a1,s1
ffffffffc0200bc6:	00001517          	auipc	a0,0x1
ffffffffc0200bca:	56a50513          	addi	a0,a0,1386 # ffffffffc0202130 <commands+0x768>
ffffffffc0200bce:	ce8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("in check: B %p\n",B);
ffffffffc0200bd2:	85a2                	mv	a1,s0
ffffffffc0200bd4:	00001517          	auipc	a0,0x1
ffffffffc0200bd8:	56c50513          	addi	a0,a0,1388 # ffffffffc0202140 <commands+0x778>
ffffffffc0200bdc:	cdaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("********************************Check End****************************\n");
}
ffffffffc0200be0:	6442                	ld	s0,16(sp)
ffffffffc0200be2:	60e2                	ld	ra,24(sp)
ffffffffc0200be4:	64a2                	ld	s1,8(sp)
    cprintf("********************************Check End****************************\n");
ffffffffc0200be6:	00001517          	auipc	a0,0x1
ffffffffc0200bea:	56a50513          	addi	a0,a0,1386 # ffffffffc0202150 <commands+0x788>
}
ffffffffc0200bee:	6105                	addi	sp,sp,32
    cprintf("********************************Check End****************************\n");
ffffffffc0200bf0:	cc6ff06f          	j	ffffffffc02000b6 <cprintf>
    assert(page_ref(A) == 0 && page_ref(B) == 0);
ffffffffc0200bf4:	00001697          	auipc	a3,0x1
ffffffffc0200bf8:	51468693          	addi	a3,a3,1300 # ffffffffc0202108 <commands+0x740>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	5ac60613          	addi	a2,a2,1452 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200c04:	13600593          	li	a1,310
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	5b850513          	addi	a0,a0,1464 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200c10:	f9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert( A != B);
ffffffffc0200c14:	00001697          	auipc	a3,0x1
ffffffffc0200c18:	4ec68693          	addi	a3,a3,1260 # ffffffffc0202100 <commands+0x738>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	58c60613          	addi	a2,a2,1420 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200c24:	13500593          	li	a1,309
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	59850513          	addi	a0,a0,1432 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200c30:	f7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((B = alloc_page()) != NULL);
ffffffffc0200c34:	00001697          	auipc	a3,0x1
ffffffffc0200c38:	4ac68693          	addi	a3,a3,1196 # ffffffffc02020e0 <commands+0x718>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	56c60613          	addi	a2,a2,1388 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200c44:	13300593          	li	a1,307
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	57850513          	addi	a0,a0,1400 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((A = alloc_page()) != NULL);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	44468693          	addi	a3,a3,1092 # ffffffffc0202098 <commands+0x6d0>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	54c60613          	addi	a2,a2,1356 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200c64:	13100593          	li	a1,305
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	55850513          	addi	a0,a0,1368 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200c70:	f3cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200c74 <buddy2_new.part.2>:
    root[0].size = size;
ffffffffc0200c74:	00005717          	auipc	a4,0x5
ffffffffc0200c78:	7ea72223          	sw	a0,2020(a4) # ffffffffc0206458 <root>
    node_size = size * 2;
ffffffffc0200c7c:	0015161b          	slliw	a2,a0,0x1
    for (i = 0; i < 2 * size - 1; ++i) 
ffffffffc0200c80:	4705                	li	a4,1
ffffffffc0200c82:	02c75563          	ble	a2,a4,ffffffffc0200cac <buddy2_new.part.2+0x38>
ffffffffc0200c86:	00005717          	auipc	a4,0x5
ffffffffc0200c8a:	7d670713          	addi	a4,a4,2006 # ffffffffc020645c <root+0x4>
ffffffffc0200c8e:	fff6051b          	addiw	a0,a2,-1
ffffffffc0200c92:	4781                	li	a5,0
        if (IS_POWER_OF_2(i+1))
ffffffffc0200c94:	0017869b          	addiw	a3,a5,1
ffffffffc0200c98:	00f6f5b3          	and	a1,a3,a5
ffffffffc0200c9c:	87b6                	mv	a5,a3
ffffffffc0200c9e:	e199                	bnez	a1,ffffffffc0200ca4 <buddy2_new.part.2+0x30>
            node_size /= 2;
ffffffffc0200ca0:	0016561b          	srliw	a2,a2,0x1
        root[i].len = node_size;
ffffffffc0200ca4:	c310                	sw	a2,0(a4)
ffffffffc0200ca6:	0721                	addi	a4,a4,8
    for (i = 0; i < 2 * size - 1; ++i) 
ffffffffc0200ca8:	fea796e3          	bne	a5,a0,ffffffffc0200c94 <buddy2_new.part.2+0x20>
}
ffffffffc0200cac:	8082                	ret

ffffffffc0200cae <buddy_init_memmap>:
{
ffffffffc0200cae:	1141                	addi	sp,sp,-16
ffffffffc0200cb0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cb2:	c1fd                	beqz	a1,ffffffffc0200d98 <buddy_init_memmap+0xea>
    n = UINT32_ROUND_DOWN(n);
ffffffffc0200cb4:	0015d793          	srli	a5,a1,0x1
ffffffffc0200cb8:	8fcd                	or	a5,a5,a1
ffffffffc0200cba:	0027d713          	srli	a4,a5,0x2
ffffffffc0200cbe:	8fd9                	or	a5,a5,a4
ffffffffc0200cc0:	0047d713          	srli	a4,a5,0x4
ffffffffc0200cc4:	8f5d                	or	a4,a4,a5
ffffffffc0200cc6:	00875793          	srli	a5,a4,0x8
ffffffffc0200cca:	8f5d                	or	a4,a4,a5
ffffffffc0200ccc:	01075793          	srli	a5,a4,0x10
ffffffffc0200cd0:	8fd9                	or	a5,a5,a4
ffffffffc0200cd2:	8385                	srli	a5,a5,0x1
ffffffffc0200cd4:	00b7f733          	and	a4,a5,a1
ffffffffc0200cd8:	ef41                	bnez	a4,ffffffffc0200d70 <buddy_init_memmap+0xc2>
    for (; p != base + n; p ++) 
ffffffffc0200cda:	00259693          	slli	a3,a1,0x2
ffffffffc0200cde:	96ae                	add	a3,a3,a1
ffffffffc0200ce0:	068e                	slli	a3,a3,0x3
    struct Page *p = page_base = base;
ffffffffc0200ce2:	00054797          	auipc	a5,0x54
ffffffffc0200ce6:	96a7bb23          	sd	a0,-1674(a5) # ffffffffc0254658 <page_base>
    for (; p != base + n; p ++) 
ffffffffc0200cea:	96aa                	add	a3,a3,a0
ffffffffc0200cec:	02d50463          	beq	a0,a3,ffffffffc0200d14 <buddy_init_memmap+0x66>
ffffffffc0200cf0:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200cf2:	8b85                	andi	a5,a5,1
ffffffffc0200cf4:	c3d1                	beqz	a5,ffffffffc0200d78 <buddy_init_memmap+0xca>
ffffffffc0200cf6:	87aa                	mv	a5,a0
ffffffffc0200cf8:	a021                	j	ffffffffc0200d00 <buddy_init_memmap+0x52>
ffffffffc0200cfa:	6798                	ld	a4,8(a5)
ffffffffc0200cfc:	8b05                	andi	a4,a4,1
ffffffffc0200cfe:	cf2d                	beqz	a4,ffffffffc0200d78 <buddy_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc0200d00:	0007a823          	sw	zero,16(a5)
ffffffffc0200d04:	0007b423          	sd	zero,8(a5)
ffffffffc0200d08:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) 
ffffffffc0200d0c:	02878793          	addi	a5,a5,40
ffffffffc0200d10:	fed795e3          	bne	a5,a3,ffffffffc0200cfa <buddy_init_memmap+0x4c>
    base->property = n;
ffffffffc0200d14:	2581                	sext.w	a1,a1
ffffffffc0200d16:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d18:	4789                	li	a5,2
ffffffffc0200d1a:	00850713          	addi	a4,a0,8
ffffffffc0200d1e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0200d22:	00005797          	auipc	a5,0x5
ffffffffc0200d26:	71678793          	addi	a5,a5,1814 # ffffffffc0206438 <free_area>
ffffffffc0200d2a:	4b98                	lw	a4,16(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200d2c:	6794                	ld	a3,8(a5)
    list_add(&free_list, &(base->page_link));
ffffffffc0200d2e:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc0200d32:	9f2d                	addw	a4,a4,a1
ffffffffc0200d34:	00005817          	auipc	a6,0x5
ffffffffc0200d38:	70e82a23          	sw	a4,1812(a6) # ffffffffc0206448 <free_area+0x10>
    prev->next = next->prev = elm;
ffffffffc0200d3c:	e290                	sd	a2,0(a3)
    elm->prev = prev;
ffffffffc0200d3e:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0200d40:	00005717          	auipc	a4,0x5
ffffffffc0200d44:	70c73023          	sd	a2,1792(a4) # ffffffffc0206440 <free_area+0x8>
    elm->next = next;
ffffffffc0200d48:	f114                	sd	a3,32(a0)
    nr_block=0;
ffffffffc0200d4a:	00005797          	auipc	a5,0x5
ffffffffc0200d4e:	7007a323          	sw	zero,1798(a5) # ffffffffc0206450 <nr_block>
    if (size < 1 || !IS_POWER_OF_2(size)) //规格不对
ffffffffc0200d52:	00b05c63          	blez	a1,ffffffffc0200d6a <buddy_init_memmap+0xbc>
ffffffffc0200d56:	fff5879b          	addiw	a5,a1,-1
ffffffffc0200d5a:	8fed                	and	a5,a5,a1
ffffffffc0200d5c:	2781                	sext.w	a5,a5
ffffffffc0200d5e:	e791                	bnez	a5,ffffffffc0200d6a <buddy_init_memmap+0xbc>
}
ffffffffc0200d60:	60a2                	ld	ra,8(sp)
ffffffffc0200d62:	852e                	mv	a0,a1
ffffffffc0200d64:	0141                	addi	sp,sp,16
ffffffffc0200d66:	f0fff06f          	j	ffffffffc0200c74 <buddy2_new.part.2>
ffffffffc0200d6a:	60a2                	ld	ra,8(sp)
ffffffffc0200d6c:	0141                	addi	sp,sp,16
ffffffffc0200d6e:	8082                	ret
    n = UINT32_ROUND_DOWN(n);
ffffffffc0200d70:	fff7c793          	not	a5,a5
ffffffffc0200d74:	8dfd                	and	a1,a1,a5
ffffffffc0200d76:	b795                	j	ffffffffc0200cda <buddy_init_memmap+0x2c>
        assert(PageReserved(p));
ffffffffc0200d78:	00001697          	auipc	a3,0x1
ffffffffc0200d7c:	57068693          	addi	a3,a3,1392 # ffffffffc02022e8 <commands+0x920>
ffffffffc0200d80:	00001617          	auipc	a2,0x1
ffffffffc0200d84:	42860613          	addi	a2,a2,1064 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200d88:	05200593          	li	a1,82
ffffffffc0200d8c:	00001517          	auipc	a0,0x1
ffffffffc0200d90:	43450513          	addi	a0,a0,1076 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200d94:	e18ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200d98:	00001697          	auipc	a3,0x1
ffffffffc0200d9c:	54868693          	addi	a3,a3,1352 # ffffffffc02022e0 <commands+0x918>
ffffffffc0200da0:	00001617          	auipc	a2,0x1
ffffffffc0200da4:	40860613          	addi	a2,a2,1032 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc0200da8:	04c00593          	li	a1,76
ffffffffc0200dac:	00001517          	auipc	a0,0x1
ffffffffc0200db0:	41450513          	addi	a0,a0,1044 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc0200db4:	df8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200db8 <buddy2_alloc.part.3>:
    if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
ffffffffc0200db8:	fff5879b          	addiw	a5,a1,-1
ffffffffc0200dbc:	8fed                	and	a5,a5,a1
ffffffffc0200dbe:	2781                	sext.w	a5,a5
ffffffffc0200dc0:	2581                	sext.w	a1,a1
ffffffffc0200dc2:	c78d                	beqz	a5,ffffffffc0200dec <buddy2_alloc.part.3+0x34>
    size |= size >> 1;
ffffffffc0200dc4:	0015d79b          	srliw	a5,a1,0x1
ffffffffc0200dc8:	8ddd                	or	a1,a1,a5
ffffffffc0200dca:	2581                	sext.w	a1,a1
    size |= size >> 2;
ffffffffc0200dcc:	0025d79b          	srliw	a5,a1,0x2
ffffffffc0200dd0:	8ddd                	or	a1,a1,a5
ffffffffc0200dd2:	2581                	sext.w	a1,a1
    size |= size >> 4;
ffffffffc0200dd4:	0045d79b          	srliw	a5,a1,0x4
ffffffffc0200dd8:	8ddd                	or	a1,a1,a5
ffffffffc0200dda:	2581                	sext.w	a1,a1
    size |= size >> 8;
ffffffffc0200ddc:	0085d79b          	srliw	a5,a1,0x8
ffffffffc0200de0:	8ddd                	or	a1,a1,a5
ffffffffc0200de2:	2581                	sext.w	a1,a1
    size |= size >> 16;
ffffffffc0200de4:	0105d79b          	srliw	a5,a1,0x10
ffffffffc0200de8:	8ddd                	or	a1,a1,a5
    return size+1;
ffffffffc0200dea:	2585                	addiw	a1,a1,1
    if (root[index].len < size)//可分配内存不足
ffffffffc0200dec:	415c                	lw	a5,4(a0)
ffffffffc0200dee:	16b7e163          	bltu	a5,a1,ffffffffc0200f50 <buddy2_alloc.part.3+0x198>
    for(node_size = root->size; node_size != size; node_size /= 2 ) 
ffffffffc0200df2:	00052f83          	lw	t6,0(a0)
ffffffffc0200df6:	837e                	mv	t1,t6
ffffffffc0200df8:	14bf8463          	beq	t6,a1,ffffffffc0200f40 <buddy2_alloc.part.3+0x188>
ffffffffc0200dfc:	8efe                	mv	t4,t6
    unsigned index = 0;//节点的标号
ffffffffc0200dfe:	4781                	li	a5,0
ffffffffc0200e00:	00054f17          	auipc	t5,0x54
ffffffffc0200e04:	858f0f13          	addi	t5,t5,-1960 # ffffffffc0254658 <page_base>
ffffffffc0200e08:	4289                	li	t0,2
ffffffffc0200e0a:	a819                	j	ffffffffc0200e20 <buddy2_alloc.part.3+0x68>
        if (root[LEFT_LEAF(index)].len >= size && root[RIGHT_LEAF(index)].len>=size)
ffffffffc0200e0c:	06b86563          	bltu	a6,a1,ffffffffc0200e76 <buddy2_alloc.part.3+0xbe>
            if(root[LEFT_LEAF(index)].len <= root[RIGHT_LEAF(index)].len)
ffffffffc0200e10:	00687563          	bleu	t1,a6,ffffffffc0200e1a <buddy2_alloc.part.3+0x62>
                index = RIGHT_LEAF(index);
ffffffffc0200e14:	87ba                	mv	a5,a4
            if(root[LEFT_LEAF(index)].len < root[RIGHT_LEAF(index)].len)
ffffffffc0200e16:	0038871b          	addiw	a4,a7,3
ffffffffc0200e1a:	8372                	mv	t1,t3
    for(node_size = root->size; node_size != size; node_size /= 2 ) 
ffffffffc0200e1c:	06be0263          	beq	t3,a1,ffffffffc0200e80 <buddy2_alloc.part.3+0xc8>
        int page_num = (index + 1) * node_size - root->size;
ffffffffc0200e20:	0017871b          	addiw	a4,a5,1
ffffffffc0200e24:	0267073b          	mulw	a4,a4,t1
        struct Page *left_page = page_base + page_num;
ffffffffc0200e28:	000f3883          	ld	a7,0(t5)
        struct Page *right_page = left_page + node_size/2;
ffffffffc0200e2c:	0013539b          	srliw	t2,t1,0x1
ffffffffc0200e30:	00038e1b          	sext.w	t3,t2
        struct Page *left_page = page_base + page_num;
ffffffffc0200e34:	41d7073b          	subw	a4,a4,t4
ffffffffc0200e38:	00271813          	slli	a6,a4,0x2
ffffffffc0200e3c:	9742                	add	a4,a4,a6
ffffffffc0200e3e:	070e                	slli	a4,a4,0x3
ffffffffc0200e40:	9746                	add	a4,a4,a7
        if(left_page->property == node_size && PageProperty(left_page)) //当且仅当整个大页都是空闲页的时候，才分裂
ffffffffc0200e42:	01072803          	lw	a6,16(a4)
ffffffffc0200e46:	0a680663          	beq	a6,t1,ffffffffc0200ef2 <buddy2_alloc.part.3+0x13a>
        if (root[LEFT_LEAF(index)].len >= size && root[RIGHT_LEAF(index)].len>=size)
ffffffffc0200e4a:	0017989b          	slliw	a7,a5,0x1
ffffffffc0200e4e:	0018879b          	addiw	a5,a7,1
ffffffffc0200e52:	02079813          	slli	a6,a5,0x20
ffffffffc0200e56:	01d85813          	srli	a6,a6,0x1d
ffffffffc0200e5a:	982a                	add	a6,a6,a0
ffffffffc0200e5c:	0028871b          	addiw	a4,a7,2
ffffffffc0200e60:	00482303          	lw	t1,4(a6)
ffffffffc0200e64:	02071813          	slli	a6,a4,0x20
ffffffffc0200e68:	01d85813          	srli	a6,a6,0x1d
ffffffffc0200e6c:	982a                	add	a6,a6,a0
ffffffffc0200e6e:	00482803          	lw	a6,4(a6)
ffffffffc0200e72:	f8b37de3          	bleu	a1,t1,ffffffffc0200e0c <buddy2_alloc.part.3+0x54>
            if(root[LEFT_LEAF(index)].len < root[RIGHT_LEAF(index)].len)
ffffffffc0200e76:	f9036fe3          	bltu	t1,a6,ffffffffc0200e14 <buddy2_alloc.part.3+0x5c>
ffffffffc0200e7a:	8372                	mv	t1,t3
    for(node_size = root->size; node_size != size; node_size /= 2 ) 
ffffffffc0200e7c:	fabe12e3          	bne	t3,a1,ffffffffc0200e20 <buddy2_alloc.part.3+0x68>
    *page_num = (index + 1) * node_size - root->size;
ffffffffc0200e80:	02ee083b          	mulw	a6,t3,a4
    *parent_page_num = (PARENT(index) + 1) * node_size*2 - root->size;
ffffffffc0200e84:	0017571b          	srliw	a4,a4,0x1
    root[index].len = 0;//标记节点为已使用
ffffffffc0200e88:	02079593          	slli	a1,a5,0x20
ffffffffc0200e8c:	81f5                	srli	a1,a1,0x1d
ffffffffc0200e8e:	95aa                	add	a1,a1,a0
ffffffffc0200e90:	0005a223          	sw	zero,4(a1)
    *parent_page_num = (PARENT(index) + 1) * node_size*2 - root->size;
ffffffffc0200e94:	03c7073b          	mulw	a4,a4,t3
    *page_num = (index + 1) * node_size - root->size;
ffffffffc0200e98:	41d80ebb          	subw	t4,a6,t4
ffffffffc0200e9c:	01d62023          	sw	t4,0(a2)
    *parent_page_num = (PARENT(index) + 1) * node_size*2 - root->size;
ffffffffc0200ea0:	4110                	lw	a2,0(a0)
ffffffffc0200ea2:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200ea6:	9f11                	subw	a4,a4,a2
ffffffffc0200ea8:	c298                	sw	a4,0(a3)
    while (index) 
ffffffffc0200eaa:	c3dd                	beqz	a5,ffffffffc0200f50 <buddy2_alloc.part.3+0x198>
        index = PARENT(index);
ffffffffc0200eac:	2785                	addiw	a5,a5,1
ffffffffc0200eae:	0017d61b          	srliw	a2,a5,0x1
ffffffffc0200eb2:	367d                	addiw	a2,a2,-1
        root[index].len = MAX(root[LEFT_LEAF(index)].len, root[RIGHT_LEAF(index)].len);
ffffffffc0200eb4:	0016169b          	slliw	a3,a2,0x1
ffffffffc0200eb8:	ffe7f713          	andi	a4,a5,-2
ffffffffc0200ebc:	2685                	addiw	a3,a3,1
ffffffffc0200ebe:	1682                	slli	a3,a3,0x20
ffffffffc0200ec0:	1702                	slli	a4,a4,0x20
ffffffffc0200ec2:	9281                	srli	a3,a3,0x20
ffffffffc0200ec4:	9301                	srli	a4,a4,0x20
ffffffffc0200ec6:	068e                	slli	a3,a3,0x3
ffffffffc0200ec8:	070e                	slli	a4,a4,0x3
ffffffffc0200eca:	972a                	add	a4,a4,a0
ffffffffc0200ecc:	96aa                	add	a3,a3,a0
ffffffffc0200ece:	434c                	lw	a1,4(a4)
ffffffffc0200ed0:	42d4                	lw	a3,4(a3)
ffffffffc0200ed2:	02061713          	slli	a4,a2,0x20
ffffffffc0200ed6:	8375                	srli	a4,a4,0x1d
ffffffffc0200ed8:	0006889b          	sext.w	a7,a3
ffffffffc0200edc:	0005881b          	sext.w	a6,a1
        index = PARENT(index);
ffffffffc0200ee0:	0006079b          	sext.w	a5,a2
        root[index].len = MAX(root[LEFT_LEAF(index)].len, root[RIGHT_LEAF(index)].len);
ffffffffc0200ee4:	972a                	add	a4,a4,a0
ffffffffc0200ee6:	0108f363          	bleu	a6,a7,ffffffffc0200eec <buddy2_alloc.part.3+0x134>
ffffffffc0200eea:	86ae                	mv	a3,a1
ffffffffc0200eec:	c354                	sw	a3,4(a4)
    while (index) 
ffffffffc0200eee:	ffdd                	bnez	a5,ffffffffc0200eac <buddy2_alloc.part.3+0xf4>
ffffffffc0200ef0:	8082                	ret
        struct Page *right_page = left_page + node_size/2;
ffffffffc0200ef2:	02039893          	slli	a7,t2,0x20
ffffffffc0200ef6:	0208d893          	srli	a7,a7,0x20
ffffffffc0200efa:	00289813          	slli	a6,a7,0x2
ffffffffc0200efe:	9846                	add	a6,a6,a7
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f00:	00873883          	ld	a7,8(a4)
ffffffffc0200f04:	080e                	slli	a6,a6,0x3
ffffffffc0200f06:	983a                	add	a6,a6,a4
        if(left_page->property == node_size && PageProperty(left_page)) //当且仅当整个大页都是空闲页的时候，才分裂
ffffffffc0200f08:	0028f893          	andi	a7,a7,2
ffffffffc0200f0c:	f2088fe3          	beqz	a7,ffffffffc0200e4a <buddy2_alloc.part.3+0x92>
            left_page->property /= 2;
ffffffffc0200f10:	00772823          	sw	t2,16(a4)
            right_page->property = left_page->property;
ffffffffc0200f14:	00782823          	sw	t2,16(a6)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f18:	00880893          	addi	a7,a6,8
ffffffffc0200f1c:	4058b02f          	amoor.d	zero,t0,(a7)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200f20:	02073883          	ld	a7,32(a4)
            list_add(&(left_page->page_link), &(right_page->page_link));
ffffffffc0200f24:	01880313          	addi	t1,a6,24
ffffffffc0200f28:	01870e93          	addi	t4,a4,24
    prev->next = next->prev = elm;
ffffffffc0200f2c:	0068b023          	sd	t1,0(a7)
ffffffffc0200f30:	02673023          	sd	t1,32(a4)
    elm->prev = prev;
ffffffffc0200f34:	01d83c23          	sd	t4,24(a6)
    elm->next = next;
ffffffffc0200f38:	03183023          	sd	a7,32(a6)
    elm->prev = prev;
ffffffffc0200f3c:	8efe                	mv	t4,t6
ffffffffc0200f3e:	b731                	j	ffffffffc0200e4a <buddy2_alloc.part.3+0x92>
    root[index].len = 0;//标记节点为已使用
ffffffffc0200f40:	00052223          	sw	zero,4(a0)
    *page_num = (index + 1) * node_size - root->size;
ffffffffc0200f44:	00062023          	sw	zero,0(a2)
    *parent_page_num = (PARENT(index) + 1) * node_size*2 - root->size;
ffffffffc0200f48:	411c                	lw	a5,0(a0)
ffffffffc0200f4a:	40f007bb          	negw	a5,a5
ffffffffc0200f4e:	c29c                	sw	a5,0(a3)
}
ffffffffc0200f50:	8082                	ret

ffffffffc0200f52 <buddy_alloc_pages>:
{
ffffffffc0200f52:	715d                	addi	sp,sp,-80
ffffffffc0200f54:	e486                	sd	ra,72(sp)
ffffffffc0200f56:	e0a2                	sd	s0,64(sp)
ffffffffc0200f58:	fc26                	sd	s1,56(sp)
ffffffffc0200f5a:	f84a                	sd	s2,48(sp)
ffffffffc0200f5c:	f44e                	sd	s3,40(sp)
ffffffffc0200f5e:	f052                	sd	s4,32(sp)
ffffffffc0200f60:	ec56                	sd	s5,24(sp)
    assert(n>0);
ffffffffc0200f62:	16050063          	beqz	a0,ffffffffc02010c2 <buddy_alloc_pages+0x170>
    if(n>nr_free)
ffffffffc0200f66:	00005797          	auipc	a5,0x5
ffffffffc0200f6a:	4e27e783          	lwu	a5,1250(a5) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200f6e:	84aa                	mv	s1,a0
ffffffffc0200f70:	14a7e763          	bltu	a5,a0,ffffffffc02010be <buddy_alloc_pages+0x16c>
    if(!IS_POWER_OF_2(n))
ffffffffc0200f74:	fff50793          	addi	a5,a0,-1
ffffffffc0200f78:	0005059b          	sext.w	a1,a0
ffffffffc0200f7c:	8fe9                	and	a5,a5,a0
ffffffffc0200f7e:	89ae                	mv	s3,a1
ffffffffc0200f80:	ebe9                	bnez	a5,ffffffffc0201052 <buddy_alloc_pages+0x100>
    if (size <= 0)//分配不合理
ffffffffc0200f82:	00b05a63          	blez	a1,ffffffffc0200f96 <buddy_alloc_pages+0x44>
ffffffffc0200f86:	0074                	addi	a3,sp,12
ffffffffc0200f88:	0030                	addi	a2,sp,8
ffffffffc0200f8a:	00005517          	auipc	a0,0x5
ffffffffc0200f8e:	4ce50513          	addi	a0,a0,1230 # ffffffffc0206458 <root>
ffffffffc0200f92:	e27ff0ef          	jal	ra,ffffffffc0200db8 <buddy2_alloc.part.3>
    page = page_base + page_num;
ffffffffc0200f96:	45a2                	lw	a1,8(sp)
    parent_page = page_base + parent_page_num;
ffffffffc0200f98:	4a32                	lw	s4,12(sp)
    page = page_base + page_num;
ffffffffc0200f9a:	00053a97          	auipc	s5,0x53
ffffffffc0200f9e:	6bea8a93          	addi	s5,s5,1726 # ffffffffc0254658 <page_base>
ffffffffc0200fa2:	00259413          	slli	s0,a1,0x2
    cprintf("in alloc: page_num:%d, parent_page_num:%d\n",page_num,parent_page_num);
ffffffffc0200fa6:	8652                	mv	a2,s4
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	05050513          	addi	a0,a0,80 # ffffffffc0201ff8 <commands+0x630>
    page = page_base + page_num;
ffffffffc0200fb0:	000ab903          	ld	s2,0(s5)
ffffffffc0200fb4:	942e                	add	s0,s0,a1
    cprintf("in alloc: page_num:%d, parent_page_num:%d\n",page_num,parent_page_num);
ffffffffc0200fb6:	900ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    nr_block++;
ffffffffc0200fba:	00005797          	auipc	a5,0x5
ffffffffc0200fbe:	49678793          	addi	a5,a5,1174 # ffffffffc0206450 <nr_block>
ffffffffc0200fc2:	439c                	lw	a5,0(a5)
    page = page_base + page_num;
ffffffffc0200fc4:	040e                	slli	s0,s0,0x3
ffffffffc0200fc6:	944a                	add	s0,s0,s2
    if (page->property != n) //还有剩余
ffffffffc0200fc8:	01046703          	lwu	a4,16(s0)
    nr_block++;
ffffffffc0200fcc:	2785                	addiw	a5,a5,1
ffffffffc0200fce:	00005697          	auipc	a3,0x5
ffffffffc0200fd2:	48f6a123          	sw	a5,1154(a3) # ffffffffc0206450 <nr_block>
    if (page->property != n) //还有剩余
ffffffffc0200fd6:	0a970a63          	beq	a4,s1,ffffffffc020108a <buddy_alloc_pages+0x138>
    parent_page = page_base + parent_page_num;
ffffffffc0200fda:	002a1613          	slli	a2,s4,0x2
ffffffffc0200fde:	9652                	add	a2,a2,s4
ffffffffc0200fe0:	060e                	slli	a2,a2,0x3
ffffffffc0200fe2:	9932                	add	s2,s2,a2
        if (page == parent_page) //说明page是parent_page的左孩子
ffffffffc0200fe4:	0b240863          	beq	s0,s2,ffffffffc0201094 <buddy_alloc_pages+0x142>
            parent_page -> property /= 2;
ffffffffc0200fe8:	01092783          	lw	a5,16(s2)
ffffffffc0200fec:	0017d79b          	srliw	a5,a5,0x1
ffffffffc0200ff0:	00f92823          	sw	a5,16(s2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ff4:	57f5                	li	a5,-3
ffffffffc0200ff6:	00840713          	addi	a4,s0,8
ffffffffc0200ffa:	60f7302f          	amoand.d	zero,a5,(a4)
    cprintf("in alloc: page_num:%d , property:%d \n",page-page_base, PageProperty(page));
ffffffffc0200ffe:	000ab783          	ld	a5,0(s5)
ffffffffc0201002:	00001717          	auipc	a4,0x1
ffffffffc0201006:	19670713          	addi	a4,a4,406 # ffffffffc0202198 <commands+0x7d0>
ffffffffc020100a:	630c                	ld	a1,0(a4)
ffffffffc020100c:	40f407b3          	sub	a5,s0,a5
ffffffffc0201010:	878d                	srai	a5,a5,0x3
ffffffffc0201012:	02b785b3          	mul	a1,a5,a1
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201016:	6410                	ld	a2,8(s0)
ffffffffc0201018:	00001517          	auipc	a0,0x1
ffffffffc020101c:	01050513          	addi	a0,a0,16 # ffffffffc0202028 <commands+0x660>
ffffffffc0201020:	8205                	srli	a2,a2,0x1
ffffffffc0201022:	8a05                	andi	a2,a2,1
ffffffffc0201024:	892ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    nr_free -= n;//减去已被分配的页数
ffffffffc0201028:	00005797          	auipc	a5,0x5
ffffffffc020102c:	41078793          	addi	a5,a5,1040 # ffffffffc0206438 <free_area>
ffffffffc0201030:	4b9c                	lw	a5,16(a5)
ffffffffc0201032:	413787bb          	subw	a5,a5,s3
ffffffffc0201036:	00005717          	auipc	a4,0x5
ffffffffc020103a:	40f72923          	sw	a5,1042(a4) # ffffffffc0206448 <free_area+0x10>
}
ffffffffc020103e:	8522                	mv	a0,s0
ffffffffc0201040:	60a6                	ld	ra,72(sp)
ffffffffc0201042:	6406                	ld	s0,64(sp)
ffffffffc0201044:	74e2                	ld	s1,56(sp)
ffffffffc0201046:	7942                	ld	s2,48(sp)
ffffffffc0201048:	79a2                	ld	s3,40(sp)
ffffffffc020104a:	7a02                	ld	s4,32(sp)
ffffffffc020104c:	6ae2                	ld	s5,24(sp)
ffffffffc020104e:	6161                	addi	sp,sp,80
ffffffffc0201050:	8082                	ret
    size |= size >> 1;
ffffffffc0201052:	0015d79b          	srliw	a5,a1,0x1
ffffffffc0201056:	8ddd                	or	a1,a1,a5
ffffffffc0201058:	2581                	sext.w	a1,a1
    size |= size >> 2;
ffffffffc020105a:	0025d79b          	srliw	a5,a1,0x2
ffffffffc020105e:	8fcd                	or	a5,a5,a1
ffffffffc0201060:	2781                	sext.w	a5,a5
    size |= size >> 4;
ffffffffc0201062:	0047d71b          	srliw	a4,a5,0x4
ffffffffc0201066:	8fd9                	or	a5,a5,a4
ffffffffc0201068:	2781                	sext.w	a5,a5
    size |= size >> 8;
ffffffffc020106a:	0087d71b          	srliw	a4,a5,0x8
ffffffffc020106e:	8fd9                	or	a5,a5,a4
ffffffffc0201070:	2781                	sext.w	a5,a5
    size |= size >> 16;
ffffffffc0201072:	0107d71b          	srliw	a4,a5,0x10
ffffffffc0201076:	8fd9                	or	a5,a5,a4
    return size+1;
ffffffffc0201078:	2785                	addiw	a5,a5,1
        n=fixsize(n);
ffffffffc020107a:	02079493          	slli	s1,a5,0x20
ffffffffc020107e:	9081                	srli	s1,s1,0x20
    return size+1;
ffffffffc0201080:	0007899b          	sext.w	s3,a5
ffffffffc0201084:	0004859b          	sext.w	a1,s1
ffffffffc0201088:	bded                	j	ffffffffc0200f82 <buddy_alloc_pages+0x30>
    __list_del(listelm->prev, listelm->next);
ffffffffc020108a:	6c18                	ld	a4,24(s0)
ffffffffc020108c:	701c                	ld	a5,32(s0)
    prev->next = next;
ffffffffc020108e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201090:	e398                	sd	a4,0(a5)
ffffffffc0201092:	b78d                	j	ffffffffc0200ff4 <buddy_alloc_pages+0xa2>
            struct Page *right_page = page + n;
ffffffffc0201094:	00249793          	slli	a5,s1,0x2
ffffffffc0201098:	94be                	add	s1,s1,a5
    __list_del(listelm->prev, listelm->next);
ffffffffc020109a:	7018                	ld	a4,32(s0)
ffffffffc020109c:	048e                	slli	s1,s1,0x3
    return listelm->prev;
ffffffffc020109e:	6c1c                	ld	a5,24(s0)
ffffffffc02010a0:	94a2                	add	s1,s1,s0
            right_page->property = n;
ffffffffc02010a2:	0134a823          	sw	s3,16(s1)
            list_add(prev, &(right_page->page_link));
ffffffffc02010a6:	01848693          	addi	a3,s1,24
    prev->next = next->prev = elm;
ffffffffc02010aa:	e314                	sd	a3,0(a4)
ffffffffc02010ac:	e794                	sd	a3,8(a5)
    elm->next = next;
ffffffffc02010ae:	f098                	sd	a4,32(s1)
    elm->prev = prev;
ffffffffc02010b0:	ec9c                	sd	a5,24(s1)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010b2:	00848713          	addi	a4,s1,8
ffffffffc02010b6:	4789                	li	a5,2
ffffffffc02010b8:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc02010bc:	bf25                	j	ffffffffc0200ff4 <buddy_alloc_pages+0xa2>
        return NULL;
ffffffffc02010be:	4401                	li	s0,0
ffffffffc02010c0:	bfbd                	j	ffffffffc020103e <buddy_alloc_pages+0xec>
    assert(n>0);
ffffffffc02010c2:	00001697          	auipc	a3,0x1
ffffffffc02010c6:	0de68693          	addi	a3,a3,222 # ffffffffc02021a0 <commands+0x7d8>
ffffffffc02010ca:	00001617          	auipc	a2,0x1
ffffffffc02010ce:	0de60613          	addi	a2,a2,222 # ffffffffc02021a8 <commands+0x7e0>
ffffffffc02010d2:	0a300593          	li	a1,163
ffffffffc02010d6:	00001517          	auipc	a0,0x1
ffffffffc02010da:	0ea50513          	addi	a0,a0,234 # ffffffffc02021c0 <commands+0x7f8>
ffffffffc02010de:	aceff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010e2 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02010e2:	100027f3          	csrr	a5,sstatus
ffffffffc02010e6:	8b89                	andi	a5,a5,2
ffffffffc02010e8:	eb89                	bnez	a5,ffffffffc02010fa <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02010ea:	00053797          	auipc	a5,0x53
ffffffffc02010ee:	57e78793          	addi	a5,a5,1406 # ffffffffc0254668 <pmm_manager>
ffffffffc02010f2:	639c                	ld	a5,0(a5)
ffffffffc02010f4:	0187b303          	ld	t1,24(a5)
ffffffffc02010f8:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02010fa:	1141                	addi	sp,sp,-16
ffffffffc02010fc:	e406                	sd	ra,8(sp)
ffffffffc02010fe:	e022                	sd	s0,0(sp)
ffffffffc0201100:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0201102:	b62ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201106:	00053797          	auipc	a5,0x53
ffffffffc020110a:	56278793          	addi	a5,a5,1378 # ffffffffc0254668 <pmm_manager>
ffffffffc020110e:	639c                	ld	a5,0(a5)
ffffffffc0201110:	8522                	mv	a0,s0
ffffffffc0201112:	6f9c                	ld	a5,24(a5)
ffffffffc0201114:	9782                	jalr	a5
ffffffffc0201116:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201118:	b46ff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020111c:	8522                	mv	a0,s0
ffffffffc020111e:	60a2                	ld	ra,8(sp)
ffffffffc0201120:	6402                	ld	s0,0(sp)
ffffffffc0201122:	0141                	addi	sp,sp,16
ffffffffc0201124:	8082                	ret

ffffffffc0201126 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201126:	100027f3          	csrr	a5,sstatus
ffffffffc020112a:	8b89                	andi	a5,a5,2
ffffffffc020112c:	eb89                	bnez	a5,ffffffffc020113e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020112e:	00053797          	auipc	a5,0x53
ffffffffc0201132:	53a78793          	addi	a5,a5,1338 # ffffffffc0254668 <pmm_manager>
ffffffffc0201136:	639c                	ld	a5,0(a5)
ffffffffc0201138:	0207b303          	ld	t1,32(a5)
ffffffffc020113c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020113e:	1101                	addi	sp,sp,-32
ffffffffc0201140:	ec06                	sd	ra,24(sp)
ffffffffc0201142:	e822                	sd	s0,16(sp)
ffffffffc0201144:	e426                	sd	s1,8(sp)
ffffffffc0201146:	842a                	mv	s0,a0
ffffffffc0201148:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020114a:	b1aff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020114e:	00053797          	auipc	a5,0x53
ffffffffc0201152:	51a78793          	addi	a5,a5,1306 # ffffffffc0254668 <pmm_manager>
ffffffffc0201156:	639c                	ld	a5,0(a5)
ffffffffc0201158:	85a6                	mv	a1,s1
ffffffffc020115a:	8522                	mv	a0,s0
ffffffffc020115c:	739c                	ld	a5,32(a5)
ffffffffc020115e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201160:	6442                	ld	s0,16(sp)
ffffffffc0201162:	60e2                	ld	ra,24(sp)
ffffffffc0201164:	64a2                	ld	s1,8(sp)
ffffffffc0201166:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201168:	af6ff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc020116c <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc020116c:	00001797          	auipc	a5,0x1
ffffffffc0201170:	18c78793          	addi	a5,a5,396 # ffffffffc02022f8 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201174:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201176:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201178:	00001517          	auipc	a0,0x1
ffffffffc020117c:	1d050513          	addi	a0,a0,464 # ffffffffc0202348 <buddy_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0201180:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201182:	00053717          	auipc	a4,0x53
ffffffffc0201186:	4ef73323          	sd	a5,1254(a4) # ffffffffc0254668 <pmm_manager>
void pmm_init(void) {
ffffffffc020118a:	e822                	sd	s0,16(sp)
ffffffffc020118c:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc020118e:	00053417          	auipc	s0,0x53
ffffffffc0201192:	4da40413          	addi	s0,s0,1242 # ffffffffc0254668 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201196:	f21fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc020119a:	601c                	ld	a5,0(s0)
ffffffffc020119c:	679c                	ld	a5,8(a5)
ffffffffc020119e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011a0:	57f5                	li	a5,-3
ffffffffc02011a2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02011a4:	00001517          	auipc	a0,0x1
ffffffffc02011a8:	1bc50513          	addi	a0,a0,444 # ffffffffc0202360 <buddy_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02011ac:	00053717          	auipc	a4,0x53
ffffffffc02011b0:	4cf73223          	sd	a5,1220(a4) # ffffffffc0254670 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02011b4:	f03fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02011b8:	46c5                	li	a3,17
ffffffffc02011ba:	06ee                	slli	a3,a3,0x1b
ffffffffc02011bc:	40100613          	li	a2,1025
ffffffffc02011c0:	16fd                	addi	a3,a3,-1
ffffffffc02011c2:	0656                	slli	a2,a2,0x15
ffffffffc02011c4:	07e005b7          	lui	a1,0x7e00
ffffffffc02011c8:	00001517          	auipc	a0,0x1
ffffffffc02011cc:	1b050513          	addi	a0,a0,432 # ffffffffc0202378 <buddy_pmm_manager+0x80>
ffffffffc02011d0:	ee7fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011d4:	777d                	lui	a4,0xfffff
ffffffffc02011d6:	00054797          	auipc	a5,0x54
ffffffffc02011da:	4a978793          	addi	a5,a5,1193 # ffffffffc025567f <end+0xfff>
ffffffffc02011de:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02011e0:	00088737          	lui	a4,0x88
ffffffffc02011e4:	00005697          	auipc	a3,0x5
ffffffffc02011e8:	22e6ba23          	sd	a4,564(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011ec:	4601                	li	a2,0
ffffffffc02011ee:	00053717          	auipc	a4,0x53
ffffffffc02011f2:	48f73523          	sd	a5,1162(a4) # ffffffffc0254678 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011f6:	4681                	li	a3,0
ffffffffc02011f8:	00005897          	auipc	a7,0x5
ffffffffc02011fc:	22088893          	addi	a7,a7,544 # ffffffffc0206418 <npage>
ffffffffc0201200:	00053597          	auipc	a1,0x53
ffffffffc0201204:	47858593          	addi	a1,a1,1144 # ffffffffc0254678 <pages>
ffffffffc0201208:	4805                	li	a6,1
ffffffffc020120a:	fff80537          	lui	a0,0xfff80
ffffffffc020120e:	a011                	j	ffffffffc0201212 <pmm_init+0xa6>
ffffffffc0201210:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201212:	97b2                	add	a5,a5,a2
ffffffffc0201214:	07a1                	addi	a5,a5,8
ffffffffc0201216:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020121a:	0008b703          	ld	a4,0(a7)
ffffffffc020121e:	0685                	addi	a3,a3,1
ffffffffc0201220:	02860613          	addi	a2,a2,40
ffffffffc0201224:	00a707b3          	add	a5,a4,a0
ffffffffc0201228:	fef6e4e3          	bltu	a3,a5,ffffffffc0201210 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020122c:	6190                	ld	a2,0(a1)
ffffffffc020122e:	00271793          	slli	a5,a4,0x2
ffffffffc0201232:	97ba                	add	a5,a5,a4
ffffffffc0201234:	fec006b7          	lui	a3,0xfec00
ffffffffc0201238:	078e                	slli	a5,a5,0x3
ffffffffc020123a:	96b2                	add	a3,a3,a2
ffffffffc020123c:	96be                	add	a3,a3,a5
ffffffffc020123e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201242:	08f6e863          	bltu	a3,a5,ffffffffc02012d2 <pmm_init+0x166>
ffffffffc0201246:	00053497          	auipc	s1,0x53
ffffffffc020124a:	42a48493          	addi	s1,s1,1066 # ffffffffc0254670 <va_pa_offset>
ffffffffc020124e:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201250:	45c5                	li	a1,17
ffffffffc0201252:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201254:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201256:	04b6e963          	bltu	a3,a1,ffffffffc02012a8 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020125a:	601c                	ld	a5,0(s0)
ffffffffc020125c:	7b9c                	ld	a5,48(a5)
ffffffffc020125e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201260:	00001517          	auipc	a0,0x1
ffffffffc0201264:	1b050513          	addi	a0,a0,432 # ffffffffc0202410 <buddy_pmm_manager+0x118>
ffffffffc0201268:	e4ffe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020126c:	00004697          	auipc	a3,0x4
ffffffffc0201270:	d9468693          	addi	a3,a3,-620 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201274:	00005797          	auipc	a5,0x5
ffffffffc0201278:	1ad7b623          	sd	a3,428(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020127c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201280:	06f6e563          	bltu	a3,a5,ffffffffc02012ea <pmm_init+0x17e>
ffffffffc0201284:	609c                	ld	a5,0(s1)
}
ffffffffc0201286:	6442                	ld	s0,16(sp)
ffffffffc0201288:	60e2                	ld	ra,24(sp)
ffffffffc020128a:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020128c:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020128e:	8e9d                	sub	a3,a3,a5
ffffffffc0201290:	00053797          	auipc	a5,0x53
ffffffffc0201294:	3cd7b823          	sd	a3,976(a5) # ffffffffc0254660 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201298:	00001517          	auipc	a0,0x1
ffffffffc020129c:	19850513          	addi	a0,a0,408 # ffffffffc0202430 <buddy_pmm_manager+0x138>
ffffffffc02012a0:	8636                	mv	a2,a3
}
ffffffffc02012a2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02012a4:	e13fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02012a8:	6785                	lui	a5,0x1
ffffffffc02012aa:	17fd                	addi	a5,a5,-1
ffffffffc02012ac:	96be                	add	a3,a3,a5
ffffffffc02012ae:	77fd                	lui	a5,0xfffff
ffffffffc02012b0:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02012b2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02012b6:	04e7f663          	bleu	a4,a5,ffffffffc0201302 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02012ba:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02012bc:	97aa                	add	a5,a5,a0
ffffffffc02012be:	00279513          	slli	a0,a5,0x2
ffffffffc02012c2:	953e                	add	a0,a0,a5
ffffffffc02012c4:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02012c6:	8d95                	sub	a1,a1,a3
ffffffffc02012c8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02012ca:	81b1                	srli	a1,a1,0xc
ffffffffc02012cc:	9532                	add	a0,a0,a2
ffffffffc02012ce:	9782                	jalr	a5
ffffffffc02012d0:	b769                	j	ffffffffc020125a <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02012d2:	00001617          	auipc	a2,0x1
ffffffffc02012d6:	0d660613          	addi	a2,a2,214 # ffffffffc02023a8 <buddy_pmm_manager+0xb0>
ffffffffc02012da:	06f00593          	li	a1,111
ffffffffc02012de:	00001517          	auipc	a0,0x1
ffffffffc02012e2:	0f250513          	addi	a0,a0,242 # ffffffffc02023d0 <buddy_pmm_manager+0xd8>
ffffffffc02012e6:	8c6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012ea:	00001617          	auipc	a2,0x1
ffffffffc02012ee:	0be60613          	addi	a2,a2,190 # ffffffffc02023a8 <buddy_pmm_manager+0xb0>
ffffffffc02012f2:	08a00593          	li	a1,138
ffffffffc02012f6:	00001517          	auipc	a0,0x1
ffffffffc02012fa:	0da50513          	addi	a0,a0,218 # ffffffffc02023d0 <buddy_pmm_manager+0xd8>
ffffffffc02012fe:	8aeff0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201302:	00001617          	auipc	a2,0x1
ffffffffc0201306:	0de60613          	addi	a2,a2,222 # ffffffffc02023e0 <buddy_pmm_manager+0xe8>
ffffffffc020130a:	06b00593          	li	a1,107
ffffffffc020130e:	00001517          	auipc	a0,0x1
ffffffffc0201312:	0f250513          	addi	a0,a0,242 # ffffffffc0202400 <buddy_pmm_manager+0x108>
ffffffffc0201316:	896ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020131a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020131a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020131e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201320:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201324:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201326:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020132a:	f022                	sd	s0,32(sp)
ffffffffc020132c:	ec26                	sd	s1,24(sp)
ffffffffc020132e:	e84a                	sd	s2,16(sp)
ffffffffc0201330:	f406                	sd	ra,40(sp)
ffffffffc0201332:	e44e                	sd	s3,8(sp)
ffffffffc0201334:	84aa                	mv	s1,a0
ffffffffc0201336:	892e                	mv	s2,a1
ffffffffc0201338:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020133c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020133e:	03067e63          	bleu	a6,a2,ffffffffc020137a <printnum+0x60>
ffffffffc0201342:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201344:	00805763          	blez	s0,ffffffffc0201352 <printnum+0x38>
ffffffffc0201348:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020134a:	85ca                	mv	a1,s2
ffffffffc020134c:	854e                	mv	a0,s3
ffffffffc020134e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201350:	fc65                	bnez	s0,ffffffffc0201348 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201352:	1a02                	slli	s4,s4,0x20
ffffffffc0201354:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201358:	00001797          	auipc	a5,0x1
ffffffffc020135c:	2a878793          	addi	a5,a5,680 # ffffffffc0202600 <error_string+0x38>
ffffffffc0201360:	9a3e                	add	s4,s4,a5
}
ffffffffc0201362:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201364:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201368:	70a2                	ld	ra,40(sp)
ffffffffc020136a:	69a2                	ld	s3,8(sp)
ffffffffc020136c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020136e:	85ca                	mv	a1,s2
ffffffffc0201370:	8326                	mv	t1,s1
}
ffffffffc0201372:	6942                	ld	s2,16(sp)
ffffffffc0201374:	64e2                	ld	s1,24(sp)
ffffffffc0201376:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201378:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020137a:	03065633          	divu	a2,a2,a6
ffffffffc020137e:	8722                	mv	a4,s0
ffffffffc0201380:	f9bff0ef          	jal	ra,ffffffffc020131a <printnum>
ffffffffc0201384:	b7f9                	j	ffffffffc0201352 <printnum+0x38>

ffffffffc0201386 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201386:	7119                	addi	sp,sp,-128
ffffffffc0201388:	f4a6                	sd	s1,104(sp)
ffffffffc020138a:	f0ca                	sd	s2,96(sp)
ffffffffc020138c:	e8d2                	sd	s4,80(sp)
ffffffffc020138e:	e4d6                	sd	s5,72(sp)
ffffffffc0201390:	e0da                	sd	s6,64(sp)
ffffffffc0201392:	fc5e                	sd	s7,56(sp)
ffffffffc0201394:	f862                	sd	s8,48(sp)
ffffffffc0201396:	f06a                	sd	s10,32(sp)
ffffffffc0201398:	fc86                	sd	ra,120(sp)
ffffffffc020139a:	f8a2                	sd	s0,112(sp)
ffffffffc020139c:	ecce                	sd	s3,88(sp)
ffffffffc020139e:	f466                	sd	s9,40(sp)
ffffffffc02013a0:	ec6e                	sd	s11,24(sp)
ffffffffc02013a2:	892a                	mv	s2,a0
ffffffffc02013a4:	84ae                	mv	s1,a1
ffffffffc02013a6:	8d32                	mv	s10,a2
ffffffffc02013a8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02013aa:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ac:	00001a17          	auipc	s4,0x1
ffffffffc02013b0:	0c4a0a13          	addi	s4,s4,196 # ffffffffc0202470 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02013b4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02013b8:	00001c17          	auipc	s8,0x1
ffffffffc02013bc:	210c0c13          	addi	s8,s8,528 # ffffffffc02025c8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013c0:	000d4503          	lbu	a0,0(s10)
ffffffffc02013c4:	02500793          	li	a5,37
ffffffffc02013c8:	001d0413          	addi	s0,s10,1
ffffffffc02013cc:	00f50e63          	beq	a0,a5,ffffffffc02013e8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02013d0:	c521                	beqz	a0,ffffffffc0201418 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013d2:	02500993          	li	s3,37
ffffffffc02013d6:	a011                	j	ffffffffc02013da <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02013d8:	c121                	beqz	a0,ffffffffc0201418 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02013da:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013dc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02013de:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02013e0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02013e4:	ff351ae3          	bne	a0,s3,ffffffffc02013d8 <vprintfmt+0x52>
ffffffffc02013e8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02013ec:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02013f0:	4981                	li	s3,0
ffffffffc02013f2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02013f4:	5cfd                	li	s9,-1
ffffffffc02013f6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013f8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02013fc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013fe:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201402:	0ff6f693          	andi	a3,a3,255
ffffffffc0201406:	00140d13          	addi	s10,s0,1
ffffffffc020140a:	20d5e563          	bltu	a1,a3,ffffffffc0201614 <vprintfmt+0x28e>
ffffffffc020140e:	068a                	slli	a3,a3,0x2
ffffffffc0201410:	96d2                	add	a3,a3,s4
ffffffffc0201412:	4294                	lw	a3,0(a3)
ffffffffc0201414:	96d2                	add	a3,a3,s4
ffffffffc0201416:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201418:	70e6                	ld	ra,120(sp)
ffffffffc020141a:	7446                	ld	s0,112(sp)
ffffffffc020141c:	74a6                	ld	s1,104(sp)
ffffffffc020141e:	7906                	ld	s2,96(sp)
ffffffffc0201420:	69e6                	ld	s3,88(sp)
ffffffffc0201422:	6a46                	ld	s4,80(sp)
ffffffffc0201424:	6aa6                	ld	s5,72(sp)
ffffffffc0201426:	6b06                	ld	s6,64(sp)
ffffffffc0201428:	7be2                	ld	s7,56(sp)
ffffffffc020142a:	7c42                	ld	s8,48(sp)
ffffffffc020142c:	7ca2                	ld	s9,40(sp)
ffffffffc020142e:	7d02                	ld	s10,32(sp)
ffffffffc0201430:	6de2                	ld	s11,24(sp)
ffffffffc0201432:	6109                	addi	sp,sp,128
ffffffffc0201434:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201436:	4705                	li	a4,1
ffffffffc0201438:	008a8593          	addi	a1,s5,8
ffffffffc020143c:	01074463          	blt	a4,a6,ffffffffc0201444 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201440:	26080363          	beqz	a6,ffffffffc02016a6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201444:	000ab603          	ld	a2,0(s5)
ffffffffc0201448:	46c1                	li	a3,16
ffffffffc020144a:	8aae                	mv	s5,a1
ffffffffc020144c:	a06d                	j	ffffffffc02014f6 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020144e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201452:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201454:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201456:	b765                	j	ffffffffc02013fe <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201458:	000aa503          	lw	a0,0(s5)
ffffffffc020145c:	85a6                	mv	a1,s1
ffffffffc020145e:	0aa1                	addi	s5,s5,8
ffffffffc0201460:	9902                	jalr	s2
            break;
ffffffffc0201462:	bfb9                	j	ffffffffc02013c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201464:	4705                	li	a4,1
ffffffffc0201466:	008a8993          	addi	s3,s5,8
ffffffffc020146a:	01074463          	blt	a4,a6,ffffffffc0201472 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020146e:	22080463          	beqz	a6,ffffffffc0201696 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201472:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201476:	24044463          	bltz	s0,ffffffffc02016be <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020147a:	8622                	mv	a2,s0
ffffffffc020147c:	8ace                	mv	s5,s3
ffffffffc020147e:	46a9                	li	a3,10
ffffffffc0201480:	a89d                	j	ffffffffc02014f6 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201482:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201486:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201488:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020148a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020148e:	8fb5                	xor	a5,a5,a3
ffffffffc0201490:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201494:	1ad74363          	blt	a4,a3,ffffffffc020163a <vprintfmt+0x2b4>
ffffffffc0201498:	00369793          	slli	a5,a3,0x3
ffffffffc020149c:	97e2                	add	a5,a5,s8
ffffffffc020149e:	639c                	ld	a5,0(a5)
ffffffffc02014a0:	18078d63          	beqz	a5,ffffffffc020163a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014a4:	86be                	mv	a3,a5
ffffffffc02014a6:	00001617          	auipc	a2,0x1
ffffffffc02014aa:	20a60613          	addi	a2,a2,522 # ffffffffc02026b0 <error_string+0xe8>
ffffffffc02014ae:	85a6                	mv	a1,s1
ffffffffc02014b0:	854a                	mv	a0,s2
ffffffffc02014b2:	240000ef          	jal	ra,ffffffffc02016f2 <printfmt>
ffffffffc02014b6:	b729                	j	ffffffffc02013c0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02014b8:	00144603          	lbu	a2,1(s0)
ffffffffc02014bc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014c0:	bf3d                	j	ffffffffc02013fe <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02014c2:	4705                	li	a4,1
ffffffffc02014c4:	008a8593          	addi	a1,s5,8
ffffffffc02014c8:	01074463          	blt	a4,a6,ffffffffc02014d0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02014cc:	1e080263          	beqz	a6,ffffffffc02016b0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02014d0:	000ab603          	ld	a2,0(s5)
ffffffffc02014d4:	46a1                	li	a3,8
ffffffffc02014d6:	8aae                	mv	s5,a1
ffffffffc02014d8:	a839                	j	ffffffffc02014f6 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02014da:	03000513          	li	a0,48
ffffffffc02014de:	85a6                	mv	a1,s1
ffffffffc02014e0:	e03e                	sd	a5,0(sp)
ffffffffc02014e2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02014e4:	85a6                	mv	a1,s1
ffffffffc02014e6:	07800513          	li	a0,120
ffffffffc02014ea:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02014ec:	0aa1                	addi	s5,s5,8
ffffffffc02014ee:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02014f2:	6782                	ld	a5,0(sp)
ffffffffc02014f4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02014f6:	876e                	mv	a4,s11
ffffffffc02014f8:	85a6                	mv	a1,s1
ffffffffc02014fa:	854a                	mv	a0,s2
ffffffffc02014fc:	e1fff0ef          	jal	ra,ffffffffc020131a <printnum>
            break;
ffffffffc0201500:	b5c1                	j	ffffffffc02013c0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201502:	000ab603          	ld	a2,0(s5)
ffffffffc0201506:	0aa1                	addi	s5,s5,8
ffffffffc0201508:	1c060663          	beqz	a2,ffffffffc02016d4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020150c:	00160413          	addi	s0,a2,1
ffffffffc0201510:	17b05c63          	blez	s11,ffffffffc0201688 <vprintfmt+0x302>
ffffffffc0201514:	02d00593          	li	a1,45
ffffffffc0201518:	14b79263          	bne	a5,a1,ffffffffc020165c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020151c:	00064783          	lbu	a5,0(a2)
ffffffffc0201520:	0007851b          	sext.w	a0,a5
ffffffffc0201524:	c905                	beqz	a0,ffffffffc0201554 <vprintfmt+0x1ce>
ffffffffc0201526:	000cc563          	bltz	s9,ffffffffc0201530 <vprintfmt+0x1aa>
ffffffffc020152a:	3cfd                	addiw	s9,s9,-1
ffffffffc020152c:	036c8263          	beq	s9,s6,ffffffffc0201550 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201530:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201532:	18098463          	beqz	s3,ffffffffc02016ba <vprintfmt+0x334>
ffffffffc0201536:	3781                	addiw	a5,a5,-32
ffffffffc0201538:	18fbf163          	bleu	a5,s7,ffffffffc02016ba <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020153c:	03f00513          	li	a0,63
ffffffffc0201540:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201542:	0405                	addi	s0,s0,1
ffffffffc0201544:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201548:	3dfd                	addiw	s11,s11,-1
ffffffffc020154a:	0007851b          	sext.w	a0,a5
ffffffffc020154e:	fd61                	bnez	a0,ffffffffc0201526 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201550:	e7b058e3          	blez	s11,ffffffffc02013c0 <vprintfmt+0x3a>
ffffffffc0201554:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201556:	85a6                	mv	a1,s1
ffffffffc0201558:	02000513          	li	a0,32
ffffffffc020155c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020155e:	e60d81e3          	beqz	s11,ffffffffc02013c0 <vprintfmt+0x3a>
ffffffffc0201562:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201564:	85a6                	mv	a1,s1
ffffffffc0201566:	02000513          	li	a0,32
ffffffffc020156a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020156c:	fe0d94e3          	bnez	s11,ffffffffc0201554 <vprintfmt+0x1ce>
ffffffffc0201570:	bd81                	j	ffffffffc02013c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201572:	4705                	li	a4,1
ffffffffc0201574:	008a8593          	addi	a1,s5,8
ffffffffc0201578:	01074463          	blt	a4,a6,ffffffffc0201580 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020157c:	12080063          	beqz	a6,ffffffffc020169c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201580:	000ab603          	ld	a2,0(s5)
ffffffffc0201584:	46a9                	li	a3,10
ffffffffc0201586:	8aae                	mv	s5,a1
ffffffffc0201588:	b7bd                	j	ffffffffc02014f6 <vprintfmt+0x170>
ffffffffc020158a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020158e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201592:	846a                	mv	s0,s10
ffffffffc0201594:	b5ad                	j	ffffffffc02013fe <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201596:	85a6                	mv	a1,s1
ffffffffc0201598:	02500513          	li	a0,37
ffffffffc020159c:	9902                	jalr	s2
            break;
ffffffffc020159e:	b50d                	j	ffffffffc02013c0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02015a0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02015a4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02015a8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015aa:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02015ac:	e40dd9e3          	bgez	s11,ffffffffc02013fe <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02015b0:	8de6                	mv	s11,s9
ffffffffc02015b2:	5cfd                	li	s9,-1
ffffffffc02015b4:	b5a9                	j	ffffffffc02013fe <vprintfmt+0x78>
            goto reswitch;
ffffffffc02015b6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02015ba:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015c0:	bd3d                	j	ffffffffc02013fe <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02015c2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02015c6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ca:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015cc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015d0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015d4:	fcd56ce3          	bltu	a0,a3,ffffffffc02015ac <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02015d8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015da:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02015de:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015e2:	0196873b          	addw	a4,a3,s9
ffffffffc02015e6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015ea:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02015ee:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02015f2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02015f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015fa:	fcd57fe3          	bleu	a3,a0,ffffffffc02015d8 <vprintfmt+0x252>
ffffffffc02015fe:	b77d                	j	ffffffffc02015ac <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201600:	fffdc693          	not	a3,s11
ffffffffc0201604:	96fd                	srai	a3,a3,0x3f
ffffffffc0201606:	00ddfdb3          	and	s11,s11,a3
ffffffffc020160a:	00144603          	lbu	a2,1(s0)
ffffffffc020160e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201610:	846a                	mv	s0,s10
ffffffffc0201612:	b3f5                	j	ffffffffc02013fe <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201614:	85a6                	mv	a1,s1
ffffffffc0201616:	02500513          	li	a0,37
ffffffffc020161a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020161c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201620:	02500793          	li	a5,37
ffffffffc0201624:	8d22                	mv	s10,s0
ffffffffc0201626:	d8f70de3          	beq	a4,a5,ffffffffc02013c0 <vprintfmt+0x3a>
ffffffffc020162a:	02500713          	li	a4,37
ffffffffc020162e:	1d7d                	addi	s10,s10,-1
ffffffffc0201630:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201634:	fee79de3          	bne	a5,a4,ffffffffc020162e <vprintfmt+0x2a8>
ffffffffc0201638:	b361                	j	ffffffffc02013c0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020163a:	00001617          	auipc	a2,0x1
ffffffffc020163e:	06660613          	addi	a2,a2,102 # ffffffffc02026a0 <error_string+0xd8>
ffffffffc0201642:	85a6                	mv	a1,s1
ffffffffc0201644:	854a                	mv	a0,s2
ffffffffc0201646:	0ac000ef          	jal	ra,ffffffffc02016f2 <printfmt>
ffffffffc020164a:	bb9d                	j	ffffffffc02013c0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020164c:	00001617          	auipc	a2,0x1
ffffffffc0201650:	04c60613          	addi	a2,a2,76 # ffffffffc0202698 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201654:	00001417          	auipc	s0,0x1
ffffffffc0201658:	04540413          	addi	s0,s0,69 # ffffffffc0202699 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020165c:	8532                	mv	a0,a2
ffffffffc020165e:	85e6                	mv	a1,s9
ffffffffc0201660:	e032                	sd	a2,0(sp)
ffffffffc0201662:	e43e                	sd	a5,8(sp)
ffffffffc0201664:	1c2000ef          	jal	ra,ffffffffc0201826 <strnlen>
ffffffffc0201668:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020166c:	6602                	ld	a2,0(sp)
ffffffffc020166e:	01b05d63          	blez	s11,ffffffffc0201688 <vprintfmt+0x302>
ffffffffc0201672:	67a2                	ld	a5,8(sp)
ffffffffc0201674:	2781                	sext.w	a5,a5
ffffffffc0201676:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201678:	6522                	ld	a0,8(sp)
ffffffffc020167a:	85a6                	mv	a1,s1
ffffffffc020167c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020167e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201680:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201682:	6602                	ld	a2,0(sp)
ffffffffc0201684:	fe0d9ae3          	bnez	s11,ffffffffc0201678 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201688:	00064783          	lbu	a5,0(a2)
ffffffffc020168c:	0007851b          	sext.w	a0,a5
ffffffffc0201690:	e8051be3          	bnez	a0,ffffffffc0201526 <vprintfmt+0x1a0>
ffffffffc0201694:	b335                	j	ffffffffc02013c0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201696:	000aa403          	lw	s0,0(s5)
ffffffffc020169a:	bbf1                	j	ffffffffc0201476 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020169c:	000ae603          	lwu	a2,0(s5)
ffffffffc02016a0:	46a9                	li	a3,10
ffffffffc02016a2:	8aae                	mv	s5,a1
ffffffffc02016a4:	bd89                	j	ffffffffc02014f6 <vprintfmt+0x170>
ffffffffc02016a6:	000ae603          	lwu	a2,0(s5)
ffffffffc02016aa:	46c1                	li	a3,16
ffffffffc02016ac:	8aae                	mv	s5,a1
ffffffffc02016ae:	b5a1                	j	ffffffffc02014f6 <vprintfmt+0x170>
ffffffffc02016b0:	000ae603          	lwu	a2,0(s5)
ffffffffc02016b4:	46a1                	li	a3,8
ffffffffc02016b6:	8aae                	mv	s5,a1
ffffffffc02016b8:	bd3d                	j	ffffffffc02014f6 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02016ba:	9902                	jalr	s2
ffffffffc02016bc:	b559                	j	ffffffffc0201542 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02016be:	85a6                	mv	a1,s1
ffffffffc02016c0:	02d00513          	li	a0,45
ffffffffc02016c4:	e03e                	sd	a5,0(sp)
ffffffffc02016c6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02016c8:	8ace                	mv	s5,s3
ffffffffc02016ca:	40800633          	neg	a2,s0
ffffffffc02016ce:	46a9                	li	a3,10
ffffffffc02016d0:	6782                	ld	a5,0(sp)
ffffffffc02016d2:	b515                	j	ffffffffc02014f6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02016d4:	01b05663          	blez	s11,ffffffffc02016e0 <vprintfmt+0x35a>
ffffffffc02016d8:	02d00693          	li	a3,45
ffffffffc02016dc:	f6d798e3          	bne	a5,a3,ffffffffc020164c <vprintfmt+0x2c6>
ffffffffc02016e0:	00001417          	auipc	s0,0x1
ffffffffc02016e4:	fb940413          	addi	s0,s0,-71 # ffffffffc0202699 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016e8:	02800513          	li	a0,40
ffffffffc02016ec:	02800793          	li	a5,40
ffffffffc02016f0:	bd1d                	j	ffffffffc0201526 <vprintfmt+0x1a0>

ffffffffc02016f2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016f2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02016f4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016f8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016fa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016fc:	ec06                	sd	ra,24(sp)
ffffffffc02016fe:	f83a                	sd	a4,48(sp)
ffffffffc0201700:	fc3e                	sd	a5,56(sp)
ffffffffc0201702:	e0c2                	sd	a6,64(sp)
ffffffffc0201704:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201706:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201708:	c7fff0ef          	jal	ra,ffffffffc0201386 <vprintfmt>
}
ffffffffc020170c:	60e2                	ld	ra,24(sp)
ffffffffc020170e:	6161                	addi	sp,sp,80
ffffffffc0201710:	8082                	ret

ffffffffc0201712 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201712:	715d                	addi	sp,sp,-80
ffffffffc0201714:	e486                	sd	ra,72(sp)
ffffffffc0201716:	e0a2                	sd	s0,64(sp)
ffffffffc0201718:	fc26                	sd	s1,56(sp)
ffffffffc020171a:	f84a                	sd	s2,48(sp)
ffffffffc020171c:	f44e                	sd	s3,40(sp)
ffffffffc020171e:	f052                	sd	s4,32(sp)
ffffffffc0201720:	ec56                	sd	s5,24(sp)
ffffffffc0201722:	e85a                	sd	s6,16(sp)
ffffffffc0201724:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201726:	c901                	beqz	a0,ffffffffc0201736 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201728:	85aa                	mv	a1,a0
ffffffffc020172a:	00001517          	auipc	a0,0x1
ffffffffc020172e:	f8650513          	addi	a0,a0,-122 # ffffffffc02026b0 <error_string+0xe8>
ffffffffc0201732:	985fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201736:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201738:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020173a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020173c:	4aa9                	li	s5,10
ffffffffc020173e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201740:	00005b97          	auipc	s7,0x5
ffffffffc0201744:	8d0b8b93          	addi	s7,s7,-1840 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201748:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020174c:	9e3fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201750:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201752:	00054b63          	bltz	a0,ffffffffc0201768 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201756:	00a95b63          	ble	a0,s2,ffffffffc020176c <readline+0x5a>
ffffffffc020175a:	029a5463          	ble	s1,s4,ffffffffc0201782 <readline+0x70>
        c = getchar();
ffffffffc020175e:	9d1fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201762:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201764:	fe0559e3          	bgez	a0,ffffffffc0201756 <readline+0x44>
            return NULL;
ffffffffc0201768:	4501                	li	a0,0
ffffffffc020176a:	a099                	j	ffffffffc02017b0 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020176c:	03341463          	bne	s0,s3,ffffffffc0201794 <readline+0x82>
ffffffffc0201770:	e8b9                	bnez	s1,ffffffffc02017c6 <readline+0xb4>
        c = getchar();
ffffffffc0201772:	9bdfe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc0201776:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201778:	fe0548e3          	bltz	a0,ffffffffc0201768 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020177c:	fea958e3          	ble	a0,s2,ffffffffc020176c <readline+0x5a>
ffffffffc0201780:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201782:	8522                	mv	a0,s0
ffffffffc0201784:	967fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201788:	009b87b3          	add	a5,s7,s1
ffffffffc020178c:	00878023          	sb	s0,0(a5)
ffffffffc0201790:	2485                	addiw	s1,s1,1
ffffffffc0201792:	bf6d                	j	ffffffffc020174c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201794:	01540463          	beq	s0,s5,ffffffffc020179c <readline+0x8a>
ffffffffc0201798:	fb641ae3          	bne	s0,s6,ffffffffc020174c <readline+0x3a>
            cputchar(c);
ffffffffc020179c:	8522                	mv	a0,s0
ffffffffc020179e:	94dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02017a2:	00005517          	auipc	a0,0x5
ffffffffc02017a6:	86e50513          	addi	a0,a0,-1938 # ffffffffc0206010 <edata>
ffffffffc02017aa:	94aa                	add	s1,s1,a0
ffffffffc02017ac:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02017b0:	60a6                	ld	ra,72(sp)
ffffffffc02017b2:	6406                	ld	s0,64(sp)
ffffffffc02017b4:	74e2                	ld	s1,56(sp)
ffffffffc02017b6:	7942                	ld	s2,48(sp)
ffffffffc02017b8:	79a2                	ld	s3,40(sp)
ffffffffc02017ba:	7a02                	ld	s4,32(sp)
ffffffffc02017bc:	6ae2                	ld	s5,24(sp)
ffffffffc02017be:	6b42                	ld	s6,16(sp)
ffffffffc02017c0:	6ba2                	ld	s7,8(sp)
ffffffffc02017c2:	6161                	addi	sp,sp,80
ffffffffc02017c4:	8082                	ret
            cputchar(c);
ffffffffc02017c6:	4521                	li	a0,8
ffffffffc02017c8:	923fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02017cc:	34fd                	addiw	s1,s1,-1
ffffffffc02017ce:	bfbd                	j	ffffffffc020174c <readline+0x3a>

ffffffffc02017d0 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02017d0:	00005797          	auipc	a5,0x5
ffffffffc02017d4:	83878793          	addi	a5,a5,-1992 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02017d8:	6398                	ld	a4,0(a5)
ffffffffc02017da:	4781                	li	a5,0
ffffffffc02017dc:	88ba                	mv	a7,a4
ffffffffc02017de:	852a                	mv	a0,a0
ffffffffc02017e0:	85be                	mv	a1,a5
ffffffffc02017e2:	863e                	mv	a2,a5
ffffffffc02017e4:	00000073          	ecall
ffffffffc02017e8:	87aa                	mv	a5,a0
}
ffffffffc02017ea:	8082                	ret

ffffffffc02017ec <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02017ec:	00005797          	auipc	a5,0x5
ffffffffc02017f0:	c3c78793          	addi	a5,a5,-964 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02017f4:	6398                	ld	a4,0(a5)
ffffffffc02017f6:	4781                	li	a5,0
ffffffffc02017f8:	88ba                	mv	a7,a4
ffffffffc02017fa:	852a                	mv	a0,a0
ffffffffc02017fc:	85be                	mv	a1,a5
ffffffffc02017fe:	863e                	mv	a2,a5
ffffffffc0201800:	00000073          	ecall
ffffffffc0201804:	87aa                	mv	a5,a0
}
ffffffffc0201806:	8082                	ret

ffffffffc0201808 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201808:	00004797          	auipc	a5,0x4
ffffffffc020180c:	7f878793          	addi	a5,a5,2040 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201810:	639c                	ld	a5,0(a5)
ffffffffc0201812:	4501                	li	a0,0
ffffffffc0201814:	88be                	mv	a7,a5
ffffffffc0201816:	852a                	mv	a0,a0
ffffffffc0201818:	85aa                	mv	a1,a0
ffffffffc020181a:	862a                	mv	a2,a0
ffffffffc020181c:	00000073          	ecall
ffffffffc0201820:	852a                	mv	a0,a0
}
ffffffffc0201822:	2501                	sext.w	a0,a0
ffffffffc0201824:	8082                	ret

ffffffffc0201826 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201826:	c185                	beqz	a1,ffffffffc0201846 <strnlen+0x20>
ffffffffc0201828:	00054783          	lbu	a5,0(a0)
ffffffffc020182c:	cf89                	beqz	a5,ffffffffc0201846 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020182e:	4781                	li	a5,0
ffffffffc0201830:	a021                	j	ffffffffc0201838 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201832:	00074703          	lbu	a4,0(a4)
ffffffffc0201836:	c711                	beqz	a4,ffffffffc0201842 <strnlen+0x1c>
        cnt ++;
ffffffffc0201838:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020183a:	00f50733          	add	a4,a0,a5
ffffffffc020183e:	fef59ae3          	bne	a1,a5,ffffffffc0201832 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201842:	853e                	mv	a0,a5
ffffffffc0201844:	8082                	ret
    size_t cnt = 0;
ffffffffc0201846:	4781                	li	a5,0
}
ffffffffc0201848:	853e                	mv	a0,a5
ffffffffc020184a:	8082                	ret

ffffffffc020184c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020184c:	00054783          	lbu	a5,0(a0)
ffffffffc0201850:	0005c703          	lbu	a4,0(a1)
ffffffffc0201854:	cb91                	beqz	a5,ffffffffc0201868 <strcmp+0x1c>
ffffffffc0201856:	00e79c63          	bne	a5,a4,ffffffffc020186e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020185a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020185c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201860:	0585                	addi	a1,a1,1
ffffffffc0201862:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201866:	fbe5                	bnez	a5,ffffffffc0201856 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201868:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020186a:	9d19                	subw	a0,a0,a4
ffffffffc020186c:	8082                	ret
ffffffffc020186e:	0007851b          	sext.w	a0,a5
ffffffffc0201872:	9d19                	subw	a0,a0,a4
ffffffffc0201874:	8082                	ret

ffffffffc0201876 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201876:	00054783          	lbu	a5,0(a0)
ffffffffc020187a:	cb91                	beqz	a5,ffffffffc020188e <strchr+0x18>
        if (*s == c) {
ffffffffc020187c:	00b79563          	bne	a5,a1,ffffffffc0201886 <strchr+0x10>
ffffffffc0201880:	a809                	j	ffffffffc0201892 <strchr+0x1c>
ffffffffc0201882:	00b78763          	beq	a5,a1,ffffffffc0201890 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201886:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201888:	00054783          	lbu	a5,0(a0)
ffffffffc020188c:	fbfd                	bnez	a5,ffffffffc0201882 <strchr+0xc>
    }
    return NULL;
ffffffffc020188e:	4501                	li	a0,0
}
ffffffffc0201890:	8082                	ret
ffffffffc0201892:	8082                	ret

ffffffffc0201894 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201894:	ca01                	beqz	a2,ffffffffc02018a4 <memset+0x10>
ffffffffc0201896:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201898:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020189a:	0785                	addi	a5,a5,1
ffffffffc020189c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02018a0:	fec79de3          	bne	a5,a2,ffffffffc020189a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02018a4:	8082                	ret
