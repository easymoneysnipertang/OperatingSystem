
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
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
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	55a60613          	addi	a2,a2,1370 # ffffffffc0211598 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	146040ef          	jal	ra,ffffffffc0204194 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	16e58593          	addi	a1,a1,366 # ffffffffc02041c0 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	18650513          	addi	a0,a0,390 # ffffffffc02041e0 <etext+0x22>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	2bd010ef          	jal	ra,ffffffffc0201b26 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	416030ef          	jal	ra,ffffffffc0203488 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	7a2020ef          	jal	ra,ffffffffc020281c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	356000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	39e000ef          	jal	ra,ffffffffc020042a <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	3fb030ef          	jal	ra,ffffffffc0203cac <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	3c7030ef          	jal	ra,ffffffffc0203cac <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3380006f          	j	ffffffffc020042a <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	366000ef          	jal	ra,ffffffffc0200460 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200108:	00004517          	auipc	a0,0x4
ffffffffc020010c:	11050513          	addi	a0,a0,272 # ffffffffc0204218 <etext+0x5a>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	11a50513          	addi	a0,a0,282 # ffffffffc0204238 <etext+0x7a>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	09458593          	addi	a1,a1,148 # ffffffffc02041be <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	12650513          	addi	a0,a0,294 # ffffffffc0204258 <etext+0x9a>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	0000a597          	auipc	a1,0xa
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc020a040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	13250513          	addi	a0,a0,306 # ffffffffc0204278 <etext+0xba>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00011597          	auipc	a1,0x11
ffffffffc0200156:	44658593          	addi	a1,a1,1094 # ffffffffc0211598 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	13e50513          	addi	a0,a0,318 # ffffffffc0204298 <etext+0xda>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00012597          	auipc	a1,0x12
ffffffffc020016a:	83158593          	addi	a1,a1,-1999 # ffffffffc0211997 <end+0x3ff>
ffffffffc020016e:	00000797          	auipc	a5,0x0
ffffffffc0200172:	ec878793          	addi	a5,a5,-312 # ffffffffc0200036 <kern_init>
ffffffffc0200176:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200180:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200184:	95be                	add	a1,a1,a5
ffffffffc0200186:	85a9                	srai	a1,a1,0xa
ffffffffc0200188:	00004517          	auipc	a0,0x4
ffffffffc020018c:	13050513          	addi	a0,a0,304 # ffffffffc02042b8 <etext+0xfa>
}
ffffffffc0200190:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200192:	f2dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200196 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200198:	00004617          	auipc	a2,0x4
ffffffffc020019c:	05060613          	addi	a2,a2,80 # ffffffffc02041e8 <etext+0x2a>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	05c50513          	addi	a0,a0,92 # ffffffffc0204200 <etext+0x42>
void print_stackframe(void) {
ffffffffc02001ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ae:	1c6000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b4:	00004617          	auipc	a2,0x4
ffffffffc02001b8:	20c60613          	addi	a2,a2,524 # ffffffffc02043c0 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	22458593          	addi	a1,a1,548 # ffffffffc02043e0 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	22450513          	addi	a0,a0,548 # ffffffffc02043e8 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	22660613          	addi	a2,a2,550 # ffffffffc02043f8 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	24658593          	addi	a1,a1,582 # ffffffffc0204420 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	20650513          	addi	a0,a0,518 # ffffffffc02043e8 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	24260613          	addi	a2,a2,578 # ffffffffc0204430 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	25a58593          	addi	a1,a1,602 # ffffffffc0204450 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	1ea50513          	addi	a0,a0,490 # ffffffffc02043e8 <commands+0x100>
ffffffffc0200206:	eb9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020020a:	60a2                	ld	ra,8(sp)
ffffffffc020020c:	4501                	li	a0,0
ffffffffc020020e:	0141                	addi	sp,sp,16
ffffffffc0200210:	8082                	ret

ffffffffc0200212 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
ffffffffc0200214:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200216:	ef1ff0ef          	jal	ra,ffffffffc0200106 <print_kerninfo>
    return 0;
}
ffffffffc020021a:	60a2                	ld	ra,8(sp)
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	0141                	addi	sp,sp,16
ffffffffc0200220:	8082                	ret

ffffffffc0200222 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	1141                	addi	sp,sp,-16
ffffffffc0200224:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200226:	f71ff0ef          	jal	ra,ffffffffc0200196 <print_stackframe>
    return 0;
}
ffffffffc020022a:	60a2                	ld	ra,8(sp)
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	0141                	addi	sp,sp,16
ffffffffc0200230:	8082                	ret

ffffffffc0200232 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200232:	7115                	addi	sp,sp,-224
ffffffffc0200234:	e962                	sd	s8,144(sp)
ffffffffc0200236:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	0f850513          	addi	a0,a0,248 # ffffffffc0204330 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200240:	ed86                	sd	ra,216(sp)
ffffffffc0200242:	e9a2                	sd	s0,208(sp)
ffffffffc0200244:	e5a6                	sd	s1,200(sp)
ffffffffc0200246:	e1ca                	sd	s2,192(sp)
ffffffffc0200248:	fd4e                	sd	s3,184(sp)
ffffffffc020024a:	f952                	sd	s4,176(sp)
ffffffffc020024c:	f556                	sd	s5,168(sp)
ffffffffc020024e:	f15a                	sd	s6,160(sp)
ffffffffc0200250:	ed5e                	sd	s7,152(sp)
ffffffffc0200252:	e566                	sd	s9,136(sp)
ffffffffc0200254:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200256:	e69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	0fe50513          	addi	a0,a0,254 # ffffffffc0204358 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4f2000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	078c8c93          	addi	s9,s9,120 # ffffffffc02042e8 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00005997          	auipc	s3,0x5
ffffffffc020027c:	60898993          	addi	s3,s3,1544 # ffffffffc0205880 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	10090913          	addi	s2,s2,256 # ffffffffc0204380 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	0feb0b13          	addi	s6,s6,254 # ffffffffc0204388 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	14ea8a93          	addi	s5,s5,334 # ffffffffc02043e0 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	59b030ef          	jal	ra,ffffffffc0204038 <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	6c7030ef          	jal	ra,ffffffffc0204176 <strchr>
ffffffffc02002b4:	c925                	beqz	a0,ffffffffc0200324 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b6:	00144583          	lbu	a1,1(s0)
ffffffffc02002ba:	00040023          	sb	zero,0(s0)
ffffffffc02002be:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c0:	f5fd                	bnez	a1,ffffffffc02002ae <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002c2:	dce9                	beqz	s1,ffffffffc020029c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c4:	6582                	ld	a1,0(sp)
ffffffffc02002c6:	00004d17          	auipc	s10,0x4
ffffffffc02002ca:	022d0d13          	addi	s10,s10,34 # ffffffffc02042e8 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	679030ef          	jal	ra,ffffffffc020414c <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	665030ef          	jal	ra,ffffffffc020414c <strcmp>
ffffffffc02002ec:	f57d                	bnez	a0,ffffffffc02002da <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ee:	00141793          	slli	a5,s0,0x1
ffffffffc02002f2:	97a2                	add	a5,a5,s0
ffffffffc02002f4:	078e                	slli	a5,a5,0x3
ffffffffc02002f6:	97e6                	add	a5,a5,s9
ffffffffc02002f8:	6b9c                	ld	a5,16(a5)
ffffffffc02002fa:	8662                	mv	a2,s8
ffffffffc02002fc:	002c                	addi	a1,sp,8
ffffffffc02002fe:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200302:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200304:	f8055ce3          	bgez	a0,ffffffffc020029c <kmonitor+0x6a>
}
ffffffffc0200308:	60ee                	ld	ra,216(sp)
ffffffffc020030a:	644e                	ld	s0,208(sp)
ffffffffc020030c:	64ae                	ld	s1,200(sp)
ffffffffc020030e:	690e                	ld	s2,192(sp)
ffffffffc0200310:	79ea                	ld	s3,184(sp)
ffffffffc0200312:	7a4a                	ld	s4,176(sp)
ffffffffc0200314:	7aaa                	ld	s5,168(sp)
ffffffffc0200316:	7b0a                	ld	s6,160(sp)
ffffffffc0200318:	6bea                	ld	s7,152(sp)
ffffffffc020031a:	6c4a                	ld	s8,144(sp)
ffffffffc020031c:	6caa                	ld	s9,136(sp)
ffffffffc020031e:	6d0a                	ld	s10,128(sp)
ffffffffc0200320:	612d                	addi	sp,sp,224
ffffffffc0200322:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200324:	00044783          	lbu	a5,0(s0)
ffffffffc0200328:	dfc9                	beqz	a5,ffffffffc02002c2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020032a:	03448863          	beq	s1,s4,ffffffffc020035a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032e:	00349793          	slli	a5,s1,0x3
ffffffffc0200332:	0118                	addi	a4,sp,128
ffffffffc0200334:	97ba                	add	a5,a5,a4
ffffffffc0200336:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200340:	e591                	bnez	a1,ffffffffc020034c <kmonitor+0x11a>
ffffffffc0200342:	b749                	j	ffffffffc02002c4 <kmonitor+0x92>
            buf ++;
ffffffffc0200344:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200346:	00044583          	lbu	a1,0(s0)
ffffffffc020034a:	ddad                	beqz	a1,ffffffffc02002c4 <kmonitor+0x92>
ffffffffc020034c:	854a                	mv	a0,s2
ffffffffc020034e:	629030ef          	jal	ra,ffffffffc0204176 <strchr>
ffffffffc0200352:	d96d                	beqz	a0,ffffffffc0200344 <kmonitor+0x112>
ffffffffc0200354:	00044583          	lbu	a1,0(s0)
ffffffffc0200358:	bf91                	j	ffffffffc02002ac <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200362:	b7f1                	j	ffffffffc020032e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	04250513          	addi	a0,a0,66 # ffffffffc02043a8 <commands+0xc0>
ffffffffc020036e:	d51ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc0200372:	b72d                	j	ffffffffc020029c <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0211440 <is_panic>
ffffffffc020037c:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	02031c63          	bnez	t1,ffffffffc02003c8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	8432                	mv	s0,a2
ffffffffc0200398:	00011717          	auipc	a4,0x11
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a4:	85aa                	mv	a1,a0
ffffffffc02003a6:	00004517          	auipc	a0,0x4
ffffffffc02003aa:	0ba50513          	addi	a0,a0,186 # ffffffffc0204460 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003ae:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003b0:	d0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b4:	65a2                	ld	a1,8(sp)
ffffffffc02003b6:	8522                	mv	a0,s0
ffffffffc02003b8:	ce7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003bc:	00005517          	auipc	a0,0x5
ffffffffc02003c0:	01c50513          	addi	a0,a0,28 # ffffffffc02053d8 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	132000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e65ff0ef          	jal	ra,ffffffffc0200232 <kmonitor>
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x58>

ffffffffc02003d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003da:	00011717          	auipc	a4,0x11
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e2:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	953e                	add	a0,a0,a5
ffffffffc02003ea:	4601                	li	a2,0
ffffffffc02003ec:	4881                	li	a7,0
ffffffffc02003ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003f2:	02000793          	li	a5,32
ffffffffc02003f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003fa:	00004517          	auipc	a0,0x4
ffffffffc02003fe:	08650513          	addi	a0,a0,134 # ffffffffc0204480 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00011797          	auipc	a5,0x11
ffffffffc0200406:	0607b723          	sd	zero,110(a5) # ffffffffc0211470 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00011797          	auipc	a5,0x11
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0211448 <timebase>
ffffffffc020041a:	639c                	ld	a5,0(a5)
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	953e                	add	a0,a0,a5
ffffffffc0200422:	4881                	li	a7,0
ffffffffc0200424:	00000073          	ecall
ffffffffc0200428:	8082                	ret

ffffffffc020042a <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020042a:	100027f3          	csrr	a5,sstatus
ffffffffc020042e:	8b89                	andi	a5,a5,2
ffffffffc0200430:	0ff57513          	andi	a0,a0,255
ffffffffc0200434:	e799                	bnez	a5,ffffffffc0200442 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200436:	4581                	li	a1,0
ffffffffc0200438:	4601                	li	a2,0
ffffffffc020043a:	4885                	li	a7,1
ffffffffc020043c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200440:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200442:	1101                	addi	sp,sp,-32
ffffffffc0200444:	ec06                	sd	ra,24(sp)
ffffffffc0200446:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200448:	0b2000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc020044c:	6522                	ld	a0,8(sp)
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4885                	li	a7,1
ffffffffc0200454:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200458:	60e2                	ld	ra,24(sp)
ffffffffc020045a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020045c:	0980006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200460 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200460:	100027f3          	csrr	a5,sstatus
ffffffffc0200464:	8b89                	andi	a5,a5,2
ffffffffc0200466:	eb89                	bnez	a5,ffffffffc0200478 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200468:	4501                	li	a0,0
ffffffffc020046a:	4581                	li	a1,0
ffffffffc020046c:	4601                	li	a2,0
ffffffffc020046e:	4889                	li	a7,2
ffffffffc0200470:	00000073          	ecall
ffffffffc0200474:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200476:	8082                	ret
int cons_getc(void) {
ffffffffc0200478:	1101                	addi	sp,sp,-32
ffffffffc020047a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020047c:	07e000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	064000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc0200494:	60e2                	ld	ra,24(sp)
ffffffffc0200496:	6522                	ld	a0,8(sp)
ffffffffc0200498:	6105                	addi	sp,sp,32
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020049e:	00253513          	sltiu	a0,a0,2
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004a4:	03800513          	li	a0,56
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004aa:	0000a797          	auipc	a5,0xa
ffffffffc02004ae:	b9678793          	addi	a5,a5,-1130 # ffffffffc020a040 <edata>
ffffffffc02004b2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b6:	1141                	addi	sp,sp,-16
ffffffffc02004b8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	95be                	add	a1,a1,a5
ffffffffc02004bc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c2:	4e5030ef          	jal	ra,ffffffffc02041a6 <memcpy>
    return 0;
}
ffffffffc02004c6:	60a2                	ld	ra,8(sp)
ffffffffc02004c8:	4501                	li	a0,0
ffffffffc02004ca:	0141                	addi	sp,sp,16
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004ce:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004d4:	0000a517          	auipc	a0,0xa
ffffffffc02004d8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004dc:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004de:	00969613          	slli	a2,a3,0x9
ffffffffc02004e2:	85ba                	mv	a1,a4
ffffffffc02004e4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004e6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e8:	4bf030ef          	jal	ra,ffffffffc02041a6 <memcpy>
    return 0;
}
ffffffffc02004ec:	60a2                	ld	ra,8(sp)
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	0141                	addi	sp,sp,16
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	24850513          	addi	a0,a0,584 # ffffffffc0204778 <commands+0x490>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	05478793          	addi	a5,a5,84 # ffffffffc0211590 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	4700306f          	j	ffffffffc02039c6 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	23e60613          	addi	a2,a2,574 # ffffffffc0204798 <commands+0x4b0>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	24a50513          	addi	a0,a0,586 # ffffffffc02047b0 <commands+0x4c8>
ffffffffc020056e:	e07ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	4aa78793          	addi	a5,a5,1194 # ffffffffc0200a20 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	23050513          	addi	a0,a0,560 # ffffffffc02047c8 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	23850513          	addi	a0,a0,568 # ffffffffc02047e0 <commands+0x4f8>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	24250513          	addi	a0,a0,578 # ffffffffc02047f8 <commands+0x510>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	24c50513          	addi	a0,a0,588 # ffffffffc0204810 <commands+0x528>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	25650513          	addi	a0,a0,598 # ffffffffc0204828 <commands+0x540>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	26050513          	addi	a0,a0,608 # ffffffffc0204840 <commands+0x558>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	26a50513          	addi	a0,a0,618 # ffffffffc0204858 <commands+0x570>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	27450513          	addi	a0,a0,628 # ffffffffc0204870 <commands+0x588>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	27e50513          	addi	a0,a0,638 # ffffffffc0204888 <commands+0x5a0>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	28850513          	addi	a0,a0,648 # ffffffffc02048a0 <commands+0x5b8>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	29250513          	addi	a0,a0,658 # ffffffffc02048b8 <commands+0x5d0>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	29c50513          	addi	a0,a0,668 # ffffffffc02048d0 <commands+0x5e8>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	2a650513          	addi	a0,a0,678 # ffffffffc02048e8 <commands+0x600>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	2b050513          	addi	a0,a0,688 # ffffffffc0204900 <commands+0x618>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	2ba50513          	addi	a0,a0,698 # ffffffffc0204918 <commands+0x630>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	2c450513          	addi	a0,a0,708 # ffffffffc0204930 <commands+0x648>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	2ce50513          	addi	a0,a0,718 # ffffffffc0204948 <commands+0x660>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	2d850513          	addi	a0,a0,728 # ffffffffc0204960 <commands+0x678>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	2e250513          	addi	a0,a0,738 # ffffffffc0204978 <commands+0x690>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	2ec50513          	addi	a0,a0,748 # ffffffffc0204990 <commands+0x6a8>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	2f650513          	addi	a0,a0,758 # ffffffffc02049a8 <commands+0x6c0>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	30050513          	addi	a0,a0,768 # ffffffffc02049c0 <commands+0x6d8>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	30a50513          	addi	a0,a0,778 # ffffffffc02049d8 <commands+0x6f0>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	31450513          	addi	a0,a0,788 # ffffffffc02049f0 <commands+0x708>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	31e50513          	addi	a0,a0,798 # ffffffffc0204a08 <commands+0x720>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	32850513          	addi	a0,a0,808 # ffffffffc0204a20 <commands+0x738>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	33250513          	addi	a0,a0,818 # ffffffffc0204a38 <commands+0x750>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	33c50513          	addi	a0,a0,828 # ffffffffc0204a50 <commands+0x768>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	34650513          	addi	a0,a0,838 # ffffffffc0204a68 <commands+0x780>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	35050513          	addi	a0,a0,848 # ffffffffc0204a80 <commands+0x798>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	35a50513          	addi	a0,a0,858 # ffffffffc0204a98 <commands+0x7b0>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	36050513          	addi	a0,a0,864 # ffffffffc0204ab0 <commands+0x7c8>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	36250513          	addi	a0,a0,866 # ffffffffc0204ac8 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	36250513          	addi	a0,a0,866 # ffffffffc0204ae0 <commands+0x7f8>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	36a50513          	addi	a0,a0,874 # ffffffffc0204af8 <commands+0x810>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	37250513          	addi	a0,a0,882 # ffffffffc0204b10 <commands+0x828>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	37650513          	addi	a0,a0,886 # ffffffffc0204b28 <commands+0x840>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	ccc70713          	addi	a4,a4,-820 # ffffffffc020449c <commands+0x1b4>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	f4650513          	addi	a0,a0,-186 # ffffffffc0204728 <commands+0x440>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	f1a50513          	addi	a0,a0,-230 # ffffffffc0204708 <commands+0x420>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	ece50513          	addi	a0,a0,-306 # ffffffffc02046c8 <commands+0x3e0>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	ee250513          	addi	a0,a0,-286 # ffffffffc02046e8 <commands+0x400>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	f4650513          	addi	a0,a0,-186 # ffffffffc0204758 <commands+0x470>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	bedff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c4a78793          	addi	a5,a5,-950 # ffffffffc0211470 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bb23          	sd	a5,-970(a3) # ffffffffc0211470 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020084e:	06400593          	li	a1,100
ffffffffc0200852:	00004517          	auipc	a0,0x4
ffffffffc0200856:	ef650513          	addi	a0,a0,-266 # ffffffffc0204748 <commands+0x460>
ffffffffc020085a:	865ff0ef          	jal	ra,ffffffffc02000be <cprintf>
                swap_tick_event(check_mm_struct);
ffffffffc020085e:	00011797          	auipc	a5,0x11
ffffffffc0200862:	d3278793          	addi	a5,a5,-718 # ffffffffc0211590 <check_mm_struct>
}
ffffffffc0200866:	60a2                	ld	ra,8(sp)
                swap_tick_event(check_mm_struct);
ffffffffc0200868:	6388                	ld	a0,0(a5)
}
ffffffffc020086a:	0141                	addi	sp,sp,16
                swap_tick_event(check_mm_struct);
ffffffffc020086c:	6600206f          	j	ffffffffc0202ecc <swap_tick_event>

ffffffffc0200870 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200870:	11853783          	ld	a5,280(a0)
ffffffffc0200874:	473d                	li	a4,15
ffffffffc0200876:	16f76563          	bltu	a4,a5,ffffffffc02009e0 <exception_handler+0x170>
ffffffffc020087a:	00004717          	auipc	a4,0x4
ffffffffc020087e:	c5270713          	addi	a4,a4,-942 # ffffffffc02044cc <commands+0x1e4>
ffffffffc0200882:	078a                	slli	a5,a5,0x2
ffffffffc0200884:	97ba                	add	a5,a5,a4
ffffffffc0200886:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200888:	1101                	addi	sp,sp,-32
ffffffffc020088a:	e822                	sd	s0,16(sp)
ffffffffc020088c:	ec06                	sd	ra,24(sp)
ffffffffc020088e:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200890:	97ba                	add	a5,a5,a4
ffffffffc0200892:	842a                	mv	s0,a0
ffffffffc0200894:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200896:	00004517          	auipc	a0,0x4
ffffffffc020089a:	e1a50513          	addi	a0,a0,-486 # ffffffffc02046b0 <commands+0x3c8>
ffffffffc020089e:	821ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008a2:	8522                	mv	a0,s0
ffffffffc02008a4:	c5dff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02008a8:	84aa                	mv	s1,a0
ffffffffc02008aa:	12051d63          	bnez	a0,ffffffffc02009e4 <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008ae:	60e2                	ld	ra,24(sp)
ffffffffc02008b0:	6442                	ld	s0,16(sp)
ffffffffc02008b2:	64a2                	ld	s1,8(sp)
ffffffffc02008b4:	6105                	addi	sp,sp,32
ffffffffc02008b6:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	c5850513          	addi	a0,a0,-936 # ffffffffc0204510 <commands+0x228>
}
ffffffffc02008c0:	6442                	ld	s0,16(sp)
ffffffffc02008c2:	60e2                	ld	ra,24(sp)
ffffffffc02008c4:	64a2                	ld	s1,8(sp)
ffffffffc02008c6:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008c8:	ff6ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	c6450513          	addi	a0,a0,-924 # ffffffffc0204530 <commands+0x248>
ffffffffc02008d4:	b7f5                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008d6:	00004517          	auipc	a0,0x4
ffffffffc02008da:	c7a50513          	addi	a0,a0,-902 # ffffffffc0204550 <commands+0x268>
ffffffffc02008de:	b7cd                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008e0:	00004517          	auipc	a0,0x4
ffffffffc02008e4:	c8850513          	addi	a0,a0,-888 # ffffffffc0204568 <commands+0x280>
ffffffffc02008e8:	bfe1                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008ea:	00004517          	auipc	a0,0x4
ffffffffc02008ee:	c8e50513          	addi	a0,a0,-882 # ffffffffc0204578 <commands+0x290>
ffffffffc02008f2:	b7f9                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008f4:	00004517          	auipc	a0,0x4
ffffffffc02008f8:	ca450513          	addi	a0,a0,-860 # ffffffffc0204598 <commands+0x2b0>
ffffffffc02008fc:	fc2ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200900:	8522                	mv	a0,s0
ffffffffc0200902:	bffff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200906:	84aa                	mv	s1,a0
ffffffffc0200908:	d15d                	beqz	a0,ffffffffc02008ae <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020090a:	8522                	mv	a0,s0
ffffffffc020090c:	e53ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200910:	86a6                	mv	a3,s1
ffffffffc0200912:	00004617          	auipc	a2,0x4
ffffffffc0200916:	c9e60613          	addi	a2,a2,-866 # ffffffffc02045b0 <commands+0x2c8>
ffffffffc020091a:	0cb00593          	li	a1,203
ffffffffc020091e:	00004517          	auipc	a0,0x4
ffffffffc0200922:	e9250513          	addi	a0,a0,-366 # ffffffffc02047b0 <commands+0x4c8>
ffffffffc0200926:	a4fff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020092a:	00004517          	auipc	a0,0x4
ffffffffc020092e:	ca650513          	addi	a0,a0,-858 # ffffffffc02045d0 <commands+0x2e8>
ffffffffc0200932:	b779                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200934:	00004517          	auipc	a0,0x4
ffffffffc0200938:	cb450513          	addi	a0,a0,-844 # ffffffffc02045e8 <commands+0x300>
ffffffffc020093c:	f82ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200940:	8522                	mv	a0,s0
ffffffffc0200942:	bbfff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200946:	84aa                	mv	s1,a0
ffffffffc0200948:	d13d                	beqz	a0,ffffffffc02008ae <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020094a:	8522                	mv	a0,s0
ffffffffc020094c:	e13ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200950:	86a6                	mv	a3,s1
ffffffffc0200952:	00004617          	auipc	a2,0x4
ffffffffc0200956:	c5e60613          	addi	a2,a2,-930 # ffffffffc02045b0 <commands+0x2c8>
ffffffffc020095a:	0d500593          	li	a1,213
ffffffffc020095e:	00004517          	auipc	a0,0x4
ffffffffc0200962:	e5250513          	addi	a0,a0,-430 # ffffffffc02047b0 <commands+0x4c8>
ffffffffc0200966:	a0fff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	c9650513          	addi	a0,a0,-874 # ffffffffc0204600 <commands+0x318>
ffffffffc0200972:	b7b9                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	cac50513          	addi	a0,a0,-852 # ffffffffc0204620 <commands+0x338>
ffffffffc020097c:	b791                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc020097e:	00004517          	auipc	a0,0x4
ffffffffc0200982:	cc250513          	addi	a0,a0,-830 # ffffffffc0204640 <commands+0x358>
ffffffffc0200986:	bf2d                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200988:	00004517          	auipc	a0,0x4
ffffffffc020098c:	cd850513          	addi	a0,a0,-808 # ffffffffc0204660 <commands+0x378>
ffffffffc0200990:	bf05                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200992:	00004517          	auipc	a0,0x4
ffffffffc0200996:	cee50513          	addi	a0,a0,-786 # ffffffffc0204680 <commands+0x398>
ffffffffc020099a:	b71d                	j	ffffffffc02008c0 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc020099c:	00004517          	auipc	a0,0x4
ffffffffc02009a0:	cfc50513          	addi	a0,a0,-772 # ffffffffc0204698 <commands+0x3b0>
ffffffffc02009a4:	f1aff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009a8:	8522                	mv	a0,s0
ffffffffc02009aa:	b57ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009ae:	84aa                	mv	s1,a0
ffffffffc02009b0:	ee050fe3          	beqz	a0,ffffffffc02008ae <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	da9ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00004617          	auipc	a2,0x4
ffffffffc02009c0:	bf460613          	addi	a2,a2,-1036 # ffffffffc02045b0 <commands+0x2c8>
ffffffffc02009c4:	0eb00593          	li	a1,235
ffffffffc02009c8:	00004517          	auipc	a0,0x4
ffffffffc02009cc:	de850513          	addi	a0,a0,-536 # ffffffffc02047b0 <commands+0x4c8>
ffffffffc02009d0:	9a5ff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc02009d4:	6442                	ld	s0,16(sp)
ffffffffc02009d6:	60e2                	ld	ra,24(sp)
ffffffffc02009d8:	64a2                	ld	s1,8(sp)
ffffffffc02009da:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009dc:	d83ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc02009e0:	d7fff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009e4:	8522                	mv	a0,s0
ffffffffc02009e6:	d79ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ea:	86a6                	mv	a3,s1
ffffffffc02009ec:	00004617          	auipc	a2,0x4
ffffffffc02009f0:	bc460613          	addi	a2,a2,-1084 # ffffffffc02045b0 <commands+0x2c8>
ffffffffc02009f4:	0f200593          	li	a1,242
ffffffffc02009f8:	00004517          	auipc	a0,0x4
ffffffffc02009fc:	db850513          	addi	a0,a0,-584 # ffffffffc02047b0 <commands+0x4c8>
ffffffffc0200a00:	975ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a04 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a04:	11853783          	ld	a5,280(a0)
ffffffffc0200a08:	0007c463          	bltz	a5,ffffffffc0200a10 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a0c:	e65ff06f          	j	ffffffffc0200870 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a10:	db1ff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a20 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a20:	14011073          	csrw	sscratch,sp
ffffffffc0200a24:	712d                	addi	sp,sp,-288
ffffffffc0200a26:	e406                	sd	ra,8(sp)
ffffffffc0200a28:	ec0e                	sd	gp,24(sp)
ffffffffc0200a2a:	f012                	sd	tp,32(sp)
ffffffffc0200a2c:	f416                	sd	t0,40(sp)
ffffffffc0200a2e:	f81a                	sd	t1,48(sp)
ffffffffc0200a30:	fc1e                	sd	t2,56(sp)
ffffffffc0200a32:	e0a2                	sd	s0,64(sp)
ffffffffc0200a34:	e4a6                	sd	s1,72(sp)
ffffffffc0200a36:	e8aa                	sd	a0,80(sp)
ffffffffc0200a38:	ecae                	sd	a1,88(sp)
ffffffffc0200a3a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a3c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a3e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a40:	fcbe                	sd	a5,120(sp)
ffffffffc0200a42:	e142                	sd	a6,128(sp)
ffffffffc0200a44:	e546                	sd	a7,136(sp)
ffffffffc0200a46:	e94a                	sd	s2,144(sp)
ffffffffc0200a48:	ed4e                	sd	s3,152(sp)
ffffffffc0200a4a:	f152                	sd	s4,160(sp)
ffffffffc0200a4c:	f556                	sd	s5,168(sp)
ffffffffc0200a4e:	f95a                	sd	s6,176(sp)
ffffffffc0200a50:	fd5e                	sd	s7,184(sp)
ffffffffc0200a52:	e1e2                	sd	s8,192(sp)
ffffffffc0200a54:	e5e6                	sd	s9,200(sp)
ffffffffc0200a56:	e9ea                	sd	s10,208(sp)
ffffffffc0200a58:	edee                	sd	s11,216(sp)
ffffffffc0200a5a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a5c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a5e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a60:	fdfe                	sd	t6,248(sp)
ffffffffc0200a62:	14002473          	csrr	s0,sscratch
ffffffffc0200a66:	100024f3          	csrr	s1,sstatus
ffffffffc0200a6a:	14102973          	csrr	s2,sepc
ffffffffc0200a6e:	143029f3          	csrr	s3,stval
ffffffffc0200a72:	14202a73          	csrr	s4,scause
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	e226                	sd	s1,256(sp)
ffffffffc0200a7a:	e64a                	sd	s2,264(sp)
ffffffffc0200a7c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a7e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a80:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a82:	f83ff0ef          	jal	ra,ffffffffc0200a04 <trap>

ffffffffc0200a86 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a86:	6492                	ld	s1,256(sp)
ffffffffc0200a88:	6932                	ld	s2,264(sp)
ffffffffc0200a8a:	10049073          	csrw	sstatus,s1
ffffffffc0200a8e:	14191073          	csrw	sepc,s2
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	61e2                	ld	gp,24(sp)
ffffffffc0200a96:	7202                	ld	tp,32(sp)
ffffffffc0200a98:	72a2                	ld	t0,40(sp)
ffffffffc0200a9a:	7342                	ld	t1,48(sp)
ffffffffc0200a9c:	73e2                	ld	t2,56(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	64a6                	ld	s1,72(sp)
ffffffffc0200aa2:	6546                	ld	a0,80(sp)
ffffffffc0200aa4:	65e6                	ld	a1,88(sp)
ffffffffc0200aa6:	7606                	ld	a2,96(sp)
ffffffffc0200aa8:	76a6                	ld	a3,104(sp)
ffffffffc0200aaa:	7746                	ld	a4,112(sp)
ffffffffc0200aac:	77e6                	ld	a5,120(sp)
ffffffffc0200aae:	680a                	ld	a6,128(sp)
ffffffffc0200ab0:	68aa                	ld	a7,136(sp)
ffffffffc0200ab2:	694a                	ld	s2,144(sp)
ffffffffc0200ab4:	69ea                	ld	s3,152(sp)
ffffffffc0200ab6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ab8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aba:	7b4a                	ld	s6,176(sp)
ffffffffc0200abc:	7bea                	ld	s7,184(sp)
ffffffffc0200abe:	6c0e                	ld	s8,192(sp)
ffffffffc0200ac0:	6cae                	ld	s9,200(sp)
ffffffffc0200ac2:	6d4e                	ld	s10,208(sp)
ffffffffc0200ac4:	6dee                	ld	s11,216(sp)
ffffffffc0200ac6:	7e0e                	ld	t3,224(sp)
ffffffffc0200ac8:	7eae                	ld	t4,232(sp)
ffffffffc0200aca:	7f4e                	ld	t5,240(sp)
ffffffffc0200acc:	7fee                	ld	t6,248(sp)
ffffffffc0200ace:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200ad0:	10200073          	sret
	...

ffffffffc0200ae0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ae0:	00011797          	auipc	a5,0x11
ffffffffc0200ae4:	99878793          	addi	a5,a5,-1640 # ffffffffc0211478 <free_area>
ffffffffc0200ae8:	e79c                	sd	a5,8(a5)
ffffffffc0200aea:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200aec:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200af0:	8082                	ret

ffffffffc0200af2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200af2:	00011517          	auipc	a0,0x11
ffffffffc0200af6:	99656503          	lwu	a0,-1642(a0) # ffffffffc0211488 <free_area+0x10>
ffffffffc0200afa:	8082                	ret

ffffffffc0200afc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200afc:	715d                	addi	sp,sp,-80
ffffffffc0200afe:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b00:	00011917          	auipc	s2,0x11
ffffffffc0200b04:	97890913          	addi	s2,s2,-1672 # ffffffffc0211478 <free_area>
ffffffffc0200b08:	00893783          	ld	a5,8(s2)
ffffffffc0200b0c:	e486                	sd	ra,72(sp)
ffffffffc0200b0e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b10:	fc26                	sd	s1,56(sp)
ffffffffc0200b12:	f44e                	sd	s3,40(sp)
ffffffffc0200b14:	f052                	sd	s4,32(sp)
ffffffffc0200b16:	ec56                	sd	s5,24(sp)
ffffffffc0200b18:	e85a                	sd	s6,16(sp)
ffffffffc0200b1a:	e45e                	sd	s7,8(sp)
ffffffffc0200b1c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b1e:	31278f63          	beq	a5,s2,ffffffffc0200e3c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b22:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b26:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b28:	8b05                	andi	a4,a4,1
ffffffffc0200b2a:	30070d63          	beqz	a4,ffffffffc0200e44 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b2e:	4401                	li	s0,0
ffffffffc0200b30:	4481                	li	s1,0
ffffffffc0200b32:	a031                	j	ffffffffc0200b3e <default_check+0x42>
ffffffffc0200b34:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b38:	8b09                	andi	a4,a4,2
ffffffffc0200b3a:	30070563          	beqz	a4,ffffffffc0200e44 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b42:	679c                	ld	a5,8(a5)
ffffffffc0200b44:	2485                	addiw	s1,s1,1
ffffffffc0200b46:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b48:	ff2796e3          	bne	a5,s2,ffffffffc0200b34 <default_check+0x38>
ffffffffc0200b4c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b4e:	3ef000ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0200b52:	75351963          	bne	a0,s3,ffffffffc02012a4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b56:	4505                	li	a0,1
ffffffffc0200b58:	317000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b5c:	8a2a                	mv	s4,a0
ffffffffc0200b5e:	48050363          	beqz	a0,ffffffffc0200fe4 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b62:	4505                	li	a0,1
ffffffffc0200b64:	30b000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b68:	89aa                	mv	s3,a0
ffffffffc0200b6a:	74050d63          	beqz	a0,ffffffffc02012c4 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b6e:	4505                	li	a0,1
ffffffffc0200b70:	2ff000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200b74:	8aaa                	mv	s5,a0
ffffffffc0200b76:	4e050763          	beqz	a0,ffffffffc0201064 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b7a:	2f3a0563          	beq	s4,s3,ffffffffc0200e64 <default_check+0x368>
ffffffffc0200b7e:	2eaa0363          	beq	s4,a0,ffffffffc0200e64 <default_check+0x368>
ffffffffc0200b82:	2ea98163          	beq	s3,a0,ffffffffc0200e64 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b86:	000a2783          	lw	a5,0(s4)
ffffffffc0200b8a:	2e079d63          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
ffffffffc0200b8e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b92:	2e079963          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
ffffffffc0200b96:	411c                	lw	a5,0(a0)
ffffffffc0200b98:	2e079663          	bnez	a5,ffffffffc0200e84 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b9c:	00011797          	auipc	a5,0x11
ffffffffc0200ba0:	90c78793          	addi	a5,a5,-1780 # ffffffffc02114a8 <pages>
ffffffffc0200ba4:	639c                	ld	a5,0(a5)
ffffffffc0200ba6:	00004717          	auipc	a4,0x4
ffffffffc0200baa:	f9a70713          	addi	a4,a4,-102 # ffffffffc0204b40 <commands+0x858>
ffffffffc0200bae:	630c                	ld	a1,0(a4)
ffffffffc0200bb0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200bb4:	870d                	srai	a4,a4,0x3
ffffffffc0200bb6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bba:	00005697          	auipc	a3,0x5
ffffffffc0200bbe:	48668693          	addi	a3,a3,1158 # ffffffffc0206040 <nbase>
ffffffffc0200bc2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bc4:	00011697          	auipc	a3,0x11
ffffffffc0200bc8:	89468693          	addi	a3,a3,-1900 # ffffffffc0211458 <npage>
ffffffffc0200bcc:	6294                	ld	a3,0(a3)
ffffffffc0200bce:	06b2                	slli	a3,a3,0xc
ffffffffc0200bd0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bd2:	0732                	slli	a4,a4,0xc
ffffffffc0200bd4:	2cd77863          	bleu	a3,a4,ffffffffc0200ea4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bd8:	40f98733          	sub	a4,s3,a5
ffffffffc0200bdc:	870d                	srai	a4,a4,0x3
ffffffffc0200bde:	02b70733          	mul	a4,a4,a1
ffffffffc0200be2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200be4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200be6:	4ed77f63          	bleu	a3,a4,ffffffffc02010e4 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bea:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bee:	878d                	srai	a5,a5,0x3
ffffffffc0200bf0:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bf4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bf6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bf8:	34d7f663          	bleu	a3,a5,ffffffffc0200f44 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200bfc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bfe:	00093c03          	ld	s8,0(s2)
ffffffffc0200c02:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c06:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c0a:	00011797          	auipc	a5,0x11
ffffffffc0200c0e:	8727bb23          	sd	s2,-1930(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc0200c12:	00011797          	auipc	a5,0x11
ffffffffc0200c16:	8727b323          	sd	s2,-1946(a5) # ffffffffc0211478 <free_area>
    nr_free = 0;
ffffffffc0200c1a:	00011797          	auipc	a5,0x11
ffffffffc0200c1e:	8607a723          	sw	zero,-1938(a5) # ffffffffc0211488 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c22:	24d000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c26:	2e051f63          	bnez	a0,ffffffffc0200f24 <default_check+0x428>
    free_page(p0);
ffffffffc0200c2a:	4585                	li	a1,1
ffffffffc0200c2c:	8552                	mv	a0,s4
ffffffffc0200c2e:	2c9000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p1);
ffffffffc0200c32:	4585                	li	a1,1
ffffffffc0200c34:	854e                	mv	a0,s3
ffffffffc0200c36:	2c1000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200c3a:	4585                	li	a1,1
ffffffffc0200c3c:	8556                	mv	a0,s5
ffffffffc0200c3e:	2b9000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c42:	01092703          	lw	a4,16(s2)
ffffffffc0200c46:	478d                	li	a5,3
ffffffffc0200c48:	2af71e63          	bne	a4,a5,ffffffffc0200f04 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c4c:	4505                	li	a0,1
ffffffffc0200c4e:	221000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c52:	89aa                	mv	s3,a0
ffffffffc0200c54:	28050863          	beqz	a0,ffffffffc0200ee4 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c58:	4505                	li	a0,1
ffffffffc0200c5a:	215000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c5e:	8aaa                	mv	s5,a0
ffffffffc0200c60:	3e050263          	beqz	a0,ffffffffc0201044 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c64:	4505                	li	a0,1
ffffffffc0200c66:	209000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c6a:	8a2a                	mv	s4,a0
ffffffffc0200c6c:	3a050c63          	beqz	a0,ffffffffc0201024 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c70:	4505                	li	a0,1
ffffffffc0200c72:	1fd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c76:	38051763          	bnez	a0,ffffffffc0201004 <default_check+0x508>
    free_page(p0);
ffffffffc0200c7a:	4585                	li	a1,1
ffffffffc0200c7c:	854e                	mv	a0,s3
ffffffffc0200c7e:	279000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c82:	00893783          	ld	a5,8(s2)
ffffffffc0200c86:	23278f63          	beq	a5,s2,ffffffffc0200ec4 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200c8a:	4505                	li	a0,1
ffffffffc0200c8c:	1e3000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c90:	32a99a63          	bne	s3,a0,ffffffffc0200fc4 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200c94:	4505                	li	a0,1
ffffffffc0200c96:	1d9000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200c9a:	30051563          	bnez	a0,ffffffffc0200fa4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200c9e:	01092783          	lw	a5,16(s2)
ffffffffc0200ca2:	2e079163          	bnez	a5,ffffffffc0200f84 <default_check+0x488>
    free_page(p);
ffffffffc0200ca6:	854e                	mv	a0,s3
ffffffffc0200ca8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200caa:	00010797          	auipc	a5,0x10
ffffffffc0200cae:	7d87b723          	sd	s8,1998(a5) # ffffffffc0211478 <free_area>
ffffffffc0200cb2:	00010797          	auipc	a5,0x10
ffffffffc0200cb6:	7d77b723          	sd	s7,1998(a5) # ffffffffc0211480 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200cba:	00010797          	auipc	a5,0x10
ffffffffc0200cbe:	7d67a723          	sw	s6,1998(a5) # ffffffffc0211488 <free_area+0x10>
    free_page(p);
ffffffffc0200cc2:	235000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p1);
ffffffffc0200cc6:	4585                	li	a1,1
ffffffffc0200cc8:	8556                	mv	a0,s5
ffffffffc0200cca:	22d000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200cce:	4585                	li	a1,1
ffffffffc0200cd0:	8552                	mv	a0,s4
ffffffffc0200cd2:	225000ef          	jal	ra,ffffffffc02016f6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200cd6:	4515                	li	a0,5
ffffffffc0200cd8:	197000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200cdc:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cde:	28050363          	beqz	a0,ffffffffc0200f64 <default_check+0x468>
ffffffffc0200ce2:	651c                	ld	a5,8(a0)
ffffffffc0200ce4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ce6:	8b85                	andi	a5,a5,1
ffffffffc0200ce8:	54079e63          	bnez	a5,ffffffffc0201244 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cec:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cee:	00093b03          	ld	s6,0(s2)
ffffffffc0200cf2:	00893a83          	ld	s5,8(s2)
ffffffffc0200cf6:	00010797          	auipc	a5,0x10
ffffffffc0200cfa:	7927b123          	sd	s2,1922(a5) # ffffffffc0211478 <free_area>
ffffffffc0200cfe:	00010797          	auipc	a5,0x10
ffffffffc0200d02:	7927b123          	sd	s2,1922(a5) # ffffffffc0211480 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d06:	169000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d0a:	50051d63          	bnez	a0,ffffffffc0201224 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d0e:	09098a13          	addi	s4,s3,144
ffffffffc0200d12:	8552                	mv	a0,s4
ffffffffc0200d14:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d16:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d1a:	00010797          	auipc	a5,0x10
ffffffffc0200d1e:	7607a723          	sw	zero,1902(a5) # ffffffffc0211488 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d22:	1d5000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d26:	4511                	li	a0,4
ffffffffc0200d28:	147000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d2c:	4c051c63          	bnez	a0,ffffffffc0201204 <default_check+0x708>
ffffffffc0200d30:	0989b783          	ld	a5,152(s3)
ffffffffc0200d34:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d36:	8b85                	andi	a5,a5,1
ffffffffc0200d38:	4a078663          	beqz	a5,ffffffffc02011e4 <default_check+0x6e8>
ffffffffc0200d3c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d40:	478d                	li	a5,3
ffffffffc0200d42:	4af71163          	bne	a4,a5,ffffffffc02011e4 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d46:	450d                	li	a0,3
ffffffffc0200d48:	127000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d4c:	8c2a                	mv	s8,a0
ffffffffc0200d4e:	46050b63          	beqz	a0,ffffffffc02011c4 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d52:	4505                	li	a0,1
ffffffffc0200d54:	11b000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200d58:	44051663          	bnez	a0,ffffffffc02011a4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d5c:	438a1463          	bne	s4,s8,ffffffffc0201184 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d60:	4585                	li	a1,1
ffffffffc0200d62:	854e                	mv	a0,s3
ffffffffc0200d64:	193000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d68:	458d                	li	a1,3
ffffffffc0200d6a:	8552                	mv	a0,s4
ffffffffc0200d6c:	18b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0200d70:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d74:	04898c13          	addi	s8,s3,72
ffffffffc0200d78:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d7a:	8b85                	andi	a5,a5,1
ffffffffc0200d7c:	3e078463          	beqz	a5,ffffffffc0201164 <default_check+0x668>
ffffffffc0200d80:	0189a703          	lw	a4,24(s3)
ffffffffc0200d84:	4785                	li	a5,1
ffffffffc0200d86:	3cf71f63          	bne	a4,a5,ffffffffc0201164 <default_check+0x668>
ffffffffc0200d8a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d8e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d90:	8b85                	andi	a5,a5,1
ffffffffc0200d92:	3a078963          	beqz	a5,ffffffffc0201144 <default_check+0x648>
ffffffffc0200d96:	018a2703          	lw	a4,24(s4)
ffffffffc0200d9a:	478d                	li	a5,3
ffffffffc0200d9c:	3af71463          	bne	a4,a5,ffffffffc0201144 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200da0:	4505                	li	a0,1
ffffffffc0200da2:	0cd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200da6:	36a99f63          	bne	s3,a0,ffffffffc0201124 <default_check+0x628>
    free_page(p0);
