
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
void grade_backtrace(void);

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	02a50513          	addi	a0,a0,42 # ffffffffc020a060 <edata>
ffffffffc020003e:	00015617          	auipc	a2,0x15
ffffffffc0200042:	5ba60613          	addi	a2,a2,1466 # ffffffffc02155f8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	4a3040ef          	jal	ra,ffffffffc0204cf0 <memset>

    cons_init();                // init the console
ffffffffc0200052:	4b4000ef          	jal	ra,ffffffffc0200506 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00005597          	auipc	a1,0x5
ffffffffc020005a:	cfa58593          	addi	a1,a1,-774 # ffffffffc0204d50 <etext+0x6>
ffffffffc020005e:	00005517          	auipc	a0,0x5
ffffffffc0200062:	d1250513          	addi	a0,a0,-750 # ffffffffc0204d70 <etext+0x26>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	16c000ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	779010ef          	jal	ra,ffffffffc0201fe6 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	548000ef          	jal	ra,ffffffffc02005ba <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5b8000ef          	jal	ra,ffffffffc020062e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	103030ef          	jal	ra,ffffffffc020397c <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	472040ef          	jal	ra,ffffffffc02044f0 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	4f8000ef          	jal	ra,ffffffffc020057a <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	283020ef          	jal	ra,ffffffffc0202b08 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	426000ef          	jal	ra,ffffffffc02004b0 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	520000ef          	jal	ra,ffffffffc02005ae <intr_enable>

    cpu_idle();                 // run idle process
ffffffffc0200092:	65e040ef          	jal	ra,ffffffffc02046f0 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00005517          	auipc	a0,0x5
ffffffffc02000b2:	cca50513          	addi	a0,a0,-822 # ffffffffc0204d78 <etext+0x2e>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	0000ab97          	auipc	s7,0xa
ffffffffc02000c8:	f9cb8b93          	addi	s7,s7,-100 # ffffffffc020a060 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	0f6000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	0e4000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	0d0000ef          	jal	ra,ffffffffc02001c6 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	0000a517          	auipc	a0,0xa
ffffffffc020012a:	f3a50513          	addi	a0,a0,-198 # ffffffffc020a060 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	3ac000ef          	jal	ra,ffffffffc0200508 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	744040ef          	jal	ra,ffffffffc02048c6 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	710040ef          	jal	ra,ffffffffc02048c6 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3460006f          	j	ffffffffc0200508 <cons_putc>

ffffffffc02001c6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02001c6:	1141                	addi	sp,sp,-16
ffffffffc02001c8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001ca:	374000ef          	jal	ra,ffffffffc020053e <cons_getc>
ffffffffc02001ce:	dd75                	beqz	a0,ffffffffc02001ca <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d0:	60a2                	ld	ra,8(sp)
ffffffffc02001d2:	0141                	addi	sp,sp,16
ffffffffc02001d4:	8082                	ret

ffffffffc02001d6 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc02001d6:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001d8:	00005517          	auipc	a0,0x5
ffffffffc02001dc:	bd850513          	addi	a0,a0,-1064 # ffffffffc0204db0 <etext+0x66>
void print_kerninfo(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e2:	fadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001e6:	00000597          	auipc	a1,0x0
ffffffffc02001ea:	e5058593          	addi	a1,a1,-432 # ffffffffc0200036 <kern_init>
ffffffffc02001ee:	00005517          	auipc	a0,0x5
ffffffffc02001f2:	be250513          	addi	a0,a0,-1054 # ffffffffc0204dd0 <etext+0x86>
ffffffffc02001f6:	f99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001fa:	00005597          	auipc	a1,0x5
ffffffffc02001fe:	b5058593          	addi	a1,a1,-1200 # ffffffffc0204d4a <etext>
ffffffffc0200202:	00005517          	auipc	a0,0x5
ffffffffc0200206:	bee50513          	addi	a0,a0,-1042 # ffffffffc0204df0 <etext+0xa6>
ffffffffc020020a:	f85ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020020e:	0000a597          	auipc	a1,0xa
ffffffffc0200212:	e5258593          	addi	a1,a1,-430 # ffffffffc020a060 <edata>
ffffffffc0200216:	00005517          	auipc	a0,0x5
ffffffffc020021a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0204e10 <etext+0xc6>
ffffffffc020021e:	f71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200222:	00015597          	auipc	a1,0x15
ffffffffc0200226:	3d658593          	addi	a1,a1,982 # ffffffffc02155f8 <end>
ffffffffc020022a:	00005517          	auipc	a0,0x5
ffffffffc020022e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0204e30 <etext+0xe6>
ffffffffc0200232:	f5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200236:	00015597          	auipc	a1,0x15
ffffffffc020023a:	7c158593          	addi	a1,a1,1985 # ffffffffc02159f7 <end+0x3ff>
ffffffffc020023e:	00000797          	auipc	a5,0x0
ffffffffc0200242:	df878793          	addi	a5,a5,-520 # ffffffffc0200036 <kern_init>
ffffffffc0200246:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200250:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200254:	95be                	add	a1,a1,a5
ffffffffc0200256:	85a9                	srai	a1,a1,0xa
ffffffffc0200258:	00005517          	auipc	a0,0x5
ffffffffc020025c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0204e50 <etext+0x106>
}
ffffffffc0200260:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200262:	f2dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200266 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200266:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200268:	00005617          	auipc	a2,0x5
ffffffffc020026c:	b1860613          	addi	a2,a2,-1256 # ffffffffc0204d80 <etext+0x36>
ffffffffc0200270:	04d00593          	li	a1,77
ffffffffc0200274:	00005517          	auipc	a0,0x5
ffffffffc0200278:	b2450513          	addi	a0,a0,-1244 # ffffffffc0204d98 <etext+0x4e>
void print_stackframe(void) {
ffffffffc020027c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027e:	1d2000ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200282 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200284:	00005617          	auipc	a2,0x5
ffffffffc0200288:	cdc60613          	addi	a2,a2,-804 # ffffffffc0204f60 <commands+0xe0>
ffffffffc020028c:	00005597          	auipc	a1,0x5
ffffffffc0200290:	cf458593          	addi	a1,a1,-780 # ffffffffc0204f80 <commands+0x100>
ffffffffc0200294:	00005517          	auipc	a0,0x5
ffffffffc0200298:	cf450513          	addi	a0,a0,-780 # ffffffffc0204f88 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020029c:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029e:	ef1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002a2:	00005617          	auipc	a2,0x5
ffffffffc02002a6:	cf660613          	addi	a2,a2,-778 # ffffffffc0204f98 <commands+0x118>
ffffffffc02002aa:	00005597          	auipc	a1,0x5
ffffffffc02002ae:	d1658593          	addi	a1,a1,-746 # ffffffffc0204fc0 <commands+0x140>
ffffffffc02002b2:	00005517          	auipc	a0,0x5
ffffffffc02002b6:	cd650513          	addi	a0,a0,-810 # ffffffffc0204f88 <commands+0x108>
ffffffffc02002ba:	ed5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002be:	00005617          	auipc	a2,0x5
ffffffffc02002c2:	d1260613          	addi	a2,a2,-750 # ffffffffc0204fd0 <commands+0x150>
ffffffffc02002c6:	00005597          	auipc	a1,0x5
ffffffffc02002ca:	d2a58593          	addi	a1,a1,-726 # ffffffffc0204ff0 <commands+0x170>
ffffffffc02002ce:	00005517          	auipc	a0,0x5
ffffffffc02002d2:	cba50513          	addi	a0,a0,-838 # ffffffffc0204f88 <commands+0x108>
ffffffffc02002d6:	eb9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc02002da:	60a2                	ld	ra,8(sp)
ffffffffc02002dc:	4501                	li	a0,0
ffffffffc02002de:	0141                	addi	sp,sp,16
ffffffffc02002e0:	8082                	ret

ffffffffc02002e2 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e2:	1141                	addi	sp,sp,-16
ffffffffc02002e4:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002e6:	ef1ff0ef          	jal	ra,ffffffffc02001d6 <print_kerninfo>
    return 0;
}
ffffffffc02002ea:	60a2                	ld	ra,8(sp)
ffffffffc02002ec:	4501                	li	a0,0
ffffffffc02002ee:	0141                	addi	sp,sp,16
ffffffffc02002f0:	8082                	ret

ffffffffc02002f2 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002f2:	1141                	addi	sp,sp,-16
ffffffffc02002f4:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002f6:	f71ff0ef          	jal	ra,ffffffffc0200266 <print_stackframe>
    return 0;
}
ffffffffc02002fa:	60a2                	ld	ra,8(sp)
ffffffffc02002fc:	4501                	li	a0,0
ffffffffc02002fe:	0141                	addi	sp,sp,16
ffffffffc0200300:	8082                	ret

ffffffffc0200302 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200302:	7115                	addi	sp,sp,-224
ffffffffc0200304:	e962                	sd	s8,144(sp)
ffffffffc0200306:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200308:	00005517          	auipc	a0,0x5
ffffffffc020030c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204ec8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200310:	ed86                	sd	ra,216(sp)
ffffffffc0200312:	e9a2                	sd	s0,208(sp)
ffffffffc0200314:	e5a6                	sd	s1,200(sp)
ffffffffc0200316:	e1ca                	sd	s2,192(sp)
ffffffffc0200318:	fd4e                	sd	s3,184(sp)
ffffffffc020031a:	f952                	sd	s4,176(sp)
ffffffffc020031c:	f556                	sd	s5,168(sp)
ffffffffc020031e:	f15a                	sd	s6,160(sp)
ffffffffc0200320:	ed5e                	sd	s7,152(sp)
ffffffffc0200322:	e566                	sd	s9,136(sp)
ffffffffc0200324:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200326:	e69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020032a:	00005517          	auipc	a0,0x5
ffffffffc020032e:	bc650513          	addi	a0,a0,-1082 # ffffffffc0204ef0 <commands+0x70>
ffffffffc0200332:	e5dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200336:	000c0563          	beqz	s8,ffffffffc0200340 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020033a:	8562                	mv	a0,s8
ffffffffc020033c:	4da000ef          	jal	ra,ffffffffc0200816 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200340:	4501                	li	a0,0
ffffffffc0200342:	4581                	li	a1,0
ffffffffc0200344:	4601                	li	a2,0
ffffffffc0200346:	48a1                	li	a7,8
ffffffffc0200348:	00000073          	ecall
ffffffffc020034c:	00005c97          	auipc	s9,0x5
ffffffffc0200350:	b34c8c93          	addi	s9,s9,-1228 # ffffffffc0204e80 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200354:	00005997          	auipc	s3,0x5
ffffffffc0200358:	bc498993          	addi	s3,s3,-1084 # ffffffffc0204f18 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035c:	00005917          	auipc	s2,0x5
ffffffffc0200360:	bc490913          	addi	s2,s2,-1084 # ffffffffc0204f20 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200364:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200366:	00005b17          	auipc	s6,0x5
ffffffffc020036a:	bc2b0b13          	addi	s6,s6,-1086 # ffffffffc0204f28 <commands+0xa8>
    if (argc == 0) {
ffffffffc020036e:	00005a97          	auipc	s5,0x5
ffffffffc0200372:	c12a8a93          	addi	s5,s5,-1006 # ffffffffc0204f80 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200376:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200378:	854e                	mv	a0,s3
ffffffffc020037a:	d1dff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc020037e:	842a                	mv	s0,a0
ffffffffc0200380:	dd65                	beqz	a0,ffffffffc0200378 <kmonitor+0x76>
ffffffffc0200382:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc0200386:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200388:	c999                	beqz	a1,ffffffffc020039e <kmonitor+0x9c>
ffffffffc020038a:	854a                	mv	a0,s2
ffffffffc020038c:	147040ef          	jal	ra,ffffffffc0204cd2 <strchr>
ffffffffc0200390:	c925                	beqz	a0,ffffffffc0200400 <kmonitor+0xfe>
            *buf ++ = '\0';
ffffffffc0200392:	00144583          	lbu	a1,1(s0)
ffffffffc0200396:	00040023          	sb	zero,0(s0)
ffffffffc020039a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020039c:	f5fd                	bnez	a1,ffffffffc020038a <kmonitor+0x88>
    if (argc == 0) {
ffffffffc020039e:	dce9                	beqz	s1,ffffffffc0200378 <kmonitor+0x76>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003a0:	6582                	ld	a1,0(sp)
ffffffffc02003a2:	00005d17          	auipc	s10,0x5
ffffffffc02003a6:	aded0d13          	addi	s10,s10,-1314 # ffffffffc0204e80 <commands>
    if (argc == 0) {
ffffffffc02003aa:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ac:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003ae:	0d61                	addi	s10,s10,24
ffffffffc02003b0:	0f9040ef          	jal	ra,ffffffffc0204ca8 <strcmp>
ffffffffc02003b4:	c919                	beqz	a0,ffffffffc02003ca <kmonitor+0xc8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003b6:	2405                	addiw	s0,s0,1
ffffffffc02003b8:	09740463          	beq	s0,s7,ffffffffc0200440 <kmonitor+0x13e>
ffffffffc02003bc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003c0:	6582                	ld	a1,0(sp)
ffffffffc02003c2:	0d61                	addi	s10,s10,24
ffffffffc02003c4:	0e5040ef          	jal	ra,ffffffffc0204ca8 <strcmp>
ffffffffc02003c8:	f57d                	bnez	a0,ffffffffc02003b6 <kmonitor+0xb4>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003ca:	00141793          	slli	a5,s0,0x1
ffffffffc02003ce:	97a2                	add	a5,a5,s0
ffffffffc02003d0:	078e                	slli	a5,a5,0x3
ffffffffc02003d2:	97e6                	add	a5,a5,s9
ffffffffc02003d4:	6b9c                	ld	a5,16(a5)
ffffffffc02003d6:	8662                	mv	a2,s8
ffffffffc02003d8:	002c                	addi	a1,sp,8
ffffffffc02003da:	fff4851b          	addiw	a0,s1,-1
ffffffffc02003de:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003e0:	f8055ce3          	bgez	a0,ffffffffc0200378 <kmonitor+0x76>
}
ffffffffc02003e4:	60ee                	ld	ra,216(sp)
ffffffffc02003e6:	644e                	ld	s0,208(sp)
ffffffffc02003e8:	64ae                	ld	s1,200(sp)
ffffffffc02003ea:	690e                	ld	s2,192(sp)
ffffffffc02003ec:	79ea                	ld	s3,184(sp)
ffffffffc02003ee:	7a4a                	ld	s4,176(sp)
ffffffffc02003f0:	7aaa                	ld	s5,168(sp)
ffffffffc02003f2:	7b0a                	ld	s6,160(sp)
ffffffffc02003f4:	6bea                	ld	s7,152(sp)
ffffffffc02003f6:	6c4a                	ld	s8,144(sp)
ffffffffc02003f8:	6caa                	ld	s9,136(sp)
ffffffffc02003fa:	6d0a                	ld	s10,128(sp)
ffffffffc02003fc:	612d                	addi	sp,sp,224
ffffffffc02003fe:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200400:	00044783          	lbu	a5,0(s0)
ffffffffc0200404:	dfc9                	beqz	a5,ffffffffc020039e <kmonitor+0x9c>
        if (argc == MAXARGS - 1) {
ffffffffc0200406:	03448863          	beq	s1,s4,ffffffffc0200436 <kmonitor+0x134>
        argv[argc ++] = buf;
ffffffffc020040a:	00349793          	slli	a5,s1,0x3
ffffffffc020040e:	0118                	addi	a4,sp,128
ffffffffc0200410:	97ba                	add	a5,a5,a4
ffffffffc0200412:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200416:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020041a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020041c:	e591                	bnez	a1,ffffffffc0200428 <kmonitor+0x126>
ffffffffc020041e:	b749                	j	ffffffffc02003a0 <kmonitor+0x9e>
            buf ++;
ffffffffc0200420:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200422:	00044583          	lbu	a1,0(s0)
ffffffffc0200426:	ddad                	beqz	a1,ffffffffc02003a0 <kmonitor+0x9e>
ffffffffc0200428:	854a                	mv	a0,s2
ffffffffc020042a:	0a9040ef          	jal	ra,ffffffffc0204cd2 <strchr>
ffffffffc020042e:	d96d                	beqz	a0,ffffffffc0200420 <kmonitor+0x11e>
ffffffffc0200430:	00044583          	lbu	a1,0(s0)
ffffffffc0200434:	bf91                	j	ffffffffc0200388 <kmonitor+0x86>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200436:	45c1                	li	a1,16
ffffffffc0200438:	855a                	mv	a0,s6
ffffffffc020043a:	d55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020043e:	b7f1                	j	ffffffffc020040a <kmonitor+0x108>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200440:	6582                	ld	a1,0(sp)
ffffffffc0200442:	00005517          	auipc	a0,0x5
ffffffffc0200446:	b0650513          	addi	a0,a0,-1274 # ffffffffc0204f48 <commands+0xc8>
ffffffffc020044a:	d45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020044e:	b72d                	j	ffffffffc0200378 <kmonitor+0x76>

ffffffffc0200450 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200450:	00015317          	auipc	t1,0x15
ffffffffc0200454:	02030313          	addi	t1,t1,32 # ffffffffc0215470 <is_panic>
ffffffffc0200458:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020045c:	715d                	addi	sp,sp,-80
ffffffffc020045e:	ec06                	sd	ra,24(sp)
ffffffffc0200460:	e822                	sd	s0,16(sp)
ffffffffc0200462:	f436                	sd	a3,40(sp)
ffffffffc0200464:	f83a                	sd	a4,48(sp)
ffffffffc0200466:	fc3e                	sd	a5,56(sp)
ffffffffc0200468:	e0c2                	sd	a6,64(sp)
ffffffffc020046a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020046c:	02031c63          	bnez	t1,ffffffffc02004a4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200470:	4785                	li	a5,1
ffffffffc0200472:	8432                	mv	s0,a2
ffffffffc0200474:	00015717          	auipc	a4,0x15
ffffffffc0200478:	fef72e23          	sw	a5,-4(a4) # ffffffffc0215470 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020047e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200480:	85aa                	mv	a1,a0
ffffffffc0200482:	00005517          	auipc	a0,0x5
ffffffffc0200486:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0205000 <commands+0x180>
    va_start(ap, fmt);
ffffffffc020048a:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020048c:	d03ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200490:	65a2                	ld	a1,8(sp)
ffffffffc0200492:	8522                	mv	a0,s0
ffffffffc0200494:	cdbff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc0200498:	00006517          	auipc	a0,0x6
ffffffffc020049c:	af050513          	addi	a0,a0,-1296 # ffffffffc0205f88 <default_pmm_manager+0x500>
ffffffffc02004a0:	cefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02004a4:	110000ef          	jal	ra,ffffffffc02005b4 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e59ff0ef          	jal	ra,ffffffffc0200302 <kmonitor>
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x58>

ffffffffc02004b0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004b0:	67e1                	lui	a5,0x18
ffffffffc02004b2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02004b6:	00015717          	auipc	a4,0x15
ffffffffc02004ba:	fcf73123          	sd	a5,-62(a4) # ffffffffc0215478 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004be:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02004c2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004c4:	953e                	add	a0,a0,a5
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	4881                	li	a7,0
ffffffffc02004ca:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02004ce:	02000793          	li	a5,32
ffffffffc02004d2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02004d6:	00005517          	auipc	a0,0x5
ffffffffc02004da:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0205020 <commands+0x1a0>
    ticks = 0;
ffffffffc02004de:	00015797          	auipc	a5,0x15
ffffffffc02004e2:	fe07b523          	sd	zero,-22(a5) # ffffffffc02154c8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc02004e6:	ca9ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02004ea <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02004ea:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004ee:	00015797          	auipc	a5,0x15
ffffffffc02004f2:	f8a78793          	addi	a5,a5,-118 # ffffffffc0215478 <timebase>
ffffffffc02004f6:	639c                	ld	a5,0(a5)
ffffffffc02004f8:	4581                	li	a1,0
ffffffffc02004fa:	4601                	li	a2,0
ffffffffc02004fc:	953e                	add	a0,a0,a5
ffffffffc02004fe:	4881                	li	a7,0
ffffffffc0200500:	00000073          	ecall
ffffffffc0200504:	8082                	ret

ffffffffc0200506 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200506:	8082                	ret

ffffffffc0200508 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200508:	100027f3          	csrr	a5,sstatus
ffffffffc020050c:	8b89                	andi	a5,a5,2
ffffffffc020050e:	0ff57513          	andi	a0,a0,255
ffffffffc0200512:	e799                	bnez	a5,ffffffffc0200520 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200514:	4581                	li	a1,0
ffffffffc0200516:	4601                	li	a2,0
ffffffffc0200518:	4885                	li	a7,1
ffffffffc020051a:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020051e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200520:	1101                	addi	sp,sp,-32
ffffffffc0200522:	ec06                	sd	ra,24(sp)
ffffffffc0200524:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200526:	08e000ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc020052a:	6522                	ld	a0,8(sp)
ffffffffc020052c:	4581                	li	a1,0
ffffffffc020052e:	4601                	li	a2,0
ffffffffc0200530:	4885                	li	a7,1
ffffffffc0200532:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200536:	60e2                	ld	ra,24(sp)
ffffffffc0200538:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020053a:	0740006f          	j	ffffffffc02005ae <intr_enable>

ffffffffc020053e <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020053e:	100027f3          	csrr	a5,sstatus
ffffffffc0200542:	8b89                	andi	a5,a5,2
ffffffffc0200544:	eb89                	bnez	a5,ffffffffc0200556 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200546:	4501                	li	a0,0
ffffffffc0200548:	4581                	li	a1,0
ffffffffc020054a:	4601                	li	a2,0
ffffffffc020054c:	4889                	li	a7,2
ffffffffc020054e:	00000073          	ecall
ffffffffc0200552:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200554:	8082                	ret
int cons_getc(void) {
ffffffffc0200556:	1101                	addi	sp,sp,-32
ffffffffc0200558:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020055a:	05a000ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc020055e:	4501                	li	a0,0
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4889                	li	a7,2
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	2501                	sext.w	a0,a0
ffffffffc020056c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020056e:	040000ef          	jal	ra,ffffffffc02005ae <intr_enable>
}
ffffffffc0200572:	60e2                	ld	ra,24(sp)
ffffffffc0200574:	6522                	ld	a0,8(sp)
ffffffffc0200576:	6105                	addi	sp,sp,32
ffffffffc0200578:	8082                	ret

ffffffffc020057a <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020057a:	8082                	ret

ffffffffc020057c <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020057c:	00253513          	sltiu	a0,a0,2
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200582:	03800513          	li	a0,56
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200588:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020058a:	0095979b          	slliw	a5,a1,0x9
ffffffffc020058e:	0000a517          	auipc	a0,0xa
ffffffffc0200592:	ed250513          	addi	a0,a0,-302 # ffffffffc020a460 <ide>
                   size_t nsecs) {
ffffffffc0200596:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200598:	00969613          	slli	a2,a3,0x9
ffffffffc020059c:	85ba                	mv	a1,a4
ffffffffc020059e:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02005a2:	760040ef          	jal	ra,ffffffffc0204d02 <memcpy>
    return 0;
}
ffffffffc02005a6:	60a2                	ld	ra,8(sp)
ffffffffc02005a8:	4501                	li	a0,0
ffffffffc02005aa:	0141                	addi	sp,sp,16
ffffffffc02005ac:	8082                	ret

ffffffffc02005ae <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005ae:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02005b2:	8082                	ret

ffffffffc02005b4 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02005b4:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02005b8:	8082                	ret

ffffffffc02005ba <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc02005ba:	8082                	ret

ffffffffc02005bc <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005bc:	10053783          	ld	a5,256(a0)
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005c0:	1141                	addi	sp,sp,-16
ffffffffc02005c2:	e022                	sd	s0,0(sp)
ffffffffc02005c4:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005c6:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc02005ca:	842a                	mv	s0,a0
    cprintf("page falut at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc02005cc:	11053583          	ld	a1,272(a0)
ffffffffc02005d0:	05500613          	li	a2,85
ffffffffc02005d4:	c399                	beqz	a5,ffffffffc02005da <pgfault_handler+0x1e>
ffffffffc02005d6:	04b00613          	li	a2,75
ffffffffc02005da:	11843703          	ld	a4,280(s0)
ffffffffc02005de:	47bd                	li	a5,15
ffffffffc02005e0:	05700693          	li	a3,87
ffffffffc02005e4:	00f70463          	beq	a4,a5,ffffffffc02005ec <pgfault_handler+0x30>
ffffffffc02005e8:	05200693          	li	a3,82
ffffffffc02005ec:	00005517          	auipc	a0,0x5
ffffffffc02005f0:	d2c50513          	addi	a0,a0,-724 # ffffffffc0205318 <commands+0x498>
ffffffffc02005f4:	b9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc02005f8:	00015797          	auipc	a5,0x15
ffffffffc02005fc:	fe878793          	addi	a5,a5,-24 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0200600:	6388                	ld	a0,0(a5)
ffffffffc0200602:	c911                	beqz	a0,ffffffffc0200616 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200604:	11043603          	ld	a2,272(s0)
ffffffffc0200608:	11842583          	lw	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc020060c:	6402                	ld	s0,0(sp)
ffffffffc020060e:	60a2                	ld	ra,8(sp)
ffffffffc0200610:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200612:	0b10306f          	j	ffffffffc0203ec2 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200616:	00005617          	auipc	a2,0x5
ffffffffc020061a:	d2260613          	addi	a2,a2,-734 # ffffffffc0205338 <commands+0x4b8>
ffffffffc020061e:	06200593          	li	a1,98
ffffffffc0200622:	00005517          	auipc	a0,0x5
ffffffffc0200626:	d2e50513          	addi	a0,a0,-722 # ffffffffc0205350 <commands+0x4d0>
ffffffffc020062a:	e27ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020062e <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020062e:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200632:	00000797          	auipc	a5,0x0
ffffffffc0200636:	48e78793          	addi	a5,a5,1166 # ffffffffc0200ac0 <__alltraps>
ffffffffc020063a:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020063e:	000407b7          	lui	a5,0x40
ffffffffc0200642:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200646:	8082                	ret

ffffffffc0200648 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200648:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
ffffffffc020064e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200650:	00005517          	auipc	a0,0x5
ffffffffc0200654:	d1850513          	addi	a0,a0,-744 # ffffffffc0205368 <commands+0x4e8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200658:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020065a:	b35ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020065e:	640c                	ld	a1,8(s0)
ffffffffc0200660:	00005517          	auipc	a0,0x5
ffffffffc0200664:	d2050513          	addi	a0,a0,-736 # ffffffffc0205380 <commands+0x500>
ffffffffc0200668:	b27ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020066c:	680c                	ld	a1,16(s0)
ffffffffc020066e:	00005517          	auipc	a0,0x5
ffffffffc0200672:	d2a50513          	addi	a0,a0,-726 # ffffffffc0205398 <commands+0x518>
ffffffffc0200676:	b19ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020067a:	6c0c                	ld	a1,24(s0)
ffffffffc020067c:	00005517          	auipc	a0,0x5
ffffffffc0200680:	d3450513          	addi	a0,a0,-716 # ffffffffc02053b0 <commands+0x530>
ffffffffc0200684:	b0bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200688:	700c                	ld	a1,32(s0)
ffffffffc020068a:	00005517          	auipc	a0,0x5
ffffffffc020068e:	d3e50513          	addi	a0,a0,-706 # ffffffffc02053c8 <commands+0x548>
ffffffffc0200692:	afdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200696:	740c                	ld	a1,40(s0)
ffffffffc0200698:	00005517          	auipc	a0,0x5
ffffffffc020069c:	d4850513          	addi	a0,a0,-696 # ffffffffc02053e0 <commands+0x560>
ffffffffc02006a0:	aefff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006a4:	780c                	ld	a1,48(s0)
ffffffffc02006a6:	00005517          	auipc	a0,0x5
ffffffffc02006aa:	d5250513          	addi	a0,a0,-686 # ffffffffc02053f8 <commands+0x578>
ffffffffc02006ae:	ae1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006b2:	7c0c                	ld	a1,56(s0)
ffffffffc02006b4:	00005517          	auipc	a0,0x5
ffffffffc02006b8:	d5c50513          	addi	a0,a0,-676 # ffffffffc0205410 <commands+0x590>
ffffffffc02006bc:	ad3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006c0:	602c                	ld	a1,64(s0)
ffffffffc02006c2:	00005517          	auipc	a0,0x5
ffffffffc02006c6:	d6650513          	addi	a0,a0,-666 # ffffffffc0205428 <commands+0x5a8>
ffffffffc02006ca:	ac5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006ce:	642c                	ld	a1,72(s0)
ffffffffc02006d0:	00005517          	auipc	a0,0x5
ffffffffc02006d4:	d7050513          	addi	a0,a0,-656 # ffffffffc0205440 <commands+0x5c0>
ffffffffc02006d8:	ab7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006dc:	682c                	ld	a1,80(s0)
ffffffffc02006de:	00005517          	auipc	a0,0x5
ffffffffc02006e2:	d7a50513          	addi	a0,a0,-646 # ffffffffc0205458 <commands+0x5d8>
ffffffffc02006e6:	aa9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006ea:	6c2c                	ld	a1,88(s0)
ffffffffc02006ec:	00005517          	auipc	a0,0x5
ffffffffc02006f0:	d8450513          	addi	a0,a0,-636 # ffffffffc0205470 <commands+0x5f0>
ffffffffc02006f4:	a9bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02006f8:	702c                	ld	a1,96(s0)
ffffffffc02006fa:	00005517          	auipc	a0,0x5
ffffffffc02006fe:	d8e50513          	addi	a0,a0,-626 # ffffffffc0205488 <commands+0x608>
ffffffffc0200702:	a8dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200706:	742c                	ld	a1,104(s0)
ffffffffc0200708:	00005517          	auipc	a0,0x5
ffffffffc020070c:	d9850513          	addi	a0,a0,-616 # ffffffffc02054a0 <commands+0x620>
ffffffffc0200710:	a7fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200714:	782c                	ld	a1,112(s0)
ffffffffc0200716:	00005517          	auipc	a0,0x5
ffffffffc020071a:	da250513          	addi	a0,a0,-606 # ffffffffc02054b8 <commands+0x638>
ffffffffc020071e:	a71ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200722:	7c2c                	ld	a1,120(s0)
ffffffffc0200724:	00005517          	auipc	a0,0x5
ffffffffc0200728:	dac50513          	addi	a0,a0,-596 # ffffffffc02054d0 <commands+0x650>
ffffffffc020072c:	a63ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200730:	604c                	ld	a1,128(s0)
ffffffffc0200732:	00005517          	auipc	a0,0x5
ffffffffc0200736:	db650513          	addi	a0,a0,-586 # ffffffffc02054e8 <commands+0x668>
ffffffffc020073a:	a55ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020073e:	644c                	ld	a1,136(s0)
ffffffffc0200740:	00005517          	auipc	a0,0x5
ffffffffc0200744:	dc050513          	addi	a0,a0,-576 # ffffffffc0205500 <commands+0x680>
ffffffffc0200748:	a47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020074c:	684c                	ld	a1,144(s0)
ffffffffc020074e:	00005517          	auipc	a0,0x5
ffffffffc0200752:	dca50513          	addi	a0,a0,-566 # ffffffffc0205518 <commands+0x698>
ffffffffc0200756:	a39ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020075a:	6c4c                	ld	a1,152(s0)
ffffffffc020075c:	00005517          	auipc	a0,0x5
ffffffffc0200760:	dd450513          	addi	a0,a0,-556 # ffffffffc0205530 <commands+0x6b0>
ffffffffc0200764:	a2bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200768:	704c                	ld	a1,160(s0)
ffffffffc020076a:	00005517          	auipc	a0,0x5
ffffffffc020076e:	dde50513          	addi	a0,a0,-546 # ffffffffc0205548 <commands+0x6c8>
ffffffffc0200772:	a1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200776:	744c                	ld	a1,168(s0)
ffffffffc0200778:	00005517          	auipc	a0,0x5
ffffffffc020077c:	de850513          	addi	a0,a0,-536 # ffffffffc0205560 <commands+0x6e0>
ffffffffc0200780:	a0fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200784:	784c                	ld	a1,176(s0)
ffffffffc0200786:	00005517          	auipc	a0,0x5
ffffffffc020078a:	df250513          	addi	a0,a0,-526 # ffffffffc0205578 <commands+0x6f8>
ffffffffc020078e:	a01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200792:	7c4c                	ld	a1,184(s0)
ffffffffc0200794:	00005517          	auipc	a0,0x5
ffffffffc0200798:	dfc50513          	addi	a0,a0,-516 # ffffffffc0205590 <commands+0x710>
ffffffffc020079c:	9f3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007a0:	606c                	ld	a1,192(s0)
ffffffffc02007a2:	00005517          	auipc	a0,0x5
ffffffffc02007a6:	e0650513          	addi	a0,a0,-506 # ffffffffc02055a8 <commands+0x728>
ffffffffc02007aa:	9e5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007ae:	646c                	ld	a1,200(s0)
ffffffffc02007b0:	00005517          	auipc	a0,0x5
ffffffffc02007b4:	e1050513          	addi	a0,a0,-496 # ffffffffc02055c0 <commands+0x740>
ffffffffc02007b8:	9d7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007bc:	686c                	ld	a1,208(s0)
ffffffffc02007be:	00005517          	auipc	a0,0x5
ffffffffc02007c2:	e1a50513          	addi	a0,a0,-486 # ffffffffc02055d8 <commands+0x758>
ffffffffc02007c6:	9c9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007ca:	6c6c                	ld	a1,216(s0)
ffffffffc02007cc:	00005517          	auipc	a0,0x5
ffffffffc02007d0:	e2450513          	addi	a0,a0,-476 # ffffffffc02055f0 <commands+0x770>
ffffffffc02007d4:	9bbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007d8:	706c                	ld	a1,224(s0)
ffffffffc02007da:	00005517          	auipc	a0,0x5
ffffffffc02007de:	e2e50513          	addi	a0,a0,-466 # ffffffffc0205608 <commands+0x788>
ffffffffc02007e2:	9adff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007e6:	746c                	ld	a1,232(s0)
ffffffffc02007e8:	00005517          	auipc	a0,0x5
ffffffffc02007ec:	e3850513          	addi	a0,a0,-456 # ffffffffc0205620 <commands+0x7a0>
ffffffffc02007f0:	99fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc02007f4:	786c                	ld	a1,240(s0)
ffffffffc02007f6:	00005517          	auipc	a0,0x5
ffffffffc02007fa:	e4250513          	addi	a0,a0,-446 # ffffffffc0205638 <commands+0x7b8>
ffffffffc02007fe:	991ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200802:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200804:	6402                	ld	s0,0(sp)
ffffffffc0200806:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200808:	00005517          	auipc	a0,0x5
ffffffffc020080c:	e4850513          	addi	a0,a0,-440 # ffffffffc0205650 <commands+0x7d0>
}
ffffffffc0200810:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200812:	97dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200816 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200816:	1141                	addi	sp,sp,-16
ffffffffc0200818:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020081a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020081c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020081e:	00005517          	auipc	a0,0x5
ffffffffc0200822:	e4a50513          	addi	a0,a0,-438 # ffffffffc0205668 <commands+0x7e8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200828:	967ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc020082c:	8522                	mv	a0,s0
ffffffffc020082e:	e1bff0ef          	jal	ra,ffffffffc0200648 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200832:	10043583          	ld	a1,256(s0)
ffffffffc0200836:	00005517          	auipc	a0,0x5
ffffffffc020083a:	e4a50513          	addi	a0,a0,-438 # ffffffffc0205680 <commands+0x800>
ffffffffc020083e:	951ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200842:	10843583          	ld	a1,264(s0)
ffffffffc0200846:	00005517          	auipc	a0,0x5
ffffffffc020084a:	e5250513          	addi	a0,a0,-430 # ffffffffc0205698 <commands+0x818>
ffffffffc020084e:	941ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200852:	11043583          	ld	a1,272(s0)
ffffffffc0200856:	00005517          	auipc	a0,0x5
ffffffffc020085a:	e5a50513          	addi	a0,a0,-422 # ffffffffc02056b0 <commands+0x830>
ffffffffc020085e:	931ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200862:	11843583          	ld	a1,280(s0)
}
ffffffffc0200866:	6402                	ld	s0,0(sp)
ffffffffc0200868:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020086a:	00005517          	auipc	a0,0x5
ffffffffc020086e:	e5e50513          	addi	a0,a0,-418 # ffffffffc02056c8 <commands+0x848>
}
ffffffffc0200872:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200874:	91bff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200878 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc0200878:	11853783          	ld	a5,280(a0)
ffffffffc020087c:	577d                	li	a4,-1
ffffffffc020087e:	8305                	srli	a4,a4,0x1
ffffffffc0200880:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc0200882:	472d                	li	a4,11
ffffffffc0200884:	06f76f63          	bltu	a4,a5,ffffffffc0200902 <interrupt_handler+0x8a>
ffffffffc0200888:	00004717          	auipc	a4,0x4
ffffffffc020088c:	7b470713          	addi	a4,a4,1972 # ffffffffc020503c <commands+0x1bc>
ffffffffc0200890:	078a                	slli	a5,a5,0x2
ffffffffc0200892:	97ba                	add	a5,a5,a4
ffffffffc0200894:	439c                	lw	a5,0(a5)
ffffffffc0200896:	97ba                	add	a5,a5,a4
ffffffffc0200898:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc020089a:	00005517          	auipc	a0,0x5
ffffffffc020089e:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02052c8 <commands+0x448>
ffffffffc02008a2:	8edff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02008a6:	00005517          	auipc	a0,0x5
ffffffffc02008aa:	a0250513          	addi	a0,a0,-1534 # ffffffffc02052a8 <commands+0x428>
ffffffffc02008ae:	8e1ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02008b2:	00005517          	auipc	a0,0x5
ffffffffc02008b6:	9b650513          	addi	a0,a0,-1610 # ffffffffc0205268 <commands+0x3e8>
ffffffffc02008ba:	8d5ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02008be:	00005517          	auipc	a0,0x5
ffffffffc02008c2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0205288 <commands+0x408>
ffffffffc02008c6:	8c9ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02008ca:	00005517          	auipc	a0,0x5
ffffffffc02008ce:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02052f8 <commands+0x478>
ffffffffc02008d2:	8bdff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02008d6:	1141                	addi	sp,sp,-16
ffffffffc02008d8:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc02008da:	c11ff0ef          	jal	ra,ffffffffc02004ea <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02008de:	00015797          	auipc	a5,0x15
ffffffffc02008e2:	bea78793          	addi	a5,a5,-1046 # ffffffffc02154c8 <ticks>
ffffffffc02008e6:	639c                	ld	a5,0(a5)
ffffffffc02008e8:	06400713          	li	a4,100
ffffffffc02008ec:	0785                	addi	a5,a5,1
ffffffffc02008ee:	02e7f733          	remu	a4,a5,a4
ffffffffc02008f2:	00015697          	auipc	a3,0x15
ffffffffc02008f6:	bcf6bb23          	sd	a5,-1066(a3) # ffffffffc02154c8 <ticks>
ffffffffc02008fa:	c711                	beqz	a4,ffffffffc0200906 <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008fc:	60a2                	ld	ra,8(sp)
ffffffffc02008fe:	0141                	addi	sp,sp,16
ffffffffc0200900:	8082                	ret
            print_trapframe(tf);
ffffffffc0200902:	f15ff06f          	j	ffffffffc0200816 <print_trapframe>
}
ffffffffc0200906:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200908:	06400593          	li	a1,100
ffffffffc020090c:	00005517          	auipc	a0,0x5
ffffffffc0200910:	9dc50513          	addi	a0,a0,-1572 # ffffffffc02052e8 <commands+0x468>
}
ffffffffc0200914:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200916:	879ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020091a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc020091a:	11853783          	ld	a5,280(a0)
ffffffffc020091e:	473d                	li	a4,15
ffffffffc0200920:	16f76563          	bltu	a4,a5,ffffffffc0200a8a <exception_handler+0x170>
ffffffffc0200924:	00004717          	auipc	a4,0x4
ffffffffc0200928:	74870713          	addi	a4,a4,1864 # ffffffffc020506c <commands+0x1ec>
ffffffffc020092c:	078a                	slli	a5,a5,0x2
ffffffffc020092e:	97ba                	add	a5,a5,a4
ffffffffc0200930:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200932:	1101                	addi	sp,sp,-32
ffffffffc0200934:	e822                	sd	s0,16(sp)
ffffffffc0200936:	ec06                	sd	ra,24(sp)
ffffffffc0200938:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc020093a:	97ba                	add	a5,a5,a4
ffffffffc020093c:	842a                	mv	s0,a0
ffffffffc020093e:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200940:	00005517          	auipc	a0,0x5
ffffffffc0200944:	91050513          	addi	a0,a0,-1776 # ffffffffc0205250 <commands+0x3d0>
ffffffffc0200948:	847ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020094c:	8522                	mv	a0,s0
ffffffffc020094e:	c6fff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc0200952:	84aa                	mv	s1,a0
ffffffffc0200954:	12051d63          	bnez	a0,ffffffffc0200a8e <exception_handler+0x174>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200958:	60e2                	ld	ra,24(sp)
ffffffffc020095a:	6442                	ld	s0,16(sp)
ffffffffc020095c:	64a2                	ld	s1,8(sp)
ffffffffc020095e:	6105                	addi	sp,sp,32
ffffffffc0200960:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	74e50513          	addi	a0,a0,1870 # ffffffffc02050b0 <commands+0x230>
}
ffffffffc020096a:	6442                	ld	s0,16(sp)
ffffffffc020096c:	60e2                	ld	ra,24(sp)
ffffffffc020096e:	64a2                	ld	s1,8(sp)
ffffffffc0200970:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200972:	81dff06f          	j	ffffffffc020018e <cprintf>
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	75a50513          	addi	a0,a0,1882 # ffffffffc02050d0 <commands+0x250>
ffffffffc020097e:	b7f5                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	77050513          	addi	a0,a0,1904 # ffffffffc02050f0 <commands+0x270>
ffffffffc0200988:	b7cd                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc020098a:	00004517          	auipc	a0,0x4
ffffffffc020098e:	77e50513          	addi	a0,a0,1918 # ffffffffc0205108 <commands+0x288>
ffffffffc0200992:	bfe1                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc0200994:	00004517          	auipc	a0,0x4
ffffffffc0200998:	78450513          	addi	a0,a0,1924 # ffffffffc0205118 <commands+0x298>
ffffffffc020099c:	b7f9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc020099e:	00004517          	auipc	a0,0x4
ffffffffc02009a2:	79a50513          	addi	a0,a0,1946 # ffffffffc0205138 <commands+0x2b8>
ffffffffc02009a6:	fe8ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009aa:	8522                	mv	a0,s0
ffffffffc02009ac:	c11ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc02009b0:	84aa                	mv	s1,a0
ffffffffc02009b2:	d15d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	e61ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ba:	86a6                	mv	a3,s1
ffffffffc02009bc:	00004617          	auipc	a2,0x4
ffffffffc02009c0:	79460613          	addi	a2,a2,1940 # ffffffffc0205150 <commands+0x2d0>
ffffffffc02009c4:	0b300593          	li	a1,179
ffffffffc02009c8:	00005517          	auipc	a0,0x5
ffffffffc02009cc:	98850513          	addi	a0,a0,-1656 # ffffffffc0205350 <commands+0x4d0>
ffffffffc02009d0:	a81ff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc02009d4:	00004517          	auipc	a0,0x4
ffffffffc02009d8:	79c50513          	addi	a0,a0,1948 # ffffffffc0205170 <commands+0x2f0>
ffffffffc02009dc:	b779                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc02009de:	00004517          	auipc	a0,0x4
ffffffffc02009e2:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205188 <commands+0x308>
ffffffffc02009e6:	fa8ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009ea:	8522                	mv	a0,s0
ffffffffc02009ec:	bd1ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc02009f0:	84aa                	mv	s1,a0
ffffffffc02009f2:	d13d                	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009f4:	8522                	mv	a0,s0
ffffffffc02009f6:	e21ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009fa:	86a6                	mv	a3,s1
ffffffffc02009fc:	00004617          	auipc	a2,0x4
ffffffffc0200a00:	75460613          	addi	a2,a2,1876 # ffffffffc0205150 <commands+0x2d0>
ffffffffc0200a04:	0bd00593          	li	a1,189
ffffffffc0200a08:	00005517          	auipc	a0,0x5
ffffffffc0200a0c:	94850513          	addi	a0,a0,-1720 # ffffffffc0205350 <commands+0x4d0>
ffffffffc0200a10:	a41ff0ef          	jal	ra,ffffffffc0200450 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200a14:	00004517          	auipc	a0,0x4
ffffffffc0200a18:	78c50513          	addi	a0,a0,1932 # ffffffffc02051a0 <commands+0x320>
ffffffffc0200a1c:	b7b9                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200a1e:	00004517          	auipc	a0,0x4
ffffffffc0200a22:	7a250513          	addi	a0,a0,1954 # ffffffffc02051c0 <commands+0x340>
ffffffffc0200a26:	b791                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a28:	00004517          	auipc	a0,0x4
ffffffffc0200a2c:	7b850513          	addi	a0,a0,1976 # ffffffffc02051e0 <commands+0x360>
ffffffffc0200a30:	bf2d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200a32:	00004517          	auipc	a0,0x4
ffffffffc0200a36:	7ce50513          	addi	a0,a0,1998 # ffffffffc0205200 <commands+0x380>
ffffffffc0200a3a:	bf05                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200a3c:	00004517          	auipc	a0,0x4
ffffffffc0200a40:	7e450513          	addi	a0,a0,2020 # ffffffffc0205220 <commands+0x3a0>
ffffffffc0200a44:	b71d                	j	ffffffffc020096a <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200a46:	00004517          	auipc	a0,0x4
ffffffffc0200a4a:	7f250513          	addi	a0,a0,2034 # ffffffffc0205238 <commands+0x3b8>
ffffffffc0200a4e:	f40ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200a52:	8522                	mv	a0,s0
ffffffffc0200a54:	b69ff0ef          	jal	ra,ffffffffc02005bc <pgfault_handler>
ffffffffc0200a58:	84aa                	mv	s1,a0
ffffffffc0200a5a:	ee050fe3          	beqz	a0,ffffffffc0200958 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200a5e:	8522                	mv	a0,s0
ffffffffc0200a60:	db7ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a64:	86a6                	mv	a3,s1
ffffffffc0200a66:	00004617          	auipc	a2,0x4
ffffffffc0200a6a:	6ea60613          	addi	a2,a2,1770 # ffffffffc0205150 <commands+0x2d0>
ffffffffc0200a6e:	0d300593          	li	a1,211
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	8de50513          	addi	a0,a0,-1826 # ffffffffc0205350 <commands+0x4d0>
ffffffffc0200a7a:	9d7ff0ef          	jal	ra,ffffffffc0200450 <__panic>
}
ffffffffc0200a7e:	6442                	ld	s0,16(sp)
ffffffffc0200a80:	60e2                	ld	ra,24(sp)
ffffffffc0200a82:	64a2                	ld	s1,8(sp)
ffffffffc0200a84:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a86:	d91ff06f          	j	ffffffffc0200816 <print_trapframe>
ffffffffc0200a8a:	d8dff06f          	j	ffffffffc0200816 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a8e:	8522                	mv	a0,s0
ffffffffc0200a90:	d87ff0ef          	jal	ra,ffffffffc0200816 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a94:	86a6                	mv	a3,s1
ffffffffc0200a96:	00004617          	auipc	a2,0x4
ffffffffc0200a9a:	6ba60613          	addi	a2,a2,1722 # ffffffffc0205150 <commands+0x2d0>
ffffffffc0200a9e:	0da00593          	li	a1,218
ffffffffc0200aa2:	00005517          	auipc	a0,0x5
ffffffffc0200aa6:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0205350 <commands+0x4d0>
ffffffffc0200aaa:	9a7ff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0200aae <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200aae:	11853783          	ld	a5,280(a0)
ffffffffc0200ab2:	0007c463          	bltz	a5,ffffffffc0200aba <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200ab6:	e65ff06f          	j	ffffffffc020091a <exception_handler>
        interrupt_handler(tf);
ffffffffc0200aba:	dbfff06f          	j	ffffffffc0200878 <interrupt_handler>
	...

ffffffffc0200ac0 <__alltraps>:
    LOAD  x2,2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ac0:	14011073          	csrw	sscratch,sp
ffffffffc0200ac4:	712d                	addi	sp,sp,-288
ffffffffc0200ac6:	e406                	sd	ra,8(sp)
ffffffffc0200ac8:	ec0e                	sd	gp,24(sp)
ffffffffc0200aca:	f012                	sd	tp,32(sp)
ffffffffc0200acc:	f416                	sd	t0,40(sp)
ffffffffc0200ace:	f81a                	sd	t1,48(sp)
ffffffffc0200ad0:	fc1e                	sd	t2,56(sp)
ffffffffc0200ad2:	e0a2                	sd	s0,64(sp)
ffffffffc0200ad4:	e4a6                	sd	s1,72(sp)
ffffffffc0200ad6:	e8aa                	sd	a0,80(sp)
ffffffffc0200ad8:	ecae                	sd	a1,88(sp)
ffffffffc0200ada:	f0b2                	sd	a2,96(sp)
ffffffffc0200adc:	f4b6                	sd	a3,104(sp)
ffffffffc0200ade:	f8ba                	sd	a4,112(sp)
ffffffffc0200ae0:	fcbe                	sd	a5,120(sp)
ffffffffc0200ae2:	e142                	sd	a6,128(sp)
ffffffffc0200ae4:	e546                	sd	a7,136(sp)
ffffffffc0200ae6:	e94a                	sd	s2,144(sp)
ffffffffc0200ae8:	ed4e                	sd	s3,152(sp)
ffffffffc0200aea:	f152                	sd	s4,160(sp)
ffffffffc0200aec:	f556                	sd	s5,168(sp)
ffffffffc0200aee:	f95a                	sd	s6,176(sp)
ffffffffc0200af0:	fd5e                	sd	s7,184(sp)
ffffffffc0200af2:	e1e2                	sd	s8,192(sp)
ffffffffc0200af4:	e5e6                	sd	s9,200(sp)
ffffffffc0200af6:	e9ea                	sd	s10,208(sp)
ffffffffc0200af8:	edee                	sd	s11,216(sp)
ffffffffc0200afa:	f1f2                	sd	t3,224(sp)
ffffffffc0200afc:	f5f6                	sd	t4,232(sp)
ffffffffc0200afe:	f9fa                	sd	t5,240(sp)
ffffffffc0200b00:	fdfe                	sd	t6,248(sp)
ffffffffc0200b02:	14002473          	csrr	s0,sscratch
ffffffffc0200b06:	100024f3          	csrr	s1,sstatus
ffffffffc0200b0a:	14102973          	csrr	s2,sepc
ffffffffc0200b0e:	143029f3          	csrr	s3,stval
ffffffffc0200b12:	14202a73          	csrr	s4,scause
ffffffffc0200b16:	e822                	sd	s0,16(sp)
ffffffffc0200b18:	e226                	sd	s1,256(sp)
ffffffffc0200b1a:	e64a                	sd	s2,264(sp)
ffffffffc0200b1c:	ea4e                	sd	s3,272(sp)
ffffffffc0200b1e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200b20:	850a                	mv	a0,sp
    jal trap
ffffffffc0200b22:	f8dff0ef          	jal	ra,ffffffffc0200aae <trap>

ffffffffc0200b26 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200b26:	6492                	ld	s1,256(sp)
ffffffffc0200b28:	6932                	ld	s2,264(sp)
ffffffffc0200b2a:	10049073          	csrw	sstatus,s1
ffffffffc0200b2e:	14191073          	csrw	sepc,s2
ffffffffc0200b32:	60a2                	ld	ra,8(sp)
ffffffffc0200b34:	61e2                	ld	gp,24(sp)
ffffffffc0200b36:	7202                	ld	tp,32(sp)
ffffffffc0200b38:	72a2                	ld	t0,40(sp)
ffffffffc0200b3a:	7342                	ld	t1,48(sp)
ffffffffc0200b3c:	73e2                	ld	t2,56(sp)
ffffffffc0200b3e:	6406                	ld	s0,64(sp)
ffffffffc0200b40:	64a6                	ld	s1,72(sp)
ffffffffc0200b42:	6546                	ld	a0,80(sp)
ffffffffc0200b44:	65e6                	ld	a1,88(sp)
ffffffffc0200b46:	7606                	ld	a2,96(sp)
ffffffffc0200b48:	76a6                	ld	a3,104(sp)
ffffffffc0200b4a:	7746                	ld	a4,112(sp)
ffffffffc0200b4c:	77e6                	ld	a5,120(sp)
ffffffffc0200b4e:	680a                	ld	a6,128(sp)
ffffffffc0200b50:	68aa                	ld	a7,136(sp)
ffffffffc0200b52:	694a                	ld	s2,144(sp)
ffffffffc0200b54:	69ea                	ld	s3,152(sp)
ffffffffc0200b56:	7a0a                	ld	s4,160(sp)
ffffffffc0200b58:	7aaa                	ld	s5,168(sp)
ffffffffc0200b5a:	7b4a                	ld	s6,176(sp)
ffffffffc0200b5c:	7bea                	ld	s7,184(sp)
ffffffffc0200b5e:	6c0e                	ld	s8,192(sp)
ffffffffc0200b60:	6cae                	ld	s9,200(sp)
ffffffffc0200b62:	6d4e                	ld	s10,208(sp)
ffffffffc0200b64:	6dee                	ld	s11,216(sp)
ffffffffc0200b66:	7e0e                	ld	t3,224(sp)
ffffffffc0200b68:	7eae                	ld	t4,232(sp)
ffffffffc0200b6a:	7f4e                	ld	t5,240(sp)
ffffffffc0200b6c:	7fee                	ld	t6,248(sp)
ffffffffc0200b6e:	6142                	ld	sp,16(sp)
    # go back from supervisor call
    # pc <- sepc
    sret
ffffffffc0200b70:	10200073          	sret

ffffffffc0200b74 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200b74:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200b76:	bf45                	j	ffffffffc0200b26 <__trapret>
	...

ffffffffc0200b7a <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b7a:	00015797          	auipc	a5,0x15
ffffffffc0200b7e:	95678793          	addi	a5,a5,-1706 # ffffffffc02154d0 <free_area>
ffffffffc0200b82:	e79c                	sd	a5,8(a5)
ffffffffc0200b84:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b86:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b8a:	8082                	ret

ffffffffc0200b8c <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b8c:	00015517          	auipc	a0,0x15
ffffffffc0200b90:	95456503          	lwu	a0,-1708(a0) # ffffffffc02154e0 <free_area+0x10>
ffffffffc0200b94:	8082                	ret

ffffffffc0200b96 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b96:	715d                	addi	sp,sp,-80
ffffffffc0200b98:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b9a:	00015917          	auipc	s2,0x15
ffffffffc0200b9e:	93690913          	addi	s2,s2,-1738 # ffffffffc02154d0 <free_area>
ffffffffc0200ba2:	00893783          	ld	a5,8(s2)
ffffffffc0200ba6:	e486                	sd	ra,72(sp)
ffffffffc0200ba8:	e0a2                	sd	s0,64(sp)
ffffffffc0200baa:	fc26                	sd	s1,56(sp)
ffffffffc0200bac:	f44e                	sd	s3,40(sp)
ffffffffc0200bae:	f052                	sd	s4,32(sp)
ffffffffc0200bb0:	ec56                	sd	s5,24(sp)
ffffffffc0200bb2:	e85a                	sd	s6,16(sp)
ffffffffc0200bb4:	e45e                	sd	s7,8(sp)
ffffffffc0200bb6:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bb8:	31278463          	beq	a5,s2,ffffffffc0200ec0 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200bbc:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200bc0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200bc2:	8b05                	andi	a4,a4,1
ffffffffc0200bc4:	30070263          	beqz	a4,ffffffffc0200ec8 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200bc8:	4401                	li	s0,0
ffffffffc0200bca:	4481                	li	s1,0
ffffffffc0200bcc:	a031                	j	ffffffffc0200bd8 <default_check+0x42>
ffffffffc0200bce:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200bd2:	8b09                	andi	a4,a4,2
ffffffffc0200bd4:	2e070a63          	beqz	a4,ffffffffc0200ec8 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200bd8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bdc:	679c                	ld	a5,8(a5)
ffffffffc0200bde:	2485                	addiw	s1,s1,1
ffffffffc0200be0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200be2:	ff2796e3          	bne	a5,s2,ffffffffc0200bce <default_check+0x38>
ffffffffc0200be6:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200be8:	058010ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0200bec:	73351e63          	bne	a0,s3,ffffffffc0201328 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bf0:	4505                	li	a0,1
ffffffffc0200bf2:	781000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200bf6:	8a2a                	mv	s4,a0
ffffffffc0200bf8:	46050863          	beqz	a0,ffffffffc0201068 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bfc:	4505                	li	a0,1
ffffffffc0200bfe:	775000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200c02:	89aa                	mv	s3,a0
ffffffffc0200c04:	74050263          	beqz	a0,ffffffffc0201348 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c08:	4505                	li	a0,1
ffffffffc0200c0a:	769000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200c0e:	8aaa                	mv	s5,a0
ffffffffc0200c10:	4c050c63          	beqz	a0,ffffffffc02010e8 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c14:	2d3a0a63          	beq	s4,s3,ffffffffc0200ee8 <default_check+0x352>
ffffffffc0200c18:	2caa0863          	beq	s4,a0,ffffffffc0200ee8 <default_check+0x352>
ffffffffc0200c1c:	2ca98663          	beq	s3,a0,ffffffffc0200ee8 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c20:	000a2783          	lw	a5,0(s4)
ffffffffc0200c24:	2e079263          	bnez	a5,ffffffffc0200f08 <default_check+0x372>
ffffffffc0200c28:	0009a783          	lw	a5,0(s3)
ffffffffc0200c2c:	2c079e63          	bnez	a5,ffffffffc0200f08 <default_check+0x372>
ffffffffc0200c30:	411c                	lw	a5,0(a0)
ffffffffc0200c32:	2c079b63          	bnez	a5,ffffffffc0200f08 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200c36:	00015797          	auipc	a5,0x15
ffffffffc0200c3a:	8ca78793          	addi	a5,a5,-1846 # ffffffffc0215500 <pages>
ffffffffc0200c3e:	639c                	ld	a5,0(a5)
ffffffffc0200c40:	00006717          	auipc	a4,0x6
ffffffffc0200c44:	1a870713          	addi	a4,a4,424 # ffffffffc0206de8 <nbase>
ffffffffc0200c48:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c4a:	00015717          	auipc	a4,0x15
ffffffffc0200c4e:	84670713          	addi	a4,a4,-1978 # ffffffffc0215490 <npage>
ffffffffc0200c52:	6314                	ld	a3,0(a4)
ffffffffc0200c54:	40fa0733          	sub	a4,s4,a5
ffffffffc0200c58:	8719                	srai	a4,a4,0x6
ffffffffc0200c5a:	9732                	add	a4,a4,a2
ffffffffc0200c5c:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c5e:	0732                	slli	a4,a4,0xc
ffffffffc0200c60:	2cd77463          	bleu	a3,a4,ffffffffc0200f28 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200c64:	40f98733          	sub	a4,s3,a5
ffffffffc0200c68:	8719                	srai	a4,a4,0x6
ffffffffc0200c6a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c6c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c6e:	4ed77d63          	bleu	a3,a4,ffffffffc0201168 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200c72:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c76:	8799                	srai	a5,a5,0x6
ffffffffc0200c78:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c7a:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c7c:	34d7f663          	bleu	a3,a5,ffffffffc0200fc8 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200c80:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c82:	00093c03          	ld	s8,0(s2)
ffffffffc0200c86:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c8a:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c8e:	00015797          	auipc	a5,0x15
ffffffffc0200c92:	8527b523          	sd	s2,-1974(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0200c96:	00015797          	auipc	a5,0x15
ffffffffc0200c9a:	8327bd23          	sd	s2,-1990(a5) # ffffffffc02154d0 <free_area>
    nr_free = 0;
ffffffffc0200c9e:	00015797          	auipc	a5,0x15
ffffffffc0200ca2:	8407a123          	sw	zero,-1982(a5) # ffffffffc02154e0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200ca6:	6cd000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200caa:	2e051f63          	bnez	a0,ffffffffc0200fa8 <default_check+0x412>
    free_page(p0);
ffffffffc0200cae:	4585                	li	a1,1
ffffffffc0200cb0:	8552                	mv	a0,s4
ffffffffc0200cb2:	749000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p1);
ffffffffc0200cb6:	4585                	li	a1,1
ffffffffc0200cb8:	854e                	mv	a0,s3
ffffffffc0200cba:	741000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p2);
ffffffffc0200cbe:	4585                	li	a1,1
ffffffffc0200cc0:	8556                	mv	a0,s5
ffffffffc0200cc2:	739000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert(nr_free == 3);
ffffffffc0200cc6:	01092703          	lw	a4,16(s2)
ffffffffc0200cca:	478d                	li	a5,3
ffffffffc0200ccc:	2af71e63          	bne	a4,a5,ffffffffc0200f88 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200cd0:	4505                	li	a0,1
ffffffffc0200cd2:	6a1000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200cd6:	89aa                	mv	s3,a0
ffffffffc0200cd8:	28050863          	beqz	a0,ffffffffc0200f68 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cdc:	4505                	li	a0,1
ffffffffc0200cde:	695000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200ce2:	8aaa                	mv	s5,a0
ffffffffc0200ce4:	3e050263          	beqz	a0,ffffffffc02010c8 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ce8:	4505                	li	a0,1
ffffffffc0200cea:	689000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200cee:	8a2a                	mv	s4,a0
ffffffffc0200cf0:	3a050c63          	beqz	a0,ffffffffc02010a8 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200cf4:	4505                	li	a0,1
ffffffffc0200cf6:	67d000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200cfa:	38051763          	bnez	a0,ffffffffc0201088 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200cfe:	4585                	li	a1,1
ffffffffc0200d00:	854e                	mv	a0,s3
ffffffffc0200d02:	6f9000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200d06:	00893783          	ld	a5,8(s2)
ffffffffc0200d0a:	23278f63          	beq	a5,s2,ffffffffc0200f48 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200d0e:	4505                	li	a0,1
ffffffffc0200d10:	663000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d14:	32a99a63          	bne	s3,a0,ffffffffc0201048 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200d18:	4505                	li	a0,1
ffffffffc0200d1a:	659000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d1e:	30051563          	bnez	a0,ffffffffc0201028 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200d22:	01092783          	lw	a5,16(s2)
ffffffffc0200d26:	2e079163          	bnez	a5,ffffffffc0201008 <default_check+0x472>
    free_page(p);
ffffffffc0200d2a:	854e                	mv	a0,s3
ffffffffc0200d2c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200d2e:	00014797          	auipc	a5,0x14
ffffffffc0200d32:	7b87b123          	sd	s8,1954(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200d36:	00014797          	auipc	a5,0x14
ffffffffc0200d3a:	7b77b123          	sd	s7,1954(a5) # ffffffffc02154d8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200d3e:	00014797          	auipc	a5,0x14
ffffffffc0200d42:	7b67a123          	sw	s6,1954(a5) # ffffffffc02154e0 <free_area+0x10>
    free_page(p);
ffffffffc0200d46:	6b5000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p1);
ffffffffc0200d4a:	4585                	li	a1,1
ffffffffc0200d4c:	8556                	mv	a0,s5
ffffffffc0200d4e:	6ad000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p2);
ffffffffc0200d52:	4585                	li	a1,1
ffffffffc0200d54:	8552                	mv	a0,s4
ffffffffc0200d56:	6a5000ef          	jal	ra,ffffffffc0201bfa <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d5a:	4515                	li	a0,5
ffffffffc0200d5c:	617000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d60:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d62:	28050363          	beqz	a0,ffffffffc0200fe8 <default_check+0x452>
ffffffffc0200d66:	651c                	ld	a5,8(a0)
ffffffffc0200d68:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d6a:	8b85                	andi	a5,a5,1
ffffffffc0200d6c:	54079e63          	bnez	a5,ffffffffc02012c8 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d70:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d72:	00093b03          	ld	s6,0(s2)
ffffffffc0200d76:	00893a83          	ld	s5,8(s2)
ffffffffc0200d7a:	00014797          	auipc	a5,0x14
ffffffffc0200d7e:	7527bb23          	sd	s2,1878(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200d82:	00014797          	auipc	a5,0x14
ffffffffc0200d86:	7527bb23          	sd	s2,1878(a5) # ffffffffc02154d8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d8a:	5e9000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200d8e:	50051d63          	bnez	a0,ffffffffc02012a8 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d92:	08098a13          	addi	s4,s3,128
ffffffffc0200d96:	8552                	mv	a0,s4
ffffffffc0200d98:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d9a:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d9e:	00014797          	auipc	a5,0x14
ffffffffc0200da2:	7407a123          	sw	zero,1858(a5) # ffffffffc02154e0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200da6:	655000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200daa:	4511                	li	a0,4
ffffffffc0200dac:	5c7000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200db0:	4c051c63          	bnez	a0,ffffffffc0201288 <default_check+0x6f2>
ffffffffc0200db4:	0889b783          	ld	a5,136(s3)
ffffffffc0200db8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200dba:	8b85                	andi	a5,a5,1
ffffffffc0200dbc:	4a078663          	beqz	a5,ffffffffc0201268 <default_check+0x6d2>
ffffffffc0200dc0:	0909a703          	lw	a4,144(s3)
ffffffffc0200dc4:	478d                	li	a5,3
ffffffffc0200dc6:	4af71163          	bne	a4,a5,ffffffffc0201268 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200dca:	450d                	li	a0,3
ffffffffc0200dcc:	5a7000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200dd0:	8c2a                	mv	s8,a0
ffffffffc0200dd2:	46050b63          	beqz	a0,ffffffffc0201248 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0200dd6:	4505                	li	a0,1
ffffffffc0200dd8:	59b000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200ddc:	44051663          	bnez	a0,ffffffffc0201228 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0200de0:	438a1463          	bne	s4,s8,ffffffffc0201208 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200de4:	4585                	li	a1,1
ffffffffc0200de6:	854e                	mv	a0,s3
ffffffffc0200de8:	613000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_pages(p1, 3);
ffffffffc0200dec:	458d                	li	a1,3
ffffffffc0200dee:	8552                	mv	a0,s4
ffffffffc0200df0:	60b000ef          	jal	ra,ffffffffc0201bfa <free_pages>
ffffffffc0200df4:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200df8:	04098c13          	addi	s8,s3,64
ffffffffc0200dfc:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200dfe:	8b85                	andi	a5,a5,1
ffffffffc0200e00:	3e078463          	beqz	a5,ffffffffc02011e8 <default_check+0x652>
ffffffffc0200e04:	0109a703          	lw	a4,16(s3)
ffffffffc0200e08:	4785                	li	a5,1
ffffffffc0200e0a:	3cf71f63          	bne	a4,a5,ffffffffc02011e8 <default_check+0x652>
ffffffffc0200e0e:	008a3783          	ld	a5,8(s4)
ffffffffc0200e12:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200e14:	8b85                	andi	a5,a5,1
ffffffffc0200e16:	3a078963          	beqz	a5,ffffffffc02011c8 <default_check+0x632>
ffffffffc0200e1a:	010a2703          	lw	a4,16(s4)
ffffffffc0200e1e:	478d                	li	a5,3
ffffffffc0200e20:	3af71463          	bne	a4,a5,ffffffffc02011c8 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200e24:	4505                	li	a0,1
ffffffffc0200e26:	54d000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e2a:	36a99f63          	bne	s3,a0,ffffffffc02011a8 <default_check+0x612>
    free_page(p0);
ffffffffc0200e2e:	4585                	li	a1,1
ffffffffc0200e30:	5cb000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200e34:	4509                	li	a0,2
ffffffffc0200e36:	53d000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e3a:	34aa1763          	bne	s4,a0,ffffffffc0201188 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0200e3e:	4589                	li	a1,2
ffffffffc0200e40:	5bb000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    free_page(p2);
ffffffffc0200e44:	4585                	li	a1,1
ffffffffc0200e46:	8562                	mv	a0,s8
ffffffffc0200e48:	5b3000ef          	jal	ra,ffffffffc0201bfa <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e4c:	4515                	li	a0,5
ffffffffc0200e4e:	525000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e52:	89aa                	mv	s3,a0
ffffffffc0200e54:	48050a63          	beqz	a0,ffffffffc02012e8 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0200e58:	4505                	li	a0,1
ffffffffc0200e5a:	519000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0200e5e:	2e051563          	bnez	a0,ffffffffc0201148 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0200e62:	01092783          	lw	a5,16(s2)
ffffffffc0200e66:	2c079163          	bnez	a5,ffffffffc0201128 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e6a:	4595                	li	a1,5
ffffffffc0200e6c:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e6e:	00014797          	auipc	a5,0x14
ffffffffc0200e72:	6777a923          	sw	s7,1650(a5) # ffffffffc02154e0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e76:	00014797          	auipc	a5,0x14
ffffffffc0200e7a:	6567bd23          	sd	s6,1626(a5) # ffffffffc02154d0 <free_area>
ffffffffc0200e7e:	00014797          	auipc	a5,0x14
ffffffffc0200e82:	6557bd23          	sd	s5,1626(a5) # ffffffffc02154d8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e86:	575000ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return listelm->next;
ffffffffc0200e8a:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e8e:	01278963          	beq	a5,s2,ffffffffc0200ea0 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e92:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e96:	679c                	ld	a5,8(a5)
ffffffffc0200e98:	34fd                	addiw	s1,s1,-1
ffffffffc0200e9a:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9c:	ff279be3          	bne	a5,s2,ffffffffc0200e92 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0200ea0:	26049463          	bnez	s1,ffffffffc0201108 <default_check+0x572>
    assert(total == 0);
ffffffffc0200ea4:	46041263          	bnez	s0,ffffffffc0201308 <default_check+0x772>
}
ffffffffc0200ea8:	60a6                	ld	ra,72(sp)
ffffffffc0200eaa:	6406                	ld	s0,64(sp)
ffffffffc0200eac:	74e2                	ld	s1,56(sp)
ffffffffc0200eae:	7942                	ld	s2,48(sp)
ffffffffc0200eb0:	79a2                	ld	s3,40(sp)
ffffffffc0200eb2:	7a02                	ld	s4,32(sp)
ffffffffc0200eb4:	6ae2                	ld	s5,24(sp)
ffffffffc0200eb6:	6b42                	ld	s6,16(sp)
ffffffffc0200eb8:	6ba2                	ld	s7,8(sp)
ffffffffc0200eba:	6c02                	ld	s8,0(sp)
ffffffffc0200ebc:	6161                	addi	sp,sp,80
ffffffffc0200ebe:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ec0:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ec2:	4401                	li	s0,0
ffffffffc0200ec4:	4481                	li	s1,0
ffffffffc0200ec6:	b30d                	j	ffffffffc0200be8 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200ec8:	00005697          	auipc	a3,0x5
ffffffffc0200ecc:	81868693          	addi	a3,a3,-2024 # ffffffffc02056e0 <commands+0x860>
ffffffffc0200ed0:	00005617          	auipc	a2,0x5
ffffffffc0200ed4:	82060613          	addi	a2,a2,-2016 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200ed8:	0f000593          	li	a1,240
ffffffffc0200edc:	00005517          	auipc	a0,0x5
ffffffffc0200ee0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0205708 <commands+0x888>
ffffffffc0200ee4:	d6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ee8:	00005697          	auipc	a3,0x5
ffffffffc0200eec:	8b868693          	addi	a3,a3,-1864 # ffffffffc02057a0 <commands+0x920>
ffffffffc0200ef0:	00005617          	auipc	a2,0x5
ffffffffc0200ef4:	80060613          	addi	a2,a2,-2048 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200ef8:	0bd00593          	li	a1,189
ffffffffc0200efc:	00005517          	auipc	a0,0x5
ffffffffc0200f00:	80c50513          	addi	a0,a0,-2036 # ffffffffc0205708 <commands+0x888>
ffffffffc0200f04:	d4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f08:	00005697          	auipc	a3,0x5
ffffffffc0200f0c:	8c068693          	addi	a3,a3,-1856 # ffffffffc02057c8 <commands+0x948>
ffffffffc0200f10:	00004617          	auipc	a2,0x4
ffffffffc0200f14:	7e060613          	addi	a2,a2,2016 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200f18:	0be00593          	li	a1,190
ffffffffc0200f1c:	00004517          	auipc	a0,0x4
ffffffffc0200f20:	7ec50513          	addi	a0,a0,2028 # ffffffffc0205708 <commands+0x888>
ffffffffc0200f24:	d2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f28:	00005697          	auipc	a3,0x5
ffffffffc0200f2c:	8e068693          	addi	a3,a3,-1824 # ffffffffc0205808 <commands+0x988>
ffffffffc0200f30:	00004617          	auipc	a2,0x4
ffffffffc0200f34:	7c060613          	addi	a2,a2,1984 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200f38:	0c000593          	li	a1,192
ffffffffc0200f3c:	00004517          	auipc	a0,0x4
ffffffffc0200f40:	7cc50513          	addi	a0,a0,1996 # ffffffffc0205708 <commands+0x888>
ffffffffc0200f44:	d0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200f48:	00005697          	auipc	a3,0x5
ffffffffc0200f4c:	94868693          	addi	a3,a3,-1720 # ffffffffc0205890 <commands+0xa10>
ffffffffc0200f50:	00004617          	auipc	a2,0x4
ffffffffc0200f54:	7a060613          	addi	a2,a2,1952 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200f58:	0d900593          	li	a1,217
ffffffffc0200f5c:	00004517          	auipc	a0,0x4
ffffffffc0200f60:	7ac50513          	addi	a0,a0,1964 # ffffffffc0205708 <commands+0x888>
ffffffffc0200f64:	cecff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f68:	00004697          	auipc	a3,0x4
ffffffffc0200f6c:	7d868693          	addi	a3,a3,2008 # ffffffffc0205740 <commands+0x8c0>
ffffffffc0200f70:	00004617          	auipc	a2,0x4
ffffffffc0200f74:	78060613          	addi	a2,a2,1920 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200f78:	0d200593          	li	a1,210
ffffffffc0200f7c:	00004517          	auipc	a0,0x4
ffffffffc0200f80:	78c50513          	addi	a0,a0,1932 # ffffffffc0205708 <commands+0x888>
ffffffffc0200f84:	cccff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 3);
ffffffffc0200f88:	00005697          	auipc	a3,0x5
ffffffffc0200f8c:	8f868693          	addi	a3,a3,-1800 # ffffffffc0205880 <commands+0xa00>
ffffffffc0200f90:	00004617          	auipc	a2,0x4
ffffffffc0200f94:	76060613          	addi	a2,a2,1888 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200f98:	0d000593          	li	a1,208
ffffffffc0200f9c:	00004517          	auipc	a0,0x4
ffffffffc0200fa0:	76c50513          	addi	a0,a0,1900 # ffffffffc0205708 <commands+0x888>
ffffffffc0200fa4:	cacff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa8:	00005697          	auipc	a3,0x5
ffffffffc0200fac:	8c068693          	addi	a3,a3,-1856 # ffffffffc0205868 <commands+0x9e8>
ffffffffc0200fb0:	00004617          	auipc	a2,0x4
ffffffffc0200fb4:	74060613          	addi	a2,a2,1856 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200fb8:	0cb00593          	li	a1,203
ffffffffc0200fbc:	00004517          	auipc	a0,0x4
ffffffffc0200fc0:	74c50513          	addi	a0,a0,1868 # ffffffffc0205708 <commands+0x888>
ffffffffc0200fc4:	c8cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fc8:	00005697          	auipc	a3,0x5
ffffffffc0200fcc:	88068693          	addi	a3,a3,-1920 # ffffffffc0205848 <commands+0x9c8>
ffffffffc0200fd0:	00004617          	auipc	a2,0x4
ffffffffc0200fd4:	72060613          	addi	a2,a2,1824 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200fd8:	0c200593          	li	a1,194
ffffffffc0200fdc:	00004517          	auipc	a0,0x4
ffffffffc0200fe0:	72c50513          	addi	a0,a0,1836 # ffffffffc0205708 <commands+0x888>
ffffffffc0200fe4:	c6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 != NULL);
ffffffffc0200fe8:	00005697          	auipc	a3,0x5
ffffffffc0200fec:	8f068693          	addi	a3,a3,-1808 # ffffffffc02058d8 <commands+0xa58>
ffffffffc0200ff0:	00004617          	auipc	a2,0x4
ffffffffc0200ff4:	70060613          	addi	a2,a2,1792 # ffffffffc02056f0 <commands+0x870>
ffffffffc0200ff8:	0f800593          	li	a1,248
ffffffffc0200ffc:	00004517          	auipc	a0,0x4
ffffffffc0201000:	70c50513          	addi	a0,a0,1804 # ffffffffc0205708 <commands+0x888>
ffffffffc0201004:	c4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201008:	00005697          	auipc	a3,0x5
ffffffffc020100c:	8c068693          	addi	a3,a3,-1856 # ffffffffc02058c8 <commands+0xa48>
ffffffffc0201010:	00004617          	auipc	a2,0x4
ffffffffc0201014:	6e060613          	addi	a2,a2,1760 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201018:	0df00593          	li	a1,223
ffffffffc020101c:	00004517          	auipc	a0,0x4
ffffffffc0201020:	6ec50513          	addi	a0,a0,1772 # ffffffffc0205708 <commands+0x888>
ffffffffc0201024:	c2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201028:	00005697          	auipc	a3,0x5
ffffffffc020102c:	84068693          	addi	a3,a3,-1984 # ffffffffc0205868 <commands+0x9e8>
ffffffffc0201030:	00004617          	auipc	a2,0x4
ffffffffc0201034:	6c060613          	addi	a2,a2,1728 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201038:	0dd00593          	li	a1,221
ffffffffc020103c:	00004517          	auipc	a0,0x4
ffffffffc0201040:	6cc50513          	addi	a0,a0,1740 # ffffffffc0205708 <commands+0x888>
ffffffffc0201044:	c0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201048:	00005697          	auipc	a3,0x5
ffffffffc020104c:	86068693          	addi	a3,a3,-1952 # ffffffffc02058a8 <commands+0xa28>
ffffffffc0201050:	00004617          	auipc	a2,0x4
ffffffffc0201054:	6a060613          	addi	a2,a2,1696 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201058:	0dc00593          	li	a1,220
ffffffffc020105c:	00004517          	auipc	a0,0x4
ffffffffc0201060:	6ac50513          	addi	a0,a0,1708 # ffffffffc0205708 <commands+0x888>
ffffffffc0201064:	becff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201068:	00004697          	auipc	a3,0x4
ffffffffc020106c:	6d868693          	addi	a3,a3,1752 # ffffffffc0205740 <commands+0x8c0>
ffffffffc0201070:	00004617          	auipc	a2,0x4
ffffffffc0201074:	68060613          	addi	a2,a2,1664 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201078:	0b900593          	li	a1,185
ffffffffc020107c:	00004517          	auipc	a0,0x4
ffffffffc0201080:	68c50513          	addi	a0,a0,1676 # ffffffffc0205708 <commands+0x888>
ffffffffc0201084:	bccff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201088:	00004697          	auipc	a3,0x4
ffffffffc020108c:	7e068693          	addi	a3,a3,2016 # ffffffffc0205868 <commands+0x9e8>
ffffffffc0201090:	00004617          	auipc	a2,0x4
ffffffffc0201094:	66060613          	addi	a2,a2,1632 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201098:	0d600593          	li	a1,214
ffffffffc020109c:	00004517          	auipc	a0,0x4
ffffffffc02010a0:	66c50513          	addi	a0,a0,1644 # ffffffffc0205708 <commands+0x888>
ffffffffc02010a4:	bacff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010a8:	00004697          	auipc	a3,0x4
ffffffffc02010ac:	6d868693          	addi	a3,a3,1752 # ffffffffc0205780 <commands+0x900>
ffffffffc02010b0:	00004617          	auipc	a2,0x4
ffffffffc02010b4:	64060613          	addi	a2,a2,1600 # ffffffffc02056f0 <commands+0x870>
ffffffffc02010b8:	0d400593          	li	a1,212
ffffffffc02010bc:	00004517          	auipc	a0,0x4
ffffffffc02010c0:	64c50513          	addi	a0,a0,1612 # ffffffffc0205708 <commands+0x888>
ffffffffc02010c4:	b8cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010c8:	00004697          	auipc	a3,0x4
ffffffffc02010cc:	69868693          	addi	a3,a3,1688 # ffffffffc0205760 <commands+0x8e0>
ffffffffc02010d0:	00004617          	auipc	a2,0x4
ffffffffc02010d4:	62060613          	addi	a2,a2,1568 # ffffffffc02056f0 <commands+0x870>
ffffffffc02010d8:	0d300593          	li	a1,211
ffffffffc02010dc:	00004517          	auipc	a0,0x4
ffffffffc02010e0:	62c50513          	addi	a0,a0,1580 # ffffffffc0205708 <commands+0x888>
ffffffffc02010e4:	b6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010e8:	00004697          	auipc	a3,0x4
ffffffffc02010ec:	69868693          	addi	a3,a3,1688 # ffffffffc0205780 <commands+0x900>
ffffffffc02010f0:	00004617          	auipc	a2,0x4
ffffffffc02010f4:	60060613          	addi	a2,a2,1536 # ffffffffc02056f0 <commands+0x870>
ffffffffc02010f8:	0bb00593          	li	a1,187
ffffffffc02010fc:	00004517          	auipc	a0,0x4
ffffffffc0201100:	60c50513          	addi	a0,a0,1548 # ffffffffc0205708 <commands+0x888>
ffffffffc0201104:	b4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(count == 0);
ffffffffc0201108:	00005697          	auipc	a3,0x5
ffffffffc020110c:	92068693          	addi	a3,a3,-1760 # ffffffffc0205a28 <commands+0xba8>
ffffffffc0201110:	00004617          	auipc	a2,0x4
ffffffffc0201114:	5e060613          	addi	a2,a2,1504 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201118:	12500593          	li	a1,293
ffffffffc020111c:	00004517          	auipc	a0,0x4
ffffffffc0201120:	5ec50513          	addi	a0,a0,1516 # ffffffffc0205708 <commands+0x888>
ffffffffc0201124:	b2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free == 0);
ffffffffc0201128:	00004697          	auipc	a3,0x4
ffffffffc020112c:	7a068693          	addi	a3,a3,1952 # ffffffffc02058c8 <commands+0xa48>
ffffffffc0201130:	00004617          	auipc	a2,0x4
ffffffffc0201134:	5c060613          	addi	a2,a2,1472 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201138:	11a00593          	li	a1,282
ffffffffc020113c:	00004517          	auipc	a0,0x4
ffffffffc0201140:	5cc50513          	addi	a0,a0,1484 # ffffffffc0205708 <commands+0x888>
ffffffffc0201144:	b0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201148:	00004697          	auipc	a3,0x4
ffffffffc020114c:	72068693          	addi	a3,a3,1824 # ffffffffc0205868 <commands+0x9e8>
ffffffffc0201150:	00004617          	auipc	a2,0x4
ffffffffc0201154:	5a060613          	addi	a2,a2,1440 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201158:	11800593          	li	a1,280
ffffffffc020115c:	00004517          	auipc	a0,0x4
ffffffffc0201160:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205708 <commands+0x888>
ffffffffc0201164:	aecff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201168:	00004697          	auipc	a3,0x4
ffffffffc020116c:	6c068693          	addi	a3,a3,1728 # ffffffffc0205828 <commands+0x9a8>
ffffffffc0201170:	00004617          	auipc	a2,0x4
ffffffffc0201174:	58060613          	addi	a2,a2,1408 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201178:	0c100593          	li	a1,193
ffffffffc020117c:	00004517          	auipc	a0,0x4
ffffffffc0201180:	58c50513          	addi	a0,a0,1420 # ffffffffc0205708 <commands+0x888>
ffffffffc0201184:	accff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201188:	00005697          	auipc	a3,0x5
ffffffffc020118c:	86068693          	addi	a3,a3,-1952 # ffffffffc02059e8 <commands+0xb68>
ffffffffc0201190:	00004617          	auipc	a2,0x4
ffffffffc0201194:	56060613          	addi	a2,a2,1376 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201198:	11200593          	li	a1,274
ffffffffc020119c:	00004517          	auipc	a0,0x4
ffffffffc02011a0:	56c50513          	addi	a0,a0,1388 # ffffffffc0205708 <commands+0x888>
ffffffffc02011a4:	aacff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02011a8:	00005697          	auipc	a3,0x5
ffffffffc02011ac:	82068693          	addi	a3,a3,-2016 # ffffffffc02059c8 <commands+0xb48>
ffffffffc02011b0:	00004617          	auipc	a2,0x4
ffffffffc02011b4:	54060613          	addi	a2,a2,1344 # ffffffffc02056f0 <commands+0x870>
ffffffffc02011b8:	11000593          	li	a1,272
ffffffffc02011bc:	00004517          	auipc	a0,0x4
ffffffffc02011c0:	54c50513          	addi	a0,a0,1356 # ffffffffc0205708 <commands+0x888>
ffffffffc02011c4:	a8cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02011c8:	00004697          	auipc	a3,0x4
ffffffffc02011cc:	7d868693          	addi	a3,a3,2008 # ffffffffc02059a0 <commands+0xb20>
ffffffffc02011d0:	00004617          	auipc	a2,0x4
ffffffffc02011d4:	52060613          	addi	a2,a2,1312 # ffffffffc02056f0 <commands+0x870>
ffffffffc02011d8:	10e00593          	li	a1,270
ffffffffc02011dc:	00004517          	auipc	a0,0x4
ffffffffc02011e0:	52c50513          	addi	a0,a0,1324 # ffffffffc0205708 <commands+0x888>
ffffffffc02011e4:	a6cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02011e8:	00004697          	auipc	a3,0x4
ffffffffc02011ec:	79068693          	addi	a3,a3,1936 # ffffffffc0205978 <commands+0xaf8>
ffffffffc02011f0:	00004617          	auipc	a2,0x4
ffffffffc02011f4:	50060613          	addi	a2,a2,1280 # ffffffffc02056f0 <commands+0x870>
ffffffffc02011f8:	10d00593          	li	a1,269
ffffffffc02011fc:	00004517          	auipc	a0,0x4
ffffffffc0201200:	50c50513          	addi	a0,a0,1292 # ffffffffc0205708 <commands+0x888>
ffffffffc0201204:	a4cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201208:	00004697          	auipc	a3,0x4
ffffffffc020120c:	76068693          	addi	a3,a3,1888 # ffffffffc0205968 <commands+0xae8>
ffffffffc0201210:	00004617          	auipc	a2,0x4
ffffffffc0201214:	4e060613          	addi	a2,a2,1248 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201218:	10800593          	li	a1,264
ffffffffc020121c:	00004517          	auipc	a0,0x4
ffffffffc0201220:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205708 <commands+0x888>
ffffffffc0201224:	a2cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201228:	00004697          	auipc	a3,0x4
ffffffffc020122c:	64068693          	addi	a3,a3,1600 # ffffffffc0205868 <commands+0x9e8>
ffffffffc0201230:	00004617          	auipc	a2,0x4
ffffffffc0201234:	4c060613          	addi	a2,a2,1216 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201238:	10700593          	li	a1,263
ffffffffc020123c:	00004517          	auipc	a0,0x4
ffffffffc0201240:	4cc50513          	addi	a0,a0,1228 # ffffffffc0205708 <commands+0x888>
ffffffffc0201244:	a0cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201248:	00004697          	auipc	a3,0x4
ffffffffc020124c:	70068693          	addi	a3,a3,1792 # ffffffffc0205948 <commands+0xac8>
ffffffffc0201250:	00004617          	auipc	a2,0x4
ffffffffc0201254:	4a060613          	addi	a2,a2,1184 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201258:	10600593          	li	a1,262
ffffffffc020125c:	00004517          	auipc	a0,0x4
ffffffffc0201260:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205708 <commands+0x888>
ffffffffc0201264:	9ecff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201268:	00004697          	auipc	a3,0x4
ffffffffc020126c:	6b068693          	addi	a3,a3,1712 # ffffffffc0205918 <commands+0xa98>
ffffffffc0201270:	00004617          	auipc	a2,0x4
ffffffffc0201274:	48060613          	addi	a2,a2,1152 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201278:	10500593          	li	a1,261
ffffffffc020127c:	00004517          	auipc	a0,0x4
ffffffffc0201280:	48c50513          	addi	a0,a0,1164 # ffffffffc0205708 <commands+0x888>
ffffffffc0201284:	9ccff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201288:	00004697          	auipc	a3,0x4
ffffffffc020128c:	67868693          	addi	a3,a3,1656 # ffffffffc0205900 <commands+0xa80>
ffffffffc0201290:	00004617          	auipc	a2,0x4
ffffffffc0201294:	46060613          	addi	a2,a2,1120 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201298:	10400593          	li	a1,260
ffffffffc020129c:	00004517          	auipc	a0,0x4
ffffffffc02012a0:	46c50513          	addi	a0,a0,1132 # ffffffffc0205708 <commands+0x888>
ffffffffc02012a4:	9acff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012a8:	00004697          	auipc	a3,0x4
ffffffffc02012ac:	5c068693          	addi	a3,a3,1472 # ffffffffc0205868 <commands+0x9e8>
ffffffffc02012b0:	00004617          	auipc	a2,0x4
ffffffffc02012b4:	44060613          	addi	a2,a2,1088 # ffffffffc02056f0 <commands+0x870>
ffffffffc02012b8:	0fe00593          	li	a1,254
ffffffffc02012bc:	00004517          	auipc	a0,0x4
ffffffffc02012c0:	44c50513          	addi	a0,a0,1100 # ffffffffc0205708 <commands+0x888>
ffffffffc02012c4:	98cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(!PageProperty(p0));
ffffffffc02012c8:	00004697          	auipc	a3,0x4
ffffffffc02012cc:	62068693          	addi	a3,a3,1568 # ffffffffc02058e8 <commands+0xa68>
ffffffffc02012d0:	00004617          	auipc	a2,0x4
ffffffffc02012d4:	42060613          	addi	a2,a2,1056 # ffffffffc02056f0 <commands+0x870>
ffffffffc02012d8:	0f900593          	li	a1,249
ffffffffc02012dc:	00004517          	auipc	a0,0x4
ffffffffc02012e0:	42c50513          	addi	a0,a0,1068 # ffffffffc0205708 <commands+0x888>
ffffffffc02012e4:	96cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012e8:	00004697          	auipc	a3,0x4
ffffffffc02012ec:	72068693          	addi	a3,a3,1824 # ffffffffc0205a08 <commands+0xb88>
ffffffffc02012f0:	00004617          	auipc	a2,0x4
ffffffffc02012f4:	40060613          	addi	a2,a2,1024 # ffffffffc02056f0 <commands+0x870>
ffffffffc02012f8:	11700593          	li	a1,279
ffffffffc02012fc:	00004517          	auipc	a0,0x4
ffffffffc0201300:	40c50513          	addi	a0,a0,1036 # ffffffffc0205708 <commands+0x888>
ffffffffc0201304:	94cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == 0);
ffffffffc0201308:	00004697          	auipc	a3,0x4
ffffffffc020130c:	73068693          	addi	a3,a3,1840 # ffffffffc0205a38 <commands+0xbb8>
ffffffffc0201310:	00004617          	auipc	a2,0x4
ffffffffc0201314:	3e060613          	addi	a2,a2,992 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201318:	12600593          	li	a1,294
ffffffffc020131c:	00004517          	auipc	a0,0x4
ffffffffc0201320:	3ec50513          	addi	a0,a0,1004 # ffffffffc0205708 <commands+0x888>
ffffffffc0201324:	92cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201328:	00004697          	auipc	a3,0x4
ffffffffc020132c:	3f868693          	addi	a3,a3,1016 # ffffffffc0205720 <commands+0x8a0>
ffffffffc0201330:	00004617          	auipc	a2,0x4
ffffffffc0201334:	3c060613          	addi	a2,a2,960 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201338:	0f300593          	li	a1,243
ffffffffc020133c:	00004517          	auipc	a0,0x4
ffffffffc0201340:	3cc50513          	addi	a0,a0,972 # ffffffffc0205708 <commands+0x888>
ffffffffc0201344:	90cff0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201348:	00004697          	auipc	a3,0x4
ffffffffc020134c:	41868693          	addi	a3,a3,1048 # ffffffffc0205760 <commands+0x8e0>
ffffffffc0201350:	00004617          	auipc	a2,0x4
ffffffffc0201354:	3a060613          	addi	a2,a2,928 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201358:	0ba00593          	li	a1,186
ffffffffc020135c:	00004517          	auipc	a0,0x4
ffffffffc0201360:	3ac50513          	addi	a0,a0,940 # ffffffffc0205708 <commands+0x888>
ffffffffc0201364:	8ecff0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201368 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201368:	1141                	addi	sp,sp,-16
ffffffffc020136a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020136c:	16058e63          	beqz	a1,ffffffffc02014e8 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201370:	00659693          	slli	a3,a1,0x6
ffffffffc0201374:	96aa                	add	a3,a3,a0
ffffffffc0201376:	02d50d63          	beq	a0,a3,ffffffffc02013b0 <default_free_pages+0x48>
ffffffffc020137a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020137c:	8b85                	andi	a5,a5,1
ffffffffc020137e:	14079563          	bnez	a5,ffffffffc02014c8 <default_free_pages+0x160>
ffffffffc0201382:	651c                	ld	a5,8(a0)
ffffffffc0201384:	8385                	srli	a5,a5,0x1
ffffffffc0201386:	8b85                	andi	a5,a5,1
ffffffffc0201388:	14079063          	bnez	a5,ffffffffc02014c8 <default_free_pages+0x160>
ffffffffc020138c:	87aa                	mv	a5,a0
ffffffffc020138e:	a809                	j	ffffffffc02013a0 <default_free_pages+0x38>
ffffffffc0201390:	6798                	ld	a4,8(a5)
ffffffffc0201392:	8b05                	andi	a4,a4,1
ffffffffc0201394:	12071a63          	bnez	a4,ffffffffc02014c8 <default_free_pages+0x160>
ffffffffc0201398:	6798                	ld	a4,8(a5)
ffffffffc020139a:	8b09                	andi	a4,a4,2
ffffffffc020139c:	12071663          	bnez	a4,ffffffffc02014c8 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc02013a0:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc02013a4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02013a8:	04078793          	addi	a5,a5,64
ffffffffc02013ac:	fed792e3          	bne	a5,a3,ffffffffc0201390 <default_free_pages+0x28>
    base->property = n;
ffffffffc02013b0:	2581                	sext.w	a1,a1
ffffffffc02013b2:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02013b4:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02013b8:	4789                	li	a5,2
ffffffffc02013ba:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02013be:	00014697          	auipc	a3,0x14
ffffffffc02013c2:	11268693          	addi	a3,a3,274 # ffffffffc02154d0 <free_area>
ffffffffc02013c6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02013c8:	669c                	ld	a5,8(a3)
ffffffffc02013ca:	9db9                	addw	a1,a1,a4
ffffffffc02013cc:	00014717          	auipc	a4,0x14
ffffffffc02013d0:	10b72a23          	sw	a1,276(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02013d4:	0cd78163          	beq	a5,a3,ffffffffc0201496 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02013d8:	fe878713          	addi	a4,a5,-24
ffffffffc02013dc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02013de:	4801                	li	a6,0
ffffffffc02013e0:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02013e4:	00e56a63          	bltu	a0,a4,ffffffffc02013f8 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02013e8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02013ea:	04d70f63          	beq	a4,a3,ffffffffc0201448 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ee:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013f0:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02013f4:	fee57ae3          	bleu	a4,a0,ffffffffc02013e8 <default_free_pages+0x80>
ffffffffc02013f8:	00080663          	beqz	a6,ffffffffc0201404 <default_free_pages+0x9c>
ffffffffc02013fc:	00014817          	auipc	a6,0x14
ffffffffc0201400:	0cb83a23          	sd	a1,212(a6) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201404:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201406:	e390                	sd	a2,0(a5)
ffffffffc0201408:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020140a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020140c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020140e:	06d58a63          	beq	a1,a3,ffffffffc0201482 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0201412:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201416:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020141a:	02061793          	slli	a5,a2,0x20
ffffffffc020141e:	83e9                	srli	a5,a5,0x1a
ffffffffc0201420:	97ba                	add	a5,a5,a4
ffffffffc0201422:	04f51b63          	bne	a0,a5,ffffffffc0201478 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201426:	491c                	lw	a5,16(a0)
ffffffffc0201428:	9e3d                	addw	a2,a2,a5
ffffffffc020142a:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020142e:	57f5                	li	a5,-3
ffffffffc0201430:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201434:	01853803          	ld	a6,24(a0)
ffffffffc0201438:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc020143a:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020143c:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201440:	659c                	ld	a5,8(a1)
ffffffffc0201442:	01063023          	sd	a6,0(a2)
ffffffffc0201446:	a815                	j	ffffffffc020147a <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201448:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020144a:	f114                	sd	a3,32(a0)
ffffffffc020144c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020144e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201450:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201452:	00d70563          	beq	a4,a3,ffffffffc020145c <default_free_pages+0xf4>
ffffffffc0201456:	4805                	li	a6,1
ffffffffc0201458:	87ba                	mv	a5,a4
ffffffffc020145a:	bf59                	j	ffffffffc02013f0 <default_free_pages+0x88>
ffffffffc020145c:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020145e:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201460:	00d78d63          	beq	a5,a3,ffffffffc020147a <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201464:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201468:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc020146c:	02061793          	slli	a5,a2,0x20
ffffffffc0201470:	83e9                	srli	a5,a5,0x1a
ffffffffc0201472:	97ba                	add	a5,a5,a4
ffffffffc0201474:	faf509e3          	beq	a0,a5,ffffffffc0201426 <default_free_pages+0xbe>
ffffffffc0201478:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020147a:	fe878713          	addi	a4,a5,-24
ffffffffc020147e:	00d78963          	beq	a5,a3,ffffffffc0201490 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201482:	4910                	lw	a2,16(a0)
ffffffffc0201484:	02061693          	slli	a3,a2,0x20
ffffffffc0201488:	82e9                	srli	a3,a3,0x1a
ffffffffc020148a:	96aa                	add	a3,a3,a0
ffffffffc020148c:	00d70e63          	beq	a4,a3,ffffffffc02014a8 <default_free_pages+0x140>
}
ffffffffc0201490:	60a2                	ld	ra,8(sp)
ffffffffc0201492:	0141                	addi	sp,sp,16
ffffffffc0201494:	8082                	ret
ffffffffc0201496:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201498:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020149c:	e398                	sd	a4,0(a5)
ffffffffc020149e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02014a0:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02014a2:	ed1c                	sd	a5,24(a0)
}
ffffffffc02014a4:	0141                	addi	sp,sp,16
ffffffffc02014a6:	8082                	ret
            base->property += p->property;
ffffffffc02014a8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014ac:	ff078693          	addi	a3,a5,-16
ffffffffc02014b0:	9e39                	addw	a2,a2,a4
ffffffffc02014b2:	c910                	sw	a2,16(a0)
ffffffffc02014b4:	5775                	li	a4,-3
ffffffffc02014b6:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014ba:	6398                	ld	a4,0(a5)
ffffffffc02014bc:	679c                	ld	a5,8(a5)
}
ffffffffc02014be:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02014c0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02014c2:	e398                	sd	a4,0(a5)
ffffffffc02014c4:	0141                	addi	sp,sp,16
ffffffffc02014c6:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014c8:	00004697          	auipc	a3,0x4
ffffffffc02014cc:	58068693          	addi	a3,a3,1408 # ffffffffc0205a48 <commands+0xbc8>
ffffffffc02014d0:	00004617          	auipc	a2,0x4
ffffffffc02014d4:	22060613          	addi	a2,a2,544 # ffffffffc02056f0 <commands+0x870>
ffffffffc02014d8:	08300593          	li	a1,131
ffffffffc02014dc:	00004517          	auipc	a0,0x4
ffffffffc02014e0:	22c50513          	addi	a0,a0,556 # ffffffffc0205708 <commands+0x888>
ffffffffc02014e4:	f6dfe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc02014e8:	00004697          	auipc	a3,0x4
ffffffffc02014ec:	58868693          	addi	a3,a3,1416 # ffffffffc0205a70 <commands+0xbf0>
ffffffffc02014f0:	00004617          	auipc	a2,0x4
ffffffffc02014f4:	20060613          	addi	a2,a2,512 # ffffffffc02056f0 <commands+0x870>
ffffffffc02014f8:	08000593          	li	a1,128
ffffffffc02014fc:	00004517          	auipc	a0,0x4
ffffffffc0201500:	20c50513          	addi	a0,a0,524 # ffffffffc0205708 <commands+0x888>
ffffffffc0201504:	f4dfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201508 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201508:	c959                	beqz	a0,ffffffffc020159e <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc020150a:	00014597          	auipc	a1,0x14
ffffffffc020150e:	fc658593          	addi	a1,a1,-58 # ffffffffc02154d0 <free_area>
ffffffffc0201512:	0105a803          	lw	a6,16(a1)
ffffffffc0201516:	862a                	mv	a2,a0
ffffffffc0201518:	02081793          	slli	a5,a6,0x20
ffffffffc020151c:	9381                	srli	a5,a5,0x20
ffffffffc020151e:	00a7ee63          	bltu	a5,a0,ffffffffc020153a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201522:	87ae                	mv	a5,a1
ffffffffc0201524:	a801                	j	ffffffffc0201534 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201526:	ff87a703          	lw	a4,-8(a5)
ffffffffc020152a:	02071693          	slli	a3,a4,0x20
ffffffffc020152e:	9281                	srli	a3,a3,0x20
ffffffffc0201530:	00c6f763          	bleu	a2,a3,ffffffffc020153e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201534:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201536:	feb798e3          	bne	a5,a1,ffffffffc0201526 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020153a:	4501                	li	a0,0
}
ffffffffc020153c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020153e:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201542:	dd6d                	beqz	a0,ffffffffc020153c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201544:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201548:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020154c:	00060e1b          	sext.w	t3,a2
ffffffffc0201550:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201554:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201558:	02d67863          	bleu	a3,a2,ffffffffc0201588 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc020155c:	061a                	slli	a2,a2,0x6
ffffffffc020155e:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201560:	41c7073b          	subw	a4,a4,t3
ffffffffc0201564:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201566:	00860693          	addi	a3,a2,8
ffffffffc020156a:	4709                	li	a4,2
ffffffffc020156c:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201570:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201574:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201578:	0105a803          	lw	a6,16(a1)
ffffffffc020157c:	e314                	sd	a3,0(a4)
ffffffffc020157e:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201582:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201584:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201588:	41c8083b          	subw	a6,a6,t3
ffffffffc020158c:	00014717          	auipc	a4,0x14
ffffffffc0201590:	f5072a23          	sw	a6,-172(a4) # ffffffffc02154e0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201594:	5775                	li	a4,-3
ffffffffc0201596:	17c1                	addi	a5,a5,-16
ffffffffc0201598:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc020159c:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020159e:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02015a0:	00004697          	auipc	a3,0x4
ffffffffc02015a4:	4d068693          	addi	a3,a3,1232 # ffffffffc0205a70 <commands+0xbf0>
ffffffffc02015a8:	00004617          	auipc	a2,0x4
ffffffffc02015ac:	14860613          	addi	a2,a2,328 # ffffffffc02056f0 <commands+0x870>
ffffffffc02015b0:	06200593          	li	a1,98
ffffffffc02015b4:	00004517          	auipc	a0,0x4
ffffffffc02015b8:	15450513          	addi	a0,a0,340 # ffffffffc0205708 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc02015bc:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015be:	e93fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02015c2 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02015c2:	1141                	addi	sp,sp,-16
ffffffffc02015c4:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02015c6:	c1ed                	beqz	a1,ffffffffc02016a8 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc02015c8:	00659693          	slli	a3,a1,0x6
ffffffffc02015cc:	96aa                	add	a3,a3,a0
ffffffffc02015ce:	02d50463          	beq	a0,a3,ffffffffc02015f6 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02015d2:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02015d4:	87aa                	mv	a5,a0
ffffffffc02015d6:	8b05                	andi	a4,a4,1
ffffffffc02015d8:	e709                	bnez	a4,ffffffffc02015e2 <default_init_memmap+0x20>
ffffffffc02015da:	a07d                	j	ffffffffc0201688 <default_init_memmap+0xc6>
ffffffffc02015dc:	6798                	ld	a4,8(a5)
ffffffffc02015de:	8b05                	andi	a4,a4,1
ffffffffc02015e0:	c745                	beqz	a4,ffffffffc0201688 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02015e2:	0007a823          	sw	zero,16(a5)
ffffffffc02015e6:	0007b423          	sd	zero,8(a5)
ffffffffc02015ea:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015ee:	04078793          	addi	a5,a5,64
ffffffffc02015f2:	fed795e3          	bne	a5,a3,ffffffffc02015dc <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02015f6:	2581                	sext.w	a1,a1
ffffffffc02015f8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015fa:	4789                	li	a5,2
ffffffffc02015fc:	00850713          	addi	a4,a0,8
ffffffffc0201600:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201604:	00014697          	auipc	a3,0x14
ffffffffc0201608:	ecc68693          	addi	a3,a3,-308 # ffffffffc02154d0 <free_area>
ffffffffc020160c:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020160e:	669c                	ld	a5,8(a3)
ffffffffc0201610:	9db9                	addw	a1,a1,a4
ffffffffc0201612:	00014717          	auipc	a4,0x14
ffffffffc0201616:	ecb72723          	sw	a1,-306(a4) # ffffffffc02154e0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020161a:	04d78a63          	beq	a5,a3,ffffffffc020166e <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc020161e:	fe878713          	addi	a4,a5,-24
ffffffffc0201622:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201624:	4801                	li	a6,0
ffffffffc0201626:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020162a:	00e56a63          	bltu	a0,a4,ffffffffc020163e <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc020162e:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201630:	02d70563          	beq	a4,a3,ffffffffc020165a <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201634:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201636:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020163a:	fee57ae3          	bleu	a4,a0,ffffffffc020162e <default_init_memmap+0x6c>
ffffffffc020163e:	00080663          	beqz	a6,ffffffffc020164a <default_init_memmap+0x88>
ffffffffc0201642:	00014717          	auipc	a4,0x14
ffffffffc0201646:	e8b73723          	sd	a1,-370(a4) # ffffffffc02154d0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020164a:	6398                	ld	a4,0(a5)
}
ffffffffc020164c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020164e:	e390                	sd	a2,0(a5)
ffffffffc0201650:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201652:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201654:	ed18                	sd	a4,24(a0)
ffffffffc0201656:	0141                	addi	sp,sp,16
ffffffffc0201658:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020165a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020165c:	f114                	sd	a3,32(a0)
ffffffffc020165e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201660:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201662:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201664:	00d70e63          	beq	a4,a3,ffffffffc0201680 <default_init_memmap+0xbe>
ffffffffc0201668:	4805                	li	a6,1
ffffffffc020166a:	87ba                	mv	a5,a4
ffffffffc020166c:	b7e9                	j	ffffffffc0201636 <default_init_memmap+0x74>
}
ffffffffc020166e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201670:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201674:	e398                	sd	a4,0(a5)
ffffffffc0201676:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201678:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020167a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020167c:	0141                	addi	sp,sp,16
ffffffffc020167e:	8082                	ret
ffffffffc0201680:	60a2                	ld	ra,8(sp)
ffffffffc0201682:	e290                	sd	a2,0(a3)
ffffffffc0201684:	0141                	addi	sp,sp,16
ffffffffc0201686:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201688:	00004697          	auipc	a3,0x4
ffffffffc020168c:	3f068693          	addi	a3,a3,1008 # ffffffffc0205a78 <commands+0xbf8>
ffffffffc0201690:	00004617          	auipc	a2,0x4
ffffffffc0201694:	06060613          	addi	a2,a2,96 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201698:	04900593          	li	a1,73
ffffffffc020169c:	00004517          	auipc	a0,0x4
ffffffffc02016a0:	06c50513          	addi	a0,a0,108 # ffffffffc0205708 <commands+0x888>
ffffffffc02016a4:	dadfe0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(n > 0);
ffffffffc02016a8:	00004697          	auipc	a3,0x4
ffffffffc02016ac:	3c868693          	addi	a3,a3,968 # ffffffffc0205a70 <commands+0xbf0>
ffffffffc02016b0:	00004617          	auipc	a2,0x4
ffffffffc02016b4:	04060613          	addi	a2,a2,64 # ffffffffc02056f0 <commands+0x870>
ffffffffc02016b8:	04600593          	li	a1,70
ffffffffc02016bc:	00004517          	auipc	a0,0x4
ffffffffc02016c0:	04c50513          	addi	a0,a0,76 # ffffffffc0205708 <commands+0x888>
ffffffffc02016c4:	d8dfe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02016c8 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02016c8:	c125                	beqz	a0,ffffffffc0201728 <slob_free+0x60>
		return;

	if (size)
ffffffffc02016ca:	e1a5                	bnez	a1,ffffffffc020172a <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016cc:	100027f3          	csrr	a5,sstatus
ffffffffc02016d0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02016d2:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016d4:	e3bd                	bnez	a5,ffffffffc020173a <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016d6:	00009797          	auipc	a5,0x9
ffffffffc02016da:	97a78793          	addi	a5,a5,-1670 # ffffffffc020a050 <slobfree>
ffffffffc02016de:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016e0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016e2:	00a7fa63          	bleu	a0,a5,ffffffffc02016f6 <slob_free+0x2e>
ffffffffc02016e6:	00e56c63          	bltu	a0,a4,ffffffffc02016fe <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016ea:	00e7fa63          	bleu	a4,a5,ffffffffc02016fe <slob_free+0x36>
    return 0;
ffffffffc02016ee:	87ba                	mv	a5,a4
ffffffffc02016f0:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02016f2:	fea7eae3          	bltu	a5,a0,ffffffffc02016e6 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02016f6:	fee7ece3          	bltu	a5,a4,ffffffffc02016ee <slob_free+0x26>
ffffffffc02016fa:	fee57ae3          	bleu	a4,a0,ffffffffc02016ee <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02016fe:	4110                	lw	a2,0(a0)
ffffffffc0201700:	00461693          	slli	a3,a2,0x4
ffffffffc0201704:	96aa                	add	a3,a3,a0
ffffffffc0201706:	08d70b63          	beq	a4,a3,ffffffffc020179c <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc020170a:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc020170c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020170e:	00469713          	slli	a4,a3,0x4
ffffffffc0201712:	973e                	add	a4,a4,a5
ffffffffc0201714:	08e50f63          	beq	a0,a4,ffffffffc02017b2 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201718:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc020171a:	00009717          	auipc	a4,0x9
ffffffffc020171e:	92f73b23          	sd	a5,-1738(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201722:	c199                	beqz	a1,ffffffffc0201728 <slob_free+0x60>
        intr_enable();
ffffffffc0201724:	e8bfe06f          	j	ffffffffc02005ae <intr_enable>
ffffffffc0201728:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc020172a:	05bd                	addi	a1,a1,15
ffffffffc020172c:	8191                	srli	a1,a1,0x4
ffffffffc020172e:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201730:	100027f3          	csrr	a5,sstatus
ffffffffc0201734:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201736:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201738:	dfd9                	beqz	a5,ffffffffc02016d6 <slob_free+0xe>
{
ffffffffc020173a:	1101                	addi	sp,sp,-32
ffffffffc020173c:	e42a                	sd	a0,8(sp)
ffffffffc020173e:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201740:	e75fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201744:	00009797          	auipc	a5,0x9
ffffffffc0201748:	90c78793          	addi	a5,a5,-1780 # ffffffffc020a050 <slobfree>
ffffffffc020174c:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc020174e:	6522                	ld	a0,8(sp)
ffffffffc0201750:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201752:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201754:	00a7fa63          	bleu	a0,a5,ffffffffc0201768 <slob_free+0xa0>
ffffffffc0201758:	00e56c63          	bltu	a0,a4,ffffffffc0201770 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020175c:	00e7fa63          	bleu	a4,a5,ffffffffc0201770 <slob_free+0xa8>
    return 0;
ffffffffc0201760:	87ba                	mv	a5,a4
ffffffffc0201762:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201764:	fea7eae3          	bltu	a5,a0,ffffffffc0201758 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201768:	fee7ece3          	bltu	a5,a4,ffffffffc0201760 <slob_free+0x98>
ffffffffc020176c:	fee57ae3          	bleu	a4,a0,ffffffffc0201760 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201770:	4110                	lw	a2,0(a0)
ffffffffc0201772:	00461693          	slli	a3,a2,0x4
ffffffffc0201776:	96aa                	add	a3,a3,a0
ffffffffc0201778:	04d70763          	beq	a4,a3,ffffffffc02017c6 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc020177c:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc020177e:	4394                	lw	a3,0(a5)
ffffffffc0201780:	00469713          	slli	a4,a3,0x4
ffffffffc0201784:	973e                	add	a4,a4,a5
ffffffffc0201786:	04e50663          	beq	a0,a4,ffffffffc02017d2 <slob_free+0x10a>
		cur->next = b;
ffffffffc020178a:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc020178c:	00009717          	auipc	a4,0x9
ffffffffc0201790:	8cf73223          	sd	a5,-1852(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201794:	e58d                	bnez	a1,ffffffffc02017be <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201796:	60e2                	ld	ra,24(sp)
ffffffffc0201798:	6105                	addi	sp,sp,32
ffffffffc020179a:	8082                	ret
		b->units += cur->next->units;
ffffffffc020179c:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc020179e:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017a0:	9e35                	addw	a2,a2,a3
ffffffffc02017a2:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc02017a4:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc02017a6:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02017a8:	00469713          	slli	a4,a3,0x4
ffffffffc02017ac:	973e                	add	a4,a4,a5
ffffffffc02017ae:	f6e515e3          	bne	a0,a4,ffffffffc0201718 <slob_free+0x50>
		cur->units += b->units;
ffffffffc02017b2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017b4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017b6:	9eb9                	addw	a3,a3,a4
ffffffffc02017b8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017ba:	e790                	sd	a2,8(a5)
ffffffffc02017bc:	bfb9                	j	ffffffffc020171a <slob_free+0x52>
}
ffffffffc02017be:	60e2                	ld	ra,24(sp)
ffffffffc02017c0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02017c2:	dedfe06f          	j	ffffffffc02005ae <intr_enable>
		b->units += cur->next->units;
ffffffffc02017c6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc02017c8:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc02017ca:	9e35                	addw	a2,a2,a3
ffffffffc02017cc:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc02017ce:	e518                	sd	a4,8(a0)
ffffffffc02017d0:	b77d                	j	ffffffffc020177e <slob_free+0xb6>
		cur->units += b->units;
ffffffffc02017d2:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc02017d4:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc02017d6:	9eb9                	addw	a3,a3,a4
ffffffffc02017d8:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc02017da:	e790                	sd	a2,8(a5)
ffffffffc02017dc:	bf45                	j	ffffffffc020178c <slob_free+0xc4>

ffffffffc02017de <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017de:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02017e0:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017e2:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc02017e6:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc02017e8:	38a000ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
  if(!page)
ffffffffc02017ec:	c139                	beqz	a0,ffffffffc0201832 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc02017ee:	00014797          	auipc	a5,0x14
ffffffffc02017f2:	d1278793          	addi	a5,a5,-750 # ffffffffc0215500 <pages>
ffffffffc02017f6:	6394                	ld	a3,0(a5)
ffffffffc02017f8:	00005797          	auipc	a5,0x5
ffffffffc02017fc:	5f078793          	addi	a5,a5,1520 # ffffffffc0206de8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201800:	00014717          	auipc	a4,0x14
ffffffffc0201804:	c9070713          	addi	a4,a4,-880 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc0201808:	40d506b3          	sub	a3,a0,a3
ffffffffc020180c:	6388                	ld	a0,0(a5)
ffffffffc020180e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201810:	57fd                	li	a5,-1
ffffffffc0201812:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201814:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201816:	83b1                	srli	a5,a5,0xc
ffffffffc0201818:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020181a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020181c:	00e7ff63          	bleu	a4,a5,ffffffffc020183a <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201820:	00014797          	auipc	a5,0x14
ffffffffc0201824:	cd078793          	addi	a5,a5,-816 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201828:	6388                	ld	a0,0(a5)
}
ffffffffc020182a:	60a2                	ld	ra,8(sp)
ffffffffc020182c:	9536                	add	a0,a0,a3
ffffffffc020182e:	0141                	addi	sp,sp,16
ffffffffc0201830:	8082                	ret
ffffffffc0201832:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201834:	4501                	li	a0,0
}
ffffffffc0201836:	0141                	addi	sp,sp,16
ffffffffc0201838:	8082                	ret
ffffffffc020183a:	00004617          	auipc	a2,0x4
ffffffffc020183e:	29e60613          	addi	a2,a2,670 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0201842:	06900593          	li	a1,105
ffffffffc0201846:	00004517          	auipc	a0,0x4
ffffffffc020184a:	2ba50513          	addi	a0,a0,698 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc020184e:	c03fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201852 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201852:	7179                	addi	sp,sp,-48
ffffffffc0201854:	f406                	sd	ra,40(sp)
ffffffffc0201856:	f022                	sd	s0,32(sp)
ffffffffc0201858:	ec26                	sd	s1,24(sp)
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc020185a:	01050713          	addi	a4,a0,16
ffffffffc020185e:	6785                	lui	a5,0x1
ffffffffc0201860:	0cf77b63          	bleu	a5,a4,ffffffffc0201936 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201864:	00f50413          	addi	s0,a0,15
ffffffffc0201868:	8011                	srli	s0,s0,0x4
ffffffffc020186a:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020186c:	10002673          	csrr	a2,sstatus
ffffffffc0201870:	8a09                	andi	a2,a2,2
ffffffffc0201872:	ea5d                	bnez	a2,ffffffffc0201928 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201874:	00008497          	auipc	s1,0x8
ffffffffc0201878:	7dc48493          	addi	s1,s1,2012 # ffffffffc020a050 <slobfree>
ffffffffc020187c:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020187e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201880:	4398                	lw	a4,0(a5)
ffffffffc0201882:	0a875763          	ble	s0,a4,ffffffffc0201930 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201886:	00f68a63          	beq	a3,a5,ffffffffc020189a <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc020188a:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020188c:	4118                	lw	a4,0(a0)
ffffffffc020188e:	02875763          	ble	s0,a4,ffffffffc02018bc <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201892:	6094                	ld	a3,0(s1)
ffffffffc0201894:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201896:	fef69ae3          	bne	a3,a5,ffffffffc020188a <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc020189a:	ea39                	bnez	a2,ffffffffc02018f0 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc020189c:	4501                	li	a0,0
ffffffffc020189e:	f41ff0ef          	jal	ra,ffffffffc02017de <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02018a2:	cd29                	beqz	a0,ffffffffc02018fc <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02018a4:	6585                	lui	a1,0x1
ffffffffc02018a6:	e23ff0ef          	jal	ra,ffffffffc02016c8 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018aa:	10002673          	csrr	a2,sstatus
ffffffffc02018ae:	8a09                	andi	a2,a2,2
ffffffffc02018b0:	ea1d                	bnez	a2,ffffffffc02018e6 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc02018b2:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02018b4:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02018b6:	4118                	lw	a4,0(a0)
ffffffffc02018b8:	fc874de3          	blt	a4,s0,ffffffffc0201892 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc02018bc:	04e40663          	beq	s0,a4,ffffffffc0201908 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc02018c0:	00441693          	slli	a3,s0,0x4
ffffffffc02018c4:	96aa                	add	a3,a3,a0
ffffffffc02018c6:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02018c8:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc02018ca:	9f01                	subw	a4,a4,s0
ffffffffc02018cc:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02018ce:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02018d0:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc02018d2:	00008717          	auipc	a4,0x8
ffffffffc02018d6:	76f73f23          	sd	a5,1918(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc02018da:	ee15                	bnez	a2,ffffffffc0201916 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc02018dc:	70a2                	ld	ra,40(sp)
ffffffffc02018de:	7402                	ld	s0,32(sp)
ffffffffc02018e0:	64e2                	ld	s1,24(sp)
ffffffffc02018e2:	6145                	addi	sp,sp,48
ffffffffc02018e4:	8082                	ret
        intr_disable();
ffffffffc02018e6:	ccffe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc02018ea:	4605                	li	a2,1
			cur = slobfree;
ffffffffc02018ec:	609c                	ld	a5,0(s1)
ffffffffc02018ee:	b7d9                	j	ffffffffc02018b4 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc02018f0:	cbffe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02018f4:	4501                	li	a0,0
ffffffffc02018f6:	ee9ff0ef          	jal	ra,ffffffffc02017de <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02018fa:	f54d                	bnez	a0,ffffffffc02018a4 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc02018fc:	70a2                	ld	ra,40(sp)
ffffffffc02018fe:	7402                	ld	s0,32(sp)
ffffffffc0201900:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201902:	4501                	li	a0,0
}
ffffffffc0201904:	6145                	addi	sp,sp,48
ffffffffc0201906:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201908:	6518                	ld	a4,8(a0)
ffffffffc020190a:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc020190c:	00008717          	auipc	a4,0x8
ffffffffc0201910:	74f73223          	sd	a5,1860(a4) # ffffffffc020a050 <slobfree>
    if (flag) {
ffffffffc0201914:	d661                	beqz	a2,ffffffffc02018dc <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201916:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201918:	c97fe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
}
ffffffffc020191c:	70a2                	ld	ra,40(sp)
ffffffffc020191e:	7402                	ld	s0,32(sp)
ffffffffc0201920:	6522                	ld	a0,8(sp)
ffffffffc0201922:	64e2                	ld	s1,24(sp)
ffffffffc0201924:	6145                	addi	sp,sp,48
ffffffffc0201926:	8082                	ret
        intr_disable();
ffffffffc0201928:	c8dfe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc020192c:	4605                	li	a2,1
ffffffffc020192e:	b799                	j	ffffffffc0201874 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201930:	853e                	mv	a0,a5
ffffffffc0201932:	87b6                	mv	a5,a3
ffffffffc0201934:	b761                	j	ffffffffc02018bc <slob_alloc.isra.1.constprop.3+0x6a>
	assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201936:	00004697          	auipc	a3,0x4
ffffffffc020193a:	24268693          	addi	a3,a3,578 # ffffffffc0205b78 <default_pmm_manager+0xf0>
ffffffffc020193e:	00004617          	auipc	a2,0x4
ffffffffc0201942:	db260613          	addi	a2,a2,-590 # ffffffffc02056f0 <commands+0x870>
ffffffffc0201946:	06300593          	li	a1,99
ffffffffc020194a:	00004517          	auipc	a0,0x4
ffffffffc020194e:	24e50513          	addi	a0,a0,590 # ffffffffc0205b98 <default_pmm_manager+0x110>
ffffffffc0201952:	afffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201956 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201956:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201958:	00004517          	auipc	a0,0x4
ffffffffc020195c:	25850513          	addi	a0,a0,600 # ffffffffc0205bb0 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201960:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201962:	82dfe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201966:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201968:	00004517          	auipc	a0,0x4
ffffffffc020196c:	1f050513          	addi	a0,a0,496 # ffffffffc0205b58 <default_pmm_manager+0xd0>
}
ffffffffc0201970:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201972:	81dfe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201976 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201976:	1101                	addi	sp,sp,-32
ffffffffc0201978:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc020197a:	6905                	lui	s2,0x1
{
ffffffffc020197c:	e822                	sd	s0,16(sp)
ffffffffc020197e:	ec06                	sd	ra,24(sp)
ffffffffc0201980:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201982:	fef90793          	addi	a5,s2,-17 # fef <BASE_ADDRESS-0xffffffffc01ff011>
{
ffffffffc0201986:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201988:	04a7fc63          	bleu	a0,a5,ffffffffc02019e0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc020198c:	4561                	li	a0,24
ffffffffc020198e:	ec5ff0ef          	jal	ra,ffffffffc0201852 <slob_alloc.isra.1.constprop.3>
ffffffffc0201992:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201994:	cd21                	beqz	a0,ffffffffc02019ec <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201996:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc020199a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc020199c:	00f95763          	ble	a5,s2,ffffffffc02019aa <kmalloc+0x34>
ffffffffc02019a0:	6705                	lui	a4,0x1
ffffffffc02019a2:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02019a4:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02019a6:	fef74ee3          	blt	a4,a5,ffffffffc02019a2 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02019aa:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02019ac:	e33ff0ef          	jal	ra,ffffffffc02017de <__slob_get_free_pages.isra.0>
ffffffffc02019b0:	e488                	sd	a0,8(s1)
ffffffffc02019b2:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02019b4:	c935                	beqz	a0,ffffffffc0201a28 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019b6:	100027f3          	csrr	a5,sstatus
ffffffffc02019ba:	8b89                	andi	a5,a5,2
ffffffffc02019bc:	e3a1                	bnez	a5,ffffffffc02019fc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02019be:	00014797          	auipc	a5,0x14
ffffffffc02019c2:	ac278793          	addi	a5,a5,-1342 # ffffffffc0215480 <bigblocks>
ffffffffc02019c6:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02019c8:	00014717          	auipc	a4,0x14
ffffffffc02019cc:	aa973c23          	sd	s1,-1352(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc02019d0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc02019d2:	8522                	mv	a0,s0
ffffffffc02019d4:	60e2                	ld	ra,24(sp)
ffffffffc02019d6:	6442                	ld	s0,16(sp)
ffffffffc02019d8:	64a2                	ld	s1,8(sp)
ffffffffc02019da:	6902                	ld	s2,0(sp)
ffffffffc02019dc:	6105                	addi	sp,sp,32
ffffffffc02019de:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc02019e0:	0541                	addi	a0,a0,16
ffffffffc02019e2:	e71ff0ef          	jal	ra,ffffffffc0201852 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc02019e6:	01050413          	addi	s0,a0,16
ffffffffc02019ea:	f565                	bnez	a0,ffffffffc02019d2 <kmalloc+0x5c>
ffffffffc02019ec:	4401                	li	s0,0
}
ffffffffc02019ee:	8522                	mv	a0,s0
ffffffffc02019f0:	60e2                	ld	ra,24(sp)
ffffffffc02019f2:	6442                	ld	s0,16(sp)
ffffffffc02019f4:	64a2                	ld	s1,8(sp)
ffffffffc02019f6:	6902                	ld	s2,0(sp)
ffffffffc02019f8:	6105                	addi	sp,sp,32
ffffffffc02019fa:	8082                	ret
        intr_disable();
ffffffffc02019fc:	bb9fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a00:	00014797          	auipc	a5,0x14
ffffffffc0201a04:	a8078793          	addi	a5,a5,-1408 # ffffffffc0215480 <bigblocks>
ffffffffc0201a08:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201a0a:	00014717          	auipc	a4,0x14
ffffffffc0201a0e:	a6973b23          	sd	s1,-1418(a4) # ffffffffc0215480 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a12:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201a14:	b9bfe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201a18:	6480                	ld	s0,8(s1)
}
ffffffffc0201a1a:	60e2                	ld	ra,24(sp)
ffffffffc0201a1c:	64a2                	ld	s1,8(sp)
ffffffffc0201a1e:	8522                	mv	a0,s0
ffffffffc0201a20:	6442                	ld	s0,16(sp)
ffffffffc0201a22:	6902                	ld	s2,0(sp)
ffffffffc0201a24:	6105                	addi	sp,sp,32
ffffffffc0201a26:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a28:	45e1                	li	a1,24
ffffffffc0201a2a:	8526                	mv	a0,s1
ffffffffc0201a2c:	c9dff0ef          	jal	ra,ffffffffc02016c8 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201a30:	b74d                	j	ffffffffc02019d2 <kmalloc+0x5c>

ffffffffc0201a32 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201a32:	c175                	beqz	a0,ffffffffc0201b16 <kfree+0xe4>
{
ffffffffc0201a34:	1101                	addi	sp,sp,-32
ffffffffc0201a36:	e426                	sd	s1,8(sp)
ffffffffc0201a38:	ec06                	sd	ra,24(sp)
ffffffffc0201a3a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201a3c:	03451793          	slli	a5,a0,0x34
ffffffffc0201a40:	84aa                	mv	s1,a0
ffffffffc0201a42:	eb8d                	bnez	a5,ffffffffc0201a74 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a44:	100027f3          	csrr	a5,sstatus
ffffffffc0201a48:	8b89                	andi	a5,a5,2
ffffffffc0201a4a:	efc9                	bnez	a5,ffffffffc0201ae4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a4c:	00014797          	auipc	a5,0x14
ffffffffc0201a50:	a3478793          	addi	a5,a5,-1484 # ffffffffc0215480 <bigblocks>
ffffffffc0201a54:	6394                	ld	a3,0(a5)
ffffffffc0201a56:	ce99                	beqz	a3,ffffffffc0201a74 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201a58:	669c                	ld	a5,8(a3)
ffffffffc0201a5a:	6a80                	ld	s0,16(a3)
ffffffffc0201a5c:	0af50e63          	beq	a0,a5,ffffffffc0201b18 <kfree+0xe6>
    return 0;
ffffffffc0201a60:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a62:	c801                	beqz	s0,ffffffffc0201a72 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201a64:	6418                	ld	a4,8(s0)
ffffffffc0201a66:	681c                	ld	a5,16(s0)
ffffffffc0201a68:	00970f63          	beq	a4,s1,ffffffffc0201a86 <kfree+0x54>
ffffffffc0201a6c:	86a2                	mv	a3,s0
ffffffffc0201a6e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201a70:	f875                	bnez	s0,ffffffffc0201a64 <kfree+0x32>
    if (flag) {
ffffffffc0201a72:	e659                	bnez	a2,ffffffffc0201b00 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201a74:	6442                	ld	s0,16(sp)
ffffffffc0201a76:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a78:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201a7c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a7e:	4581                	li	a1,0
}
ffffffffc0201a80:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201a82:	c47ff06f          	j	ffffffffc02016c8 <slob_free>
				*last = bb->next;
ffffffffc0201a86:	ea9c                	sd	a5,16(a3)
ffffffffc0201a88:	e641                	bnez	a2,ffffffffc0201b10 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201a8a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201a8e:	4018                	lw	a4,0(s0)
ffffffffc0201a90:	08f4ea63          	bltu	s1,a5,ffffffffc0201b24 <kfree+0xf2>
ffffffffc0201a94:	00014797          	auipc	a5,0x14
ffffffffc0201a98:	a5c78793          	addi	a5,a5,-1444 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201a9c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201a9e:	00014797          	auipc	a5,0x14
ffffffffc0201aa2:	9f278793          	addi	a5,a5,-1550 # ffffffffc0215490 <npage>
ffffffffc0201aa6:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201aa8:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201aaa:	80b1                	srli	s1,s1,0xc
ffffffffc0201aac:	08f4f963          	bleu	a5,s1,ffffffffc0201b3e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ab0:	00005797          	auipc	a5,0x5
ffffffffc0201ab4:	33878793          	addi	a5,a5,824 # ffffffffc0206de8 <nbase>
ffffffffc0201ab8:	639c                	ld	a5,0(a5)
ffffffffc0201aba:	00014697          	auipc	a3,0x14
ffffffffc0201abe:	a4668693          	addi	a3,a3,-1466 # ffffffffc0215500 <pages>
ffffffffc0201ac2:	6288                	ld	a0,0(a3)
ffffffffc0201ac4:	8c9d                	sub	s1,s1,a5
ffffffffc0201ac6:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201ac8:	4585                	li	a1,1
ffffffffc0201aca:	9526                	add	a0,a0,s1
ffffffffc0201acc:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201ad0:	12a000ef          	jal	ra,ffffffffc0201bfa <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ad4:	8522                	mv	a0,s0
}
ffffffffc0201ad6:	6442                	ld	s0,16(sp)
ffffffffc0201ad8:	60e2                	ld	ra,24(sp)
ffffffffc0201ada:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201adc:	45e1                	li	a1,24
}
ffffffffc0201ade:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ae0:	be9ff06f          	j	ffffffffc02016c8 <slob_free>
        intr_disable();
ffffffffc0201ae4:	ad1fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ae8:	00014797          	auipc	a5,0x14
ffffffffc0201aec:	99878793          	addi	a5,a5,-1640 # ffffffffc0215480 <bigblocks>
ffffffffc0201af0:	6394                	ld	a3,0(a5)
ffffffffc0201af2:	c699                	beqz	a3,ffffffffc0201b00 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201af4:	669c                	ld	a5,8(a3)
ffffffffc0201af6:	6a80                	ld	s0,16(a3)
ffffffffc0201af8:	00f48763          	beq	s1,a5,ffffffffc0201b06 <kfree+0xd4>
        return 1;
ffffffffc0201afc:	4605                	li	a2,1
ffffffffc0201afe:	b795                	j	ffffffffc0201a62 <kfree+0x30>
        intr_enable();
ffffffffc0201b00:	aaffe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201b04:	bf85                	j	ffffffffc0201a74 <kfree+0x42>
				*last = bb->next;
ffffffffc0201b06:	00014797          	auipc	a5,0x14
ffffffffc0201b0a:	9687bd23          	sd	s0,-1670(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201b0e:	8436                	mv	s0,a3
ffffffffc0201b10:	a9ffe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201b14:	bf9d                	j	ffffffffc0201a8a <kfree+0x58>
ffffffffc0201b16:	8082                	ret
ffffffffc0201b18:	00014797          	auipc	a5,0x14
ffffffffc0201b1c:	9687b423          	sd	s0,-1688(a5) # ffffffffc0215480 <bigblocks>
ffffffffc0201b20:	8436                	mv	s0,a3
ffffffffc0201b22:	b7a5                	j	ffffffffc0201a8a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201b24:	86a6                	mv	a3,s1
ffffffffc0201b26:	00004617          	auipc	a2,0x4
ffffffffc0201b2a:	fea60613          	addi	a2,a2,-22 # ffffffffc0205b10 <default_pmm_manager+0x88>
ffffffffc0201b2e:	06e00593          	li	a1,110
ffffffffc0201b32:	00004517          	auipc	a0,0x4
ffffffffc0201b36:	fce50513          	addi	a0,a0,-50 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0201b3a:	917fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201b3e:	00004617          	auipc	a2,0x4
ffffffffc0201b42:	ffa60613          	addi	a2,a2,-6 # ffffffffc0205b38 <default_pmm_manager+0xb0>
ffffffffc0201b46:	06200593          	li	a1,98
ffffffffc0201b4a:	00004517          	auipc	a0,0x4
ffffffffc0201b4e:	fb650513          	addi	a0,a0,-74 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0201b52:	8fffe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201b56 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201b56:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201b58:	00004617          	auipc	a2,0x4
ffffffffc0201b5c:	fe060613          	addi	a2,a2,-32 # ffffffffc0205b38 <default_pmm_manager+0xb0>
ffffffffc0201b60:	06200593          	li	a1,98
ffffffffc0201b64:	00004517          	auipc	a0,0x4
ffffffffc0201b68:	f9c50513          	addi	a0,a0,-100 # ffffffffc0205b00 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201b6c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201b6e:	8e3fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201b72 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201b72:	715d                	addi	sp,sp,-80
ffffffffc0201b74:	e0a2                	sd	s0,64(sp)
ffffffffc0201b76:	fc26                	sd	s1,56(sp)
ffffffffc0201b78:	f84a                	sd	s2,48(sp)
ffffffffc0201b7a:	f44e                	sd	s3,40(sp)
ffffffffc0201b7c:	f052                	sd	s4,32(sp)
ffffffffc0201b7e:	ec56                	sd	s5,24(sp)
ffffffffc0201b80:	e486                	sd	ra,72(sp)
ffffffffc0201b82:	842a                	mv	s0,a0
ffffffffc0201b84:	00014497          	auipc	s1,0x14
ffffffffc0201b88:	96448493          	addi	s1,s1,-1692 # ffffffffc02154e8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201b8c:	4985                	li	s3,1
ffffffffc0201b8e:	00014a17          	auipc	s4,0x14
ffffffffc0201b92:	912a0a13          	addi	s4,s4,-1774 # ffffffffc02154a0 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201b96:	0005091b          	sext.w	s2,a0
ffffffffc0201b9a:	00014a97          	auipc	s5,0x14
ffffffffc0201b9e:	a46a8a93          	addi	s5,s5,-1466 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0201ba2:	a00d                	j	ffffffffc0201bc4 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201ba4:	609c                	ld	a5,0(s1)
ffffffffc0201ba6:	6f9c                	ld	a5,24(a5)
ffffffffc0201ba8:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201baa:	4601                	li	a2,0
ffffffffc0201bac:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201bae:	ed0d                	bnez	a0,ffffffffc0201be8 <alloc_pages+0x76>
ffffffffc0201bb0:	0289ec63          	bltu	s3,s0,ffffffffc0201be8 <alloc_pages+0x76>
ffffffffc0201bb4:	000a2783          	lw	a5,0(s4)
ffffffffc0201bb8:	2781                	sext.w	a5,a5
ffffffffc0201bba:	c79d                	beqz	a5,ffffffffc0201be8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201bbc:	000ab503          	ld	a0,0(s5)
ffffffffc0201bc0:	6dc010ef          	jal	ra,ffffffffc020329c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bc4:	100027f3          	csrr	a5,sstatus
ffffffffc0201bc8:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201bca:	8522                	mv	a0,s0
ffffffffc0201bcc:	dfe1                	beqz	a5,ffffffffc0201ba4 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201bce:	9e7fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
ffffffffc0201bd2:	609c                	ld	a5,0(s1)
ffffffffc0201bd4:	8522                	mv	a0,s0
ffffffffc0201bd6:	6f9c                	ld	a5,24(a5)
ffffffffc0201bd8:	9782                	jalr	a5
ffffffffc0201bda:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bdc:	9d3fe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
ffffffffc0201be0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201be2:	4601                	li	a2,0
ffffffffc0201be4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201be6:	d569                	beqz	a0,ffffffffc0201bb0 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201be8:	60a6                	ld	ra,72(sp)
ffffffffc0201bea:	6406                	ld	s0,64(sp)
ffffffffc0201bec:	74e2                	ld	s1,56(sp)
ffffffffc0201bee:	7942                	ld	s2,48(sp)
ffffffffc0201bf0:	79a2                	ld	s3,40(sp)
ffffffffc0201bf2:	7a02                	ld	s4,32(sp)
ffffffffc0201bf4:	6ae2                	ld	s5,24(sp)
ffffffffc0201bf6:	6161                	addi	sp,sp,80
ffffffffc0201bf8:	8082                	ret

ffffffffc0201bfa <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bfa:	100027f3          	csrr	a5,sstatus
ffffffffc0201bfe:	8b89                	andi	a5,a5,2
ffffffffc0201c00:	eb89                	bnez	a5,ffffffffc0201c12 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201c02:	00014797          	auipc	a5,0x14
ffffffffc0201c06:	8e678793          	addi	a5,a5,-1818 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c0a:	639c                	ld	a5,0(a5)
ffffffffc0201c0c:	0207b303          	ld	t1,32(a5)
ffffffffc0201c10:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201c12:	1101                	addi	sp,sp,-32
ffffffffc0201c14:	ec06                	sd	ra,24(sp)
ffffffffc0201c16:	e822                	sd	s0,16(sp)
ffffffffc0201c18:	e426                	sd	s1,8(sp)
ffffffffc0201c1a:	842a                	mv	s0,a0
ffffffffc0201c1c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201c1e:	997fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201c22:	00014797          	auipc	a5,0x14
ffffffffc0201c26:	8c678793          	addi	a5,a5,-1850 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c2a:	639c                	ld	a5,0(a5)
ffffffffc0201c2c:	85a6                	mv	a1,s1
ffffffffc0201c2e:	8522                	mv	a0,s0
ffffffffc0201c30:	739c                	ld	a5,32(a5)
ffffffffc0201c32:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c34:	6442                	ld	s0,16(sp)
ffffffffc0201c36:	60e2                	ld	ra,24(sp)
ffffffffc0201c38:	64a2                	ld	s1,8(sp)
ffffffffc0201c3a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c3c:	973fe06f          	j	ffffffffc02005ae <intr_enable>

ffffffffc0201c40 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c40:	100027f3          	csrr	a5,sstatus
ffffffffc0201c44:	8b89                	andi	a5,a5,2
ffffffffc0201c46:	eb89                	bnez	a5,ffffffffc0201c58 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c48:	00014797          	auipc	a5,0x14
ffffffffc0201c4c:	8a078793          	addi	a5,a5,-1888 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c50:	639c                	ld	a5,0(a5)
ffffffffc0201c52:	0287b303          	ld	t1,40(a5)
ffffffffc0201c56:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201c58:	1141                	addi	sp,sp,-16
ffffffffc0201c5a:	e406                	sd	ra,8(sp)
ffffffffc0201c5c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201c5e:	957fe0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c62:	00014797          	auipc	a5,0x14
ffffffffc0201c66:	88678793          	addi	a5,a5,-1914 # ffffffffc02154e8 <pmm_manager>
ffffffffc0201c6a:	639c                	ld	a5,0(a5)
ffffffffc0201c6c:	779c                	ld	a5,40(a5)
ffffffffc0201c6e:	9782                	jalr	a5
ffffffffc0201c70:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201c72:	93dfe0ef          	jal	ra,ffffffffc02005ae <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201c76:	8522                	mv	a0,s0
ffffffffc0201c78:	60a2                	ld	ra,8(sp)
ffffffffc0201c7a:	6402                	ld	s0,0(sp)
ffffffffc0201c7c:	0141                	addi	sp,sp,16
ffffffffc0201c7e:	8082                	ret

ffffffffc0201c80 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201c80:	7139                	addi	sp,sp,-64
ffffffffc0201c82:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201c84:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201c88:	1ff4f493          	andi	s1,s1,511
ffffffffc0201c8c:	048e                	slli	s1,s1,0x3
ffffffffc0201c8e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201c90:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201c92:	f04a                	sd	s2,32(sp)
ffffffffc0201c94:	ec4e                	sd	s3,24(sp)
ffffffffc0201c96:	e852                	sd	s4,16(sp)
ffffffffc0201c98:	fc06                	sd	ra,56(sp)
ffffffffc0201c9a:	f822                	sd	s0,48(sp)
ffffffffc0201c9c:	e456                	sd	s5,8(sp)
ffffffffc0201c9e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201ca0:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201ca4:	892e                	mv	s2,a1
ffffffffc0201ca6:	8a32                	mv	s4,a2
ffffffffc0201ca8:	00013997          	auipc	s3,0x13
ffffffffc0201cac:	7e898993          	addi	s3,s3,2024 # ffffffffc0215490 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201cb0:	e7bd                	bnez	a5,ffffffffc0201d1e <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201cb2:	12060c63          	beqz	a2,ffffffffc0201dea <get_pte+0x16a>
ffffffffc0201cb6:	4505                	li	a0,1
ffffffffc0201cb8:	ebbff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0201cbc:	842a                	mv	s0,a0
ffffffffc0201cbe:	12050663          	beqz	a0,ffffffffc0201dea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201cc2:	00014b17          	auipc	s6,0x14
ffffffffc0201cc6:	83eb0b13          	addi	s6,s6,-1986 # ffffffffc0215500 <pages>
ffffffffc0201cca:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201cce:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201cd0:	00013997          	auipc	s3,0x13
ffffffffc0201cd4:	7c098993          	addi	s3,s3,1984 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc0201cd8:	40a40533          	sub	a0,s0,a0
ffffffffc0201cdc:	00080ab7          	lui	s5,0x80
ffffffffc0201ce0:	8519                	srai	a0,a0,0x6
ffffffffc0201ce2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201ce6:	c01c                	sw	a5,0(s0)
ffffffffc0201ce8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201cea:	9556                	add	a0,a0,s5
ffffffffc0201cec:	83b1                	srli	a5,a5,0xc
ffffffffc0201cee:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201cf0:	0532                	slli	a0,a0,0xc
ffffffffc0201cf2:	14e7f363          	bleu	a4,a5,ffffffffc0201e38 <get_pte+0x1b8>
ffffffffc0201cf6:	00013797          	auipc	a5,0x13
ffffffffc0201cfa:	7fa78793          	addi	a5,a5,2042 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201cfe:	639c                	ld	a5,0(a5)
ffffffffc0201d00:	6605                	lui	a2,0x1
ffffffffc0201d02:	4581                	li	a1,0
ffffffffc0201d04:	953e                	add	a0,a0,a5
ffffffffc0201d06:	7eb020ef          	jal	ra,ffffffffc0204cf0 <memset>
    return page - pages + nbase;
ffffffffc0201d0a:	000b3683          	ld	a3,0(s6)
ffffffffc0201d0e:	40d406b3          	sub	a3,s0,a3
ffffffffc0201d12:	8699                	srai	a3,a3,0x6
ffffffffc0201d14:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201d16:	06aa                	slli	a3,a3,0xa
ffffffffc0201d18:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201d1c:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d1e:	77fd                	lui	a5,0xfffff
ffffffffc0201d20:	068a                	slli	a3,a3,0x2
ffffffffc0201d22:	0009b703          	ld	a4,0(s3)
ffffffffc0201d26:	8efd                	and	a3,a3,a5
ffffffffc0201d28:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d2c:	0ce7f163          	bleu	a4,a5,ffffffffc0201dee <get_pte+0x16e>
ffffffffc0201d30:	00013a97          	auipc	s5,0x13
ffffffffc0201d34:	7c0a8a93          	addi	s5,s5,1984 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0201d38:	000ab403          	ld	s0,0(s5)
ffffffffc0201d3c:	01595793          	srli	a5,s2,0x15
ffffffffc0201d40:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d44:	96a2                	add	a3,a3,s0
ffffffffc0201d46:	00379413          	slli	s0,a5,0x3
ffffffffc0201d4a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201d4c:	6014                	ld	a3,0(s0)
ffffffffc0201d4e:	0016f793          	andi	a5,a3,1
ffffffffc0201d52:	e3ad                	bnez	a5,ffffffffc0201db4 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201d54:	080a0b63          	beqz	s4,ffffffffc0201dea <get_pte+0x16a>
ffffffffc0201d58:	4505                	li	a0,1
ffffffffc0201d5a:	e19ff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0201d5e:	84aa                	mv	s1,a0
ffffffffc0201d60:	c549                	beqz	a0,ffffffffc0201dea <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201d62:	00013b17          	auipc	s6,0x13
ffffffffc0201d66:	79eb0b13          	addi	s6,s6,1950 # ffffffffc0215500 <pages>
ffffffffc0201d6a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201d6e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0201d70:	00080a37          	lui	s4,0x80
ffffffffc0201d74:	40a48533          	sub	a0,s1,a0
ffffffffc0201d78:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d7a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201d7e:	c09c                	sw	a5,0(s1)
ffffffffc0201d80:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201d82:	9552                	add	a0,a0,s4
ffffffffc0201d84:	83b1                	srli	a5,a5,0xc
ffffffffc0201d86:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d88:	0532                	slli	a0,a0,0xc
ffffffffc0201d8a:	08e7fa63          	bleu	a4,a5,ffffffffc0201e1e <get_pte+0x19e>
ffffffffc0201d8e:	000ab783          	ld	a5,0(s5)
ffffffffc0201d92:	6605                	lui	a2,0x1
ffffffffc0201d94:	4581                	li	a1,0
ffffffffc0201d96:	953e                	add	a0,a0,a5
ffffffffc0201d98:	759020ef          	jal	ra,ffffffffc0204cf0 <memset>
    return page - pages + nbase;
ffffffffc0201d9c:	000b3683          	ld	a3,0(s6)
ffffffffc0201da0:	40d486b3          	sub	a3,s1,a3
ffffffffc0201da4:	8699                	srai	a3,a3,0x6
ffffffffc0201da6:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201da8:	06aa                	slli	a3,a3,0xa
ffffffffc0201daa:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201dae:	e014                	sd	a3,0(s0)
ffffffffc0201db0:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201db4:	068a                	slli	a3,a3,0x2
ffffffffc0201db6:	757d                	lui	a0,0xfffff
ffffffffc0201db8:	8ee9                	and	a3,a3,a0
ffffffffc0201dba:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201dbe:	04e7f463          	bleu	a4,a5,ffffffffc0201e06 <get_pte+0x186>
ffffffffc0201dc2:	000ab503          	ld	a0,0(s5)
ffffffffc0201dc6:	00c95793          	srli	a5,s2,0xc
ffffffffc0201dca:	1ff7f793          	andi	a5,a5,511
ffffffffc0201dce:	96aa                	add	a3,a3,a0
ffffffffc0201dd0:	00379513          	slli	a0,a5,0x3
ffffffffc0201dd4:	9536                	add	a0,a0,a3
}
ffffffffc0201dd6:	70e2                	ld	ra,56(sp)
ffffffffc0201dd8:	7442                	ld	s0,48(sp)
ffffffffc0201dda:	74a2                	ld	s1,40(sp)
ffffffffc0201ddc:	7902                	ld	s2,32(sp)
ffffffffc0201dde:	69e2                	ld	s3,24(sp)
ffffffffc0201de0:	6a42                	ld	s4,16(sp)
ffffffffc0201de2:	6aa2                	ld	s5,8(sp)
ffffffffc0201de4:	6b02                	ld	s6,0(sp)
ffffffffc0201de6:	6121                	addi	sp,sp,64
ffffffffc0201de8:	8082                	ret
            return NULL;
ffffffffc0201dea:	4501                	li	a0,0
ffffffffc0201dec:	b7ed                	j	ffffffffc0201dd6 <get_pte+0x156>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201dee:	00004617          	auipc	a2,0x4
ffffffffc0201df2:	cea60613          	addi	a2,a2,-790 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0201df6:	0e400593          	li	a1,228
ffffffffc0201dfa:	00004517          	auipc	a0,0x4
ffffffffc0201dfe:	dce50513          	addi	a0,a0,-562 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0201e02:	e4efe0ef          	jal	ra,ffffffffc0200450 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e06:	00004617          	auipc	a2,0x4
ffffffffc0201e0a:	cd260613          	addi	a2,a2,-814 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0201e0e:	0ef00593          	li	a1,239
ffffffffc0201e12:	00004517          	auipc	a0,0x4
ffffffffc0201e16:	db650513          	addi	a0,a0,-586 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0201e1a:	e36fe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e1e:	86aa                	mv	a3,a0
ffffffffc0201e20:	00004617          	auipc	a2,0x4
ffffffffc0201e24:	cb860613          	addi	a2,a2,-840 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0201e28:	0ec00593          	li	a1,236
ffffffffc0201e2c:	00004517          	auipc	a0,0x4
ffffffffc0201e30:	d9c50513          	addi	a0,a0,-612 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0201e34:	e1cfe0ef          	jal	ra,ffffffffc0200450 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e38:	86aa                	mv	a3,a0
ffffffffc0201e3a:	00004617          	auipc	a2,0x4
ffffffffc0201e3e:	c9e60613          	addi	a2,a2,-866 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0201e42:	0e100593          	li	a1,225
ffffffffc0201e46:	00004517          	auipc	a0,0x4
ffffffffc0201e4a:	d8250513          	addi	a0,a0,-638 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0201e4e:	e02fe0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0201e52 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e52:	1141                	addi	sp,sp,-16
ffffffffc0201e54:	e022                	sd	s0,0(sp)
ffffffffc0201e56:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e58:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201e5a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201e5c:	e25ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201e60:	c011                	beqz	s0,ffffffffc0201e64 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0201e62:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e64:	c129                	beqz	a0,ffffffffc0201ea6 <get_page+0x54>
ffffffffc0201e66:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201e68:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201e6a:	0017f713          	andi	a4,a5,1
ffffffffc0201e6e:	e709                	bnez	a4,ffffffffc0201e78 <get_page+0x26>
}
ffffffffc0201e70:	60a2                	ld	ra,8(sp)
ffffffffc0201e72:	6402                	ld	s0,0(sp)
ffffffffc0201e74:	0141                	addi	sp,sp,16
ffffffffc0201e76:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201e78:	00013717          	auipc	a4,0x13
ffffffffc0201e7c:	61870713          	addi	a4,a4,1560 # ffffffffc0215490 <npage>
ffffffffc0201e80:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e82:	078a                	slli	a5,a5,0x2
ffffffffc0201e84:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e86:	02e7f563          	bleu	a4,a5,ffffffffc0201eb0 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e8a:	00013717          	auipc	a4,0x13
ffffffffc0201e8e:	67670713          	addi	a4,a4,1654 # ffffffffc0215500 <pages>
ffffffffc0201e92:	6308                	ld	a0,0(a4)
ffffffffc0201e94:	60a2                	ld	ra,8(sp)
ffffffffc0201e96:	6402                	ld	s0,0(sp)
ffffffffc0201e98:	fff80737          	lui	a4,0xfff80
ffffffffc0201e9c:	97ba                	add	a5,a5,a4
ffffffffc0201e9e:	079a                	slli	a5,a5,0x6
ffffffffc0201ea0:	953e                	add	a0,a0,a5
ffffffffc0201ea2:	0141                	addi	sp,sp,16
ffffffffc0201ea4:	8082                	ret
ffffffffc0201ea6:	60a2                	ld	ra,8(sp)
ffffffffc0201ea8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201eaa:	4501                	li	a0,0
}
ffffffffc0201eac:	0141                	addi	sp,sp,16
ffffffffc0201eae:	8082                	ret
ffffffffc0201eb0:	ca7ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>

ffffffffc0201eb4 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201eb4:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201eb6:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201eb8:	e426                	sd	s1,8(sp)
ffffffffc0201eba:	ec06                	sd	ra,24(sp)
ffffffffc0201ebc:	e822                	sd	s0,16(sp)
ffffffffc0201ebe:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201ec0:	dc1ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    if (ptep != NULL) {
ffffffffc0201ec4:	c511                	beqz	a0,ffffffffc0201ed0 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201ec6:	611c                	ld	a5,0(a0)
ffffffffc0201ec8:	842a                	mv	s0,a0
ffffffffc0201eca:	0017f713          	andi	a4,a5,1
ffffffffc0201ece:	e711                	bnez	a4,ffffffffc0201eda <page_remove+0x26>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201ed0:	60e2                	ld	ra,24(sp)
ffffffffc0201ed2:	6442                	ld	s0,16(sp)
ffffffffc0201ed4:	64a2                	ld	s1,8(sp)
ffffffffc0201ed6:	6105                	addi	sp,sp,32
ffffffffc0201ed8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201eda:	00013717          	auipc	a4,0x13
ffffffffc0201ede:	5b670713          	addi	a4,a4,1462 # ffffffffc0215490 <npage>
ffffffffc0201ee2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ee4:	078a                	slli	a5,a5,0x2
ffffffffc0201ee6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ee8:	02e7fe63          	bleu	a4,a5,ffffffffc0201f24 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eec:	00013717          	auipc	a4,0x13
ffffffffc0201ef0:	61470713          	addi	a4,a4,1556 # ffffffffc0215500 <pages>
ffffffffc0201ef4:	6308                	ld	a0,0(a4)
ffffffffc0201ef6:	fff80737          	lui	a4,0xfff80
ffffffffc0201efa:	97ba                	add	a5,a5,a4
ffffffffc0201efc:	079a                	slli	a5,a5,0x6
ffffffffc0201efe:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201f00:	411c                	lw	a5,0(a0)
ffffffffc0201f02:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201f06:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201f08:	cb11                	beqz	a4,ffffffffc0201f1c <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201f0a:	00043023          	sd	zero,0(s0)
// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    // flush_tlb();
    // The flush_tlb flush the entire TLB, is there any better way?
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f0e:	12048073          	sfence.vma	s1
}
ffffffffc0201f12:	60e2                	ld	ra,24(sp)
ffffffffc0201f14:	6442                	ld	s0,16(sp)
ffffffffc0201f16:	64a2                	ld	s1,8(sp)
ffffffffc0201f18:	6105                	addi	sp,sp,32
ffffffffc0201f1a:	8082                	ret
            free_page(page);
ffffffffc0201f1c:	4585                	li	a1,1
ffffffffc0201f1e:	cddff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
ffffffffc0201f22:	b7e5                	j	ffffffffc0201f0a <page_remove+0x56>
ffffffffc0201f24:	c33ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>

ffffffffc0201f28 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f28:	7179                	addi	sp,sp,-48
ffffffffc0201f2a:	e44e                	sd	s3,8(sp)
ffffffffc0201f2c:	89b2                	mv	s3,a2
ffffffffc0201f2e:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f30:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f32:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f34:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201f36:	ec26                	sd	s1,24(sp)
ffffffffc0201f38:	f406                	sd	ra,40(sp)
ffffffffc0201f3a:	e84a                	sd	s2,16(sp)
ffffffffc0201f3c:	e052                	sd	s4,0(sp)
ffffffffc0201f3e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201f40:	d41ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    if (ptep == NULL) {
ffffffffc0201f44:	cd49                	beqz	a0,ffffffffc0201fde <page_insert+0xb6>
    page->ref += 1;
ffffffffc0201f46:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0201f48:	611c                	ld	a5,0(a0)
ffffffffc0201f4a:	892a                	mv	s2,a0
ffffffffc0201f4c:	0016871b          	addiw	a4,a3,1
ffffffffc0201f50:	c018                	sw	a4,0(s0)
ffffffffc0201f52:	0017f713          	andi	a4,a5,1
ffffffffc0201f56:	ef05                	bnez	a4,ffffffffc0201f8e <page_insert+0x66>
ffffffffc0201f58:	00013797          	auipc	a5,0x13
ffffffffc0201f5c:	5a878793          	addi	a5,a5,1448 # ffffffffc0215500 <pages>
ffffffffc0201f60:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0201f62:	8c19                	sub	s0,s0,a4
ffffffffc0201f64:	000806b7          	lui	a3,0x80
ffffffffc0201f68:	8419                	srai	s0,s0,0x6
ffffffffc0201f6a:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f6c:	042a                	slli	s0,s0,0xa
ffffffffc0201f6e:	8c45                	or	s0,s0,s1
ffffffffc0201f70:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201f74:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f78:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0201f7c:	4501                	li	a0,0
}
ffffffffc0201f7e:	70a2                	ld	ra,40(sp)
ffffffffc0201f80:	7402                	ld	s0,32(sp)
ffffffffc0201f82:	64e2                	ld	s1,24(sp)
ffffffffc0201f84:	6942                	ld	s2,16(sp)
ffffffffc0201f86:	69a2                	ld	s3,8(sp)
ffffffffc0201f88:	6a02                	ld	s4,0(sp)
ffffffffc0201f8a:	6145                	addi	sp,sp,48
ffffffffc0201f8c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201f8e:	00013717          	auipc	a4,0x13
ffffffffc0201f92:	50270713          	addi	a4,a4,1282 # ffffffffc0215490 <npage>
ffffffffc0201f96:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f98:	078a                	slli	a5,a5,0x2
ffffffffc0201f9a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f9c:	04e7f363          	bleu	a4,a5,ffffffffc0201fe2 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fa0:	00013a17          	auipc	s4,0x13
ffffffffc0201fa4:	560a0a13          	addi	s4,s4,1376 # ffffffffc0215500 <pages>
ffffffffc0201fa8:	000a3703          	ld	a4,0(s4)
ffffffffc0201fac:	fff80537          	lui	a0,0xfff80
ffffffffc0201fb0:	953e                	add	a0,a0,a5
ffffffffc0201fb2:	051a                	slli	a0,a0,0x6
ffffffffc0201fb4:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0201fb6:	00a40a63          	beq	s0,a0,ffffffffc0201fca <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0201fba:	411c                	lw	a5,0(a0)
ffffffffc0201fbc:	fff7869b          	addiw	a3,a5,-1
ffffffffc0201fc0:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0201fc2:	c691                	beqz	a3,ffffffffc0201fce <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fc4:	12098073          	sfence.vma	s3
ffffffffc0201fc8:	bf69                	j	ffffffffc0201f62 <page_insert+0x3a>
ffffffffc0201fca:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201fcc:	bf59                	j	ffffffffc0201f62 <page_insert+0x3a>
            free_page(page);
ffffffffc0201fce:	4585                	li	a1,1
ffffffffc0201fd0:	c2bff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
ffffffffc0201fd4:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fd8:	12098073          	sfence.vma	s3
ffffffffc0201fdc:	b759                	j	ffffffffc0201f62 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0201fde:	5571                	li	a0,-4
ffffffffc0201fe0:	bf79                	j	ffffffffc0201f7e <page_insert+0x56>
ffffffffc0201fe2:	b75ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>

ffffffffc0201fe6 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201fe6:	00004797          	auipc	a5,0x4
ffffffffc0201fea:	aa278793          	addi	a5,a5,-1374 # ffffffffc0205a88 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201fee:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201ff0:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201ff2:	00004517          	auipc	a0,0x4
ffffffffc0201ff6:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0205bf0 <default_pmm_manager+0x168>
void pmm_init(void) {
ffffffffc0201ffa:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201ffc:	00013717          	auipc	a4,0x13
ffffffffc0202000:	4ef73623          	sd	a5,1260(a4) # ffffffffc02154e8 <pmm_manager>
void pmm_init(void) {
ffffffffc0202004:	e0a2                	sd	s0,64(sp)
ffffffffc0202006:	fc26                	sd	s1,56(sp)
ffffffffc0202008:	f84a                	sd	s2,48(sp)
ffffffffc020200a:	f44e                	sd	s3,40(sp)
ffffffffc020200c:	f052                	sd	s4,32(sp)
ffffffffc020200e:	ec56                	sd	s5,24(sp)
ffffffffc0202010:	e85a                	sd	s6,16(sp)
ffffffffc0202012:	e45e                	sd	s7,8(sp)
ffffffffc0202014:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202016:	00013417          	auipc	s0,0x13
ffffffffc020201a:	4d240413          	addi	s0,s0,1234 # ffffffffc02154e8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020201e:	970fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202022:	601c                	ld	a5,0(s0)
ffffffffc0202024:	00013497          	auipc	s1,0x13
ffffffffc0202028:	46c48493          	addi	s1,s1,1132 # ffffffffc0215490 <npage>
ffffffffc020202c:	00013917          	auipc	s2,0x13
ffffffffc0202030:	4d490913          	addi	s2,s2,1236 # ffffffffc0215500 <pages>
ffffffffc0202034:	679c                	ld	a5,8(a5)
ffffffffc0202036:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202038:	57f5                	li	a5,-3
ffffffffc020203a:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020203c:	00004517          	auipc	a0,0x4
ffffffffc0202040:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0205c08 <default_pmm_manager+0x180>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202044:	00013717          	auipc	a4,0x13
ffffffffc0202048:	4af73623          	sd	a5,1196(a4) # ffffffffc02154f0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020204c:	942fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202050:	46c5                	li	a3,17
ffffffffc0202052:	06ee                	slli	a3,a3,0x1b
ffffffffc0202054:	40100613          	li	a2,1025
ffffffffc0202058:	16fd                	addi	a3,a3,-1
ffffffffc020205a:	0656                	slli	a2,a2,0x15
ffffffffc020205c:	07e005b7          	lui	a1,0x7e00
ffffffffc0202060:	00004517          	auipc	a0,0x4
ffffffffc0202064:	bc050513          	addi	a0,a0,-1088 # ffffffffc0205c20 <default_pmm_manager+0x198>
ffffffffc0202068:	926fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020206c:	777d                	lui	a4,0xfffff
ffffffffc020206e:	00014797          	auipc	a5,0x14
ffffffffc0202072:	58978793          	addi	a5,a5,1417 # ffffffffc02165f7 <end+0xfff>
ffffffffc0202076:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202078:	00088737          	lui	a4,0x88
ffffffffc020207c:	00013697          	auipc	a3,0x13
ffffffffc0202080:	40e6ba23          	sd	a4,1044(a3) # ffffffffc0215490 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202084:	00013717          	auipc	a4,0x13
ffffffffc0202088:	46f73e23          	sd	a5,1148(a4) # ffffffffc0215500 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020208c:	4701                	li	a4,0
ffffffffc020208e:	4685                	li	a3,1
ffffffffc0202090:	fff80837          	lui	a6,0xfff80
ffffffffc0202094:	a019                	j	ffffffffc020209a <pmm_init+0xb4>
ffffffffc0202096:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc020209a:	00671613          	slli	a2,a4,0x6
ffffffffc020209e:	97b2                	add	a5,a5,a2
ffffffffc02020a0:	07a1                	addi	a5,a5,8
ffffffffc02020a2:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02020a6:	6090                	ld	a2,0(s1)
ffffffffc02020a8:	0705                	addi	a4,a4,1
ffffffffc02020aa:	010607b3          	add	a5,a2,a6
ffffffffc02020ae:	fef764e3          	bltu	a4,a5,ffffffffc0202096 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020b2:	00093503          	ld	a0,0(s2)
ffffffffc02020b6:	fe0007b7          	lui	a5,0xfe000
ffffffffc02020ba:	00661693          	slli	a3,a2,0x6
ffffffffc02020be:	97aa                	add	a5,a5,a0
ffffffffc02020c0:	96be                	add	a3,a3,a5
ffffffffc02020c2:	c02007b7          	lui	a5,0xc0200
ffffffffc02020c6:	7af6ed63          	bltu	a3,a5,ffffffffc0202880 <pmm_init+0x89a>
ffffffffc02020ca:	00013997          	auipc	s3,0x13
ffffffffc02020ce:	42698993          	addi	s3,s3,1062 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02020d2:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02020d6:	47c5                	li	a5,17
ffffffffc02020d8:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02020da:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02020dc:	02f6f763          	bleu	a5,a3,ffffffffc020210a <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020e0:	6585                	lui	a1,0x1
ffffffffc02020e2:	15fd                	addi	a1,a1,-1
ffffffffc02020e4:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02020e6:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020ea:	48c77a63          	bleu	a2,a4,ffffffffc020257e <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc02020ee:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f0:	75fd                	lui	a1,0xfffff
ffffffffc02020f2:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc02020f4:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc02020f6:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f8:	40d786b3          	sub	a3,a5,a3
ffffffffc02020fc:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc02020fe:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202102:	953a                	add	a0,a0,a4
ffffffffc0202104:	9602                	jalr	a2
ffffffffc0202106:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc020210a:	00004517          	auipc	a0,0x4
ffffffffc020210e:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0205c48 <default_pmm_manager+0x1c0>
ffffffffc0202112:	87cfe0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202116:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202118:	00013417          	auipc	s0,0x13
ffffffffc020211c:	37040413          	addi	s0,s0,880 # ffffffffc0215488 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202120:	7b9c                	ld	a5,48(a5)
ffffffffc0202122:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202124:	00004517          	auipc	a0,0x4
ffffffffc0202128:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0205c60 <default_pmm_manager+0x1d8>
ffffffffc020212c:	862fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202130:	00007697          	auipc	a3,0x7
ffffffffc0202134:	ed068693          	addi	a3,a3,-304 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0202138:	00013797          	auipc	a5,0x13
ffffffffc020213c:	34d7b823          	sd	a3,848(a5) # ffffffffc0215488 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202140:	c02007b7          	lui	a5,0xc0200
ffffffffc0202144:	10f6eae3          	bltu	a3,a5,ffffffffc0202a58 <pmm_init+0xa72>
ffffffffc0202148:	0009b783          	ld	a5,0(s3)
ffffffffc020214c:	8e9d                	sub	a3,a3,a5
ffffffffc020214e:	00013797          	auipc	a5,0x13
ffffffffc0202152:	3ad7b523          	sd	a3,938(a5) # ffffffffc02154f8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202156:	aebff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020215a:	6098                	ld	a4,0(s1)
ffffffffc020215c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202160:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202162:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202164:	0ce7eae3          	bltu	a5,a4,ffffffffc0202a38 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202168:	6008                	ld	a0,0(s0)
ffffffffc020216a:	44050463          	beqz	a0,ffffffffc02025b2 <pmm_init+0x5cc>
ffffffffc020216e:	6785                	lui	a5,0x1
ffffffffc0202170:	17fd                	addi	a5,a5,-1
ffffffffc0202172:	8fe9                	and	a5,a5,a0
ffffffffc0202174:	2781                	sext.w	a5,a5
ffffffffc0202176:	42079e63          	bnez	a5,ffffffffc02025b2 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020217a:	4601                	li	a2,0
ffffffffc020217c:	4581                	li	a1,0
ffffffffc020217e:	cd5ff0ef          	jal	ra,ffffffffc0201e52 <get_page>
ffffffffc0202182:	78051b63          	bnez	a0,ffffffffc0202918 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202186:	4505                	li	a0,1
ffffffffc0202188:	9ebff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc020218c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020218e:	6008                	ld	a0,0(s0)
ffffffffc0202190:	4681                	li	a3,0
ffffffffc0202192:	4601                	li	a2,0
ffffffffc0202194:	85d6                	mv	a1,s5
ffffffffc0202196:	d93ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc020219a:	7a051f63          	bnez	a0,ffffffffc0202958 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc020219e:	6008                	ld	a0,0(s0)
ffffffffc02021a0:	4601                	li	a2,0
ffffffffc02021a2:	4581                	li	a1,0
ffffffffc02021a4:	addff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc02021a8:	78050863          	beqz	a0,ffffffffc0202938 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02021ac:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02021ae:	0017f713          	andi	a4,a5,1
ffffffffc02021b2:	3e070463          	beqz	a4,ffffffffc020259a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02021b6:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021b8:	078a                	slli	a5,a5,0x2
ffffffffc02021ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021bc:	3ce7f163          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02021c0:	00093683          	ld	a3,0(s2)
ffffffffc02021c4:	fff80637          	lui	a2,0xfff80
ffffffffc02021c8:	97b2                	add	a5,a5,a2
ffffffffc02021ca:	079a                	slli	a5,a5,0x6
ffffffffc02021cc:	97b6                	add	a5,a5,a3
ffffffffc02021ce:	72fa9563          	bne	s5,a5,ffffffffc02028f8 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc02021d2:	000aab83          	lw	s7,0(s5)
ffffffffc02021d6:	4785                	li	a5,1
ffffffffc02021d8:	70fb9063          	bne	s7,a5,ffffffffc02028d8 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02021dc:	6008                	ld	a0,0(s0)
ffffffffc02021de:	76fd                	lui	a3,0xfffff
ffffffffc02021e0:	611c                	ld	a5,0(a0)
ffffffffc02021e2:	078a                	slli	a5,a5,0x2
ffffffffc02021e4:	8ff5                	and	a5,a5,a3
ffffffffc02021e6:	00c7d613          	srli	a2,a5,0xc
ffffffffc02021ea:	66e67e63          	bleu	a4,a2,ffffffffc0202866 <pmm_init+0x880>
ffffffffc02021ee:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02021f2:	97e2                	add	a5,a5,s8
ffffffffc02021f4:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc02021f8:	0b0a                	slli	s6,s6,0x2
ffffffffc02021fa:	00db7b33          	and	s6,s6,a3
ffffffffc02021fe:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202202:	56e7f863          	bleu	a4,a5,ffffffffc0202772 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202206:	4601                	li	a2,0
ffffffffc0202208:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020220a:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020220c:	a75ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202210:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202212:	55651063          	bne	a0,s6,ffffffffc0202752 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202216:	4505                	li	a0,1
ffffffffc0202218:	95bff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc020221c:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020221e:	6008                	ld	a0,0(s0)
ffffffffc0202220:	46d1                	li	a3,20
ffffffffc0202222:	6605                	lui	a2,0x1
ffffffffc0202224:	85da                	mv	a1,s6
ffffffffc0202226:	d03ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc020222a:	50051463          	bnez	a0,ffffffffc0202732 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020222e:	6008                	ld	a0,0(s0)
ffffffffc0202230:	4601                	li	a2,0
ffffffffc0202232:	6585                	lui	a1,0x1
ffffffffc0202234:	a4dff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0202238:	4c050d63          	beqz	a0,ffffffffc0202712 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020223c:	611c                	ld	a5,0(a0)
ffffffffc020223e:	0107f713          	andi	a4,a5,16
ffffffffc0202242:	4a070863          	beqz	a4,ffffffffc02026f2 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202246:	8b91                	andi	a5,a5,4
ffffffffc0202248:	48078563          	beqz	a5,ffffffffc02026d2 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020224c:	6008                	ld	a0,0(s0)
ffffffffc020224e:	611c                	ld	a5,0(a0)
ffffffffc0202250:	8bc1                	andi	a5,a5,16
ffffffffc0202252:	46078063          	beqz	a5,ffffffffc02026b2 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202256:	000b2783          	lw	a5,0(s6)
ffffffffc020225a:	43779c63          	bne	a5,s7,ffffffffc0202692 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020225e:	4681                	li	a3,0
ffffffffc0202260:	6605                	lui	a2,0x1
ffffffffc0202262:	85d6                	mv	a1,s5
ffffffffc0202264:	cc5ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc0202268:	40051563          	bnez	a0,ffffffffc0202672 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc020226c:	000aa703          	lw	a4,0(s5)
ffffffffc0202270:	4789                	li	a5,2
ffffffffc0202272:	3ef71063          	bne	a4,a5,ffffffffc0202652 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0202276:	000b2783          	lw	a5,0(s6)
ffffffffc020227a:	3a079c63          	bnez	a5,ffffffffc0202632 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020227e:	6008                	ld	a0,0(s0)
ffffffffc0202280:	4601                	li	a2,0
ffffffffc0202282:	6585                	lui	a1,0x1
ffffffffc0202284:	9fdff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0202288:	38050563          	beqz	a0,ffffffffc0202612 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc020228c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020228e:	00177793          	andi	a5,a4,1
ffffffffc0202292:	30078463          	beqz	a5,ffffffffc020259a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202296:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202298:	00271793          	slli	a5,a4,0x2
ffffffffc020229c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020229e:	2ed7f063          	bleu	a3,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02022a2:	00093683          	ld	a3,0(s2)
ffffffffc02022a6:	fff80637          	lui	a2,0xfff80
ffffffffc02022aa:	97b2                	add	a5,a5,a2
ffffffffc02022ac:	079a                	slli	a5,a5,0x6
ffffffffc02022ae:	97b6                	add	a5,a5,a3
ffffffffc02022b0:	32fa9163          	bne	s5,a5,ffffffffc02025d2 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02022b4:	8b41                	andi	a4,a4,16
ffffffffc02022b6:	70071163          	bnez	a4,ffffffffc02029b8 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02022ba:	6008                	ld	a0,0(s0)
ffffffffc02022bc:	4581                	li	a1,0
ffffffffc02022be:	bf7ff0ef          	jal	ra,ffffffffc0201eb4 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02022c2:	000aa703          	lw	a4,0(s5)
ffffffffc02022c6:	4785                	li	a5,1
ffffffffc02022c8:	6cf71863          	bne	a4,a5,ffffffffc0202998 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02022cc:	000b2783          	lw	a5,0(s6)
ffffffffc02022d0:	6a079463          	bnez	a5,ffffffffc0202978 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02022d4:	6008                	ld	a0,0(s0)
ffffffffc02022d6:	6585                	lui	a1,0x1
ffffffffc02022d8:	bddff0ef          	jal	ra,ffffffffc0201eb4 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02022dc:	000aa783          	lw	a5,0(s5)
ffffffffc02022e0:	50079363          	bnez	a5,ffffffffc02027e6 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc02022e4:	000b2783          	lw	a5,0(s6)
ffffffffc02022e8:	4c079f63          	bnez	a5,ffffffffc02027c6 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02022ec:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02022f0:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02022f2:	000ab783          	ld	a5,0(s5)
ffffffffc02022f6:	078a                	slli	a5,a5,0x2
ffffffffc02022f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02022fa:	28c7f263          	bleu	a2,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02022fe:	fff80737          	lui	a4,0xfff80
ffffffffc0202302:	00093503          	ld	a0,0(s2)
ffffffffc0202306:	97ba                	add	a5,a5,a4
ffffffffc0202308:	079a                	slli	a5,a5,0x6
ffffffffc020230a:	00f50733          	add	a4,a0,a5
ffffffffc020230e:	4314                	lw	a3,0(a4)
ffffffffc0202310:	4705                	li	a4,1
ffffffffc0202312:	48e69a63          	bne	a3,a4,ffffffffc02027a6 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202316:	8799                	srai	a5,a5,0x6
ffffffffc0202318:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020231c:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020231e:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202320:	8331                	srli	a4,a4,0xc
ffffffffc0202322:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202324:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202326:	46c77363          	bleu	a2,a4,ffffffffc020278c <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020232a:	0009b683          	ld	a3,0(s3)
ffffffffc020232e:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202330:	639c                	ld	a5,0(a5)
ffffffffc0202332:	078a                	slli	a5,a5,0x2
ffffffffc0202334:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202336:	24c7f463          	bleu	a2,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020233a:	416787b3          	sub	a5,a5,s6
ffffffffc020233e:	079a                	slli	a5,a5,0x6
ffffffffc0202340:	953e                	add	a0,a0,a5
ffffffffc0202342:	4585                	li	a1,1
ffffffffc0202344:	8b7ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202348:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020234c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020234e:	078a                	slli	a5,a5,0x2
ffffffffc0202350:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202352:	22e7f663          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202356:	00093503          	ld	a0,0(s2)
ffffffffc020235a:	416787b3          	sub	a5,a5,s6
ffffffffc020235e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202360:	953e                	add	a0,a0,a5
ffffffffc0202362:	4585                	li	a1,1
ffffffffc0202364:	897ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202368:	601c                	ld	a5,0(s0)
ffffffffc020236a:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc020236e:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202372:	8cfff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0202376:	68aa1163          	bne	s4,a0,ffffffffc02029f8 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020237a:	00004517          	auipc	a0,0x4
ffffffffc020237e:	bf650513          	addi	a0,a0,-1034 # ffffffffc0205f70 <default_pmm_manager+0x4e8>
ffffffffc0202382:	e0dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202386:	8bbff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020238a:	6098                	ld	a4,0(s1)
ffffffffc020238c:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0202390:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202392:	00c71693          	slli	a3,a4,0xc
ffffffffc0202396:	18d7f563          	bleu	a3,a5,ffffffffc0202520 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020239a:	83b1                	srli	a5,a5,0xc
ffffffffc020239c:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020239e:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023a2:	1ae7f163          	bleu	a4,a5,ffffffffc0202544 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023a6:	7bfd                	lui	s7,0xfffff
ffffffffc02023a8:	6b05                	lui	s6,0x1
ffffffffc02023aa:	a029                	j	ffffffffc02023b4 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02023ac:	00cad713          	srli	a4,s5,0xc
ffffffffc02023b0:	18f77a63          	bleu	a5,a4,ffffffffc0202544 <pmm_init+0x55e>
ffffffffc02023b4:	0009b583          	ld	a1,0(s3)
ffffffffc02023b8:	4601                	li	a2,0
ffffffffc02023ba:	95d6                	add	a1,a1,s5
ffffffffc02023bc:	8c5ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc02023c0:	16050263          	beqz	a0,ffffffffc0202524 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02023c4:	611c                	ld	a5,0(a0)
ffffffffc02023c6:	078a                	slli	a5,a5,0x2
ffffffffc02023c8:	0177f7b3          	and	a5,a5,s7
ffffffffc02023cc:	19579963          	bne	a5,s5,ffffffffc020255e <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02023d0:	609c                	ld	a5,0(s1)
ffffffffc02023d2:	9ada                	add	s5,s5,s6
ffffffffc02023d4:	6008                	ld	a0,0(s0)
ffffffffc02023d6:	00c79713          	slli	a4,a5,0xc
ffffffffc02023da:	fceae9e3          	bltu	s5,a4,ffffffffc02023ac <pmm_init+0x3c6>
    }

    assert(boot_pgdir[0] == 0);
ffffffffc02023de:	611c                	ld	a5,0(a0)
ffffffffc02023e0:	62079c63          	bnez	a5,ffffffffc0202a18 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc02023e4:	4505                	li	a0,1
ffffffffc02023e6:	f8cff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc02023ea:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02023ec:	6008                	ld	a0,0(s0)
ffffffffc02023ee:	4699                	li	a3,6
ffffffffc02023f0:	10000613          	li	a2,256
ffffffffc02023f4:	85d6                	mv	a1,s5
ffffffffc02023f6:	b33ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc02023fa:	1e051c63          	bnez	a0,ffffffffc02025f2 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc02023fe:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202402:	4785                	li	a5,1
ffffffffc0202404:	44f71163          	bne	a4,a5,ffffffffc0202846 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202408:	6008                	ld	a0,0(s0)
ffffffffc020240a:	6b05                	lui	s6,0x1
ffffffffc020240c:	4699                	li	a3,6
ffffffffc020240e:	100b0613          	addi	a2,s6,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0202412:	85d6                	mv	a1,s5
ffffffffc0202414:	b15ff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc0202418:	40051763          	bnez	a0,ffffffffc0202826 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc020241c:	000aa703          	lw	a4,0(s5)
ffffffffc0202420:	4789                	li	a5,2
ffffffffc0202422:	3ef71263          	bne	a4,a5,ffffffffc0202806 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202426:	00004597          	auipc	a1,0x4
ffffffffc020242a:	c8258593          	addi	a1,a1,-894 # ffffffffc02060a8 <default_pmm_manager+0x620>
ffffffffc020242e:	10000513          	li	a0,256
ffffffffc0202432:	065020ef          	jal	ra,ffffffffc0204c96 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202436:	100b0593          	addi	a1,s6,256
ffffffffc020243a:	10000513          	li	a0,256
ffffffffc020243e:	06b020ef          	jal	ra,ffffffffc0204ca8 <strcmp>
ffffffffc0202442:	44051b63          	bnez	a0,ffffffffc0202898 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202446:	00093683          	ld	a3,0(s2)
ffffffffc020244a:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc020244e:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202450:	40da86b3          	sub	a3,s5,a3
ffffffffc0202454:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202456:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202458:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc020245a:	00cb5b13          	srli	s6,s6,0xc
ffffffffc020245e:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202462:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202464:	10f77f63          	bleu	a5,a4,ffffffffc0202582 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202468:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020246c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202470:	96be                	add	a3,a3,a5
ffffffffc0202472:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fde9b08>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202476:	7dc020ef          	jal	ra,ffffffffc0204c52 <strlen>
ffffffffc020247a:	54051f63          	bnez	a0,ffffffffc02029d8 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020247e:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202482:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202484:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fde9a08>
ffffffffc0202488:	068a                	slli	a3,a3,0x2
ffffffffc020248a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020248c:	0ef6f963          	bleu	a5,a3,ffffffffc020257e <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202490:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202494:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202496:	0efb7663          	bleu	a5,s6,ffffffffc0202582 <pmm_init+0x59c>
ffffffffc020249a:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc020249e:	4585                	li	a1,1
ffffffffc02024a0:	8556                	mv	a0,s5
ffffffffc02024a2:	99b6                	add	s3,s3,a3
ffffffffc02024a4:	f56ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024a8:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc02024ac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024ae:	078a                	slli	a5,a5,0x2
ffffffffc02024b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024b2:	0ce7f663          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02024b6:	00093503          	ld	a0,0(s2)
ffffffffc02024ba:	fff809b7          	lui	s3,0xfff80
ffffffffc02024be:	97ce                	add	a5,a5,s3
ffffffffc02024c0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02024c2:	953e                	add	a0,a0,a5
ffffffffc02024c4:	4585                	li	a1,1
ffffffffc02024c6:	f34ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02024ca:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc02024ce:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02024d0:	078a                	slli	a5,a5,0x2
ffffffffc02024d2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024d4:	0ae7f563          	bleu	a4,a5,ffffffffc020257e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02024d8:	00093503          	ld	a0,0(s2)
ffffffffc02024dc:	97ce                	add	a5,a5,s3
ffffffffc02024de:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02024e0:	953e                	add	a0,a0,a5
ffffffffc02024e2:	4585                	li	a1,1
ffffffffc02024e4:	f16ff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02024e8:	601c                	ld	a5,0(s0)
ffffffffc02024ea:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc02024ee:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02024f2:	f4eff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc02024f6:	3caa1163          	bne	s4,a0,ffffffffc02028b8 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02024fa:	00004517          	auipc	a0,0x4
ffffffffc02024fe:	c2650513          	addi	a0,a0,-986 # ffffffffc0206120 <default_pmm_manager+0x698>
ffffffffc0202502:	c8dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202506:	6406                	ld	s0,64(sp)
ffffffffc0202508:	60a6                	ld	ra,72(sp)
ffffffffc020250a:	74e2                	ld	s1,56(sp)
ffffffffc020250c:	7942                	ld	s2,48(sp)
ffffffffc020250e:	79a2                	ld	s3,40(sp)
ffffffffc0202510:	7a02                	ld	s4,32(sp)
ffffffffc0202512:	6ae2                	ld	s5,24(sp)
ffffffffc0202514:	6b42                	ld	s6,16(sp)
ffffffffc0202516:	6ba2                	ld	s7,8(sp)
ffffffffc0202518:	6c02                	ld	s8,0(sp)
ffffffffc020251a:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc020251c:	c3aff06f          	j	ffffffffc0201956 <kmalloc_init>
ffffffffc0202520:	6008                	ld	a0,0(s0)
ffffffffc0202522:	bd75                	j	ffffffffc02023de <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202524:	00004697          	auipc	a3,0x4
ffffffffc0202528:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0205f90 <default_pmm_manager+0x508>
ffffffffc020252c:	00003617          	auipc	a2,0x3
ffffffffc0202530:	1c460613          	addi	a2,a2,452 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202534:	19d00593          	li	a1,413
ffffffffc0202538:	00003517          	auipc	a0,0x3
ffffffffc020253c:	69050513          	addi	a0,a0,1680 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202540:	f11fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0202544:	86d6                	mv	a3,s5
ffffffffc0202546:	00003617          	auipc	a2,0x3
ffffffffc020254a:	59260613          	addi	a2,a2,1426 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc020254e:	19d00593          	li	a1,413
ffffffffc0202552:	00003517          	auipc	a0,0x3
ffffffffc0202556:	67650513          	addi	a0,a0,1654 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020255a:	ef7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020255e:	00004697          	auipc	a3,0x4
ffffffffc0202562:	a7268693          	addi	a3,a3,-1422 # ffffffffc0205fd0 <default_pmm_manager+0x548>
ffffffffc0202566:	00003617          	auipc	a2,0x3
ffffffffc020256a:	18a60613          	addi	a2,a2,394 # ffffffffc02056f0 <commands+0x870>
ffffffffc020256e:	19e00593          	li	a1,414
ffffffffc0202572:	00003517          	auipc	a0,0x3
ffffffffc0202576:	65650513          	addi	a0,a0,1622 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020257a:	ed7fd0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020257e:	dd8ff0ef          	jal	ra,ffffffffc0201b56 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202582:	00003617          	auipc	a2,0x3
ffffffffc0202586:	55660613          	addi	a2,a2,1366 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc020258a:	06900593          	li	a1,105
ffffffffc020258e:	00003517          	auipc	a0,0x3
ffffffffc0202592:	57250513          	addi	a0,a0,1394 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0202596:	ebbfd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020259a:	00003617          	auipc	a2,0x3
ffffffffc020259e:	7c660613          	addi	a2,a2,1990 # ffffffffc0205d60 <default_pmm_manager+0x2d8>
ffffffffc02025a2:	07400593          	li	a1,116
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	55a50513          	addi	a0,a0,1370 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc02025ae:	ea3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	6ee68693          	addi	a3,a3,1774 # ffffffffc0205ca0 <default_pmm_manager+0x218>
ffffffffc02025ba:	00003617          	auipc	a2,0x3
ffffffffc02025be:	13660613          	addi	a2,a2,310 # ffffffffc02056f0 <commands+0x870>
ffffffffc02025c2:	16100593          	li	a1,353
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	60250513          	addi	a0,a0,1538 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02025ce:	e83fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	7b668693          	addi	a3,a3,1974 # ffffffffc0205d88 <default_pmm_manager+0x300>
ffffffffc02025da:	00003617          	auipc	a2,0x3
ffffffffc02025de:	11660613          	addi	a2,a2,278 # ffffffffc02056f0 <commands+0x870>
ffffffffc02025e2:	17d00593          	li	a1,381
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	5e250513          	addi	a0,a0,1506 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02025ee:	e63fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025f2:	00004697          	auipc	a3,0x4
ffffffffc02025f6:	a0e68693          	addi	a3,a3,-1522 # ffffffffc0206000 <default_pmm_manager+0x578>
ffffffffc02025fa:	00003617          	auipc	a2,0x3
ffffffffc02025fe:	0f660613          	addi	a2,a2,246 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202602:	1a500593          	li	a1,421
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	5c250513          	addi	a0,a0,1474 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020260e:	e43fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202612:	00004697          	auipc	a3,0x4
ffffffffc0202616:	80668693          	addi	a3,a3,-2042 # ffffffffc0205e18 <default_pmm_manager+0x390>
ffffffffc020261a:	00003617          	auipc	a2,0x3
ffffffffc020261e:	0d660613          	addi	a2,a2,214 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202622:	17c00593          	li	a1,380
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	5a250513          	addi	a0,a0,1442 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020262e:	e23fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202632:	00004697          	auipc	a3,0x4
ffffffffc0202636:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0205ee0 <default_pmm_manager+0x458>
ffffffffc020263a:	00003617          	auipc	a2,0x3
ffffffffc020263e:	0b660613          	addi	a2,a2,182 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202642:	17b00593          	li	a1,379
ffffffffc0202646:	00003517          	auipc	a0,0x3
ffffffffc020264a:	58250513          	addi	a0,a0,1410 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020264e:	e03fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202652:	00004697          	auipc	a3,0x4
ffffffffc0202656:	87668693          	addi	a3,a3,-1930 # ffffffffc0205ec8 <default_pmm_manager+0x440>
ffffffffc020265a:	00003617          	auipc	a2,0x3
ffffffffc020265e:	09660613          	addi	a2,a2,150 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202662:	17a00593          	li	a1,378
ffffffffc0202666:	00003517          	auipc	a0,0x3
ffffffffc020266a:	56250513          	addi	a0,a0,1378 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020266e:	de3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202672:	00004697          	auipc	a3,0x4
ffffffffc0202676:	82668693          	addi	a3,a3,-2010 # ffffffffc0205e98 <default_pmm_manager+0x410>
ffffffffc020267a:	00003617          	auipc	a2,0x3
ffffffffc020267e:	07660613          	addi	a2,a2,118 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202682:	17900593          	li	a1,377
ffffffffc0202686:	00003517          	auipc	a0,0x3
ffffffffc020268a:	54250513          	addi	a0,a0,1346 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020268e:	dc3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202692:	00003697          	auipc	a3,0x3
ffffffffc0202696:	7ee68693          	addi	a3,a3,2030 # ffffffffc0205e80 <default_pmm_manager+0x3f8>
ffffffffc020269a:	00003617          	auipc	a2,0x3
ffffffffc020269e:	05660613          	addi	a2,a2,86 # ffffffffc02056f0 <commands+0x870>
ffffffffc02026a2:	17700593          	li	a1,375
ffffffffc02026a6:	00003517          	auipc	a0,0x3
ffffffffc02026aa:	52250513          	addi	a0,a0,1314 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02026ae:	da3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02026b2:	00003697          	auipc	a3,0x3
ffffffffc02026b6:	7b668693          	addi	a3,a3,1974 # ffffffffc0205e68 <default_pmm_manager+0x3e0>
ffffffffc02026ba:	00003617          	auipc	a2,0x3
ffffffffc02026be:	03660613          	addi	a2,a2,54 # ffffffffc02056f0 <commands+0x870>
ffffffffc02026c2:	17600593          	li	a1,374
ffffffffc02026c6:	00003517          	auipc	a0,0x3
ffffffffc02026ca:	50250513          	addi	a0,a0,1282 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02026ce:	d83fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02026d2:	00003697          	auipc	a3,0x3
ffffffffc02026d6:	78668693          	addi	a3,a3,1926 # ffffffffc0205e58 <default_pmm_manager+0x3d0>
ffffffffc02026da:	00003617          	auipc	a2,0x3
ffffffffc02026de:	01660613          	addi	a2,a2,22 # ffffffffc02056f0 <commands+0x870>
ffffffffc02026e2:	17500593          	li	a1,373
ffffffffc02026e6:	00003517          	auipc	a0,0x3
ffffffffc02026ea:	4e250513          	addi	a0,a0,1250 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02026ee:	d63fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02026f2:	00003697          	auipc	a3,0x3
ffffffffc02026f6:	75668693          	addi	a3,a3,1878 # ffffffffc0205e48 <default_pmm_manager+0x3c0>
ffffffffc02026fa:	00003617          	auipc	a2,0x3
ffffffffc02026fe:	ff660613          	addi	a2,a2,-10 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202702:	17400593          	li	a1,372
ffffffffc0202706:	00003517          	auipc	a0,0x3
ffffffffc020270a:	4c250513          	addi	a0,a0,1218 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020270e:	d43fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202712:	00003697          	auipc	a3,0x3
ffffffffc0202716:	70668693          	addi	a3,a3,1798 # ffffffffc0205e18 <default_pmm_manager+0x390>
ffffffffc020271a:	00003617          	auipc	a2,0x3
ffffffffc020271e:	fd660613          	addi	a2,a2,-42 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202722:	17300593          	li	a1,371
ffffffffc0202726:	00003517          	auipc	a0,0x3
ffffffffc020272a:	4a250513          	addi	a0,a0,1186 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020272e:	d23fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202732:	00003697          	auipc	a3,0x3
ffffffffc0202736:	6ae68693          	addi	a3,a3,1710 # ffffffffc0205de0 <default_pmm_manager+0x358>
ffffffffc020273a:	00003617          	auipc	a2,0x3
ffffffffc020273e:	fb660613          	addi	a2,a2,-74 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202742:	17200593          	li	a1,370
ffffffffc0202746:	00003517          	auipc	a0,0x3
ffffffffc020274a:	48250513          	addi	a0,a0,1154 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020274e:	d03fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202752:	00003697          	auipc	a3,0x3
ffffffffc0202756:	66668693          	addi	a3,a3,1638 # ffffffffc0205db8 <default_pmm_manager+0x330>
ffffffffc020275a:	00003617          	auipc	a2,0x3
ffffffffc020275e:	f9660613          	addi	a2,a2,-106 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202762:	16f00593          	li	a1,367
ffffffffc0202766:	00003517          	auipc	a0,0x3
ffffffffc020276a:	46250513          	addi	a0,a0,1122 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020276e:	ce3fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202772:	86da                	mv	a3,s6
ffffffffc0202774:	00003617          	auipc	a2,0x3
ffffffffc0202778:	36460613          	addi	a2,a2,868 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc020277c:	16e00593          	li	a1,366
ffffffffc0202780:	00003517          	auipc	a0,0x3
ffffffffc0202784:	44850513          	addi	a0,a0,1096 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202788:	cc9fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc020278c:	86be                	mv	a3,a5
ffffffffc020278e:	00003617          	auipc	a2,0x3
ffffffffc0202792:	34a60613          	addi	a2,a2,842 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0202796:	06900593          	li	a1,105
ffffffffc020279a:	00003517          	auipc	a0,0x3
ffffffffc020279e:	36650513          	addi	a0,a0,870 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc02027a2:	caffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02027a6:	00003697          	auipc	a3,0x3
ffffffffc02027aa:	78268693          	addi	a3,a3,1922 # ffffffffc0205f28 <default_pmm_manager+0x4a0>
ffffffffc02027ae:	00003617          	auipc	a2,0x3
ffffffffc02027b2:	f4260613          	addi	a2,a2,-190 # ffffffffc02056f0 <commands+0x870>
ffffffffc02027b6:	18800593          	li	a1,392
ffffffffc02027ba:	00003517          	auipc	a0,0x3
ffffffffc02027be:	40e50513          	addi	a0,a0,1038 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02027c2:	c8ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02027c6:	00003697          	auipc	a3,0x3
ffffffffc02027ca:	71a68693          	addi	a3,a3,1818 # ffffffffc0205ee0 <default_pmm_manager+0x458>
ffffffffc02027ce:	00003617          	auipc	a2,0x3
ffffffffc02027d2:	f2260613          	addi	a2,a2,-222 # ffffffffc02056f0 <commands+0x870>
ffffffffc02027d6:	18600593          	li	a1,390
ffffffffc02027da:	00003517          	auipc	a0,0x3
ffffffffc02027de:	3ee50513          	addi	a0,a0,1006 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02027e2:	c6ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02027e6:	00003697          	auipc	a3,0x3
ffffffffc02027ea:	72a68693          	addi	a3,a3,1834 # ffffffffc0205f10 <default_pmm_manager+0x488>
ffffffffc02027ee:	00003617          	auipc	a2,0x3
ffffffffc02027f2:	f0260613          	addi	a2,a2,-254 # ffffffffc02056f0 <commands+0x870>
ffffffffc02027f6:	18500593          	li	a1,389
ffffffffc02027fa:	00003517          	auipc	a0,0x3
ffffffffc02027fe:	3ce50513          	addi	a0,a0,974 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202802:	c4ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202806:	00004697          	auipc	a3,0x4
ffffffffc020280a:	88a68693          	addi	a3,a3,-1910 # ffffffffc0206090 <default_pmm_manager+0x608>
ffffffffc020280e:	00003617          	auipc	a2,0x3
ffffffffc0202812:	ee260613          	addi	a2,a2,-286 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202816:	1a800593          	li	a1,424
ffffffffc020281a:	00003517          	auipc	a0,0x3
ffffffffc020281e:	3ae50513          	addi	a0,a0,942 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202822:	c2ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202826:	00004697          	auipc	a3,0x4
ffffffffc020282a:	82a68693          	addi	a3,a3,-2006 # ffffffffc0206050 <default_pmm_manager+0x5c8>
ffffffffc020282e:	00003617          	auipc	a2,0x3
ffffffffc0202832:	ec260613          	addi	a2,a2,-318 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202836:	1a700593          	li	a1,423
ffffffffc020283a:	00003517          	auipc	a0,0x3
ffffffffc020283e:	38e50513          	addi	a0,a0,910 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202842:	c0ffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202846:	00003697          	auipc	a3,0x3
ffffffffc020284a:	7f268693          	addi	a3,a3,2034 # ffffffffc0206038 <default_pmm_manager+0x5b0>
ffffffffc020284e:	00003617          	auipc	a2,0x3
ffffffffc0202852:	ea260613          	addi	a2,a2,-350 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202856:	1a600593          	li	a1,422
ffffffffc020285a:	00003517          	auipc	a0,0x3
ffffffffc020285e:	36e50513          	addi	a0,a0,878 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202862:	beffd0ef          	jal	ra,ffffffffc0200450 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202866:	86be                	mv	a3,a5
ffffffffc0202868:	00003617          	auipc	a2,0x3
ffffffffc020286c:	27060613          	addi	a2,a2,624 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0202870:	16d00593          	li	a1,365
ffffffffc0202874:	00003517          	auipc	a0,0x3
ffffffffc0202878:	35450513          	addi	a0,a0,852 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc020287c:	bd5fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202880:	00003617          	auipc	a2,0x3
ffffffffc0202884:	29060613          	addi	a2,a2,656 # ffffffffc0205b10 <default_pmm_manager+0x88>
ffffffffc0202888:	07f00593          	li	a1,127
ffffffffc020288c:	00003517          	auipc	a0,0x3
ffffffffc0202890:	33c50513          	addi	a0,a0,828 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202894:	bbdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202898:	00004697          	auipc	a3,0x4
ffffffffc020289c:	82868693          	addi	a3,a3,-2008 # ffffffffc02060c0 <default_pmm_manager+0x638>
ffffffffc02028a0:	00003617          	auipc	a2,0x3
ffffffffc02028a4:	e5060613          	addi	a2,a2,-432 # ffffffffc02056f0 <commands+0x870>
ffffffffc02028a8:	1ac00593          	li	a1,428
ffffffffc02028ac:	00003517          	auipc	a0,0x3
ffffffffc02028b0:	31c50513          	addi	a0,a0,796 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02028b4:	b9dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02028b8:	00003697          	auipc	a3,0x3
ffffffffc02028bc:	69868693          	addi	a3,a3,1688 # ffffffffc0205f50 <default_pmm_manager+0x4c8>
ffffffffc02028c0:	00003617          	auipc	a2,0x3
ffffffffc02028c4:	e3060613          	addi	a2,a2,-464 # ffffffffc02056f0 <commands+0x870>
ffffffffc02028c8:	1b800593          	li	a1,440
ffffffffc02028cc:	00003517          	auipc	a0,0x3
ffffffffc02028d0:	2fc50513          	addi	a0,a0,764 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02028d4:	b7dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02028d8:	00003697          	auipc	a3,0x3
ffffffffc02028dc:	4c868693          	addi	a3,a3,1224 # ffffffffc0205da0 <default_pmm_manager+0x318>
ffffffffc02028e0:	00003617          	auipc	a2,0x3
ffffffffc02028e4:	e1060613          	addi	a2,a2,-496 # ffffffffc02056f0 <commands+0x870>
ffffffffc02028e8:	16b00593          	li	a1,363
ffffffffc02028ec:	00003517          	auipc	a0,0x3
ffffffffc02028f0:	2dc50513          	addi	a0,a0,732 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02028f4:	b5dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02028f8:	00003697          	auipc	a3,0x3
ffffffffc02028fc:	49068693          	addi	a3,a3,1168 # ffffffffc0205d88 <default_pmm_manager+0x300>
ffffffffc0202900:	00003617          	auipc	a2,0x3
ffffffffc0202904:	df060613          	addi	a2,a2,-528 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202908:	16a00593          	li	a1,362
ffffffffc020290c:	00003517          	auipc	a0,0x3
ffffffffc0202910:	2bc50513          	addi	a0,a0,700 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202914:	b3dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202918:	00003697          	auipc	a3,0x3
ffffffffc020291c:	3c068693          	addi	a3,a3,960 # ffffffffc0205cd8 <default_pmm_manager+0x250>
ffffffffc0202920:	00003617          	auipc	a2,0x3
ffffffffc0202924:	dd060613          	addi	a2,a2,-560 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202928:	16200593          	li	a1,354
ffffffffc020292c:	00003517          	auipc	a0,0x3
ffffffffc0202930:	29c50513          	addi	a0,a0,668 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202934:	b1dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202938:	00003697          	auipc	a3,0x3
ffffffffc020293c:	3f868693          	addi	a3,a3,1016 # ffffffffc0205d30 <default_pmm_manager+0x2a8>
ffffffffc0202940:	00003617          	auipc	a2,0x3
ffffffffc0202944:	db060613          	addi	a2,a2,-592 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202948:	16900593          	li	a1,361
ffffffffc020294c:	00003517          	auipc	a0,0x3
ffffffffc0202950:	27c50513          	addi	a0,a0,636 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202954:	afdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202958:	00003697          	auipc	a3,0x3
ffffffffc020295c:	3a868693          	addi	a3,a3,936 # ffffffffc0205d00 <default_pmm_manager+0x278>
ffffffffc0202960:	00003617          	auipc	a2,0x3
ffffffffc0202964:	d9060613          	addi	a2,a2,-624 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202968:	16600593          	li	a1,358
ffffffffc020296c:	00003517          	auipc	a0,0x3
ffffffffc0202970:	25c50513          	addi	a0,a0,604 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202974:	addfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202978:	00003697          	auipc	a3,0x3
ffffffffc020297c:	56868693          	addi	a3,a3,1384 # ffffffffc0205ee0 <default_pmm_manager+0x458>
ffffffffc0202980:	00003617          	auipc	a2,0x3
ffffffffc0202984:	d7060613          	addi	a2,a2,-656 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202988:	18200593          	li	a1,386
ffffffffc020298c:	00003517          	auipc	a0,0x3
ffffffffc0202990:	23c50513          	addi	a0,a0,572 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202994:	abdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202998:	00003697          	auipc	a3,0x3
ffffffffc020299c:	40868693          	addi	a3,a3,1032 # ffffffffc0205da0 <default_pmm_manager+0x318>
ffffffffc02029a0:	00003617          	auipc	a2,0x3
ffffffffc02029a4:	d5060613          	addi	a2,a2,-688 # ffffffffc02056f0 <commands+0x870>
ffffffffc02029a8:	18100593          	li	a1,385
ffffffffc02029ac:	00003517          	auipc	a0,0x3
ffffffffc02029b0:	21c50513          	addi	a0,a0,540 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02029b4:	a9dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02029b8:	00003697          	auipc	a3,0x3
ffffffffc02029bc:	54068693          	addi	a3,a3,1344 # ffffffffc0205ef8 <default_pmm_manager+0x470>
ffffffffc02029c0:	00003617          	auipc	a2,0x3
ffffffffc02029c4:	d3060613          	addi	a2,a2,-720 # ffffffffc02056f0 <commands+0x870>
ffffffffc02029c8:	17e00593          	li	a1,382
ffffffffc02029cc:	00003517          	auipc	a0,0x3
ffffffffc02029d0:	1fc50513          	addi	a0,a0,508 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02029d4:	a7dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02029d8:	00003697          	auipc	a3,0x3
ffffffffc02029dc:	72068693          	addi	a3,a3,1824 # ffffffffc02060f8 <default_pmm_manager+0x670>
ffffffffc02029e0:	00003617          	auipc	a2,0x3
ffffffffc02029e4:	d1060613          	addi	a2,a2,-752 # ffffffffc02056f0 <commands+0x870>
ffffffffc02029e8:	1af00593          	li	a1,431
ffffffffc02029ec:	00003517          	auipc	a0,0x3
ffffffffc02029f0:	1dc50513          	addi	a0,a0,476 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc02029f4:	a5dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02029f8:	00003697          	auipc	a3,0x3
ffffffffc02029fc:	55868693          	addi	a3,a3,1368 # ffffffffc0205f50 <default_pmm_manager+0x4c8>
ffffffffc0202a00:	00003617          	auipc	a2,0x3
ffffffffc0202a04:	cf060613          	addi	a2,a2,-784 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202a08:	19000593          	li	a1,400
ffffffffc0202a0c:	00003517          	auipc	a0,0x3
ffffffffc0202a10:	1bc50513          	addi	a0,a0,444 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202a14:	a3dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202a18:	00003697          	auipc	a3,0x3
ffffffffc0202a1c:	5d068693          	addi	a3,a3,1488 # ffffffffc0205fe8 <default_pmm_manager+0x560>
ffffffffc0202a20:	00003617          	auipc	a2,0x3
ffffffffc0202a24:	cd060613          	addi	a2,a2,-816 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202a28:	1a100593          	li	a1,417
ffffffffc0202a2c:	00003517          	auipc	a0,0x3
ffffffffc0202a30:	19c50513          	addi	a0,a0,412 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202a34:	a1dfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202a38:	00003697          	auipc	a3,0x3
ffffffffc0202a3c:	24868693          	addi	a3,a3,584 # ffffffffc0205c80 <default_pmm_manager+0x1f8>
ffffffffc0202a40:	00003617          	auipc	a2,0x3
ffffffffc0202a44:	cb060613          	addi	a2,a2,-848 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202a48:	16000593          	li	a1,352
ffffffffc0202a4c:	00003517          	auipc	a0,0x3
ffffffffc0202a50:	17c50513          	addi	a0,a0,380 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202a54:	9fdfd0ef          	jal	ra,ffffffffc0200450 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202a58:	00003617          	auipc	a2,0x3
ffffffffc0202a5c:	0b860613          	addi	a2,a2,184 # ffffffffc0205b10 <default_pmm_manager+0x88>
ffffffffc0202a60:	0c300593          	li	a1,195
ffffffffc0202a64:	00003517          	auipc	a0,0x3
ffffffffc0202a68:	16450513          	addi	a0,a0,356 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202a6c:	9e5fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0202a70 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202a70:	12058073          	sfence.vma	a1
}
ffffffffc0202a74:	8082                	ret

ffffffffc0202a76 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a76:	7179                	addi	sp,sp,-48
ffffffffc0202a78:	e84a                	sd	s2,16(sp)
ffffffffc0202a7a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc0202a7c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202a7e:	f022                	sd	s0,32(sp)
ffffffffc0202a80:	ec26                	sd	s1,24(sp)
ffffffffc0202a82:	e44e                	sd	s3,8(sp)
ffffffffc0202a84:	f406                	sd	ra,40(sp)
ffffffffc0202a86:	84ae                	mv	s1,a1
ffffffffc0202a88:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc0202a8a:	8e8ff0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0202a8e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202a90:	cd19                	beqz	a0,ffffffffc0202aae <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202a92:	85aa                	mv	a1,a0
ffffffffc0202a94:	86ce                	mv	a3,s3
ffffffffc0202a96:	8626                	mv	a2,s1
ffffffffc0202a98:	854a                	mv	a0,s2
ffffffffc0202a9a:	c8eff0ef          	jal	ra,ffffffffc0201f28 <page_insert>
ffffffffc0202a9e:	ed39                	bnez	a0,ffffffffc0202afc <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202aa0:	00013797          	auipc	a5,0x13
ffffffffc0202aa4:	a0078793          	addi	a5,a5,-1536 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0202aa8:	439c                	lw	a5,0(a5)
ffffffffc0202aaa:	2781                	sext.w	a5,a5
ffffffffc0202aac:	eb89                	bnez	a5,ffffffffc0202abe <pgdir_alloc_page+0x48>
}
ffffffffc0202aae:	8522                	mv	a0,s0
ffffffffc0202ab0:	70a2                	ld	ra,40(sp)
ffffffffc0202ab2:	7402                	ld	s0,32(sp)
ffffffffc0202ab4:	64e2                	ld	s1,24(sp)
ffffffffc0202ab6:	6942                	ld	s2,16(sp)
ffffffffc0202ab8:	69a2                	ld	s3,8(sp)
ffffffffc0202aba:	6145                	addi	sp,sp,48
ffffffffc0202abc:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202abe:	00013797          	auipc	a5,0x13
ffffffffc0202ac2:	b2278793          	addi	a5,a5,-1246 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202ac6:	6388                	ld	a0,0(a5)
ffffffffc0202ac8:	4681                	li	a3,0
ffffffffc0202aca:	8622                	mv	a2,s0
ffffffffc0202acc:	85a6                	mv	a1,s1
ffffffffc0202ace:	7be000ef          	jal	ra,ffffffffc020328c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202ad2:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202ad4:	fc04                	sd	s1,56(s0)
            assert(page_ref(page) == 1);
ffffffffc0202ad6:	4785                	li	a5,1
ffffffffc0202ad8:	fcf70be3          	beq	a4,a5,ffffffffc0202aae <pgdir_alloc_page+0x38>
ffffffffc0202adc:	00003697          	auipc	a3,0x3
ffffffffc0202ae0:	0fc68693          	addi	a3,a3,252 # ffffffffc0205bd8 <default_pmm_manager+0x150>
ffffffffc0202ae4:	00003617          	auipc	a2,0x3
ffffffffc0202ae8:	c0c60613          	addi	a2,a2,-1012 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202aec:	14800593          	li	a1,328
ffffffffc0202af0:	00003517          	auipc	a0,0x3
ffffffffc0202af4:	0d850513          	addi	a0,a0,216 # ffffffffc0205bc8 <default_pmm_manager+0x140>
ffffffffc0202af8:	959fd0ef          	jal	ra,ffffffffc0200450 <__panic>
            free_page(page);
ffffffffc0202afc:	8522                	mv	a0,s0
ffffffffc0202afe:	4585                	li	a1,1
ffffffffc0202b00:	8faff0ef          	jal	ra,ffffffffc0201bfa <free_pages>
            return NULL;
ffffffffc0202b04:	4401                	li	s0,0
ffffffffc0202b06:	b765                	j	ffffffffc0202aae <pgdir_alloc_page+0x38>

ffffffffc0202b08 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202b08:	7135                	addi	sp,sp,-160
ffffffffc0202b0a:	ed06                	sd	ra,152(sp)
ffffffffc0202b0c:	e922                	sd	s0,144(sp)
ffffffffc0202b0e:	e526                	sd	s1,136(sp)
ffffffffc0202b10:	e14a                	sd	s2,128(sp)
ffffffffc0202b12:	fcce                	sd	s3,120(sp)
ffffffffc0202b14:	f8d2                	sd	s4,112(sp)
ffffffffc0202b16:	f4d6                	sd	s5,104(sp)
ffffffffc0202b18:	f0da                	sd	s6,96(sp)
ffffffffc0202b1a:	ecde                	sd	s7,88(sp)
ffffffffc0202b1c:	e8e2                	sd	s8,80(sp)
ffffffffc0202b1e:	e4e6                	sd	s9,72(sp)
ffffffffc0202b20:	e0ea                	sd	s10,64(sp)
ffffffffc0202b22:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202b24:	460010ef          	jal	ra,ffffffffc0203f84 <swapfs_init>
     // if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
     // {
     //      panic("bad max_swap_offset %08x.\n", max_swap_offset);
     // }
     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202b28:	00013797          	auipc	a5,0x13
ffffffffc0202b2c:	a6878793          	addi	a5,a5,-1432 # ffffffffc0215590 <max_swap_offset>
ffffffffc0202b30:	6394                	ld	a3,0(a5)
ffffffffc0202b32:	010007b7          	lui	a5,0x1000
ffffffffc0202b36:	17e1                	addi	a5,a5,-8
ffffffffc0202b38:	ff968713          	addi	a4,a3,-7
ffffffffc0202b3c:	4ae7e863          	bltu	a5,a4,ffffffffc0202fec <swap_init+0x4e4>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_fifo;
ffffffffc0202b40:	00007797          	auipc	a5,0x7
ffffffffc0202b44:	4d078793          	addi	a5,a5,1232 # ffffffffc020a010 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0202b48:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0202b4a:	00013697          	auipc	a3,0x13
ffffffffc0202b4e:	94f6b723          	sd	a5,-1714(a3) # ffffffffc0215498 <sm>
     int r = sm->init();
ffffffffc0202b52:	9702                	jalr	a4
ffffffffc0202b54:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc0202b56:	c10d                	beqz	a0,ffffffffc0202b78 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202b58:	60ea                	ld	ra,152(sp)
ffffffffc0202b5a:	644a                	ld	s0,144(sp)
ffffffffc0202b5c:	8556                	mv	a0,s5
ffffffffc0202b5e:	64aa                	ld	s1,136(sp)
ffffffffc0202b60:	690a                	ld	s2,128(sp)
ffffffffc0202b62:	79e6                	ld	s3,120(sp)
ffffffffc0202b64:	7a46                	ld	s4,112(sp)
ffffffffc0202b66:	7aa6                	ld	s5,104(sp)
ffffffffc0202b68:	7b06                	ld	s6,96(sp)
ffffffffc0202b6a:	6be6                	ld	s7,88(sp)
ffffffffc0202b6c:	6c46                	ld	s8,80(sp)
ffffffffc0202b6e:	6ca6                	ld	s9,72(sp)
ffffffffc0202b70:	6d06                	ld	s10,64(sp)
ffffffffc0202b72:	7de2                	ld	s11,56(sp)
ffffffffc0202b74:	610d                	addi	sp,sp,160
ffffffffc0202b76:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b78:	00013797          	auipc	a5,0x13
ffffffffc0202b7c:	92078793          	addi	a5,a5,-1760 # ffffffffc0215498 <sm>
ffffffffc0202b80:	639c                	ld	a5,0(a5)
ffffffffc0202b82:	00003517          	auipc	a0,0x3
ffffffffc0202b86:	5ee50513          	addi	a0,a0,1518 # ffffffffc0206170 <default_pmm_manager+0x6e8>
    return listelm->next;
ffffffffc0202b8a:	00013417          	auipc	s0,0x13
ffffffffc0202b8e:	94640413          	addi	s0,s0,-1722 # ffffffffc02154d0 <free_area>
ffffffffc0202b92:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202b94:	4785                	li	a5,1
ffffffffc0202b96:	00013717          	auipc	a4,0x13
ffffffffc0202b9a:	90f72523          	sw	a5,-1782(a4) # ffffffffc02154a0 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202b9e:	df0fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202ba2:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ba4:	36878863          	beq	a5,s0,ffffffffc0202f14 <swap_init+0x40c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202ba8:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202bac:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202bae:	8b05                	andi	a4,a4,1
ffffffffc0202bb0:	36070663          	beqz	a4,ffffffffc0202f1c <swap_init+0x414>
     int ret, count = 0, total = 0, i;
ffffffffc0202bb4:	4481                	li	s1,0
ffffffffc0202bb6:	4901                	li	s2,0
ffffffffc0202bb8:	a031                	j	ffffffffc0202bc4 <swap_init+0xbc>
ffffffffc0202bba:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0202bbe:	8b09                	andi	a4,a4,2
ffffffffc0202bc0:	34070e63          	beqz	a4,ffffffffc0202f1c <swap_init+0x414>
        count ++, total += p->property;
ffffffffc0202bc4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202bc8:	679c                	ld	a5,8(a5)
ffffffffc0202bca:	2905                	addiw	s2,s2,1
ffffffffc0202bcc:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bce:	fe8796e3          	bne	a5,s0,ffffffffc0202bba <swap_init+0xb2>
ffffffffc0202bd2:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202bd4:	86cff0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0202bd8:	69351263          	bne	a0,s3,ffffffffc020325c <swap_init+0x754>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202bdc:	8626                	mv	a2,s1
ffffffffc0202bde:	85ca                	mv	a1,s2
ffffffffc0202be0:	00003517          	auipc	a0,0x3
ffffffffc0202be4:	5a850513          	addi	a0,a0,1448 # ffffffffc0206188 <default_pmm_manager+0x700>
ffffffffc0202be8:	da6fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202bec:	3dd000ef          	jal	ra,ffffffffc02037c8 <mm_create>
ffffffffc0202bf0:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202bf2:	60050563          	beqz	a0,ffffffffc02031fc <swap_init+0x6f4>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202bf6:	00013797          	auipc	a5,0x13
ffffffffc0202bfa:	9ea78793          	addi	a5,a5,-1558 # ffffffffc02155e0 <check_mm_struct>
ffffffffc0202bfe:	639c                	ld	a5,0(a5)
ffffffffc0202c00:	60079e63          	bnez	a5,ffffffffc020321c <swap_init+0x714>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c04:	00013797          	auipc	a5,0x13
ffffffffc0202c08:	88478793          	addi	a5,a5,-1916 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202c0c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0202c10:	00013797          	auipc	a5,0x13
ffffffffc0202c14:	9ca7b823          	sd	a0,-1584(a5) # ffffffffc02155e0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0202c18:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202c1c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202c20:	4e079263          	bnez	a5,ffffffffc0203104 <swap_init+0x5fc>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202c24:	6599                	lui	a1,0x6
ffffffffc0202c26:	460d                	li	a2,3
ffffffffc0202c28:	6505                	lui	a0,0x1
ffffffffc0202c2a:	3eb000ef          	jal	ra,ffffffffc0203814 <vma_create>
ffffffffc0202c2e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202c30:	4e050a63          	beqz	a0,ffffffffc0203124 <swap_init+0x61c>

     insert_vma_struct(mm, vma);
ffffffffc0202c34:	855e                	mv	a0,s7
ffffffffc0202c36:	44b000ef          	jal	ra,ffffffffc0203880 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202c3a:	00003517          	auipc	a0,0x3
ffffffffc0202c3e:	5be50513          	addi	a0,a0,1470 # ffffffffc02061f8 <default_pmm_manager+0x770>
ffffffffc0202c42:	d4cfd0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202c46:	018bb503          	ld	a0,24(s7)
ffffffffc0202c4a:	4605                	li	a2,1
ffffffffc0202c4c:	6585                	lui	a1,0x1
ffffffffc0202c4e:	832ff0ef          	jal	ra,ffffffffc0201c80 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202c52:	4e050963          	beqz	a0,ffffffffc0203144 <swap_init+0x63c>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c56:	00003517          	auipc	a0,0x3
ffffffffc0202c5a:	5f250513          	addi	a0,a0,1522 # ffffffffc0206248 <default_pmm_manager+0x7c0>
ffffffffc0202c5e:	00013997          	auipc	s3,0x13
ffffffffc0202c62:	8aa98993          	addi	s3,s3,-1878 # ffffffffc0215508 <check_rp>
ffffffffc0202c66:	d28fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c6a:	00013a17          	auipc	s4,0x13
ffffffffc0202c6e:	8bea0a13          	addi	s4,s4,-1858 # ffffffffc0215528 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202c72:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0202c74:	4505                	li	a0,1
ffffffffc0202c76:	efdfe0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
ffffffffc0202c7a:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202c7e:	32050763          	beqz	a0,ffffffffc0202fac <swap_init+0x4a4>
ffffffffc0202c82:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c84:	8b89                	andi	a5,a5,2
ffffffffc0202c86:	30079363          	bnez	a5,ffffffffc0202f8c <swap_init+0x484>
ffffffffc0202c8a:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202c8c:	ff4c14e3          	bne	s8,s4,ffffffffc0202c74 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202c90:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202c92:	00013c17          	auipc	s8,0x13
ffffffffc0202c96:	876c0c13          	addi	s8,s8,-1930 # ffffffffc0215508 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202c9a:	ec3e                	sd	a5,24(sp)
ffffffffc0202c9c:	641c                	ld	a5,8(s0)
ffffffffc0202c9e:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202ca0:	481c                	lw	a5,16(s0)
ffffffffc0202ca2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202ca4:	00013797          	auipc	a5,0x13
ffffffffc0202ca8:	8287ba23          	sd	s0,-1996(a5) # ffffffffc02154d8 <free_area+0x8>
ffffffffc0202cac:	00013797          	auipc	a5,0x13
ffffffffc0202cb0:	8287b223          	sd	s0,-2012(a5) # ffffffffc02154d0 <free_area>
     nr_free = 0;
ffffffffc0202cb4:	00013797          	auipc	a5,0x13
ffffffffc0202cb8:	8207a623          	sw	zero,-2004(a5) # ffffffffc02154e0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202cbc:	000c3503          	ld	a0,0(s8)
ffffffffc0202cc0:	4585                	li	a1,1
ffffffffc0202cc2:	0c21                	addi	s8,s8,8
ffffffffc0202cc4:	f37fe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202cc8:	ff4c1ae3          	bne	s8,s4,ffffffffc0202cbc <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202ccc:	01042c03          	lw	s8,16(s0)
ffffffffc0202cd0:	4791                	li	a5,4
ffffffffc0202cd2:	50fc1563          	bne	s8,a5,ffffffffc02031dc <swap_init+0x6d4>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202cd6:	00003517          	auipc	a0,0x3
ffffffffc0202cda:	5fa50513          	addi	a0,a0,1530 # ffffffffc02062d0 <default_pmm_manager+0x848>
ffffffffc0202cde:	cb0fd0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202ce2:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202ce4:	00012797          	auipc	a5,0x12
ffffffffc0202ce8:	7c07a023          	sw	zero,1984(a5) # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cec:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202cee:	00012797          	auipc	a5,0x12
ffffffffc0202cf2:	7b678793          	addi	a5,a5,1974 # ffffffffc02154a4 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202cf6:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202cfa:	4398                	lw	a4,0(a5)
ffffffffc0202cfc:	4585                	li	a1,1
ffffffffc0202cfe:	2701                	sext.w	a4,a4
ffffffffc0202d00:	38b71263          	bne	a4,a1,ffffffffc0203084 <swap_init+0x57c>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202d04:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202d08:	4394                	lw	a3,0(a5)
ffffffffc0202d0a:	2681                	sext.w	a3,a3
ffffffffc0202d0c:	38e69c63          	bne	a3,a4,ffffffffc02030a4 <swap_init+0x59c>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202d10:	6689                	lui	a3,0x2
ffffffffc0202d12:	462d                	li	a2,11
ffffffffc0202d14:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202d18:	4398                	lw	a4,0(a5)
ffffffffc0202d1a:	4589                	li	a1,2
ffffffffc0202d1c:	2701                	sext.w	a4,a4
ffffffffc0202d1e:	2eb71363          	bne	a4,a1,ffffffffc0203004 <swap_init+0x4fc>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202d22:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202d26:	4394                	lw	a3,0(a5)
ffffffffc0202d28:	2681                	sext.w	a3,a3
ffffffffc0202d2a:	2ee69d63          	bne	a3,a4,ffffffffc0203024 <swap_init+0x51c>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202d2e:	668d                	lui	a3,0x3
ffffffffc0202d30:	4631                	li	a2,12
ffffffffc0202d32:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202d36:	4398                	lw	a4,0(a5)
ffffffffc0202d38:	458d                	li	a1,3
ffffffffc0202d3a:	2701                	sext.w	a4,a4
ffffffffc0202d3c:	30b71463          	bne	a4,a1,ffffffffc0203044 <swap_init+0x53c>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202d40:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202d44:	4394                	lw	a3,0(a5)
ffffffffc0202d46:	2681                	sext.w	a3,a3
ffffffffc0202d48:	30e69e63          	bne	a3,a4,ffffffffc0203064 <swap_init+0x55c>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202d4c:	6691                	lui	a3,0x4
ffffffffc0202d4e:	4635                	li	a2,13
ffffffffc0202d50:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202d54:	4398                	lw	a4,0(a5)
ffffffffc0202d56:	2701                	sext.w	a4,a4
ffffffffc0202d58:	37871663          	bne	a4,s8,ffffffffc02030c4 <swap_init+0x5bc>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202d5c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202d60:	439c                	lw	a5,0(a5)
ffffffffc0202d62:	2781                	sext.w	a5,a5
ffffffffc0202d64:	38e79063          	bne	a5,a4,ffffffffc02030e4 <swap_init+0x5dc>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202d68:	481c                	lw	a5,16(s0)
ffffffffc0202d6a:	3e079d63          	bnez	a5,ffffffffc0203164 <swap_init+0x65c>
ffffffffc0202d6e:	00012797          	auipc	a5,0x12
ffffffffc0202d72:	7ba78793          	addi	a5,a5,1978 # ffffffffc0215528 <swap_in_seq_no>
ffffffffc0202d76:	00012717          	auipc	a4,0x12
ffffffffc0202d7a:	7da70713          	addi	a4,a4,2010 # ffffffffc0215550 <swap_out_seq_no>
ffffffffc0202d7e:	00012617          	auipc	a2,0x12
ffffffffc0202d82:	7d260613          	addi	a2,a2,2002 # ffffffffc0215550 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202d86:	56fd                	li	a3,-1
ffffffffc0202d88:	c394                	sw	a3,0(a5)
ffffffffc0202d8a:	c314                	sw	a3,0(a4)
ffffffffc0202d8c:	0791                	addi	a5,a5,4
ffffffffc0202d8e:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202d90:	fef61ce3          	bne	a2,a5,ffffffffc0202d88 <swap_init+0x280>
ffffffffc0202d94:	00013697          	auipc	a3,0x13
ffffffffc0202d98:	81c68693          	addi	a3,a3,-2020 # ffffffffc02155b0 <check_ptep>
ffffffffc0202d9c:	00012817          	auipc	a6,0x12
ffffffffc0202da0:	76c80813          	addi	a6,a6,1900 # ffffffffc0215508 <check_rp>
ffffffffc0202da4:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202da6:	00012c97          	auipc	s9,0x12
ffffffffc0202daa:	6eac8c93          	addi	s9,s9,1770 # ffffffffc0215490 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202dae:	00004d97          	auipc	s11,0x4
ffffffffc0202db2:	03ad8d93          	addi	s11,s11,58 # ffffffffc0206de8 <nbase>
ffffffffc0202db6:	00012c17          	auipc	s8,0x12
ffffffffc0202dba:	74ac0c13          	addi	s8,s8,1866 # ffffffffc0215500 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202dbe:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dc2:	4601                	li	a2,0
ffffffffc0202dc4:	85ea                	mv	a1,s10
ffffffffc0202dc6:	855a                	mv	a0,s6
ffffffffc0202dc8:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202dca:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dcc:	eb5fe0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0202dd0:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202dd2:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202dd4:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202dd6:	1e050b63          	beqz	a0,ffffffffc0202fcc <swap_init+0x4c4>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202dda:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202ddc:	0017f613          	andi	a2,a5,1
ffffffffc0202de0:	18060a63          	beqz	a2,ffffffffc0202f74 <swap_init+0x46c>
    if (PPN(pa) >= npage) {
ffffffffc0202de4:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202de8:	078a                	slli	a5,a5,0x2
ffffffffc0202dea:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202dec:	14c7f863          	bleu	a2,a5,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202df0:	000db703          	ld	a4,0(s11)
ffffffffc0202df4:	000c3603          	ld	a2,0(s8)
ffffffffc0202df8:	00083583          	ld	a1,0(a6)
ffffffffc0202dfc:	8f99                	sub	a5,a5,a4
ffffffffc0202dfe:	079a                	slli	a5,a5,0x6
ffffffffc0202e00:	e43a                	sd	a4,8(sp)
ffffffffc0202e02:	97b2                	add	a5,a5,a2
ffffffffc0202e04:	14f59863          	bne	a1,a5,ffffffffc0202f54 <swap_init+0x44c>
ffffffffc0202e08:	6785                	lui	a5,0x1
ffffffffc0202e0a:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e0c:	6795                	lui	a5,0x5
ffffffffc0202e0e:	06a1                	addi	a3,a3,8
ffffffffc0202e10:	0821                	addi	a6,a6,8
ffffffffc0202e12:	fafd16e3          	bne	s10,a5,ffffffffc0202dbe <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202e16:	00003517          	auipc	a0,0x3
ffffffffc0202e1a:	56250513          	addi	a0,a0,1378 # ffffffffc0206378 <default_pmm_manager+0x8f0>
ffffffffc0202e1e:	b70fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0202e22:	00012797          	auipc	a5,0x12
ffffffffc0202e26:	67678793          	addi	a5,a5,1654 # ffffffffc0215498 <sm>
ffffffffc0202e2a:	639c                	ld	a5,0(a5)
ffffffffc0202e2c:	7f9c                	ld	a5,56(a5)
ffffffffc0202e2e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202e30:	40051663          	bnez	a0,ffffffffc020323c <swap_init+0x734>

     nr_free = nr_free_store;
ffffffffc0202e34:	77a2                	ld	a5,40(sp)
ffffffffc0202e36:	00012717          	auipc	a4,0x12
ffffffffc0202e3a:	6af72523          	sw	a5,1706(a4) # ffffffffc02154e0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202e3e:	67e2                	ld	a5,24(sp)
ffffffffc0202e40:	00012717          	auipc	a4,0x12
ffffffffc0202e44:	68f73823          	sd	a5,1680(a4) # ffffffffc02154d0 <free_area>
ffffffffc0202e48:	7782                	ld	a5,32(sp)
ffffffffc0202e4a:	00012717          	auipc	a4,0x12
ffffffffc0202e4e:	68f73723          	sd	a5,1678(a4) # ffffffffc02154d8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202e52:	0009b503          	ld	a0,0(s3)
ffffffffc0202e56:	4585                	li	a1,1
ffffffffc0202e58:	09a1                	addi	s3,s3,8
ffffffffc0202e5a:	da1fe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202e5e:	ff499ae3          	bne	s3,s4,ffffffffc0202e52 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202e62:	855e                	mv	a0,s7
ffffffffc0202e64:	2eb000ef          	jal	ra,ffffffffc020394e <mm_destroy>

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202e68:	00012797          	auipc	a5,0x12
ffffffffc0202e6c:	62078793          	addi	a5,a5,1568 # ffffffffc0215488 <boot_pgdir>
ffffffffc0202e70:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0202e72:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e76:	6394                	ld	a3,0(a5)
ffffffffc0202e78:	068a                	slli	a3,a3,0x2
ffffffffc0202e7a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e7c:	0ce6f063          	bleu	a4,a3,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e80:	67a2                	ld	a5,8(sp)
ffffffffc0202e82:	000c3503          	ld	a0,0(s8)
ffffffffc0202e86:	8e9d                	sub	a3,a3,a5
ffffffffc0202e88:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0202e8a:	8699                	srai	a3,a3,0x6
ffffffffc0202e8c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202e8e:	57fd                	li	a5,-1
ffffffffc0202e90:	83b1                	srli	a5,a5,0xc
ffffffffc0202e92:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e94:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e96:	2ee7f763          	bleu	a4,a5,ffffffffc0203184 <swap_init+0x67c>
     free_page(pde2page(pd0[0]));
ffffffffc0202e9a:	00012797          	auipc	a5,0x12
ffffffffc0202e9e:	65678793          	addi	a5,a5,1622 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0202ea2:	639c                	ld	a5,0(a5)
ffffffffc0202ea4:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ea6:	629c                	ld	a5,0(a3)
ffffffffc0202ea8:	078a                	slli	a5,a5,0x2
ffffffffc0202eaa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202eac:	08e7f863          	bleu	a4,a5,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eb0:	69a2                	ld	s3,8(sp)
ffffffffc0202eb2:	4585                	li	a1,1
ffffffffc0202eb4:	413787b3          	sub	a5,a5,s3
ffffffffc0202eb8:	079a                	slli	a5,a5,0x6
ffffffffc0202eba:	953e                	add	a0,a0,a5
ffffffffc0202ebc:	d3ffe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ec0:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0202ec4:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ec8:	078a                	slli	a5,a5,0x2
ffffffffc0202eca:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ecc:	06e7f863          	bleu	a4,a5,ffffffffc0202f3c <swap_init+0x434>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ed0:	000c3503          	ld	a0,0(s8)
ffffffffc0202ed4:	413787b3          	sub	a5,a5,s3
ffffffffc0202ed8:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0202eda:	4585                	li	a1,1
ffffffffc0202edc:	953e                	add	a0,a0,a5
ffffffffc0202ede:	d1dfe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
     pgdir[0] = 0;
ffffffffc0202ee2:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0202ee6:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0202eea:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202eec:	00878963          	beq	a5,s0,ffffffffc0202efe <swap_init+0x3f6>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202ef0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ef4:	679c                	ld	a5,8(a5)
ffffffffc0202ef6:	397d                	addiw	s2,s2,-1
ffffffffc0202ef8:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202efa:	fe879be3          	bne	a5,s0,ffffffffc0202ef0 <swap_init+0x3e8>
     }
     assert(count==0);
ffffffffc0202efe:	28091f63          	bnez	s2,ffffffffc020319c <swap_init+0x694>
     assert(total==0);
ffffffffc0202f02:	2a049d63          	bnez	s1,ffffffffc02031bc <swap_init+0x6b4>

     cprintf("check_swap() succeeded!\n");
ffffffffc0202f06:	00003517          	auipc	a0,0x3
ffffffffc0202f0a:	4c250513          	addi	a0,a0,1218 # ffffffffc02063c8 <default_pmm_manager+0x940>
ffffffffc0202f0e:	a80fd0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0202f12:	b199                	j	ffffffffc0202b58 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202f14:	4481                	li	s1,0
ffffffffc0202f16:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202f18:	4981                	li	s3,0
ffffffffc0202f1a:	b96d                	j	ffffffffc0202bd4 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202f1c:	00002697          	auipc	a3,0x2
ffffffffc0202f20:	7c468693          	addi	a3,a3,1988 # ffffffffc02056e0 <commands+0x860>
ffffffffc0202f24:	00002617          	auipc	a2,0x2
ffffffffc0202f28:	7cc60613          	addi	a2,a2,1996 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202f2c:	0bd00593          	li	a1,189
ffffffffc0202f30:	00003517          	auipc	a0,0x3
ffffffffc0202f34:	23050513          	addi	a0,a0,560 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0202f38:	d18fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202f3c:	00003617          	auipc	a2,0x3
ffffffffc0202f40:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0205b38 <default_pmm_manager+0xb0>
ffffffffc0202f44:	06200593          	li	a1,98
ffffffffc0202f48:	00003517          	auipc	a0,0x3
ffffffffc0202f4c:	bb850513          	addi	a0,a0,-1096 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0202f50:	d00fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202f54:	00003697          	auipc	a3,0x3
ffffffffc0202f58:	3fc68693          	addi	a3,a3,1020 # ffffffffc0206350 <default_pmm_manager+0x8c8>
ffffffffc0202f5c:	00002617          	auipc	a2,0x2
ffffffffc0202f60:	79460613          	addi	a2,a2,1940 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202f64:	0fd00593          	li	a1,253
ffffffffc0202f68:	00003517          	auipc	a0,0x3
ffffffffc0202f6c:	1f850513          	addi	a0,a0,504 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0202f70:	ce0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202f74:	00003617          	auipc	a2,0x3
ffffffffc0202f78:	dec60613          	addi	a2,a2,-532 # ffffffffc0205d60 <default_pmm_manager+0x2d8>
ffffffffc0202f7c:	07400593          	li	a1,116
ffffffffc0202f80:	00003517          	auipc	a0,0x3
ffffffffc0202f84:	b8050513          	addi	a0,a0,-1152 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0202f88:	cc8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202f8c:	00003697          	auipc	a3,0x3
ffffffffc0202f90:	2fc68693          	addi	a3,a3,764 # ffffffffc0206288 <default_pmm_manager+0x800>
ffffffffc0202f94:	00002617          	auipc	a2,0x2
ffffffffc0202f98:	75c60613          	addi	a2,a2,1884 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202f9c:	0de00593          	li	a1,222
ffffffffc0202fa0:	00003517          	auipc	a0,0x3
ffffffffc0202fa4:	1c050513          	addi	a0,a0,448 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0202fa8:	ca8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202fac:	00003697          	auipc	a3,0x3
ffffffffc0202fb0:	2c468693          	addi	a3,a3,708 # ffffffffc0206270 <default_pmm_manager+0x7e8>
ffffffffc0202fb4:	00002617          	auipc	a2,0x2
ffffffffc0202fb8:	73c60613          	addi	a2,a2,1852 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202fbc:	0dd00593          	li	a1,221
ffffffffc0202fc0:	00003517          	auipc	a0,0x3
ffffffffc0202fc4:	1a050513          	addi	a0,a0,416 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0202fc8:	c88fd0ef          	jal	ra,ffffffffc0200450 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202fcc:	00003697          	auipc	a3,0x3
ffffffffc0202fd0:	36c68693          	addi	a3,a3,876 # ffffffffc0206338 <default_pmm_manager+0x8b0>
ffffffffc0202fd4:	00002617          	auipc	a2,0x2
ffffffffc0202fd8:	71c60613          	addi	a2,a2,1820 # ffffffffc02056f0 <commands+0x870>
ffffffffc0202fdc:	0fc00593          	li	a1,252
ffffffffc0202fe0:	00003517          	auipc	a0,0x3
ffffffffc0202fe4:	18050513          	addi	a0,a0,384 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0202fe8:	c68fd0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202fec:	00003617          	auipc	a2,0x3
ffffffffc0202ff0:	15460613          	addi	a2,a2,340 # ffffffffc0206140 <default_pmm_manager+0x6b8>
ffffffffc0202ff4:	02a00593          	li	a1,42
ffffffffc0202ff8:	00003517          	auipc	a0,0x3
ffffffffc0202ffc:	16850513          	addi	a0,a0,360 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203000:	c50fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203004:	00003697          	auipc	a3,0x3
ffffffffc0203008:	30468693          	addi	a3,a3,772 # ffffffffc0206308 <default_pmm_manager+0x880>
ffffffffc020300c:	00002617          	auipc	a2,0x2
ffffffffc0203010:	6e460613          	addi	a2,a2,1764 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203014:	09800593          	li	a1,152
ffffffffc0203018:	00003517          	auipc	a0,0x3
ffffffffc020301c:	14850513          	addi	a0,a0,328 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203020:	c30fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==2);
ffffffffc0203024:	00003697          	auipc	a3,0x3
ffffffffc0203028:	2e468693          	addi	a3,a3,740 # ffffffffc0206308 <default_pmm_manager+0x880>
ffffffffc020302c:	00002617          	auipc	a2,0x2
ffffffffc0203030:	6c460613          	addi	a2,a2,1732 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203034:	09a00593          	li	a1,154
ffffffffc0203038:	00003517          	auipc	a0,0x3
ffffffffc020303c:	12850513          	addi	a0,a0,296 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203040:	c10fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc0203044:	00003697          	auipc	a3,0x3
ffffffffc0203048:	2d468693          	addi	a3,a3,724 # ffffffffc0206318 <default_pmm_manager+0x890>
ffffffffc020304c:	00002617          	auipc	a2,0x2
ffffffffc0203050:	6a460613          	addi	a2,a2,1700 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203054:	09c00593          	li	a1,156
ffffffffc0203058:	00003517          	auipc	a0,0x3
ffffffffc020305c:	10850513          	addi	a0,a0,264 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203060:	bf0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==3);
ffffffffc0203064:	00003697          	auipc	a3,0x3
ffffffffc0203068:	2b468693          	addi	a3,a3,692 # ffffffffc0206318 <default_pmm_manager+0x890>
ffffffffc020306c:	00002617          	auipc	a2,0x2
ffffffffc0203070:	68460613          	addi	a2,a2,1668 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203074:	09e00593          	li	a1,158
ffffffffc0203078:	00003517          	auipc	a0,0x3
ffffffffc020307c:	0e850513          	addi	a0,a0,232 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203080:	bd0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc0203084:	00003697          	auipc	a3,0x3
ffffffffc0203088:	27468693          	addi	a3,a3,628 # ffffffffc02062f8 <default_pmm_manager+0x870>
ffffffffc020308c:	00002617          	auipc	a2,0x2
ffffffffc0203090:	66460613          	addi	a2,a2,1636 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203094:	09400593          	li	a1,148
ffffffffc0203098:	00003517          	auipc	a0,0x3
ffffffffc020309c:	0c850513          	addi	a0,a0,200 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc02030a0:	bb0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==1);
ffffffffc02030a4:	00003697          	auipc	a3,0x3
ffffffffc02030a8:	25468693          	addi	a3,a3,596 # ffffffffc02062f8 <default_pmm_manager+0x870>
ffffffffc02030ac:	00002617          	auipc	a2,0x2
ffffffffc02030b0:	64460613          	addi	a2,a2,1604 # ffffffffc02056f0 <commands+0x870>
ffffffffc02030b4:	09600593          	li	a1,150
ffffffffc02030b8:	00003517          	auipc	a0,0x3
ffffffffc02030bc:	0a850513          	addi	a0,a0,168 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc02030c0:	b90fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc02030c4:	00003697          	auipc	a3,0x3
ffffffffc02030c8:	26468693          	addi	a3,a3,612 # ffffffffc0206328 <default_pmm_manager+0x8a0>
ffffffffc02030cc:	00002617          	auipc	a2,0x2
ffffffffc02030d0:	62460613          	addi	a2,a2,1572 # ffffffffc02056f0 <commands+0x870>
ffffffffc02030d4:	0a000593          	li	a1,160
ffffffffc02030d8:	00003517          	auipc	a0,0x3
ffffffffc02030dc:	08850513          	addi	a0,a0,136 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc02030e0:	b70fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgfault_num==4);
ffffffffc02030e4:	00003697          	auipc	a3,0x3
ffffffffc02030e8:	24468693          	addi	a3,a3,580 # ffffffffc0206328 <default_pmm_manager+0x8a0>
ffffffffc02030ec:	00002617          	auipc	a2,0x2
ffffffffc02030f0:	60460613          	addi	a2,a2,1540 # ffffffffc02056f0 <commands+0x870>
ffffffffc02030f4:	0a200593          	li	a1,162
ffffffffc02030f8:	00003517          	auipc	a0,0x3
ffffffffc02030fc:	06850513          	addi	a0,a0,104 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203100:	b50fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203104:	00003697          	auipc	a3,0x3
ffffffffc0203108:	0d468693          	addi	a3,a3,212 # ffffffffc02061d8 <default_pmm_manager+0x750>
ffffffffc020310c:	00002617          	auipc	a2,0x2
ffffffffc0203110:	5e460613          	addi	a2,a2,1508 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203114:	0cd00593          	li	a1,205
ffffffffc0203118:	00003517          	auipc	a0,0x3
ffffffffc020311c:	04850513          	addi	a0,a0,72 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203120:	b30fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(vma != NULL);
ffffffffc0203124:	00003697          	auipc	a3,0x3
ffffffffc0203128:	0c468693          	addi	a3,a3,196 # ffffffffc02061e8 <default_pmm_manager+0x760>
ffffffffc020312c:	00002617          	auipc	a2,0x2
ffffffffc0203130:	5c460613          	addi	a2,a2,1476 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203134:	0d000593          	li	a1,208
ffffffffc0203138:	00003517          	auipc	a0,0x3
ffffffffc020313c:	02850513          	addi	a0,a0,40 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203140:	b10fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203144:	00003697          	auipc	a3,0x3
ffffffffc0203148:	0ec68693          	addi	a3,a3,236 # ffffffffc0206230 <default_pmm_manager+0x7a8>
ffffffffc020314c:	00002617          	auipc	a2,0x2
ffffffffc0203150:	5a460613          	addi	a2,a2,1444 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203154:	0d800593          	li	a1,216
ffffffffc0203158:	00003517          	auipc	a0,0x3
ffffffffc020315c:	00850513          	addi	a0,a0,8 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203160:	af0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert( nr_free == 0);         
ffffffffc0203164:	00002697          	auipc	a3,0x2
ffffffffc0203168:	76468693          	addi	a3,a3,1892 # ffffffffc02058c8 <commands+0xa48>
ffffffffc020316c:	00002617          	auipc	a2,0x2
ffffffffc0203170:	58460613          	addi	a2,a2,1412 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203174:	0f400593          	li	a1,244
ffffffffc0203178:	00003517          	auipc	a0,0x3
ffffffffc020317c:	fe850513          	addi	a0,a0,-24 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203180:	ad0fd0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203184:	00003617          	auipc	a2,0x3
ffffffffc0203188:	95460613          	addi	a2,a2,-1708 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc020318c:	06900593          	li	a1,105
ffffffffc0203190:	00003517          	auipc	a0,0x3
ffffffffc0203194:	97050513          	addi	a0,a0,-1680 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0203198:	ab8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(count==0);
ffffffffc020319c:	00003697          	auipc	a3,0x3
ffffffffc02031a0:	20c68693          	addi	a3,a3,524 # ffffffffc02063a8 <default_pmm_manager+0x920>
ffffffffc02031a4:	00002617          	auipc	a2,0x2
ffffffffc02031a8:	54c60613          	addi	a2,a2,1356 # ffffffffc02056f0 <commands+0x870>
ffffffffc02031ac:	11c00593          	li	a1,284
ffffffffc02031b0:	00003517          	auipc	a0,0x3
ffffffffc02031b4:	fb050513          	addi	a0,a0,-80 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc02031b8:	a98fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total==0);
ffffffffc02031bc:	00003697          	auipc	a3,0x3
ffffffffc02031c0:	1fc68693          	addi	a3,a3,508 # ffffffffc02063b8 <default_pmm_manager+0x930>
ffffffffc02031c4:	00002617          	auipc	a2,0x2
ffffffffc02031c8:	52c60613          	addi	a2,a2,1324 # ffffffffc02056f0 <commands+0x870>
ffffffffc02031cc:	11d00593          	li	a1,285
ffffffffc02031d0:	00003517          	auipc	a0,0x3
ffffffffc02031d4:	f9050513          	addi	a0,a0,-112 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc02031d8:	a78fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc02031dc:	00003697          	auipc	a3,0x3
ffffffffc02031e0:	0cc68693          	addi	a3,a3,204 # ffffffffc02062a8 <default_pmm_manager+0x820>
ffffffffc02031e4:	00002617          	auipc	a2,0x2
ffffffffc02031e8:	50c60613          	addi	a2,a2,1292 # ffffffffc02056f0 <commands+0x870>
ffffffffc02031ec:	0eb00593          	li	a1,235
ffffffffc02031f0:	00003517          	auipc	a0,0x3
ffffffffc02031f4:	f7050513          	addi	a0,a0,-144 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc02031f8:	a58fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(mm != NULL);
ffffffffc02031fc:	00003697          	auipc	a3,0x3
ffffffffc0203200:	fb468693          	addi	a3,a3,-76 # ffffffffc02061b0 <default_pmm_manager+0x728>
ffffffffc0203204:	00002617          	auipc	a2,0x2
ffffffffc0203208:	4ec60613          	addi	a2,a2,1260 # ffffffffc02056f0 <commands+0x870>
ffffffffc020320c:	0c500593          	li	a1,197
ffffffffc0203210:	00003517          	auipc	a0,0x3
ffffffffc0203214:	f5050513          	addi	a0,a0,-176 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203218:	a38fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc020321c:	00003697          	auipc	a3,0x3
ffffffffc0203220:	fa468693          	addi	a3,a3,-92 # ffffffffc02061c0 <default_pmm_manager+0x738>
ffffffffc0203224:	00002617          	auipc	a2,0x2
ffffffffc0203228:	4cc60613          	addi	a2,a2,1228 # ffffffffc02056f0 <commands+0x870>
ffffffffc020322c:	0c800593          	li	a1,200
ffffffffc0203230:	00003517          	auipc	a0,0x3
ffffffffc0203234:	f3050513          	addi	a0,a0,-208 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203238:	a18fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(ret==0);
ffffffffc020323c:	00003697          	auipc	a3,0x3
ffffffffc0203240:	16468693          	addi	a3,a3,356 # ffffffffc02063a0 <default_pmm_manager+0x918>
ffffffffc0203244:	00002617          	auipc	a2,0x2
ffffffffc0203248:	4ac60613          	addi	a2,a2,1196 # ffffffffc02056f0 <commands+0x870>
ffffffffc020324c:	10300593          	li	a1,259
ffffffffc0203250:	00003517          	auipc	a0,0x3
ffffffffc0203254:	f1050513          	addi	a0,a0,-240 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203258:	9f8fd0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(total == nr_free_pages());
ffffffffc020325c:	00002697          	auipc	a3,0x2
ffffffffc0203260:	4c468693          	addi	a3,a3,1220 # ffffffffc0205720 <commands+0x8a0>
ffffffffc0203264:	00002617          	auipc	a2,0x2
ffffffffc0203268:	48c60613          	addi	a2,a2,1164 # ffffffffc02056f0 <commands+0x870>
ffffffffc020326c:	0c000593          	li	a1,192
ffffffffc0203270:	00003517          	auipc	a0,0x3
ffffffffc0203274:	ef050513          	addi	a0,a0,-272 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc0203278:	9d8fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020327c <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc020327c:	00012797          	auipc	a5,0x12
ffffffffc0203280:	21c78793          	addi	a5,a5,540 # ffffffffc0215498 <sm>
ffffffffc0203284:	639c                	ld	a5,0(a5)
ffffffffc0203286:	0107b303          	ld	t1,16(a5)
ffffffffc020328a:	8302                	jr	t1

ffffffffc020328c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020328c:	00012797          	auipc	a5,0x12
ffffffffc0203290:	20c78793          	addi	a5,a5,524 # ffffffffc0215498 <sm>
ffffffffc0203294:	639c                	ld	a5,0(a5)
ffffffffc0203296:	0207b303          	ld	t1,32(a5)
ffffffffc020329a:	8302                	jr	t1

ffffffffc020329c <swap_out>:
{
ffffffffc020329c:	711d                	addi	sp,sp,-96
ffffffffc020329e:	ec86                	sd	ra,88(sp)
ffffffffc02032a0:	e8a2                	sd	s0,80(sp)
ffffffffc02032a2:	e4a6                	sd	s1,72(sp)
ffffffffc02032a4:	e0ca                	sd	s2,64(sp)
ffffffffc02032a6:	fc4e                	sd	s3,56(sp)
ffffffffc02032a8:	f852                	sd	s4,48(sp)
ffffffffc02032aa:	f456                	sd	s5,40(sp)
ffffffffc02032ac:	f05a                	sd	s6,32(sp)
ffffffffc02032ae:	ec5e                	sd	s7,24(sp)
ffffffffc02032b0:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02032b2:	cde9                	beqz	a1,ffffffffc020338c <swap_out+0xf0>
ffffffffc02032b4:	8ab2                	mv	s5,a2
ffffffffc02032b6:	892a                	mv	s2,a0
ffffffffc02032b8:	8a2e                	mv	s4,a1
ffffffffc02032ba:	4401                	li	s0,0
ffffffffc02032bc:	00012997          	auipc	s3,0x12
ffffffffc02032c0:	1dc98993          	addi	s3,s3,476 # ffffffffc0215498 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032c4:	00003b17          	auipc	s6,0x3
ffffffffc02032c8:	184b0b13          	addi	s6,s6,388 # ffffffffc0206448 <default_pmm_manager+0x9c0>
                    cprintf("SWAP: failed to save\n");
ffffffffc02032cc:	00003b97          	auipc	s7,0x3
ffffffffc02032d0:	164b8b93          	addi	s7,s7,356 # ffffffffc0206430 <default_pmm_manager+0x9a8>
ffffffffc02032d4:	a825                	j	ffffffffc020330c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032d6:	67a2                	ld	a5,8(sp)
ffffffffc02032d8:	8626                	mv	a2,s1
ffffffffc02032da:	85a2                	mv	a1,s0
ffffffffc02032dc:	7f94                	ld	a3,56(a5)
ffffffffc02032de:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02032e0:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02032e2:	82b1                	srli	a3,a3,0xc
ffffffffc02032e4:	0685                	addi	a3,a3,1
ffffffffc02032e6:	ea9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032ea:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02032ec:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02032ee:	7d1c                	ld	a5,56(a0)
ffffffffc02032f0:	83b1                	srli	a5,a5,0xc
ffffffffc02032f2:	0785                	addi	a5,a5,1
ffffffffc02032f4:	07a2                	slli	a5,a5,0x8
ffffffffc02032f6:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc02032fa:	901fe0ef          	jal	ra,ffffffffc0201bfa <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc02032fe:	01893503          	ld	a0,24(s2)
ffffffffc0203302:	85a6                	mv	a1,s1
ffffffffc0203304:	f6cff0ef          	jal	ra,ffffffffc0202a70 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203308:	048a0d63          	beq	s4,s0,ffffffffc0203362 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc020330c:	0009b783          	ld	a5,0(s3)
ffffffffc0203310:	8656                	mv	a2,s5
ffffffffc0203312:	002c                	addi	a1,sp,8
ffffffffc0203314:	7b9c                	ld	a5,48(a5)
ffffffffc0203316:	854a                	mv	a0,s2
ffffffffc0203318:	9782                	jalr	a5
          if (r != 0) {
ffffffffc020331a:	e12d                	bnez	a0,ffffffffc020337c <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc020331c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020331e:	01893503          	ld	a0,24(s2)
ffffffffc0203322:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203324:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203326:	85a6                	mv	a1,s1
ffffffffc0203328:	959fe0ef          	jal	ra,ffffffffc0201c80 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc020332c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020332e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203330:	8b85                	andi	a5,a5,1
ffffffffc0203332:	cfb9                	beqz	a5,ffffffffc0203390 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203334:	65a2                	ld	a1,8(sp)
ffffffffc0203336:	7d9c                	ld	a5,56(a1)
ffffffffc0203338:	83b1                	srli	a5,a5,0xc
ffffffffc020333a:	00178513          	addi	a0,a5,1
ffffffffc020333e:	0522                	slli	a0,a0,0x8
ffffffffc0203340:	47d000ef          	jal	ra,ffffffffc0203fbc <swapfs_write>
ffffffffc0203344:	d949                	beqz	a0,ffffffffc02032d6 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203346:	855e                	mv	a0,s7
ffffffffc0203348:	e47fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020334c:	0009b783          	ld	a5,0(s3)
ffffffffc0203350:	6622                	ld	a2,8(sp)
ffffffffc0203352:	4681                	li	a3,0
ffffffffc0203354:	739c                	ld	a5,32(a5)
ffffffffc0203356:	85a6                	mv	a1,s1
ffffffffc0203358:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc020335a:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc020335c:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020335e:	fa8a17e3          	bne	s4,s0,ffffffffc020330c <swap_out+0x70>
}
ffffffffc0203362:	8522                	mv	a0,s0
ffffffffc0203364:	60e6                	ld	ra,88(sp)
ffffffffc0203366:	6446                	ld	s0,80(sp)
ffffffffc0203368:	64a6                	ld	s1,72(sp)
ffffffffc020336a:	6906                	ld	s2,64(sp)
ffffffffc020336c:	79e2                	ld	s3,56(sp)
ffffffffc020336e:	7a42                	ld	s4,48(sp)
ffffffffc0203370:	7aa2                	ld	s5,40(sp)
ffffffffc0203372:	7b02                	ld	s6,32(sp)
ffffffffc0203374:	6be2                	ld	s7,24(sp)
ffffffffc0203376:	6c42                	ld	s8,16(sp)
ffffffffc0203378:	6125                	addi	sp,sp,96
ffffffffc020337a:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc020337c:	85a2                	mv	a1,s0
ffffffffc020337e:	00003517          	auipc	a0,0x3
ffffffffc0203382:	06a50513          	addi	a0,a0,106 # ffffffffc02063e8 <default_pmm_manager+0x960>
ffffffffc0203386:	e09fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc020338a:	bfe1                	j	ffffffffc0203362 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc020338c:	4401                	li	s0,0
ffffffffc020338e:	bfd1                	j	ffffffffc0203362 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203390:	00003697          	auipc	a3,0x3
ffffffffc0203394:	08868693          	addi	a3,a3,136 # ffffffffc0206418 <default_pmm_manager+0x990>
ffffffffc0203398:	00002617          	auipc	a2,0x2
ffffffffc020339c:	35860613          	addi	a2,a2,856 # ffffffffc02056f0 <commands+0x870>
ffffffffc02033a0:	06900593          	li	a1,105
ffffffffc02033a4:	00003517          	auipc	a0,0x3
ffffffffc02033a8:	dbc50513          	addi	a0,a0,-580 # ffffffffc0206160 <default_pmm_manager+0x6d8>
ffffffffc02033ac:	8a4fd0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02033b0 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc02033b0:	00012797          	auipc	a5,0x12
ffffffffc02033b4:	22078793          	addi	a5,a5,544 # ffffffffc02155d0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc02033b8:	f51c                	sd	a5,40(a0)
ffffffffc02033ba:	e79c                	sd	a5,8(a5)
ffffffffc02033bc:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc02033be:	4501                	li	a0,0
ffffffffc02033c0:	8082                	ret

ffffffffc02033c2 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc02033c2:	4501                	li	a0,0
ffffffffc02033c4:	8082                	ret

ffffffffc02033c6 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc02033c6:	4501                	li	a0,0
ffffffffc02033c8:	8082                	ret

ffffffffc02033ca <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02033ca:	4501                	li	a0,0
ffffffffc02033cc:	8082                	ret

ffffffffc02033ce <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc02033ce:	711d                	addi	sp,sp,-96
ffffffffc02033d0:	fc4e                	sd	s3,56(sp)
ffffffffc02033d2:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02033d4:	00003517          	auipc	a0,0x3
ffffffffc02033d8:	0b450513          	addi	a0,a0,180 # ffffffffc0206488 <default_pmm_manager+0xa00>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02033dc:	698d                	lui	s3,0x3
ffffffffc02033de:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc02033e0:	e8a2                	sd	s0,80(sp)
ffffffffc02033e2:	e4a6                	sd	s1,72(sp)
ffffffffc02033e4:	ec86                	sd	ra,88(sp)
ffffffffc02033e6:	e0ca                	sd	s2,64(sp)
ffffffffc02033e8:	f456                	sd	s5,40(sp)
ffffffffc02033ea:	f05a                	sd	s6,32(sp)
ffffffffc02033ec:	ec5e                	sd	s7,24(sp)
ffffffffc02033ee:	e862                	sd	s8,16(sp)
ffffffffc02033f0:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc02033f2:	00012417          	auipc	s0,0x12
ffffffffc02033f6:	0b240413          	addi	s0,s0,178 # ffffffffc02154a4 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02033fa:	d95fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02033fe:	01498023          	sb	s4,0(s3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203402:	4004                	lw	s1,0(s0)
ffffffffc0203404:	4791                	li	a5,4
ffffffffc0203406:	2481                	sext.w	s1,s1
ffffffffc0203408:	14f49f63          	bne	s1,a5,ffffffffc0203566 <_fifo_check_swap+0x198>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020340c:	00003517          	auipc	a0,0x3
ffffffffc0203410:	0bc50513          	addi	a0,a0,188 # ffffffffc02064c8 <default_pmm_manager+0xa40>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203414:	6a85                	lui	s5,0x1
ffffffffc0203416:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203418:	d77fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020341c:	016a8023          	sb	s6,0(s5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203420:	00042903          	lw	s2,0(s0)
ffffffffc0203424:	2901                	sext.w	s2,s2
ffffffffc0203426:	2c991063          	bne	s2,s1,ffffffffc02036e6 <_fifo_check_swap+0x318>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020342a:	00003517          	auipc	a0,0x3
ffffffffc020342e:	0c650513          	addi	a0,a0,198 # ffffffffc02064f0 <default_pmm_manager+0xa68>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203432:	6b91                	lui	s7,0x4
ffffffffc0203434:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203436:	d59fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020343a:	018b8023          	sb	s8,0(s7) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc020343e:	4004                	lw	s1,0(s0)
ffffffffc0203440:	2481                	sext.w	s1,s1
ffffffffc0203442:	29249263          	bne	s1,s2,ffffffffc02036c6 <_fifo_check_swap+0x2f8>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203446:	00003517          	auipc	a0,0x3
ffffffffc020344a:	0d250513          	addi	a0,a0,210 # ffffffffc0206518 <default_pmm_manager+0xa90>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020344e:	6909                	lui	s2,0x2
ffffffffc0203450:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203452:	d3dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203456:	01990023          	sb	s9,0(s2) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc020345a:	401c                	lw	a5,0(s0)
ffffffffc020345c:	2781                	sext.w	a5,a5
ffffffffc020345e:	24979463          	bne	a5,s1,ffffffffc02036a6 <_fifo_check_swap+0x2d8>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203462:	00003517          	auipc	a0,0x3
ffffffffc0203466:	0de50513          	addi	a0,a0,222 # ffffffffc0206540 <default_pmm_manager+0xab8>
ffffffffc020346a:	d25fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020346e:	6795                	lui	a5,0x5
ffffffffc0203470:	4739                	li	a4,14
ffffffffc0203472:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203476:	4004                	lw	s1,0(s0)
ffffffffc0203478:	4795                	li	a5,5
ffffffffc020347a:	2481                	sext.w	s1,s1
ffffffffc020347c:	20f49563          	bne	s1,a5,ffffffffc0203686 <_fifo_check_swap+0x2b8>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203480:	00003517          	auipc	a0,0x3
ffffffffc0203484:	09850513          	addi	a0,a0,152 # ffffffffc0206518 <default_pmm_manager+0xa90>
ffffffffc0203488:	d07fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020348c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203490:	401c                	lw	a5,0(s0)
ffffffffc0203492:	2781                	sext.w	a5,a5
ffffffffc0203494:	1c979963          	bne	a5,s1,ffffffffc0203666 <_fifo_check_swap+0x298>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203498:	00003517          	auipc	a0,0x3
ffffffffc020349c:	03050513          	addi	a0,a0,48 # ffffffffc02064c8 <default_pmm_manager+0xa40>
ffffffffc02034a0:	ceffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("here\n\n\n");
ffffffffc02034a4:	00003517          	auipc	a0,0x3
ffffffffc02034a8:	0d450513          	addi	a0,a0,212 # ffffffffc0206578 <default_pmm_manager+0xaf0>
ffffffffc02034ac:	ce3fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02034b0:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02034b4:	401c                	lw	a5,0(s0)
ffffffffc02034b6:	4719                	li	a4,6
ffffffffc02034b8:	2781                	sext.w	a5,a5
ffffffffc02034ba:	18e79663          	bne	a5,a4,ffffffffc0203646 <_fifo_check_swap+0x278>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02034be:	00003517          	auipc	a0,0x3
ffffffffc02034c2:	05a50513          	addi	a0,a0,90 # ffffffffc0206518 <default_pmm_manager+0xa90>
ffffffffc02034c6:	cc9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02034ca:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02034ce:	401c                	lw	a5,0(s0)
ffffffffc02034d0:	471d                	li	a4,7
ffffffffc02034d2:	2781                	sext.w	a5,a5
ffffffffc02034d4:	14e79963          	bne	a5,a4,ffffffffc0203626 <_fifo_check_swap+0x258>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02034d8:	00003517          	auipc	a0,0x3
ffffffffc02034dc:	fb050513          	addi	a0,a0,-80 # ffffffffc0206488 <default_pmm_manager+0xa00>
ffffffffc02034e0:	caffc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02034e4:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc02034e8:	401c                	lw	a5,0(s0)
ffffffffc02034ea:	4721                	li	a4,8
ffffffffc02034ec:	2781                	sext.w	a5,a5
ffffffffc02034ee:	10e79c63          	bne	a5,a4,ffffffffc0203606 <_fifo_check_swap+0x238>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc02034f2:	00003517          	auipc	a0,0x3
ffffffffc02034f6:	ffe50513          	addi	a0,a0,-2 # ffffffffc02064f0 <default_pmm_manager+0xa68>
ffffffffc02034fa:	c95fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02034fe:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203502:	401c                	lw	a5,0(s0)
ffffffffc0203504:	4725                	li	a4,9
ffffffffc0203506:	2781                	sext.w	a5,a5
ffffffffc0203508:	0ce79f63          	bne	a5,a4,ffffffffc02035e6 <_fifo_check_swap+0x218>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020350c:	00003517          	auipc	a0,0x3
ffffffffc0203510:	03450513          	addi	a0,a0,52 # ffffffffc0206540 <default_pmm_manager+0xab8>
ffffffffc0203514:	c7bfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203518:	6795                	lui	a5,0x5
ffffffffc020351a:	4739                	li	a4,14
ffffffffc020351c:	00e78023          	sb	a4,0(a5) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==10);
ffffffffc0203520:	4004                	lw	s1,0(s0)
ffffffffc0203522:	47a9                	li	a5,10
ffffffffc0203524:	2481                	sext.w	s1,s1
ffffffffc0203526:	0af49063          	bne	s1,a5,ffffffffc02035c6 <_fifo_check_swap+0x1f8>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020352a:	00003517          	auipc	a0,0x3
ffffffffc020352e:	f9e50513          	addi	a0,a0,-98 # ffffffffc02064c8 <default_pmm_manager+0xa40>
ffffffffc0203532:	c5dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203536:	6785                	lui	a5,0x1
ffffffffc0203538:	0007c783          	lbu	a5,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc020353c:	06979563          	bne	a5,s1,ffffffffc02035a6 <_fifo_check_swap+0x1d8>
    assert(pgfault_num==11);
ffffffffc0203540:	401c                	lw	a5,0(s0)
ffffffffc0203542:	472d                	li	a4,11
ffffffffc0203544:	2781                	sext.w	a5,a5
ffffffffc0203546:	04e79063          	bne	a5,a4,ffffffffc0203586 <_fifo_check_swap+0x1b8>
}
ffffffffc020354a:	60e6                	ld	ra,88(sp)
ffffffffc020354c:	6446                	ld	s0,80(sp)
ffffffffc020354e:	64a6                	ld	s1,72(sp)
ffffffffc0203550:	6906                	ld	s2,64(sp)
ffffffffc0203552:	79e2                	ld	s3,56(sp)
ffffffffc0203554:	7a42                	ld	s4,48(sp)
ffffffffc0203556:	7aa2                	ld	s5,40(sp)
ffffffffc0203558:	7b02                	ld	s6,32(sp)
ffffffffc020355a:	6be2                	ld	s7,24(sp)
ffffffffc020355c:	6c42                	ld	s8,16(sp)
ffffffffc020355e:	6ca2                	ld	s9,8(sp)
ffffffffc0203560:	4501                	li	a0,0
ffffffffc0203562:	6125                	addi	sp,sp,96
ffffffffc0203564:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203566:	00003697          	auipc	a3,0x3
ffffffffc020356a:	dc268693          	addi	a3,a3,-574 # ffffffffc0206328 <default_pmm_manager+0x8a0>
ffffffffc020356e:	00002617          	auipc	a2,0x2
ffffffffc0203572:	18260613          	addi	a2,a2,386 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203576:	05100593          	li	a1,81
ffffffffc020357a:	00003517          	auipc	a0,0x3
ffffffffc020357e:	f3650513          	addi	a0,a0,-202 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203582:	ecffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==11);
ffffffffc0203586:	00003697          	auipc	a3,0x3
ffffffffc020358a:	07268693          	addi	a3,a3,114 # ffffffffc02065f8 <default_pmm_manager+0xb70>
ffffffffc020358e:	00002617          	auipc	a2,0x2
ffffffffc0203592:	16260613          	addi	a2,a2,354 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203596:	07400593          	li	a1,116
ffffffffc020359a:	00003517          	auipc	a0,0x3
ffffffffc020359e:	f1650513          	addi	a0,a0,-234 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc02035a2:	eaffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02035a6:	00003697          	auipc	a3,0x3
ffffffffc02035aa:	02a68693          	addi	a3,a3,42 # ffffffffc02065d0 <default_pmm_manager+0xb48>
ffffffffc02035ae:	00002617          	auipc	a2,0x2
ffffffffc02035b2:	14260613          	addi	a2,a2,322 # ffffffffc02056f0 <commands+0x870>
ffffffffc02035b6:	07200593          	li	a1,114
ffffffffc02035ba:	00003517          	auipc	a0,0x3
ffffffffc02035be:	ef650513          	addi	a0,a0,-266 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc02035c2:	e8ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==10);
ffffffffc02035c6:	00003697          	auipc	a3,0x3
ffffffffc02035ca:	ffa68693          	addi	a3,a3,-6 # ffffffffc02065c0 <default_pmm_manager+0xb38>
ffffffffc02035ce:	00002617          	auipc	a2,0x2
ffffffffc02035d2:	12260613          	addi	a2,a2,290 # ffffffffc02056f0 <commands+0x870>
ffffffffc02035d6:	07000593          	li	a1,112
ffffffffc02035da:	00003517          	auipc	a0,0x3
ffffffffc02035de:	ed650513          	addi	a0,a0,-298 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc02035e2:	e6ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==9);
ffffffffc02035e6:	00003697          	auipc	a3,0x3
ffffffffc02035ea:	fca68693          	addi	a3,a3,-54 # ffffffffc02065b0 <default_pmm_manager+0xb28>
ffffffffc02035ee:	00002617          	auipc	a2,0x2
ffffffffc02035f2:	10260613          	addi	a2,a2,258 # ffffffffc02056f0 <commands+0x870>
ffffffffc02035f6:	06d00593          	li	a1,109
ffffffffc02035fa:	00003517          	auipc	a0,0x3
ffffffffc02035fe:	eb650513          	addi	a0,a0,-330 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203602:	e4ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==8);
ffffffffc0203606:	00003697          	auipc	a3,0x3
ffffffffc020360a:	f9a68693          	addi	a3,a3,-102 # ffffffffc02065a0 <default_pmm_manager+0xb18>
ffffffffc020360e:	00002617          	auipc	a2,0x2
ffffffffc0203612:	0e260613          	addi	a2,a2,226 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203616:	06a00593          	li	a1,106
ffffffffc020361a:	00003517          	auipc	a0,0x3
ffffffffc020361e:	e9650513          	addi	a0,a0,-362 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203622:	e2ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==7);
ffffffffc0203626:	00003697          	auipc	a3,0x3
ffffffffc020362a:	f6a68693          	addi	a3,a3,-150 # ffffffffc0206590 <default_pmm_manager+0xb08>
ffffffffc020362e:	00002617          	auipc	a2,0x2
ffffffffc0203632:	0c260613          	addi	a2,a2,194 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203636:	06700593          	li	a1,103
ffffffffc020363a:	00003517          	auipc	a0,0x3
ffffffffc020363e:	e7650513          	addi	a0,a0,-394 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203642:	e0ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==6);
ffffffffc0203646:	00003697          	auipc	a3,0x3
ffffffffc020364a:	f3a68693          	addi	a3,a3,-198 # ffffffffc0206580 <default_pmm_manager+0xaf8>
ffffffffc020364e:	00002617          	auipc	a2,0x2
ffffffffc0203652:	0a260613          	addi	a2,a2,162 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203656:	06400593          	li	a1,100
ffffffffc020365a:	00003517          	auipc	a0,0x3
ffffffffc020365e:	e5650513          	addi	a0,a0,-426 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203662:	deffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc0203666:	00003697          	auipc	a3,0x3
ffffffffc020366a:	f0268693          	addi	a3,a3,-254 # ffffffffc0206568 <default_pmm_manager+0xae0>
ffffffffc020366e:	00002617          	auipc	a2,0x2
ffffffffc0203672:	08260613          	addi	a2,a2,130 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203676:	06000593          	li	a1,96
ffffffffc020367a:	00003517          	auipc	a0,0x3
ffffffffc020367e:	e3650513          	addi	a0,a0,-458 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203682:	dcffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==5);
ffffffffc0203686:	00003697          	auipc	a3,0x3
ffffffffc020368a:	ee268693          	addi	a3,a3,-286 # ffffffffc0206568 <default_pmm_manager+0xae0>
ffffffffc020368e:	00002617          	auipc	a2,0x2
ffffffffc0203692:	06260613          	addi	a2,a2,98 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203696:	05d00593          	li	a1,93
ffffffffc020369a:	00003517          	auipc	a0,0x3
ffffffffc020369e:	e1650513          	addi	a0,a0,-490 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc02036a2:	daffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02036a6:	00003697          	auipc	a3,0x3
ffffffffc02036aa:	c8268693          	addi	a3,a3,-894 # ffffffffc0206328 <default_pmm_manager+0x8a0>
ffffffffc02036ae:	00002617          	auipc	a2,0x2
ffffffffc02036b2:	04260613          	addi	a2,a2,66 # ffffffffc02056f0 <commands+0x870>
ffffffffc02036b6:	05a00593          	li	a1,90
ffffffffc02036ba:	00003517          	auipc	a0,0x3
ffffffffc02036be:	df650513          	addi	a0,a0,-522 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc02036c2:	d8ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02036c6:	00003697          	auipc	a3,0x3
ffffffffc02036ca:	c6268693          	addi	a3,a3,-926 # ffffffffc0206328 <default_pmm_manager+0x8a0>
ffffffffc02036ce:	00002617          	auipc	a2,0x2
ffffffffc02036d2:	02260613          	addi	a2,a2,34 # ffffffffc02056f0 <commands+0x870>
ffffffffc02036d6:	05700593          	li	a1,87
ffffffffc02036da:	00003517          	auipc	a0,0x3
ffffffffc02036de:	dd650513          	addi	a0,a0,-554 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc02036e2:	d6ffc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgfault_num==4);
ffffffffc02036e6:	00003697          	auipc	a3,0x3
ffffffffc02036ea:	c4268693          	addi	a3,a3,-958 # ffffffffc0206328 <default_pmm_manager+0x8a0>
ffffffffc02036ee:	00002617          	auipc	a2,0x2
ffffffffc02036f2:	00260613          	addi	a2,a2,2 # ffffffffc02056f0 <commands+0x870>
ffffffffc02036f6:	05400593          	li	a1,84
ffffffffc02036fa:	00003517          	auipc	a0,0x3
ffffffffc02036fe:	db650513          	addi	a0,a0,-586 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203702:	d4ffc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203706 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203706:	751c                	ld	a5,40(a0)
{
ffffffffc0203708:	1141                	addi	sp,sp,-16
ffffffffc020370a:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc020370c:	cf91                	beqz	a5,ffffffffc0203728 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc020370e:	ee0d                	bnez	a2,ffffffffc0203748 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203710:	679c                	ld	a5,8(a5)
}
ffffffffc0203712:	60a2                	ld	ra,8(sp)
ffffffffc0203714:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203716:	6394                	ld	a3,0(a5)
ffffffffc0203718:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc020371a:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020371e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203720:	e314                	sd	a3,0(a4)
ffffffffc0203722:	e19c                	sd	a5,0(a1)
}
ffffffffc0203724:	0141                	addi	sp,sp,16
ffffffffc0203726:	8082                	ret
         assert(head != NULL);
ffffffffc0203728:	00003697          	auipc	a3,0x3
ffffffffc020372c:	f0068693          	addi	a3,a3,-256 # ffffffffc0206628 <default_pmm_manager+0xba0>
ffffffffc0203730:	00002617          	auipc	a2,0x2
ffffffffc0203734:	fc060613          	addi	a2,a2,-64 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203738:	04100593          	li	a1,65
ffffffffc020373c:	00003517          	auipc	a0,0x3
ffffffffc0203740:	d7450513          	addi	a0,a0,-652 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203744:	d0dfc0ef          	jal	ra,ffffffffc0200450 <__panic>
     assert(in_tick==0);
ffffffffc0203748:	00003697          	auipc	a3,0x3
ffffffffc020374c:	ef068693          	addi	a3,a3,-272 # ffffffffc0206638 <default_pmm_manager+0xbb0>
ffffffffc0203750:	00002617          	auipc	a2,0x2
ffffffffc0203754:	fa060613          	addi	a2,a2,-96 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203758:	04200593          	li	a1,66
ffffffffc020375c:	00003517          	auipc	a0,0x3
ffffffffc0203760:	d5450513          	addi	a0,a0,-684 # ffffffffc02064b0 <default_pmm_manager+0xa28>
ffffffffc0203764:	cedfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203768 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203768:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020376c:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020376e:	cb09                	beqz	a4,ffffffffc0203780 <_fifo_map_swappable+0x18>
ffffffffc0203770:	cb81                	beqz	a5,ffffffffc0203780 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203772:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203774:	e398                	sd	a4,0(a5)
}
ffffffffc0203776:	4501                	li	a0,0
ffffffffc0203778:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020377a:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020377c:	f614                	sd	a3,40(a2)
ffffffffc020377e:	8082                	ret
{
ffffffffc0203780:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203782:	00003697          	auipc	a3,0x3
ffffffffc0203786:	e8668693          	addi	a3,a3,-378 # ffffffffc0206608 <default_pmm_manager+0xb80>
ffffffffc020378a:	00002617          	auipc	a2,0x2
ffffffffc020378e:	f6660613          	addi	a2,a2,-154 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203792:	03200593          	li	a1,50
ffffffffc0203796:	00003517          	auipc	a0,0x3
ffffffffc020379a:	d1a50513          	addi	a0,a0,-742 # ffffffffc02064b0 <default_pmm_manager+0xa28>
{
ffffffffc020379e:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02037a0:	cb1fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02037a4 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02037a4:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02037a6:	00003697          	auipc	a3,0x3
ffffffffc02037aa:	eba68693          	addi	a3,a3,-326 # ffffffffc0206660 <default_pmm_manager+0xbd8>
ffffffffc02037ae:	00002617          	auipc	a2,0x2
ffffffffc02037b2:	f4260613          	addi	a2,a2,-190 # ffffffffc02056f0 <commands+0x870>
ffffffffc02037b6:	07e00593          	li	a1,126
ffffffffc02037ba:	00003517          	auipc	a0,0x3
ffffffffc02037be:	ec650513          	addi	a0,a0,-314 # ffffffffc0206680 <default_pmm_manager+0xbf8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02037c2:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02037c4:	c8dfc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02037c8 <mm_create>:
mm_create(void) {
ffffffffc02037c8:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037ca:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02037ce:	e022                	sd	s0,0(sp)
ffffffffc02037d0:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037d2:	9a4fe0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc02037d6:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02037d8:	c115                	beqz	a0,ffffffffc02037fc <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037da:	00012797          	auipc	a5,0x12
ffffffffc02037de:	cc678793          	addi	a5,a5,-826 # ffffffffc02154a0 <swap_init_ok>
ffffffffc02037e2:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02037e4:	e408                	sd	a0,8(s0)
ffffffffc02037e6:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02037e8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037ec:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037f0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02037f4:	2781                	sext.w	a5,a5
ffffffffc02037f6:	eb81                	bnez	a5,ffffffffc0203806 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc02037f8:	02053423          	sd	zero,40(a0)
}
ffffffffc02037fc:	8522                	mv	a0,s0
ffffffffc02037fe:	60a2                	ld	ra,8(sp)
ffffffffc0203800:	6402                	ld	s0,0(sp)
ffffffffc0203802:	0141                	addi	sp,sp,16
ffffffffc0203804:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203806:	a77ff0ef          	jal	ra,ffffffffc020327c <swap_init_mm>
}
ffffffffc020380a:	8522                	mv	a0,s0
ffffffffc020380c:	60a2                	ld	ra,8(sp)
ffffffffc020380e:	6402                	ld	s0,0(sp)
ffffffffc0203810:	0141                	addi	sp,sp,16
ffffffffc0203812:	8082                	ret

ffffffffc0203814 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0203814:	1101                	addi	sp,sp,-32
ffffffffc0203816:	e04a                	sd	s2,0(sp)
ffffffffc0203818:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020381a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020381e:	e822                	sd	s0,16(sp)
ffffffffc0203820:	e426                	sd	s1,8(sp)
ffffffffc0203822:	ec06                	sd	ra,24(sp)
ffffffffc0203824:	84ae                	mv	s1,a1
ffffffffc0203826:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203828:	94efe0ef          	jal	ra,ffffffffc0201976 <kmalloc>
    if (vma != NULL) {
ffffffffc020382c:	c509                	beqz	a0,ffffffffc0203836 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020382e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203832:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203834:	cd00                	sw	s0,24(a0)
}
ffffffffc0203836:	60e2                	ld	ra,24(sp)
ffffffffc0203838:	6442                	ld	s0,16(sp)
ffffffffc020383a:	64a2                	ld	s1,8(sp)
ffffffffc020383c:	6902                	ld	s2,0(sp)
ffffffffc020383e:	6105                	addi	sp,sp,32
ffffffffc0203840:	8082                	ret

ffffffffc0203842 <find_vma>:
    if (mm != NULL) {
ffffffffc0203842:	c51d                	beqz	a0,ffffffffc0203870 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0203844:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203846:	c781                	beqz	a5,ffffffffc020384e <find_vma+0xc>
ffffffffc0203848:	6798                	ld	a4,8(a5)
ffffffffc020384a:	02e5f663          	bleu	a4,a1,ffffffffc0203876 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020384e:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0203850:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0203852:	00f50f63          	beq	a0,a5,ffffffffc0203870 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0203856:	fe87b703          	ld	a4,-24(a5)
ffffffffc020385a:	fee5ebe3          	bltu	a1,a4,ffffffffc0203850 <find_vma+0xe>
ffffffffc020385e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203862:	fee5f7e3          	bleu	a4,a1,ffffffffc0203850 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0203866:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0203868:	c781                	beqz	a5,ffffffffc0203870 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020386a:	e91c                	sd	a5,16(a0)
}
ffffffffc020386c:	853e                	mv	a0,a5
ffffffffc020386e:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203870:	4781                	li	a5,0
}
ffffffffc0203872:	853e                	mv	a0,a5
ffffffffc0203874:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203876:	6b98                	ld	a4,16(a5)
ffffffffc0203878:	fce5fbe3          	bleu	a4,a1,ffffffffc020384e <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020387c:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020387e:	b7fd                	j	ffffffffc020386c <find_vma+0x2a>

ffffffffc0203880 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203880:	6590                	ld	a2,8(a1)
ffffffffc0203882:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203886:	1141                	addi	sp,sp,-16
ffffffffc0203888:	e406                	sd	ra,8(sp)
ffffffffc020388a:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020388c:	01066863          	bltu	a2,a6,ffffffffc020389c <insert_vma_struct+0x1c>
ffffffffc0203890:	a8b9                	j	ffffffffc02038ee <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203892:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203896:	04d66763          	bltu	a2,a3,ffffffffc02038e4 <insert_vma_struct+0x64>
ffffffffc020389a:	873e                	mv	a4,a5
ffffffffc020389c:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020389e:	fef51ae3          	bne	a0,a5,ffffffffc0203892 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02038a2:	02a70463          	beq	a4,a0,ffffffffc02038ca <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02038a6:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02038aa:	fe873883          	ld	a7,-24(a4)
ffffffffc02038ae:	08d8f063          	bleu	a3,a7,ffffffffc020392e <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038b2:	04d66e63          	bltu	a2,a3,ffffffffc020390e <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02038b6:	00f50a63          	beq	a0,a5,ffffffffc02038ca <insert_vma_struct+0x4a>
ffffffffc02038ba:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038be:	0506e863          	bltu	a3,a6,ffffffffc020390e <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02038c2:	ff07b603          	ld	a2,-16(a5)
ffffffffc02038c6:	02c6f263          	bleu	a2,a3,ffffffffc02038ea <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02038ca:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02038cc:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02038ce:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02038d2:	e390                	sd	a2,0(a5)
ffffffffc02038d4:	e710                	sd	a2,8(a4)
}
ffffffffc02038d6:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02038d8:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02038da:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02038dc:	2685                	addiw	a3,a3,1
ffffffffc02038de:	d114                	sw	a3,32(a0)
}
ffffffffc02038e0:	0141                	addi	sp,sp,16
ffffffffc02038e2:	8082                	ret
    if (le_prev != list) {
ffffffffc02038e4:	fca711e3          	bne	a4,a0,ffffffffc02038a6 <insert_vma_struct+0x26>
ffffffffc02038e8:	bfd9                	j	ffffffffc02038be <insert_vma_struct+0x3e>
ffffffffc02038ea:	ebbff0ef          	jal	ra,ffffffffc02037a4 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038ee:	00003697          	auipc	a3,0x3
ffffffffc02038f2:	e4268693          	addi	a3,a3,-446 # ffffffffc0206730 <default_pmm_manager+0xca8>
ffffffffc02038f6:	00002617          	auipc	a2,0x2
ffffffffc02038fa:	dfa60613          	addi	a2,a2,-518 # ffffffffc02056f0 <commands+0x870>
ffffffffc02038fe:	08500593          	li	a1,133
ffffffffc0203902:	00003517          	auipc	a0,0x3
ffffffffc0203906:	d7e50513          	addi	a0,a0,-642 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc020390a:	b47fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020390e:	00003697          	auipc	a3,0x3
ffffffffc0203912:	e6268693          	addi	a3,a3,-414 # ffffffffc0206770 <default_pmm_manager+0xce8>
ffffffffc0203916:	00002617          	auipc	a2,0x2
ffffffffc020391a:	dda60613          	addi	a2,a2,-550 # ffffffffc02056f0 <commands+0x870>
ffffffffc020391e:	07d00593          	li	a1,125
ffffffffc0203922:	00003517          	auipc	a0,0x3
ffffffffc0203926:	d5e50513          	addi	a0,a0,-674 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc020392a:	b27fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020392e:	00003697          	auipc	a3,0x3
ffffffffc0203932:	e2268693          	addi	a3,a3,-478 # ffffffffc0206750 <default_pmm_manager+0xcc8>
ffffffffc0203936:	00002617          	auipc	a2,0x2
ffffffffc020393a:	dba60613          	addi	a2,a2,-582 # ffffffffc02056f0 <commands+0x870>
ffffffffc020393e:	07c00593          	li	a1,124
ffffffffc0203942:	00003517          	auipc	a0,0x3
ffffffffc0203946:	d3e50513          	addi	a0,a0,-706 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc020394a:	b07fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc020394e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc020394e:	1141                	addi	sp,sp,-16
ffffffffc0203950:	e022                	sd	s0,0(sp)
ffffffffc0203952:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203954:	6508                	ld	a0,8(a0)
ffffffffc0203956:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0203958:	00a40c63          	beq	s0,a0,ffffffffc0203970 <mm_destroy+0x22>
    __list_del(listelm->prev, listelm->next);
ffffffffc020395c:	6118                	ld	a4,0(a0)
ffffffffc020395e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0203960:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203962:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203964:	e398                	sd	a4,0(a5)
ffffffffc0203966:	8ccfe0ef          	jal	ra,ffffffffc0201a32 <kfree>
    return listelm->next;
ffffffffc020396a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020396c:	fea418e3          	bne	s0,a0,ffffffffc020395c <mm_destroy+0xe>
    }
    kfree(mm); //kfree mm
ffffffffc0203970:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203972:	6402                	ld	s0,0(sp)
ffffffffc0203974:	60a2                	ld	ra,8(sp)
ffffffffc0203976:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0203978:	8bafe06f          	j	ffffffffc0201a32 <kfree>

ffffffffc020397c <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc020397c:	7139                	addi	sp,sp,-64
ffffffffc020397e:	f822                	sd	s0,48(sp)
ffffffffc0203980:	f426                	sd	s1,40(sp)
ffffffffc0203982:	fc06                	sd	ra,56(sp)
ffffffffc0203984:	f04a                	sd	s2,32(sp)
ffffffffc0203986:	ec4e                	sd	s3,24(sp)
ffffffffc0203988:	e852                	sd	s4,16(sp)
ffffffffc020398a:	e456                	sd	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    struct mm_struct *mm = mm_create();
ffffffffc020398c:	e3dff0ef          	jal	ra,ffffffffc02037c8 <mm_create>
    assert(mm != NULL);
ffffffffc0203990:	842a                	mv	s0,a0
ffffffffc0203992:	03200493          	li	s1,50
ffffffffc0203996:	e919                	bnez	a0,ffffffffc02039ac <vmm_init+0x30>
ffffffffc0203998:	a989                	j	ffffffffc0203dea <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc020399a:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc020399c:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020399e:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039a2:	14ed                	addi	s1,s1,-5
ffffffffc02039a4:	8522                	mv	a0,s0
ffffffffc02039a6:	edbff0ef          	jal	ra,ffffffffc0203880 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02039aa:	c88d                	beqz	s1,ffffffffc02039dc <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039ac:	03000513          	li	a0,48
ffffffffc02039b0:	fc7fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc02039b4:	85aa                	mv	a1,a0
ffffffffc02039b6:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02039ba:	f165                	bnez	a0,ffffffffc020399a <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02039bc:	00003697          	auipc	a3,0x3
ffffffffc02039c0:	82c68693          	addi	a3,a3,-2004 # ffffffffc02061e8 <default_pmm_manager+0x760>
ffffffffc02039c4:	00002617          	auipc	a2,0x2
ffffffffc02039c8:	d2c60613          	addi	a2,a2,-724 # ffffffffc02056f0 <commands+0x870>
ffffffffc02039cc:	0c900593          	li	a1,201
ffffffffc02039d0:	00003517          	auipc	a0,0x3
ffffffffc02039d4:	cb050513          	addi	a0,a0,-848 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc02039d8:	a79fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02039dc:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02039e0:	1f900913          	li	s2,505
ffffffffc02039e4:	a819                	j	ffffffffc02039fa <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02039e6:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02039e8:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02039ea:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039ee:	0495                	addi	s1,s1,5
ffffffffc02039f0:	8522                	mv	a0,s0
ffffffffc02039f2:	e8fff0ef          	jal	ra,ffffffffc0203880 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02039f6:	03248a63          	beq	s1,s2,ffffffffc0203a2a <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039fa:	03000513          	li	a0,48
ffffffffc02039fe:	f79fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc0203a02:	85aa                	mv	a1,a0
ffffffffc0203a04:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203a08:	fd79                	bnez	a0,ffffffffc02039e6 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0203a0a:	00002697          	auipc	a3,0x2
ffffffffc0203a0e:	7de68693          	addi	a3,a3,2014 # ffffffffc02061e8 <default_pmm_manager+0x760>
ffffffffc0203a12:	00002617          	auipc	a2,0x2
ffffffffc0203a16:	cde60613          	addi	a2,a2,-802 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203a1a:	0cf00593          	li	a1,207
ffffffffc0203a1e:	00003517          	auipc	a0,0x3
ffffffffc0203a22:	c6250513          	addi	a0,a0,-926 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203a26:	a2bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203a2a:	6418                	ld	a4,8(s0)
ffffffffc0203a2c:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0203a2e:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0203a32:	2ee40063          	beq	s0,a4,ffffffffc0203d12 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a36:	fe873603          	ld	a2,-24(a4)
ffffffffc0203a3a:	ffe78693          	addi	a3,a5,-2
ffffffffc0203a3e:	24d61a63          	bne	a2,a3,ffffffffc0203c92 <vmm_init+0x316>
ffffffffc0203a42:	ff073683          	ld	a3,-16(a4)
ffffffffc0203a46:	24f69663          	bne	a3,a5,ffffffffc0203c92 <vmm_init+0x316>
ffffffffc0203a4a:	0795                	addi	a5,a5,5
ffffffffc0203a4c:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0203a4e:	feb792e3          	bne	a5,a1,ffffffffc0203a32 <vmm_init+0xb6>
ffffffffc0203a52:	491d                	li	s2,7
ffffffffc0203a54:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203a56:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203a5a:	85a6                	mv	a1,s1
ffffffffc0203a5c:	8522                	mv	a0,s0
ffffffffc0203a5e:	de5ff0ef          	jal	ra,ffffffffc0203842 <find_vma>
ffffffffc0203a62:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203a64:	30050763          	beqz	a0,ffffffffc0203d72 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203a68:	00148593          	addi	a1,s1,1
ffffffffc0203a6c:	8522                	mv	a0,s0
ffffffffc0203a6e:	dd5ff0ef          	jal	ra,ffffffffc0203842 <find_vma>
ffffffffc0203a72:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203a74:	2c050f63          	beqz	a0,ffffffffc0203d52 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203a78:	85ca                	mv	a1,s2
ffffffffc0203a7a:	8522                	mv	a0,s0
ffffffffc0203a7c:	dc7ff0ef          	jal	ra,ffffffffc0203842 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203a80:	2a051963          	bnez	a0,ffffffffc0203d32 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203a84:	00348593          	addi	a1,s1,3
ffffffffc0203a88:	8522                	mv	a0,s0
ffffffffc0203a8a:	db9ff0ef          	jal	ra,ffffffffc0203842 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203a8e:	32051263          	bnez	a0,ffffffffc0203db2 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0203a92:	00448593          	addi	a1,s1,4
ffffffffc0203a96:	8522                	mv	a0,s0
ffffffffc0203a98:	dabff0ef          	jal	ra,ffffffffc0203842 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203a9c:	2e051b63          	bnez	a0,ffffffffc0203d92 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203aa0:	008a3783          	ld	a5,8(s4)
ffffffffc0203aa4:	20979763          	bne	a5,s1,ffffffffc0203cb2 <vmm_init+0x336>
ffffffffc0203aa8:	010a3783          	ld	a5,16(s4)
ffffffffc0203aac:	21279363          	bne	a5,s2,ffffffffc0203cb2 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203ab0:	0089b783          	ld	a5,8(s3)
ffffffffc0203ab4:	20979f63          	bne	a5,s1,ffffffffc0203cd2 <vmm_init+0x356>
ffffffffc0203ab8:	0109b783          	ld	a5,16(s3)
ffffffffc0203abc:	21279b63          	bne	a5,s2,ffffffffc0203cd2 <vmm_init+0x356>
ffffffffc0203ac0:	0495                	addi	s1,s1,5
ffffffffc0203ac2:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203ac4:	f9549be3          	bne	s1,s5,ffffffffc0203a5a <vmm_init+0xde>
ffffffffc0203ac8:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203aca:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203acc:	85a6                	mv	a1,s1
ffffffffc0203ace:	8522                	mv	a0,s0
ffffffffc0203ad0:	d73ff0ef          	jal	ra,ffffffffc0203842 <find_vma>
ffffffffc0203ad4:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203ad8:	c90d                	beqz	a0,ffffffffc0203b0a <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203ada:	6914                	ld	a3,16(a0)
ffffffffc0203adc:	6510                	ld	a2,8(a0)
ffffffffc0203ade:	00003517          	auipc	a0,0x3
ffffffffc0203ae2:	db250513          	addi	a0,a0,-590 # ffffffffc0206890 <default_pmm_manager+0xe08>
ffffffffc0203ae6:	ea8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203aea:	00003697          	auipc	a3,0x3
ffffffffc0203aee:	dce68693          	addi	a3,a3,-562 # ffffffffc02068b8 <default_pmm_manager+0xe30>
ffffffffc0203af2:	00002617          	auipc	a2,0x2
ffffffffc0203af6:	bfe60613          	addi	a2,a2,-1026 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203afa:	0f100593          	li	a1,241
ffffffffc0203afe:	00003517          	auipc	a0,0x3
ffffffffc0203b02:	b8250513          	addi	a0,a0,-1150 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203b06:	94bfc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc0203b0a:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0203b0c:	fd2490e3          	bne	s1,s2,ffffffffc0203acc <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0203b10:	8522                	mv	a0,s0
ffffffffc0203b12:	e3dff0ef          	jal	ra,ffffffffc020394e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b16:	00003517          	auipc	a0,0x3
ffffffffc0203b1a:	dba50513          	addi	a0,a0,-582 # ffffffffc02068d0 <default_pmm_manager+0xe48>
ffffffffc0203b1e:	e70fc0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203b22:	91efe0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0203b26:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0203b28:	ca1ff0ef          	jal	ra,ffffffffc02037c8 <mm_create>
ffffffffc0203b2c:	00012797          	auipc	a5,0x12
ffffffffc0203b30:	aaa7ba23          	sd	a0,-1356(a5) # ffffffffc02155e0 <check_mm_struct>
ffffffffc0203b34:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc0203b36:	36050663          	beqz	a0,ffffffffc0203ea2 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203b3a:	00012797          	auipc	a5,0x12
ffffffffc0203b3e:	94e78793          	addi	a5,a5,-1714 # ffffffffc0215488 <boot_pgdir>
ffffffffc0203b42:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc0203b46:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203b4a:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0203b4e:	2c079e63          	bnez	a5,ffffffffc0203e2a <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b52:	03000513          	li	a0,48
ffffffffc0203b56:	e21fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc0203b5a:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0203b5c:	18050b63          	beqz	a0,ffffffffc0203cf2 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0203b60:	002007b7          	lui	a5,0x200
ffffffffc0203b64:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0203b66:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203b68:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203b6a:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203b6c:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0203b6e:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0203b72:	d0fff0ef          	jal	ra,ffffffffc0203880 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b76:	10000593          	li	a1,256
ffffffffc0203b7a:	8526                	mv	a0,s1
ffffffffc0203b7c:	cc7ff0ef          	jal	ra,ffffffffc0203842 <find_vma>
ffffffffc0203b80:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203b84:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203b88:	2ca41163          	bne	s0,a0,ffffffffc0203e4a <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0203b8c:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203b90:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203b92:	fee79de3          	bne	a5,a4,ffffffffc0203b8c <vmm_init+0x210>
        sum += i;
ffffffffc0203b96:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203b98:	10000793          	li	a5,256
        sum += i;
ffffffffc0203b9c:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203ba0:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203ba4:	0007c683          	lbu	a3,0(a5)
ffffffffc0203ba8:	0785                	addi	a5,a5,1
ffffffffc0203baa:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0203bac:	fec79ce3          	bne	a5,a2,ffffffffc0203ba4 <vmm_init+0x228>
    }
    assert(sum == 0);
ffffffffc0203bb0:	2c071963          	bnez	a4,ffffffffc0203e82 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203bb4:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203bb8:	00012a97          	auipc	s5,0x12
ffffffffc0203bbc:	8d8a8a93          	addi	s5,s5,-1832 # ffffffffc0215490 <npage>
ffffffffc0203bc0:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203bc4:	078a                	slli	a5,a5,0x2
ffffffffc0203bc6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203bc8:	20e7f563          	bleu	a4,a5,ffffffffc0203dd2 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203bcc:	00003697          	auipc	a3,0x3
ffffffffc0203bd0:	21c68693          	addi	a3,a3,540 # ffffffffc0206de8 <nbase>
ffffffffc0203bd4:	0006ba03          	ld	s4,0(a3)
ffffffffc0203bd8:	414786b3          	sub	a3,a5,s4
ffffffffc0203bdc:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203bde:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203be0:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0203be2:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0203be4:	83b1                	srli	a5,a5,0xc
ffffffffc0203be6:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203be8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203bea:	28e7f063          	bleu	a4,a5,ffffffffc0203e6a <vmm_init+0x4ee>
ffffffffc0203bee:	00012797          	auipc	a5,0x12
ffffffffc0203bf2:	90278793          	addi	a5,a5,-1790 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0203bf6:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203bf8:	4581                	li	a1,0
ffffffffc0203bfa:	854a                	mv	a0,s2
ffffffffc0203bfc:	9436                	add	s0,s0,a3
ffffffffc0203bfe:	ab6fe0ef          	jal	ra,ffffffffc0201eb4 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c02:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203c04:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c08:	078a                	slli	a5,a5,0x2
ffffffffc0203c0a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c0c:	1ce7f363          	bleu	a4,a5,ffffffffc0203dd2 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c10:	00012417          	auipc	s0,0x12
ffffffffc0203c14:	8f040413          	addi	s0,s0,-1808 # ffffffffc0215500 <pages>
ffffffffc0203c18:	6008                	ld	a0,0(s0)
ffffffffc0203c1a:	414787b3          	sub	a5,a5,s4
ffffffffc0203c1e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203c20:	953e                	add	a0,a0,a5
ffffffffc0203c22:	4585                	li	a1,1
ffffffffc0203c24:	fd7fd0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c28:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203c2c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203c30:	078a                	slli	a5,a5,0x2
ffffffffc0203c32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203c34:	18e7ff63          	bleu	a4,a5,ffffffffc0203dd2 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0203c38:	6008                	ld	a0,0(s0)
ffffffffc0203c3a:	414787b3          	sub	a5,a5,s4
ffffffffc0203c3e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203c40:	4585                	li	a1,1
ffffffffc0203c42:	953e                	add	a0,a0,a5
ffffffffc0203c44:	fb7fd0ef          	jal	ra,ffffffffc0201bfa <free_pages>
    pgdir[0] = 0;
ffffffffc0203c48:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0203c4c:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0203c50:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc0203c54:	8526                	mv	a0,s1
ffffffffc0203c56:	cf9ff0ef          	jal	ra,ffffffffc020394e <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0203c5a:	00012797          	auipc	a5,0x12
ffffffffc0203c5e:	9807b323          	sd	zero,-1658(a5) # ffffffffc02155e0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203c62:	fdffd0ef          	jal	ra,ffffffffc0201c40 <nr_free_pages>
ffffffffc0203c66:	1aa99263          	bne	s3,a0,ffffffffc0203e0a <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203c6a:	00003517          	auipc	a0,0x3
ffffffffc0203c6e:	cf650513          	addi	a0,a0,-778 # ffffffffc0206960 <default_pmm_manager+0xed8>
ffffffffc0203c72:	d1cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203c76:	7442                	ld	s0,48(sp)
ffffffffc0203c78:	70e2                	ld	ra,56(sp)
ffffffffc0203c7a:	74a2                	ld	s1,40(sp)
ffffffffc0203c7c:	7902                	ld	s2,32(sp)
ffffffffc0203c7e:	69e2                	ld	s3,24(sp)
ffffffffc0203c80:	6a42                	ld	s4,16(sp)
ffffffffc0203c82:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c84:	00003517          	auipc	a0,0x3
ffffffffc0203c88:	cfc50513          	addi	a0,a0,-772 # ffffffffc0206980 <default_pmm_manager+0xef8>
}
ffffffffc0203c8c:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203c8e:	d00fc06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203c92:	00003697          	auipc	a3,0x3
ffffffffc0203c96:	b1668693          	addi	a3,a3,-1258 # ffffffffc02067a8 <default_pmm_manager+0xd20>
ffffffffc0203c9a:	00002617          	auipc	a2,0x2
ffffffffc0203c9e:	a5660613          	addi	a2,a2,-1450 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203ca2:	0d800593          	li	a1,216
ffffffffc0203ca6:	00003517          	auipc	a0,0x3
ffffffffc0203caa:	9da50513          	addi	a0,a0,-1574 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203cae:	fa2fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0203cb2:	00003697          	auipc	a3,0x3
ffffffffc0203cb6:	b7e68693          	addi	a3,a3,-1154 # ffffffffc0206830 <default_pmm_manager+0xda8>
ffffffffc0203cba:	00002617          	auipc	a2,0x2
ffffffffc0203cbe:	a3660613          	addi	a2,a2,-1482 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203cc2:	0e800593          	li	a1,232
ffffffffc0203cc6:	00003517          	auipc	a0,0x3
ffffffffc0203cca:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203cce:	f82fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0203cd2:	00003697          	auipc	a3,0x3
ffffffffc0203cd6:	b8e68693          	addi	a3,a3,-1138 # ffffffffc0206860 <default_pmm_manager+0xdd8>
ffffffffc0203cda:	00002617          	auipc	a2,0x2
ffffffffc0203cde:	a1660613          	addi	a2,a2,-1514 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203ce2:	0e900593          	li	a1,233
ffffffffc0203ce6:	00003517          	auipc	a0,0x3
ffffffffc0203cea:	99a50513          	addi	a0,a0,-1638 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203cee:	f62fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(vma != NULL);
ffffffffc0203cf2:	00002697          	auipc	a3,0x2
ffffffffc0203cf6:	4f668693          	addi	a3,a3,1270 # ffffffffc02061e8 <default_pmm_manager+0x760>
ffffffffc0203cfa:	00002617          	auipc	a2,0x2
ffffffffc0203cfe:	9f660613          	addi	a2,a2,-1546 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203d02:	10800593          	li	a1,264
ffffffffc0203d06:	00003517          	auipc	a0,0x3
ffffffffc0203d0a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203d0e:	f42fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203d12:	00003697          	auipc	a3,0x3
ffffffffc0203d16:	a7e68693          	addi	a3,a3,-1410 # ffffffffc0206790 <default_pmm_manager+0xd08>
ffffffffc0203d1a:	00002617          	auipc	a2,0x2
ffffffffc0203d1e:	9d660613          	addi	a2,a2,-1578 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203d22:	0d600593          	li	a1,214
ffffffffc0203d26:	00003517          	auipc	a0,0x3
ffffffffc0203d2a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203d2e:	f22fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma3 == NULL);
ffffffffc0203d32:	00003697          	auipc	a3,0x3
ffffffffc0203d36:	ace68693          	addi	a3,a3,-1330 # ffffffffc0206800 <default_pmm_manager+0xd78>
ffffffffc0203d3a:	00002617          	auipc	a2,0x2
ffffffffc0203d3e:	9b660613          	addi	a2,a2,-1610 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203d42:	0e200593          	li	a1,226
ffffffffc0203d46:	00003517          	auipc	a0,0x3
ffffffffc0203d4a:	93a50513          	addi	a0,a0,-1734 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203d4e:	f02fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma2 != NULL);
ffffffffc0203d52:	00003697          	auipc	a3,0x3
ffffffffc0203d56:	a9e68693          	addi	a3,a3,-1378 # ffffffffc02067f0 <default_pmm_manager+0xd68>
ffffffffc0203d5a:	00002617          	auipc	a2,0x2
ffffffffc0203d5e:	99660613          	addi	a2,a2,-1642 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203d62:	0e000593          	li	a1,224
ffffffffc0203d66:	00003517          	auipc	a0,0x3
ffffffffc0203d6a:	91a50513          	addi	a0,a0,-1766 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203d6e:	ee2fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma1 != NULL);
ffffffffc0203d72:	00003697          	auipc	a3,0x3
ffffffffc0203d76:	a6e68693          	addi	a3,a3,-1426 # ffffffffc02067e0 <default_pmm_manager+0xd58>
ffffffffc0203d7a:	00002617          	auipc	a2,0x2
ffffffffc0203d7e:	97660613          	addi	a2,a2,-1674 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203d82:	0de00593          	li	a1,222
ffffffffc0203d86:	00003517          	auipc	a0,0x3
ffffffffc0203d8a:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203d8e:	ec2fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma5 == NULL);
ffffffffc0203d92:	00003697          	auipc	a3,0x3
ffffffffc0203d96:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0206820 <default_pmm_manager+0xd98>
ffffffffc0203d9a:	00002617          	auipc	a2,0x2
ffffffffc0203d9e:	95660613          	addi	a2,a2,-1706 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203da2:	0e600593          	li	a1,230
ffffffffc0203da6:	00003517          	auipc	a0,0x3
ffffffffc0203daa:	8da50513          	addi	a0,a0,-1830 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203dae:	ea2fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        assert(vma4 == NULL);
ffffffffc0203db2:	00003697          	auipc	a3,0x3
ffffffffc0203db6:	a5e68693          	addi	a3,a3,-1442 # ffffffffc0206810 <default_pmm_manager+0xd88>
ffffffffc0203dba:	00002617          	auipc	a2,0x2
ffffffffc0203dbe:	93660613          	addi	a2,a2,-1738 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203dc2:	0e400593          	li	a1,228
ffffffffc0203dc6:	00003517          	auipc	a0,0x3
ffffffffc0203dca:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203dce:	e82fc0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203dd2:	00002617          	auipc	a2,0x2
ffffffffc0203dd6:	d6660613          	addi	a2,a2,-666 # ffffffffc0205b38 <default_pmm_manager+0xb0>
ffffffffc0203dda:	06200593          	li	a1,98
ffffffffc0203dde:	00002517          	auipc	a0,0x2
ffffffffc0203de2:	d2250513          	addi	a0,a0,-734 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0203de6:	e6afc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(mm != NULL);
ffffffffc0203dea:	00002697          	auipc	a3,0x2
ffffffffc0203dee:	3c668693          	addi	a3,a3,966 # ffffffffc02061b0 <default_pmm_manager+0x728>
ffffffffc0203df2:	00002617          	auipc	a2,0x2
ffffffffc0203df6:	8fe60613          	addi	a2,a2,-1794 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203dfa:	0c200593          	li	a1,194
ffffffffc0203dfe:	00003517          	auipc	a0,0x3
ffffffffc0203e02:	88250513          	addi	a0,a0,-1918 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203e06:	e4afc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203e0a:	00003697          	auipc	a3,0x3
ffffffffc0203e0e:	b2e68693          	addi	a3,a3,-1234 # ffffffffc0206938 <default_pmm_manager+0xeb0>
ffffffffc0203e12:	00002617          	auipc	a2,0x2
ffffffffc0203e16:	8de60613          	addi	a2,a2,-1826 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203e1a:	12400593          	li	a1,292
ffffffffc0203e1e:	00003517          	auipc	a0,0x3
ffffffffc0203e22:	86250513          	addi	a0,a0,-1950 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203e26:	e2afc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203e2a:	00002697          	auipc	a3,0x2
ffffffffc0203e2e:	3ae68693          	addi	a3,a3,942 # ffffffffc02061d8 <default_pmm_manager+0x750>
ffffffffc0203e32:	00002617          	auipc	a2,0x2
ffffffffc0203e36:	8be60613          	addi	a2,a2,-1858 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203e3a:	10500593          	li	a1,261
ffffffffc0203e3e:	00003517          	auipc	a0,0x3
ffffffffc0203e42:	84250513          	addi	a0,a0,-1982 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203e46:	e0afc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203e4a:	00003697          	auipc	a3,0x3
ffffffffc0203e4e:	abe68693          	addi	a3,a3,-1346 # ffffffffc0206908 <default_pmm_manager+0xe80>
ffffffffc0203e52:	00002617          	auipc	a2,0x2
ffffffffc0203e56:	89e60613          	addi	a2,a2,-1890 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203e5a:	10d00593          	li	a1,269
ffffffffc0203e5e:	00003517          	auipc	a0,0x3
ffffffffc0203e62:	82250513          	addi	a0,a0,-2014 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203e66:	deafc0ef          	jal	ra,ffffffffc0200450 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203e6a:	00002617          	auipc	a2,0x2
ffffffffc0203e6e:	c6e60613          	addi	a2,a2,-914 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0203e72:	06900593          	li	a1,105
ffffffffc0203e76:	00002517          	auipc	a0,0x2
ffffffffc0203e7a:	c8a50513          	addi	a0,a0,-886 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0203e7e:	dd2fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(sum == 0);
ffffffffc0203e82:	00003697          	auipc	a3,0x3
ffffffffc0203e86:	aa668693          	addi	a3,a3,-1370 # ffffffffc0206928 <default_pmm_manager+0xea0>
ffffffffc0203e8a:	00002617          	auipc	a2,0x2
ffffffffc0203e8e:	86660613          	addi	a2,a2,-1946 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203e92:	11700593          	li	a1,279
ffffffffc0203e96:	00002517          	auipc	a0,0x2
ffffffffc0203e9a:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203e9e:	db2fc0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203ea2:	00003697          	auipc	a3,0x3
ffffffffc0203ea6:	a4e68693          	addi	a3,a3,-1458 # ffffffffc02068f0 <default_pmm_manager+0xe68>
ffffffffc0203eaa:	00002617          	auipc	a2,0x2
ffffffffc0203eae:	84660613          	addi	a2,a2,-1978 # ffffffffc02056f0 <commands+0x870>
ffffffffc0203eb2:	10100593          	li	a1,257
ffffffffc0203eb6:	00002517          	auipc	a0,0x2
ffffffffc0203eba:	7ca50513          	addi	a0,a0,1994 # ffffffffc0206680 <default_pmm_manager+0xbf8>
ffffffffc0203ebe:	d92fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203ec2 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203ec2:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203ec4:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203ec6:	e822                	sd	s0,16(sp)
ffffffffc0203ec8:	e426                	sd	s1,8(sp)
ffffffffc0203eca:	ec06                	sd	ra,24(sp)
ffffffffc0203ecc:	e04a                	sd	s2,0(sp)
ffffffffc0203ece:	8432                	mv	s0,a2
ffffffffc0203ed0:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203ed2:	971ff0ef          	jal	ra,ffffffffc0203842 <find_vma>

    pgfault_num++;
ffffffffc0203ed6:	00011797          	auipc	a5,0x11
ffffffffc0203eda:	5ce78793          	addi	a5,a5,1486 # ffffffffc02154a4 <pgfault_num>
ffffffffc0203ede:	439c                	lw	a5,0(a5)
ffffffffc0203ee0:	2785                	addiw	a5,a5,1
ffffffffc0203ee2:	00011717          	auipc	a4,0x11
ffffffffc0203ee6:	5cf72123          	sw	a5,1474(a4) # ffffffffc02154a4 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203eea:	cd21                	beqz	a0,ffffffffc0203f42 <do_pgfault+0x80>
ffffffffc0203eec:	651c                	ld	a5,8(a0)
ffffffffc0203eee:	04f46a63          	bltu	s0,a5,ffffffffc0203f42 <do_pgfault+0x80>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203ef2:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203ef4:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203ef6:	8b89                	andi	a5,a5,2
ffffffffc0203ef8:	e78d                	bnez	a5,ffffffffc0203f22 <do_pgfault+0x60>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203efa:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203efc:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203efe:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203f00:	85a2                	mv	a1,s0
ffffffffc0203f02:	4605                	li	a2,1
ffffffffc0203f04:	d7dfd0ef          	jal	ra,ffffffffc0201c80 <get_pte>
ffffffffc0203f08:	cd31                	beqz	a0,ffffffffc0203f64 <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0203f0a:	610c                	ld	a1,0(a0)
ffffffffc0203f0c:	cd89                	beqz	a1,ffffffffc0203f26 <do_pgfault+0x64>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203f0e:	00011797          	auipc	a5,0x11
ffffffffc0203f12:	59278793          	addi	a5,a5,1426 # ffffffffc02154a0 <swap_init_ok>
ffffffffc0203f16:	439c                	lw	a5,0(a5)
ffffffffc0203f18:	2781                	sext.w	a5,a5
ffffffffc0203f1a:	cf8d                	beqz	a5,ffffffffc0203f54 <do_pgfault+0x92>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0203f1c:	02003c23          	sd	zero,56(zero) # 38 <BASE_ADDRESS-0xffffffffc01fffc8>
ffffffffc0203f20:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc0203f22:	495d                	li	s2,23
ffffffffc0203f24:	bfd9                	j	ffffffffc0203efa <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203f26:	6c88                	ld	a0,24(s1)
ffffffffc0203f28:	864a                	mv	a2,s2
ffffffffc0203f2a:	85a2                	mv	a1,s0
ffffffffc0203f2c:	b4bfe0ef          	jal	ra,ffffffffc0202a76 <pgdir_alloc_page>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203f30:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203f32:	c129                	beqz	a0,ffffffffc0203f74 <do_pgfault+0xb2>
failed:
    return ret;
}
ffffffffc0203f34:	60e2                	ld	ra,24(sp)
ffffffffc0203f36:	6442                	ld	s0,16(sp)
ffffffffc0203f38:	64a2                	ld	s1,8(sp)
ffffffffc0203f3a:	6902                	ld	s2,0(sp)
ffffffffc0203f3c:	853e                	mv	a0,a5
ffffffffc0203f3e:	6105                	addi	sp,sp,32
ffffffffc0203f40:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203f42:	85a2                	mv	a1,s0
ffffffffc0203f44:	00002517          	auipc	a0,0x2
ffffffffc0203f48:	74c50513          	addi	a0,a0,1868 # ffffffffc0206690 <default_pmm_manager+0xc08>
ffffffffc0203f4c:	a42fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0203f50:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203f52:	b7cd                	j	ffffffffc0203f34 <do_pgfault+0x72>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203f54:	00002517          	auipc	a0,0x2
ffffffffc0203f58:	7b450513          	addi	a0,a0,1972 # ffffffffc0206708 <default_pmm_manager+0xc80>
ffffffffc0203f5c:	a32fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f60:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203f62:	bfc9                	j	ffffffffc0203f34 <do_pgfault+0x72>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203f64:	00002517          	auipc	a0,0x2
ffffffffc0203f68:	75c50513          	addi	a0,a0,1884 # ffffffffc02066c0 <default_pmm_manager+0xc38>
ffffffffc0203f6c:	a22fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f70:	57f1                	li	a5,-4
        goto failed;
ffffffffc0203f72:	b7c9                	j	ffffffffc0203f34 <do_pgfault+0x72>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203f74:	00002517          	auipc	a0,0x2
ffffffffc0203f78:	76c50513          	addi	a0,a0,1900 # ffffffffc02066e0 <default_pmm_manager+0xc58>
ffffffffc0203f7c:	a12fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f80:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203f82:	bf4d                	j	ffffffffc0203f34 <do_pgfault+0x72>

ffffffffc0203f84 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203f84:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f86:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203f88:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203f8a:	df2fc0ef          	jal	ra,ffffffffc020057c <ide_device_valid>
ffffffffc0203f8e:	cd01                	beqz	a0,ffffffffc0203fa6 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f90:	4505                	li	a0,1
ffffffffc0203f92:	df0fc0ef          	jal	ra,ffffffffc0200582 <ide_device_size>
}
ffffffffc0203f96:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203f98:	810d                	srli	a0,a0,0x3
ffffffffc0203f9a:	00011797          	auipc	a5,0x11
ffffffffc0203f9e:	5ea7bb23          	sd	a0,1526(a5) # ffffffffc0215590 <max_swap_offset>
}
ffffffffc0203fa2:	0141                	addi	sp,sp,16
ffffffffc0203fa4:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203fa6:	00003617          	auipc	a2,0x3
ffffffffc0203faa:	9f260613          	addi	a2,a2,-1550 # ffffffffc0206998 <default_pmm_manager+0xf10>
ffffffffc0203fae:	45b5                	li	a1,13
ffffffffc0203fb0:	00003517          	auipc	a0,0x3
ffffffffc0203fb4:	a0850513          	addi	a0,a0,-1528 # ffffffffc02069b8 <default_pmm_manager+0xf30>
ffffffffc0203fb8:	c98fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0203fbc <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203fbc:	1141                	addi	sp,sp,-16
ffffffffc0203fbe:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203fc0:	00855793          	srli	a5,a0,0x8
ffffffffc0203fc4:	cfb9                	beqz	a5,ffffffffc0204022 <swapfs_write+0x66>
ffffffffc0203fc6:	00011717          	auipc	a4,0x11
ffffffffc0203fca:	5ca70713          	addi	a4,a4,1482 # ffffffffc0215590 <max_swap_offset>
ffffffffc0203fce:	6318                	ld	a4,0(a4)
ffffffffc0203fd0:	04e7f963          	bleu	a4,a5,ffffffffc0204022 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0203fd4:	00011717          	auipc	a4,0x11
ffffffffc0203fd8:	52c70713          	addi	a4,a4,1324 # ffffffffc0215500 <pages>
ffffffffc0203fdc:	6310                	ld	a2,0(a4)
ffffffffc0203fde:	00003717          	auipc	a4,0x3
ffffffffc0203fe2:	e0a70713          	addi	a4,a4,-502 # ffffffffc0206de8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0203fe6:	00011697          	auipc	a3,0x11
ffffffffc0203fea:	4aa68693          	addi	a3,a3,1194 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc0203fee:	40c58633          	sub	a2,a1,a2
ffffffffc0203ff2:	630c                	ld	a1,0(a4)
ffffffffc0203ff4:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0203ff6:	577d                	li	a4,-1
ffffffffc0203ff8:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0203ffa:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0203ffc:	8331                	srli	a4,a4,0xc
ffffffffc0203ffe:	8f71                	and	a4,a4,a2
ffffffffc0204000:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204004:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204006:	02d77a63          	bleu	a3,a4,ffffffffc020403a <swapfs_write+0x7e>
ffffffffc020400a:	00011797          	auipc	a5,0x11
ffffffffc020400e:	4e678793          	addi	a5,a5,1254 # ffffffffc02154f0 <va_pa_offset>
ffffffffc0204012:	639c                	ld	a5,0(a5)
}
ffffffffc0204014:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204016:	46a1                	li	a3,8
ffffffffc0204018:	963e                	add	a2,a2,a5
ffffffffc020401a:	4505                	li	a0,1
}
ffffffffc020401c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc020401e:	d6afc06f          	j	ffffffffc0200588 <ide_write_secs>
ffffffffc0204022:	86aa                	mv	a3,a0
ffffffffc0204024:	00003617          	auipc	a2,0x3
ffffffffc0204028:	9ac60613          	addi	a2,a2,-1620 # ffffffffc02069d0 <default_pmm_manager+0xf48>
ffffffffc020402c:	45e5                	li	a1,25
ffffffffc020402e:	00003517          	auipc	a0,0x3
ffffffffc0204032:	98a50513          	addi	a0,a0,-1654 # ffffffffc02069b8 <default_pmm_manager+0xf30>
ffffffffc0204036:	c1afc0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020403a:	86b2                	mv	a3,a2
ffffffffc020403c:	06900593          	li	a1,105
ffffffffc0204040:	00002617          	auipc	a2,0x2
ffffffffc0204044:	a9860613          	addi	a2,a2,-1384 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0204048:	00002517          	auipc	a0,0x2
ffffffffc020404c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0204050:	c00fc0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204054 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204054:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204056:	9402                	jalr	s0

	jal do_exit
ffffffffc0204058:	47c000ef          	jal	ra,ffffffffc02044d4 <do_exit>

ffffffffc020405c <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc020405c:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020405e:	0e800513          	li	a0,232
alloc_proc(void) {
ffffffffc0204062:	e022                	sd	s0,0(sp)
ffffffffc0204064:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204066:	911fd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
ffffffffc020406a:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc020406c:	c929                	beqz	a0,ffffffffc02040be <alloc_proc+0x62>
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    
    // 设置进程为 初始 态
    proc->state = PROC_UNINIT;
ffffffffc020406e:	57fd                	li	a5,-1
ffffffffc0204070:	1782                	slli	a5,a5,0x20
ffffffffc0204072:	e11c                	sd	a5,0(a0)
    // 设置kstack为NULL
    proc->kstack = 0;
    // 设置need_resched为0
    proc->need_resched = 0;
    // 设置parent为当前进程，idle进程是没有父进程的，将会是NULL
    proc->parent = current;
ffffffffc0204074:	00011797          	auipc	a5,0x11
ffffffffc0204078:	43478793          	addi	a5,a5,1076 # ffffffffc02154a8 <current>
ffffffffc020407c:	639c                	ld	a5,0(a5)
    // mm设置为空
    proc->mm = NULL;
    // 上下文设置为空
    memset(&proc->context, 0, sizeof(struct context));
ffffffffc020407e:	07000613          	li	a2,112
ffffffffc0204082:	4581                	li	a1,0
    proc->parent = current;
ffffffffc0204084:	f11c                	sd	a5,32(a0)
    proc->runs = 0;
ffffffffc0204086:	00052423          	sw	zero,8(a0)
    proc->kstack = 0;
ffffffffc020408a:	00053823          	sd	zero,16(a0)
    proc->need_resched = 0;
ffffffffc020408e:	00052c23          	sw	zero,24(a0)
    proc->mm = NULL;
ffffffffc0204092:	02053423          	sd	zero,40(a0)
    memset(&proc->context, 0, sizeof(struct context));
ffffffffc0204096:	03050513          	addi	a0,a0,48
ffffffffc020409a:	457000ef          	jal	ra,ffffffffc0204cf0 <memset>
    // tf置空
    proc->tf = 0;
    // 使用内核页目录表的基址
    proc->cr3 = boot_cr3;
ffffffffc020409e:	00011797          	auipc	a5,0x11
ffffffffc02040a2:	45a78793          	addi	a5,a5,1114 # ffffffffc02154f8 <boot_cr3>
ffffffffc02040a6:	639c                	ld	a5,0(a5)
    proc->tf = 0;
ffffffffc02040a8:	0a043023          	sd	zero,160(s0)
    // flags置为0
    proc->flags = 0;
ffffffffc02040ac:	0a042823          	sw	zero,176(s0)
    proc->cr3 = boot_cr3;
ffffffffc02040b0:	f45c                	sd	a5,168(s0)
    // name置空
    memset(&proc->name, 0, PROC_NAME_LEN+1);
ffffffffc02040b2:	4641                	li	a2,16
ffffffffc02040b4:	4581                	li	a1,0
ffffffffc02040b6:	0b440513          	addi	a0,s0,180
ffffffffc02040ba:	437000ef          	jal	ra,ffffffffc0204cf0 <memset>
    }
    return proc;
}
ffffffffc02040be:	8522                	mv	a0,s0
ffffffffc02040c0:	60a2                	ld	ra,8(sp)
ffffffffc02040c2:	6402                	ld	s0,0(sp)
ffffffffc02040c4:	0141                	addi	sp,sp,16
ffffffffc02040c6:	8082                	ret

ffffffffc02040c8 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc02040c8:	00011797          	auipc	a5,0x11
ffffffffc02040cc:	3e078793          	addi	a5,a5,992 # ffffffffc02154a8 <current>
ffffffffc02040d0:	639c                	ld	a5,0(a5)
ffffffffc02040d2:	73c8                	ld	a0,160(a5)
ffffffffc02040d4:	aa1fc06f          	j	ffffffffc0200b74 <forkrets>

ffffffffc02040d8 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02040d8:	1101                	addi	sp,sp,-32
ffffffffc02040da:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02040dc:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02040e0:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02040e2:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02040e4:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02040e6:	8522                	mv	a0,s0
ffffffffc02040e8:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02040ea:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02040ec:	405000ef          	jal	ra,ffffffffc0204cf0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02040f0:	8522                	mv	a0,s0
}
ffffffffc02040f2:	6442                	ld	s0,16(sp)
ffffffffc02040f4:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02040f6:	85a6                	mv	a1,s1
}
ffffffffc02040f8:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02040fa:	463d                	li	a2,15
}
ffffffffc02040fc:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02040fe:	4050006f          	j	ffffffffc0204d02 <memcpy>

ffffffffc0204102 <get_proc_name>:
get_proc_name(struct proc_struct *proc) {
ffffffffc0204102:	1101                	addi	sp,sp,-32
ffffffffc0204104:	e822                	sd	s0,16(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204106:	00011417          	auipc	s0,0x11
ffffffffc020410a:	35a40413          	addi	s0,s0,858 # ffffffffc0215460 <name.1565>
get_proc_name(struct proc_struct *proc) {
ffffffffc020410e:	e426                	sd	s1,8(sp)
    memset(name, 0, sizeof(name));
ffffffffc0204110:	4641                	li	a2,16
get_proc_name(struct proc_struct *proc) {
ffffffffc0204112:	84aa                	mv	s1,a0
    memset(name, 0, sizeof(name));
ffffffffc0204114:	4581                	li	a1,0
ffffffffc0204116:	8522                	mv	a0,s0
get_proc_name(struct proc_struct *proc) {
ffffffffc0204118:	ec06                	sd	ra,24(sp)
    memset(name, 0, sizeof(name));
ffffffffc020411a:	3d7000ef          	jal	ra,ffffffffc0204cf0 <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020411e:	8522                	mv	a0,s0
}
ffffffffc0204120:	6442                	ld	s0,16(sp)
ffffffffc0204122:	60e2                	ld	ra,24(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc0204124:	0b448593          	addi	a1,s1,180
}
ffffffffc0204128:	64a2                	ld	s1,8(sp)
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020412a:	463d                	li	a2,15
}
ffffffffc020412c:	6105                	addi	sp,sp,32
    return memcpy(name, proc->name, PROC_NAME_LEN);
ffffffffc020412e:	3d50006f          	j	ffffffffc0204d02 <memcpy>

ffffffffc0204132 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204132:	00011797          	auipc	a5,0x11
ffffffffc0204136:	37678793          	addi	a5,a5,886 # ffffffffc02154a8 <current>
ffffffffc020413a:	639c                	ld	a5,0(a5)
init_main(void *arg) {
ffffffffc020413c:	1101                	addi	sp,sp,-32
ffffffffc020413e:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204140:	43c4                	lw	s1,4(a5)
init_main(void *arg) {
ffffffffc0204142:	e822                	sd	s0,16(sp)
ffffffffc0204144:	842a                	mv	s0,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc0204146:	853e                	mv	a0,a5
init_main(void *arg) {
ffffffffc0204148:	ec06                	sd	ra,24(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc020414a:	fb9ff0ef          	jal	ra,ffffffffc0204102 <get_proc_name>
ffffffffc020414e:	862a                	mv	a2,a0
ffffffffc0204150:	85a6                	mv	a1,s1
ffffffffc0204152:	00003517          	auipc	a0,0x3
ffffffffc0204156:	8e650513          	addi	a0,a0,-1818 # ffffffffc0206a38 <default_pmm_manager+0xfb0>
ffffffffc020415a:	834fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020415e:	85a2                	mv	a1,s0
ffffffffc0204160:	00003517          	auipc	a0,0x3
ffffffffc0204164:	90050513          	addi	a0,a0,-1792 # ffffffffc0206a60 <default_pmm_manager+0xfd8>
ffffffffc0204168:	826fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc020416c:	00003517          	auipc	a0,0x3
ffffffffc0204170:	90450513          	addi	a0,a0,-1788 # ffffffffc0206a70 <default_pmm_manager+0xfe8>
ffffffffc0204174:	81afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0204178:	60e2                	ld	ra,24(sp)
ffffffffc020417a:	6442                	ld	s0,16(sp)
ffffffffc020417c:	64a2                	ld	s1,8(sp)
ffffffffc020417e:	4501                	li	a0,0
ffffffffc0204180:	6105                	addi	sp,sp,32
ffffffffc0204182:	8082                	ret

ffffffffc0204184 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204184:	1101                	addi	sp,sp,-32
ffffffffc0204186:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204188:	00011497          	auipc	s1,0x11
ffffffffc020418c:	32048493          	addi	s1,s1,800 # ffffffffc02154a8 <current>
ffffffffc0204190:	6098                	ld	a4,0(s1)
proc_run(struct proc_struct *proc) {
ffffffffc0204192:	ec06                	sd	ra,24(sp)
ffffffffc0204194:	e822                	sd	s0,16(sp)
ffffffffc0204196:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204198:	02a70c63          	beq	a4,a0,ffffffffc02041d0 <proc_run+0x4c>
ffffffffc020419c:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020419e:	100027f3          	csrr	a5,sstatus
ffffffffc02041a2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02041a4:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02041a6:	e3b1                	bnez	a5,ffffffffc02041ea <proc_run+0x66>
            lcr3(proc->cr3);
ffffffffc02041a8:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc02041aa:	00011697          	auipc	a3,0x11
ffffffffc02041ae:	2e86bf23          	sd	s0,766(a3) # ffffffffc02154a8 <current>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
ffffffffc02041b2:	800006b7          	lui	a3,0x80000
ffffffffc02041b6:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc02041ba:	8fd5                	or	a5,a5,a3
ffffffffc02041bc:	18079073          	csrw	satp,a5
            switch_to(&present_proc->context, &proc->context);
ffffffffc02041c0:	03040593          	addi	a1,s0,48
ffffffffc02041c4:	03070513          	addi	a0,a4,48
ffffffffc02041c8:	544000ef          	jal	ra,ffffffffc020470c <switch_to>
    if (flag) {
ffffffffc02041cc:	00091863          	bnez	s2,ffffffffc02041dc <proc_run+0x58>
}
ffffffffc02041d0:	60e2                	ld	ra,24(sp)
ffffffffc02041d2:	6442                	ld	s0,16(sp)
ffffffffc02041d4:	64a2                	ld	s1,8(sp)
ffffffffc02041d6:	6902                	ld	s2,0(sp)
ffffffffc02041d8:	6105                	addi	sp,sp,32
ffffffffc02041da:	8082                	ret
ffffffffc02041dc:	6442                	ld	s0,16(sp)
ffffffffc02041de:	60e2                	ld	ra,24(sp)
ffffffffc02041e0:	64a2                	ld	s1,8(sp)
ffffffffc02041e2:	6902                	ld	s2,0(sp)
ffffffffc02041e4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02041e6:	bc8fc06f          	j	ffffffffc02005ae <intr_enable>
        intr_disable();
ffffffffc02041ea:	bcafc0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
        return 1;
ffffffffc02041ee:	6098                	ld	a4,0(s1)
ffffffffc02041f0:	4905                	li	s2,1
ffffffffc02041f2:	bf5d                	j	ffffffffc02041a8 <proc_run+0x24>

ffffffffc02041f4 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc02041f4:	0005071b          	sext.w	a4,a0
ffffffffc02041f8:	6789                	lui	a5,0x2
ffffffffc02041fa:	fff7069b          	addiw	a3,a4,-1
ffffffffc02041fe:	17f9                	addi	a5,a5,-2
ffffffffc0204200:	04d7e063          	bltu	a5,a3,ffffffffc0204240 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204204:	1141                	addi	sp,sp,-16
ffffffffc0204206:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204208:	45a9                	li	a1,10
ffffffffc020420a:	842a                	mv	s0,a0
ffffffffc020420c:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc020420e:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204210:	632000ef          	jal	ra,ffffffffc0204842 <hash32>
ffffffffc0204214:	02051693          	slli	a3,a0,0x20
ffffffffc0204218:	82f1                	srli	a3,a3,0x1c
ffffffffc020421a:	0000d517          	auipc	a0,0xd
ffffffffc020421e:	24650513          	addi	a0,a0,582 # ffffffffc0211460 <hash_list>
ffffffffc0204222:	96aa                	add	a3,a3,a0
ffffffffc0204224:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204226:	a029                	j	ffffffffc0204230 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204228:	f2c7a703          	lw	a4,-212(a5) # 1f2c <BASE_ADDRESS-0xffffffffc01fe0d4>
ffffffffc020422c:	00870c63          	beq	a4,s0,ffffffffc0204244 <find_proc+0x50>
ffffffffc0204230:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204232:	fef69be3          	bne	a3,a5,ffffffffc0204228 <find_proc+0x34>
}
ffffffffc0204236:	60a2                	ld	ra,8(sp)
ffffffffc0204238:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020423a:	4501                	li	a0,0
}
ffffffffc020423c:	0141                	addi	sp,sp,16
ffffffffc020423e:	8082                	ret
    return NULL;
ffffffffc0204240:	4501                	li	a0,0
}
ffffffffc0204242:	8082                	ret
ffffffffc0204244:	60a2                	ld	ra,8(sp)
ffffffffc0204246:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204248:	f2878513          	addi	a0,a5,-216
}
ffffffffc020424c:	0141                	addi	sp,sp,16
ffffffffc020424e:	8082                	ret

ffffffffc0204250 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204250:	7179                	addi	sp,sp,-48
ffffffffc0204252:	e84a                	sd	s2,16(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204254:	00011917          	auipc	s2,0x11
ffffffffc0204258:	26c90913          	addi	s2,s2,620 # ffffffffc02154c0 <nr_process>
ffffffffc020425c:	00092703          	lw	a4,0(s2)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204260:	f406                	sd	ra,40(sp)
ffffffffc0204262:	f022                	sd	s0,32(sp)
ffffffffc0204264:	ec26                	sd	s1,24(sp)
ffffffffc0204266:	e44e                	sd	s3,8(sp)
ffffffffc0204268:	e052                	sd	s4,0(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc020426a:	6785                	lui	a5,0x1
ffffffffc020426c:	1cf75e63          	ble	a5,a4,ffffffffc0204448 <do_fork+0x1f8>
ffffffffc0204270:	89ae                	mv	s3,a1
ffffffffc0204272:	84b2                	mv	s1,a2
    if ((proc = alloc_proc()) == NULL)
ffffffffc0204274:	de9ff0ef          	jal	ra,ffffffffc020405c <alloc_proc>
ffffffffc0204278:	842a                	mv	s0,a0
ffffffffc020427a:	1c050263          	beqz	a0,ffffffffc020443e <do_fork+0x1ee>
    proc->parent = current;
ffffffffc020427e:	00011a17          	auipc	s4,0x11
ffffffffc0204282:	22aa0a13          	addi	s4,s4,554 # ffffffffc02154a8 <current>
ffffffffc0204286:	000a3783          	ld	a5,0(s4)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020428a:	4509                	li	a0,2
    proc->parent = current;
ffffffffc020428c:	f01c                	sd	a5,32(s0)
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020428e:	8e5fd0ef          	jal	ra,ffffffffc0201b72 <alloc_pages>
    if (page != NULL) {
ffffffffc0204292:	1a050663          	beqz	a0,ffffffffc020443e <do_fork+0x1ee>
    return page - pages + nbase;
ffffffffc0204296:	00011797          	auipc	a5,0x11
ffffffffc020429a:	26a78793          	addi	a5,a5,618 # ffffffffc0215500 <pages>
ffffffffc020429e:	6394                	ld	a3,0(a5)
ffffffffc02042a0:	00003797          	auipc	a5,0x3
ffffffffc02042a4:	b4878793          	addi	a5,a5,-1208 # ffffffffc0206de8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02042a8:	00011717          	auipc	a4,0x11
ffffffffc02042ac:	1e870713          	addi	a4,a4,488 # ffffffffc0215490 <npage>
    return page - pages + nbase;
ffffffffc02042b0:	40d506b3          	sub	a3,a0,a3
ffffffffc02042b4:	6388                	ld	a0,0(a5)
ffffffffc02042b6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02042b8:	57fd                	li	a5,-1
ffffffffc02042ba:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc02042bc:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc02042be:	83b1                	srli	a5,a5,0xc
ffffffffc02042c0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02042c2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02042c4:	1ae7f463          	bleu	a4,a5,ffffffffc020446c <do_fork+0x21c>
    assert(current->mm == NULL);
ffffffffc02042c8:	000a3783          	ld	a5,0(s4)
ffffffffc02042cc:	00011717          	auipc	a4,0x11
ffffffffc02042d0:	22470713          	addi	a4,a4,548 # ffffffffc02154f0 <va_pa_offset>
ffffffffc02042d4:	6318                	ld	a4,0(a4)
ffffffffc02042d6:	779c                	ld	a5,40(a5)
ffffffffc02042d8:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02042da:	e814                	sd	a3,16(s0)
    assert(current->mm == NULL);
ffffffffc02042dc:	16079863          	bnez	a5,ffffffffc020444c <do_fork+0x1fc>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02042e0:	6789                	lui	a5,0x2
ffffffffc02042e2:	ee078793          	addi	a5,a5,-288 # 1ee0 <BASE_ADDRESS-0xffffffffc01fe120>
ffffffffc02042e6:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf; // 深拷贝，在这以前已经分配了空间
ffffffffc02042e8:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02042ea:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf; // 深拷贝，在这以前已经分配了空间
ffffffffc02042ec:	87b6                	mv	a5,a3
ffffffffc02042ee:	12048893          	addi	a7,s1,288
ffffffffc02042f2:	00063803          	ld	a6,0(a2)
ffffffffc02042f6:	6608                	ld	a0,8(a2)
ffffffffc02042f8:	6a0c                	ld	a1,16(a2)
ffffffffc02042fa:	6e18                	ld	a4,24(a2)
ffffffffc02042fc:	0107b023          	sd	a6,0(a5)
ffffffffc0204300:	e788                	sd	a0,8(a5)
ffffffffc0204302:	eb8c                	sd	a1,16(a5)
ffffffffc0204304:	ef98                	sd	a4,24(a5)
ffffffffc0204306:	02060613          	addi	a2,a2,32
ffffffffc020430a:	02078793          	addi	a5,a5,32
ffffffffc020430e:	ff1612e3          	bne	a2,a7,ffffffffc02042f2 <do_fork+0xa2>
    proc->tf->gpr.a0 = 0; // 联想真实的fork，主进程返回1，子进程返回0
ffffffffc0204312:	0406b823          	sd	zero,80(a3) # ffffffff80000050 <BASE_ADDRESS-0x401fffb0>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp; //esp为0，是为了复制一个内核线程，所以直接用
ffffffffc0204316:	10098663          	beqz	s3,ffffffffc0204422 <do_fork+0x1d2>
    if (++ last_pid >= MAX_PID) {
ffffffffc020431a:	00006797          	auipc	a5,0x6
ffffffffc020431e:	d3e78793          	addi	a5,a5,-706 # ffffffffc020a058 <last_pid.1575>
ffffffffc0204322:	439c                	lw	a5,0(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp; //esp为0，是为了复制一个内核线程，所以直接用
ffffffffc0204324:	0136b823          	sd	s3,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204328:	00000717          	auipc	a4,0x0
ffffffffc020432c:	da070713          	addi	a4,a4,-608 # ffffffffc02040c8 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204330:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204334:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204336:	fc14                	sd	a3,56(s0)
    if (++ last_pid >= MAX_PID) {
ffffffffc0204338:	00006717          	auipc	a4,0x6
ffffffffc020433c:	d2a72023          	sw	a0,-736(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc0204340:	6789                	lui	a5,0x2
ffffffffc0204342:	0ef55263          	ble	a5,a0,ffffffffc0204426 <do_fork+0x1d6>
    if (last_pid >= next_safe) {
ffffffffc0204346:	00006797          	auipc	a5,0x6
ffffffffc020434a:	d1678793          	addi	a5,a5,-746 # ffffffffc020a05c <next_safe.1574>
ffffffffc020434e:	439c                	lw	a5,0(a5)
ffffffffc0204350:	00011497          	auipc	s1,0x11
ffffffffc0204354:	29848493          	addi	s1,s1,664 # ffffffffc02155e8 <proc_list>
ffffffffc0204358:	06f54063          	blt	a0,a5,ffffffffc02043b8 <do_fork+0x168>
        next_safe = MAX_PID;
ffffffffc020435c:	6789                	lui	a5,0x2
ffffffffc020435e:	00006717          	auipc	a4,0x6
ffffffffc0204362:	cef72f23          	sw	a5,-770(a4) # ffffffffc020a05c <next_safe.1574>
ffffffffc0204366:	4581                	li	a1,0
ffffffffc0204368:	87aa                	mv	a5,a0
ffffffffc020436a:	00011497          	auipc	s1,0x11
ffffffffc020436e:	27e48493          	addi	s1,s1,638 # ffffffffc02155e8 <proc_list>
    repeat:
ffffffffc0204372:	6889                	lui	a7,0x2
ffffffffc0204374:	882e                	mv	a6,a1
ffffffffc0204376:	6609                	lui	a2,0x2
        le = list;
ffffffffc0204378:	00011697          	auipc	a3,0x11
ffffffffc020437c:	27068693          	addi	a3,a3,624 # ffffffffc02155e8 <proc_list>
ffffffffc0204380:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0204382:	00968f63          	beq	a3,s1,ffffffffc02043a0 <do_fork+0x150>
            if (proc->pid == last_pid) {
ffffffffc0204386:	f3c6a703          	lw	a4,-196(a3)
ffffffffc020438a:	08e78763          	beq	a5,a4,ffffffffc0204418 <do_fork+0x1c8>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020438e:	fee7d9e3          	ble	a4,a5,ffffffffc0204380 <do_fork+0x130>
ffffffffc0204392:	fec757e3          	ble	a2,a4,ffffffffc0204380 <do_fork+0x130>
ffffffffc0204396:	6694                	ld	a3,8(a3)
ffffffffc0204398:	863a                	mv	a2,a4
ffffffffc020439a:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc020439c:	fe9695e3          	bne	a3,s1,ffffffffc0204386 <do_fork+0x136>
ffffffffc02043a0:	c591                	beqz	a1,ffffffffc02043ac <do_fork+0x15c>
ffffffffc02043a2:	00006717          	auipc	a4,0x6
ffffffffc02043a6:	caf72b23          	sw	a5,-842(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc02043aa:	853e                	mv	a0,a5
ffffffffc02043ac:	00080663          	beqz	a6,ffffffffc02043b8 <do_fork+0x168>
ffffffffc02043b0:	00006797          	auipc	a5,0x6
ffffffffc02043b4:	cac7a623          	sw	a2,-852(a5) # ffffffffc020a05c <next_safe.1574>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02043b8:	45a9                	li	a1,10
    proc->pid = get_pid();
ffffffffc02043ba:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02043bc:	2501                	sext.w	a0,a0
ffffffffc02043be:	484000ef          	jal	ra,ffffffffc0204842 <hash32>
ffffffffc02043c2:	1502                	slli	a0,a0,0x20
ffffffffc02043c4:	0000d797          	auipc	a5,0xd
ffffffffc02043c8:	09c78793          	addi	a5,a5,156 # ffffffffc0211460 <hash_list>
ffffffffc02043cc:	8171                	srli	a0,a0,0x1c
ffffffffc02043ce:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02043d0:	6518                	ld	a4,8(a0)
ffffffffc02043d2:	0d840613          	addi	a2,s0,216
    nr_process ++;
ffffffffc02043d6:	00092783          	lw	a5,0(s2)
    prev->next = next->prev = elm;
ffffffffc02043da:	e310                	sd	a2,0(a4)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02043dc:	6094                	ld	a3,0(s1)
    prev->next = next->prev = elm;
ffffffffc02043de:	e510                	sd	a2,8(a0)
    elm->next = next;
ffffffffc02043e0:	f078                	sd	a4,224(s0)
    elm->prev = prev;
ffffffffc02043e2:	ec68                	sd	a0,216(s0)
    list_add_before(&proc_list, &(proc->list_link));//连在最后
ffffffffc02043e4:	0c840713          	addi	a4,s0,200
    prev->next = next->prev = elm;
ffffffffc02043e8:	e698                	sd	a4,8(a3)
    nr_process ++;
ffffffffc02043ea:	2785                	addiw	a5,a5,1
    elm->prev = prev;
ffffffffc02043ec:	e474                	sd	a3,200(s0)
    wakeup_proc(proc);
ffffffffc02043ee:	8522                	mv	a0,s0
    elm->next = next;
ffffffffc02043f0:	e864                	sd	s1,208(s0)
    prev->next = next->prev = elm;
ffffffffc02043f2:	00011697          	auipc	a3,0x11
ffffffffc02043f6:	1ee6bb23          	sd	a4,502(a3) # ffffffffc02155e8 <proc_list>
    nr_process ++;
ffffffffc02043fa:	00011717          	auipc	a4,0x11
ffffffffc02043fe:	0cf72323          	sw	a5,198(a4) # ffffffffc02154c0 <nr_process>
    wakeup_proc(proc);
ffffffffc0204402:	374000ef          	jal	ra,ffffffffc0204776 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204406:	4048                	lw	a0,4(s0)
}
ffffffffc0204408:	70a2                	ld	ra,40(sp)
ffffffffc020440a:	7402                	ld	s0,32(sp)
ffffffffc020440c:	64e2                	ld	s1,24(sp)
ffffffffc020440e:	6942                	ld	s2,16(sp)
ffffffffc0204410:	69a2                	ld	s3,8(sp)
ffffffffc0204412:	6a02                	ld	s4,0(sp)
ffffffffc0204414:	6145                	addi	sp,sp,48
ffffffffc0204416:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0204418:	2785                	addiw	a5,a5,1
ffffffffc020441a:	00c7dd63          	ble	a2,a5,ffffffffc0204434 <do_fork+0x1e4>
ffffffffc020441e:	4585                	li	a1,1
ffffffffc0204420:	b785                	j	ffffffffc0204380 <do_fork+0x130>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp; //esp为0，是为了复制一个内核线程，所以直接用
ffffffffc0204422:	89b6                	mv	s3,a3
ffffffffc0204424:	bddd                	j	ffffffffc020431a <do_fork+0xca>
        last_pid = 1;
ffffffffc0204426:	4785                	li	a5,1
ffffffffc0204428:	00006717          	auipc	a4,0x6
ffffffffc020442c:	c2f72823          	sw	a5,-976(a4) # ffffffffc020a058 <last_pid.1575>
ffffffffc0204430:	4505                	li	a0,1
ffffffffc0204432:	b72d                	j	ffffffffc020435c <do_fork+0x10c>
                    if (last_pid >= MAX_PID) {
ffffffffc0204434:	0117c363          	blt	a5,a7,ffffffffc020443a <do_fork+0x1ea>
                        last_pid = 1;
ffffffffc0204438:	4785                	li	a5,1
                    goto repeat;
ffffffffc020443a:	4585                	li	a1,1
ffffffffc020443c:	bf25                	j	ffffffffc0204374 <do_fork+0x124>
    kfree(proc);
ffffffffc020443e:	8522                	mv	a0,s0
ffffffffc0204440:	df2fd0ef          	jal	ra,ffffffffc0201a32 <kfree>
    ret = -E_NO_MEM;
ffffffffc0204444:	5571                	li	a0,-4
    return ret;
ffffffffc0204446:	b7c9                	j	ffffffffc0204408 <do_fork+0x1b8>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204448:	556d                	li	a0,-5
ffffffffc020444a:	bf7d                	j	ffffffffc0204408 <do_fork+0x1b8>
    assert(current->mm == NULL);
ffffffffc020444c:	00002697          	auipc	a3,0x2
ffffffffc0204450:	5bc68693          	addi	a3,a3,1468 # ffffffffc0206a08 <default_pmm_manager+0xf80>
ffffffffc0204454:	00001617          	auipc	a2,0x1
ffffffffc0204458:	29c60613          	addi	a2,a2,668 # ffffffffc02056f0 <commands+0x870>
ffffffffc020445c:	11d00593          	li	a1,285
ffffffffc0204460:	00002517          	auipc	a0,0x2
ffffffffc0204464:	5c050513          	addi	a0,a0,1472 # ffffffffc0206a20 <default_pmm_manager+0xf98>
ffffffffc0204468:	fe9fb0ef          	jal	ra,ffffffffc0200450 <__panic>
ffffffffc020446c:	00001617          	auipc	a2,0x1
ffffffffc0204470:	66c60613          	addi	a2,a2,1644 # ffffffffc0205ad8 <default_pmm_manager+0x50>
ffffffffc0204474:	06900593          	li	a1,105
ffffffffc0204478:	00001517          	auipc	a0,0x1
ffffffffc020447c:	68850513          	addi	a0,a0,1672 # ffffffffc0205b00 <default_pmm_manager+0x78>
ffffffffc0204480:	fd1fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc0204484 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0204484:	7129                	addi	sp,sp,-320
ffffffffc0204486:	fa22                	sd	s0,304(sp)
ffffffffc0204488:	f626                	sd	s1,296(sp)
ffffffffc020448a:	f24a                	sd	s2,288(sp)
ffffffffc020448c:	84ae                	mv	s1,a1
ffffffffc020448e:	892a                	mv	s2,a0
ffffffffc0204490:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204492:	4581                	li	a1,0
ffffffffc0204494:	12000613          	li	a2,288
ffffffffc0204498:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020449a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc020449c:	055000ef          	jal	ra,ffffffffc0204cf0 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02044a0:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02044a2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02044a4:	100027f3          	csrr	a5,sstatus
ffffffffc02044a8:	edd7f793          	andi	a5,a5,-291
ffffffffc02044ac:	1207e793          	ori	a5,a5,288
ffffffffc02044b0:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044b2:	860a                	mv	a2,sp
ffffffffc02044b4:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044b8:	00000797          	auipc	a5,0x0
ffffffffc02044bc:	b9c78793          	addi	a5,a5,-1124 # ffffffffc0204054 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044c0:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02044c2:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02044c4:	d8dff0ef          	jal	ra,ffffffffc0204250 <do_fork>
}
ffffffffc02044c8:	70f2                	ld	ra,312(sp)
ffffffffc02044ca:	7452                	ld	s0,304(sp)
ffffffffc02044cc:	74b2                	ld	s1,296(sp)
ffffffffc02044ce:	7912                	ld	s2,288(sp)
ffffffffc02044d0:	6131                	addi	sp,sp,320
ffffffffc02044d2:	8082                	ret

ffffffffc02044d4 <do_exit>:
do_exit(int error_code) {
ffffffffc02044d4:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");
ffffffffc02044d6:	00002617          	auipc	a2,0x2
ffffffffc02044da:	51a60613          	addi	a2,a2,1306 # ffffffffc02069f0 <default_pmm_manager+0xf68>
ffffffffc02044de:	18500593          	li	a1,389
ffffffffc02044e2:	00002517          	auipc	a0,0x2
ffffffffc02044e6:	53e50513          	addi	a0,a0,1342 # ffffffffc0206a20 <default_pmm_manager+0xf98>
do_exit(int error_code) {
ffffffffc02044ea:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");
ffffffffc02044ec:	f65fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02044f0 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc02044f0:	00011797          	auipc	a5,0x11
ffffffffc02044f4:	0f878793          	addi	a5,a5,248 # ffffffffc02155e8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc02044f8:	1101                	addi	sp,sp,-32
ffffffffc02044fa:	00011717          	auipc	a4,0x11
ffffffffc02044fe:	0ef73b23          	sd	a5,246(a4) # ffffffffc02155f0 <proc_list+0x8>
ffffffffc0204502:	00011717          	auipc	a4,0x11
ffffffffc0204506:	0ef73323          	sd	a5,230(a4) # ffffffffc02155e8 <proc_list>
ffffffffc020450a:	ec06                	sd	ra,24(sp)
ffffffffc020450c:	e822                	sd	s0,16(sp)
ffffffffc020450e:	e426                	sd	s1,8(sp)
ffffffffc0204510:	e04a                	sd	s2,0(sp)
ffffffffc0204512:	0000d797          	auipc	a5,0xd
ffffffffc0204516:	f4e78793          	addi	a5,a5,-178 # ffffffffc0211460 <hash_list>
ffffffffc020451a:	00011717          	auipc	a4,0x11
ffffffffc020451e:	f4670713          	addi	a4,a4,-186 # ffffffffc0215460 <name.1565>
ffffffffc0204522:	e79c                	sd	a5,8(a5)
ffffffffc0204524:	e39c                	sd	a5,0(a5)
ffffffffc0204526:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0204528:	fee79de3          	bne	a5,a4,ffffffffc0204522 <proc_init+0x32>
        list_init(hash_list + i);
    }

    // 创建内核线程idle
    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc020452c:	b31ff0ef          	jal	ra,ffffffffc020405c <alloc_proc>
ffffffffc0204530:	00011797          	auipc	a5,0x11
ffffffffc0204534:	f8a7b023          	sd	a0,-128(a5) # ffffffffc02154b0 <idleproc>
ffffffffc0204538:	00011417          	auipc	s0,0x11
ffffffffc020453c:	f7840413          	addi	s0,s0,-136 # ffffffffc02154b0 <idleproc>
ffffffffc0204540:	14050063          	beqz	a0,ffffffffc0204680 <proc_init+0x190>
        panic("cannot alloc idleproc.\n");
    }

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204544:	07000513          	li	a0,112
ffffffffc0204548:	c2efd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020454c:	07000613          	li	a2,112
ffffffffc0204550:	4581                	li	a1,0
    int *context_mem = (int*) kmalloc(sizeof(struct context));
ffffffffc0204552:	84aa                	mv	s1,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0204554:	79c000ef          	jal	ra,ffffffffc0204cf0 <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc0204558:	6008                	ld	a0,0(s0)
ffffffffc020455a:	85a6                	mv	a1,s1
ffffffffc020455c:	07000613          	li	a2,112
ffffffffc0204560:	03050513          	addi	a0,a0,48
ffffffffc0204564:	7b6000ef          	jal	ra,ffffffffc0204d1a <memcmp>
ffffffffc0204568:	892a                	mv	s2,a0

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc020456a:	453d                	li	a0,15
ffffffffc020456c:	c0afd0ef          	jal	ra,ffffffffc0201976 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204570:	463d                	li	a2,15
ffffffffc0204572:	4581                	li	a1,0
    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
ffffffffc0204574:	84aa                	mv	s1,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0204576:	77a000ef          	jal	ra,ffffffffc0204cf0 <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc020457a:	6008                	ld	a0,0(s0)
ffffffffc020457c:	463d                	li	a2,15
ffffffffc020457e:	85a6                	mv	a1,s1
ffffffffc0204580:	0b450513          	addi	a0,a0,180
ffffffffc0204584:	796000ef          	jal	ra,ffffffffc0204d1a <memcmp>

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc0204588:	601c                	ld	a5,0(s0)
ffffffffc020458a:	00011717          	auipc	a4,0x11
ffffffffc020458e:	f6e70713          	addi	a4,a4,-146 # ffffffffc02154f8 <boot_cr3>
ffffffffc0204592:	6318                	ld	a4,0(a4)
ffffffffc0204594:	77d4                	ld	a3,168(a5)
ffffffffc0204596:	0ae68463          	beq	a3,a4,ffffffffc020463e <proc_init+0x14e>
        cprintf("alloc_proc() correct!\n");

    }
    
    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc020459a:	4709                	li	a4,2
ffffffffc020459c:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc020459e:	00003717          	auipc	a4,0x3
ffffffffc02045a2:	a6270713          	addi	a4,a4,-1438 # ffffffffc0207000 <bootstack>
ffffffffc02045a6:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;
ffffffffc02045a8:	4705                	li	a4,1
ffffffffc02045aa:	cf98                	sw	a4,24(a5)
    set_proc_name(idleproc, "idle");
ffffffffc02045ac:	00002597          	auipc	a1,0x2
ffffffffc02045b0:	51458593          	addi	a1,a1,1300 # ffffffffc0206ac0 <default_pmm_manager+0x1038>
ffffffffc02045b4:	853e                	mv	a0,a5
ffffffffc02045b6:	b23ff0ef          	jal	ra,ffffffffc02040d8 <set_proc_name>
    nr_process ++;
ffffffffc02045ba:	00011797          	auipc	a5,0x11
ffffffffc02045be:	f0678793          	addi	a5,a5,-250 # ffffffffc02154c0 <nr_process>
ffffffffc02045c2:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc02045c4:	6018                	ld	a4,0(s0)

    // kernel_thread创建init内核线程
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02045c6:	4601                	li	a2,0
    nr_process ++;
ffffffffc02045c8:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02045ca:	00002597          	auipc	a1,0x2
ffffffffc02045ce:	4fe58593          	addi	a1,a1,1278 # ffffffffc0206ac8 <default_pmm_manager+0x1040>
ffffffffc02045d2:	00000517          	auipc	a0,0x0
ffffffffc02045d6:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204132 <init_main>
    nr_process ++;
ffffffffc02045da:	00011697          	auipc	a3,0x11
ffffffffc02045de:	eef6a323          	sw	a5,-282(a3) # ffffffffc02154c0 <nr_process>
    current = idleproc;
ffffffffc02045e2:	00011797          	auipc	a5,0x11
ffffffffc02045e6:	ece7b323          	sd	a4,-314(a5) # ffffffffc02154a8 <current>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02045ea:	e9bff0ef          	jal	ra,ffffffffc0204484 <kernel_thread>
    if (pid <= 0) {
ffffffffc02045ee:	0ea05563          	blez	a0,ffffffffc02046d8 <proc_init+0x1e8>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc02045f2:	c03ff0ef          	jal	ra,ffffffffc02041f4 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc02045f6:	00002597          	auipc	a1,0x2
ffffffffc02045fa:	50258593          	addi	a1,a1,1282 # ffffffffc0206af8 <default_pmm_manager+0x1070>
    initproc = find_proc(pid);
ffffffffc02045fe:	00011797          	auipc	a5,0x11
ffffffffc0204602:	eaa7bd23          	sd	a0,-326(a5) # ffffffffc02154b8 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0204606:	ad3ff0ef          	jal	ra,ffffffffc02040d8 <set_proc_name>

    cprintf("here\n\n\n");
ffffffffc020460a:	00002517          	auipc	a0,0x2
ffffffffc020460e:	f6e50513          	addi	a0,a0,-146 # ffffffffc0206578 <default_pmm_manager+0xaf0>
ffffffffc0204612:	b7dfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204616:	601c                	ld	a5,0(s0)
ffffffffc0204618:	c3c5                	beqz	a5,ffffffffc02046b8 <proc_init+0x1c8>
ffffffffc020461a:	43dc                	lw	a5,4(a5)
ffffffffc020461c:	efd1                	bnez	a5,ffffffffc02046b8 <proc_init+0x1c8>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020461e:	00011797          	auipc	a5,0x11
ffffffffc0204622:	e9a78793          	addi	a5,a5,-358 # ffffffffc02154b8 <initproc>
ffffffffc0204626:	639c                	ld	a5,0(a5)
ffffffffc0204628:	cba5                	beqz	a5,ffffffffc0204698 <proc_init+0x1a8>
ffffffffc020462a:	43d8                	lw	a4,4(a5)
ffffffffc020462c:	4785                	li	a5,1
ffffffffc020462e:	06f71563          	bne	a4,a5,ffffffffc0204698 <proc_init+0x1a8>
}
ffffffffc0204632:	60e2                	ld	ra,24(sp)
ffffffffc0204634:	6442                	ld	s0,16(sp)
ffffffffc0204636:	64a2                	ld	s1,8(sp)
ffffffffc0204638:	6902                	ld	s2,0(sp)
ffffffffc020463a:	6105                	addi	sp,sp,32
ffffffffc020463c:	8082                	ret
    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL && !context_init_flag
ffffffffc020463e:	73d8                	ld	a4,160(a5)
ffffffffc0204640:	ff29                	bnez	a4,ffffffffc020459a <proc_init+0xaa>
ffffffffc0204642:	f4091ce3          	bnez	s2,ffffffffc020459a <proc_init+0xaa>
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
ffffffffc0204646:	6394                	ld	a3,0(a5)
ffffffffc0204648:	577d                	li	a4,-1
ffffffffc020464a:	1702                	slli	a4,a4,0x20
ffffffffc020464c:	f4e697e3          	bne	a3,a4,ffffffffc020459a <proc_init+0xaa>
ffffffffc0204650:	4798                	lw	a4,8(a5)
ffffffffc0204652:	f721                	bnez	a4,ffffffffc020459a <proc_init+0xaa>
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
ffffffffc0204654:	6b98                	ld	a4,16(a5)
ffffffffc0204656:	f331                	bnez	a4,ffffffffc020459a <proc_init+0xaa>
ffffffffc0204658:	4f98                	lw	a4,24(a5)
ffffffffc020465a:	2701                	sext.w	a4,a4
ffffffffc020465c:	ff1d                	bnez	a4,ffffffffc020459a <proc_init+0xaa>
ffffffffc020465e:	7398                	ld	a4,32(a5)
ffffffffc0204660:	ff0d                	bnez	a4,ffffffffc020459a <proc_init+0xaa>
        && idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag
ffffffffc0204662:	7798                	ld	a4,40(a5)
ffffffffc0204664:	fb1d                	bnez	a4,ffffffffc020459a <proc_init+0xaa>
ffffffffc0204666:	0b07a703          	lw	a4,176(a5)
ffffffffc020466a:	8f49                	or	a4,a4,a0
ffffffffc020466c:	2701                	sext.w	a4,a4
ffffffffc020466e:	f715                	bnez	a4,ffffffffc020459a <proc_init+0xaa>
        cprintf("alloc_proc() correct!\n");
ffffffffc0204670:	00002517          	auipc	a0,0x2
ffffffffc0204674:	43850513          	addi	a0,a0,1080 # ffffffffc0206aa8 <default_pmm_manager+0x1020>
ffffffffc0204678:	b17fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020467c:	601c                	ld	a5,0(s0)
ffffffffc020467e:	bf31                	j	ffffffffc020459a <proc_init+0xaa>
        panic("cannot alloc idleproc.\n");
ffffffffc0204680:	00002617          	auipc	a2,0x2
ffffffffc0204684:	41060613          	addi	a2,a2,1040 # ffffffffc0206a90 <default_pmm_manager+0x1008>
ffffffffc0204688:	19e00593          	li	a1,414
ffffffffc020468c:	00002517          	auipc	a0,0x2
ffffffffc0204690:	39450513          	addi	a0,a0,916 # ffffffffc0206a20 <default_pmm_manager+0xf98>
ffffffffc0204694:	dbdfb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204698:	00002697          	auipc	a3,0x2
ffffffffc020469c:	49068693          	addi	a3,a3,1168 # ffffffffc0206b28 <default_pmm_manager+0x10a0>
ffffffffc02046a0:	00001617          	auipc	a2,0x1
ffffffffc02046a4:	05060613          	addi	a2,a2,80 # ffffffffc02056f0 <commands+0x870>
ffffffffc02046a8:	1c700593          	li	a1,455
ffffffffc02046ac:	00002517          	auipc	a0,0x2
ffffffffc02046b0:	37450513          	addi	a0,a0,884 # ffffffffc0206a20 <default_pmm_manager+0xf98>
ffffffffc02046b4:	d9dfb0ef          	jal	ra,ffffffffc0200450 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02046b8:	00002697          	auipc	a3,0x2
ffffffffc02046bc:	44868693          	addi	a3,a3,1096 # ffffffffc0206b00 <default_pmm_manager+0x1078>
ffffffffc02046c0:	00001617          	auipc	a2,0x1
ffffffffc02046c4:	03060613          	addi	a2,a2,48 # ffffffffc02056f0 <commands+0x870>
ffffffffc02046c8:	1c600593          	li	a1,454
ffffffffc02046cc:	00002517          	auipc	a0,0x2
ffffffffc02046d0:	35450513          	addi	a0,a0,852 # ffffffffc0206a20 <default_pmm_manager+0xf98>
ffffffffc02046d4:	d7dfb0ef          	jal	ra,ffffffffc0200450 <__panic>
        panic("create init_main failed.\n");
ffffffffc02046d8:	00002617          	auipc	a2,0x2
ffffffffc02046dc:	40060613          	addi	a2,a2,1024 # ffffffffc0206ad8 <default_pmm_manager+0x1050>
ffffffffc02046e0:	1bf00593          	li	a1,447
ffffffffc02046e4:	00002517          	auipc	a0,0x2
ffffffffc02046e8:	33c50513          	addi	a0,a0,828 # ffffffffc0206a20 <default_pmm_manager+0xf98>
ffffffffc02046ec:	d65fb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02046f0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc02046f0:	1141                	addi	sp,sp,-16
ffffffffc02046f2:	e022                	sd	s0,0(sp)
ffffffffc02046f4:	e406                	sd	ra,8(sp)
ffffffffc02046f6:	00011417          	auipc	s0,0x11
ffffffffc02046fa:	db240413          	addi	s0,s0,-590 # ffffffffc02154a8 <current>
    while (1) {
        if (current->need_resched) { //调度器调度
ffffffffc02046fe:	6018                	ld	a4,0(s0)
ffffffffc0204700:	4f1c                	lw	a5,24(a4)
ffffffffc0204702:	2781                	sext.w	a5,a5
ffffffffc0204704:	dff5                	beqz	a5,ffffffffc0204700 <cpu_idle+0x10>
            schedule();
ffffffffc0204706:	0a2000ef          	jal	ra,ffffffffc02047a8 <schedule>
ffffffffc020470a:	bfd5                	j	ffffffffc02046fe <cpu_idle+0xe>

ffffffffc020470c <switch_to>:
.text
# void switch_to(struct context* from, struct context* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc020470c:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0204710:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0204714:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0204716:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0204718:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc020471c:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0204720:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0204724:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0204728:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc020472c:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0204730:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0204734:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0204738:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc020473c:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0204740:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0204744:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0204748:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc020474a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc020474c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0204750:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0204754:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0204758:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc020475c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0204760:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0204764:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0204768:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc020476c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0204770:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0204774:	8082                	ret

ffffffffc0204776 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204776:	411c                	lw	a5,0(a0)
ffffffffc0204778:	4705                	li	a4,1
ffffffffc020477a:	37f9                	addiw	a5,a5,-2
ffffffffc020477c:	00f77563          	bleu	a5,a4,ffffffffc0204786 <wakeup_proc+0x10>
    proc->state = PROC_RUNNABLE;
ffffffffc0204780:	4789                	li	a5,2
ffffffffc0204782:	c11c                	sw	a5,0(a0)
ffffffffc0204784:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc0204786:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc0204788:	00002697          	auipc	a3,0x2
ffffffffc020478c:	3c868693          	addi	a3,a3,968 # ffffffffc0206b50 <default_pmm_manager+0x10c8>
ffffffffc0204790:	00001617          	auipc	a2,0x1
ffffffffc0204794:	f6060613          	addi	a2,a2,-160 # ffffffffc02056f0 <commands+0x870>
ffffffffc0204798:	45a5                	li	a1,9
ffffffffc020479a:	00002517          	auipc	a0,0x2
ffffffffc020479e:	3f650513          	addi	a0,a0,1014 # ffffffffc0206b90 <default_pmm_manager+0x1108>
wakeup_proc(struct proc_struct *proc) {
ffffffffc02047a2:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02047a4:	cadfb0ef          	jal	ra,ffffffffc0200450 <__panic>

ffffffffc02047a8 <schedule>:
}

void
schedule(void) {
ffffffffc02047a8:	1141                	addi	sp,sp,-16
ffffffffc02047aa:	e406                	sd	ra,8(sp)
ffffffffc02047ac:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02047ae:	100027f3          	csrr	a5,sstatus
ffffffffc02047b2:	8b89                	andi	a5,a5,2
ffffffffc02047b4:	4401                	li	s0,0
ffffffffc02047b6:	e3d1                	bnez	a5,ffffffffc020483a <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02047b8:	00011797          	auipc	a5,0x11
ffffffffc02047bc:	cf078793          	addi	a5,a5,-784 # ffffffffc02154a8 <current>
ffffffffc02047c0:	0007b883          	ld	a7,0(a5)
        // 如果是idle线程就从斗开始查，因为idle是不在表里面的
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02047c4:	00011797          	auipc	a5,0x11
ffffffffc02047c8:	cec78793          	addi	a5,a5,-788 # ffffffffc02154b0 <idleproc>
ffffffffc02047cc:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc02047ce:	0008ac23          	sw	zero,24(a7) # 2018 <BASE_ADDRESS-0xffffffffc01fdfe8>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02047d2:	04a88e63          	beq	a7,a0,ffffffffc020482e <schedule+0x86>
ffffffffc02047d6:	0c888693          	addi	a3,a7,200
ffffffffc02047da:	00011617          	auipc	a2,0x11
ffffffffc02047de:	e0e60613          	addi	a2,a2,-498 # ffffffffc02155e8 <proc_list>
        le = last;
ffffffffc02047e2:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc02047e4:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047e6:	4809                	li	a6,2
    return listelm->next;
ffffffffc02047e8:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc02047ea:	00c78863          	beq	a5,a2,ffffffffc02047fa <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047ee:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc02047f2:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc02047f6:	01070463          	beq	a4,a6,ffffffffc02047fe <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc02047fa:	fef697e3          	bne	a3,a5,ffffffffc02047e8 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02047fe:	c589                	beqz	a1,ffffffffc0204808 <schedule+0x60>
ffffffffc0204800:	4198                	lw	a4,0(a1)
ffffffffc0204802:	4789                	li	a5,2
ffffffffc0204804:	00f70e63          	beq	a4,a5,ffffffffc0204820 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0204808:	451c                	lw	a5,8(a0)
ffffffffc020480a:	2785                	addiw	a5,a5,1
ffffffffc020480c:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc020480e:	00a88463          	beq	a7,a0,ffffffffc0204816 <schedule+0x6e>
            proc_run(next);
ffffffffc0204812:	973ff0ef          	jal	ra,ffffffffc0204184 <proc_run>
    if (flag) {
ffffffffc0204816:	e419                	bnez	s0,ffffffffc0204824 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0204818:	60a2                	ld	ra,8(sp)
ffffffffc020481a:	6402                	ld	s0,0(sp)
ffffffffc020481c:	0141                	addi	sp,sp,16
ffffffffc020481e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0204820:	852e                	mv	a0,a1
ffffffffc0204822:	b7dd                	j	ffffffffc0204808 <schedule+0x60>
}
ffffffffc0204824:	6402                	ld	s0,0(sp)
ffffffffc0204826:	60a2                	ld	ra,8(sp)
ffffffffc0204828:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020482a:	d85fb06f          	j	ffffffffc02005ae <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020482e:	00011617          	auipc	a2,0x11
ffffffffc0204832:	dba60613          	addi	a2,a2,-582 # ffffffffc02155e8 <proc_list>
ffffffffc0204836:	86b2                	mv	a3,a2
ffffffffc0204838:	b76d                	j	ffffffffc02047e2 <schedule+0x3a>
        intr_disable();
ffffffffc020483a:	d7bfb0ef          	jal	ra,ffffffffc02005b4 <intr_disable>
        return 1;
ffffffffc020483e:	4405                	li	s0,1
ffffffffc0204840:	bfa5                	j	ffffffffc02047b8 <schedule+0x10>

ffffffffc0204842 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0204842:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204846:	2785                	addiw	a5,a5,1
ffffffffc0204848:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc020484c:	02000793          	li	a5,32
ffffffffc0204850:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0204854:	00b5553b          	srlw	a0,a0,a1
ffffffffc0204858:	8082                	ret

ffffffffc020485a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020485a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020485e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0204860:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0204864:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0204866:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020486a:	f022                	sd	s0,32(sp)
ffffffffc020486c:	ec26                	sd	s1,24(sp)
ffffffffc020486e:	e84a                	sd	s2,16(sp)
ffffffffc0204870:	f406                	sd	ra,40(sp)
ffffffffc0204872:	e44e                	sd	s3,8(sp)
ffffffffc0204874:	84aa                	mv	s1,a0
ffffffffc0204876:	892e                	mv	s2,a1
ffffffffc0204878:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020487c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020487e:	03067e63          	bleu	a6,a2,ffffffffc02048ba <printnum+0x60>
ffffffffc0204882:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0204884:	00805763          	blez	s0,ffffffffc0204892 <printnum+0x38>
ffffffffc0204888:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020488a:	85ca                	mv	a1,s2
ffffffffc020488c:	854e                	mv	a0,s3
ffffffffc020488e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0204890:	fc65                	bnez	s0,ffffffffc0204888 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204892:	1a02                	slli	s4,s4,0x20
ffffffffc0204894:	020a5a13          	srli	s4,s4,0x20
ffffffffc0204898:	00002797          	auipc	a5,0x2
ffffffffc020489c:	4a078793          	addi	a5,a5,1184 # ffffffffc0206d38 <error_string+0x38>
ffffffffc02048a0:	9a3e                	add	s4,s4,a5
}
ffffffffc02048a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02048a4:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02048a8:	70a2                	ld	ra,40(sp)
ffffffffc02048aa:	69a2                	ld	s3,8(sp)
ffffffffc02048ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02048ae:	85ca                	mv	a1,s2
ffffffffc02048b0:	8326                	mv	t1,s1
}
ffffffffc02048b2:	6942                	ld	s2,16(sp)
ffffffffc02048b4:	64e2                	ld	s1,24(sp)
ffffffffc02048b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02048b8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02048ba:	03065633          	divu	a2,a2,a6
ffffffffc02048be:	8722                	mv	a4,s0
ffffffffc02048c0:	f9bff0ef          	jal	ra,ffffffffc020485a <printnum>
ffffffffc02048c4:	b7f9                	j	ffffffffc0204892 <printnum+0x38>

ffffffffc02048c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02048c6:	7119                	addi	sp,sp,-128
ffffffffc02048c8:	f4a6                	sd	s1,104(sp)
ffffffffc02048ca:	f0ca                	sd	s2,96(sp)
ffffffffc02048cc:	e8d2                	sd	s4,80(sp)
ffffffffc02048ce:	e4d6                	sd	s5,72(sp)
ffffffffc02048d0:	e0da                	sd	s6,64(sp)
ffffffffc02048d2:	fc5e                	sd	s7,56(sp)
ffffffffc02048d4:	f862                	sd	s8,48(sp)
ffffffffc02048d6:	f06a                	sd	s10,32(sp)
ffffffffc02048d8:	fc86                	sd	ra,120(sp)
ffffffffc02048da:	f8a2                	sd	s0,112(sp)
ffffffffc02048dc:	ecce                	sd	s3,88(sp)
ffffffffc02048de:	f466                	sd	s9,40(sp)
ffffffffc02048e0:	ec6e                	sd	s11,24(sp)
ffffffffc02048e2:	892a                	mv	s2,a0
ffffffffc02048e4:	84ae                	mv	s1,a1
ffffffffc02048e6:	8d32                	mv	s10,a2
ffffffffc02048e8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02048ea:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02048ec:	00002a17          	auipc	s4,0x2
ffffffffc02048f0:	2bca0a13          	addi	s4,s4,700 # ffffffffc0206ba8 <default_pmm_manager+0x1120>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02048f4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02048f8:	00002c17          	auipc	s8,0x2
ffffffffc02048fc:	408c0c13          	addi	s8,s8,1032 # ffffffffc0206d00 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204900:	000d4503          	lbu	a0,0(s10) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0204904:	02500793          	li	a5,37
ffffffffc0204908:	001d0413          	addi	s0,s10,1
ffffffffc020490c:	00f50e63          	beq	a0,a5,ffffffffc0204928 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0204910:	c521                	beqz	a0,ffffffffc0204958 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204912:	02500993          	li	s3,37
ffffffffc0204916:	a011                	j	ffffffffc020491a <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0204918:	c121                	beqz	a0,ffffffffc0204958 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020491a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020491c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020491e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204920:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204924:	ff351ae3          	bne	a0,s3,ffffffffc0204918 <vprintfmt+0x52>
ffffffffc0204928:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020492c:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204930:	4981                	li	s3,0
ffffffffc0204932:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0204934:	5cfd                	li	s9,-1
ffffffffc0204936:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204938:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc020493c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020493e:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0204942:	0ff6f693          	andi	a3,a3,255
ffffffffc0204946:	00140d13          	addi	s10,s0,1
ffffffffc020494a:	20d5e563          	bltu	a1,a3,ffffffffc0204b54 <vprintfmt+0x28e>
ffffffffc020494e:	068a                	slli	a3,a3,0x2
ffffffffc0204950:	96d2                	add	a3,a3,s4
ffffffffc0204952:	4294                	lw	a3,0(a3)
ffffffffc0204954:	96d2                	add	a3,a3,s4
ffffffffc0204956:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0204958:	70e6                	ld	ra,120(sp)
ffffffffc020495a:	7446                	ld	s0,112(sp)
ffffffffc020495c:	74a6                	ld	s1,104(sp)
ffffffffc020495e:	7906                	ld	s2,96(sp)
ffffffffc0204960:	69e6                	ld	s3,88(sp)
ffffffffc0204962:	6a46                	ld	s4,80(sp)
ffffffffc0204964:	6aa6                	ld	s5,72(sp)
ffffffffc0204966:	6b06                	ld	s6,64(sp)
ffffffffc0204968:	7be2                	ld	s7,56(sp)
ffffffffc020496a:	7c42                	ld	s8,48(sp)
ffffffffc020496c:	7ca2                	ld	s9,40(sp)
ffffffffc020496e:	7d02                	ld	s10,32(sp)
ffffffffc0204970:	6de2                	ld	s11,24(sp)
ffffffffc0204972:	6109                	addi	sp,sp,128
ffffffffc0204974:	8082                	ret
    if (lflag >= 2) {
ffffffffc0204976:	4705                	li	a4,1
ffffffffc0204978:	008a8593          	addi	a1,s5,8
ffffffffc020497c:	01074463          	blt	a4,a6,ffffffffc0204984 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0204980:	26080363          	beqz	a6,ffffffffc0204be6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0204984:	000ab603          	ld	a2,0(s5)
ffffffffc0204988:	46c1                	li	a3,16
ffffffffc020498a:	8aae                	mv	s5,a1
ffffffffc020498c:	a06d                	j	ffffffffc0204a36 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020498e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0204992:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204994:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204996:	b765                	j	ffffffffc020493e <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0204998:	000aa503          	lw	a0,0(s5)
ffffffffc020499c:	85a6                	mv	a1,s1
ffffffffc020499e:	0aa1                	addi	s5,s5,8
ffffffffc02049a0:	9902                	jalr	s2
            break;
ffffffffc02049a2:	bfb9                	j	ffffffffc0204900 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02049a4:	4705                	li	a4,1
ffffffffc02049a6:	008a8993          	addi	s3,s5,8
ffffffffc02049aa:	01074463          	blt	a4,a6,ffffffffc02049b2 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc02049ae:	22080463          	beqz	a6,ffffffffc0204bd6 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc02049b2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02049b6:	24044463          	bltz	s0,ffffffffc0204bfe <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02049ba:	8622                	mv	a2,s0
ffffffffc02049bc:	8ace                	mv	s5,s3
ffffffffc02049be:	46a9                	li	a3,10
ffffffffc02049c0:	a89d                	j	ffffffffc0204a36 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02049c2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02049c6:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02049c8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02049ca:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02049ce:	8fb5                	xor	a5,a5,a3
ffffffffc02049d0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02049d4:	1ad74363          	blt	a4,a3,ffffffffc0204b7a <vprintfmt+0x2b4>
ffffffffc02049d8:	00369793          	slli	a5,a3,0x3
ffffffffc02049dc:	97e2                	add	a5,a5,s8
ffffffffc02049de:	639c                	ld	a5,0(a5)
ffffffffc02049e0:	18078d63          	beqz	a5,ffffffffc0204b7a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02049e4:	86be                	mv	a3,a5
ffffffffc02049e6:	00000617          	auipc	a2,0x0
ffffffffc02049ea:	39260613          	addi	a2,a2,914 # ffffffffc0204d78 <etext+0x2e>
ffffffffc02049ee:	85a6                	mv	a1,s1
ffffffffc02049f0:	854a                	mv	a0,s2
ffffffffc02049f2:	240000ef          	jal	ra,ffffffffc0204c32 <printfmt>
ffffffffc02049f6:	b729                	j	ffffffffc0204900 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02049f8:	00144603          	lbu	a2,1(s0)
ffffffffc02049fc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02049fe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204a00:	bf3d                	j	ffffffffc020493e <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0204a02:	4705                	li	a4,1
ffffffffc0204a04:	008a8593          	addi	a1,s5,8
ffffffffc0204a08:	01074463          	blt	a4,a6,ffffffffc0204a10 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0204a0c:	1e080263          	beqz	a6,ffffffffc0204bf0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0204a10:	000ab603          	ld	a2,0(s5)
ffffffffc0204a14:	46a1                	li	a3,8
ffffffffc0204a16:	8aae                	mv	s5,a1
ffffffffc0204a18:	a839                	j	ffffffffc0204a36 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0204a1a:	03000513          	li	a0,48
ffffffffc0204a1e:	85a6                	mv	a1,s1
ffffffffc0204a20:	e03e                	sd	a5,0(sp)
ffffffffc0204a22:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204a24:	85a6                	mv	a1,s1
ffffffffc0204a26:	07800513          	li	a0,120
ffffffffc0204a2a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204a2c:	0aa1                	addi	s5,s5,8
ffffffffc0204a2e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204a32:	6782                	ld	a5,0(sp)
ffffffffc0204a34:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204a36:	876e                	mv	a4,s11
ffffffffc0204a38:	85a6                	mv	a1,s1
ffffffffc0204a3a:	854a                	mv	a0,s2
ffffffffc0204a3c:	e1fff0ef          	jal	ra,ffffffffc020485a <printnum>
            break;
ffffffffc0204a40:	b5c1                	j	ffffffffc0204900 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204a42:	000ab603          	ld	a2,0(s5)
ffffffffc0204a46:	0aa1                	addi	s5,s5,8
ffffffffc0204a48:	1c060663          	beqz	a2,ffffffffc0204c14 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0204a4c:	00160413          	addi	s0,a2,1
ffffffffc0204a50:	17b05c63          	blez	s11,ffffffffc0204bc8 <vprintfmt+0x302>
ffffffffc0204a54:	02d00593          	li	a1,45
ffffffffc0204a58:	14b79263          	bne	a5,a1,ffffffffc0204b9c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204a5c:	00064783          	lbu	a5,0(a2)
ffffffffc0204a60:	0007851b          	sext.w	a0,a5
ffffffffc0204a64:	c905                	beqz	a0,ffffffffc0204a94 <vprintfmt+0x1ce>
ffffffffc0204a66:	000cc563          	bltz	s9,ffffffffc0204a70 <vprintfmt+0x1aa>
ffffffffc0204a6a:	3cfd                	addiw	s9,s9,-1
ffffffffc0204a6c:	036c8263          	beq	s9,s6,ffffffffc0204a90 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0204a70:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204a72:	18098463          	beqz	s3,ffffffffc0204bfa <vprintfmt+0x334>
ffffffffc0204a76:	3781                	addiw	a5,a5,-32
ffffffffc0204a78:	18fbf163          	bleu	a5,s7,ffffffffc0204bfa <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0204a7c:	03f00513          	li	a0,63
ffffffffc0204a80:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204a82:	0405                	addi	s0,s0,1
ffffffffc0204a84:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204a88:	3dfd                	addiw	s11,s11,-1
ffffffffc0204a8a:	0007851b          	sext.w	a0,a5
ffffffffc0204a8e:	fd61                	bnez	a0,ffffffffc0204a66 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0204a90:	e7b058e3          	blez	s11,ffffffffc0204900 <vprintfmt+0x3a>
ffffffffc0204a94:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204a96:	85a6                	mv	a1,s1
ffffffffc0204a98:	02000513          	li	a0,32
ffffffffc0204a9c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204a9e:	e60d81e3          	beqz	s11,ffffffffc0204900 <vprintfmt+0x3a>
ffffffffc0204aa2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204aa4:	85a6                	mv	a1,s1
ffffffffc0204aa6:	02000513          	li	a0,32
ffffffffc0204aaa:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204aac:	fe0d94e3          	bnez	s11,ffffffffc0204a94 <vprintfmt+0x1ce>
ffffffffc0204ab0:	bd81                	j	ffffffffc0204900 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204ab2:	4705                	li	a4,1
ffffffffc0204ab4:	008a8593          	addi	a1,s5,8
ffffffffc0204ab8:	01074463          	blt	a4,a6,ffffffffc0204ac0 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204abc:	12080063          	beqz	a6,ffffffffc0204bdc <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0204ac0:	000ab603          	ld	a2,0(s5)
ffffffffc0204ac4:	46a9                	li	a3,10
ffffffffc0204ac6:	8aae                	mv	s5,a1
ffffffffc0204ac8:	b7bd                	j	ffffffffc0204a36 <vprintfmt+0x170>
ffffffffc0204aca:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204ace:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204ad2:	846a                	mv	s0,s10
ffffffffc0204ad4:	b5ad                	j	ffffffffc020493e <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204ad6:	85a6                	mv	a1,s1
ffffffffc0204ad8:	02500513          	li	a0,37
ffffffffc0204adc:	9902                	jalr	s2
            break;
ffffffffc0204ade:	b50d                	j	ffffffffc0204900 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0204ae0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0204ae4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204ae8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204aea:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204aec:	e40dd9e3          	bgez	s11,ffffffffc020493e <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0204af0:	8de6                	mv	s11,s9
ffffffffc0204af2:	5cfd                	li	s9,-1
ffffffffc0204af4:	b5a9                	j	ffffffffc020493e <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204af6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204afa:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204afe:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204b00:	bd3d                	j	ffffffffc020493e <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0204b02:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204b06:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b0a:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204b0c:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0204b10:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204b14:	fcd56ce3          	bltu	a0,a3,ffffffffc0204aec <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204b18:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204b1a:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204b1e:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204b22:	0196873b          	addw	a4,a3,s9
ffffffffc0204b26:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204b2a:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204b2e:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0204b32:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204b36:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204b3a:	fcd57fe3          	bleu	a3,a0,ffffffffc0204b18 <vprintfmt+0x252>
ffffffffc0204b3e:	b77d                	j	ffffffffc0204aec <vprintfmt+0x226>
            if (width < 0)
ffffffffc0204b40:	fffdc693          	not	a3,s11
ffffffffc0204b44:	96fd                	srai	a3,a3,0x3f
ffffffffc0204b46:	00ddfdb3          	and	s11,s11,a3
ffffffffc0204b4a:	00144603          	lbu	a2,1(s0)
ffffffffc0204b4e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204b50:	846a                	mv	s0,s10
ffffffffc0204b52:	b3f5                	j	ffffffffc020493e <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0204b54:	85a6                	mv	a1,s1
ffffffffc0204b56:	02500513          	li	a0,37
ffffffffc0204b5a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0204b5c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0204b60:	02500793          	li	a5,37
ffffffffc0204b64:	8d22                	mv	s10,s0
ffffffffc0204b66:	d8f70de3          	beq	a4,a5,ffffffffc0204900 <vprintfmt+0x3a>
ffffffffc0204b6a:	02500713          	li	a4,37
ffffffffc0204b6e:	1d7d                	addi	s10,s10,-1
ffffffffc0204b70:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0204b74:	fee79de3          	bne	a5,a4,ffffffffc0204b6e <vprintfmt+0x2a8>
ffffffffc0204b78:	b361                	j	ffffffffc0204900 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0204b7a:	00002617          	auipc	a2,0x2
ffffffffc0204b7e:	25e60613          	addi	a2,a2,606 # ffffffffc0206dd8 <error_string+0xd8>
ffffffffc0204b82:	85a6                	mv	a1,s1
ffffffffc0204b84:	854a                	mv	a0,s2
ffffffffc0204b86:	0ac000ef          	jal	ra,ffffffffc0204c32 <printfmt>
ffffffffc0204b8a:	bb9d                	j	ffffffffc0204900 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204b8c:	00002617          	auipc	a2,0x2
ffffffffc0204b90:	24460613          	addi	a2,a2,580 # ffffffffc0206dd0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0204b94:	00002417          	auipc	s0,0x2
ffffffffc0204b98:	23d40413          	addi	s0,s0,573 # ffffffffc0206dd1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204b9c:	8532                	mv	a0,a2
ffffffffc0204b9e:	85e6                	mv	a1,s9
ffffffffc0204ba0:	e032                	sd	a2,0(sp)
ffffffffc0204ba2:	e43e                	sd	a5,8(sp)
ffffffffc0204ba4:	0cc000ef          	jal	ra,ffffffffc0204c70 <strnlen>
ffffffffc0204ba8:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204bac:	6602                	ld	a2,0(sp)
ffffffffc0204bae:	01b05d63          	blez	s11,ffffffffc0204bc8 <vprintfmt+0x302>
ffffffffc0204bb2:	67a2                	ld	a5,8(sp)
ffffffffc0204bb4:	2781                	sext.w	a5,a5
ffffffffc0204bb6:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204bb8:	6522                	ld	a0,8(sp)
ffffffffc0204bba:	85a6                	mv	a1,s1
ffffffffc0204bbc:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204bbe:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204bc0:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204bc2:	6602                	ld	a2,0(sp)
ffffffffc0204bc4:	fe0d9ae3          	bnez	s11,ffffffffc0204bb8 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204bc8:	00064783          	lbu	a5,0(a2)
ffffffffc0204bcc:	0007851b          	sext.w	a0,a5
ffffffffc0204bd0:	e8051be3          	bnez	a0,ffffffffc0204a66 <vprintfmt+0x1a0>
ffffffffc0204bd4:	b335                	j	ffffffffc0204900 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204bd6:	000aa403          	lw	s0,0(s5)
ffffffffc0204bda:	bbf1                	j	ffffffffc02049b6 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204bdc:	000ae603          	lwu	a2,0(s5)
ffffffffc0204be0:	46a9                	li	a3,10
ffffffffc0204be2:	8aae                	mv	s5,a1
ffffffffc0204be4:	bd89                	j	ffffffffc0204a36 <vprintfmt+0x170>
ffffffffc0204be6:	000ae603          	lwu	a2,0(s5)
ffffffffc0204bea:	46c1                	li	a3,16
ffffffffc0204bec:	8aae                	mv	s5,a1
ffffffffc0204bee:	b5a1                	j	ffffffffc0204a36 <vprintfmt+0x170>
ffffffffc0204bf0:	000ae603          	lwu	a2,0(s5)
ffffffffc0204bf4:	46a1                	li	a3,8
ffffffffc0204bf6:	8aae                	mv	s5,a1
ffffffffc0204bf8:	bd3d                	j	ffffffffc0204a36 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204bfa:	9902                	jalr	s2
ffffffffc0204bfc:	b559                	j	ffffffffc0204a82 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204bfe:	85a6                	mv	a1,s1
ffffffffc0204c00:	02d00513          	li	a0,45
ffffffffc0204c04:	e03e                	sd	a5,0(sp)
ffffffffc0204c06:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204c08:	8ace                	mv	s5,s3
ffffffffc0204c0a:	40800633          	neg	a2,s0
ffffffffc0204c0e:	46a9                	li	a3,10
ffffffffc0204c10:	6782                	ld	a5,0(sp)
ffffffffc0204c12:	b515                	j	ffffffffc0204a36 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0204c14:	01b05663          	blez	s11,ffffffffc0204c20 <vprintfmt+0x35a>
ffffffffc0204c18:	02d00693          	li	a3,45
ffffffffc0204c1c:	f6d798e3          	bne	a5,a3,ffffffffc0204b8c <vprintfmt+0x2c6>
ffffffffc0204c20:	00002417          	auipc	s0,0x2
ffffffffc0204c24:	1b140413          	addi	s0,s0,433 # ffffffffc0206dd1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204c28:	02800513          	li	a0,40
ffffffffc0204c2c:	02800793          	li	a5,40
ffffffffc0204c30:	bd1d                	j	ffffffffc0204a66 <vprintfmt+0x1a0>

ffffffffc0204c32 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204c32:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204c34:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204c38:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204c3a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204c3c:	ec06                	sd	ra,24(sp)
ffffffffc0204c3e:	f83a                	sd	a4,48(sp)
ffffffffc0204c40:	fc3e                	sd	a5,56(sp)
ffffffffc0204c42:	e0c2                	sd	a6,64(sp)
ffffffffc0204c44:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0204c46:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204c48:	c7fff0ef          	jal	ra,ffffffffc02048c6 <vprintfmt>
}
ffffffffc0204c4c:	60e2                	ld	ra,24(sp)
ffffffffc0204c4e:	6161                	addi	sp,sp,80
ffffffffc0204c50:	8082                	ret

ffffffffc0204c52 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204c52:	00054783          	lbu	a5,0(a0)
ffffffffc0204c56:	cb91                	beqz	a5,ffffffffc0204c6a <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204c58:	4781                	li	a5,0
        cnt ++;
ffffffffc0204c5a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204c5c:	00f50733          	add	a4,a0,a5
ffffffffc0204c60:	00074703          	lbu	a4,0(a4)
ffffffffc0204c64:	fb7d                	bnez	a4,ffffffffc0204c5a <strlen+0x8>
    }
    return cnt;
}
ffffffffc0204c66:	853e                	mv	a0,a5
ffffffffc0204c68:	8082                	ret
    size_t cnt = 0;
ffffffffc0204c6a:	4781                	li	a5,0
}
ffffffffc0204c6c:	853e                	mv	a0,a5
ffffffffc0204c6e:	8082                	ret

ffffffffc0204c70 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204c70:	c185                	beqz	a1,ffffffffc0204c90 <strnlen+0x20>
ffffffffc0204c72:	00054783          	lbu	a5,0(a0)
ffffffffc0204c76:	cf89                	beqz	a5,ffffffffc0204c90 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204c78:	4781                	li	a5,0
ffffffffc0204c7a:	a021                	j	ffffffffc0204c82 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204c7c:	00074703          	lbu	a4,0(a4)
ffffffffc0204c80:	c711                	beqz	a4,ffffffffc0204c8c <strnlen+0x1c>
        cnt ++;
ffffffffc0204c82:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204c84:	00f50733          	add	a4,a0,a5
ffffffffc0204c88:	fef59ae3          	bne	a1,a5,ffffffffc0204c7c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0204c8c:	853e                	mv	a0,a5
ffffffffc0204c8e:	8082                	ret
    size_t cnt = 0;
ffffffffc0204c90:	4781                	li	a5,0
}
ffffffffc0204c92:	853e                	mv	a0,a5
ffffffffc0204c94:	8082                	ret

ffffffffc0204c96 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0204c96:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0204c98:	0585                	addi	a1,a1,1
ffffffffc0204c9a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204c9e:	0785                	addi	a5,a5,1
ffffffffc0204ca0:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0204ca4:	fb75                	bnez	a4,ffffffffc0204c98 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0204ca6:	8082                	ret

ffffffffc0204ca8 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204ca8:	00054783          	lbu	a5,0(a0)
ffffffffc0204cac:	0005c703          	lbu	a4,0(a1)
ffffffffc0204cb0:	cb91                	beqz	a5,ffffffffc0204cc4 <strcmp+0x1c>
ffffffffc0204cb2:	00e79c63          	bne	a5,a4,ffffffffc0204cca <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0204cb6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204cb8:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0204cbc:	0585                	addi	a1,a1,1
ffffffffc0204cbe:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0204cc2:	fbe5                	bnez	a5,ffffffffc0204cb2 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204cc4:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0204cc6:	9d19                	subw	a0,a0,a4
ffffffffc0204cc8:	8082                	ret
ffffffffc0204cca:	0007851b          	sext.w	a0,a5
ffffffffc0204cce:	9d19                	subw	a0,a0,a4
ffffffffc0204cd0:	8082                	ret

ffffffffc0204cd2 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204cd2:	00054783          	lbu	a5,0(a0)
ffffffffc0204cd6:	cb91                	beqz	a5,ffffffffc0204cea <strchr+0x18>
        if (*s == c) {
ffffffffc0204cd8:	00b79563          	bne	a5,a1,ffffffffc0204ce2 <strchr+0x10>
ffffffffc0204cdc:	a809                	j	ffffffffc0204cee <strchr+0x1c>
ffffffffc0204cde:	00b78763          	beq	a5,a1,ffffffffc0204cec <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204ce2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204ce4:	00054783          	lbu	a5,0(a0)
ffffffffc0204ce8:	fbfd                	bnez	a5,ffffffffc0204cde <strchr+0xc>
    }
    return NULL;
ffffffffc0204cea:	4501                	li	a0,0
}
ffffffffc0204cec:	8082                	ret
ffffffffc0204cee:	8082                	ret

ffffffffc0204cf0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204cf0:	ca01                	beqz	a2,ffffffffc0204d00 <memset+0x10>
ffffffffc0204cf2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204cf4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0204cf6:	0785                	addi	a5,a5,1
ffffffffc0204cf8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204cfc:	fec79de3          	bne	a5,a2,ffffffffc0204cf6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204d00:	8082                	ret

ffffffffc0204d02 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204d02:	ca19                	beqz	a2,ffffffffc0204d18 <memcpy+0x16>
ffffffffc0204d04:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0204d06:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204d08:	0585                	addi	a1,a1,1
ffffffffc0204d0a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204d0e:	0785                	addi	a5,a5,1
ffffffffc0204d10:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204d14:	fec59ae3          	bne	a1,a2,ffffffffc0204d08 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204d18:	8082                	ret

ffffffffc0204d1a <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0204d1a:	c21d                	beqz	a2,ffffffffc0204d40 <memcmp+0x26>
        if (*s1 != *s2) {
ffffffffc0204d1c:	00054783          	lbu	a5,0(a0)
ffffffffc0204d20:	0005c703          	lbu	a4,0(a1)
ffffffffc0204d24:	962a                	add	a2,a2,a0
ffffffffc0204d26:	00f70963          	beq	a4,a5,ffffffffc0204d38 <memcmp+0x1e>
ffffffffc0204d2a:	a829                	j	ffffffffc0204d44 <memcmp+0x2a>
ffffffffc0204d2c:	00054783          	lbu	a5,0(a0)
ffffffffc0204d30:	0005c703          	lbu	a4,0(a1)
ffffffffc0204d34:	00e79863          	bne	a5,a4,ffffffffc0204d44 <memcmp+0x2a>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0204d38:	0505                	addi	a0,a0,1
ffffffffc0204d3a:	0585                	addi	a1,a1,1
    while (n -- > 0) {
ffffffffc0204d3c:	fea618e3          	bne	a2,a0,ffffffffc0204d2c <memcmp+0x12>
    }
    return 0;
ffffffffc0204d40:	4501                	li	a0,0
}
ffffffffc0204d42:	8082                	ret
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0204d44:	40e7853b          	subw	a0,a5,a4
ffffffffc0204d48:	8082                	ret