ffffffffc0200daa:	4585                	li	a1,1
ffffffffc0200dac:	14b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200db0:	4509                	li	a0,2
ffffffffc0200db2:	0bd000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200db6:	34aa1763          	bne	s4,a0,ffffffffc0201104 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200dba:	4589                	li	a1,2
ffffffffc0200dbc:	13b000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    free_page(p2);
ffffffffc0200dc0:	4585                	li	a1,1
ffffffffc0200dc2:	8562                	mv	a0,s8
ffffffffc0200dc4:	133000ef          	jal	ra,ffffffffc02016f6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200dc8:	4515                	li	a0,5
ffffffffc0200dca:	0a5000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200dce:	89aa                	mv	s3,a0
ffffffffc0200dd0:	48050a63          	beqz	a0,ffffffffc0201264 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200dd4:	4505                	li	a0,1
ffffffffc0200dd6:	099000ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0200dda:	2e051563          	bnez	a0,ffffffffc02010c4 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200dde:	01092783          	lw	a5,16(s2)
ffffffffc0200de2:	2c079163          	bnez	a5,ffffffffc02010a4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200de6:	4595                	li	a1,5
ffffffffc0200de8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dea:	00010797          	auipc	a5,0x10
ffffffffc0200dee:	6977af23          	sw	s7,1694(a5) # ffffffffc0211488 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200df2:	00010797          	auipc	a5,0x10
ffffffffc0200df6:	6967b323          	sd	s6,1670(a5) # ffffffffc0211478 <free_area>
ffffffffc0200dfa:	00010797          	auipc	a5,0x10
ffffffffc0200dfe:	6957b323          	sd	s5,1670(a5) # ffffffffc0211480 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e02:	0f5000ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return listelm->next;
ffffffffc0200e06:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e0a:	01278963          	beq	a5,s2,ffffffffc0200e1c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e12:	679c                	ld	a5,8(a5)
ffffffffc0200e14:	34fd                	addiw	s1,s1,-1
ffffffffc0200e16:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e18:	ff279be3          	bne	a5,s2,ffffffffc0200e0e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e1c:	26049463          	bnez	s1,ffffffffc0201084 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e20:	46041263          	bnez	s0,ffffffffc0201284 <default_check+0x788>
}
ffffffffc0200e24:	60a6                	ld	ra,72(sp)
ffffffffc0200e26:	6406                	ld	s0,64(sp)
ffffffffc0200e28:	74e2                	ld	s1,56(sp)
ffffffffc0200e2a:	7942                	ld	s2,48(sp)
ffffffffc0200e2c:	79a2                	ld	s3,40(sp)
ffffffffc0200e2e:	7a02                	ld	s4,32(sp)
ffffffffc0200e30:	6ae2                	ld	s5,24(sp)
ffffffffc0200e32:	6b42                	ld	s6,16(sp)
ffffffffc0200e34:	6ba2                	ld	s7,8(sp)
ffffffffc0200e36:	6c02                	ld	s8,0(sp)
ffffffffc0200e38:	6161                	addi	sp,sp,80
ffffffffc0200e3a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e3e:	4401                	li	s0,0
ffffffffc0200e40:	4481                	li	s1,0
ffffffffc0200e42:	b331                	j	ffffffffc0200b4e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e44:	00004697          	auipc	a3,0x4
ffffffffc0200e48:	d0468693          	addi	a3,a3,-764 # ffffffffc0204b48 <commands+0x860>
ffffffffc0200e4c:	00004617          	auipc	a2,0x4
ffffffffc0200e50:	d0c60613          	addi	a2,a2,-756 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200e54:	0f000593          	li	a1,240
ffffffffc0200e58:	00004517          	auipc	a0,0x4
ffffffffc0200e5c:	d1850513          	addi	a0,a0,-744 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200e60:	d14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e64:	00004697          	auipc	a3,0x4
ffffffffc0200e68:	da468693          	addi	a3,a3,-604 # ffffffffc0204c08 <commands+0x920>
ffffffffc0200e6c:	00004617          	auipc	a2,0x4
ffffffffc0200e70:	cec60613          	addi	a2,a2,-788 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200e74:	0bd00593          	li	a1,189
ffffffffc0200e78:	00004517          	auipc	a0,0x4
ffffffffc0200e7c:	cf850513          	addi	a0,a0,-776 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200e80:	cf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e84:	00004697          	auipc	a3,0x4
ffffffffc0200e88:	dac68693          	addi	a3,a3,-596 # ffffffffc0204c30 <commands+0x948>
ffffffffc0200e8c:	00004617          	auipc	a2,0x4
ffffffffc0200e90:	ccc60613          	addi	a2,a2,-820 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200e94:	0be00593          	li	a1,190
ffffffffc0200e98:	00004517          	auipc	a0,0x4
ffffffffc0200e9c:	cd850513          	addi	a0,a0,-808 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200ea0:	cd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ea4:	00004697          	auipc	a3,0x4
ffffffffc0200ea8:	dcc68693          	addi	a3,a3,-564 # ffffffffc0204c70 <commands+0x988>
ffffffffc0200eac:	00004617          	auipc	a2,0x4
ffffffffc0200eb0:	cac60613          	addi	a2,a2,-852 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200eb4:	0c000593          	li	a1,192
ffffffffc0200eb8:	00004517          	auipc	a0,0x4
ffffffffc0200ebc:	cb850513          	addi	a0,a0,-840 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200ec0:	cb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ec4:	00004697          	auipc	a3,0x4
ffffffffc0200ec8:	e3468693          	addi	a3,a3,-460 # ffffffffc0204cf8 <commands+0xa10>
ffffffffc0200ecc:	00004617          	auipc	a2,0x4
ffffffffc0200ed0:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200ed4:	0d900593          	li	a1,217
ffffffffc0200ed8:	00004517          	auipc	a0,0x4
ffffffffc0200edc:	c9850513          	addi	a0,a0,-872 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200ee0:	c94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ee4:	00004697          	auipc	a3,0x4
ffffffffc0200ee8:	cc468693          	addi	a3,a3,-828 # ffffffffc0204ba8 <commands+0x8c0>
ffffffffc0200eec:	00004617          	auipc	a2,0x4
ffffffffc0200ef0:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200ef4:	0d200593          	li	a1,210
ffffffffc0200ef8:	00004517          	auipc	a0,0x4
ffffffffc0200efc:	c7850513          	addi	a0,a0,-904 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200f00:	c74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200f04:	00004697          	auipc	a3,0x4
ffffffffc0200f08:	de468693          	addi	a3,a3,-540 # ffffffffc0204ce8 <commands+0xa00>
ffffffffc0200f0c:	00004617          	auipc	a2,0x4
ffffffffc0200f10:	c4c60613          	addi	a2,a2,-948 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200f14:	0d000593          	li	a1,208
ffffffffc0200f18:	00004517          	auipc	a0,0x4
ffffffffc0200f1c:	c5850513          	addi	a0,a0,-936 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200f20:	c54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f24:	00004697          	auipc	a3,0x4
ffffffffc0200f28:	dac68693          	addi	a3,a3,-596 # ffffffffc0204cd0 <commands+0x9e8>
ffffffffc0200f2c:	00004617          	auipc	a2,0x4
ffffffffc0200f30:	c2c60613          	addi	a2,a2,-980 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200f34:	0cb00593          	li	a1,203
ffffffffc0200f38:	00004517          	auipc	a0,0x4
ffffffffc0200f3c:	c3850513          	addi	a0,a0,-968 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200f40:	c34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f44:	00004697          	auipc	a3,0x4
ffffffffc0200f48:	d6c68693          	addi	a3,a3,-660 # ffffffffc0204cb0 <commands+0x9c8>
ffffffffc0200f4c:	00004617          	auipc	a2,0x4
ffffffffc0200f50:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200f54:	0c200593          	li	a1,194
ffffffffc0200f58:	00004517          	auipc	a0,0x4
ffffffffc0200f5c:	c1850513          	addi	a0,a0,-1000 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200f60:	c14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f64:	00004697          	auipc	a3,0x4
ffffffffc0200f68:	ddc68693          	addi	a3,a3,-548 # ffffffffc0204d40 <commands+0xa58>
ffffffffc0200f6c:	00004617          	auipc	a2,0x4
ffffffffc0200f70:	bec60613          	addi	a2,a2,-1044 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200f74:	0f800593          	li	a1,248
ffffffffc0200f78:	00004517          	auipc	a0,0x4
ffffffffc0200f7c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200f80:	bf4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f84:	00004697          	auipc	a3,0x4
ffffffffc0200f88:	dac68693          	addi	a3,a3,-596 # ffffffffc0204d30 <commands+0xa48>
ffffffffc0200f8c:	00004617          	auipc	a2,0x4
ffffffffc0200f90:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200f94:	0df00593          	li	a1,223
ffffffffc0200f98:	00004517          	auipc	a0,0x4
ffffffffc0200f9c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200fa0:	bd4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa4:	00004697          	auipc	a3,0x4
ffffffffc0200fa8:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204cd0 <commands+0x9e8>
ffffffffc0200fac:	00004617          	auipc	a2,0x4
ffffffffc0200fb0:	bac60613          	addi	a2,a2,-1108 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200fb4:	0dd00593          	li	a1,221
ffffffffc0200fb8:	00004517          	auipc	a0,0x4
ffffffffc0200fbc:	bb850513          	addi	a0,a0,-1096 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200fc0:	bb4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fc4:	00004697          	auipc	a3,0x4
ffffffffc0200fc8:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204d10 <commands+0xa28>
ffffffffc0200fcc:	00004617          	auipc	a2,0x4
ffffffffc0200fd0:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200fd4:	0dc00593          	li	a1,220
ffffffffc0200fd8:	00004517          	auipc	a0,0x4
ffffffffc0200fdc:	b9850513          	addi	a0,a0,-1128 # ffffffffc0204b70 <commands+0x888>
ffffffffc0200fe0:	b94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fe4:	00004697          	auipc	a3,0x4
ffffffffc0200fe8:	bc468693          	addi	a3,a3,-1084 # ffffffffc0204ba8 <commands+0x8c0>
ffffffffc0200fec:	00004617          	auipc	a2,0x4
ffffffffc0200ff0:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0204b58 <commands+0x870>
ffffffffc0200ff4:	0b900593          	li	a1,185
ffffffffc0200ff8:	00004517          	auipc	a0,0x4
ffffffffc0200ffc:	b7850513          	addi	a0,a0,-1160 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201000:	b74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201004:	00004697          	auipc	a3,0x4
ffffffffc0201008:	ccc68693          	addi	a3,a3,-820 # ffffffffc0204cd0 <commands+0x9e8>
ffffffffc020100c:	00004617          	auipc	a2,0x4
ffffffffc0201010:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201014:	0d600593          	li	a1,214
ffffffffc0201018:	00004517          	auipc	a0,0x4
ffffffffc020101c:	b5850513          	addi	a0,a0,-1192 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201020:	b54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201024:	00004697          	auipc	a3,0x4
ffffffffc0201028:	bc468693          	addi	a3,a3,-1084 # ffffffffc0204be8 <commands+0x900>
ffffffffc020102c:	00004617          	auipc	a2,0x4
ffffffffc0201030:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201034:	0d400593          	li	a1,212
ffffffffc0201038:	00004517          	auipc	a0,0x4
ffffffffc020103c:	b3850513          	addi	a0,a0,-1224 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201040:	b34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201044:	00004697          	auipc	a3,0x4
ffffffffc0201048:	b8468693          	addi	a3,a3,-1148 # ffffffffc0204bc8 <commands+0x8e0>
ffffffffc020104c:	00004617          	auipc	a2,0x4
ffffffffc0201050:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201054:	0d300593          	li	a1,211
ffffffffc0201058:	00004517          	auipc	a0,0x4
ffffffffc020105c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201060:	b14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201064:	00004697          	auipc	a3,0x4
ffffffffc0201068:	b8468693          	addi	a3,a3,-1148 # ffffffffc0204be8 <commands+0x900>
ffffffffc020106c:	00004617          	auipc	a2,0x4
ffffffffc0201070:	aec60613          	addi	a2,a2,-1300 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201074:	0bb00593          	li	a1,187
ffffffffc0201078:	00004517          	auipc	a0,0x4
ffffffffc020107c:	af850513          	addi	a0,a0,-1288 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201080:	af4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201084:	00004697          	auipc	a3,0x4
ffffffffc0201088:	e0c68693          	addi	a3,a3,-500 # ffffffffc0204e90 <commands+0xba8>
ffffffffc020108c:	00004617          	auipc	a2,0x4
ffffffffc0201090:	acc60613          	addi	a2,a2,-1332 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201094:	12500593          	li	a1,293
ffffffffc0201098:	00004517          	auipc	a0,0x4
ffffffffc020109c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204b70 <commands+0x888>
ffffffffc02010a0:	ad4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc02010a4:	00004697          	auipc	a3,0x4
ffffffffc02010a8:	c8c68693          	addi	a3,a3,-884 # ffffffffc0204d30 <commands+0xa48>
ffffffffc02010ac:	00004617          	auipc	a2,0x4
ffffffffc02010b0:	aac60613          	addi	a2,a2,-1364 # ffffffffc0204b58 <commands+0x870>
ffffffffc02010b4:	11a00593          	li	a1,282
ffffffffc02010b8:	00004517          	auipc	a0,0x4
ffffffffc02010bc:	ab850513          	addi	a0,a0,-1352 # ffffffffc0204b70 <commands+0x888>
ffffffffc02010c0:	ab4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010c4:	00004697          	auipc	a3,0x4
ffffffffc02010c8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0204cd0 <commands+0x9e8>
ffffffffc02010cc:	00004617          	auipc	a2,0x4
ffffffffc02010d0:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0204b58 <commands+0x870>
ffffffffc02010d4:	11800593          	li	a1,280
ffffffffc02010d8:	00004517          	auipc	a0,0x4
ffffffffc02010dc:	a9850513          	addi	a0,a0,-1384 # ffffffffc0204b70 <commands+0x888>
ffffffffc02010e0:	a94ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010e4:	00004697          	auipc	a3,0x4
ffffffffc02010e8:	bac68693          	addi	a3,a3,-1108 # ffffffffc0204c90 <commands+0x9a8>
ffffffffc02010ec:	00004617          	auipc	a2,0x4
ffffffffc02010f0:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0204b58 <commands+0x870>
ffffffffc02010f4:	0c100593          	li	a1,193
ffffffffc02010f8:	00004517          	auipc	a0,0x4
ffffffffc02010fc:	a7850513          	addi	a0,a0,-1416 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201100:	a74ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201104:	00004697          	auipc	a3,0x4
ffffffffc0201108:	d4c68693          	addi	a3,a3,-692 # ffffffffc0204e50 <commands+0xb68>
ffffffffc020110c:	00004617          	auipc	a2,0x4
ffffffffc0201110:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201114:	11200593          	li	a1,274
ffffffffc0201118:	00004517          	auipc	a0,0x4
ffffffffc020111c:	a5850513          	addi	a0,a0,-1448 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201120:	a54ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201124:	00004697          	auipc	a3,0x4
ffffffffc0201128:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204e30 <commands+0xb48>
ffffffffc020112c:	00004617          	auipc	a2,0x4
ffffffffc0201130:	a2c60613          	addi	a2,a2,-1492 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201134:	11000593          	li	a1,272
ffffffffc0201138:	00004517          	auipc	a0,0x4
ffffffffc020113c:	a3850513          	addi	a0,a0,-1480 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201140:	a34ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201144:	00004697          	auipc	a3,0x4
ffffffffc0201148:	cc468693          	addi	a3,a3,-828 # ffffffffc0204e08 <commands+0xb20>
ffffffffc020114c:	00004617          	auipc	a2,0x4
ffffffffc0201150:	a0c60613          	addi	a2,a2,-1524 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201154:	10e00593          	li	a1,270
ffffffffc0201158:	00004517          	auipc	a0,0x4
ffffffffc020115c:	a1850513          	addi	a0,a0,-1512 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201160:	a14ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201164:	00004697          	auipc	a3,0x4
ffffffffc0201168:	c7c68693          	addi	a3,a3,-900 # ffffffffc0204de0 <commands+0xaf8>
ffffffffc020116c:	00004617          	auipc	a2,0x4
ffffffffc0201170:	9ec60613          	addi	a2,a2,-1556 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201174:	10d00593          	li	a1,269
ffffffffc0201178:	00004517          	auipc	a0,0x4
ffffffffc020117c:	9f850513          	addi	a0,a0,-1544 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201180:	9f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201184:	00004697          	auipc	a3,0x4
ffffffffc0201188:	c4c68693          	addi	a3,a3,-948 # ffffffffc0204dd0 <commands+0xae8>
ffffffffc020118c:	00004617          	auipc	a2,0x4
ffffffffc0201190:	9cc60613          	addi	a2,a2,-1588 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201194:	10800593          	li	a1,264
ffffffffc0201198:	00004517          	auipc	a0,0x4
ffffffffc020119c:	9d850513          	addi	a0,a0,-1576 # ffffffffc0204b70 <commands+0x888>
ffffffffc02011a0:	9d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011a4:	00004697          	auipc	a3,0x4
ffffffffc02011a8:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0204cd0 <commands+0x9e8>
ffffffffc02011ac:	00004617          	auipc	a2,0x4
ffffffffc02011b0:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0204b58 <commands+0x870>
ffffffffc02011b4:	10700593          	li	a1,263
ffffffffc02011b8:	00004517          	auipc	a0,0x4
ffffffffc02011bc:	9b850513          	addi	a0,a0,-1608 # ffffffffc0204b70 <commands+0x888>
ffffffffc02011c0:	9b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011c4:	00004697          	auipc	a3,0x4
ffffffffc02011c8:	bec68693          	addi	a3,a3,-1044 # ffffffffc0204db0 <commands+0xac8>
ffffffffc02011cc:	00004617          	auipc	a2,0x4
ffffffffc02011d0:	98c60613          	addi	a2,a2,-1652 # ffffffffc0204b58 <commands+0x870>
ffffffffc02011d4:	10600593          	li	a1,262
ffffffffc02011d8:	00004517          	auipc	a0,0x4
ffffffffc02011dc:	99850513          	addi	a0,a0,-1640 # ffffffffc0204b70 <commands+0x888>
ffffffffc02011e0:	994ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011e4:	00004697          	auipc	a3,0x4
ffffffffc02011e8:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0204d80 <commands+0xa98>
ffffffffc02011ec:	00004617          	auipc	a2,0x4
ffffffffc02011f0:	96c60613          	addi	a2,a2,-1684 # ffffffffc0204b58 <commands+0x870>
ffffffffc02011f4:	10500593          	li	a1,261
ffffffffc02011f8:	00004517          	auipc	a0,0x4
ffffffffc02011fc:	97850513          	addi	a0,a0,-1672 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201200:	974ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201204:	00004697          	auipc	a3,0x4
ffffffffc0201208:	b6468693          	addi	a3,a3,-1180 # ffffffffc0204d68 <commands+0xa80>
ffffffffc020120c:	00004617          	auipc	a2,0x4
ffffffffc0201210:	94c60613          	addi	a2,a2,-1716 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201214:	10400593          	li	a1,260
ffffffffc0201218:	00004517          	auipc	a0,0x4
ffffffffc020121c:	95850513          	addi	a0,a0,-1704 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201220:	954ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201224:	00004697          	auipc	a3,0x4
ffffffffc0201228:	aac68693          	addi	a3,a3,-1364 # ffffffffc0204cd0 <commands+0x9e8>
ffffffffc020122c:	00004617          	auipc	a2,0x4
ffffffffc0201230:	92c60613          	addi	a2,a2,-1748 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201234:	0fe00593          	li	a1,254
ffffffffc0201238:	00004517          	auipc	a0,0x4
ffffffffc020123c:	93850513          	addi	a0,a0,-1736 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201240:	934ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201244:	00004697          	auipc	a3,0x4
ffffffffc0201248:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0204d50 <commands+0xa68>
ffffffffc020124c:	00004617          	auipc	a2,0x4
ffffffffc0201250:	90c60613          	addi	a2,a2,-1780 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201254:	0f900593          	li	a1,249
ffffffffc0201258:	00004517          	auipc	a0,0x4
ffffffffc020125c:	91850513          	addi	a0,a0,-1768 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201260:	914ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201264:	00004697          	auipc	a3,0x4
ffffffffc0201268:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0204e70 <commands+0xb88>
ffffffffc020126c:	00004617          	auipc	a2,0x4
ffffffffc0201270:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201274:	11700593          	li	a1,279
ffffffffc0201278:	00004517          	auipc	a0,0x4
ffffffffc020127c:	8f850513          	addi	a0,a0,-1800 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201280:	8f4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201284:	00004697          	auipc	a3,0x4
ffffffffc0201288:	c1c68693          	addi	a3,a3,-996 # ffffffffc0204ea0 <commands+0xbb8>
ffffffffc020128c:	00004617          	auipc	a2,0x4
ffffffffc0201290:	8cc60613          	addi	a2,a2,-1844 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201294:	12600593          	li	a1,294
ffffffffc0201298:	00004517          	auipc	a0,0x4
ffffffffc020129c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0204b70 <commands+0x888>
ffffffffc02012a0:	8d4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012a4:	00004697          	auipc	a3,0x4
ffffffffc02012a8:	8e468693          	addi	a3,a3,-1820 # ffffffffc0204b88 <commands+0x8a0>
ffffffffc02012ac:	00004617          	auipc	a2,0x4
ffffffffc02012b0:	8ac60613          	addi	a2,a2,-1876 # ffffffffc0204b58 <commands+0x870>
ffffffffc02012b4:	0f300593          	li	a1,243
ffffffffc02012b8:	00004517          	auipc	a0,0x4
ffffffffc02012bc:	8b850513          	addi	a0,a0,-1864 # ffffffffc0204b70 <commands+0x888>
ffffffffc02012c0:	8b4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012c4:	00004697          	auipc	a3,0x4
ffffffffc02012c8:	90468693          	addi	a3,a3,-1788 # ffffffffc0204bc8 <commands+0x8e0>
ffffffffc02012cc:	00004617          	auipc	a2,0x4
ffffffffc02012d0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0204b58 <commands+0x870>
ffffffffc02012d4:	0ba00593          	li	a1,186
ffffffffc02012d8:	00004517          	auipc	a0,0x4
ffffffffc02012dc:	89850513          	addi	a0,a0,-1896 # ffffffffc0204b70 <commands+0x888>
ffffffffc02012e0:	894ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02012e4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012e4:	1141                	addi	sp,sp,-16
ffffffffc02012e6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012e8:	18058063          	beqz	a1,ffffffffc0201468 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02012ec:	00359693          	slli	a3,a1,0x3
ffffffffc02012f0:	96ae                	add	a3,a3,a1
ffffffffc02012f2:	068e                	slli	a3,a3,0x3
ffffffffc02012f4:	96aa                	add	a3,a3,a0
ffffffffc02012f6:	02d50d63          	beq	a0,a3,ffffffffc0201330 <default_free_pages+0x4c>
ffffffffc02012fa:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012fc:	8b85                	andi	a5,a5,1
ffffffffc02012fe:	14079563          	bnez	a5,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc0201302:	651c                	ld	a5,8(a0)
ffffffffc0201304:	8385                	srli	a5,a5,0x1
ffffffffc0201306:	8b85                	andi	a5,a5,1
ffffffffc0201308:	14079063          	bnez	a5,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc020130c:	87aa                	mv	a5,a0
ffffffffc020130e:	a809                	j	ffffffffc0201320 <default_free_pages+0x3c>
ffffffffc0201310:	6798                	ld	a4,8(a5)
ffffffffc0201312:	8b05                	andi	a4,a4,1
ffffffffc0201314:	12071a63          	bnez	a4,ffffffffc0201448 <default_free_pages+0x164>
ffffffffc0201318:	6798                	ld	a4,8(a5)
ffffffffc020131a:	8b09                	andi	a4,a4,2
ffffffffc020131c:	12071663          	bnez	a4,ffffffffc0201448 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201320:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201324:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201328:	04878793          	addi	a5,a5,72
ffffffffc020132c:	fed792e3          	bne	a5,a3,ffffffffc0201310 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201330:	2581                	sext.w	a1,a1
ffffffffc0201332:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201334:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201338:	4789                	li	a5,2
ffffffffc020133a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020133e:	00010697          	auipc	a3,0x10
ffffffffc0201342:	13a68693          	addi	a3,a3,314 # ffffffffc0211478 <free_area>
ffffffffc0201346:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201348:	669c                	ld	a5,8(a3)
ffffffffc020134a:	9db9                	addw	a1,a1,a4
ffffffffc020134c:	00010717          	auipc	a4,0x10
ffffffffc0201350:	12b72e23          	sw	a1,316(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201354:	08d78f63          	beq	a5,a3,ffffffffc02013f2 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201358:	fe078713          	addi	a4,a5,-32
ffffffffc020135c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020135e:	4801                	li	a6,0
ffffffffc0201360:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201364:	00e56a63          	bltu	a0,a4,ffffffffc0201378 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201368:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020136a:	02d70563          	beq	a4,a3,ffffffffc0201394 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201370:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201374:	fee57ae3          	bleu	a4,a0,ffffffffc0201368 <default_free_pages+0x84>
ffffffffc0201378:	00080663          	beqz	a6,ffffffffc0201384 <default_free_pages+0xa0>
ffffffffc020137c:	00010817          	auipc	a6,0x10
ffffffffc0201380:	0eb83e23          	sd	a1,252(a6) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201384:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201386:	e390                	sd	a2,0(a5)
ffffffffc0201388:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020138a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020138c:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020138e:	02d59163          	bne	a1,a3,ffffffffc02013b0 <default_free_pages+0xcc>
ffffffffc0201392:	a091                	j	ffffffffc02013d6 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201394:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201396:	f514                	sd	a3,40(a0)
ffffffffc0201398:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020139a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020139c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020139e:	00d70563          	beq	a4,a3,ffffffffc02013a8 <default_free_pages+0xc4>
ffffffffc02013a2:	4805                	li	a6,1
ffffffffc02013a4:	87ba                	mv	a5,a4
ffffffffc02013a6:	b7e9                	j	ffffffffc0201370 <default_free_pages+0x8c>
ffffffffc02013a8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013aa:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013ac:	02d78163          	beq	a5,a3,ffffffffc02013ce <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02013b0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02013b4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02013b8:	02081713          	slli	a4,a6,0x20
ffffffffc02013bc:	9301                	srli	a4,a4,0x20
ffffffffc02013be:	00371793          	slli	a5,a4,0x3
ffffffffc02013c2:	97ba                	add	a5,a5,a4
ffffffffc02013c4:	078e                	slli	a5,a5,0x3
ffffffffc02013c6:	97b2                	add	a5,a5,a2
ffffffffc02013c8:	02f50e63          	beq	a0,a5,ffffffffc0201404 <default_free_pages+0x120>
ffffffffc02013cc:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02013ce:	fe078713          	addi	a4,a5,-32
ffffffffc02013d2:	00d78d63          	beq	a5,a3,ffffffffc02013ec <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02013d6:	4d0c                	lw	a1,24(a0)
ffffffffc02013d8:	02059613          	slli	a2,a1,0x20
ffffffffc02013dc:	9201                	srli	a2,a2,0x20
ffffffffc02013de:	00361693          	slli	a3,a2,0x3
ffffffffc02013e2:	96b2                	add	a3,a3,a2
ffffffffc02013e4:	068e                	slli	a3,a3,0x3
ffffffffc02013e6:	96aa                	add	a3,a3,a0
ffffffffc02013e8:	04d70063          	beq	a4,a3,ffffffffc0201428 <default_free_pages+0x144>
}
ffffffffc02013ec:	60a2                	ld	ra,8(sp)
ffffffffc02013ee:	0141                	addi	sp,sp,16
ffffffffc02013f0:	8082                	ret
ffffffffc02013f2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013f4:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02013f8:	e398                	sd	a4,0(a5)
ffffffffc02013fa:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013fc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013fe:	f11c                	sd	a5,32(a0)
}
ffffffffc0201400:	0141                	addi	sp,sp,16
ffffffffc0201402:	8082                	ret
            p->property += base->property;
ffffffffc0201404:	4d1c                	lw	a5,24(a0)
ffffffffc0201406:	0107883b          	addw	a6,a5,a6
ffffffffc020140a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020140e:	57f5                	li	a5,-3
ffffffffc0201410:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201414:	02053803          	ld	a6,32(a0)
ffffffffc0201418:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020141a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020141c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201420:	659c                	ld	a5,8(a1)
ffffffffc0201422:	01073023          	sd	a6,0(a4)
ffffffffc0201426:	b765                	j	ffffffffc02013ce <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201428:	ff87a703          	lw	a4,-8(a5)
ffffffffc020142c:	fe878693          	addi	a3,a5,-24
ffffffffc0201430:	9db9                	addw	a1,a1,a4
ffffffffc0201432:	cd0c                	sw	a1,24(a0)
ffffffffc0201434:	5775                	li	a4,-3
ffffffffc0201436:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020143a:	6398                	ld	a4,0(a5)
ffffffffc020143c:	679c                	ld	a5,8(a5)
}
ffffffffc020143e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201440:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201442:	e398                	sd	a4,0(a5)
ffffffffc0201444:	0141                	addi	sp,sp,16
ffffffffc0201446:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201448:	00004697          	auipc	a3,0x4
ffffffffc020144c:	a6868693          	addi	a3,a3,-1432 # ffffffffc0204eb0 <commands+0xbc8>
ffffffffc0201450:	00003617          	auipc	a2,0x3
ffffffffc0201454:	70860613          	addi	a2,a2,1800 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201458:	08300593          	li	a1,131
ffffffffc020145c:	00003517          	auipc	a0,0x3
ffffffffc0201460:	71450513          	addi	a0,a0,1812 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201464:	f11fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201468:	00004697          	auipc	a3,0x4
ffffffffc020146c:	a7068693          	addi	a3,a3,-1424 # ffffffffc0204ed8 <commands+0xbf0>
ffffffffc0201470:	00003617          	auipc	a2,0x3
ffffffffc0201474:	6e860613          	addi	a2,a2,1768 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201478:	08000593          	li	a1,128
ffffffffc020147c:	00003517          	auipc	a0,0x3
ffffffffc0201480:	6f450513          	addi	a0,a0,1780 # ffffffffc0204b70 <commands+0x888>
ffffffffc0201484:	ef1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201488 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201488:	cd51                	beqz	a0,ffffffffc0201524 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020148a:	00010597          	auipc	a1,0x10
ffffffffc020148e:	fee58593          	addi	a1,a1,-18 # ffffffffc0211478 <free_area>
ffffffffc0201492:	0105a803          	lw	a6,16(a1)
ffffffffc0201496:	862a                	mv	a2,a0
ffffffffc0201498:	02081793          	slli	a5,a6,0x20
ffffffffc020149c:	9381                	srli	a5,a5,0x20
ffffffffc020149e:	00a7ee63          	bltu	a5,a0,ffffffffc02014ba <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014a2:	87ae                	mv	a5,a1
ffffffffc02014a4:	a801                	j	ffffffffc02014b4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014a6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014aa:	02071693          	slli	a3,a4,0x20
ffffffffc02014ae:	9281                	srli	a3,a3,0x20
ffffffffc02014b0:	00c6f763          	bleu	a2,a3,ffffffffc02014be <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014b4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014b6:	feb798e3          	bne	a5,a1,ffffffffc02014a6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014ba:	4501                	li	a0,0
}
ffffffffc02014bc:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02014be:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02014c2:	dd6d                	beqz	a0,ffffffffc02014bc <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02014c4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014c8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02014cc:	00060e1b          	sext.w	t3,a2
ffffffffc02014d0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014d4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014d8:	02d67b63          	bleu	a3,a2,ffffffffc020150e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02014dc:	00361693          	slli	a3,a2,0x3
ffffffffc02014e0:	96b2                	add	a3,a3,a2
ffffffffc02014e2:	068e                	slli	a3,a3,0x3
ffffffffc02014e4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02014e6:	41c7073b          	subw	a4,a4,t3
ffffffffc02014ea:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014ec:	00868613          	addi	a2,a3,8
ffffffffc02014f0:	4709                	li	a4,2
ffffffffc02014f2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014f6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014fa:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02014fe:	0105a803          	lw	a6,16(a1)
ffffffffc0201502:	e310                	sd	a2,0(a4)
ffffffffc0201504:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201508:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020150a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020150e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201512:	00010717          	auipc	a4,0x10
ffffffffc0201516:	f7072b23          	sw	a6,-138(a4) # ffffffffc0211488 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020151a:	5775                	li	a4,-3
ffffffffc020151c:	17a1                	addi	a5,a5,-24
ffffffffc020151e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201522:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201524:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201526:	00004697          	auipc	a3,0x4
ffffffffc020152a:	9b268693          	addi	a3,a3,-1614 # ffffffffc0204ed8 <commands+0xbf0>
ffffffffc020152e:	00003617          	auipc	a2,0x3
ffffffffc0201532:	62a60613          	addi	a2,a2,1578 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201536:	06200593          	li	a1,98
ffffffffc020153a:	00003517          	auipc	a0,0x3
ffffffffc020153e:	63650513          	addi	a0,a0,1590 # ffffffffc0204b70 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201542:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201544:	e31fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201548 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201548:	1141                	addi	sp,sp,-16
ffffffffc020154a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020154c:	c1fd                	beqz	a1,ffffffffc0201632 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020154e:	00359693          	slli	a3,a1,0x3
ffffffffc0201552:	96ae                	add	a3,a3,a1
ffffffffc0201554:	068e                	slli	a3,a3,0x3
ffffffffc0201556:	96aa                	add	a3,a3,a0
ffffffffc0201558:	02d50463          	beq	a0,a3,ffffffffc0201580 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020155c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020155e:	87aa                	mv	a5,a0
ffffffffc0201560:	8b05                	andi	a4,a4,1
ffffffffc0201562:	e709                	bnez	a4,ffffffffc020156c <default_init_memmap+0x24>
ffffffffc0201564:	a07d                	j	ffffffffc0201612 <default_init_memmap+0xca>
ffffffffc0201566:	6798                	ld	a4,8(a5)
ffffffffc0201568:	8b05                	andi	a4,a4,1
ffffffffc020156a:	c745                	beqz	a4,ffffffffc0201612 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020156c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201570:	0007b423          	sd	zero,8(a5)
ffffffffc0201574:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201578:	04878793          	addi	a5,a5,72
ffffffffc020157c:	fed795e3          	bne	a5,a3,ffffffffc0201566 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201580:	2581                	sext.w	a1,a1
ffffffffc0201582:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201584:	4789                	li	a5,2
ffffffffc0201586:	00850713          	addi	a4,a0,8
ffffffffc020158a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020158e:	00010697          	auipc	a3,0x10
ffffffffc0201592:	eea68693          	addi	a3,a3,-278 # ffffffffc0211478 <free_area>
ffffffffc0201596:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201598:	669c                	ld	a5,8(a3)
ffffffffc020159a:	9db9                	addw	a1,a1,a4
ffffffffc020159c:	00010717          	auipc	a4,0x10
ffffffffc02015a0:	eeb72623          	sw	a1,-276(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015a4:	04d78a63          	beq	a5,a3,ffffffffc02015f8 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015a8:	fe078713          	addi	a4,a5,-32
ffffffffc02015ac:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015ae:	4801                	li	a6,0
ffffffffc02015b0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02015b4:	00e56a63          	bltu	a0,a4,ffffffffc02015c8 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02015b8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015ba:	02d70563          	beq	a4,a3,ffffffffc02015e4 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015be:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015c0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02015c4:	fee57ae3          	bleu	a4,a0,ffffffffc02015b8 <default_init_memmap+0x70>
ffffffffc02015c8:	00080663          	beqz	a6,ffffffffc02015d4 <default_init_memmap+0x8c>
ffffffffc02015cc:	00010717          	auipc	a4,0x10
ffffffffc02015d0:	eab73623          	sd	a1,-340(a4) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015d4:	6398                	ld	a4,0(a5)
}
ffffffffc02015d6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015d8:	e390                	sd	a2,0(a5)
ffffffffc02015da:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015dc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015de:	f118                	sd	a4,32(a0)
ffffffffc02015e0:	0141                	addi	sp,sp,16
ffffffffc02015e2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015e4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015e6:	f514                	sd	a3,40(a0)
ffffffffc02015e8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015ea:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02015ec:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015ee:	00d70e63          	beq	a4,a3,ffffffffc020160a <default_init_memmap+0xc2>
ffffffffc02015f2:	4805                	li	a6,1
ffffffffc02015f4:	87ba                	mv	a5,a4
ffffffffc02015f6:	b7e9                	j	ffffffffc02015c0 <default_init_memmap+0x78>
}
ffffffffc02015f8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015fa:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02015fe:	e398                	sd	a4,0(a5)
ffffffffc0201600:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201602:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201604:	f11c                	sd	a5,32(a0)
}
ffffffffc0201606:	0141                	addi	sp,sp,16
ffffffffc0201608:	8082                	ret
ffffffffc020160a:	60a2                	ld	ra,8(sp)
ffffffffc020160c:	e290                	sd	a2,0(a3)
ffffffffc020160e:	0141                	addi	sp,sp,16
ffffffffc0201610:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201612:	00004697          	auipc	a3,0x4
ffffffffc0201616:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0204ee0 <commands+0xbf8>
ffffffffc020161a:	00003617          	auipc	a2,0x3
ffffffffc020161e:	53e60613          	addi	a2,a2,1342 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201622:	04900593          	li	a1,73
ffffffffc0201626:	00003517          	auipc	a0,0x3
ffffffffc020162a:	54a50513          	addi	a0,a0,1354 # ffffffffc0204b70 <commands+0x888>
ffffffffc020162e:	d47fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201632:	00004697          	auipc	a3,0x4
ffffffffc0201636:	8a668693          	addi	a3,a3,-1882 # ffffffffc0204ed8 <commands+0xbf0>
ffffffffc020163a:	00003617          	auipc	a2,0x3
ffffffffc020163e:	51e60613          	addi	a2,a2,1310 # ffffffffc0204b58 <commands+0x870>
ffffffffc0201642:	04600593          	li	a1,70
ffffffffc0201646:	00003517          	auipc	a0,0x3
ffffffffc020164a:	52a50513          	addi	a0,a0,1322 # ffffffffc0204b70 <commands+0x888>
ffffffffc020164e:	d27fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201652 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201652:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201654:	00004617          	auipc	a2,0x4
ffffffffc0201658:	96460613          	addi	a2,a2,-1692 # ffffffffc0204fb8 <default_pmm_manager+0xc8>
ffffffffc020165c:	06500593          	li	a1,101
ffffffffc0201660:	00004517          	auipc	a0,0x4
ffffffffc0201664:	97850513          	addi	a0,a0,-1672 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201668:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020166a:	d0bfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020166e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020166e:	715d                	addi	sp,sp,-80
ffffffffc0201670:	e0a2                	sd	s0,64(sp)
ffffffffc0201672:	fc26                	sd	s1,56(sp)
ffffffffc0201674:	f84a                	sd	s2,48(sp)
ffffffffc0201676:	f44e                	sd	s3,40(sp)
ffffffffc0201678:	f052                	sd	s4,32(sp)
ffffffffc020167a:	ec56                	sd	s5,24(sp)
ffffffffc020167c:	e486                	sd	ra,72(sp)
ffffffffc020167e:	842a                	mv	s0,a0
ffffffffc0201680:	00010497          	auipc	s1,0x10
ffffffffc0201684:	e1048493          	addi	s1,s1,-496 # ffffffffc0211490 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201688:	4985                	li	s3,1
ffffffffc020168a:	00010a17          	auipc	s4,0x10
ffffffffc020168e:	ddea0a13          	addi	s4,s4,-546 # ffffffffc0211468 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201692:	0005091b          	sext.w	s2,a0
ffffffffc0201696:	00010a97          	auipc	s5,0x10
ffffffffc020169a:	efaa8a93          	addi	s5,s5,-262 # ffffffffc0211590 <check_mm_struct>
ffffffffc020169e:	a00d                	j	ffffffffc02016c0 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016a0:	609c                	ld	a5,0(s1)
ffffffffc02016a2:	6f9c                	ld	a5,24(a5)
ffffffffc02016a4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016a6:	4601                	li	a2,0
ffffffffc02016a8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016aa:	ed0d                	bnez	a0,ffffffffc02016e4 <alloc_pages+0x76>
ffffffffc02016ac:	0289ec63          	bltu	s3,s0,ffffffffc02016e4 <alloc_pages+0x76>
ffffffffc02016b0:	000a2783          	lw	a5,0(s4)
ffffffffc02016b4:	2781                	sext.w	a5,a5
ffffffffc02016b6:	c79d                	beqz	a5,ffffffffc02016e4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02016b8:	000ab503          	ld	a0,0(s5)
ffffffffc02016bc:	031010ef          	jal	ra,ffffffffc0202eec <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c0:	100027f3          	csrr	a5,sstatus
ffffffffc02016c4:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016c6:	8522                	mv	a0,s0
ffffffffc02016c8:	dfe1                	beqz	a5,ffffffffc02016a0 <alloc_pages+0x32>
        intr_disable();
ffffffffc02016ca:	e31fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02016ce:	609c                	ld	a5,0(s1)
ffffffffc02016d0:	8522                	mv	a0,s0
ffffffffc02016d2:	6f9c                	ld	a5,24(a5)
ffffffffc02016d4:	9782                	jalr	a5
ffffffffc02016d6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02016d8:	e1dfe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc02016dc:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc02016de:	4601                	li	a2,0
ffffffffc02016e0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016e2:	d569                	beqz	a0,ffffffffc02016ac <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02016e4:	60a6                	ld	ra,72(sp)
ffffffffc02016e6:	6406                	ld	s0,64(sp)
ffffffffc02016e8:	74e2                	ld	s1,56(sp)
ffffffffc02016ea:	7942                	ld	s2,48(sp)
ffffffffc02016ec:	79a2                	ld	s3,40(sp)
ffffffffc02016ee:	7a02                	ld	s4,32(sp)
ffffffffc02016f0:	6ae2                	ld	s5,24(sp)
ffffffffc02016f2:	6161                	addi	sp,sp,80
ffffffffc02016f4:	8082                	ret

ffffffffc02016f6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f6:	100027f3          	csrr	a5,sstatus
ffffffffc02016fa:	8b89                	andi	a5,a5,2
ffffffffc02016fc:	eb89                	bnez	a5,ffffffffc020170e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016fe:	00010797          	auipc	a5,0x10
ffffffffc0201702:	d9278793          	addi	a5,a5,-622 # ffffffffc0211490 <pmm_manager>
ffffffffc0201706:	639c                	ld	a5,0(a5)
ffffffffc0201708:	0207b303          	ld	t1,32(a5)
ffffffffc020170c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020170e:	1101                	addi	sp,sp,-32
ffffffffc0201710:	ec06                	sd	ra,24(sp)
ffffffffc0201712:	e822                	sd	s0,16(sp)
ffffffffc0201714:	e426                	sd	s1,8(sp)
ffffffffc0201716:	842a                	mv	s0,a0
ffffffffc0201718:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020171a:	de1fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020171e:	00010797          	auipc	a5,0x10
ffffffffc0201722:	d7278793          	addi	a5,a5,-654 # ffffffffc0211490 <pmm_manager>
ffffffffc0201726:	639c                	ld	a5,0(a5)
ffffffffc0201728:	85a6                	mv	a1,s1
ffffffffc020172a:	8522                	mv	a0,s0
ffffffffc020172c:	739c                	ld	a5,32(a5)
ffffffffc020172e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201730:	6442                	ld	s0,16(sp)
ffffffffc0201732:	60e2                	ld	ra,24(sp)
ffffffffc0201734:	64a2                	ld	s1,8(sp)
ffffffffc0201736:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201738:	dbdfe06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc020173c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020173c:	100027f3          	csrr	a5,sstatus
ffffffffc0201740:	8b89                	andi	a5,a5,2
ffffffffc0201742:	eb89                	bnez	a5,ffffffffc0201754 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201744:	00010797          	auipc	a5,0x10
ffffffffc0201748:	d4c78793          	addi	a5,a5,-692 # ffffffffc0211490 <pmm_manager>
ffffffffc020174c:	639c                	ld	a5,0(a5)
ffffffffc020174e:	0287b303          	ld	t1,40(a5)
ffffffffc0201752:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201754:	1141                	addi	sp,sp,-16
ffffffffc0201756:	e406                	sd	ra,8(sp)
ffffffffc0201758:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020175a:	da1fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020175e:	00010797          	auipc	a5,0x10
ffffffffc0201762:	d3278793          	addi	a5,a5,-718 # ffffffffc0211490 <pmm_manager>
ffffffffc0201766:	639c                	ld	a5,0(a5)
ffffffffc0201768:	779c                	ld	a5,40(a5)
ffffffffc020176a:	9782                	jalr	a5
ffffffffc020176c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020176e:	d87fe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201772:	8522                	mv	a0,s0
ffffffffc0201774:	60a2                	ld	ra,8(sp)
ffffffffc0201776:	6402                	ld	s0,0(sp)
ffffffffc0201778:	0141                	addi	sp,sp,16
ffffffffc020177a:	8082                	ret

ffffffffc020177c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020177c:	715d                	addi	sp,sp,-80
ffffffffc020177e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201780:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201784:	1ff4f493          	andi	s1,s1,511
ffffffffc0201788:	048e                	slli	s1,s1,0x3
ffffffffc020178a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020178c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020178e:	f84a                	sd	s2,48(sp)
ffffffffc0201790:	f44e                	sd	s3,40(sp)
ffffffffc0201792:	f052                	sd	s4,32(sp)
ffffffffc0201794:	e486                	sd	ra,72(sp)
ffffffffc0201796:	e0a2                	sd	s0,64(sp)
ffffffffc0201798:	ec56                	sd	s5,24(sp)
ffffffffc020179a:	e85a                	sd	s6,16(sp)
ffffffffc020179c:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020179e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017a2:	892e                	mv	s2,a1
ffffffffc02017a4:	8a32                	mv	s4,a2
ffffffffc02017a6:	00010997          	auipc	s3,0x10
ffffffffc02017aa:	cb298993          	addi	s3,s3,-846 # ffffffffc0211458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ae:	e3c9                	bnez	a5,ffffffffc0201830 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017b0:	16060163          	beqz	a2,ffffffffc0201912 <get_pte+0x196>
ffffffffc02017b4:	4505                	li	a0,1
ffffffffc02017b6:	eb9ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc02017ba:	842a                	mv	s0,a0
ffffffffc02017bc:	14050b63          	beqz	a0,ffffffffc0201912 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c0:	00010b97          	auipc	s7,0x10
ffffffffc02017c4:	ce8b8b93          	addi	s7,s7,-792 # ffffffffc02114a8 <pages>
ffffffffc02017c8:	000bb503          	ld	a0,0(s7)
ffffffffc02017cc:	00003797          	auipc	a5,0x3
ffffffffc02017d0:	37478793          	addi	a5,a5,884 # ffffffffc0204b40 <commands+0x858>
ffffffffc02017d4:	0007bb03          	ld	s6,0(a5)
ffffffffc02017d8:	40a40533          	sub	a0,s0,a0
ffffffffc02017dc:	850d                	srai	a0,a0,0x3
ffffffffc02017de:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017e2:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017e4:	00010997          	auipc	s3,0x10
ffffffffc02017e8:	c7498993          	addi	s3,s3,-908 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017ec:	00080ab7          	lui	s5,0x80
ffffffffc02017f0:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017f4:	c01c                	sw	a5,0(s0)
ffffffffc02017f6:	57fd                	li	a5,-1
ffffffffc02017f8:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017fa:	9556                	add	a0,a0,s5
ffffffffc02017fc:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02017fe:	0532                	slli	a0,a0,0xc
ffffffffc0201800:	16e7f063          	bleu	a4,a5,ffffffffc0201960 <get_pte+0x1e4>
ffffffffc0201804:	00010797          	auipc	a5,0x10
ffffffffc0201808:	c9478793          	addi	a5,a5,-876 # ffffffffc0211498 <va_pa_offset>
ffffffffc020180c:	639c                	ld	a5,0(a5)
ffffffffc020180e:	6605                	lui	a2,0x1
ffffffffc0201810:	4581                	li	a1,0
ffffffffc0201812:	953e                	add	a0,a0,a5
ffffffffc0201814:	181020ef          	jal	ra,ffffffffc0204194 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201818:	000bb683          	ld	a3,0(s7)
ffffffffc020181c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201820:	868d                	srai	a3,a3,0x3
ffffffffc0201822:	036686b3          	mul	a3,a3,s6
ffffffffc0201826:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201828:	06aa                	slli	a3,a3,0xa
ffffffffc020182a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020182e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201830:	77fd                	lui	a5,0xfffff
ffffffffc0201832:	068a                	slli	a3,a3,0x2
ffffffffc0201834:	0009b703          	ld	a4,0(s3)
ffffffffc0201838:	8efd                	and	a3,a3,a5
ffffffffc020183a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020183e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201916 <get_pte+0x19a>
ffffffffc0201842:	00010a97          	auipc	s5,0x10
ffffffffc0201846:	c56a8a93          	addi	s5,s5,-938 # ffffffffc0211498 <va_pa_offset>
ffffffffc020184a:	000ab403          	ld	s0,0(s5)
ffffffffc020184e:	01595793          	srli	a5,s2,0x15
ffffffffc0201852:	1ff7f793          	andi	a5,a5,511
ffffffffc0201856:	96a2                	add	a3,a3,s0
ffffffffc0201858:	00379413          	slli	s0,a5,0x3
ffffffffc020185c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020185e:	6014                	ld	a3,0(s0)
ffffffffc0201860:	0016f793          	andi	a5,a3,1
ffffffffc0201864:	ebbd                	bnez	a5,ffffffffc02018da <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201866:	0a0a0663          	beqz	s4,ffffffffc0201912 <get_pte+0x196>
ffffffffc020186a:	4505                	li	a0,1
ffffffffc020186c:	e03ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201870:	84aa                	mv	s1,a0
ffffffffc0201872:	c145                	beqz	a0,ffffffffc0201912 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201874:	00010b97          	auipc	s7,0x10
ffffffffc0201878:	c34b8b93          	addi	s7,s7,-972 # ffffffffc02114a8 <pages>
ffffffffc020187c:	000bb503          	ld	a0,0(s7)
ffffffffc0201880:	00003797          	auipc	a5,0x3
ffffffffc0201884:	2c078793          	addi	a5,a5,704 # ffffffffc0204b40 <commands+0x858>
ffffffffc0201888:	0007bb03          	ld	s6,0(a5)
ffffffffc020188c:	40a48533          	sub	a0,s1,a0
ffffffffc0201890:	850d                	srai	a0,a0,0x3
ffffffffc0201892:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201896:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201898:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020189c:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018a0:	c09c                	sw	a5,0(s1)
ffffffffc02018a2:	57fd                	li	a5,-1
ffffffffc02018a4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018a6:	9552                	add	a0,a0,s4
ffffffffc02018a8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018aa:	0532                	slli	a0,a0,0xc
ffffffffc02018ac:	08e7fd63          	bleu	a4,a5,ffffffffc0201946 <get_pte+0x1ca>
ffffffffc02018b0:	000ab783          	ld	a5,0(s5)
ffffffffc02018b4:	6605                	lui	a2,0x1
ffffffffc02018b6:	4581                	li	a1,0
ffffffffc02018b8:	953e                	add	a0,a0,a5
ffffffffc02018ba:	0db020ef          	jal	ra,ffffffffc0204194 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018be:	000bb683          	ld	a3,0(s7)
ffffffffc02018c2:	40d486b3          	sub	a3,s1,a3
ffffffffc02018c6:	868d                	srai	a3,a3,0x3
ffffffffc02018c8:	036686b3          	mul	a3,a3,s6
ffffffffc02018cc:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02018ce:	06aa                	slli	a3,a3,0xa
ffffffffc02018d0:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02018d4:	e014                	sd	a3,0(s0)
ffffffffc02018d6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018da:	068a                	slli	a3,a3,0x2
ffffffffc02018dc:	757d                	lui	a0,0xfffff
ffffffffc02018de:	8ee9                	and	a3,a3,a0
ffffffffc02018e0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02018e4:	04e7f563          	bleu	a4,a5,ffffffffc020192e <get_pte+0x1b2>
ffffffffc02018e8:	000ab503          	ld	a0,0(s5)
ffffffffc02018ec:	00c95793          	srli	a5,s2,0xc
ffffffffc02018f0:	1ff7f793          	andi	a5,a5,511
ffffffffc02018f4:	96aa                	add	a3,a3,a0
ffffffffc02018f6:	00379513          	slli	a0,a5,0x3
ffffffffc02018fa:	9536                	add	a0,a0,a3
}
ffffffffc02018fc:	60a6                	ld	ra,72(sp)
ffffffffc02018fe:	6406                	ld	s0,64(sp)
ffffffffc0201900:	74e2                	ld	s1,56(sp)
ffffffffc0201902:	7942                	ld	s2,48(sp)
ffffffffc0201904:	79a2                	ld	s3,40(sp)
ffffffffc0201906:	7a02                	ld	s4,32(sp)
ffffffffc0201908:	6ae2                	ld	s5,24(sp)
ffffffffc020190a:	6b42                	ld	s6,16(sp)
ffffffffc020190c:	6ba2                	ld	s7,8(sp)
ffffffffc020190e:	6161                	addi	sp,sp,80
ffffffffc0201910:	8082                	ret
            return NULL;
ffffffffc0201912:	4501                	li	a0,0
ffffffffc0201914:	b7e5                	j	ffffffffc02018fc <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201916:	00003617          	auipc	a2,0x3
ffffffffc020191a:	62a60613          	addi	a2,a2,1578 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc020191e:	10200593          	li	a1,258
ffffffffc0201922:	00003517          	auipc	a0,0x3
ffffffffc0201926:	64650513          	addi	a0,a0,1606 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020192a:	a4bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020192e:	00003617          	auipc	a2,0x3
ffffffffc0201932:	61260613          	addi	a2,a2,1554 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc0201936:	10f00593          	li	a1,271
ffffffffc020193a:	00003517          	auipc	a0,0x3
ffffffffc020193e:	62e50513          	addi	a0,a0,1582 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0201942:	a33fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201946:	86aa                	mv	a3,a0
ffffffffc0201948:	00003617          	auipc	a2,0x3
ffffffffc020194c:	5f860613          	addi	a2,a2,1528 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc0201950:	10b00593          	li	a1,267
ffffffffc0201954:	00003517          	auipc	a0,0x3
ffffffffc0201958:	61450513          	addi	a0,a0,1556 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020195c:	a19fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201960:	86aa                	mv	a3,a0
ffffffffc0201962:	00003617          	auipc	a2,0x3
ffffffffc0201966:	5de60613          	addi	a2,a2,1502 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc020196a:	0ff00593          	li	a1,255
ffffffffc020196e:	00003517          	auipc	a0,0x3
ffffffffc0201972:	5fa50513          	addi	a0,a0,1530 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0201976:	9fffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020197a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020197a:	1141                	addi	sp,sp,-16
ffffffffc020197c:	e022                	sd	s0,0(sp)
ffffffffc020197e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201980:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201982:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201984:	df9ff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201988:	c011                	beqz	s0,ffffffffc020198c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020198a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020198c:	c521                	beqz	a0,ffffffffc02019d4 <get_page+0x5a>
ffffffffc020198e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201990:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201992:	0017f713          	andi	a4,a5,1
ffffffffc0201996:	e709                	bnez	a4,ffffffffc02019a0 <get_page+0x26>
}
ffffffffc0201998:	60a2                	ld	ra,8(sp)
ffffffffc020199a:	6402                	ld	s0,0(sp)
ffffffffc020199c:	0141                	addi	sp,sp,16
ffffffffc020199e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019a0:	00010717          	auipc	a4,0x10
ffffffffc02019a4:	ab870713          	addi	a4,a4,-1352 # ffffffffc0211458 <npage>
ffffffffc02019a8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019aa:	078a                	slli	a5,a5,0x2
ffffffffc02019ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019ae:	02e7f863          	bleu	a4,a5,ffffffffc02019de <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc02019b2:	fff80537          	lui	a0,0xfff80
ffffffffc02019b6:	97aa                	add	a5,a5,a0
ffffffffc02019b8:	00010697          	auipc	a3,0x10
ffffffffc02019bc:	af068693          	addi	a3,a3,-1296 # ffffffffc02114a8 <pages>
ffffffffc02019c0:	6288                	ld	a0,0(a3)
ffffffffc02019c2:	60a2                	ld	ra,8(sp)
ffffffffc02019c4:	6402                	ld	s0,0(sp)
ffffffffc02019c6:	00379713          	slli	a4,a5,0x3
ffffffffc02019ca:	97ba                	add	a5,a5,a4
ffffffffc02019cc:	078e                	slli	a5,a5,0x3
ffffffffc02019ce:	953e                	add	a0,a0,a5
ffffffffc02019d0:	0141                	addi	sp,sp,16
ffffffffc02019d2:	8082                	ret
ffffffffc02019d4:	60a2                	ld	ra,8(sp)
ffffffffc02019d6:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02019d8:	4501                	li	a0,0
}
ffffffffc02019da:	0141                	addi	sp,sp,16
ffffffffc02019dc:	8082                	ret
ffffffffc02019de:	c75ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc02019e2 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019e2:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019e4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019e6:	e406                	sd	ra,8(sp)
ffffffffc02019e8:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019ea:	d93ff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep != NULL) {
ffffffffc02019ee:	c511                	beqz	a0,ffffffffc02019fa <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02019f0:	611c                	ld	a5,0(a0)
ffffffffc02019f2:	842a                	mv	s0,a0
ffffffffc02019f4:	0017f713          	andi	a4,a5,1
ffffffffc02019f8:	e709                	bnez	a4,ffffffffc0201a02 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02019fa:	60a2                	ld	ra,8(sp)
ffffffffc02019fc:	6402                	ld	s0,0(sp)
ffffffffc02019fe:	0141                	addi	sp,sp,16
ffffffffc0201a00:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a02:	00010717          	auipc	a4,0x10
ffffffffc0201a06:	a5670713          	addi	a4,a4,-1450 # ffffffffc0211458 <npage>
ffffffffc0201a0a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a0c:	078a                	slli	a5,a5,0x2
ffffffffc0201a0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a10:	04e7f063          	bleu	a4,a5,ffffffffc0201a50 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a14:	fff80737          	lui	a4,0xfff80
ffffffffc0201a18:	97ba                	add	a5,a5,a4
ffffffffc0201a1a:	00010717          	auipc	a4,0x10
ffffffffc0201a1e:	a8e70713          	addi	a4,a4,-1394 # ffffffffc02114a8 <pages>
ffffffffc0201a22:	6308                	ld	a0,0(a4)
ffffffffc0201a24:	00379713          	slli	a4,a5,0x3
ffffffffc0201a28:	97ba                	add	a5,a5,a4
ffffffffc0201a2a:	078e                	slli	a5,a5,0x3
ffffffffc0201a2c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a2e:	411c                	lw	a5,0(a0)
ffffffffc0201a30:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a34:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a36:	cb09                	beqz	a4,ffffffffc0201a48 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a38:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a3c:	12000073          	sfence.vma
}
ffffffffc0201a40:	60a2                	ld	ra,8(sp)
ffffffffc0201a42:	6402                	ld	s0,0(sp)
ffffffffc0201a44:	0141                	addi	sp,sp,16
ffffffffc0201a46:	8082                	ret
            free_page(page);
ffffffffc0201a48:	4585                	li	a1,1
ffffffffc0201a4a:	cadff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0201a4e:	b7ed                	j	ffffffffc0201a38 <page_remove+0x56>
ffffffffc0201a50:	c03ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc0201a54 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a54:	7179                	addi	sp,sp,-48
ffffffffc0201a56:	87b2                	mv	a5,a2
ffffffffc0201a58:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a5a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a5c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a5e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a60:	ec26                	sd	s1,24(sp)
ffffffffc0201a62:	f406                	sd	ra,40(sp)
ffffffffc0201a64:	e84a                	sd	s2,16(sp)
ffffffffc0201a66:	e44e                	sd	s3,8(sp)
ffffffffc0201a68:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a6a:	d13ff0ef          	jal	ra,ffffffffc020177c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a6e:	c945                	beqz	a0,ffffffffc0201b1e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a70:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {  // valid!，页表项如果是有效的才会去删除
ffffffffc0201a72:	611c                	ld	a5,0(a0)
ffffffffc0201a74:	892a                	mv	s2,a0
ffffffffc0201a76:	0016871b          	addiw	a4,a3,1
ffffffffc0201a7a:	c018                	sw	a4,0(s0)
ffffffffc0201a7c:	0017f713          	andi	a4,a5,1
ffffffffc0201a80:	e339                	bnez	a4,ffffffffc0201ac6 <page_insert+0x72>
ffffffffc0201a82:	00010797          	auipc	a5,0x10
ffffffffc0201a86:	a2678793          	addi	a5,a5,-1498 # ffffffffc02114a8 <pages>
ffffffffc0201a8a:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a8c:	00003717          	auipc	a4,0x3
ffffffffc0201a90:	0b470713          	addi	a4,a4,180 # ffffffffc0204b40 <commands+0x858>
ffffffffc0201a94:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a98:	6300                	ld	s0,0(a4)
ffffffffc0201a9a:	878d                	srai	a5,a5,0x3
ffffffffc0201a9c:	000806b7          	lui	a3,0x80
ffffffffc0201aa0:	028787b3          	mul	a5,a5,s0
ffffffffc0201aa4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201aa6:	07aa                	slli	a5,a5,0xa
ffffffffc0201aa8:	8fc5                	or	a5,a5,s1
ffffffffc0201aaa:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201aae:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ab2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201ab6:	4501                	li	a0,0
}
ffffffffc0201ab8:	70a2                	ld	ra,40(sp)
ffffffffc0201aba:	7402                	ld	s0,32(sp)
ffffffffc0201abc:	64e2                	ld	s1,24(sp)
ffffffffc0201abe:	6942                	ld	s2,16(sp)
ffffffffc0201ac0:	69a2                	ld	s3,8(sp)
ffffffffc0201ac2:	6145                	addi	sp,sp,48
ffffffffc0201ac4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201ac6:	00010717          	auipc	a4,0x10
ffffffffc0201aca:	99270713          	addi	a4,a4,-1646 # ffffffffc0211458 <npage>
ffffffffc0201ace:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ad0:	00279513          	slli	a0,a5,0x2
ffffffffc0201ad4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ad6:	04e57663          	bleu	a4,a0,ffffffffc0201b22 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ada:	fff807b7          	lui	a5,0xfff80
ffffffffc0201ade:	953e                	add	a0,a0,a5
ffffffffc0201ae0:	00010997          	auipc	s3,0x10
ffffffffc0201ae4:	9c898993          	addi	s3,s3,-1592 # ffffffffc02114a8 <pages>
ffffffffc0201ae8:	0009b783          	ld	a5,0(s3)
ffffffffc0201aec:	00351713          	slli	a4,a0,0x3
ffffffffc0201af0:	953a                	add	a0,a0,a4
ffffffffc0201af2:	050e                	slli	a0,a0,0x3
ffffffffc0201af4:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201af6:	00a40e63          	beq	s0,a0,ffffffffc0201b12 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201afa:	411c                	lw	a5,0(a0)
ffffffffc0201afc:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b00:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b02:	cb11                	beqz	a4,ffffffffc0201b16 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b04:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b08:	12000073          	sfence.vma
ffffffffc0201b0c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b10:	bfb5                	j	ffffffffc0201a8c <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b12:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b14:	bfa5                	j	ffffffffc0201a8c <page_insert+0x38>
            free_page(page);
ffffffffc0201b16:	4585                	li	a1,1
ffffffffc0201b18:	bdfff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
ffffffffc0201b1c:	b7e5                	j	ffffffffc0201b04 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b1e:	5571                	li	a0,-4
ffffffffc0201b20:	bf61                	j	ffffffffc0201ab8 <page_insert+0x64>
ffffffffc0201b22:	b31ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>

ffffffffc0201b26 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b26:	00003797          	auipc	a5,0x3
ffffffffc0201b2a:	3ca78793          	addi	a5,a5,970 # ffffffffc0204ef0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b2e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b30:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b32:	00003517          	auipc	a0,0x3
ffffffffc0201b36:	4ce50513          	addi	a0,a0,1230 # ffffffffc0205000 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b3a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b3c:	00010717          	auipc	a4,0x10
ffffffffc0201b40:	94f73a23          	sd	a5,-1708(a4) # ffffffffc0211490 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b44:	e8a2                	sd	s0,80(sp)
ffffffffc0201b46:	e4a6                	sd	s1,72(sp)
ffffffffc0201b48:	e0ca                	sd	s2,64(sp)
ffffffffc0201b4a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b4c:	f852                	sd	s4,48(sp)
ffffffffc0201b4e:	f456                	sd	s5,40(sp)
ffffffffc0201b50:	f05a                	sd	s6,32(sp)
ffffffffc0201b52:	ec5e                	sd	s7,24(sp)
ffffffffc0201b54:	e862                	sd	s8,16(sp)
ffffffffc0201b56:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b58:	00010417          	auipc	s0,0x10
ffffffffc0201b5c:	93840413          	addi	s0,s0,-1736 # ffffffffc0211490 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b60:	d5efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b64:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b66:	49c5                	li	s3,17
ffffffffc0201b68:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b6c:	679c                	ld	a5,8(a5)
ffffffffc0201b6e:	00010497          	auipc	s1,0x10
ffffffffc0201b72:	8ea48493          	addi	s1,s1,-1814 # ffffffffc0211458 <npage>
ffffffffc0201b76:	00010917          	auipc	s2,0x10
ffffffffc0201b7a:	93290913          	addi	s2,s2,-1742 # ffffffffc02114a8 <pages>
ffffffffc0201b7e:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b80:	57f5                	li	a5,-3
ffffffffc0201b82:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b84:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b88:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201b8c:	015a1593          	slli	a1,s4,0x15
ffffffffc0201b90:	00003517          	auipc	a0,0x3
ffffffffc0201b94:	48850513          	addi	a0,a0,1160 # ffffffffc0205018 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b98:	00010717          	auipc	a4,0x10
ffffffffc0201b9c:	90f73023          	sd	a5,-1792(a4) # ffffffffc0211498 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201ba0:	d1efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201ba4:	00003517          	auipc	a0,0x3
ffffffffc0201ba8:	4a450513          	addi	a0,a0,1188 # ffffffffc0205048 <default_pmm_manager+0x158>
ffffffffc0201bac:	d12fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201bb0:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201bb4:	16fd                	addi	a3,a3,-1
ffffffffc0201bb6:	015a1613          	slli	a2,s4,0x15
ffffffffc0201bba:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bbe:	00003517          	auipc	a0,0x3
ffffffffc0201bc2:	4a250513          	addi	a0,a0,1186 # ffffffffc0205060 <default_pmm_manager+0x170>
ffffffffc0201bc6:	cf8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bca:	777d                	lui	a4,0xfffff
ffffffffc0201bcc:	00011797          	auipc	a5,0x11
ffffffffc0201bd0:	9cb78793          	addi	a5,a5,-1589 # ffffffffc0212597 <end+0xfff>
ffffffffc0201bd4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201bd6:	00088737          	lui	a4,0x88
ffffffffc0201bda:	00010697          	auipc	a3,0x10
ffffffffc0201bde:	86e6bf23          	sd	a4,-1922(a3) # ffffffffc0211458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201be2:	00010717          	auipc	a4,0x10
ffffffffc0201be6:	8cf73323          	sd	a5,-1850(a4) # ffffffffc02114a8 <pages>
ffffffffc0201bea:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bec:	4701                	li	a4,0
ffffffffc0201bee:	4585                	li	a1,1
ffffffffc0201bf0:	fff80637          	lui	a2,0xfff80
ffffffffc0201bf4:	a019                	j	ffffffffc0201bfa <pmm_init+0xd4>
ffffffffc0201bf6:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201bfa:	97b6                	add	a5,a5,a3
ffffffffc0201bfc:	07a1                	addi	a5,a5,8
ffffffffc0201bfe:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c02:	609c                	ld	a5,0(s1)
ffffffffc0201c04:	0705                	addi	a4,a4,1
ffffffffc0201c06:	04868693          	addi	a3,a3,72
ffffffffc0201c0a:	00c78533          	add	a0,a5,a2
ffffffffc0201c0e:	fea764e3          	bltu	a4,a0,ffffffffc0201bf6 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c12:	00093503          	ld	a0,0(s2)
ffffffffc0201c16:	00379693          	slli	a3,a5,0x3
ffffffffc0201c1a:	96be                	add	a3,a3,a5
ffffffffc0201c1c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c20:	972a                	add	a4,a4,a0
ffffffffc0201c22:	068e                	slli	a3,a3,0x3
ffffffffc0201c24:	96ba                	add	a3,a3,a4
ffffffffc0201c26:	c0200737          	lui	a4,0xc0200
ffffffffc0201c2a:	58e6ea63          	bltu	a3,a4,ffffffffc02021be <pmm_init+0x698>
ffffffffc0201c2e:	00010997          	auipc	s3,0x10
ffffffffc0201c32:	86a98993          	addi	s3,s3,-1942 # ffffffffc0211498 <va_pa_offset>
ffffffffc0201c36:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c3a:	45c5                	li	a1,17
ffffffffc0201c3c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c3e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c40:	44b6ef63          	bltu	a3,a1,ffffffffc020209e <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c44:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c46:	00010417          	auipc	s0,0x10
ffffffffc0201c4a:	80a40413          	addi	s0,s0,-2038 # ffffffffc0211450 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c4e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c50:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c52:	00003517          	auipc	a0,0x3
ffffffffc0201c56:	45e50513          	addi	a0,a0,1118 # ffffffffc02050b0 <default_pmm_manager+0x1c0>
ffffffffc0201c5a:	c64fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c5e:	00007697          	auipc	a3,0x7
ffffffffc0201c62:	3a268693          	addi	a3,a3,930 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c66:	0000f797          	auipc	a5,0xf
ffffffffc0201c6a:	7ed7b523          	sd	a3,2026(a5) # ffffffffc0211450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c6e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c72:	0ef6ece3          	bltu	a3,a5,ffffffffc020256a <pmm_init+0xa44>
ffffffffc0201c76:	0009b783          	ld	a5,0(s3)
ffffffffc0201c7a:	8e9d                	sub	a3,a3,a5
ffffffffc0201c7c:	00010797          	auipc	a5,0x10
ffffffffc0201c80:	82d7b223          	sd	a3,-2012(a5) # ffffffffc02114a0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201c84:	ab9ff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c88:	6098                	ld	a4,0(s1)
ffffffffc0201c8a:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c8e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201c90:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c92:	0ae7ece3          	bltu	a5,a4,ffffffffc020254a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c96:	6008                	ld	a0,0(s0)
ffffffffc0201c98:	4c050363          	beqz	a0,ffffffffc020215e <pmm_init+0x638>
ffffffffc0201c9c:	6785                	lui	a5,0x1
ffffffffc0201c9e:	17fd                	addi	a5,a5,-1
ffffffffc0201ca0:	8fe9                	and	a5,a5,a0
ffffffffc0201ca2:	2781                	sext.w	a5,a5
ffffffffc0201ca4:	4a079d63          	bnez	a5,ffffffffc020215e <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201ca8:	4601                	li	a2,0
ffffffffc0201caa:	4581                	li	a1,0
ffffffffc0201cac:	ccfff0ef          	jal	ra,ffffffffc020197a <get_page>
ffffffffc0201cb0:	4c051763          	bnez	a0,ffffffffc020217e <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201cb4:	4505                	li	a0,1
ffffffffc0201cb6:	9b9ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201cba:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201cbc:	6008                	ld	a0,0(s0)
ffffffffc0201cbe:	4681                	li	a3,0
ffffffffc0201cc0:	4601                	li	a2,0
ffffffffc0201cc2:	85d6                	mv	a1,s5
ffffffffc0201cc4:	d91ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201cc8:	52051763          	bnez	a0,ffffffffc02021f6 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201ccc:	6008                	ld	a0,0(s0)
ffffffffc0201cce:	4601                	li	a2,0
ffffffffc0201cd0:	4581                	li	a1,0
ffffffffc0201cd2:	aabff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201cd6:	50050063          	beqz	a0,ffffffffc02021d6 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201cda:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201cdc:	0017f713          	andi	a4,a5,1
ffffffffc0201ce0:	46070363          	beqz	a4,ffffffffc0202146 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201ce4:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ce6:	078a                	slli	a5,a5,0x2
ffffffffc0201ce8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cea:	44c7f063          	bleu	a2,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cee:	fff80737          	lui	a4,0xfff80
ffffffffc0201cf2:	97ba                	add	a5,a5,a4
ffffffffc0201cf4:	00379713          	slli	a4,a5,0x3
ffffffffc0201cf8:	00093683          	ld	a3,0(s2)
ffffffffc0201cfc:	97ba                	add	a5,a5,a4
ffffffffc0201cfe:	078e                	slli	a5,a5,0x3
ffffffffc0201d00:	97b6                	add	a5,a5,a3
ffffffffc0201d02:	5efa9463          	bne	s5,a5,ffffffffc02022ea <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d06:	000aab83          	lw	s7,0(s5)
ffffffffc0201d0a:	4785                	li	a5,1
ffffffffc0201d0c:	5afb9f63          	bne	s7,a5,ffffffffc02022ca <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d10:	6008                	ld	a0,0(s0)
ffffffffc0201d12:	76fd                	lui	a3,0xfffff
ffffffffc0201d14:	611c                	ld	a5,0(a0)
ffffffffc0201d16:	078a                	slli	a5,a5,0x2
ffffffffc0201d18:	8ff5                	and	a5,a5,a3
ffffffffc0201d1a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d1e:	58c77963          	bleu	a2,a4,ffffffffc02022b0 <pmm_init+0x78a>
ffffffffc0201d22:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d26:	97e2                	add	a5,a5,s8
ffffffffc0201d28:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d2c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d2e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d32:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d36:	56c7f063          	bleu	a2,a5,ffffffffc0202296 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d3a:	4601                	li	a2,0
ffffffffc0201d3c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d3e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d40:	a3dff0ef          	jal	ra,ffffffffc020177c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d44:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d46:	53651863          	bne	a0,s6,ffffffffc0202276 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d4a:	4505                	li	a0,1
ffffffffc0201d4c:	923ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201d50:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d52:	6008                	ld	a0,0(s0)
ffffffffc0201d54:	46d1                	li	a3,20
ffffffffc0201d56:	6605                	lui	a2,0x1
ffffffffc0201d58:	85da                	mv	a1,s6
ffffffffc0201d5a:	cfbff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201d5e:	4e051c63          	bnez	a0,ffffffffc0202256 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d62:	6008                	ld	a0,0(s0)
ffffffffc0201d64:	4601                	li	a2,0
ffffffffc0201d66:	6585                	lui	a1,0x1
ffffffffc0201d68:	a15ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201d6c:	4c050563          	beqz	a0,ffffffffc0202236 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201d70:	611c                	ld	a5,0(a0)
ffffffffc0201d72:	0107f713          	andi	a4,a5,16
ffffffffc0201d76:	4a070063          	beqz	a4,ffffffffc0202216 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201d7a:	8b91                	andi	a5,a5,4
ffffffffc0201d7c:	66078763          	beqz	a5,ffffffffc02023ea <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d80:	6008                	ld	a0,0(s0)
ffffffffc0201d82:	611c                	ld	a5,0(a0)
ffffffffc0201d84:	8bc1                	andi	a5,a5,16
ffffffffc0201d86:	64078263          	beqz	a5,ffffffffc02023ca <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201d8a:	000b2783          	lw	a5,0(s6)
ffffffffc0201d8e:	61779e63          	bne	a5,s7,ffffffffc02023aa <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d92:	4681                	li	a3,0
ffffffffc0201d94:	6605                	lui	a2,0x1
ffffffffc0201d96:	85d6                	mv	a1,s5
ffffffffc0201d98:	cbdff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201d9c:	5e051763          	bnez	a0,ffffffffc020238a <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201da0:	000aa703          	lw	a4,0(s5)
ffffffffc0201da4:	4789                	li	a5,2
ffffffffc0201da6:	5cf71263          	bne	a4,a5,ffffffffc020236a <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201daa:	000b2783          	lw	a5,0(s6)
ffffffffc0201dae:	58079e63          	bnez	a5,ffffffffc020234a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201db2:	6008                	ld	a0,0(s0)
ffffffffc0201db4:	4601                	li	a2,0
ffffffffc0201db6:	6585                	lui	a1,0x1
ffffffffc0201db8:	9c5ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201dbc:	56050763          	beqz	a0,ffffffffc020232a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201dc0:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201dc2:	0016f793          	andi	a5,a3,1
ffffffffc0201dc6:	38078063          	beqz	a5,ffffffffc0202146 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201dca:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dcc:	00269793          	slli	a5,a3,0x2
ffffffffc0201dd0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201dd2:	34e7fc63          	bleu	a4,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dd6:	fff80737          	lui	a4,0xfff80
ffffffffc0201dda:	97ba                	add	a5,a5,a4
ffffffffc0201ddc:	00379713          	slli	a4,a5,0x3
ffffffffc0201de0:	00093603          	ld	a2,0(s2)
ffffffffc0201de4:	97ba                	add	a5,a5,a4
ffffffffc0201de6:	078e                	slli	a5,a5,0x3
ffffffffc0201de8:	97b2                	add	a5,a5,a2
ffffffffc0201dea:	52fa9063          	bne	s5,a5,ffffffffc020230a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201dee:	8ac1                	andi	a3,a3,16
ffffffffc0201df0:	6e069d63          	bnez	a3,ffffffffc02024ea <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201df4:	6008                	ld	a0,0(s0)
ffffffffc0201df6:	4581                	li	a1,0
ffffffffc0201df8:	bebff0ef          	jal	ra,ffffffffc02019e2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dfc:	000aa703          	lw	a4,0(s5)
ffffffffc0201e00:	4785                	li	a5,1
ffffffffc0201e02:	6cf71463          	bne	a4,a5,ffffffffc02024ca <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e06:	000b2783          	lw	a5,0(s6)
ffffffffc0201e0a:	6a079063          	bnez	a5,ffffffffc02024aa <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e0e:	6008                	ld	a0,0(s0)
ffffffffc0201e10:	6585                	lui	a1,0x1
ffffffffc0201e12:	bd1ff0ef          	jal	ra,ffffffffc02019e2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e16:	000aa783          	lw	a5,0(s5)
ffffffffc0201e1a:	66079863          	bnez	a5,ffffffffc020248a <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e1e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e22:	70079463          	bnez	a5,ffffffffc020252a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e26:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e2a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e2c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e30:	078a                	slli	a5,a5,0x2
ffffffffc0201e32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e34:	2eb7fb63          	bleu	a1,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e38:	fff80737          	lui	a4,0xfff80
ffffffffc0201e3c:	973e                	add	a4,a4,a5
ffffffffc0201e3e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e42:	00093603          	ld	a2,0(s2)
ffffffffc0201e46:	97ba                	add	a5,a5,a4
ffffffffc0201e48:	078e                	slli	a5,a5,0x3
ffffffffc0201e4a:	00f60733          	add	a4,a2,a5
ffffffffc0201e4e:	4314                	lw	a3,0(a4)
ffffffffc0201e50:	4705                	li	a4,1
ffffffffc0201e52:	6ae69c63          	bne	a3,a4,ffffffffc020250a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e56:	00003a97          	auipc	s5,0x3
ffffffffc0201e5a:	ceaa8a93          	addi	s5,s5,-790 # ffffffffc0204b40 <commands+0x858>
ffffffffc0201e5e:	000ab703          	ld	a4,0(s5)
ffffffffc0201e62:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e66:	00080bb7          	lui	s7,0x80
ffffffffc0201e6a:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e6e:	577d                	li	a4,-1
ffffffffc0201e70:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e72:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e74:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e76:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e78:	2ab77b63          	bleu	a1,a4,ffffffffc020212e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e7c:	0009b783          	ld	a5,0(s3)
ffffffffc0201e80:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e82:	629c                	ld	a5,0(a3)
ffffffffc0201e84:	078a                	slli	a5,a5,0x2
ffffffffc0201e86:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e88:	2ab7f163          	bleu	a1,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e8c:	417787b3          	sub	a5,a5,s7
ffffffffc0201e90:	00379513          	slli	a0,a5,0x3
ffffffffc0201e94:	97aa                	add	a5,a5,a0
ffffffffc0201e96:	00379513          	slli	a0,a5,0x3
ffffffffc0201e9a:	9532                	add	a0,a0,a2
ffffffffc0201e9c:	4585                	li	a1,1
ffffffffc0201e9e:	859ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201ea6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ea8:	050a                	slli	a0,a0,0x2
ffffffffc0201eaa:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eac:	26f57f63          	bleu	a5,a0,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eb0:	417507b3          	sub	a5,a0,s7
ffffffffc0201eb4:	00379513          	slli	a0,a5,0x3
ffffffffc0201eb8:	00093703          	ld	a4,0(s2)
ffffffffc0201ebc:	953e                	add	a0,a0,a5
ffffffffc0201ebe:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201ec0:	4585                	li	a1,1
ffffffffc0201ec2:	953a                	add	a0,a0,a4
ffffffffc0201ec4:	833ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201ec8:	601c                	ld	a5,0(s0)
ffffffffc0201eca:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201ece:	86fff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0201ed2:	2caa1663          	bne	s4,a0,ffffffffc020219e <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201ed6:	00003517          	auipc	a0,0x3
ffffffffc0201eda:	4ea50513          	addi	a0,a0,1258 # ffffffffc02053c0 <default_pmm_manager+0x4d0>
ffffffffc0201ede:	9e0fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201ee2:	85bff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ee6:	6098                	ld	a4,0(s1)
ffffffffc0201ee8:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201eec:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eee:	00c71693          	slli	a3,a4,0xc
ffffffffc0201ef2:	1cd7fd63          	bleu	a3,a5,ffffffffc02020cc <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ef6:	83b1                	srli	a5,a5,0xc
ffffffffc0201ef8:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201efa:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201efe:	1ce7f963          	bleu	a4,a5,ffffffffc02020d0 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f02:	7c7d                	lui	s8,0xfffff
ffffffffc0201f04:	6b85                	lui	s7,0x1
ffffffffc0201f06:	a029                	j	ffffffffc0201f10 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f08:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f0c:	1cf77263          	bleu	a5,a4,ffffffffc02020d0 <pmm_init+0x5aa>
ffffffffc0201f10:	0009b583          	ld	a1,0(s3)
ffffffffc0201f14:	4601                	li	a2,0
ffffffffc0201f16:	95d2                	add	a1,a1,s4
ffffffffc0201f18:	865ff0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0201f1c:	1c050763          	beqz	a0,ffffffffc02020ea <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f20:	611c                	ld	a5,0(a0)
ffffffffc0201f22:	078a                	slli	a5,a5,0x2
ffffffffc0201f24:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f28:	1f479163          	bne	a5,s4,ffffffffc020210a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f2c:	609c                	ld	a5,0(s1)
ffffffffc0201f2e:	9a5e                	add	s4,s4,s7
ffffffffc0201f30:	6008                	ld	a0,0(s0)
ffffffffc0201f32:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f36:	fcea69e3          	bltu	s4,a4,ffffffffc0201f08 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f3a:	611c                	ld	a5,0(a0)
ffffffffc0201f3c:	6a079363          	bnez	a5,ffffffffc02025e2 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f40:	4505                	li	a0,1
ffffffffc0201f42:	f2cff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0201f46:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f48:	6008                	ld	a0,0(s0)
ffffffffc0201f4a:	4699                	li	a3,6
ffffffffc0201f4c:	10000613          	li	a2,256
ffffffffc0201f50:	85d2                	mv	a1,s4
ffffffffc0201f52:	b03ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201f56:	66051663          	bnez	a0,ffffffffc02025c2 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201f5a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f5e:	4785                	li	a5,1
ffffffffc0201f60:	64f71163          	bne	a4,a5,ffffffffc02025a2 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f64:	6008                	ld	a0,0(s0)
ffffffffc0201f66:	6b85                	lui	s7,0x1
ffffffffc0201f68:	4699                	li	a3,6
ffffffffc0201f6a:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f6e:	85d2                	mv	a1,s4
ffffffffc0201f70:	ae5ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0201f74:	60051763          	bnez	a0,ffffffffc0202582 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201f78:	000a2703          	lw	a4,0(s4)
ffffffffc0201f7c:	4789                	li	a5,2
ffffffffc0201f7e:	4ef71663          	bne	a4,a5,ffffffffc020246a <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f82:	00003597          	auipc	a1,0x3
ffffffffc0201f86:	57658593          	addi	a1,a1,1398 # ffffffffc02054f8 <default_pmm_manager+0x608>
ffffffffc0201f8a:	10000513          	li	a0,256
ffffffffc0201f8e:	1ac020ef          	jal	ra,ffffffffc020413a <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f92:	100b8593          	addi	a1,s7,256
ffffffffc0201f96:	10000513          	li	a0,256
ffffffffc0201f9a:	1b2020ef          	jal	ra,ffffffffc020414c <strcmp>
ffffffffc0201f9e:	4a051663          	bnez	a0,ffffffffc020244a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fa2:	00093683          	ld	a3,0(s2)
ffffffffc0201fa6:	000abc83          	ld	s9,0(s5)
ffffffffc0201faa:	00080c37          	lui	s8,0x80
ffffffffc0201fae:	40da06b3          	sub	a3,s4,a3
ffffffffc0201fb2:	868d                	srai	a3,a3,0x3
ffffffffc0201fb4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fb8:	5afd                	li	s5,-1
ffffffffc0201fba:	609c                	ld	a5,0(s1)
ffffffffc0201fbc:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fc0:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc2:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc8:	16f77363          	bleu	a5,a4,ffffffffc020212e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fcc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fd0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201fd4:	96be                	add	a3,a3,a5
ffffffffc0201fd6:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb68>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201fda:	11c020ef          	jal	ra,ffffffffc02040f6 <strlen>
ffffffffc0201fde:	44051663          	bnez	a0,ffffffffc020242a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fe2:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201fe6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe8:	000bb783          	ld	a5,0(s7)
ffffffffc0201fec:	078a                	slli	a5,a5,0x2
ffffffffc0201fee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ff0:	12e7fd63          	bleu	a4,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ff4:	418787b3          	sub	a5,a5,s8
ffffffffc0201ff8:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ffc:	96be                	add	a3,a3,a5
ffffffffc0201ffe:	039686b3          	mul	a3,a3,s9
ffffffffc0202002:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202004:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202008:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020200a:	12eaf263          	bleu	a4,s5,ffffffffc020212e <pmm_init+0x608>
ffffffffc020200e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202012:	4585                	li	a1,1
ffffffffc0202014:	8552                	mv	a0,s4
ffffffffc0202016:	99b6                	add	s3,s3,a3
ffffffffc0202018:	edeff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020201c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202020:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202022:	078a                	slli	a5,a5,0x2
ffffffffc0202024:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202026:	10e7f263          	bleu	a4,a5,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020202a:	fff809b7          	lui	s3,0xfff80
ffffffffc020202e:	97ce                	add	a5,a5,s3
ffffffffc0202030:	00379513          	slli	a0,a5,0x3
ffffffffc0202034:	00093703          	ld	a4,0(s2)
ffffffffc0202038:	97aa                	add	a5,a5,a0
ffffffffc020203a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020203e:	953a                	add	a0,a0,a4
ffffffffc0202040:	4585                	li	a1,1
ffffffffc0202042:	eb4ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202046:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020204a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020204c:	050a                	slli	a0,a0,0x2
ffffffffc020204e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202050:	0cf57d63          	bleu	a5,a0,ffffffffc020212a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202054:	013507b3          	add	a5,a0,s3
ffffffffc0202058:	00379513          	slli	a0,a5,0x3
ffffffffc020205c:	00093703          	ld	a4,0(s2)
ffffffffc0202060:	953e                	add	a0,a0,a5
ffffffffc0202062:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202064:	4585                	li	a1,1
ffffffffc0202066:	953a                	add	a0,a0,a4
ffffffffc0202068:	e8eff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020206c:	601c                	ld	a5,0(s0)
ffffffffc020206e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202072:	ecaff0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0202076:	38ab1a63          	bne	s6,a0,ffffffffc020240a <pmm_init+0x8e4>
}
ffffffffc020207a:	6446                	ld	s0,80(sp)
ffffffffc020207c:	60e6                	ld	ra,88(sp)
ffffffffc020207e:	64a6                	ld	s1,72(sp)
ffffffffc0202080:	6906                	ld	s2,64(sp)
ffffffffc0202082:	79e2                	ld	s3,56(sp)
ffffffffc0202084:	7a42                	ld	s4,48(sp)
ffffffffc0202086:	7aa2                	ld	s5,40(sp)
ffffffffc0202088:	7b02                	ld	s6,32(sp)
ffffffffc020208a:	6be2                	ld	s7,24(sp)
ffffffffc020208c:	6c42                	ld	s8,16(sp)
ffffffffc020208e:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202090:	00003517          	auipc	a0,0x3
ffffffffc0202094:	4e050513          	addi	a0,a0,1248 # ffffffffc0205570 <default_pmm_manager+0x680>
}
ffffffffc0202098:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020209a:	824fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020209e:	6705                	lui	a4,0x1
ffffffffc02020a0:	177d                	addi	a4,a4,-1
ffffffffc02020a2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02020a4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020a8:	08f77163          	bleu	a5,a4,ffffffffc020212a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02020ac:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02020b0:	9732                	add	a4,a4,a2
ffffffffc02020b2:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020b6:	767d                	lui	a2,0xfffff
ffffffffc02020b8:	8ef1                	and	a3,a3,a2
ffffffffc02020ba:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02020bc:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020c0:	8d95                	sub	a1,a1,a3
ffffffffc02020c2:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020c4:	81b1                	srli	a1,a1,0xc
ffffffffc02020c6:	953e                	add	a0,a0,a5
ffffffffc02020c8:	9702                	jalr	a4
ffffffffc02020ca:	bead                	j	ffffffffc0201c44 <pmm_init+0x11e>
ffffffffc02020cc:	6008                	ld	a0,0(s0)
ffffffffc02020ce:	b5b5                	j	ffffffffc0201f3a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02020d0:	86d2                	mv	a3,s4
ffffffffc02020d2:	00003617          	auipc	a2,0x3
ffffffffc02020d6:	e6e60613          	addi	a2,a2,-402 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc02020da:	1cd00593          	li	a1,461
ffffffffc02020de:	00003517          	auipc	a0,0x3
ffffffffc02020e2:	e8a50513          	addi	a0,a0,-374 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02020e6:	a8efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02020ea:	00003697          	auipc	a3,0x3
ffffffffc02020ee:	2f668693          	addi	a3,a3,758 # ffffffffc02053e0 <default_pmm_manager+0x4f0>
ffffffffc02020f2:	00003617          	auipc	a2,0x3
ffffffffc02020f6:	a6660613          	addi	a2,a2,-1434 # ffffffffc0204b58 <commands+0x870>
ffffffffc02020fa:	1cd00593          	li	a1,461
ffffffffc02020fe:	00003517          	auipc	a0,0x3
ffffffffc0202102:	e6a50513          	addi	a0,a0,-406 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202106:	a6efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020210a:	00003697          	auipc	a3,0x3
ffffffffc020210e:	31668693          	addi	a3,a3,790 # ffffffffc0205420 <default_pmm_manager+0x530>
ffffffffc0202112:	00003617          	auipc	a2,0x3
ffffffffc0202116:	a4660613          	addi	a2,a2,-1466 # ffffffffc0204b58 <commands+0x870>
ffffffffc020211a:	1ce00593          	li	a1,462
ffffffffc020211e:	00003517          	auipc	a0,0x3
ffffffffc0202122:	e4a50513          	addi	a0,a0,-438 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202126:	a4efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020212a:	d28ff0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020212e:	00003617          	auipc	a2,0x3
ffffffffc0202132:	e1260613          	addi	a2,a2,-494 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc0202136:	06a00593          	li	a1,106
ffffffffc020213a:	00003517          	auipc	a0,0x3
ffffffffc020213e:	e9e50513          	addi	a0,a0,-354 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc0202142:	a32fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202146:	00003617          	auipc	a2,0x3
ffffffffc020214a:	06a60613          	addi	a2,a2,106 # ffffffffc02051b0 <default_pmm_manager+0x2c0>
ffffffffc020214e:	07000593          	li	a1,112
ffffffffc0202152:	00003517          	auipc	a0,0x3
ffffffffc0202156:	e8650513          	addi	a0,a0,-378 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc020215a:	a1afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020215e:	00003697          	auipc	a3,0x3
ffffffffc0202162:	f9268693          	addi	a3,a3,-110 # ffffffffc02050f0 <default_pmm_manager+0x200>
ffffffffc0202166:	00003617          	auipc	a2,0x3
ffffffffc020216a:	9f260613          	addi	a2,a2,-1550 # ffffffffc0204b58 <commands+0x870>
ffffffffc020216e:	19300593          	li	a1,403
ffffffffc0202172:	00003517          	auipc	a0,0x3
ffffffffc0202176:	df650513          	addi	a0,a0,-522 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020217a:	9fafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020217e:	00003697          	auipc	a3,0x3
ffffffffc0202182:	faa68693          	addi	a3,a3,-86 # ffffffffc0205128 <default_pmm_manager+0x238>
ffffffffc0202186:	00003617          	auipc	a2,0x3
ffffffffc020218a:	9d260613          	addi	a2,a2,-1582 # ffffffffc0204b58 <commands+0x870>
ffffffffc020218e:	19400593          	li	a1,404
ffffffffc0202192:	00003517          	auipc	a0,0x3
ffffffffc0202196:	dd650513          	addi	a0,a0,-554 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020219a:	9dafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020219e:	00003697          	auipc	a3,0x3
ffffffffc02021a2:	20268693          	addi	a3,a3,514 # ffffffffc02053a0 <default_pmm_manager+0x4b0>
ffffffffc02021a6:	00003617          	auipc	a2,0x3
ffffffffc02021aa:	9b260613          	addi	a2,a2,-1614 # ffffffffc0204b58 <commands+0x870>
ffffffffc02021ae:	1c000593          	li	a1,448
ffffffffc02021b2:	00003517          	auipc	a0,0x3
ffffffffc02021b6:	db650513          	addi	a0,a0,-586 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02021ba:	9bafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021be:	00003617          	auipc	a2,0x3
ffffffffc02021c2:	eca60613          	addi	a2,a2,-310 # ffffffffc0205088 <default_pmm_manager+0x198>
ffffffffc02021c6:	07700593          	li	a1,119
ffffffffc02021ca:	00003517          	auipc	a0,0x3
ffffffffc02021ce:	d9e50513          	addi	a0,a0,-610 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02021d2:	9a2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02021d6:	00003697          	auipc	a3,0x3
ffffffffc02021da:	faa68693          	addi	a3,a3,-86 # ffffffffc0205180 <default_pmm_manager+0x290>
ffffffffc02021de:	00003617          	auipc	a2,0x3
ffffffffc02021e2:	97a60613          	addi	a2,a2,-1670 # ffffffffc0204b58 <commands+0x870>
ffffffffc02021e6:	19a00593          	li	a1,410
ffffffffc02021ea:	00003517          	auipc	a0,0x3
ffffffffc02021ee:	d7e50513          	addi	a0,a0,-642 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02021f2:	982fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02021f6:	00003697          	auipc	a3,0x3
ffffffffc02021fa:	f5a68693          	addi	a3,a3,-166 # ffffffffc0205150 <default_pmm_manager+0x260>
ffffffffc02021fe:	00003617          	auipc	a2,0x3
ffffffffc0202202:	95a60613          	addi	a2,a2,-1702 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202206:	19800593          	li	a1,408
ffffffffc020220a:	00003517          	auipc	a0,0x3
ffffffffc020220e:	d5e50513          	addi	a0,a0,-674 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202212:	962fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202216:	00003697          	auipc	a3,0x3
ffffffffc020221a:	08268693          	addi	a3,a3,130 # ffffffffc0205298 <default_pmm_manager+0x3a8>
ffffffffc020221e:	00003617          	auipc	a2,0x3
ffffffffc0202222:	93a60613          	addi	a2,a2,-1734 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202226:	1a500593          	li	a1,421
ffffffffc020222a:	00003517          	auipc	a0,0x3
ffffffffc020222e:	d3e50513          	addi	a0,a0,-706 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202232:	942fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202236:	00003697          	auipc	a3,0x3
ffffffffc020223a:	03268693          	addi	a3,a3,50 # ffffffffc0205268 <default_pmm_manager+0x378>
ffffffffc020223e:	00003617          	auipc	a2,0x3
ffffffffc0202242:	91a60613          	addi	a2,a2,-1766 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202246:	1a400593          	li	a1,420
ffffffffc020224a:	00003517          	auipc	a0,0x3
ffffffffc020224e:	d1e50513          	addi	a0,a0,-738 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202252:	922fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202256:	00003697          	auipc	a3,0x3
ffffffffc020225a:	fda68693          	addi	a3,a3,-38 # ffffffffc0205230 <default_pmm_manager+0x340>
ffffffffc020225e:	00003617          	auipc	a2,0x3
ffffffffc0202262:	8fa60613          	addi	a2,a2,-1798 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202266:	1a300593          	li	a1,419
ffffffffc020226a:	00003517          	auipc	a0,0x3
ffffffffc020226e:	cfe50513          	addi	a0,a0,-770 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202272:	902fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202276:	00003697          	auipc	a3,0x3
ffffffffc020227a:	f9268693          	addi	a3,a3,-110 # ffffffffc0205208 <default_pmm_manager+0x318>
ffffffffc020227e:	00003617          	auipc	a2,0x3
ffffffffc0202282:	8da60613          	addi	a2,a2,-1830 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202286:	1a000593          	li	a1,416
ffffffffc020228a:	00003517          	auipc	a0,0x3
ffffffffc020228e:	cde50513          	addi	a0,a0,-802 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202292:	8e2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202296:	86da                	mv	a3,s6
ffffffffc0202298:	00003617          	auipc	a2,0x3
ffffffffc020229c:	ca860613          	addi	a2,a2,-856 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc02022a0:	19f00593          	li	a1,415
ffffffffc02022a4:	00003517          	auipc	a0,0x3
ffffffffc02022a8:	cc450513          	addi	a0,a0,-828 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02022ac:	8c8fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022b0:	86be                	mv	a3,a5
ffffffffc02022b2:	00003617          	auipc	a2,0x3
ffffffffc02022b6:	c8e60613          	addi	a2,a2,-882 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc02022ba:	19e00593          	li	a1,414
ffffffffc02022be:	00003517          	auipc	a0,0x3
ffffffffc02022c2:	caa50513          	addi	a0,a0,-854 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02022c6:	8aefe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02022ca:	00003697          	auipc	a3,0x3
ffffffffc02022ce:	f2668693          	addi	a3,a3,-218 # ffffffffc02051f0 <default_pmm_manager+0x300>
ffffffffc02022d2:	00003617          	auipc	a2,0x3
ffffffffc02022d6:	88660613          	addi	a2,a2,-1914 # ffffffffc0204b58 <commands+0x870>
ffffffffc02022da:	19c00593          	li	a1,412
ffffffffc02022de:	00003517          	auipc	a0,0x3
ffffffffc02022e2:	c8a50513          	addi	a0,a0,-886 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02022e6:	88efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022ea:	00003697          	auipc	a3,0x3
ffffffffc02022ee:	eee68693          	addi	a3,a3,-274 # ffffffffc02051d8 <default_pmm_manager+0x2e8>
ffffffffc02022f2:	00003617          	auipc	a2,0x3
ffffffffc02022f6:	86660613          	addi	a2,a2,-1946 # ffffffffc0204b58 <commands+0x870>
ffffffffc02022fa:	19b00593          	li	a1,411
ffffffffc02022fe:	00003517          	auipc	a0,0x3
ffffffffc0202302:	c6a50513          	addi	a0,a0,-918 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202306:	86efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020230a:	00003697          	auipc	a3,0x3
ffffffffc020230e:	ece68693          	addi	a3,a3,-306 # ffffffffc02051d8 <default_pmm_manager+0x2e8>
ffffffffc0202312:	00003617          	auipc	a2,0x3
ffffffffc0202316:	84660613          	addi	a2,a2,-1978 # ffffffffc0204b58 <commands+0x870>
ffffffffc020231a:	1ae00593          	li	a1,430
ffffffffc020231e:	00003517          	auipc	a0,0x3
ffffffffc0202322:	c4a50513          	addi	a0,a0,-950 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202326:	84efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020232a:	00003697          	auipc	a3,0x3
ffffffffc020232e:	f3e68693          	addi	a3,a3,-194 # ffffffffc0205268 <default_pmm_manager+0x378>
ffffffffc0202332:	00003617          	auipc	a2,0x3
ffffffffc0202336:	82660613          	addi	a2,a2,-2010 # ffffffffc0204b58 <commands+0x870>
ffffffffc020233a:	1ad00593          	li	a1,429
ffffffffc020233e:	00003517          	auipc	a0,0x3
ffffffffc0202342:	c2a50513          	addi	a0,a0,-982 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202346:	82efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020234a:	00003697          	auipc	a3,0x3
ffffffffc020234e:	fe668693          	addi	a3,a3,-26 # ffffffffc0205330 <default_pmm_manager+0x440>
ffffffffc0202352:	00003617          	auipc	a2,0x3
ffffffffc0202356:	80660613          	addi	a2,a2,-2042 # ffffffffc0204b58 <commands+0x870>
ffffffffc020235a:	1ac00593          	li	a1,428
ffffffffc020235e:	00003517          	auipc	a0,0x3
ffffffffc0202362:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202366:	80efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020236a:	00003697          	auipc	a3,0x3
ffffffffc020236e:	fae68693          	addi	a3,a3,-82 # ffffffffc0205318 <default_pmm_manager+0x428>
ffffffffc0202372:	00002617          	auipc	a2,0x2
ffffffffc0202376:	7e660613          	addi	a2,a2,2022 # ffffffffc0204b58 <commands+0x870>
ffffffffc020237a:	1ab00593          	li	a1,427
ffffffffc020237e:	00003517          	auipc	a0,0x3
ffffffffc0202382:	bea50513          	addi	a0,a0,-1046 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202386:	feffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020238a:	00003697          	auipc	a3,0x3
ffffffffc020238e:	f5e68693          	addi	a3,a3,-162 # ffffffffc02052e8 <default_pmm_manager+0x3f8>
ffffffffc0202392:	00002617          	auipc	a2,0x2
ffffffffc0202396:	7c660613          	addi	a2,a2,1990 # ffffffffc0204b58 <commands+0x870>
ffffffffc020239a:	1aa00593          	li	a1,426
ffffffffc020239e:	00003517          	auipc	a0,0x3
ffffffffc02023a2:	bca50513          	addi	a0,a0,-1078 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02023a6:	fcffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023aa:	00003697          	auipc	a3,0x3
ffffffffc02023ae:	f2668693          	addi	a3,a3,-218 # ffffffffc02052d0 <default_pmm_manager+0x3e0>
ffffffffc02023b2:	00002617          	auipc	a2,0x2
ffffffffc02023b6:	7a660613          	addi	a2,a2,1958 # ffffffffc0204b58 <commands+0x870>
ffffffffc02023ba:	1a800593          	li	a1,424
ffffffffc02023be:	00003517          	auipc	a0,0x3
ffffffffc02023c2:	baa50513          	addi	a0,a0,-1110 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02023c6:	faffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023ca:	00003697          	auipc	a3,0x3
ffffffffc02023ce:	eee68693          	addi	a3,a3,-274 # ffffffffc02052b8 <default_pmm_manager+0x3c8>
ffffffffc02023d2:	00002617          	auipc	a2,0x2
ffffffffc02023d6:	78660613          	addi	a2,a2,1926 # ffffffffc0204b58 <commands+0x870>
ffffffffc02023da:	1a700593          	li	a1,423
ffffffffc02023de:	00003517          	auipc	a0,0x3
ffffffffc02023e2:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02023e6:	f8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023ea:	00003697          	auipc	a3,0x3
ffffffffc02023ee:	ebe68693          	addi	a3,a3,-322 # ffffffffc02052a8 <default_pmm_manager+0x3b8>
ffffffffc02023f2:	00002617          	auipc	a2,0x2
ffffffffc02023f6:	76660613          	addi	a2,a2,1894 # ffffffffc0204b58 <commands+0x870>
ffffffffc02023fa:	1a600593          	li	a1,422
ffffffffc02023fe:	00003517          	auipc	a0,0x3
ffffffffc0202402:	b6a50513          	addi	a0,a0,-1174 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202406:	f6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020240a:	00003697          	auipc	a3,0x3
ffffffffc020240e:	f9668693          	addi	a3,a3,-106 # ffffffffc02053a0 <default_pmm_manager+0x4b0>
ffffffffc0202412:	00002617          	auipc	a2,0x2
ffffffffc0202416:	74660613          	addi	a2,a2,1862 # ffffffffc0204b58 <commands+0x870>
ffffffffc020241a:	1e800593          	li	a1,488
ffffffffc020241e:	00003517          	auipc	a0,0x3
ffffffffc0202422:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202426:	f4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020242a:	00003697          	auipc	a3,0x3
ffffffffc020242e:	11e68693          	addi	a3,a3,286 # ffffffffc0205548 <default_pmm_manager+0x658>
ffffffffc0202432:	00002617          	auipc	a2,0x2
ffffffffc0202436:	72660613          	addi	a2,a2,1830 # ffffffffc0204b58 <commands+0x870>
ffffffffc020243a:	1e000593          	li	a1,480
ffffffffc020243e:	00003517          	auipc	a0,0x3
ffffffffc0202442:	b2a50513          	addi	a0,a0,-1238 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202446:	f2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020244a:	00003697          	auipc	a3,0x3
ffffffffc020244e:	0c668693          	addi	a3,a3,198 # ffffffffc0205510 <default_pmm_manager+0x620>
ffffffffc0202452:	00002617          	auipc	a2,0x2
ffffffffc0202456:	70660613          	addi	a2,a2,1798 # ffffffffc0204b58 <commands+0x870>
ffffffffc020245a:	1dd00593          	li	a1,477
ffffffffc020245e:	00003517          	auipc	a0,0x3
ffffffffc0202462:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202466:	f0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020246a:	00003697          	auipc	a3,0x3
ffffffffc020246e:	07668693          	addi	a3,a3,118 # ffffffffc02054e0 <default_pmm_manager+0x5f0>
ffffffffc0202472:	00002617          	auipc	a2,0x2
ffffffffc0202476:	6e660613          	addi	a2,a2,1766 # ffffffffc0204b58 <commands+0x870>
ffffffffc020247a:	1d900593          	li	a1,473
ffffffffc020247e:	00003517          	auipc	a0,0x3
ffffffffc0202482:	aea50513          	addi	a0,a0,-1302 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202486:	eeffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020248a:	00003697          	auipc	a3,0x3
ffffffffc020248e:	ed668693          	addi	a3,a3,-298 # ffffffffc0205360 <default_pmm_manager+0x470>
ffffffffc0202492:	00002617          	auipc	a2,0x2
ffffffffc0202496:	6c660613          	addi	a2,a2,1734 # ffffffffc0204b58 <commands+0x870>
ffffffffc020249a:	1b600593          	li	a1,438
ffffffffc020249e:	00003517          	auipc	a0,0x3
ffffffffc02024a2:	aca50513          	addi	a0,a0,-1334 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02024a6:	ecffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024aa:	00003697          	auipc	a3,0x3
ffffffffc02024ae:	e8668693          	addi	a3,a3,-378 # ffffffffc0205330 <default_pmm_manager+0x440>
ffffffffc02024b2:	00002617          	auipc	a2,0x2
ffffffffc02024b6:	6a660613          	addi	a2,a2,1702 # ffffffffc0204b58 <commands+0x870>
ffffffffc02024ba:	1b300593          	li	a1,435
ffffffffc02024be:	00003517          	auipc	a0,0x3
ffffffffc02024c2:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02024c6:	eaffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024ca:	00003697          	auipc	a3,0x3
ffffffffc02024ce:	d2668693          	addi	a3,a3,-730 # ffffffffc02051f0 <default_pmm_manager+0x300>
ffffffffc02024d2:	00002617          	auipc	a2,0x2
ffffffffc02024d6:	68660613          	addi	a2,a2,1670 # ffffffffc0204b58 <commands+0x870>
ffffffffc02024da:	1b200593          	li	a1,434
ffffffffc02024de:	00003517          	auipc	a0,0x3
ffffffffc02024e2:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02024e6:	e8ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ea:	00003697          	auipc	a3,0x3
ffffffffc02024ee:	e5e68693          	addi	a3,a3,-418 # ffffffffc0205348 <default_pmm_manager+0x458>
ffffffffc02024f2:	00002617          	auipc	a2,0x2
ffffffffc02024f6:	66660613          	addi	a2,a2,1638 # ffffffffc0204b58 <commands+0x870>
ffffffffc02024fa:	1af00593          	li	a1,431
ffffffffc02024fe:	00003517          	auipc	a0,0x3
ffffffffc0202502:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202506:	e6ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020250a:	00003697          	auipc	a3,0x3
ffffffffc020250e:	e6e68693          	addi	a3,a3,-402 # ffffffffc0205378 <default_pmm_manager+0x488>
ffffffffc0202512:	00002617          	auipc	a2,0x2
ffffffffc0202516:	64660613          	addi	a2,a2,1606 # ffffffffc0204b58 <commands+0x870>
ffffffffc020251a:	1b900593          	li	a1,441
ffffffffc020251e:	00003517          	auipc	a0,0x3
ffffffffc0202522:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202526:	e4ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020252a:	00003697          	auipc	a3,0x3
ffffffffc020252e:	e0668693          	addi	a3,a3,-506 # ffffffffc0205330 <default_pmm_manager+0x440>
ffffffffc0202532:	00002617          	auipc	a2,0x2
ffffffffc0202536:	62660613          	addi	a2,a2,1574 # ffffffffc0204b58 <commands+0x870>
ffffffffc020253a:	1b700593          	li	a1,439
ffffffffc020253e:	00003517          	auipc	a0,0x3
ffffffffc0202542:	a2a50513          	addi	a0,a0,-1494 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202546:	e2ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020254a:	00003697          	auipc	a3,0x3
ffffffffc020254e:	b8668693          	addi	a3,a3,-1146 # ffffffffc02050d0 <default_pmm_manager+0x1e0>
ffffffffc0202552:	00002617          	auipc	a2,0x2
ffffffffc0202556:	60660613          	addi	a2,a2,1542 # ffffffffc0204b58 <commands+0x870>
ffffffffc020255a:	19200593          	li	a1,402
ffffffffc020255e:	00003517          	auipc	a0,0x3
ffffffffc0202562:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202566:	e0ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020256a:	00003617          	auipc	a2,0x3
ffffffffc020256e:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0205088 <default_pmm_manager+0x198>
ffffffffc0202572:	0bd00593          	li	a1,189
ffffffffc0202576:	00003517          	auipc	a0,0x3
ffffffffc020257a:	9f250513          	addi	a0,a0,-1550 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020257e:	df7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202582:	00003697          	auipc	a3,0x3
ffffffffc0202586:	f1e68693          	addi	a3,a3,-226 # ffffffffc02054a0 <default_pmm_manager+0x5b0>
ffffffffc020258a:	00002617          	auipc	a2,0x2
ffffffffc020258e:	5ce60613          	addi	a2,a2,1486 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202592:	1d800593          	li	a1,472
ffffffffc0202596:	00003517          	auipc	a0,0x3
ffffffffc020259a:	9d250513          	addi	a0,a0,-1582 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020259e:	dd7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025a2:	00003697          	auipc	a3,0x3
ffffffffc02025a6:	ee668693          	addi	a3,a3,-282 # ffffffffc0205488 <default_pmm_manager+0x598>
ffffffffc02025aa:	00002617          	auipc	a2,0x2
ffffffffc02025ae:	5ae60613          	addi	a2,a2,1454 # ffffffffc0204b58 <commands+0x870>
ffffffffc02025b2:	1d700593          	li	a1,471
ffffffffc02025b6:	00003517          	auipc	a0,0x3
ffffffffc02025ba:	9b250513          	addi	a0,a0,-1614 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02025be:	db7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025c2:	00003697          	auipc	a3,0x3
ffffffffc02025c6:	e8e68693          	addi	a3,a3,-370 # ffffffffc0205450 <default_pmm_manager+0x560>
ffffffffc02025ca:	00002617          	auipc	a2,0x2
ffffffffc02025ce:	58e60613          	addi	a2,a2,1422 # ffffffffc0204b58 <commands+0x870>
ffffffffc02025d2:	1d600593          	li	a1,470
ffffffffc02025d6:	00003517          	auipc	a0,0x3
ffffffffc02025da:	99250513          	addi	a0,a0,-1646 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02025de:	d97fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025e2:	00003697          	auipc	a3,0x3
ffffffffc02025e6:	e5668693          	addi	a3,a3,-426 # ffffffffc0205438 <default_pmm_manager+0x548>
ffffffffc02025ea:	00002617          	auipc	a2,0x2
ffffffffc02025ee:	56e60613          	addi	a2,a2,1390 # ffffffffc0204b58 <commands+0x870>
ffffffffc02025f2:	1d200593          	li	a1,466
ffffffffc02025f6:	00003517          	auipc	a0,0x3
ffffffffc02025fa:	97250513          	addi	a0,a0,-1678 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02025fe:	d77fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202602 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202602:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202606:	8082                	ret

ffffffffc0202608 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202608:	7179                	addi	sp,sp,-48
ffffffffc020260a:	e84a                	sd	s2,16(sp)
ffffffffc020260c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020260e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202610:	f022                	sd	s0,32(sp)
ffffffffc0202612:	ec26                	sd	s1,24(sp)
ffffffffc0202614:	e44e                	sd	s3,8(sp)
ffffffffc0202616:	f406                	sd	ra,40(sp)
ffffffffc0202618:	84ae                	mv	s1,a1
ffffffffc020261a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020261c:	852ff0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc0202620:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202622:	cd19                	beqz	a0,ffffffffc0202640 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202624:	85aa                	mv	a1,a0
ffffffffc0202626:	86ce                	mv	a3,s3
ffffffffc0202628:	8626                	mv	a2,s1
ffffffffc020262a:	854a                	mv	a0,s2
ffffffffc020262c:	c28ff0ef          	jal	ra,ffffffffc0201a54 <page_insert>
ffffffffc0202630:	ed39                	bnez	a0,ffffffffc020268e <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202632:	0000f797          	auipc	a5,0xf
ffffffffc0202636:	e3678793          	addi	a5,a5,-458 # ffffffffc0211468 <swap_init_ok>
ffffffffc020263a:	439c                	lw	a5,0(a5)
ffffffffc020263c:	2781                	sext.w	a5,a5
ffffffffc020263e:	eb89                	bnez	a5,ffffffffc0202650 <pgdir_alloc_page+0x48>
}
ffffffffc0202640:	8522                	mv	a0,s0
ffffffffc0202642:	70a2                	ld	ra,40(sp)
ffffffffc0202644:	7402                	ld	s0,32(sp)
ffffffffc0202646:	64e2                	ld	s1,24(sp)
ffffffffc0202648:	6942                	ld	s2,16(sp)
ffffffffc020264a:	69a2                	ld	s3,8(sp)
ffffffffc020264c:	6145                	addi	sp,sp,48
ffffffffc020264e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202650:	0000f797          	auipc	a5,0xf
ffffffffc0202654:	f4078793          	addi	a5,a5,-192 # ffffffffc0211590 <check_mm_struct>
ffffffffc0202658:	6388                	ld	a0,0(a5)
ffffffffc020265a:	4681                	li	a3,0
ffffffffc020265c:	8622                	mv	a2,s0
ffffffffc020265e:	85a6                	mv	a1,s1
ffffffffc0202660:	07d000ef          	jal	ra,ffffffffc0202edc <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202664:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202666:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202668:	4785                	li	a5,1
ffffffffc020266a:	fcf70be3          	beq	a4,a5,ffffffffc0202640 <pgdir_alloc_page+0x38>
ffffffffc020266e:	00003697          	auipc	a3,0x3
ffffffffc0202672:	97a68693          	addi	a3,a3,-1670 # ffffffffc0204fe8 <default_pmm_manager+0xf8>
ffffffffc0202676:	00002617          	auipc	a2,0x2
ffffffffc020267a:	4e260613          	addi	a2,a2,1250 # ffffffffc0204b58 <commands+0x870>
ffffffffc020267e:	17a00593          	li	a1,378
ffffffffc0202682:	00003517          	auipc	a0,0x3
ffffffffc0202686:	8e650513          	addi	a0,a0,-1818 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020268a:	cebfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc020268e:	8522                	mv	a0,s0
ffffffffc0202690:	4585                	li	a1,1
ffffffffc0202692:	864ff0ef          	jal	ra,ffffffffc02016f6 <free_pages>
            return NULL;
ffffffffc0202696:	4401                	li	s0,0
ffffffffc0202698:	b765                	j	ffffffffc0202640 <pgdir_alloc_page+0x38>

ffffffffc020269a <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc020269a:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020269c:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc020269e:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026a0:	fff50713          	addi	a4,a0,-1
ffffffffc02026a4:	17f9                	addi	a5,a5,-2
ffffffffc02026a6:	04e7ee63          	bltu	a5,a4,ffffffffc0202702 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02026aa:	6785                	lui	a5,0x1
ffffffffc02026ac:	17fd                	addi	a5,a5,-1
ffffffffc02026ae:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02026b0:	8131                	srli	a0,a0,0xc
ffffffffc02026b2:	fbdfe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
    assert(base != NULL);
ffffffffc02026b6:	c159                	beqz	a0,ffffffffc020273c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026b8:	0000f797          	auipc	a5,0xf
ffffffffc02026bc:	df078793          	addi	a5,a5,-528 # ffffffffc02114a8 <pages>
ffffffffc02026c0:	639c                	ld	a5,0(a5)
ffffffffc02026c2:	8d1d                	sub	a0,a0,a5
ffffffffc02026c4:	00002797          	auipc	a5,0x2
ffffffffc02026c8:	47c78793          	addi	a5,a5,1148 # ffffffffc0204b40 <commands+0x858>
ffffffffc02026cc:	6394                	ld	a3,0(a5)
ffffffffc02026ce:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026d0:	0000f797          	auipc	a5,0xf
ffffffffc02026d4:	d8878793          	addi	a5,a5,-632 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026d8:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026dc:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026de:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026e2:	57fd                	li	a5,-1
ffffffffc02026e4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026e6:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026e8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02026ea:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026ec:	02e7fb63          	bleu	a4,a5,ffffffffc0202722 <kmalloc+0x88>
ffffffffc02026f0:	0000f797          	auipc	a5,0xf
ffffffffc02026f4:	da878793          	addi	a5,a5,-600 # ffffffffc0211498 <va_pa_offset>
ffffffffc02026f8:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02026fa:	60a2                	ld	ra,8(sp)
ffffffffc02026fc:	953e                	add	a0,a0,a5
ffffffffc02026fe:	0141                	addi	sp,sp,16
ffffffffc0202700:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202702:	00003697          	auipc	a3,0x3
ffffffffc0202706:	88668693          	addi	a3,a3,-1914 # ffffffffc0204f88 <default_pmm_manager+0x98>
ffffffffc020270a:	00002617          	auipc	a2,0x2
ffffffffc020270e:	44e60613          	addi	a2,a2,1102 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202712:	1f000593          	li	a1,496
ffffffffc0202716:	00003517          	auipc	a0,0x3
ffffffffc020271a:	85250513          	addi	a0,a0,-1966 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc020271e:	c57fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202722:	86aa                	mv	a3,a0
ffffffffc0202724:	00003617          	auipc	a2,0x3
ffffffffc0202728:	81c60613          	addi	a2,a2,-2020 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc020272c:	06a00593          	li	a1,106
ffffffffc0202730:	00003517          	auipc	a0,0x3
ffffffffc0202734:	8a850513          	addi	a0,a0,-1880 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc0202738:	c3dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020273c:	00003697          	auipc	a3,0x3
ffffffffc0202740:	86c68693          	addi	a3,a3,-1940 # ffffffffc0204fa8 <default_pmm_manager+0xb8>
ffffffffc0202744:	00002617          	auipc	a2,0x2
ffffffffc0202748:	41460613          	addi	a2,a2,1044 # ffffffffc0204b58 <commands+0x870>
ffffffffc020274c:	1f300593          	li	a1,499
ffffffffc0202750:	00003517          	auipc	a0,0x3
ffffffffc0202754:	81850513          	addi	a0,a0,-2024 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202758:	c1dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020275c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020275c:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020275e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202760:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202762:	fff58713          	addi	a4,a1,-1
ffffffffc0202766:	17f9                	addi	a5,a5,-2
ffffffffc0202768:	04e7eb63          	bltu	a5,a4,ffffffffc02027be <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020276c:	c941                	beqz	a0,ffffffffc02027fc <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020276e:	6785                	lui	a5,0x1
ffffffffc0202770:	17fd                	addi	a5,a5,-1
ffffffffc0202772:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202774:	c02007b7          	lui	a5,0xc0200
ffffffffc0202778:	81b1                	srli	a1,a1,0xc
ffffffffc020277a:	06f56463          	bltu	a0,a5,ffffffffc02027e2 <kfree+0x86>
ffffffffc020277e:	0000f797          	auipc	a5,0xf
ffffffffc0202782:	d1a78793          	addi	a5,a5,-742 # ffffffffc0211498 <va_pa_offset>
ffffffffc0202786:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202788:	0000f717          	auipc	a4,0xf
ffffffffc020278c:	cd070713          	addi	a4,a4,-816 # ffffffffc0211458 <npage>
ffffffffc0202790:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202792:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202796:	83b1                	srli	a5,a5,0xc
ffffffffc0202798:	04e7f363          	bleu	a4,a5,ffffffffc02027de <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc020279c:	fff80537          	lui	a0,0xfff80
ffffffffc02027a0:	97aa                	add	a5,a5,a0
ffffffffc02027a2:	0000f697          	auipc	a3,0xf
ffffffffc02027a6:	d0668693          	addi	a3,a3,-762 # ffffffffc02114a8 <pages>
ffffffffc02027aa:	6288                	ld	a0,0(a3)
ffffffffc02027ac:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02027b0:	60a2                	ld	ra,8(sp)
ffffffffc02027b2:	97ba                	add	a5,a5,a4
ffffffffc02027b4:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc02027b6:	953e                	add	a0,a0,a5
}
ffffffffc02027b8:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc02027ba:	f3dfe06f          	j	ffffffffc02016f6 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027be:	00002697          	auipc	a3,0x2
ffffffffc02027c2:	7ca68693          	addi	a3,a3,1994 # ffffffffc0204f88 <default_pmm_manager+0x98>
ffffffffc02027c6:	00002617          	auipc	a2,0x2
ffffffffc02027ca:	39260613          	addi	a2,a2,914 # ffffffffc0204b58 <commands+0x870>
ffffffffc02027ce:	1f900593          	li	a1,505
ffffffffc02027d2:	00002517          	auipc	a0,0x2
ffffffffc02027d6:	79650513          	addi	a0,a0,1942 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc02027da:	b9bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02027de:	e75fe0ef          	jal	ra,ffffffffc0201652 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027e2:	86aa                	mv	a3,a0
ffffffffc02027e4:	00003617          	auipc	a2,0x3
ffffffffc02027e8:	8a460613          	addi	a2,a2,-1884 # ffffffffc0205088 <default_pmm_manager+0x198>
ffffffffc02027ec:	06c00593          	li	a1,108
ffffffffc02027f0:	00002517          	auipc	a0,0x2
ffffffffc02027f4:	7e850513          	addi	a0,a0,2024 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc02027f8:	b7dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc02027fc:	00002697          	auipc	a3,0x2
ffffffffc0202800:	77c68693          	addi	a3,a3,1916 # ffffffffc0204f78 <default_pmm_manager+0x88>
ffffffffc0202804:	00002617          	auipc	a2,0x2
ffffffffc0202808:	35460613          	addi	a2,a2,852 # ffffffffc0204b58 <commands+0x870>
ffffffffc020280c:	1fa00593          	li	a1,506
ffffffffc0202810:	00002517          	auipc	a0,0x2
ffffffffc0202814:	75850513          	addi	a0,a0,1880 # ffffffffc0204f68 <default_pmm_manager+0x78>
ffffffffc0202818:	b5dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020281c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020281c:	7135                	addi	sp,sp,-160
ffffffffc020281e:	ed06                	sd	ra,152(sp)
ffffffffc0202820:	e922                	sd	s0,144(sp)
ffffffffc0202822:	e526                	sd	s1,136(sp)
ffffffffc0202824:	e14a                	sd	s2,128(sp)
ffffffffc0202826:	fcce                	sd	s3,120(sp)
ffffffffc0202828:	f8d2                	sd	s4,112(sp)
ffffffffc020282a:	f4d6                	sd	s5,104(sp)
ffffffffc020282c:	f0da                	sd	s6,96(sp)
ffffffffc020282e:	ecde                	sd	s7,88(sp)
ffffffffc0202830:	e8e2                	sd	s8,80(sp)
ffffffffc0202832:	e4e6                	sd	s9,72(sp)
ffffffffc0202834:	e0ea                	sd	s10,64(sp)
ffffffffc0202836:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202838:	284010ef          	jal	ra,ffffffffc0203abc <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020283c:	0000f797          	auipc	a5,0xf
ffffffffc0202840:	cfc78793          	addi	a5,a5,-772 # ffffffffc0211538 <max_swap_offset>
ffffffffc0202844:	6394                	ld	a3,0(a5)
ffffffffc0202846:	010007b7          	lui	a5,0x1000
ffffffffc020284a:	17e1                	addi	a5,a5,-8
ffffffffc020284c:	ff968713          	addi	a4,a3,-7
ffffffffc0202850:	42e7ea63          	bltu	a5,a4,ffffffffc0202c84 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc0202854:	00007797          	auipc	a5,0x7
ffffffffc0202858:	7ac78793          	addi	a5,a5,1964 # ffffffffc020a000 <swap_manager_lru>
     int r = sm->init();
ffffffffc020285c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_lru;//use first in first out Page Replacement Algorithm
ffffffffc020285e:	0000f697          	auipc	a3,0xf
ffffffffc0202862:	c0f6b123          	sd	a5,-1022(a3) # ffffffffc0211460 <sm>
     int r = sm->init();
ffffffffc0202866:	9702                	jalr	a4
ffffffffc0202868:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020286a:	c10d                	beqz	a0,ffffffffc020288c <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020286c:	60ea                	ld	ra,152(sp)
ffffffffc020286e:	644a                	ld	s0,144(sp)
ffffffffc0202870:	855a                	mv	a0,s6
ffffffffc0202872:	64aa                	ld	s1,136(sp)
ffffffffc0202874:	690a                	ld	s2,128(sp)
ffffffffc0202876:	79e6                	ld	s3,120(sp)
ffffffffc0202878:	7a46                	ld	s4,112(sp)
ffffffffc020287a:	7aa6                	ld	s5,104(sp)
ffffffffc020287c:	7b06                	ld	s6,96(sp)
ffffffffc020287e:	6be6                	ld	s7,88(sp)
ffffffffc0202880:	6c46                	ld	s8,80(sp)
ffffffffc0202882:	6ca6                	ld	s9,72(sp)
ffffffffc0202884:	6d06                	ld	s10,64(sp)
ffffffffc0202886:	7de2                	ld	s11,56(sp)
ffffffffc0202888:	610d                	addi	sp,sp,160
ffffffffc020288a:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020288c:	0000f797          	auipc	a5,0xf
ffffffffc0202890:	bd478793          	addi	a5,a5,-1068 # ffffffffc0211460 <sm>
ffffffffc0202894:	639c                	ld	a5,0(a5)
ffffffffc0202896:	00003517          	auipc	a0,0x3
ffffffffc020289a:	d7a50513          	addi	a0,a0,-646 # ffffffffc0205610 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc020289e:	0000f417          	auipc	s0,0xf
ffffffffc02028a2:	bda40413          	addi	s0,s0,-1062 # ffffffffc0211478 <free_area>
ffffffffc02028a6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02028a8:	4785                	li	a5,1
ffffffffc02028aa:	0000f717          	auipc	a4,0xf
ffffffffc02028ae:	baf72f23          	sw	a5,-1090(a4) # ffffffffc0211468 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028b2:	80dfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028b6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028b8:	2e878a63          	beq	a5,s0,ffffffffc0202bac <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028bc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02028c0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02028c2:	8b05                	andi	a4,a4,1
ffffffffc02028c4:	2e070863          	beqz	a4,ffffffffc0202bb4 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc02028c8:	4481                	li	s1,0
ffffffffc02028ca:	4901                	li	s2,0
ffffffffc02028cc:	a031                	j	ffffffffc02028d8 <swap_init+0xbc>
ffffffffc02028ce:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc02028d2:	8b09                	andi	a4,a4,2
ffffffffc02028d4:	2e070063          	beqz	a4,ffffffffc0202bb4 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc02028d8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02028dc:	679c                	ld	a5,8(a5)
ffffffffc02028de:	2905                	addiw	s2,s2,1
ffffffffc02028e0:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028e2:	fe8796e3          	bne	a5,s0,ffffffffc02028ce <swap_init+0xb2>
ffffffffc02028e6:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02028e8:	e55fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02028ec:	5b351863          	bne	a0,s3,ffffffffc0202e9c <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02028f0:	8626                	mv	a2,s1
ffffffffc02028f2:	85ca                	mv	a1,s2
ffffffffc02028f4:	00003517          	auipc	a0,0x3
ffffffffc02028f8:	d3450513          	addi	a0,a0,-716 # ffffffffc0205628 <default_pmm_manager+0x738>
ffffffffc02028fc:	fc2fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202900:	1cd000ef          	jal	ra,ffffffffc02032cc <mm_create>
ffffffffc0202904:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202906:	50050b63          	beqz	a0,ffffffffc0202e1c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020290a:	0000f797          	auipc	a5,0xf
ffffffffc020290e:	c8678793          	addi	a5,a5,-890 # ffffffffc0211590 <check_mm_struct>
ffffffffc0202912:	639c                	ld	a5,0(a5)
ffffffffc0202914:	52079463          	bnez	a5,ffffffffc0202e3c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202918:	0000f797          	auipc	a5,0xf
ffffffffc020291c:	b3878793          	addi	a5,a5,-1224 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202920:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202922:	0000f797          	auipc	a5,0xf
ffffffffc0202926:	c6a7b723          	sd	a0,-914(a5) # ffffffffc0211590 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020292a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020292c:	ec3a                	sd	a4,24(sp)
ffffffffc020292e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202930:	52079663          	bnez	a5,ffffffffc0202e5c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202934:	6599                	lui	a1,0x6
ffffffffc0202936:	460d                	li	a2,3
ffffffffc0202938:	6505                	lui	a0,0x1
ffffffffc020293a:	1df000ef          	jal	ra,ffffffffc0203318 <vma_create>
ffffffffc020293e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202940:	52050e63          	beqz	a0,ffffffffc0202e7c <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202944:	855e                	mv	a0,s7
ffffffffc0202946:	23f000ef          	jal	ra,ffffffffc0203384 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020294a:	00003517          	auipc	a0,0x3
ffffffffc020294e:	d4e50513          	addi	a0,a0,-690 # ffffffffc0205698 <default_pmm_manager+0x7a8>
ffffffffc0202952:	f6cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202956:	018bb503          	ld	a0,24(s7)
ffffffffc020295a:	4605                	li	a2,1
ffffffffc020295c:	6585                	lui	a1,0x1
ffffffffc020295e:	e1ffe0ef          	jal	ra,ffffffffc020177c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202962:	40050d63          	beqz	a0,ffffffffc0202d7c <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202966:	00003517          	auipc	a0,0x3
ffffffffc020296a:	d8250513          	addi	a0,a0,-638 # ffffffffc02056e8 <default_pmm_manager+0x7f8>
ffffffffc020296e:	0000fa17          	auipc	s4,0xf
ffffffffc0202972:	b42a0a13          	addi	s4,s4,-1214 # ffffffffc02114b0 <check_rp>
ffffffffc0202976:	f48fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020297a:	0000fa97          	auipc	s5,0xf
ffffffffc020297e:	b56a8a93          	addi	s5,s5,-1194 # ffffffffc02114d0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202982:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202984:	4505                	li	a0,1
ffffffffc0202986:	ce9fe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
ffffffffc020298a:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea68>
          assert(check_rp[i] != NULL );
ffffffffc020298e:	2a050b63          	beqz	a0,ffffffffc0202c44 <swap_init+0x428>
ffffffffc0202992:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202994:	8b89                	andi	a5,a5,2
ffffffffc0202996:	28079763          	bnez	a5,ffffffffc0202c24 <swap_init+0x408>
ffffffffc020299a:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020299c:	ff5994e3          	bne	s3,s5,ffffffffc0202984 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02029a0:	601c                	ld	a5,0(s0)
ffffffffc02029a2:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02029a6:	0000fd17          	auipc	s10,0xf
ffffffffc02029aa:	b0ad0d13          	addi	s10,s10,-1270 # ffffffffc02114b0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029ae:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02029b0:	481c                	lw	a5,16(s0)
ffffffffc02029b2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02029b4:	0000f797          	auipc	a5,0xf
ffffffffc02029b8:	ac87b623          	sd	s0,-1332(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc02029bc:	0000f797          	auipc	a5,0xf
ffffffffc02029c0:	aa87be23          	sd	s0,-1348(a5) # ffffffffc0211478 <free_area>
     nr_free = 0;
ffffffffc02029c4:	0000f797          	auipc	a5,0xf
ffffffffc02029c8:	ac07a223          	sw	zero,-1340(a5) # ffffffffc0211488 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02029cc:	000d3503          	ld	a0,0(s10)
ffffffffc02029d0:	4585                	li	a1,1
ffffffffc02029d2:	0d21                	addi	s10,s10,8
ffffffffc02029d4:	d23fe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029d8:	ff5d1ae3          	bne	s10,s5,ffffffffc02029cc <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02029dc:	01042d03          	lw	s10,16(s0)
ffffffffc02029e0:	4791                	li	a5,4
ffffffffc02029e2:	36fd1d63          	bne	s10,a5,ffffffffc0202d5c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02029e6:	00003517          	auipc	a0,0x3
ffffffffc02029ea:	d8a50513          	addi	a0,a0,-630 # ffffffffc0205770 <default_pmm_manager+0x880>
ffffffffc02029ee:	ed0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029f2:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02029f4:	0000f797          	auipc	a5,0xf
ffffffffc02029f8:	a607ac23          	sw	zero,-1416(a5) # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029fc:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02029fe:	0000f797          	auipc	a5,0xf
ffffffffc0202a02:	a6e78793          	addi	a5,a5,-1426 # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a06:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a0a:	4398                	lw	a4,0(a5)
ffffffffc0202a0c:	4585                	li	a1,1
ffffffffc0202a0e:	2701                	sext.w	a4,a4
ffffffffc0202a10:	30b71663          	bne	a4,a1,ffffffffc0202d1c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a14:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a18:	4394                	lw	a3,0(a5)
ffffffffc0202a1a:	2681                	sext.w	a3,a3
ffffffffc0202a1c:	32e69063          	bne	a3,a4,ffffffffc0202d3c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a20:	6689                	lui	a3,0x2
ffffffffc0202a22:	462d                	li	a2,11
ffffffffc0202a24:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a28:	4398                	lw	a4,0(a5)
ffffffffc0202a2a:	4589                	li	a1,2
ffffffffc0202a2c:	2701                	sext.w	a4,a4
ffffffffc0202a2e:	26b71763          	bne	a4,a1,ffffffffc0202c9c <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a32:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a36:	4394                	lw	a3,0(a5)
ffffffffc0202a38:	2681                	sext.w	a3,a3
ffffffffc0202a3a:	28e69163          	bne	a3,a4,ffffffffc0202cbc <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a3e:	668d                	lui	a3,0x3
ffffffffc0202a40:	4631                	li	a2,12
ffffffffc0202a42:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a46:	4398                	lw	a4,0(a5)
ffffffffc0202a48:	458d                	li	a1,3
ffffffffc0202a4a:	2701                	sext.w	a4,a4
ffffffffc0202a4c:	28b71863          	bne	a4,a1,ffffffffc0202cdc <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a50:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a54:	4394                	lw	a3,0(a5)
ffffffffc0202a56:	2681                	sext.w	a3,a3
ffffffffc0202a58:	2ae69263          	bne	a3,a4,ffffffffc0202cfc <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a5c:	6691                	lui	a3,0x4
ffffffffc0202a5e:	4635                	li	a2,13
ffffffffc0202a60:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a64:	4398                	lw	a4,0(a5)
ffffffffc0202a66:	2701                	sext.w	a4,a4
ffffffffc0202a68:	33a71a63          	bne	a4,s10,ffffffffc0202d9c <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a6c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a70:	439c                	lw	a5,0(a5)
ffffffffc0202a72:	2781                	sext.w	a5,a5
ffffffffc0202a74:	34e79463          	bne	a5,a4,ffffffffc0202dbc <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a78:	481c                	lw	a5,16(s0)
ffffffffc0202a7a:	36079163          	bnez	a5,ffffffffc0202ddc <swap_init+0x5c0>
ffffffffc0202a7e:	0000f797          	auipc	a5,0xf
ffffffffc0202a82:	a5278793          	addi	a5,a5,-1454 # ffffffffc02114d0 <swap_in_seq_no>
ffffffffc0202a86:	0000f717          	auipc	a4,0xf
ffffffffc0202a8a:	a7270713          	addi	a4,a4,-1422 # ffffffffc02114f8 <swap_out_seq_no>
ffffffffc0202a8e:	0000f617          	auipc	a2,0xf
ffffffffc0202a92:	a6a60613          	addi	a2,a2,-1430 # ffffffffc02114f8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202a96:	56fd                	li	a3,-1
ffffffffc0202a98:	c394                	sw	a3,0(a5)
ffffffffc0202a9a:	c314                	sw	a3,0(a4)
ffffffffc0202a9c:	0791                	addi	a5,a5,4
ffffffffc0202a9e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202aa0:	fec79ce3          	bne	a5,a2,ffffffffc0202a98 <swap_init+0x27c>
ffffffffc0202aa4:	0000f697          	auipc	a3,0xf
ffffffffc0202aa8:	ab468693          	addi	a3,a3,-1356 # ffffffffc0211558 <check_ptep>
ffffffffc0202aac:	0000f817          	auipc	a6,0xf
ffffffffc0202ab0:	a0480813          	addi	a6,a6,-1532 # ffffffffc02114b0 <check_rp>
ffffffffc0202ab4:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202ab6:	0000fc97          	auipc	s9,0xf
ffffffffc0202aba:	9a2c8c93          	addi	s9,s9,-1630 # ffffffffc0211458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202abe:	0000fd97          	auipc	s11,0xf
ffffffffc0202ac2:	9ead8d93          	addi	s11,s11,-1558 # ffffffffc02114a8 <pages>
ffffffffc0202ac6:	00003d17          	auipc	s10,0x3
ffffffffc0202aca:	57ad0d13          	addi	s10,s10,1402 # ffffffffc0206040 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ace:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202ad0:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ad4:	4601                	li	a2,0
ffffffffc0202ad6:	85e2                	mv	a1,s8
ffffffffc0202ad8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202ada:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202adc:	ca1fe0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0202ae0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202ae2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202ae4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202ae6:	16050f63          	beqz	a0,ffffffffc0202c64 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202aea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202aec:	0017f613          	andi	a2,a5,1
ffffffffc0202af0:	10060263          	beqz	a2,ffffffffc0202bf4 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202af4:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202af8:	078a                	slli	a5,a5,0x2
ffffffffc0202afa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202afc:	10c7f863          	bleu	a2,a5,ffffffffc0202c0c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b00:	000d3603          	ld	a2,0(s10)
ffffffffc0202b04:	000db583          	ld	a1,0(s11)
ffffffffc0202b08:	00083503          	ld	a0,0(a6)
ffffffffc0202b0c:	8f91                	sub	a5,a5,a2
ffffffffc0202b0e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b12:	97b2                	add	a5,a5,a2
ffffffffc0202b14:	078e                	slli	a5,a5,0x3
ffffffffc0202b16:	97ae                	add	a5,a5,a1
ffffffffc0202b18:	0af51e63          	bne	a0,a5,ffffffffc0202bd4 <swap_init+0x3b8>
ffffffffc0202b1c:	6785                	lui	a5,0x1
ffffffffc0202b1e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b20:	6795                	lui	a5,0x5
ffffffffc0202b22:	06a1                	addi	a3,a3,8
ffffffffc0202b24:	0821                	addi	a6,a6,8
ffffffffc0202b26:	fafc14e3          	bne	s8,a5,ffffffffc0202ace <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b2a:	00003517          	auipc	a0,0x3
ffffffffc0202b2e:	cee50513          	addi	a0,a0,-786 # ffffffffc0205818 <default_pmm_manager+0x928>
ffffffffc0202b32:	d8cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b36:	0000f797          	auipc	a5,0xf
ffffffffc0202b3a:	92a78793          	addi	a5,a5,-1750 # ffffffffc0211460 <sm>
ffffffffc0202b3e:	639c                	ld	a5,0(a5)
ffffffffc0202b40:	7f9c                	ld	a5,56(a5)
ffffffffc0202b42:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b44:	2a051c63          	bnez	a0,ffffffffc0202dfc <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b48:	000a3503          	ld	a0,0(s4)
ffffffffc0202b4c:	4585                	li	a1,1
ffffffffc0202b4e:	0a21                	addi	s4,s4,8
ffffffffc0202b50:	ba7fe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b54:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b48 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b58:	855e                	mv	a0,s7
ffffffffc0202b5a:	0f9000ef          	jal	ra,ffffffffc0203452 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b5e:	77a2                	ld	a5,40(sp)
ffffffffc0202b60:	0000f717          	auipc	a4,0xf
ffffffffc0202b64:	92f72423          	sw	a5,-1752(a4) # ffffffffc0211488 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b68:	7782                	ld	a5,32(sp)
ffffffffc0202b6a:	0000f717          	auipc	a4,0xf
ffffffffc0202b6e:	90f73723          	sd	a5,-1778(a4) # ffffffffc0211478 <free_area>
ffffffffc0202b72:	0000f797          	auipc	a5,0xf
ffffffffc0202b76:	9137b723          	sd	s3,-1778(a5) # ffffffffc0211480 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b7a:	00898a63          	beq	s3,s0,ffffffffc0202b8e <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b7e:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202b82:	0089b983          	ld	s3,8(s3)
ffffffffc0202b86:	397d                	addiw	s2,s2,-1
ffffffffc0202b88:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b8a:	fe899ae3          	bne	s3,s0,ffffffffc0202b7e <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202b8e:	8626                	mv	a2,s1
ffffffffc0202b90:	85ca                	mv	a1,s2
ffffffffc0202b92:	00003517          	auipc	a0,0x3
ffffffffc0202b96:	cb650513          	addi	a0,a0,-842 # ffffffffc0205848 <default_pmm_manager+0x958>
ffffffffc0202b9a:	d24fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202b9e:	00003517          	auipc	a0,0x3
ffffffffc0202ba2:	cca50513          	addi	a0,a0,-822 # ffffffffc0205868 <default_pmm_manager+0x978>
ffffffffc0202ba6:	d18fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202baa:	b1c9                	j	ffffffffc020286c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bac:	4481                	li	s1,0
ffffffffc0202bae:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bb0:	4981                	li	s3,0
ffffffffc0202bb2:	bb1d                	j	ffffffffc02028e8 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202bb4:	00002697          	auipc	a3,0x2
ffffffffc0202bb8:	f9468693          	addi	a3,a3,-108 # ffffffffc0204b48 <commands+0x860>
ffffffffc0202bbc:	00002617          	auipc	a2,0x2
ffffffffc0202bc0:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202bc4:	0bb00593          	li	a1,187
ffffffffc0202bc8:	00003517          	auipc	a0,0x3
ffffffffc0202bcc:	a3850513          	addi	a0,a0,-1480 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202bd0:	fa4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202bd4:	00003697          	auipc	a3,0x3
ffffffffc0202bd8:	c1c68693          	addi	a3,a3,-996 # ffffffffc02057f0 <default_pmm_manager+0x900>
ffffffffc0202bdc:	00002617          	auipc	a2,0x2
ffffffffc0202be0:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202be4:	0fb00593          	li	a1,251
ffffffffc0202be8:	00003517          	auipc	a0,0x3
ffffffffc0202bec:	a1850513          	addi	a0,a0,-1512 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202bf0:	f84fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bf4:	00002617          	auipc	a2,0x2
ffffffffc0202bf8:	5bc60613          	addi	a2,a2,1468 # ffffffffc02051b0 <default_pmm_manager+0x2c0>
ffffffffc0202bfc:	07000593          	li	a1,112
ffffffffc0202c00:	00002517          	auipc	a0,0x2
ffffffffc0202c04:	3d850513          	addi	a0,a0,984 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc0202c08:	f6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c0c:	00002617          	auipc	a2,0x2
ffffffffc0202c10:	3ac60613          	addi	a2,a2,940 # ffffffffc0204fb8 <default_pmm_manager+0xc8>
ffffffffc0202c14:	06500593          	li	a1,101
ffffffffc0202c18:	00002517          	auipc	a0,0x2
ffffffffc0202c1c:	3c050513          	addi	a0,a0,960 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc0202c20:	f54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c24:	00003697          	auipc	a3,0x3
ffffffffc0202c28:	b0468693          	addi	a3,a3,-1276 # ffffffffc0205728 <default_pmm_manager+0x838>
ffffffffc0202c2c:	00002617          	auipc	a2,0x2
ffffffffc0202c30:	f2c60613          	addi	a2,a2,-212 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202c34:	0dc00593          	li	a1,220
ffffffffc0202c38:	00003517          	auipc	a0,0x3
ffffffffc0202c3c:	9c850513          	addi	a0,a0,-1592 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202c40:	f34fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c44:	00003697          	auipc	a3,0x3
ffffffffc0202c48:	acc68693          	addi	a3,a3,-1332 # ffffffffc0205710 <default_pmm_manager+0x820>
ffffffffc0202c4c:	00002617          	auipc	a2,0x2
ffffffffc0202c50:	f0c60613          	addi	a2,a2,-244 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202c54:	0db00593          	li	a1,219
ffffffffc0202c58:	00003517          	auipc	a0,0x3
ffffffffc0202c5c:	9a850513          	addi	a0,a0,-1624 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202c60:	f14fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c64:	00003697          	auipc	a3,0x3
ffffffffc0202c68:	b7468693          	addi	a3,a3,-1164 # ffffffffc02057d8 <default_pmm_manager+0x8e8>
ffffffffc0202c6c:	00002617          	auipc	a2,0x2
ffffffffc0202c70:	eec60613          	addi	a2,a2,-276 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202c74:	0fa00593          	li	a1,250
ffffffffc0202c78:	00003517          	auipc	a0,0x3
ffffffffc0202c7c:	98850513          	addi	a0,a0,-1656 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202c80:	ef4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c84:	00003617          	auipc	a2,0x3
ffffffffc0202c88:	95c60613          	addi	a2,a2,-1700 # ffffffffc02055e0 <default_pmm_manager+0x6f0>
ffffffffc0202c8c:	02800593          	li	a1,40
ffffffffc0202c90:	00003517          	auipc	a0,0x3
ffffffffc0202c94:	97050513          	addi	a0,a0,-1680 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202c98:	edcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c9c:	00003697          	auipc	a3,0x3
ffffffffc0202ca0:	b0c68693          	addi	a3,a3,-1268 # ffffffffc02057a8 <default_pmm_manager+0x8b8>
ffffffffc0202ca4:	00002617          	auipc	a2,0x2
ffffffffc0202ca8:	eb460613          	addi	a2,a2,-332 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202cac:	09600593          	li	a1,150
ffffffffc0202cb0:	00003517          	auipc	a0,0x3
ffffffffc0202cb4:	95050513          	addi	a0,a0,-1712 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202cb8:	ebcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cbc:	00003697          	auipc	a3,0x3
ffffffffc0202cc0:	aec68693          	addi	a3,a3,-1300 # ffffffffc02057a8 <default_pmm_manager+0x8b8>
ffffffffc0202cc4:	00002617          	auipc	a2,0x2
ffffffffc0202cc8:	e9460613          	addi	a2,a2,-364 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202ccc:	09800593          	li	a1,152
ffffffffc0202cd0:	00003517          	auipc	a0,0x3
ffffffffc0202cd4:	93050513          	addi	a0,a0,-1744 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202cd8:	e9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cdc:	00003697          	auipc	a3,0x3
ffffffffc0202ce0:	adc68693          	addi	a3,a3,-1316 # ffffffffc02057b8 <default_pmm_manager+0x8c8>
ffffffffc0202ce4:	00002617          	auipc	a2,0x2
ffffffffc0202ce8:	e7460613          	addi	a2,a2,-396 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202cec:	09a00593          	li	a1,154
ffffffffc0202cf0:	00003517          	auipc	a0,0x3
ffffffffc0202cf4:	91050513          	addi	a0,a0,-1776 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202cf8:	e7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cfc:	00003697          	auipc	a3,0x3
ffffffffc0202d00:	abc68693          	addi	a3,a3,-1348 # ffffffffc02057b8 <default_pmm_manager+0x8c8>
ffffffffc0202d04:	00002617          	auipc	a2,0x2
ffffffffc0202d08:	e5460613          	addi	a2,a2,-428 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202d0c:	09c00593          	li	a1,156
ffffffffc0202d10:	00003517          	auipc	a0,0x3
ffffffffc0202d14:	8f050513          	addi	a0,a0,-1808 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202d18:	e5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d1c:	00003697          	auipc	a3,0x3
ffffffffc0202d20:	a7c68693          	addi	a3,a3,-1412 # ffffffffc0205798 <default_pmm_manager+0x8a8>
ffffffffc0202d24:	00002617          	auipc	a2,0x2
ffffffffc0202d28:	e3460613          	addi	a2,a2,-460 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202d2c:	09200593          	li	a1,146
ffffffffc0202d30:	00003517          	auipc	a0,0x3
ffffffffc0202d34:	8d050513          	addi	a0,a0,-1840 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202d38:	e3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d3c:	00003697          	auipc	a3,0x3
ffffffffc0202d40:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0205798 <default_pmm_manager+0x8a8>
ffffffffc0202d44:	00002617          	auipc	a2,0x2
ffffffffc0202d48:	e1460613          	addi	a2,a2,-492 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202d4c:	09400593          	li	a1,148
ffffffffc0202d50:	00003517          	auipc	a0,0x3
ffffffffc0202d54:	8b050513          	addi	a0,a0,-1872 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202d58:	e1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d5c:	00003697          	auipc	a3,0x3
ffffffffc0202d60:	9ec68693          	addi	a3,a3,-1556 # ffffffffc0205748 <default_pmm_manager+0x858>
ffffffffc0202d64:	00002617          	auipc	a2,0x2
ffffffffc0202d68:	df460613          	addi	a2,a2,-524 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202d6c:	0e900593          	li	a1,233
ffffffffc0202d70:	00003517          	auipc	a0,0x3
ffffffffc0202d74:	89050513          	addi	a0,a0,-1904 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202d78:	dfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d7c:	00003697          	auipc	a3,0x3
ffffffffc0202d80:	95468693          	addi	a3,a3,-1708 # ffffffffc02056d0 <default_pmm_manager+0x7e0>
ffffffffc0202d84:	00002617          	auipc	a2,0x2
ffffffffc0202d88:	dd460613          	addi	a2,a2,-556 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202d8c:	0d600593          	li	a1,214
ffffffffc0202d90:	00003517          	auipc	a0,0x3
ffffffffc0202d94:	87050513          	addi	a0,a0,-1936 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202d98:	ddcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d9c:	00003697          	auipc	a3,0x3
ffffffffc0202da0:	a2c68693          	addi	a3,a3,-1492 # ffffffffc02057c8 <default_pmm_manager+0x8d8>
ffffffffc0202da4:	00002617          	auipc	a2,0x2
ffffffffc0202da8:	db460613          	addi	a2,a2,-588 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202dac:	09e00593          	li	a1,158
ffffffffc0202db0:	00003517          	auipc	a0,0x3
ffffffffc0202db4:	85050513          	addi	a0,a0,-1968 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202db8:	dbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dbc:	00003697          	auipc	a3,0x3
ffffffffc0202dc0:	a0c68693          	addi	a3,a3,-1524 # ffffffffc02057c8 <default_pmm_manager+0x8d8>
ffffffffc0202dc4:	00002617          	auipc	a2,0x2
ffffffffc0202dc8:	d9460613          	addi	a2,a2,-620 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202dcc:	0a000593          	li	a1,160
ffffffffc0202dd0:	00003517          	auipc	a0,0x3
ffffffffc0202dd4:	83050513          	addi	a0,a0,-2000 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202dd8:	d9cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202ddc:	00002697          	auipc	a3,0x2
ffffffffc0202de0:	f5468693          	addi	a3,a3,-172 # ffffffffc0204d30 <commands+0xa48>
ffffffffc0202de4:	00002617          	auipc	a2,0x2
ffffffffc0202de8:	d7460613          	addi	a2,a2,-652 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202dec:	0f200593          	li	a1,242
ffffffffc0202df0:	00003517          	auipc	a0,0x3
ffffffffc0202df4:	81050513          	addi	a0,a0,-2032 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202df8:	d7cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202dfc:	00003697          	auipc	a3,0x3
ffffffffc0202e00:	a4468693          	addi	a3,a3,-1468 # ffffffffc0205840 <default_pmm_manager+0x950>
ffffffffc0202e04:	00002617          	auipc	a2,0x2
ffffffffc0202e08:	d5460613          	addi	a2,a2,-684 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202e0c:	10100593          	li	a1,257
ffffffffc0202e10:	00002517          	auipc	a0,0x2
ffffffffc0202e14:	7f050513          	addi	a0,a0,2032 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202e18:	d5cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202e1c:	00003697          	auipc	a3,0x3
ffffffffc0202e20:	83468693          	addi	a3,a3,-1996 # ffffffffc0205650 <default_pmm_manager+0x760>
ffffffffc0202e24:	00002617          	auipc	a2,0x2
ffffffffc0202e28:	d3460613          	addi	a2,a2,-716 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202e2c:	0c300593          	li	a1,195
ffffffffc0202e30:	00002517          	auipc	a0,0x2
ffffffffc0202e34:	7d050513          	addi	a0,a0,2000 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202e38:	d3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e3c:	00003697          	auipc	a3,0x3
ffffffffc0202e40:	82468693          	addi	a3,a3,-2012 # ffffffffc0205660 <default_pmm_manager+0x770>
ffffffffc0202e44:	00002617          	auipc	a2,0x2
ffffffffc0202e48:	d1460613          	addi	a2,a2,-748 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202e4c:	0c600593          	li	a1,198
ffffffffc0202e50:	00002517          	auipc	a0,0x2
ffffffffc0202e54:	7b050513          	addi	a0,a0,1968 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202e58:	d1cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e5c:	00003697          	auipc	a3,0x3
ffffffffc0202e60:	81c68693          	addi	a3,a3,-2020 # ffffffffc0205678 <default_pmm_manager+0x788>
ffffffffc0202e64:	00002617          	auipc	a2,0x2
ffffffffc0202e68:	cf460613          	addi	a2,a2,-780 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202e6c:	0cb00593          	li	a1,203
ffffffffc0202e70:	00002517          	auipc	a0,0x2
ffffffffc0202e74:	79050513          	addi	a0,a0,1936 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202e78:	cfcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202e7c:	00003697          	auipc	a3,0x3
ffffffffc0202e80:	80c68693          	addi	a3,a3,-2036 # ffffffffc0205688 <default_pmm_manager+0x798>
ffffffffc0202e84:	00002617          	auipc	a2,0x2
ffffffffc0202e88:	cd460613          	addi	a2,a2,-812 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202e8c:	0ce00593          	li	a1,206
ffffffffc0202e90:	00002517          	auipc	a0,0x2
ffffffffc0202e94:	77050513          	addi	a0,a0,1904 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202e98:	cdcfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e9c:	00002697          	auipc	a3,0x2
ffffffffc0202ea0:	cec68693          	addi	a3,a3,-788 # ffffffffc0204b88 <commands+0x8a0>
ffffffffc0202ea4:	00002617          	auipc	a2,0x2
ffffffffc0202ea8:	cb460613          	addi	a2,a2,-844 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202eac:	0be00593          	li	a1,190
ffffffffc0202eb0:	00002517          	auipc	a0,0x2
ffffffffc0202eb4:	75050513          	addi	a0,a0,1872 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202eb8:	cbcfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202ebc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202ebc:	0000e797          	auipc	a5,0xe
ffffffffc0202ec0:	5a478793          	addi	a5,a5,1444 # ffffffffc0211460 <sm>
ffffffffc0202ec4:	639c                	ld	a5,0(a5)
ffffffffc0202ec6:	0107b303          	ld	t1,16(a5)
ffffffffc0202eca:	8302                	jr	t1

ffffffffc0202ecc <swap_tick_event>:
     return sm->tick_event(mm);
ffffffffc0202ecc:	0000e797          	auipc	a5,0xe
ffffffffc0202ed0:	59478793          	addi	a5,a5,1428 # ffffffffc0211460 <sm>
ffffffffc0202ed4:	639c                	ld	a5,0(a5)
ffffffffc0202ed6:	0187b303          	ld	t1,24(a5)
ffffffffc0202eda:	8302                	jr	t1

ffffffffc0202edc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202edc:	0000e797          	auipc	a5,0xe
ffffffffc0202ee0:	58478793          	addi	a5,a5,1412 # ffffffffc0211460 <sm>
ffffffffc0202ee4:	639c                	ld	a5,0(a5)
ffffffffc0202ee6:	0207b303          	ld	t1,32(a5)
ffffffffc0202eea:	8302                	jr	t1

ffffffffc0202eec <swap_out>:
{
ffffffffc0202eec:	711d                	addi	sp,sp,-96
ffffffffc0202eee:	ec86                	sd	ra,88(sp)
ffffffffc0202ef0:	e8a2                	sd	s0,80(sp)
ffffffffc0202ef2:	e4a6                	sd	s1,72(sp)
ffffffffc0202ef4:	e0ca                	sd	s2,64(sp)
ffffffffc0202ef6:	fc4e                	sd	s3,56(sp)
ffffffffc0202ef8:	f852                	sd	s4,48(sp)
ffffffffc0202efa:	f456                	sd	s5,40(sp)
ffffffffc0202efc:	f05a                	sd	s6,32(sp)
ffffffffc0202efe:	ec5e                	sd	s7,24(sp)
ffffffffc0202f00:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f02:	cde9                	beqz	a1,ffffffffc0202fdc <swap_out+0xf0>
ffffffffc0202f04:	8ab2                	mv	s5,a2
ffffffffc0202f06:	892a                	mv	s2,a0
ffffffffc0202f08:	8a2e                	mv	s4,a1
ffffffffc0202f0a:	4401                	li	s0,0
ffffffffc0202f0c:	0000e997          	auipc	s3,0xe
ffffffffc0202f10:	55498993          	addi	s3,s3,1364 # ffffffffc0211460 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f14:	00003b17          	auipc	s6,0x3
ffffffffc0202f18:	9d4b0b13          	addi	s6,s6,-1580 # ffffffffc02058e8 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f1c:	00003b97          	auipc	s7,0x3
ffffffffc0202f20:	9b4b8b93          	addi	s7,s7,-1612 # ffffffffc02058d0 <default_pmm_manager+0x9e0>
ffffffffc0202f24:	a825                	j	ffffffffc0202f5c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f26:	67a2                	ld	a5,8(sp)
ffffffffc0202f28:	8626                	mv	a2,s1
ffffffffc0202f2a:	85a2                	mv	a1,s0
ffffffffc0202f2c:	63b4                	ld	a3,64(a5)
ffffffffc0202f2e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f30:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f32:	82b1                	srli	a3,a3,0xc
ffffffffc0202f34:	0685                	addi	a3,a3,1
ffffffffc0202f36:	988fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f3a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f3c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f3e:	613c                	ld	a5,64(a0)
ffffffffc0202f40:	83b1                	srli	a5,a5,0xc
ffffffffc0202f42:	0785                	addi	a5,a5,1
ffffffffc0202f44:	07a2                	slli	a5,a5,0x8
ffffffffc0202f46:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f4a:	facfe0ef          	jal	ra,ffffffffc02016f6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f4e:	01893503          	ld	a0,24(s2)
ffffffffc0202f52:	85a6                	mv	a1,s1
ffffffffc0202f54:	eaeff0ef          	jal	ra,ffffffffc0202602 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f58:	048a0d63          	beq	s4,s0,ffffffffc0202fb2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f5c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f60:	8656                	mv	a2,s5
ffffffffc0202f62:	002c                	addi	a1,sp,8
ffffffffc0202f64:	7b9c                	ld	a5,48(a5)
ffffffffc0202f66:	854a                	mv	a0,s2
ffffffffc0202f68:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f6a:	e12d                	bnez	a0,ffffffffc0202fcc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f6c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f6e:	01893503          	ld	a0,24(s2)
ffffffffc0202f72:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f74:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f76:	85a6                	mv	a1,s1
ffffffffc0202f78:	805fe0ef          	jal	ra,ffffffffc020177c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f7c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f7e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f80:	8b85                	andi	a5,a5,1
ffffffffc0202f82:	cfb9                	beqz	a5,ffffffffc0202fe0 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f84:	65a2                	ld	a1,8(sp)
ffffffffc0202f86:	61bc                	ld	a5,64(a1)
ffffffffc0202f88:	83b1                	srli	a5,a5,0xc
ffffffffc0202f8a:	00178513          	addi	a0,a5,1
ffffffffc0202f8e:	0522                	slli	a0,a0,0x8
ffffffffc0202f90:	40b000ef          	jal	ra,ffffffffc0203b9a <swapfs_write>
ffffffffc0202f94:	d949                	beqz	a0,ffffffffc0202f26 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f96:	855e                	mv	a0,s7
ffffffffc0202f98:	926fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f9c:	0009b783          	ld	a5,0(s3)
ffffffffc0202fa0:	6622                	ld	a2,8(sp)
ffffffffc0202fa2:	4681                	li	a3,0
ffffffffc0202fa4:	739c                	ld	a5,32(a5)
ffffffffc0202fa6:	85a6                	mv	a1,s1
ffffffffc0202fa8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202faa:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fac:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202fae:	fa8a17e3          	bne	s4,s0,ffffffffc0202f5c <swap_out+0x70>
}
ffffffffc0202fb2:	8522                	mv	a0,s0
ffffffffc0202fb4:	60e6                	ld	ra,88(sp)
ffffffffc0202fb6:	6446                	ld	s0,80(sp)
ffffffffc0202fb8:	64a6                	ld	s1,72(sp)
ffffffffc0202fba:	6906                	ld	s2,64(sp)
ffffffffc0202fbc:	79e2                	ld	s3,56(sp)
ffffffffc0202fbe:	7a42                	ld	s4,48(sp)
ffffffffc0202fc0:	7aa2                	ld	s5,40(sp)
ffffffffc0202fc2:	7b02                	ld	s6,32(sp)
ffffffffc0202fc4:	6be2                	ld	s7,24(sp)
ffffffffc0202fc6:	6c42                	ld	s8,16(sp)
ffffffffc0202fc8:	6125                	addi	sp,sp,96
ffffffffc0202fca:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202fcc:	85a2                	mv	a1,s0
ffffffffc0202fce:	00003517          	auipc	a0,0x3
ffffffffc0202fd2:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0205888 <default_pmm_manager+0x998>
ffffffffc0202fd6:	8e8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202fda:	bfe1                	j	ffffffffc0202fb2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202fdc:	4401                	li	s0,0
ffffffffc0202fde:	bfd1                	j	ffffffffc0202fb2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fe0:	00003697          	auipc	a3,0x3
ffffffffc0202fe4:	8d868693          	addi	a3,a3,-1832 # ffffffffc02058b8 <default_pmm_manager+0x9c8>
ffffffffc0202fe8:	00002617          	auipc	a2,0x2
ffffffffc0202fec:	b7060613          	addi	a2,a2,-1168 # ffffffffc0204b58 <commands+0x870>
ffffffffc0202ff0:	06700593          	li	a1,103
ffffffffc0202ff4:	00002517          	auipc	a0,0x2
ffffffffc0202ff8:	60c50513          	addi	a0,a0,1548 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0202ffc:	b78fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203000 <swap_in>:
{
ffffffffc0203000:	7179                	addi	sp,sp,-48
ffffffffc0203002:	e84a                	sd	s2,16(sp)
ffffffffc0203004:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203006:	4505                	li	a0,1
{
ffffffffc0203008:	ec26                	sd	s1,24(sp)
ffffffffc020300a:	e44e                	sd	s3,8(sp)
ffffffffc020300c:	f406                	sd	ra,40(sp)
ffffffffc020300e:	f022                	sd	s0,32(sp)
ffffffffc0203010:	84ae                	mv	s1,a1
ffffffffc0203012:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203014:	e5afe0ef          	jal	ra,ffffffffc020166e <alloc_pages>
     assert(result!=NULL);
ffffffffc0203018:	c129                	beqz	a0,ffffffffc020305a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020301a:	842a                	mv	s0,a0
ffffffffc020301c:	01893503          	ld	a0,24(s2)
ffffffffc0203020:	4601                	li	a2,0
ffffffffc0203022:	85a6                	mv	a1,s1
ffffffffc0203024:	f58fe0ef          	jal	ra,ffffffffc020177c <get_pte>
ffffffffc0203028:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020302a:	6108                	ld	a0,0(a0)
ffffffffc020302c:	85a2                	mv	a1,s0
ffffffffc020302e:	2c7000ef          	jal	ra,ffffffffc0203af4 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203032:	00093583          	ld	a1,0(s2)
ffffffffc0203036:	8626                	mv	a2,s1
ffffffffc0203038:	00002517          	auipc	a0,0x2
ffffffffc020303c:	56850513          	addi	a0,a0,1384 # ffffffffc02055a0 <default_pmm_manager+0x6b0>
ffffffffc0203040:	81a1                	srli	a1,a1,0x8
ffffffffc0203042:	87cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203046:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203048:	0089b023          	sd	s0,0(s3)
}
ffffffffc020304c:	7402                	ld	s0,32(sp)
ffffffffc020304e:	64e2                	ld	s1,24(sp)
ffffffffc0203050:	6942                	ld	s2,16(sp)
ffffffffc0203052:	69a2                	ld	s3,8(sp)
ffffffffc0203054:	4501                	li	a0,0
ffffffffc0203056:	6145                	addi	sp,sp,48
ffffffffc0203058:	8082                	ret
     assert(result!=NULL);
ffffffffc020305a:	00002697          	auipc	a3,0x2
ffffffffc020305e:	53668693          	addi	a3,a3,1334 # ffffffffc0205590 <default_pmm_manager+0x6a0>
ffffffffc0203062:	00002617          	auipc	a2,0x2
ffffffffc0203066:	af660613          	addi	a2,a2,-1290 # ffffffffc0204b58 <commands+0x870>
ffffffffc020306a:	07d00593          	li	a1,125
ffffffffc020306e:	00002517          	auipc	a0,0x2
ffffffffc0203072:	59250513          	addi	a0,a0,1426 # ffffffffc0205600 <default_pmm_manager+0x710>
ffffffffc0203076:	afefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020307a <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020307a:	0000e797          	auipc	a5,0xe
ffffffffc020307e:	4fe78793          	addi	a5,a5,1278 # ffffffffc0211578 <pra_list_head>

static int
_lru_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203082:	f51c                	sd	a5,40(a0)
ffffffffc0203084:	e79c                	sd	a5,8(a5)
ffffffffc0203086:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203088:	4501                	li	a0,0
ffffffffc020308a:	8082                	ret

ffffffffc020308c <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc020308c:	4501                	li	a0,0
ffffffffc020308e:	8082                	ret

ffffffffc0203090 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203090:	4501                	li	a0,0
ffffffffc0203092:	8082                	ret

ffffffffc0203094 <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc0203094:	1101                	addi	sp,sp,-32
ffffffffc0203096:	e04a                	sd	s2,0(sp)
    swap_tick_event(check_mm_struct);
ffffffffc0203098:	0000e917          	auipc	s2,0xe
ffffffffc020309c:	4f890913          	addi	s2,s2,1272 # ffffffffc0211590 <check_mm_struct>
ffffffffc02030a0:	00093503          	ld	a0,0(s2)
_lru_check_swap(void) {
ffffffffc02030a4:	ec06                	sd	ra,24(sp)
ffffffffc02030a6:	e822                	sd	s0,16(sp)
ffffffffc02030a8:	e426                	sd	s1,8(sp)
    swap_tick_event(check_mm_struct);
ffffffffc02030aa:	e23ff0ef          	jal	ra,ffffffffc0202ecc <swap_tick_event>
    cprintf("write Virt Page e in lru_check_swap\n");
ffffffffc02030ae:	00003517          	auipc	a0,0x3
ffffffffc02030b2:	87a50513          	addi	a0,a0,-1926 # ffffffffc0205928 <default_pmm_manager+0xa38>
ffffffffc02030b6:	808fd0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030ba:	6795                	lui	a5,0x5
ffffffffc02030bc:	44b9                	li	s1,14
    assert(pgfault_num==5);
ffffffffc02030be:	0000e417          	auipc	s0,0xe
ffffffffc02030c2:	3ae40413          	addi	s0,s0,942 # ffffffffc021146c <pgfault_num>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030c6:	00978023          	sb	s1,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02030ca:	401c                	lw	a5,0(s0)
ffffffffc02030cc:	4715                	li	a4,5
ffffffffc02030ce:	2781                	sext.w	a5,a5
ffffffffc02030d0:	06e79b63          	bne	a5,a4,ffffffffc0203146 <_lru_check_swap+0xb2>
    cprintf("write Virt Page c and set Access bit\n");
ffffffffc02030d4:	00003517          	auipc	a0,0x3
ffffffffc02030d8:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205978 <default_pmm_manager+0xa88>
ffffffffc02030dc:	fe3fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    pte_t *ptep = get_pte(check_mm_struct->pgdir, 0x3000, 0);
ffffffffc02030e0:	00093783          	ld	a5,0(s2)
ffffffffc02030e4:	4601                	li	a2,0
ffffffffc02030e6:	658d                	lui	a1,0x3
ffffffffc02030e8:	6f88                	ld	a0,24(a5)
ffffffffc02030ea:	e92fe0ef          	jal	ra,ffffffffc020177c <get_pte>
    *ptep |= PTE_A;
ffffffffc02030ee:	611c                	ld	a5,0(a0)
    pte_t *ptep = get_pte(check_mm_struct->pgdir, 0x3000, 0);
ffffffffc02030f0:	872a                	mv	a4,a0
    swap_tick_event(check_mm_struct);
ffffffffc02030f2:	00093503          	ld	a0,0(s2)
    *ptep |= PTE_A;
ffffffffc02030f6:	0407e793          	ori	a5,a5,64
ffffffffc02030fa:	e31c                	sd	a5,0(a4)
    swap_tick_event(check_mm_struct);
ffffffffc02030fc:	dd1ff0ef          	jal	ra,ffffffffc0202ecc <swap_tick_event>
    cprintf("write Virt Page d in lru_check_swap\n");
ffffffffc0203100:	00003517          	auipc	a0,0x3
ffffffffc0203104:	8a050513          	addi	a0,a0,-1888 # ffffffffc02059a0 <default_pmm_manager+0xab0>
ffffffffc0203108:	fb7fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x4000 = 0x0e;
ffffffffc020310c:	6791                	lui	a5,0x4
ffffffffc020310e:	00978023          	sb	s1,0(a5) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==6);
ffffffffc0203112:	401c                	lw	a5,0(s0)
ffffffffc0203114:	4719                	li	a4,6
ffffffffc0203116:	2781                	sext.w	a5,a5
ffffffffc0203118:	06e79763          	bne	a5,a4,ffffffffc0203186 <_lru_check_swap+0xf2>
    cprintf("write Virt Page b in lru_check_swap\n");
ffffffffc020311c:	00003517          	auipc	a0,0x3
ffffffffc0203120:	8bc50513          	addi	a0,a0,-1860 # ffffffffc02059d8 <default_pmm_manager+0xae8>
ffffffffc0203124:	f9bfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    *(unsigned char *)0x2000 = 0x0e;
ffffffffc0203128:	6789                	lui	a5,0x2
ffffffffc020312a:	00978023          	sb	s1,0(a5) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==7);
ffffffffc020312e:	401c                	lw	a5,0(s0)
ffffffffc0203130:	471d                	li	a4,7
ffffffffc0203132:	2781                	sext.w	a5,a5
ffffffffc0203134:	02e79963          	bne	a5,a4,ffffffffc0203166 <_lru_check_swap+0xd2>
}
ffffffffc0203138:	60e2                	ld	ra,24(sp)
ffffffffc020313a:	6442                	ld	s0,16(sp)
ffffffffc020313c:	64a2                	ld	s1,8(sp)
ffffffffc020313e:	6902                	ld	s2,0(sp)
ffffffffc0203140:	4501                	li	a0,0
ffffffffc0203142:	6105                	addi	sp,sp,32
ffffffffc0203144:	8082                	ret
    assert(pgfault_num==5);
ffffffffc0203146:	00003697          	auipc	a3,0x3
ffffffffc020314a:	80a68693          	addi	a3,a3,-2038 # ffffffffc0205950 <default_pmm_manager+0xa60>
ffffffffc020314e:	00002617          	auipc	a2,0x2
ffffffffc0203152:	a0a60613          	addi	a2,a2,-1526 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203156:	03f00593          	li	a1,63
ffffffffc020315a:	00003517          	auipc	a0,0x3
ffffffffc020315e:	80650513          	addi	a0,a0,-2042 # ffffffffc0205960 <default_pmm_manager+0xa70>
ffffffffc0203162:	a12fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==7);
ffffffffc0203166:	00003697          	auipc	a3,0x3
ffffffffc020316a:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205a00 <default_pmm_manager+0xb10>
ffffffffc020316e:	00002617          	auipc	a2,0x2
ffffffffc0203172:	9ea60613          	addi	a2,a2,-1558 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203176:	05200593          	li	a1,82
ffffffffc020317a:	00002517          	auipc	a0,0x2
ffffffffc020317e:	7e650513          	addi	a0,a0,2022 # ffffffffc0205960 <default_pmm_manager+0xa70>
ffffffffc0203182:	9f2fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc0203186:	00003697          	auipc	a3,0x3
ffffffffc020318a:	84268693          	addi	a3,a3,-1982 # ffffffffc02059c8 <default_pmm_manager+0xad8>
ffffffffc020318e:	00002617          	auipc	a2,0x2
ffffffffc0203192:	9ca60613          	addi	a2,a2,-1590 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203196:	04d00593          	li	a1,77
ffffffffc020319a:	00002517          	auipc	a0,0x2
ffffffffc020319e:	7c650513          	addi	a0,a0,1990 # ffffffffc0205960 <default_pmm_manager+0xa70>
ffffffffc02031a2:	9d2fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02031a6 <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ 
ffffffffc02031a6:	1101                	addi	sp,sp,-32
ffffffffc02031a8:	e426                	sd	s1,8(sp)
    list_entry_t* head = (list_entry_t*)mm->sm_priv;
ffffffffc02031aa:	7504                	ld	s1,40(a0)
{ 
ffffffffc02031ac:	e822                	sd	s0,16(sp)
ffffffffc02031ae:	e04a                	sd	s2,0(sp)
ffffffffc02031b0:	ec06                	sd	ra,24(sp)
ffffffffc02031b2:	892a                	mv	s2,a0
    list_entry_t* head = (list_entry_t*)mm->sm_priv;
ffffffffc02031b4:	8426                	mv	s0,s1
    list_entry_t* cur = head;
    while (cur->next != head)
ffffffffc02031b6:	a811                	j	ffffffffc02031ca <_lru_tick_event+0x24>
    {
        cur = cur->next;
        struct Page* page = le2page(cur, pra_page_link);
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc02031b8:	680c                	ld	a1,16(s0)
ffffffffc02031ba:	01893503          	ld	a0,24(s2)
ffffffffc02031be:	dbefe0ef          	jal	ra,ffffffffc020177c <get_pte>
        if (*ptep & PTE_A)      //页面在一段时间内被访问了，拿到最前，置零
ffffffffc02031c2:	611c                	ld	a5,0(a0)
ffffffffc02031c4:	0407f713          	andi	a4,a5,64
ffffffffc02031c8:	ef01                	bnez	a4,ffffffffc02031e0 <_lru_tick_event+0x3a>
    while (cur->next != head)
ffffffffc02031ca:	6400                	ld	s0,8(s0)
        pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc02031cc:	4601                	li	a2,0
    while (cur->next != head)
ffffffffc02031ce:	fe9415e3          	bne	s0,s1,ffffffffc02031b8 <_lru_tick_event+0x12>
            cur = temp;
        }
        // cprintf("here in lru_tick_event\n");
    }
    return 0;
}
ffffffffc02031d2:	60e2                	ld	ra,24(sp)
ffffffffc02031d4:	6442                	ld	s0,16(sp)
ffffffffc02031d6:	64a2                	ld	s1,8(sp)
ffffffffc02031d8:	6902                	ld	s2,0(sp)
ffffffffc02031da:	4501                	li	a0,0
ffffffffc02031dc:	6105                	addi	sp,sp,32
ffffffffc02031de:	8082                	ret
            list_entry_t* temp = cur->prev;
ffffffffc02031e0:	6018                	ld	a4,0(s0)
    __list_del(listelm->prev, listelm->next);
ffffffffc02031e2:	6410                	ld	a2,8(s0)
            *ptep &= ~PTE_A;
ffffffffc02031e4:	fbf7f793          	andi	a5,a5,-65
    prev->next = next;
ffffffffc02031e8:	e710                	sd	a2,8(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc02031ea:	6494                	ld	a3,8(s1)
    next->prev = prev;
ffffffffc02031ec:	e218                	sd	a4,0(a2)
ffffffffc02031ee:	e11c                	sd	a5,0(a0)
    prev->next = next->prev = elm;
ffffffffc02031f0:	e280                	sd	s0,0(a3)
ffffffffc02031f2:	e480                	sd	s0,8(s1)
    elm->next = next;
ffffffffc02031f4:	e414                	sd	a3,8(s0)
    elm->prev = prev;
ffffffffc02031f6:	e004                	sd	s1,0(s0)
            cur = temp;
ffffffffc02031f8:	843a                	mv	s0,a4
ffffffffc02031fa:	bfc1                	j	ffffffffc02031ca <_lru_tick_event+0x24>

ffffffffc02031fc <_lru_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02031fc:	7518                	ld	a4,40(a0)
{
ffffffffc02031fe:	1141                	addi	sp,sp,-16
ffffffffc0203200:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203202:	c731                	beqz	a4,ffffffffc020324e <_lru_swap_out_victim+0x52>
     assert(in_tick==0);
ffffffffc0203204:	e60d                	bnez	a2,ffffffffc020322e <_lru_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc0203206:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc0203208:	00f70d63          	beq	a4,a5,ffffffffc0203222 <_lru_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020320c:	6394                	ld	a3,0(a5)
ffffffffc020320e:	6798                	ld	a4,8(a5)
}
ffffffffc0203210:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203212:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc0203216:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203218:	e314                	sd	a3,0(a4)
ffffffffc020321a:	e19c                	sd	a5,0(a1)
}
ffffffffc020321c:	4501                	li	a0,0
ffffffffc020321e:	0141                	addi	sp,sp,16
ffffffffc0203220:	8082                	ret
ffffffffc0203222:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc0203224:	0005b023          	sd	zero,0(a1) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
}
ffffffffc0203228:	4501                	li	a0,0
ffffffffc020322a:	0141                	addi	sp,sp,16
ffffffffc020322c:	8082                	ret
     assert(in_tick==0);
ffffffffc020322e:	00003697          	auipc	a3,0x3
ffffffffc0203232:	81268693          	addi	a3,a3,-2030 # ffffffffc0205a40 <default_pmm_manager+0xb50>
ffffffffc0203236:	00002617          	auipc	a2,0x2
ffffffffc020323a:	92260613          	addi	a2,a2,-1758 # ffffffffc0204b58 <commands+0x870>
ffffffffc020323e:	02800593          	li	a1,40
ffffffffc0203242:	00002517          	auipc	a0,0x2
ffffffffc0203246:	71e50513          	addi	a0,a0,1822 # ffffffffc0205960 <default_pmm_manager+0xa70>
ffffffffc020324a:	92afd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(head != NULL);
ffffffffc020324e:	00002697          	auipc	a3,0x2
ffffffffc0203252:	7e268693          	addi	a3,a3,2018 # ffffffffc0205a30 <default_pmm_manager+0xb40>
ffffffffc0203256:	00002617          	auipc	a2,0x2
ffffffffc020325a:	90260613          	addi	a2,a2,-1790 # ffffffffc0204b58 <commands+0x870>
ffffffffc020325e:	02700593          	li	a1,39
ffffffffc0203262:	00002517          	auipc	a0,0x2
ffffffffc0203266:	6fe50513          	addi	a0,a0,1790 # ffffffffc0205960 <default_pmm_manager+0xa70>
ffffffffc020326a:	90afd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020326e <_lru_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020326e:	03060713          	addi	a4,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203272:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203274:	cb09                	beqz	a4,ffffffffc0203286 <_lru_map_swappable+0x18>
ffffffffc0203276:	cb81                	beqz	a5,ffffffffc0203286 <_lru_map_swappable+0x18>
    __list_add(elm, listelm, listelm->next);
ffffffffc0203278:	6794                	ld	a3,8(a5)
}
ffffffffc020327a:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc020327c:	e298                	sd	a4,0(a3)
ffffffffc020327e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203280:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0203282:	fa1c                	sd	a5,48(a2)
ffffffffc0203284:	8082                	ret
{
ffffffffc0203286:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203288:	00002697          	auipc	a3,0x2
ffffffffc020328c:	78868693          	addi	a3,a3,1928 # ffffffffc0205a10 <default_pmm_manager+0xb20>
ffffffffc0203290:	00002617          	auipc	a2,0x2
ffffffffc0203294:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203298:	45f1                	li	a1,28
ffffffffc020329a:	00002517          	auipc	a0,0x2
ffffffffc020329e:	6c650513          	addi	a0,a0,1734 # ffffffffc0205960 <default_pmm_manager+0xa70>
{
ffffffffc02032a2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02032a4:	8d0fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032a8 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02032a8:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02032aa:	00002697          	auipc	a3,0x2
ffffffffc02032ae:	7be68693          	addi	a3,a3,1982 # ffffffffc0205a68 <default_pmm_manager+0xb78>
ffffffffc02032b2:	00002617          	auipc	a2,0x2
ffffffffc02032b6:	8a660613          	addi	a2,a2,-1882 # ffffffffc0204b58 <commands+0x870>
ffffffffc02032ba:	07d00593          	li	a1,125
ffffffffc02032be:	00002517          	auipc	a0,0x2
ffffffffc02032c2:	7ca50513          	addi	a0,a0,1994 # ffffffffc0205a88 <default_pmm_manager+0xb98>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02032c6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02032c8:	8acfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032cc <mm_create>:
mm_create(void) {
ffffffffc02032cc:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02032ce:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02032d2:	e022                	sd	s0,0(sp)
ffffffffc02032d4:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02032d6:	bc4ff0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc02032da:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02032dc:	c115                	beqz	a0,ffffffffc0203300 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);  // 初始化内存交换管理器，初始化两个链表
ffffffffc02032de:	0000e797          	auipc	a5,0xe
ffffffffc02032e2:	18a78793          	addi	a5,a5,394 # ffffffffc0211468 <swap_init_ok>
ffffffffc02032e6:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02032e8:	e408                	sd	a0,8(s0)
ffffffffc02032ea:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02032ec:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02032f0:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02032f4:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);  // 初始化内存交换管理器，初始化两个链表
ffffffffc02032f8:	2781                	sext.w	a5,a5
ffffffffc02032fa:	eb81                	bnez	a5,ffffffffc020330a <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02032fc:	02053423          	sd	zero,40(a0)
}
ffffffffc0203300:	8522                	mv	a0,s0
ffffffffc0203302:	60a2                	ld	ra,8(sp)
ffffffffc0203304:	6402                	ld	s0,0(sp)
ffffffffc0203306:	0141                	addi	sp,sp,16
ffffffffc0203308:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);  // 初始化内存交换管理器，初始化两个链表
ffffffffc020330a:	bb3ff0ef          	jal	ra,ffffffffc0202ebc <swap_init_mm>
}
ffffffffc020330e:	8522                	mv	a0,s0
ffffffffc0203310:	60a2                	ld	ra,8(sp)
ffffffffc0203312:	6402                	ld	s0,0(sp)
ffffffffc0203314:	0141                	addi	sp,sp,16
ffffffffc0203316:	8082                	ret

ffffffffc0203318 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203318:	1101                	addi	sp,sp,-32
ffffffffc020331a:	e04a                	sd	s2,0(sp)
ffffffffc020331c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020331e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203322:	e822                	sd	s0,16(sp)
ffffffffc0203324:	e426                	sd	s1,8(sp)
ffffffffc0203326:	ec06                	sd	ra,24(sp)
ffffffffc0203328:	84ae                	mv	s1,a1
ffffffffc020332a:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020332c:	b6eff0ef          	jal	ra,ffffffffc020269a <kmalloc>
    if (vma != NULL) {
ffffffffc0203330:	c509                	beqz	a0,ffffffffc020333a <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc0203332:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203336:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203338:	ed00                	sd	s0,24(a0)
}
ffffffffc020333a:	60e2                	ld	ra,24(sp)
ffffffffc020333c:	6442                	ld	s0,16(sp)
ffffffffc020333e:	64a2                	ld	s1,8(sp)
ffffffffc0203340:	6902                	ld	s2,0(sp)
ffffffffc0203342:	6105                	addi	sp,sp,32
ffffffffc0203344:	8082                	ret

ffffffffc0203346 <find_vma>:
    if (mm != NULL) {
ffffffffc0203346:	c51d                	beqz	a0,ffffffffc0203374 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0203348:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020334a:	c781                	beqz	a5,ffffffffc0203352 <find_vma+0xc>
ffffffffc020334c:	6798                	ld	a4,8(a5)
ffffffffc020334e:	02e5f663          	bleu	a4,a1,ffffffffc020337a <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0203352:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0203354:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203356:	00f50f63          	beq	a0,a5,ffffffffc0203374 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc020335a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020335e:	fee5ebe3          	bltu	a1,a4,ffffffffc0203354 <find_vma+0xe>
ffffffffc0203362:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203366:	fee5f7e3          	bleu	a4,a1,ffffffffc0203354 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc020336a:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020336c:	c781                	beqz	a5,ffffffffc0203374 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020336e:	e91c                	sd	a5,16(a0)
}
ffffffffc0203370:	853e                	mv	a0,a5
ffffffffc0203372:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203374:	4781                	li	a5,0
}
ffffffffc0203376:	853e                	mv	a0,a5
ffffffffc0203378:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc020337a:	6b98                	ld	a4,16(a5)
ffffffffc020337c:	fce5fbe3          	bleu	a4,a1,ffffffffc0203352 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203380:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203382:	b7fd                	j	ffffffffc0203370 <find_vma+0x2a>

ffffffffc0203384 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203384:	6590                	ld	a2,8(a1)
ffffffffc0203386:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020338a:	1141                	addi	sp,sp,-16
ffffffffc020338c:	e406                	sd	ra,8(sp)
ffffffffc020338e:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203390:	01066863          	bltu	a2,a6,ffffffffc02033a0 <insert_vma_struct+0x1c>
ffffffffc0203394:	a8b9                	j	ffffffffc02033f2 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203396:	fe87b683          	ld	a3,-24(a5)
ffffffffc020339a:	04d66763          	bltu	a2,a3,ffffffffc02033e8 <insert_vma_struct+0x64>
ffffffffc020339e:	873e                	mv	a4,a5
ffffffffc02033a0:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02033a2:	fef51ae3          	bne	a0,a5,ffffffffc0203396 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02033a6:	02a70463          	beq	a4,a0,ffffffffc02033ce <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02033aa:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02033ae:	fe873883          	ld	a7,-24(a4)
ffffffffc02033b2:	08d8f063          	bleu	a3,a7,ffffffffc0203432 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033b6:	04d66e63          	bltu	a2,a3,ffffffffc0203412 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02033ba:	00f50a63          	beq	a0,a5,ffffffffc02033ce <insert_vma_struct+0x4a>
ffffffffc02033be:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02033c2:	0506e863          	bltu	a3,a6,ffffffffc0203412 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02033c6:	ff07b603          	ld	a2,-16(a5)
ffffffffc02033ca:	02c6f263          	bleu	a2,a3,ffffffffc02033ee <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02033ce:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02033d0:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02033d2:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02033d6:	e390                	sd	a2,0(a5)
ffffffffc02033d8:	e710                	sd	a2,8(a4)
}
ffffffffc02033da:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02033dc:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02033de:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02033e0:	2685                	addiw	a3,a3,1
ffffffffc02033e2:	d114                	sw	a3,32(a0)
}
ffffffffc02033e4:	0141                	addi	sp,sp,16
ffffffffc02033e6:	8082                	ret
    if (le_prev != list) {
ffffffffc02033e8:	fca711e3          	bne	a4,a0,ffffffffc02033aa <insert_vma_struct+0x26>
ffffffffc02033ec:	bfd9                	j	ffffffffc02033c2 <insert_vma_struct+0x3e>
ffffffffc02033ee:	ebbff0ef          	jal	ra,ffffffffc02032a8 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02033f2:	00002697          	auipc	a3,0x2
ffffffffc02033f6:	74668693          	addi	a3,a3,1862 # ffffffffc0205b38 <default_pmm_manager+0xc48>
ffffffffc02033fa:	00001617          	auipc	a2,0x1
ffffffffc02033fe:	75e60613          	addi	a2,a2,1886 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203402:	08400593          	li	a1,132
ffffffffc0203406:	00002517          	auipc	a0,0x2
ffffffffc020340a:	68250513          	addi	a0,a0,1666 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020340e:	f67fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203412:	00002697          	auipc	a3,0x2
ffffffffc0203416:	76668693          	addi	a3,a3,1894 # ffffffffc0205b78 <default_pmm_manager+0xc88>
ffffffffc020341a:	00001617          	auipc	a2,0x1
ffffffffc020341e:	73e60613          	addi	a2,a2,1854 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203422:	07c00593          	li	a1,124
ffffffffc0203426:	00002517          	auipc	a0,0x2
ffffffffc020342a:	66250513          	addi	a0,a0,1634 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020342e:	f47fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203432:	00002697          	auipc	a3,0x2
ffffffffc0203436:	72668693          	addi	a3,a3,1830 # ffffffffc0205b58 <default_pmm_manager+0xc68>
ffffffffc020343a:	00001617          	auipc	a2,0x1
ffffffffc020343e:	71e60613          	addi	a2,a2,1822 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203442:	07b00593          	li	a1,123
ffffffffc0203446:	00002517          	auipc	a0,0x2
ffffffffc020344a:	64250513          	addi	a0,a0,1602 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020344e:	f27fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203452 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203452:	1141                	addi	sp,sp,-16
ffffffffc0203454:	e022                	sd	s0,0(sp)
ffffffffc0203456:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203458:	6508                	ld	a0,8(a0)
ffffffffc020345a:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020345c:	00a40e63          	beq	s0,a0,ffffffffc0203478 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203460:	6118                	ld	a4,0(a0)
ffffffffc0203462:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc0203464:	03000593          	li	a1,48
ffffffffc0203468:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020346a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020346c:	e398                	sd	a4,0(a5)
ffffffffc020346e:	aeeff0ef          	jal	ra,ffffffffc020275c <kfree>
    return listelm->next;
ffffffffc0203472:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203474:	fea416e3          	bne	s0,a0,ffffffffc0203460 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203478:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc020347a:	6402                	ld	s0,0(sp)
ffffffffc020347c:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020347e:	03000593          	li	a1,48
}
ffffffffc0203482:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203484:	ad8ff06f          	j	ffffffffc020275c <kfree>

ffffffffc0203488 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203488:	715d                	addi	sp,sp,-80
ffffffffc020348a:	e486                	sd	ra,72(sp)
ffffffffc020348c:	e0a2                	sd	s0,64(sp)
ffffffffc020348e:	fc26                	sd	s1,56(sp)
ffffffffc0203490:	f84a                	sd	s2,48(sp)
ffffffffc0203492:	f052                	sd	s4,32(sp)
ffffffffc0203494:	f44e                	sd	s3,40(sp)
ffffffffc0203496:	ec56                	sd	s5,24(sp)
ffffffffc0203498:	e85a                	sd	s6,16(sp)
ffffffffc020349a:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020349c:	aa0fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02034a0:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02034a2:	a9afe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc02034a6:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc02034a8:	e25ff0ef          	jal	ra,ffffffffc02032cc <mm_create>
    assert(mm != NULL);
ffffffffc02034ac:	842a                	mv	s0,a0
ffffffffc02034ae:	03200493          	li	s1,50
ffffffffc02034b2:	e919                	bnez	a0,ffffffffc02034c8 <vmm_init+0x40>
ffffffffc02034b4:	aeed                	j	ffffffffc02038ae <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc02034b6:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034b8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034ba:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02034be:	14ed                	addi	s1,s1,-5
ffffffffc02034c0:	8522                	mv	a0,s0
ffffffffc02034c2:	ec3ff0ef          	jal	ra,ffffffffc0203384 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02034c6:	c88d                	beqz	s1,ffffffffc02034f8 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034c8:	03000513          	li	a0,48
ffffffffc02034cc:	9ceff0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc02034d0:	85aa                	mv	a1,a0
ffffffffc02034d2:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02034d6:	f165                	bnez	a0,ffffffffc02034b6 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc02034d8:	00002697          	auipc	a3,0x2
ffffffffc02034dc:	1b068693          	addi	a3,a3,432 # ffffffffc0205688 <default_pmm_manager+0x798>
ffffffffc02034e0:	00001617          	auipc	a2,0x1
ffffffffc02034e4:	67860613          	addi	a2,a2,1656 # ffffffffc0204b58 <commands+0x870>
ffffffffc02034e8:	0ce00593          	li	a1,206
ffffffffc02034ec:	00002517          	auipc	a0,0x2
ffffffffc02034f0:	59c50513          	addi	a0,a0,1436 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02034f4:	e81fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02034f8:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02034fc:	1f900993          	li	s3,505
ffffffffc0203500:	a819                	j	ffffffffc0203516 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203502:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203504:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203506:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020350a:	0495                	addi	s1,s1,5
ffffffffc020350c:	8522                	mv	a0,s0
ffffffffc020350e:	e77ff0ef          	jal	ra,ffffffffc0203384 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203512:	03348a63          	beq	s1,s3,ffffffffc0203546 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203516:	03000513          	li	a0,48
ffffffffc020351a:	980ff0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc020351e:	85aa                	mv	a1,a0
ffffffffc0203520:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203524:	fd79                	bnez	a0,ffffffffc0203502 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc0203526:	00002697          	auipc	a3,0x2
ffffffffc020352a:	16268693          	addi	a3,a3,354 # ffffffffc0205688 <default_pmm_manager+0x798>
ffffffffc020352e:	00001617          	auipc	a2,0x1
ffffffffc0203532:	62a60613          	addi	a2,a2,1578 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203536:	0d400593          	li	a1,212
ffffffffc020353a:	00002517          	auipc	a0,0x2
ffffffffc020353e:	54e50513          	addi	a0,a0,1358 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc0203542:	e33fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203546:	6418                	ld	a4,8(s0)
ffffffffc0203548:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc020354a:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020354e:	2ae40063          	beq	s0,a4,ffffffffc02037ee <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203552:	fe873603          	ld	a2,-24(a4)
ffffffffc0203556:	ffe78693          	addi	a3,a5,-2
ffffffffc020355a:	20d61a63          	bne	a2,a3,ffffffffc020376e <vmm_init+0x2e6>
ffffffffc020355e:	ff073683          	ld	a3,-16(a4)
ffffffffc0203562:	20d79663          	bne	a5,a3,ffffffffc020376e <vmm_init+0x2e6>
ffffffffc0203566:	0795                	addi	a5,a5,5
ffffffffc0203568:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc020356a:	feb792e3          	bne	a5,a1,ffffffffc020354e <vmm_init+0xc6>
ffffffffc020356e:	499d                	li	s3,7
ffffffffc0203570:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203572:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203576:	85a6                	mv	a1,s1
ffffffffc0203578:	8522                	mv	a0,s0
ffffffffc020357a:	dcdff0ef          	jal	ra,ffffffffc0203346 <find_vma>
ffffffffc020357e:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0203580:	2e050763          	beqz	a0,ffffffffc020386e <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203584:	00148593          	addi	a1,s1,1
ffffffffc0203588:	8522                	mv	a0,s0
ffffffffc020358a:	dbdff0ef          	jal	ra,ffffffffc0203346 <find_vma>
ffffffffc020358e:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203590:	2a050f63          	beqz	a0,ffffffffc020384e <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203594:	85ce                	mv	a1,s3
ffffffffc0203596:	8522                	mv	a0,s0
ffffffffc0203598:	dafff0ef          	jal	ra,ffffffffc0203346 <find_vma>
        assert(vma3 == NULL);
ffffffffc020359c:	28051963          	bnez	a0,ffffffffc020382e <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02035a0:	00348593          	addi	a1,s1,3
ffffffffc02035a4:	8522                	mv	a0,s0
ffffffffc02035a6:	da1ff0ef          	jal	ra,ffffffffc0203346 <find_vma>
        assert(vma4 == NULL);
ffffffffc02035aa:	26051263          	bnez	a0,ffffffffc020380e <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02035ae:	00448593          	addi	a1,s1,4
ffffffffc02035b2:	8522                	mv	a0,s0
ffffffffc02035b4:	d93ff0ef          	jal	ra,ffffffffc0203346 <find_vma>
        assert(vma5 == NULL);
ffffffffc02035b8:	2c051b63          	bnez	a0,ffffffffc020388e <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02035bc:	008b3783          	ld	a5,8(s6)
ffffffffc02035c0:	1c979763          	bne	a5,s1,ffffffffc020378e <vmm_init+0x306>
ffffffffc02035c4:	010b3783          	ld	a5,16(s6)
ffffffffc02035c8:	1d379363          	bne	a5,s3,ffffffffc020378e <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02035cc:	008ab783          	ld	a5,8(s5)
ffffffffc02035d0:	1c979f63          	bne	a5,s1,ffffffffc02037ae <vmm_init+0x326>
ffffffffc02035d4:	010ab783          	ld	a5,16(s5)
ffffffffc02035d8:	1d379b63          	bne	a5,s3,ffffffffc02037ae <vmm_init+0x326>
ffffffffc02035dc:	0495                	addi	s1,s1,5
ffffffffc02035de:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02035e0:	f9749be3          	bne	s1,s7,ffffffffc0203576 <vmm_init+0xee>
ffffffffc02035e4:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02035e6:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02035e8:	85a6                	mv	a1,s1
ffffffffc02035ea:	8522                	mv	a0,s0
ffffffffc02035ec:	d5bff0ef          	jal	ra,ffffffffc0203346 <find_vma>
ffffffffc02035f0:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02035f4:	c90d                	beqz	a0,ffffffffc0203626 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02035f6:	6914                	ld	a3,16(a0)
ffffffffc02035f8:	6510                	ld	a2,8(a0)
ffffffffc02035fa:	00002517          	auipc	a0,0x2
ffffffffc02035fe:	69e50513          	addi	a0,a0,1694 # ffffffffc0205c98 <default_pmm_manager+0xda8>
ffffffffc0203602:	abdfc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203606:	00002697          	auipc	a3,0x2
ffffffffc020360a:	6ba68693          	addi	a3,a3,1722 # ffffffffc0205cc0 <default_pmm_manager+0xdd0>
ffffffffc020360e:	00001617          	auipc	a2,0x1
ffffffffc0203612:	54a60613          	addi	a2,a2,1354 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203616:	0f600593          	li	a1,246
ffffffffc020361a:	00002517          	auipc	a0,0x2
ffffffffc020361e:	46e50513          	addi	a0,a0,1134 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc0203622:	d53fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203626:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203628:	fd3490e3          	bne	s1,s3,ffffffffc02035e8 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc020362c:	8522                	mv	a0,s0
ffffffffc020362e:	e25ff0ef          	jal	ra,ffffffffc0203452 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203632:	90afe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0203636:	28aa1c63          	bne	s4,a0,ffffffffc02038ce <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020363a:	00002517          	auipc	a0,0x2
ffffffffc020363e:	6c650513          	addi	a0,a0,1734 # ffffffffc0205d00 <default_pmm_manager+0xe10>
ffffffffc0203642:	a7dfc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203646:	8f6fe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc020364a:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc020364c:	c81ff0ef          	jal	ra,ffffffffc02032cc <mm_create>
ffffffffc0203650:	0000e797          	auipc	a5,0xe
ffffffffc0203654:	f4a7b023          	sd	a0,-192(a5) # ffffffffc0211590 <check_mm_struct>
ffffffffc0203658:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc020365a:	2a050a63          	beqz	a0,ffffffffc020390e <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020365e:	0000e797          	auipc	a5,0xe
ffffffffc0203662:	df278793          	addi	a5,a5,-526 # ffffffffc0211450 <boot_pgdir>
ffffffffc0203666:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203668:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020366a:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc020366c:	32079d63          	bnez	a5,ffffffffc02039a6 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203670:	03000513          	li	a0,48
ffffffffc0203674:	826ff0ef          	jal	ra,ffffffffc020269a <kmalloc>
ffffffffc0203678:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc020367a:	14050a63          	beqz	a0,ffffffffc02037ce <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc020367e:	002007b7          	lui	a5,0x200
ffffffffc0203682:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203686:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203688:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020368a:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc020368e:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203690:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203694:	cf1ff0ef          	jal	ra,ffffffffc0203384 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203698:	10000593          	li	a1,256
ffffffffc020369c:	8522                	mv	a0,s0
ffffffffc020369e:	ca9ff0ef          	jal	ra,ffffffffc0203346 <find_vma>
ffffffffc02036a2:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc02036a6:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02036aa:	2aaa1263          	bne	s4,a0,ffffffffc020394e <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc02036ae:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc02036b2:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02036b4:	fee79de3          	bne	a5,a4,ffffffffc02036ae <vmm_init+0x226>
        sum += i;
ffffffffc02036b8:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02036ba:	10000793          	li	a5,256
        sum += i;
ffffffffc02036be:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02036c2:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02036c6:	0007c683          	lbu	a3,0(a5)
ffffffffc02036ca:	0785                	addi	a5,a5,1
ffffffffc02036cc:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02036ce:	fec79ce3          	bne	a5,a2,ffffffffc02036c6 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc02036d2:	2a071a63          	bnez	a4,ffffffffc0203986 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02036d6:	4581                	li	a1,0
ffffffffc02036d8:	8526                	mv	a0,s1
ffffffffc02036da:	b08fe0ef          	jal	ra,ffffffffc02019e2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02036de:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc02036e0:	0000e717          	auipc	a4,0xe
ffffffffc02036e4:	d7870713          	addi	a4,a4,-648 # ffffffffc0211458 <npage>
ffffffffc02036e8:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036ea:	078a                	slli	a5,a5,0x2
ffffffffc02036ec:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036ee:	28e7f063          	bleu	a4,a5,ffffffffc020396e <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc02036f2:	00003717          	auipc	a4,0x3
ffffffffc02036f6:	94e70713          	addi	a4,a4,-1714 # ffffffffc0206040 <nbase>
ffffffffc02036fa:	6318                	ld	a4,0(a4)
ffffffffc02036fc:	0000e697          	auipc	a3,0xe
ffffffffc0203700:	dac68693          	addi	a3,a3,-596 # ffffffffc02114a8 <pages>
ffffffffc0203704:	6288                	ld	a0,0(a3)
ffffffffc0203706:	8f99                	sub	a5,a5,a4
ffffffffc0203708:	00379713          	slli	a4,a5,0x3
ffffffffc020370c:	97ba                	add	a5,a5,a4
ffffffffc020370e:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203710:	953e                	add	a0,a0,a5
ffffffffc0203712:	4585                	li	a1,1
ffffffffc0203714:	fe3fd0ef          	jal	ra,ffffffffc02016f6 <free_pages>

    pgdir[0] = 0;
ffffffffc0203718:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020371c:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc020371e:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc0203722:	d31ff0ef          	jal	ra,ffffffffc0203452 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc0203726:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc0203728:	0000e797          	auipc	a5,0xe
ffffffffc020372c:	e607b423          	sd	zero,-408(a5) # ffffffffc0211590 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203730:	80cfe0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
ffffffffc0203734:	1aa99d63          	bne	s3,a0,ffffffffc02038ee <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203738:	00002517          	auipc	a0,0x2
ffffffffc020373c:	63050513          	addi	a0,a0,1584 # ffffffffc0205d68 <default_pmm_manager+0xe78>
ffffffffc0203740:	97ffc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203744:	ff9fd0ef          	jal	ra,ffffffffc020173c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc0203748:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020374a:	1ea91263          	bne	s2,a0,ffffffffc020392e <vmm_init+0x4a6>
}
ffffffffc020374e:	6406                	ld	s0,64(sp)
ffffffffc0203750:	60a6                	ld	ra,72(sp)
ffffffffc0203752:	74e2                	ld	s1,56(sp)
ffffffffc0203754:	7942                	ld	s2,48(sp)
ffffffffc0203756:	79a2                	ld	s3,40(sp)
ffffffffc0203758:	7a02                	ld	s4,32(sp)
ffffffffc020375a:	6ae2                	ld	s5,24(sp)
ffffffffc020375c:	6b42                	ld	s6,16(sp)
ffffffffc020375e:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203760:	00002517          	auipc	a0,0x2
ffffffffc0203764:	62850513          	addi	a0,a0,1576 # ffffffffc0205d88 <default_pmm_manager+0xe98>
}
ffffffffc0203768:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc020376a:	955fc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020376e:	00002697          	auipc	a3,0x2
ffffffffc0203772:	44268693          	addi	a3,a3,1090 # ffffffffc0205bb0 <default_pmm_manager+0xcc0>
ffffffffc0203776:	00001617          	auipc	a2,0x1
ffffffffc020377a:	3e260613          	addi	a2,a2,994 # ffffffffc0204b58 <commands+0x870>
ffffffffc020377e:	0dd00593          	li	a1,221
ffffffffc0203782:	00002517          	auipc	a0,0x2
ffffffffc0203786:	30650513          	addi	a0,a0,774 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020378a:	bebfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020378e:	00002697          	auipc	a3,0x2
ffffffffc0203792:	4aa68693          	addi	a3,a3,1194 # ffffffffc0205c38 <default_pmm_manager+0xd48>
ffffffffc0203796:	00001617          	auipc	a2,0x1
ffffffffc020379a:	3c260613          	addi	a2,a2,962 # ffffffffc0204b58 <commands+0x870>
ffffffffc020379e:	0ed00593          	li	a1,237
ffffffffc02037a2:	00002517          	auipc	a0,0x2
ffffffffc02037a6:	2e650513          	addi	a0,a0,742 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02037aa:	bcbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02037ae:	00002697          	auipc	a3,0x2
ffffffffc02037b2:	4ba68693          	addi	a3,a3,1210 # ffffffffc0205c68 <default_pmm_manager+0xd78>
ffffffffc02037b6:	00001617          	auipc	a2,0x1
ffffffffc02037ba:	3a260613          	addi	a2,a2,930 # ffffffffc0204b58 <commands+0x870>
ffffffffc02037be:	0ee00593          	li	a1,238
ffffffffc02037c2:	00002517          	auipc	a0,0x2
ffffffffc02037c6:	2c650513          	addi	a0,a0,710 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02037ca:	babfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc02037ce:	00002697          	auipc	a3,0x2
ffffffffc02037d2:	eba68693          	addi	a3,a3,-326 # ffffffffc0205688 <default_pmm_manager+0x798>
ffffffffc02037d6:	00001617          	auipc	a2,0x1
ffffffffc02037da:	38260613          	addi	a2,a2,898 # ffffffffc0204b58 <commands+0x870>
ffffffffc02037de:	11100593          	li	a1,273
ffffffffc02037e2:	00002517          	auipc	a0,0x2
ffffffffc02037e6:	2a650513          	addi	a0,a0,678 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02037ea:	b8bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02037ee:	00002697          	auipc	a3,0x2
ffffffffc02037f2:	3aa68693          	addi	a3,a3,938 # ffffffffc0205b98 <default_pmm_manager+0xca8>
ffffffffc02037f6:	00001617          	auipc	a2,0x1
ffffffffc02037fa:	36260613          	addi	a2,a2,866 # ffffffffc0204b58 <commands+0x870>
ffffffffc02037fe:	0db00593          	li	a1,219
ffffffffc0203802:	00002517          	auipc	a0,0x2
ffffffffc0203806:	28650513          	addi	a0,a0,646 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020380a:	b6bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc020380e:	00002697          	auipc	a3,0x2
ffffffffc0203812:	40a68693          	addi	a3,a3,1034 # ffffffffc0205c18 <default_pmm_manager+0xd28>
ffffffffc0203816:	00001617          	auipc	a2,0x1
ffffffffc020381a:	34260613          	addi	a2,a2,834 # ffffffffc0204b58 <commands+0x870>
ffffffffc020381e:	0e900593          	li	a1,233
ffffffffc0203822:	00002517          	auipc	a0,0x2
ffffffffc0203826:	26650513          	addi	a0,a0,614 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020382a:	b4bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc020382e:	00002697          	auipc	a3,0x2
ffffffffc0203832:	3da68693          	addi	a3,a3,986 # ffffffffc0205c08 <default_pmm_manager+0xd18>
ffffffffc0203836:	00001617          	auipc	a2,0x1
ffffffffc020383a:	32260613          	addi	a2,a2,802 # ffffffffc0204b58 <commands+0x870>
ffffffffc020383e:	0e700593          	li	a1,231
ffffffffc0203842:	00002517          	auipc	a0,0x2
ffffffffc0203846:	24650513          	addi	a0,a0,582 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020384a:	b2bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc020384e:	00002697          	auipc	a3,0x2
ffffffffc0203852:	3aa68693          	addi	a3,a3,938 # ffffffffc0205bf8 <default_pmm_manager+0xd08>
ffffffffc0203856:	00001617          	auipc	a2,0x1
ffffffffc020385a:	30260613          	addi	a2,a2,770 # ffffffffc0204b58 <commands+0x870>
ffffffffc020385e:	0e500593          	li	a1,229
ffffffffc0203862:	00002517          	auipc	a0,0x2
ffffffffc0203866:	22650513          	addi	a0,a0,550 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020386a:	b0bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc020386e:	00002697          	auipc	a3,0x2
ffffffffc0203872:	37a68693          	addi	a3,a3,890 # ffffffffc0205be8 <default_pmm_manager+0xcf8>
ffffffffc0203876:	00001617          	auipc	a2,0x1
ffffffffc020387a:	2e260613          	addi	a2,a2,738 # ffffffffc0204b58 <commands+0x870>
ffffffffc020387e:	0e300593          	li	a1,227
ffffffffc0203882:	00002517          	auipc	a0,0x2
ffffffffc0203886:	20650513          	addi	a0,a0,518 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020388a:	aebfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc020388e:	00002697          	auipc	a3,0x2
ffffffffc0203892:	39a68693          	addi	a3,a3,922 # ffffffffc0205c28 <default_pmm_manager+0xd38>
ffffffffc0203896:	00001617          	auipc	a2,0x1
ffffffffc020389a:	2c260613          	addi	a2,a2,706 # ffffffffc0204b58 <commands+0x870>
ffffffffc020389e:	0eb00593          	li	a1,235
ffffffffc02038a2:	00002517          	auipc	a0,0x2
ffffffffc02038a6:	1e650513          	addi	a0,a0,486 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02038aa:	acbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc02038ae:	00002697          	auipc	a3,0x2
ffffffffc02038b2:	da268693          	addi	a3,a3,-606 # ffffffffc0205650 <default_pmm_manager+0x760>
ffffffffc02038b6:	00001617          	auipc	a2,0x1
ffffffffc02038ba:	2a260613          	addi	a2,a2,674 # ffffffffc0204b58 <commands+0x870>
ffffffffc02038be:	0c700593          	li	a1,199
ffffffffc02038c2:	00002517          	auipc	a0,0x2
ffffffffc02038c6:	1c650513          	addi	a0,a0,454 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02038ca:	aabfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038ce:	00002697          	auipc	a3,0x2
ffffffffc02038d2:	40a68693          	addi	a3,a3,1034 # ffffffffc0205cd8 <default_pmm_manager+0xde8>
ffffffffc02038d6:	00001617          	auipc	a2,0x1
ffffffffc02038da:	28260613          	addi	a2,a2,642 # ffffffffc0204b58 <commands+0x870>
ffffffffc02038de:	0fb00593          	li	a1,251
ffffffffc02038e2:	00002517          	auipc	a0,0x2
ffffffffc02038e6:	1a650513          	addi	a0,a0,422 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02038ea:	a8bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038ee:	00002697          	auipc	a3,0x2
ffffffffc02038f2:	3ea68693          	addi	a3,a3,1002 # ffffffffc0205cd8 <default_pmm_manager+0xde8>
ffffffffc02038f6:	00001617          	auipc	a2,0x1
ffffffffc02038fa:	26260613          	addi	a2,a2,610 # ffffffffc0204b58 <commands+0x870>
ffffffffc02038fe:	12e00593          	li	a1,302
ffffffffc0203902:	00002517          	auipc	a0,0x2
ffffffffc0203906:	18650513          	addi	a0,a0,390 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020390a:	a6bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020390e:	00002697          	auipc	a3,0x2
ffffffffc0203912:	41268693          	addi	a3,a3,1042 # ffffffffc0205d20 <default_pmm_manager+0xe30>
ffffffffc0203916:	00001617          	auipc	a2,0x1
ffffffffc020391a:	24260613          	addi	a2,a2,578 # ffffffffc0204b58 <commands+0x870>
ffffffffc020391e:	10a00593          	li	a1,266
ffffffffc0203922:	00002517          	auipc	a0,0x2
ffffffffc0203926:	16650513          	addi	a0,a0,358 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020392a:	a4bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020392e:	00002697          	auipc	a3,0x2
ffffffffc0203932:	3aa68693          	addi	a3,a3,938 # ffffffffc0205cd8 <default_pmm_manager+0xde8>
ffffffffc0203936:	00001617          	auipc	a2,0x1
ffffffffc020393a:	22260613          	addi	a2,a2,546 # ffffffffc0204b58 <commands+0x870>
ffffffffc020393e:	0bd00593          	li	a1,189
ffffffffc0203942:	00002517          	auipc	a0,0x2
ffffffffc0203946:	14650513          	addi	a0,a0,326 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020394a:	a2bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc020394e:	00002697          	auipc	a3,0x2
ffffffffc0203952:	3ea68693          	addi	a3,a3,1002 # ffffffffc0205d38 <default_pmm_manager+0xe48>
ffffffffc0203956:	00001617          	auipc	a2,0x1
ffffffffc020395a:	20260613          	addi	a2,a2,514 # ffffffffc0204b58 <commands+0x870>
ffffffffc020395e:	11600593          	li	a1,278
ffffffffc0203962:	00002517          	auipc	a0,0x2
ffffffffc0203966:	12650513          	addi	a0,a0,294 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc020396a:	a0bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020396e:	00001617          	auipc	a2,0x1
ffffffffc0203972:	64a60613          	addi	a2,a2,1610 # ffffffffc0204fb8 <default_pmm_manager+0xc8>
ffffffffc0203976:	06500593          	li	a1,101
ffffffffc020397a:	00001517          	auipc	a0,0x1
ffffffffc020397e:	65e50513          	addi	a0,a0,1630 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc0203982:	9f3fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203986:	00002697          	auipc	a3,0x2
ffffffffc020398a:	3d268693          	addi	a3,a3,978 # ffffffffc0205d58 <default_pmm_manager+0xe68>
ffffffffc020398e:	00001617          	auipc	a2,0x1
ffffffffc0203992:	1ca60613          	addi	a2,a2,458 # ffffffffc0204b58 <commands+0x870>
ffffffffc0203996:	12000593          	li	a1,288
ffffffffc020399a:	00002517          	auipc	a0,0x2
ffffffffc020399e:	0ee50513          	addi	a0,a0,238 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02039a2:	9d3fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02039a6:	00002697          	auipc	a3,0x2
ffffffffc02039aa:	cd268693          	addi	a3,a3,-814 # ffffffffc0205678 <default_pmm_manager+0x788>
ffffffffc02039ae:	00001617          	auipc	a2,0x1
ffffffffc02039b2:	1aa60613          	addi	a2,a2,426 # ffffffffc0204b58 <commands+0x870>
ffffffffc02039b6:	10d00593          	li	a1,269
ffffffffc02039ba:	00002517          	auipc	a0,0x2
ffffffffc02039be:	0ce50513          	addi	a0,a0,206 # ffffffffc0205a88 <default_pmm_manager+0xb98>
ffffffffc02039c2:	9b3fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02039c6 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02039c6:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    // 找到地址所在的虚拟内存区域，检查虚拟地址是否合法
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02039c8:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02039ca:	f822                	sd	s0,48(sp)
ffffffffc02039cc:	f426                	sd	s1,40(sp)
ffffffffc02039ce:	fc06                	sd	ra,56(sp)
ffffffffc02039d0:	f04a                	sd	s2,32(sp)
ffffffffc02039d2:	ec4e                	sd	s3,24(sp)
ffffffffc02039d4:	8432                	mv	s0,a2
ffffffffc02039d6:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02039d8:	96fff0ef          	jal	ra,ffffffffc0203346 <find_vma>

    pgfault_num++;
ffffffffc02039dc:	0000e797          	auipc	a5,0xe
ffffffffc02039e0:	a9078793          	addi	a5,a5,-1392 # ffffffffc021146c <pgfault_num>
ffffffffc02039e4:	439c                	lw	a5,0(a5)
ffffffffc02039e6:	2785                	addiw	a5,a5,1
ffffffffc02039e8:	0000e717          	auipc	a4,0xe
ffffffffc02039ec:	a8f72223          	sw	a5,-1404(a4) # ffffffffc021146c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02039f0:	c54d                	beqz	a0,ffffffffc0203a9a <do_pgfault+0xd4>
ffffffffc02039f2:	651c                	ld	a5,8(a0)
ffffffffc02039f4:	0af46363          	bltu	s0,a5,ffffffffc0203a9a <do_pgfault+0xd4>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02039f8:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02039fa:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02039fc:	8b89                	andi	a5,a5,2
ffffffffc02039fe:	efb9                	bnez	a5,ffffffffc0203a5c <do_pgfault+0x96>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a00:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */

    // 从mm->pgdir中获取addr对应的页表项 
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a02:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203a04:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203a06:	85a2                	mv	a1,s0
ffffffffc0203a08:	4605                	li	a2,1
ffffffffc0203a0a:	d73fd0ef          	jal	ra,ffffffffc020177c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {  // 页表项内容为0，之前并不存在映射关系，创建
ffffffffc0203a0e:	610c                	ld	a1,0(a0)
ffffffffc0203a10:	c5b5                	beqz	a1,ffffffffc0203a7c <do_pgfault+0xb6>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203a12:	0000e797          	auipc	a5,0xe
ffffffffc0203a16:	a5678793          	addi	a5,a5,-1450 # ffffffffc0211468 <swap_init_ok>
ffffffffc0203a1a:	439c                	lw	a5,0(a5)
ffffffffc0203a1c:	2781                	sext.w	a5,a5
ffffffffc0203a1e:	c7d9                	beqz	a5,ffffffffc0203aac <do_pgfault+0xe6>
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            // 根据addr将磁盘页的内容读入内存页，page是新开辟的内存页，将磁盘页的内容读入这个内存页
            if((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0203a20:	0030                	addi	a2,sp,8
ffffffffc0203a22:	85a2                	mv	a1,s0
ffffffffc0203a24:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203a26:	e402                	sd	zero,8(sp)
            if((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0203a28:	dd8ff0ef          	jal	ra,ffffffffc0203000 <swap_in>
ffffffffc0203a2c:	892a                	mv	s2,a0
ffffffffc0203a2e:	e90d                	bnez	a0,ffffffffc0203a60 <do_pgfault+0x9a>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            // 建立一个Page与pgdir的页表项的映射
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203a30:	65a2                	ld	a1,8(sp)
ffffffffc0203a32:	6c88                	ld	a0,24(s1)
ffffffffc0203a34:	86ce                	mv	a3,s3
ffffffffc0203a36:	8622                	mv	a2,s0
ffffffffc0203a38:	81cfe0ef          	jal	ra,ffffffffc0201a54 <page_insert>
            
            //(3) make the page swappable.
            // 设置页面可交换
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203a3c:	6622                	ld	a2,8(sp)
ffffffffc0203a3e:	4685                	li	a3,1
ffffffffc0203a40:	85a2                	mv	a1,s0
ffffffffc0203a42:	8526                	mv	a0,s1
ffffffffc0203a44:	c98ff0ef          	jal	ra,ffffffffc0202edc <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203a48:	67a2                	ld	a5,8(sp)
ffffffffc0203a4a:	e3a0                	sd	s0,64(a5)
   }

   ret = 0;
failed:
    return ret;
ffffffffc0203a4c:	70e2                	ld	ra,56(sp)
ffffffffc0203a4e:	7442                	ld	s0,48(sp)
ffffffffc0203a50:	854a                	mv	a0,s2
ffffffffc0203a52:	74a2                	ld	s1,40(sp)
ffffffffc0203a54:	7902                	ld	s2,32(sp)
ffffffffc0203a56:	69e2                	ld	s3,24(sp)
ffffffffc0203a58:	6121                	addi	sp,sp,64
ffffffffc0203a5a:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203a5c:	49d9                	li	s3,22
ffffffffc0203a5e:	b74d                	j	ffffffffc0203a00 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0203a60:	00002517          	auipc	a0,0x2
ffffffffc0203a64:	09050513          	addi	a0,a0,144 # ffffffffc0205af0 <default_pmm_manager+0xc00>
ffffffffc0203a68:	e56fc0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0203a6c:	70e2                	ld	ra,56(sp)
ffffffffc0203a6e:	7442                	ld	s0,48(sp)
ffffffffc0203a70:	854a                	mv	a0,s2
ffffffffc0203a72:	74a2                	ld	s1,40(sp)
ffffffffc0203a74:	7902                	ld	s2,32(sp)
ffffffffc0203a76:	69e2                	ld	s3,24(sp)
ffffffffc0203a78:	6121                	addi	sp,sp,64
ffffffffc0203a7a:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a7c:	6c88                	ld	a0,24(s1)
ffffffffc0203a7e:	864e                	mv	a2,s3
ffffffffc0203a80:	85a2                	mv	a1,s0
ffffffffc0203a82:	b87fe0ef          	jal	ra,ffffffffc0202608 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203a86:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203a88:	f171                	bnez	a0,ffffffffc0203a4c <do_pgfault+0x86>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203a8a:	00002517          	auipc	a0,0x2
ffffffffc0203a8e:	03e50513          	addi	a0,a0,62 # ffffffffc0205ac8 <default_pmm_manager+0xbd8>
ffffffffc0203a92:	e2cfc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203a96:	5971                	li	s2,-4
            goto failed;
ffffffffc0203a98:	bf55                	j	ffffffffc0203a4c <do_pgfault+0x86>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203a9a:	85a2                	mv	a1,s0
ffffffffc0203a9c:	00002517          	auipc	a0,0x2
ffffffffc0203aa0:	ffc50513          	addi	a0,a0,-4 # ffffffffc0205a98 <default_pmm_manager+0xba8>
ffffffffc0203aa4:	e1afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203aa8:	5975                	li	s2,-3
        goto failed;
ffffffffc0203aaa:	b74d                	j	ffffffffc0203a4c <do_pgfault+0x86>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203aac:	00002517          	auipc	a0,0x2
ffffffffc0203ab0:	06450513          	addi	a0,a0,100 # ffffffffc0205b10 <default_pmm_manager+0xc20>
ffffffffc0203ab4:	e0afc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ab8:	5971                	li	s2,-4
            goto failed;
ffffffffc0203aba:	bf49                	j	ffffffffc0203a4c <do_pgfault+0x86>

ffffffffc0203abc <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203abc:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203abe:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203ac0:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203ac2:	9ddfc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203ac6:	cd01                	beqz	a0,ffffffffc0203ade <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ac8:	4505                	li	a0,1
ffffffffc0203aca:	9dbfc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203ace:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203ad0:	810d                	srli	a0,a0,0x3
ffffffffc0203ad2:	0000e797          	auipc	a5,0xe
ffffffffc0203ad6:	a6a7b323          	sd	a0,-1434(a5) # ffffffffc0211538 <max_swap_offset>
}
ffffffffc0203ada:	0141                	addi	sp,sp,16
ffffffffc0203adc:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203ade:	00002617          	auipc	a2,0x2
ffffffffc0203ae2:	2c260613          	addi	a2,a2,706 # ffffffffc0205da0 <default_pmm_manager+0xeb0>
ffffffffc0203ae6:	45b5                	li	a1,13
ffffffffc0203ae8:	00002517          	auipc	a0,0x2
ffffffffc0203aec:	2d850513          	addi	a0,a0,728 # ffffffffc0205dc0 <default_pmm_manager+0xed0>
ffffffffc0203af0:	885fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203af4 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203af4:	1141                	addi	sp,sp,-16
ffffffffc0203af6:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203af8:	00855793          	srli	a5,a0,0x8
ffffffffc0203afc:	c7b5                	beqz	a5,ffffffffc0203b68 <swapfs_read+0x74>
ffffffffc0203afe:	0000e717          	auipc	a4,0xe
ffffffffc0203b02:	a3a70713          	addi	a4,a4,-1478 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203b06:	6318                	ld	a4,0(a4)
ffffffffc0203b08:	06e7f063          	bleu	a4,a5,ffffffffc0203b68 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b0c:	0000e717          	auipc	a4,0xe
ffffffffc0203b10:	99c70713          	addi	a4,a4,-1636 # ffffffffc02114a8 <pages>
ffffffffc0203b14:	6310                	ld	a2,0(a4)
ffffffffc0203b16:	00001717          	auipc	a4,0x1
ffffffffc0203b1a:	02a70713          	addi	a4,a4,42 # ffffffffc0204b40 <commands+0x858>
ffffffffc0203b1e:	00002697          	auipc	a3,0x2
ffffffffc0203b22:	52268693          	addi	a3,a3,1314 # ffffffffc0206040 <nbase>
ffffffffc0203b26:	40c58633          	sub	a2,a1,a2
ffffffffc0203b2a:	630c                	ld	a1,0(a4)
ffffffffc0203b2c:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b2e:	0000e717          	auipc	a4,0xe
ffffffffc0203b32:	92a70713          	addi	a4,a4,-1750 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b36:	02b60633          	mul	a2,a2,a1
ffffffffc0203b3a:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203b3e:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b40:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203b42:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b44:	57fd                	li	a5,-1
ffffffffc0203b46:	83b1                	srli	a5,a5,0xc
ffffffffc0203b48:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203b4a:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203b4c:	02e7fa63          	bleu	a4,a5,ffffffffc0203b80 <swapfs_read+0x8c>
ffffffffc0203b50:	0000e797          	auipc	a5,0xe
ffffffffc0203b54:	94878793          	addi	a5,a5,-1720 # ffffffffc0211498 <va_pa_offset>
ffffffffc0203b58:	639c                	ld	a5,0(a5)
}
ffffffffc0203b5a:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b5c:	46a1                	li	a3,8
ffffffffc0203b5e:	963e                	add	a2,a2,a5
ffffffffc0203b60:	4505                	li	a0,1
}
ffffffffc0203b62:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b64:	947fc06f          	j	ffffffffc02004aa <ide_read_secs>
ffffffffc0203b68:	86aa                	mv	a3,a0
ffffffffc0203b6a:	00002617          	auipc	a2,0x2
ffffffffc0203b6e:	26e60613          	addi	a2,a2,622 # ffffffffc0205dd8 <default_pmm_manager+0xee8>
ffffffffc0203b72:	45d1                	li	a1,20
ffffffffc0203b74:	00002517          	auipc	a0,0x2
ffffffffc0203b78:	24c50513          	addi	a0,a0,588 # ffffffffc0205dc0 <default_pmm_manager+0xed0>
ffffffffc0203b7c:	ff8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203b80:	86b2                	mv	a3,a2
ffffffffc0203b82:	06a00593          	li	a1,106
ffffffffc0203b86:	00001617          	auipc	a2,0x1
ffffffffc0203b8a:	3ba60613          	addi	a2,a2,954 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc0203b8e:	00001517          	auipc	a0,0x1
ffffffffc0203b92:	44a50513          	addi	a0,a0,1098 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc0203b96:	fdefc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b9a <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203b9a:	1141                	addi	sp,sp,-16
ffffffffc0203b9c:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203b9e:	00855793          	srli	a5,a0,0x8
ffffffffc0203ba2:	c7b5                	beqz	a5,ffffffffc0203c0e <swapfs_write+0x74>
ffffffffc0203ba4:	0000e717          	auipc	a4,0xe
ffffffffc0203ba8:	99470713          	addi	a4,a4,-1644 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203bac:	6318                	ld	a4,0(a4)
ffffffffc0203bae:	06e7f063          	bleu	a4,a5,ffffffffc0203c0e <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203bb2:	0000e717          	auipc	a4,0xe
ffffffffc0203bb6:	8f670713          	addi	a4,a4,-1802 # ffffffffc02114a8 <pages>
ffffffffc0203bba:	6310                	ld	a2,0(a4)
ffffffffc0203bbc:	00001717          	auipc	a4,0x1
ffffffffc0203bc0:	f8470713          	addi	a4,a4,-124 # ffffffffc0204b40 <commands+0x858>
ffffffffc0203bc4:	00002697          	auipc	a3,0x2
ffffffffc0203bc8:	47c68693          	addi	a3,a3,1148 # ffffffffc0206040 <nbase>
ffffffffc0203bcc:	40c58633          	sub	a2,a1,a2
ffffffffc0203bd0:	630c                	ld	a1,0(a4)
ffffffffc0203bd2:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bd4:	0000e717          	auipc	a4,0xe
ffffffffc0203bd8:	88470713          	addi	a4,a4,-1916 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203bdc:	02b60633          	mul	a2,a2,a1
ffffffffc0203be0:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203be4:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203be6:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203be8:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bea:	57fd                	li	a5,-1
ffffffffc0203bec:	83b1                	srli	a5,a5,0xc
ffffffffc0203bee:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203bf0:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203bf2:	02e7fa63          	bleu	a4,a5,ffffffffc0203c26 <swapfs_write+0x8c>
ffffffffc0203bf6:	0000e797          	auipc	a5,0xe
ffffffffc0203bfa:	8a278793          	addi	a5,a5,-1886 # ffffffffc0211498 <va_pa_offset>
ffffffffc0203bfe:	639c                	ld	a5,0(a5)
}
ffffffffc0203c00:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c02:	46a1                	li	a3,8
ffffffffc0203c04:	963e                	add	a2,a2,a5
ffffffffc0203c06:	4505                	li	a0,1
}
ffffffffc0203c08:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c0a:	8c5fc06f          	j	ffffffffc02004ce <ide_write_secs>
ffffffffc0203c0e:	86aa                	mv	a3,a0
ffffffffc0203c10:	00002617          	auipc	a2,0x2
ffffffffc0203c14:	1c860613          	addi	a2,a2,456 # ffffffffc0205dd8 <default_pmm_manager+0xee8>
ffffffffc0203c18:	45e5                	li	a1,25
ffffffffc0203c1a:	00002517          	auipc	a0,0x2
ffffffffc0203c1e:	1a650513          	addi	a0,a0,422 # ffffffffc0205dc0 <default_pmm_manager+0xed0>
ffffffffc0203c22:	f52fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203c26:	86b2                	mv	a3,a2
ffffffffc0203c28:	06a00593          	li	a1,106
ffffffffc0203c2c:	00001617          	auipc	a2,0x1
ffffffffc0203c30:	31460613          	addi	a2,a2,788 # ffffffffc0204f40 <default_pmm_manager+0x50>
ffffffffc0203c34:	00001517          	auipc	a0,0x1
ffffffffc0203c38:	3a450513          	addi	a0,a0,932 # ffffffffc0204fd8 <default_pmm_manager+0xe8>
ffffffffc0203c3c:	f38fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c40 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203c40:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203c44:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203c46:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203c4a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203c4c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203c50:	f022                	sd	s0,32(sp)
ffffffffc0203c52:	ec26                	sd	s1,24(sp)
ffffffffc0203c54:	e84a                	sd	s2,16(sp)
ffffffffc0203c56:	f406                	sd	ra,40(sp)
ffffffffc0203c58:	e44e                	sd	s3,8(sp)
ffffffffc0203c5a:	84aa                	mv	s1,a0
ffffffffc0203c5c:	892e                	mv	s2,a1
ffffffffc0203c5e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203c62:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203c64:	03067e63          	bleu	a6,a2,ffffffffc0203ca0 <printnum+0x60>
ffffffffc0203c68:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203c6a:	00805763          	blez	s0,ffffffffc0203c78 <printnum+0x38>
ffffffffc0203c6e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203c70:	85ca                	mv	a1,s2
ffffffffc0203c72:	854e                	mv	a0,s3
ffffffffc0203c74:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203c76:	fc65                	bnez	s0,ffffffffc0203c6e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c78:	1a02                	slli	s4,s4,0x20
ffffffffc0203c7a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203c7e:	00002797          	auipc	a5,0x2
ffffffffc0203c82:	30a78793          	addi	a5,a5,778 # ffffffffc0205f88 <error_string+0x38>
ffffffffc0203c86:	9a3e                	add	s4,s4,a5
}
ffffffffc0203c88:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c8a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203c8e:	70a2                	ld	ra,40(sp)
ffffffffc0203c90:	69a2                	ld	s3,8(sp)
ffffffffc0203c92:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c94:	85ca                	mv	a1,s2
ffffffffc0203c96:	8326                	mv	t1,s1
}
ffffffffc0203c98:	6942                	ld	s2,16(sp)
ffffffffc0203c9a:	64e2                	ld	s1,24(sp)
ffffffffc0203c9c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203c9e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203ca0:	03065633          	divu	a2,a2,a6
ffffffffc0203ca4:	8722                	mv	a4,s0
ffffffffc0203ca6:	f9bff0ef          	jal	ra,ffffffffc0203c40 <printnum>
ffffffffc0203caa:	b7f9                	j	ffffffffc0203c78 <printnum+0x38>

ffffffffc0203cac <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203cac:	7119                	addi	sp,sp,-128
ffffffffc0203cae:	f4a6                	sd	s1,104(sp)
ffffffffc0203cb0:	f0ca                	sd	s2,96(sp)
ffffffffc0203cb2:	e8d2                	sd	s4,80(sp)
ffffffffc0203cb4:	e4d6                	sd	s5,72(sp)
ffffffffc0203cb6:	e0da                	sd	s6,64(sp)
ffffffffc0203cb8:	fc5e                	sd	s7,56(sp)
ffffffffc0203cba:	f862                	sd	s8,48(sp)
ffffffffc0203cbc:	f06a                	sd	s10,32(sp)
ffffffffc0203cbe:	fc86                	sd	ra,120(sp)
ffffffffc0203cc0:	f8a2                	sd	s0,112(sp)
ffffffffc0203cc2:	ecce                	sd	s3,88(sp)
ffffffffc0203cc4:	f466                	sd	s9,40(sp)
ffffffffc0203cc6:	ec6e                	sd	s11,24(sp)
ffffffffc0203cc8:	892a                	mv	s2,a0
ffffffffc0203cca:	84ae                	mv	s1,a1
ffffffffc0203ccc:	8d32                	mv	s10,a2
ffffffffc0203cce:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203cd0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203cd2:	00002a17          	auipc	s4,0x2
ffffffffc0203cd6:	126a0a13          	addi	s4,s4,294 # ffffffffc0205df8 <default_pmm_manager+0xf08>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203cda:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203cde:	00002c17          	auipc	s8,0x2
ffffffffc0203ce2:	272c0c13          	addi	s8,s8,626 # ffffffffc0205f50 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ce6:	000d4503          	lbu	a0,0(s10)
ffffffffc0203cea:	02500793          	li	a5,37
ffffffffc0203cee:	001d0413          	addi	s0,s10,1
ffffffffc0203cf2:	00f50e63          	beq	a0,a5,ffffffffc0203d0e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203cf6:	c521                	beqz	a0,ffffffffc0203d3e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203cf8:	02500993          	li	s3,37
ffffffffc0203cfc:	a011                	j	ffffffffc0203d00 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203cfe:	c121                	beqz	a0,ffffffffc0203d3e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203d00:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203d02:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203d04:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203d06:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203d0a:	ff351ae3          	bne	a0,s3,ffffffffc0203cfe <vprintfmt+0x52>
ffffffffc0203d0e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203d12:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203d16:	4981                	li	s3,0
ffffffffc0203d18:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203d1a:	5cfd                	li	s9,-1
ffffffffc0203d1c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d1e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203d22:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d24:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203d28:	0ff6f693          	andi	a3,a3,255
ffffffffc0203d2c:	00140d13          	addi	s10,s0,1
ffffffffc0203d30:	20d5e563          	bltu	a1,a3,ffffffffc0203f3a <vprintfmt+0x28e>
ffffffffc0203d34:	068a                	slli	a3,a3,0x2
ffffffffc0203d36:	96d2                	add	a3,a3,s4
ffffffffc0203d38:	4294                	lw	a3,0(a3)
ffffffffc0203d3a:	96d2                	add	a3,a3,s4
ffffffffc0203d3c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203d3e:	70e6                	ld	ra,120(sp)
ffffffffc0203d40:	7446                	ld	s0,112(sp)
ffffffffc0203d42:	74a6                	ld	s1,104(sp)
ffffffffc0203d44:	7906                	ld	s2,96(sp)
ffffffffc0203d46:	69e6                	ld	s3,88(sp)
ffffffffc0203d48:	6a46                	ld	s4,80(sp)
ffffffffc0203d4a:	6aa6                	ld	s5,72(sp)
ffffffffc0203d4c:	6b06                	ld	s6,64(sp)
ffffffffc0203d4e:	7be2                	ld	s7,56(sp)
ffffffffc0203d50:	7c42                	ld	s8,48(sp)
ffffffffc0203d52:	7ca2                	ld	s9,40(sp)
ffffffffc0203d54:	7d02                	ld	s10,32(sp)
ffffffffc0203d56:	6de2                	ld	s11,24(sp)
ffffffffc0203d58:	6109                	addi	sp,sp,128
ffffffffc0203d5a:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203d5c:	4705                	li	a4,1
ffffffffc0203d5e:	008a8593          	addi	a1,s5,8
ffffffffc0203d62:	01074463          	blt	a4,a6,ffffffffc0203d6a <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203d66:	26080363          	beqz	a6,ffffffffc0203fcc <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203d6a:	000ab603          	ld	a2,0(s5)
ffffffffc0203d6e:	46c1                	li	a3,16
ffffffffc0203d70:	8aae                	mv	s5,a1
ffffffffc0203d72:	a06d                	j	ffffffffc0203e1c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203d74:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203d78:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203d7a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203d7c:	b765                	j	ffffffffc0203d24 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203d7e:	000aa503          	lw	a0,0(s5)
ffffffffc0203d82:	85a6                	mv	a1,s1
ffffffffc0203d84:	0aa1                	addi	s5,s5,8
ffffffffc0203d86:	9902                	jalr	s2
            break;
ffffffffc0203d88:	bfb9                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203d8a:	4705                	li	a4,1
ffffffffc0203d8c:	008a8993          	addi	s3,s5,8
ffffffffc0203d90:	01074463          	blt	a4,a6,ffffffffc0203d98 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203d94:	22080463          	beqz	a6,ffffffffc0203fbc <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203d98:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203d9c:	24044463          	bltz	s0,ffffffffc0203fe4 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203da0:	8622                	mv	a2,s0
ffffffffc0203da2:	8ace                	mv	s5,s3
ffffffffc0203da4:	46a9                	li	a3,10
ffffffffc0203da6:	a89d                	j	ffffffffc0203e1c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203da8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203dac:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203dae:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203db0:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203db4:	8fb5                	xor	a5,a5,a3
ffffffffc0203db6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203dba:	1ad74363          	blt	a4,a3,ffffffffc0203f60 <vprintfmt+0x2b4>
ffffffffc0203dbe:	00369793          	slli	a5,a3,0x3
ffffffffc0203dc2:	97e2                	add	a5,a5,s8
ffffffffc0203dc4:	639c                	ld	a5,0(a5)
ffffffffc0203dc6:	18078d63          	beqz	a5,ffffffffc0203f60 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203dca:	86be                	mv	a3,a5
ffffffffc0203dcc:	00002617          	auipc	a2,0x2
ffffffffc0203dd0:	26c60613          	addi	a2,a2,620 # ffffffffc0206038 <error_string+0xe8>
ffffffffc0203dd4:	85a6                	mv	a1,s1
ffffffffc0203dd6:	854a                	mv	a0,s2
ffffffffc0203dd8:	240000ef          	jal	ra,ffffffffc0204018 <printfmt>
ffffffffc0203ddc:	b729                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203dde:	00144603          	lbu	a2,1(s0)
ffffffffc0203de2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203de4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203de6:	bf3d                	j	ffffffffc0203d24 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203de8:	4705                	li	a4,1
ffffffffc0203dea:	008a8593          	addi	a1,s5,8
ffffffffc0203dee:	01074463          	blt	a4,a6,ffffffffc0203df6 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203df2:	1e080263          	beqz	a6,ffffffffc0203fd6 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203df6:	000ab603          	ld	a2,0(s5)
ffffffffc0203dfa:	46a1                	li	a3,8
ffffffffc0203dfc:	8aae                	mv	s5,a1
ffffffffc0203dfe:	a839                	j	ffffffffc0203e1c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203e00:	03000513          	li	a0,48
ffffffffc0203e04:	85a6                	mv	a1,s1
ffffffffc0203e06:	e03e                	sd	a5,0(sp)
ffffffffc0203e08:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203e0a:	85a6                	mv	a1,s1
ffffffffc0203e0c:	07800513          	li	a0,120
ffffffffc0203e10:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203e12:	0aa1                	addi	s5,s5,8
ffffffffc0203e14:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203e18:	6782                	ld	a5,0(sp)
ffffffffc0203e1a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203e1c:	876e                	mv	a4,s11
ffffffffc0203e1e:	85a6                	mv	a1,s1
ffffffffc0203e20:	854a                	mv	a0,s2
ffffffffc0203e22:	e1fff0ef          	jal	ra,ffffffffc0203c40 <printnum>
            break;
ffffffffc0203e26:	b5c1                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203e28:	000ab603          	ld	a2,0(s5)
ffffffffc0203e2c:	0aa1                	addi	s5,s5,8
ffffffffc0203e2e:	1c060663          	beqz	a2,ffffffffc0203ffa <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203e32:	00160413          	addi	s0,a2,1
ffffffffc0203e36:	17b05c63          	blez	s11,ffffffffc0203fae <vprintfmt+0x302>
ffffffffc0203e3a:	02d00593          	li	a1,45
ffffffffc0203e3e:	14b79263          	bne	a5,a1,ffffffffc0203f82 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e42:	00064783          	lbu	a5,0(a2)
ffffffffc0203e46:	0007851b          	sext.w	a0,a5
ffffffffc0203e4a:	c905                	beqz	a0,ffffffffc0203e7a <vprintfmt+0x1ce>
ffffffffc0203e4c:	000cc563          	bltz	s9,ffffffffc0203e56 <vprintfmt+0x1aa>
ffffffffc0203e50:	3cfd                	addiw	s9,s9,-1
ffffffffc0203e52:	036c8263          	beq	s9,s6,ffffffffc0203e76 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203e56:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e58:	18098463          	beqz	s3,ffffffffc0203fe0 <vprintfmt+0x334>
ffffffffc0203e5c:	3781                	addiw	a5,a5,-32
ffffffffc0203e5e:	18fbf163          	bleu	a5,s7,ffffffffc0203fe0 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203e62:	03f00513          	li	a0,63
ffffffffc0203e66:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203e68:	0405                	addi	s0,s0,1
ffffffffc0203e6a:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203e6e:	3dfd                	addiw	s11,s11,-1
ffffffffc0203e70:	0007851b          	sext.w	a0,a5
ffffffffc0203e74:	fd61                	bnez	a0,ffffffffc0203e4c <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203e76:	e7b058e3          	blez	s11,ffffffffc0203ce6 <vprintfmt+0x3a>
ffffffffc0203e7a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203e7c:	85a6                	mv	a1,s1
ffffffffc0203e7e:	02000513          	li	a0,32
ffffffffc0203e82:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203e84:	e60d81e3          	beqz	s11,ffffffffc0203ce6 <vprintfmt+0x3a>
ffffffffc0203e88:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203e8a:	85a6                	mv	a1,s1
ffffffffc0203e8c:	02000513          	li	a0,32
ffffffffc0203e90:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203e92:	fe0d94e3          	bnez	s11,ffffffffc0203e7a <vprintfmt+0x1ce>
ffffffffc0203e96:	bd81                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203e98:	4705                	li	a4,1
ffffffffc0203e9a:	008a8593          	addi	a1,s5,8
ffffffffc0203e9e:	01074463          	blt	a4,a6,ffffffffc0203ea6 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0203ea2:	12080063          	beqz	a6,ffffffffc0203fc2 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0203ea6:	000ab603          	ld	a2,0(s5)
ffffffffc0203eaa:	46a9                	li	a3,10
ffffffffc0203eac:	8aae                	mv	s5,a1
ffffffffc0203eae:	b7bd                	j	ffffffffc0203e1c <vprintfmt+0x170>
ffffffffc0203eb0:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0203eb4:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eb8:	846a                	mv	s0,s10
ffffffffc0203eba:	b5ad                	j	ffffffffc0203d24 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0203ebc:	85a6                	mv	a1,s1
ffffffffc0203ebe:	02500513          	li	a0,37
ffffffffc0203ec2:	9902                	jalr	s2
            break;
ffffffffc0203ec4:	b50d                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0203ec6:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203eca:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203ece:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ed0:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203ed2:	e40dd9e3          	bgez	s11,ffffffffc0203d24 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203ed6:	8de6                	mv	s11,s9
ffffffffc0203ed8:	5cfd                	li	s9,-1
ffffffffc0203eda:	b5a9                	j	ffffffffc0203d24 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0203edc:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0203ee0:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ee4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ee6:	bd3d                	j	ffffffffc0203d24 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0203ee8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203eec:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ef0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203ef2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203ef6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203efa:	fcd56ce3          	bltu	a0,a3,ffffffffc0203ed2 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203efe:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203f00:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203f04:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203f08:	0196873b          	addw	a4,a3,s9
ffffffffc0203f0c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203f10:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203f14:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203f18:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203f1c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203f20:	fcd57fe3          	bleu	a3,a0,ffffffffc0203efe <vprintfmt+0x252>
ffffffffc0203f24:	b77d                	j	ffffffffc0203ed2 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0203f26:	fffdc693          	not	a3,s11
ffffffffc0203f2a:	96fd                	srai	a3,a3,0x3f
ffffffffc0203f2c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203f30:	00144603          	lbu	a2,1(s0)
ffffffffc0203f34:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f36:	846a                	mv	s0,s10
ffffffffc0203f38:	b3f5                	j	ffffffffc0203d24 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0203f3a:	85a6                	mv	a1,s1
ffffffffc0203f3c:	02500513          	li	a0,37
ffffffffc0203f40:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0203f42:	fff44703          	lbu	a4,-1(s0)
ffffffffc0203f46:	02500793          	li	a5,37
ffffffffc0203f4a:	8d22                	mv	s10,s0
ffffffffc0203f4c:	d8f70de3          	beq	a4,a5,ffffffffc0203ce6 <vprintfmt+0x3a>
ffffffffc0203f50:	02500713          	li	a4,37
ffffffffc0203f54:	1d7d                	addi	s10,s10,-1
ffffffffc0203f56:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0203f5a:	fee79de3          	bne	a5,a4,ffffffffc0203f54 <vprintfmt+0x2a8>
ffffffffc0203f5e:	b361                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203f60:	00002617          	auipc	a2,0x2
ffffffffc0203f64:	0c860613          	addi	a2,a2,200 # ffffffffc0206028 <error_string+0xd8>
ffffffffc0203f68:	85a6                	mv	a1,s1
ffffffffc0203f6a:	854a                	mv	a0,s2
ffffffffc0203f6c:	0ac000ef          	jal	ra,ffffffffc0204018 <printfmt>
ffffffffc0203f70:	bb9d                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0203f72:	00002617          	auipc	a2,0x2
ffffffffc0203f76:	0ae60613          	addi	a2,a2,174 # ffffffffc0206020 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0203f7a:	00002417          	auipc	s0,0x2
ffffffffc0203f7e:	0a740413          	addi	s0,s0,167 # ffffffffc0206021 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203f82:	8532                	mv	a0,a2
ffffffffc0203f84:	85e6                	mv	a1,s9
ffffffffc0203f86:	e032                	sd	a2,0(sp)
ffffffffc0203f88:	e43e                	sd	a5,8(sp)
ffffffffc0203f8a:	18a000ef          	jal	ra,ffffffffc0204114 <strnlen>
ffffffffc0203f8e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0203f92:	6602                	ld	a2,0(sp)
ffffffffc0203f94:	01b05d63          	blez	s11,ffffffffc0203fae <vprintfmt+0x302>
ffffffffc0203f98:	67a2                	ld	a5,8(sp)
ffffffffc0203f9a:	2781                	sext.w	a5,a5
ffffffffc0203f9c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0203f9e:	6522                	ld	a0,8(sp)
ffffffffc0203fa0:	85a6                	mv	a1,s1
ffffffffc0203fa2:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203fa4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0203fa6:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203fa8:	6602                	ld	a2,0(sp)
ffffffffc0203faa:	fe0d9ae3          	bnez	s11,ffffffffc0203f9e <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fae:	00064783          	lbu	a5,0(a2)
ffffffffc0203fb2:	0007851b          	sext.w	a0,a5
ffffffffc0203fb6:	e8051be3          	bnez	a0,ffffffffc0203e4c <vprintfmt+0x1a0>
ffffffffc0203fba:	b335                	j	ffffffffc0203ce6 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0203fbc:	000aa403          	lw	s0,0(s5)
ffffffffc0203fc0:	bbf1                	j	ffffffffc0203d9c <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0203fc2:	000ae603          	lwu	a2,0(s5)
ffffffffc0203fc6:	46a9                	li	a3,10
ffffffffc0203fc8:	8aae                	mv	s5,a1
ffffffffc0203fca:	bd89                	j	ffffffffc0203e1c <vprintfmt+0x170>
ffffffffc0203fcc:	000ae603          	lwu	a2,0(s5)
ffffffffc0203fd0:	46c1                	li	a3,16
ffffffffc0203fd2:	8aae                	mv	s5,a1
ffffffffc0203fd4:	b5a1                	j	ffffffffc0203e1c <vprintfmt+0x170>
ffffffffc0203fd6:	000ae603          	lwu	a2,0(s5)
ffffffffc0203fda:	46a1                	li	a3,8
ffffffffc0203fdc:	8aae                	mv	s5,a1
ffffffffc0203fde:	bd3d                	j	ffffffffc0203e1c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0203fe0:	9902                	jalr	s2
ffffffffc0203fe2:	b559                	j	ffffffffc0203e68 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0203fe4:	85a6                	mv	a1,s1
ffffffffc0203fe6:	02d00513          	li	a0,45
ffffffffc0203fea:	e03e                	sd	a5,0(sp)
ffffffffc0203fec:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0203fee:	8ace                	mv	s5,s3
ffffffffc0203ff0:	40800633          	neg	a2,s0
ffffffffc0203ff4:	46a9                	li	a3,10
ffffffffc0203ff6:	6782                	ld	a5,0(sp)
ffffffffc0203ff8:	b515                	j	ffffffffc0203e1c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0203ffa:	01b05663          	blez	s11,ffffffffc0204006 <vprintfmt+0x35a>
ffffffffc0203ffe:	02d00693          	li	a3,45
ffffffffc0204002:	f6d798e3          	bne	a5,a3,ffffffffc0203f72 <vprintfmt+0x2c6>
ffffffffc0204006:	00002417          	auipc	s0,0x2
ffffffffc020400a:	01b40413          	addi	s0,s0,27 # ffffffffc0206021 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020400e:	02800513          	li	a0,40
ffffffffc0204012:	02800793          	li	a5,40
ffffffffc0204016:	bd1d                	j	ffffffffc0203e4c <vprintfmt+0x1a0>

ffffffffc0204018 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204018:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020401a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020401e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204020:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204022:	ec06                	sd	ra,24(sp)
ffffffffc0204024:	f83a                	sd	a4,48(sp)
ffffffffc0204026:	fc3e                	sd	a5,56(sp)
ffffffffc0204028:	e0c2                	sd	a6,64(sp)
ffffffffc020402a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020402c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020402e:	c7fff0ef          	jal	ra,ffffffffc0203cac <vprintfmt>
}
ffffffffc0204032:	60e2                	ld	ra,24(sp)
ffffffffc0204034:	6161                	addi	sp,sp,80
ffffffffc0204036:	8082                	ret

ffffffffc0204038 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0204038:	715d                	addi	sp,sp,-80
ffffffffc020403a:	e486                	sd	ra,72(sp)
ffffffffc020403c:	e0a2                	sd	s0,64(sp)
ffffffffc020403e:	fc26                	sd	s1,56(sp)
ffffffffc0204040:	f84a                	sd	s2,48(sp)
ffffffffc0204042:	f44e                	sd	s3,40(sp)
ffffffffc0204044:	f052                	sd	s4,32(sp)
ffffffffc0204046:	ec56                	sd	s5,24(sp)
ffffffffc0204048:	e85a                	sd	s6,16(sp)
ffffffffc020404a:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc020404c:	c901                	beqz	a0,ffffffffc020405c <readline+0x24>
        cprintf("%s", prompt);
ffffffffc020404e:	85aa                	mv	a1,a0
ffffffffc0204050:	00002517          	auipc	a0,0x2
ffffffffc0204054:	fe850513          	addi	a0,a0,-24 # ffffffffc0206038 <error_string+0xe8>
ffffffffc0204058:	866fc0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc020405c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020405e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0204060:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0204062:	4aa9                	li	s5,10
ffffffffc0204064:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0204066:	0000db97          	auipc	s7,0xd
ffffffffc020406a:	fdab8b93          	addi	s7,s7,-38 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020406e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204072:	884fc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204076:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204078:	00054b63          	bltz	a0,ffffffffc020408e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020407c:	00a95b63          	ble	a0,s2,ffffffffc0204092 <readline+0x5a>
ffffffffc0204080:	029a5463          	ble	s1,s4,ffffffffc02040a8 <readline+0x70>
        c = getchar();
ffffffffc0204084:	872fc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204088:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020408a:	fe0559e3          	bgez	a0,ffffffffc020407c <readline+0x44>
            return NULL;
ffffffffc020408e:	4501                	li	a0,0
ffffffffc0204090:	a099                	j	ffffffffc02040d6 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204092:	03341463          	bne	s0,s3,ffffffffc02040ba <readline+0x82>
ffffffffc0204096:	e8b9                	bnez	s1,ffffffffc02040ec <readline+0xb4>
        c = getchar();
ffffffffc0204098:	85efc0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc020409c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020409e:	fe0548e3          	bltz	a0,ffffffffc020408e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02040a2:	fea958e3          	ble	a0,s2,ffffffffc0204092 <readline+0x5a>
ffffffffc02040a6:	4481                	li	s1,0
            cputchar(c);
ffffffffc02040a8:	8522                	mv	a0,s0
ffffffffc02040aa:	848fc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc02040ae:	009b87b3          	add	a5,s7,s1
ffffffffc02040b2:	00878023          	sb	s0,0(a5)
ffffffffc02040b6:	2485                	addiw	s1,s1,1
ffffffffc02040b8:	bf6d                	j	ffffffffc0204072 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02040ba:	01540463          	beq	s0,s5,ffffffffc02040c2 <readline+0x8a>
ffffffffc02040be:	fb641ae3          	bne	s0,s6,ffffffffc0204072 <readline+0x3a>
            cputchar(c);
ffffffffc02040c2:	8522                	mv	a0,s0
ffffffffc02040c4:	82efc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc02040c8:	0000d517          	auipc	a0,0xd
ffffffffc02040cc:	f7850513          	addi	a0,a0,-136 # ffffffffc0211040 <buf>
ffffffffc02040d0:	94aa                	add	s1,s1,a0
ffffffffc02040d2:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02040d6:	60a6                	ld	ra,72(sp)
ffffffffc02040d8:	6406                	ld	s0,64(sp)
ffffffffc02040da:	74e2                	ld	s1,56(sp)
ffffffffc02040dc:	7942                	ld	s2,48(sp)
ffffffffc02040de:	79a2                	ld	s3,40(sp)
ffffffffc02040e0:	7a02                	ld	s4,32(sp)
ffffffffc02040e2:	6ae2                	ld	s5,24(sp)
ffffffffc02040e4:	6b42                	ld	s6,16(sp)
ffffffffc02040e6:	6ba2                	ld	s7,8(sp)
ffffffffc02040e8:	6161                	addi	sp,sp,80
ffffffffc02040ea:	8082                	ret
            cputchar(c);
ffffffffc02040ec:	4521                	li	a0,8
ffffffffc02040ee:	804fc0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc02040f2:	34fd                	addiw	s1,s1,-1
ffffffffc02040f4:	bfbd                	j	ffffffffc0204072 <readline+0x3a>

ffffffffc02040f6 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02040f6:	00054783          	lbu	a5,0(a0)
ffffffffc02040fa:	cb91                	beqz	a5,ffffffffc020410e <strlen+0x18>
    size_t cnt = 0;
ffffffffc02040fc:	4781                	li	a5,0
        cnt ++;
ffffffffc02040fe:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204100:	00f50733          	add	a4,a0,a5
ffffffffc0204104:	00074703          	lbu	a4,0(a4)
ffffffffc0204108:	fb7d                	bnez	a4,ffffffffc02040fe <strlen+0x8>
    }
    return cnt;
}
ffffffffc020410a:	853e                	mv	a0,a5
ffffffffc020410c:	8082                	ret
    size_t cnt = 0;
ffffffffc020410e:	4781                	li	a5,0
}
ffffffffc0204110:	853e                	mv	a0,a5
ffffffffc0204112:	8082                	ret

ffffffffc0204114 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204114:	c185                	beqz	a1,ffffffffc0204134 <strnlen+0x20>
ffffffffc0204116:	00054783          	lbu	a5,0(a0)
ffffffffc020411a:	cf89                	beqz	a5,ffffffffc0204134 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc020411c:	4781                	li	a5,0
ffffffffc020411e:	a021                	j	ffffffffc0204126 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204120:	00074703          	lbu	a4,0(a4)
ffffffffc0204124:	c711                	beqz	a4,ffffffffc0204130 <strnlen+0x1c>
        cnt ++;
ffffffffc0204126:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204128:	00f50733          	add	a4,a0,a5
ffffffffc020412c:	fef59ae3          	bne	a1,a5,ffffffffc0204120 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204130:	853e                	mv	a0,a5
ffffffffc0204132:	8082                	ret
    size_t cnt = 0;
ffffffffc0204134:	4781                	li	a5,0
}
ffffffffc0204136:	853e                	mv	a0,a5
ffffffffc0204138:	8082                	ret

ffffffffc020413a <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020413a:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020413c:	0585                	addi	a1,a1,1
ffffffffc020413e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204142:	0785                	addi	a5,a5,1
ffffffffc0204144:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204148:	fb75                	bnez	a4,ffffffffc020413c <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020414a:	8082                	ret

ffffffffc020414c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020414c:	00054783          	lbu	a5,0(a0)
ffffffffc0204150:	0005c703          	lbu	a4,0(a1)
ffffffffc0204154:	cb91                	beqz	a5,ffffffffc0204168 <strcmp+0x1c>
ffffffffc0204156:	00e79c63          	bne	a5,a4,ffffffffc020416e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020415a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020415c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204160:	0585                	addi	a1,a1,1
ffffffffc0204162:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204166:	fbe5                	bnez	a5,ffffffffc0204156 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204168:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020416a:	9d19                	subw	a0,a0,a4
ffffffffc020416c:	8082                	ret
ffffffffc020416e:	0007851b          	sext.w	a0,a5
ffffffffc0204172:	9d19                	subw	a0,a0,a4
ffffffffc0204174:	8082                	ret

ffffffffc0204176 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204176:	00054783          	lbu	a5,0(a0)
ffffffffc020417a:	cb91                	beqz	a5,ffffffffc020418e <strchr+0x18>
        if (*s == c) {
ffffffffc020417c:	00b79563          	bne	a5,a1,ffffffffc0204186 <strchr+0x10>
ffffffffc0204180:	a809                	j	ffffffffc0204192 <strchr+0x1c>
ffffffffc0204182:	00b78763          	beq	a5,a1,ffffffffc0204190 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204186:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204188:	00054783          	lbu	a5,0(a0)
ffffffffc020418c:	fbfd                	bnez	a5,ffffffffc0204182 <strchr+0xc>
    }
    return NULL;
ffffffffc020418e:	4501                	li	a0,0
}
ffffffffc0204190:	8082                	ret
ffffffffc0204192:	8082                	ret

ffffffffc0204194 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204194:	ca01                	beqz	a2,ffffffffc02041a4 <memset+0x10>
ffffffffc0204196:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204198:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020419a:	0785                	addi	a5,a5,1
ffffffffc020419c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02041a0:	fec79de3          	bne	a5,a2,ffffffffc020419a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02041a4:	8082                	ret

ffffffffc02041a6 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02041a6:	ca19                	beqz	a2,ffffffffc02041bc <memcpy+0x16>
ffffffffc02041a8:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02041aa:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02041ac:	0585                	addi	a1,a1,1
ffffffffc02041ae:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02041b2:	0785                	addi	a5,a5,1
ffffffffc02041b4:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02041b8:	fec59ae3          	bne	a1,a2,ffffffffc02041ac <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02041bc:	8082                	ret
