
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	14250513          	addi	a0,a0,322 # ffffffffc02a1178 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	6c260613          	addi	a2,a2,1730 # ffffffffc02ac700 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	32a060ef          	jal	ra,ffffffffc0206378 <memset>
    cons_init();                // init the console
ffffffffc0200052:	536000ef          	jal	ra,ffffffffc0200588 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	35258593          	addi	a1,a1,850 # ffffffffc02063a8 <etext+0x6>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	36a50513          	addi	a0,a0,874 # ffffffffc02063c8 <etext+0x26>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ac000ef          	jal	ra,ffffffffc0200216 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5a2020ef          	jal	ra,ffffffffc0202610 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5ca000ef          	jal	ra,ffffffffc020063c <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5c8000ef          	jal	ra,ffffffffc020063e <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	33a040ef          	jal	ra,ffffffffc02043b4 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	287050ef          	jal	ra,ffffffffc0205b04 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	57a000ef          	jal	ra,ffffffffc02005fc <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2d2030ef          	jal	ra,ffffffffc0203358 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a8000ef          	jal	ra,ffffffffc0200532 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5a2000ef          	jal	ra,ffffffffc0200630 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	3c3050ef          	jal	ra,ffffffffc0205c54 <cpu_idle>

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
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	32250513          	addi	a0,a0,802 # ffffffffc02063d0 <etext+0x2e>
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
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	0b4b8b93          	addi	s7,s7,180 # ffffffffc02a1178 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	136000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	124000ef          	jal	ra,ffffffffc0200206 <getchar>
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
ffffffffc02000f6:	110000ef          	jal	ra,ffffffffc0200206 <getchar>
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
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	05250513          	addi	a0,a0,82 # ffffffffc02a1178 <edata>
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
ffffffffc020015c:	42e000ef          	jal	ra,ffffffffc020058a <cons_putc>
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
ffffffffc0200182:	5cd050ef          	jal	ra,ffffffffc0205f4e <vprintfmt>
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
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
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
ffffffffc02001b6:	599050ef          	jal	ra,ffffffffc0205f4e <vprintfmt>
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
ffffffffc02001c2:	3c80006f          	j	ffffffffc020058a <cons_putc>

ffffffffc02001c6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c6:	1101                	addi	sp,sp,-32
ffffffffc02001c8:	e822                	sd	s0,16(sp)
ffffffffc02001ca:	ec06                	sd	ra,24(sp)
ffffffffc02001cc:	e426                	sd	s1,8(sp)
ffffffffc02001ce:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00054503          	lbu	a0,0(a0)
ffffffffc02001d4:	c51d                	beqz	a0,ffffffffc0200202 <cputs+0x3c>
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	4485                	li	s1,1
ffffffffc02001da:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001dc:	3ae000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc02001e0:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e4:	0405                	addi	s0,s0,1
ffffffffc02001e6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ea:	f96d                	bnez	a0,ffffffffc02001dc <cputs+0x16>
ffffffffc02001ec:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f0:	4529                	li	a0,10
ffffffffc02001f2:	398000ef          	jal	ra,ffffffffc020058a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f6:	8522                	mv	a0,s0
ffffffffc02001f8:	60e2                	ld	ra,24(sp)
ffffffffc02001fa:	6442                	ld	s0,16(sp)
ffffffffc02001fc:	64a2                	ld	s1,8(sp)
ffffffffc02001fe:	6105                	addi	sp,sp,32
ffffffffc0200200:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200202:	4405                	li	s0,1
ffffffffc0200204:	b7f5                	j	ffffffffc02001f0 <cputs+0x2a>

ffffffffc0200206 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200206:	1141                	addi	sp,sp,-16
ffffffffc0200208:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020a:	3b6000ef          	jal	ra,ffffffffc02005c0 <cons_getc>
ffffffffc020020e:	dd75                	beqz	a0,ffffffffc020020a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	0141                	addi	sp,sp,16
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200216:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200218:	00006517          	auipc	a0,0x6
ffffffffc020021c:	1f050513          	addi	a0,a0,496 # ffffffffc0206408 <etext+0x66>
void print_kerninfo(void) {
ffffffffc0200220:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	f6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200226:	00000597          	auipc	a1,0x0
ffffffffc020022a:	e1058593          	addi	a1,a1,-496 # ffffffffc0200036 <kern_init>
ffffffffc020022e:	00006517          	auipc	a0,0x6
ffffffffc0200232:	1fa50513          	addi	a0,a0,506 # ffffffffc0206428 <etext+0x86>
ffffffffc0200236:	f59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	16858593          	addi	a1,a1,360 # ffffffffc02063a2 <etext>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	20650513          	addi	a0,a0,518 # ffffffffc0206448 <etext+0xa6>
ffffffffc020024a:	f45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024e:	000a1597          	auipc	a1,0xa1
ffffffffc0200252:	f2a58593          	addi	a1,a1,-214 # ffffffffc02a1178 <edata>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	21250513          	addi	a0,a0,530 # ffffffffc0206468 <etext+0xc6>
ffffffffc020025e:	f31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200262:	000ac597          	auipc	a1,0xac
ffffffffc0200266:	49e58593          	addi	a1,a1,1182 # ffffffffc02ac700 <end>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	21e50513          	addi	a0,a0,542 # ffffffffc0206488 <etext+0xe6>
ffffffffc0200272:	f1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200276:	000ad597          	auipc	a1,0xad
ffffffffc020027a:	88958593          	addi	a1,a1,-1911 # ffffffffc02acaff <end+0x3ff>
ffffffffc020027e:	00000797          	auipc	a5,0x0
ffffffffc0200282:	db878793          	addi	a5,a5,-584 # ffffffffc0200036 <kern_init>
ffffffffc0200286:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200294:	95be                	add	a1,a1,a5
ffffffffc0200296:	85a9                	srai	a1,a1,0xa
ffffffffc0200298:	00006517          	auipc	a0,0x6
ffffffffc020029c:	21050513          	addi	a0,a0,528 # ffffffffc02064a8 <etext+0x106>
}
ffffffffc02002a0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	eedff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02002a6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a8:	00006617          	auipc	a2,0x6
ffffffffc02002ac:	13060613          	addi	a2,a2,304 # ffffffffc02063d8 <etext+0x36>
ffffffffc02002b0:	04d00593          	li	a1,77
ffffffffc02002b4:	00006517          	auipc	a0,0x6
ffffffffc02002b8:	13c50513          	addi	a0,a0,316 # ffffffffc02063f0 <etext+0x4e>
void print_stackframe(void) {
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002be:	1c6000ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02002c2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c4:	00006617          	auipc	a2,0x6
ffffffffc02002c8:	2f460613          	addi	a2,a2,756 # ffffffffc02065b8 <commands+0xe0>
ffffffffc02002cc:	00006597          	auipc	a1,0x6
ffffffffc02002d0:	30c58593          	addi	a1,a1,780 # ffffffffc02065d8 <commands+0x100>
ffffffffc02002d4:	00006517          	auipc	a0,0x6
ffffffffc02002d8:	30c50513          	addi	a0,a0,780 # ffffffffc02065e0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002de:	eb1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002e2:	00006617          	auipc	a2,0x6
ffffffffc02002e6:	30e60613          	addi	a2,a2,782 # ffffffffc02065f0 <commands+0x118>
ffffffffc02002ea:	00006597          	auipc	a1,0x6
ffffffffc02002ee:	32e58593          	addi	a1,a1,814 # ffffffffc0206618 <commands+0x140>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	2ee50513          	addi	a0,a0,750 # ffffffffc02065e0 <commands+0x108>
ffffffffc02002fa:	e95ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fe:	00006617          	auipc	a2,0x6
ffffffffc0200302:	32a60613          	addi	a2,a2,810 # ffffffffc0206628 <commands+0x150>
ffffffffc0200306:	00006597          	auipc	a1,0x6
ffffffffc020030a:	34258593          	addi	a1,a1,834 # ffffffffc0206648 <commands+0x170>
ffffffffc020030e:	00006517          	auipc	a0,0x6
ffffffffc0200312:	2d250513          	addi	a0,a0,722 # ffffffffc02065e0 <commands+0x108>
ffffffffc0200316:	e79ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200326:	ef1ff0ef          	jal	ra,ffffffffc0200216 <print_kerninfo>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200332:	1141                	addi	sp,sp,-16
ffffffffc0200334:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200336:	f71ff0ef          	jal	ra,ffffffffc02002a6 <print_stackframe>
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200342:	7115                	addi	sp,sp,-224
ffffffffc0200344:	e962                	sd	s8,144(sp)
ffffffffc0200346:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200348:	00006517          	auipc	a0,0x6
ffffffffc020034c:	1d850513          	addi	a0,a0,472 # ffffffffc0206520 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200350:	ed86                	sd	ra,216(sp)
ffffffffc0200352:	e9a2                	sd	s0,208(sp)
ffffffffc0200354:	e5a6                	sd	s1,200(sp)
ffffffffc0200356:	e1ca                	sd	s2,192(sp)
ffffffffc0200358:	fd4e                	sd	s3,184(sp)
ffffffffc020035a:	f952                	sd	s4,176(sp)
ffffffffc020035c:	f556                	sd	s5,168(sp)
ffffffffc020035e:	f15a                	sd	s6,160(sp)
ffffffffc0200360:	ed5e                	sd	s7,152(sp)
ffffffffc0200362:	e566                	sd	s9,136(sp)
ffffffffc0200364:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200366:	e29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	1de50513          	addi	a0,a0,478 # ffffffffc0206548 <commands+0x70>
ffffffffc0200372:	e1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200376:	000c0563          	beqz	s8,ffffffffc0200380 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037a:	8562                	mv	a0,s8
ffffffffc020037c:	4aa000ef          	jal	ra,ffffffffc0200826 <print_trapframe>
ffffffffc0200380:	00006c97          	auipc	s9,0x6
ffffffffc0200384:	158c8c93          	addi	s9,s9,344 # ffffffffc02064d8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200388:	00006997          	auipc	s3,0x6
ffffffffc020038c:	1e898993          	addi	s3,s3,488 # ffffffffc0206570 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	1e890913          	addi	s2,s2,488 # ffffffffc0206578 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200398:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	00006b17          	auipc	s6,0x6
ffffffffc020039e:	1e6b0b13          	addi	s6,s6,486 # ffffffffc0206580 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a2:	00006a97          	auipc	s5,0x6
ffffffffc02003a6:	236a8a93          	addi	s5,s5,566 # ffffffffc02065d8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003aa:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003ac:	854e                	mv	a0,s3
ffffffffc02003ae:	ce9ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003b2:	842a                	mv	s0,a0
ffffffffc02003b4:	dd65                	beqz	a0,ffffffffc02003ac <kmonitor+0x6a>
ffffffffc02003b6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003ba:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	c999                	beqz	a1,ffffffffc02003d2 <kmonitor+0x90>
ffffffffc02003be:	854a                	mv	a0,s2
ffffffffc02003c0:	79b050ef          	jal	ra,ffffffffc020635a <strchr>
ffffffffc02003c4:	c925                	beqz	a0,ffffffffc0200434 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ca:	00040023          	sb	zero,0(s0)
ffffffffc02003ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d0:	f5fd                	bnez	a1,ffffffffc02003be <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d2:	dce9                	beqz	s1,ffffffffc02003ac <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d4:	6582                	ld	a1,0(sp)
ffffffffc02003d6:	00006d17          	auipc	s10,0x6
ffffffffc02003da:	102d0d13          	addi	s10,s10,258 # ffffffffc02064d8 <commands>
    if (argc == 0) {
ffffffffc02003de:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e2:	0d61                	addi	s10,s10,24
ffffffffc02003e4:	74d050ef          	jal	ra,ffffffffc0206330 <strcmp>
ffffffffc02003e8:	c919                	beqz	a0,ffffffffc02003fe <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ea:	2405                	addiw	s0,s0,1
ffffffffc02003ec:	09740463          	beq	s0,s7,ffffffffc0200474 <kmonitor+0x132>
ffffffffc02003f0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	0d61                	addi	s10,s10,24
ffffffffc02003f8:	739050ef          	jal	ra,ffffffffc0206330 <strcmp>
ffffffffc02003fc:	f57d                	bnez	a0,ffffffffc02003ea <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fe:	00141793          	slli	a5,s0,0x1
ffffffffc0200402:	97a2                	add	a5,a5,s0
ffffffffc0200404:	078e                	slli	a5,a5,0x3
ffffffffc0200406:	97e6                	add	a5,a5,s9
ffffffffc0200408:	6b9c                	ld	a5,16(a5)
ffffffffc020040a:	8662                	mv	a2,s8
ffffffffc020040c:	002c                	addi	a1,sp,8
ffffffffc020040e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200412:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200414:	f8055ce3          	bgez	a0,ffffffffc02003ac <kmonitor+0x6a>
}
ffffffffc0200418:	60ee                	ld	ra,216(sp)
ffffffffc020041a:	644e                	ld	s0,208(sp)
ffffffffc020041c:	64ae                	ld	s1,200(sp)
ffffffffc020041e:	690e                	ld	s2,192(sp)
ffffffffc0200420:	79ea                	ld	s3,184(sp)
ffffffffc0200422:	7a4a                	ld	s4,176(sp)
ffffffffc0200424:	7aaa                	ld	s5,168(sp)
ffffffffc0200426:	7b0a                	ld	s6,160(sp)
ffffffffc0200428:	6bea                	ld	s7,152(sp)
ffffffffc020042a:	6c4a                	ld	s8,144(sp)
ffffffffc020042c:	6caa                	ld	s9,136(sp)
ffffffffc020042e:	6d0a                	ld	s10,128(sp)
ffffffffc0200430:	612d                	addi	sp,sp,224
ffffffffc0200432:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200434:	00044783          	lbu	a5,0(s0)
ffffffffc0200438:	dfc9                	beqz	a5,ffffffffc02003d2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043a:	03448863          	beq	s1,s4,ffffffffc020046a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043e:	00349793          	slli	a5,s1,0x3
ffffffffc0200442:	0118                	addi	a4,sp,128
ffffffffc0200444:	97ba                	add	a5,a5,a4
ffffffffc0200446:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200450:	e591                	bnez	a1,ffffffffc020045c <kmonitor+0x11a>
ffffffffc0200452:	b749                	j	ffffffffc02003d4 <kmonitor+0x92>
            buf ++;
ffffffffc0200454:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200456:	00044583          	lbu	a1,0(s0)
ffffffffc020045a:	ddad                	beqz	a1,ffffffffc02003d4 <kmonitor+0x92>
ffffffffc020045c:	854a                	mv	a0,s2
ffffffffc020045e:	6fd050ef          	jal	ra,ffffffffc020635a <strchr>
ffffffffc0200462:	d96d                	beqz	a0,ffffffffc0200454 <kmonitor+0x112>
ffffffffc0200464:	00044583          	lbu	a1,0(s0)
ffffffffc0200468:	bf91                	j	ffffffffc02003bc <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046a:	45c1                	li	a1,16
ffffffffc020046c:	855a                	mv	a0,s6
ffffffffc020046e:	d21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200472:	b7f1                	j	ffffffffc020043e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00006517          	auipc	a0,0x6
ffffffffc020047a:	12a50513          	addi	a0,a0,298 # ffffffffc02065a0 <commands+0xc8>
ffffffffc020047e:	d11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc0200482:	b72d                	j	ffffffffc02003ac <kmonitor+0x6a>

ffffffffc0200484 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200484:	000ac317          	auipc	t1,0xac
ffffffffc0200488:	0f430313          	addi	t1,t1,244 # ffffffffc02ac578 <is_panic>
ffffffffc020048c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200490:	715d                	addi	sp,sp,-80
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e822                	sd	s0,16(sp)
ffffffffc0200496:	f436                	sd	a3,40(sp)
ffffffffc0200498:	f83a                	sd	a4,48(sp)
ffffffffc020049a:	fc3e                	sd	a5,56(sp)
ffffffffc020049c:	e0c2                	sd	a6,64(sp)
ffffffffc020049e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a0:	02031c63          	bnez	t1,ffffffffc02004d8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a4:	4785                	li	a5,1
ffffffffc02004a6:	8432                	mv	s0,a2
ffffffffc02004a8:	000ac717          	auipc	a4,0xac
ffffffffc02004ac:	0cf73823          	sd	a5,208(a4) # ffffffffc02ac578 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	85aa                	mv	a1,a0
ffffffffc02004b6:	00006517          	auipc	a0,0x6
ffffffffc02004ba:	1a250513          	addi	a0,a0,418 # ffffffffc0206658 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004be:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c0:	ccfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c4:	65a2                	ld	a1,8(sp)
ffffffffc02004c6:	8522                	mv	a0,s0
ffffffffc02004c8:	ca7ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004cc:	00007517          	auipc	a0,0x7
ffffffffc02004d0:	13450513          	addi	a0,a0,308 # ffffffffc0207600 <default_pmm_manager+0x520>
ffffffffc02004d4:	cbbff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	48a1                	li	a7,8
ffffffffc02004e0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e4:	152000ef          	jal	ra,ffffffffc0200636 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e8:	4501                	li	a0,0
ffffffffc02004ea:	e59ff0ef          	jal	ra,ffffffffc0200342 <kmonitor>
ffffffffc02004ee:	bfed                	j	ffffffffc02004e8 <__panic+0x64>

ffffffffc02004f0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f0:	715d                	addi	sp,sp,-80
ffffffffc02004f2:	e822                	sd	s0,16(sp)
ffffffffc02004f4:	fc3e                	sd	a5,56(sp)
ffffffffc02004f6:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f8:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fa:	862e                	mv	a2,a1
ffffffffc02004fc:	85aa                	mv	a1,a0
ffffffffc02004fe:	00006517          	auipc	a0,0x6
ffffffffc0200502:	17a50513          	addi	a0,a0,378 # ffffffffc0206678 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200506:	ec06                	sd	ra,24(sp)
ffffffffc0200508:	f436                	sd	a3,40(sp)
ffffffffc020050a:	f83a                	sd	a4,48(sp)
ffffffffc020050c:	e0c2                	sd	a6,64(sp)
ffffffffc020050e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200510:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200512:	c7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200516:	65a2                	ld	a1,8(sp)
ffffffffc0200518:	8522                	mv	a0,s0
ffffffffc020051a:	c55ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051e:	00007517          	auipc	a0,0x7
ffffffffc0200522:	0e250513          	addi	a0,a0,226 # ffffffffc0207600 <default_pmm_manager+0x520>
ffffffffc0200526:	c69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc020052a:	60e2                	ld	ra,24(sp)
ffffffffc020052c:	6442                	ld	s0,16(sp)
ffffffffc020052e:	6161                	addi	sp,sp,80
ffffffffc0200530:	8082                	ret

ffffffffc0200532 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200532:	67e1                	lui	a5,0x18
ffffffffc0200534:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc10>
ffffffffc0200538:	000ac717          	auipc	a4,0xac
ffffffffc020053c:	04f73423          	sd	a5,72(a4) # ffffffffc02ac580 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200540:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200544:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	953e                	add	a0,a0,a5
ffffffffc0200548:	4601                	li	a2,0
ffffffffc020054a:	4881                	li	a7,0
ffffffffc020054c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200550:	02000793          	li	a5,32
ffffffffc0200554:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200558:	00006517          	auipc	a0,0x6
ffffffffc020055c:	14050513          	addi	a0,a0,320 # ffffffffc0206698 <commands+0x1c0>
    ticks = 0;
ffffffffc0200560:	000ac797          	auipc	a5,0xac
ffffffffc0200564:	0607b823          	sd	zero,112(a5) # ffffffffc02ac5d0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200568:	c27ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020056c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020056c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200570:	000ac797          	auipc	a5,0xac
ffffffffc0200574:	01078793          	addi	a5,a5,16 # ffffffffc02ac580 <timebase>
ffffffffc0200578:	639c                	ld	a5,0(a5)
ffffffffc020057a:	4581                	li	a1,0
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4881                	li	a7,0
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200588:	8082                	ret

ffffffffc020058a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058a:	100027f3          	csrr	a5,sstatus
ffffffffc020058e:	8b89                	andi	a5,a5,2
ffffffffc0200590:	0ff57513          	andi	a0,a0,255
ffffffffc0200594:	e799                	bnez	a5,ffffffffc02005a2 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200596:	4581                	li	a1,0
ffffffffc0200598:	4601                	li	a2,0
ffffffffc020059a:	4885                	li	a7,1
ffffffffc020059c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005a0:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a2:	1101                	addi	sp,sp,-32
ffffffffc02005a4:	ec06                	sd	ra,24(sp)
ffffffffc02005a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a8:	08e000ef          	jal	ra,ffffffffc0200636 <intr_disable>
ffffffffc02005ac:	6522                	ld	a0,8(sp)
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	4885                	li	a7,1
ffffffffc02005b4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b8:	60e2                	ld	ra,24(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005bc:	0740006f          	j	ffffffffc0200630 <intr_enable>

ffffffffc02005c0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005c0:	100027f3          	csrr	a5,sstatus
ffffffffc02005c4:	8b89                	andi	a5,a5,2
ffffffffc02005c6:	eb89                	bnez	a5,ffffffffc02005d8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d6:	8082                	ret
int cons_getc(void) {
ffffffffc02005d8:	1101                	addi	sp,sp,-32
ffffffffc02005da:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005dc:	05a000ef          	jal	ra,ffffffffc0200636 <intr_disable>
ffffffffc02005e0:	4501                	li	a0,0
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	4601                	li	a2,0
ffffffffc02005e6:	4889                	li	a7,2
ffffffffc02005e8:	00000073          	ecall
ffffffffc02005ec:	2501                	sext.w	a0,a0
ffffffffc02005ee:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f0:	040000ef          	jal	ra,ffffffffc0200630 <intr_enable>
}
ffffffffc02005f4:	60e2                	ld	ra,24(sp)
ffffffffc02005f6:	6522                	ld	a0,8(sp)
ffffffffc02005f8:	6105                	addi	sp,sp,32
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005fe:	00253513          	sltiu	a0,a0,2
ffffffffc0200602:	8082                	ret

ffffffffc0200604 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200604:	03800513          	li	a0,56
ffffffffc0200608:	8082                	ret

ffffffffc020060a <ide_write_secs>:
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;
}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc020060a:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020060c:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200610:	000a1517          	auipc	a0,0xa1
ffffffffc0200614:	f6850513          	addi	a0,a0,-152 # ffffffffc02a1578 <ide>
                   size_t nsecs) {
ffffffffc0200618:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020061a:	00969613          	slli	a2,a3,0x9
ffffffffc020061e:	85ba                	mv	a1,a4
ffffffffc0200620:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200622:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200624:	567050ef          	jal	ra,ffffffffc020638a <memcpy>
    return 0;
}
ffffffffc0200628:	60a2                	ld	ra,8(sp)
ffffffffc020062a:	4501                	li	a0,0
ffffffffc020062c:	0141                	addi	sp,sp,16
ffffffffc020062e:	8082                	ret

ffffffffc0200630 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200630:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200634:	8082                	ret

ffffffffc0200636 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200636:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020063a:	8082                	ret

ffffffffc020063c <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020063c:	8082                	ret

ffffffffc020063e <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020063e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200642:	00000797          	auipc	a5,0x0
ffffffffc0200646:	67a78793          	addi	a5,a5,1658 # ffffffffc0200cbc <__alltraps>
ffffffffc020064a:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020064e:	000407b7          	lui	a5,0x40
ffffffffc0200652:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200658:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020065a:	1141                	addi	sp,sp,-16
ffffffffc020065c:	e022                	sd	s0,0(sp)
ffffffffc020065e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200660:	00006517          	auipc	a0,0x6
ffffffffc0200664:	38050513          	addi	a0,a0,896 # ffffffffc02069e0 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200668:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020066a:	b25ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020066e:	640c                	ld	a1,8(s0)
ffffffffc0200670:	00006517          	auipc	a0,0x6
ffffffffc0200674:	38850513          	addi	a0,a0,904 # ffffffffc02069f8 <commands+0x520>
ffffffffc0200678:	b17ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020067c:	680c                	ld	a1,16(s0)
ffffffffc020067e:	00006517          	auipc	a0,0x6
ffffffffc0200682:	39250513          	addi	a0,a0,914 # ffffffffc0206a10 <commands+0x538>
ffffffffc0200686:	b09ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc020068a:	6c0c                	ld	a1,24(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	39c50513          	addi	a0,a0,924 # ffffffffc0206a28 <commands+0x550>
ffffffffc0200694:	afbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200698:	700c                	ld	a1,32(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	3a650513          	addi	a0,a0,934 # ffffffffc0206a40 <commands+0x568>
ffffffffc02006a2:	aedff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006a6:	740c                	ld	a1,40(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	3b050513          	addi	a0,a0,944 # ffffffffc0206a58 <commands+0x580>
ffffffffc02006b0:	adfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006b4:	780c                	ld	a1,48(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	3ba50513          	addi	a0,a0,954 # ffffffffc0206a70 <commands+0x598>
ffffffffc02006be:	ad1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006c2:	7c0c                	ld	a1,56(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	3c450513          	addi	a0,a0,964 # ffffffffc0206a88 <commands+0x5b0>
ffffffffc02006cc:	ac3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006d0:	602c                	ld	a1,64(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	3ce50513          	addi	a0,a0,974 # ffffffffc0206aa0 <commands+0x5c8>
ffffffffc02006da:	ab5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006de:	642c                	ld	a1,72(s0)
ffffffffc02006e0:	00006517          	auipc	a0,0x6
ffffffffc02006e4:	3d850513          	addi	a0,a0,984 # ffffffffc0206ab8 <commands+0x5e0>
ffffffffc02006e8:	aa7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02006ec:	682c                	ld	a1,80(s0)
ffffffffc02006ee:	00006517          	auipc	a0,0x6
ffffffffc02006f2:	3e250513          	addi	a0,a0,994 # ffffffffc0206ad0 <commands+0x5f8>
ffffffffc02006f6:	a99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02006fa:	6c2c                	ld	a1,88(s0)
ffffffffc02006fc:	00006517          	auipc	a0,0x6
ffffffffc0200700:	3ec50513          	addi	a0,a0,1004 # ffffffffc0206ae8 <commands+0x610>
ffffffffc0200704:	a8bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200708:	702c                	ld	a1,96(s0)
ffffffffc020070a:	00006517          	auipc	a0,0x6
ffffffffc020070e:	3f650513          	addi	a0,a0,1014 # ffffffffc0206b00 <commands+0x628>
ffffffffc0200712:	a7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200716:	742c                	ld	a1,104(s0)
ffffffffc0200718:	00006517          	auipc	a0,0x6
ffffffffc020071c:	40050513          	addi	a0,a0,1024 # ffffffffc0206b18 <commands+0x640>
ffffffffc0200720:	a6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200724:	782c                	ld	a1,112(s0)
ffffffffc0200726:	00006517          	auipc	a0,0x6
ffffffffc020072a:	40a50513          	addi	a0,a0,1034 # ffffffffc0206b30 <commands+0x658>
ffffffffc020072e:	a61ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200732:	7c2c                	ld	a1,120(s0)
ffffffffc0200734:	00006517          	auipc	a0,0x6
ffffffffc0200738:	41450513          	addi	a0,a0,1044 # ffffffffc0206b48 <commands+0x670>
ffffffffc020073c:	a53ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200740:	604c                	ld	a1,128(s0)
ffffffffc0200742:	00006517          	auipc	a0,0x6
ffffffffc0200746:	41e50513          	addi	a0,a0,1054 # ffffffffc0206b60 <commands+0x688>
ffffffffc020074a:	a45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020074e:	644c                	ld	a1,136(s0)
ffffffffc0200750:	00006517          	auipc	a0,0x6
ffffffffc0200754:	42850513          	addi	a0,a0,1064 # ffffffffc0206b78 <commands+0x6a0>
ffffffffc0200758:	a37ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020075c:	684c                	ld	a1,144(s0)
ffffffffc020075e:	00006517          	auipc	a0,0x6
ffffffffc0200762:	43250513          	addi	a0,a0,1074 # ffffffffc0206b90 <commands+0x6b8>
ffffffffc0200766:	a29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020076a:	6c4c                	ld	a1,152(s0)
ffffffffc020076c:	00006517          	auipc	a0,0x6
ffffffffc0200770:	43c50513          	addi	a0,a0,1084 # ffffffffc0206ba8 <commands+0x6d0>
ffffffffc0200774:	a1bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200778:	704c                	ld	a1,160(s0)
ffffffffc020077a:	00006517          	auipc	a0,0x6
ffffffffc020077e:	44650513          	addi	a0,a0,1094 # ffffffffc0206bc0 <commands+0x6e8>
ffffffffc0200782:	a0dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200786:	744c                	ld	a1,168(s0)
ffffffffc0200788:	00006517          	auipc	a0,0x6
ffffffffc020078c:	45050513          	addi	a0,a0,1104 # ffffffffc0206bd8 <commands+0x700>
ffffffffc0200790:	9ffff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200794:	784c                	ld	a1,176(s0)
ffffffffc0200796:	00006517          	auipc	a0,0x6
ffffffffc020079a:	45a50513          	addi	a0,a0,1114 # ffffffffc0206bf0 <commands+0x718>
ffffffffc020079e:	9f1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007a2:	7c4c                	ld	a1,184(s0)
ffffffffc02007a4:	00006517          	auipc	a0,0x6
ffffffffc02007a8:	46450513          	addi	a0,a0,1124 # ffffffffc0206c08 <commands+0x730>
ffffffffc02007ac:	9e3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007b0:	606c                	ld	a1,192(s0)
ffffffffc02007b2:	00006517          	auipc	a0,0x6
ffffffffc02007b6:	46e50513          	addi	a0,a0,1134 # ffffffffc0206c20 <commands+0x748>
ffffffffc02007ba:	9d5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007be:	646c                	ld	a1,200(s0)
ffffffffc02007c0:	00006517          	auipc	a0,0x6
ffffffffc02007c4:	47850513          	addi	a0,a0,1144 # ffffffffc0206c38 <commands+0x760>
ffffffffc02007c8:	9c7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007cc:	686c                	ld	a1,208(s0)
ffffffffc02007ce:	00006517          	auipc	a0,0x6
ffffffffc02007d2:	48250513          	addi	a0,a0,1154 # ffffffffc0206c50 <commands+0x778>
ffffffffc02007d6:	9b9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007da:	6c6c                	ld	a1,216(s0)
ffffffffc02007dc:	00006517          	auipc	a0,0x6
ffffffffc02007e0:	48c50513          	addi	a0,a0,1164 # ffffffffc0206c68 <commands+0x790>
ffffffffc02007e4:	9abff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc02007e8:	706c                	ld	a1,224(s0)
ffffffffc02007ea:	00006517          	auipc	a0,0x6
ffffffffc02007ee:	49650513          	addi	a0,a0,1174 # ffffffffc0206c80 <commands+0x7a8>
ffffffffc02007f2:	99dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc02007f6:	746c                	ld	a1,232(s0)
ffffffffc02007f8:	00006517          	auipc	a0,0x6
ffffffffc02007fc:	4a050513          	addi	a0,a0,1184 # ffffffffc0206c98 <commands+0x7c0>
ffffffffc0200800:	98fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200804:	786c                	ld	a1,240(s0)
ffffffffc0200806:	00006517          	auipc	a0,0x6
ffffffffc020080a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206cb0 <commands+0x7d8>
ffffffffc020080e:	981ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200812:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200814:	6402                	ld	s0,0(sp)
ffffffffc0200816:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200818:	00006517          	auipc	a0,0x6
ffffffffc020081c:	4b050513          	addi	a0,a0,1200 # ffffffffc0206cc8 <commands+0x7f0>
}
ffffffffc0200820:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200822:	96dff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200826 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200826:	1141                	addi	sp,sp,-16
ffffffffc0200828:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020082a:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc020082c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020082e:	00006517          	auipc	a0,0x6
ffffffffc0200832:	4b250513          	addi	a0,a0,1202 # ffffffffc0206ce0 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200836:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200838:	957ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc020083c:	8522                	mv	a0,s0
ffffffffc020083e:	e1bff0ef          	jal	ra,ffffffffc0200658 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200842:	10043583          	ld	a1,256(s0)
ffffffffc0200846:	00006517          	auipc	a0,0x6
ffffffffc020084a:	4b250513          	addi	a0,a0,1202 # ffffffffc0206cf8 <commands+0x820>
ffffffffc020084e:	941ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200852:	10843583          	ld	a1,264(s0)
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0206d10 <commands+0x838>
ffffffffc020085e:	931ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200862:	11043583          	ld	a1,272(s0)
ffffffffc0200866:	00006517          	auipc	a0,0x6
ffffffffc020086a:	4c250513          	addi	a0,a0,1218 # ffffffffc0206d28 <commands+0x850>
ffffffffc020086e:	921ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200872:	11843583          	ld	a1,280(s0)
}
ffffffffc0200876:	6402                	ld	s0,0(sp)
ffffffffc0200878:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020087a:	00006517          	auipc	a0,0x6
ffffffffc020087e:	4be50513          	addi	a0,a0,1214 # ffffffffc0206d38 <commands+0x860>
}
ffffffffc0200882:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200884:	90bff06f          	j	ffffffffc020018e <cprintf>

ffffffffc0200888 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc0200888:	1101                	addi	sp,sp,-32
ffffffffc020088a:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020088c:	000ac497          	auipc	s1,0xac
ffffffffc0200890:	e5c48493          	addi	s1,s1,-420 # ffffffffc02ac6e8 <check_mm_struct>
ffffffffc0200894:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc0200896:	e822                	sd	s0,16(sp)
ffffffffc0200898:	ec06                	sd	ra,24(sp)
ffffffffc020089a:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc020089c:	cbbd                	beqz	a5,ffffffffc0200912 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0; // spp被置位说明中断前是内核模式
ffffffffc020089e:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008a2:	11053583          	ld	a1,272(a0)
ffffffffc02008a6:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0; // spp被置位说明中断前是内核模式
ffffffffc02008aa:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008ae:	cba1                	beqz	a5,ffffffffc02008fe <pgfault_handler+0x76>
ffffffffc02008b0:	11843703          	ld	a4,280(s0)
ffffffffc02008b4:	47bd                	li	a5,15
ffffffffc02008b6:	05700693          	li	a3,87
ffffffffc02008ba:	00f70463          	beq	a4,a5,ffffffffc02008c2 <pgfault_handler+0x3a>
ffffffffc02008be:	05200693          	li	a3,82
ffffffffc02008c2:	00006517          	auipc	a0,0x6
ffffffffc02008c6:	09e50513          	addi	a0,a0,158 # ffffffffc0206960 <commands+0x488>
ffffffffc02008ca:	8c5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ce:	6088                	ld	a0,0(s1)
ffffffffc02008d0:	c129                	beqz	a0,ffffffffc0200912 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008d2:	000ac797          	auipc	a5,0xac
ffffffffc02008d6:	cde78793          	addi	a5,a5,-802 # ffffffffc02ac5b0 <current>
ffffffffc02008da:	6398                	ld	a4,0(a5)
ffffffffc02008dc:	000ac797          	auipc	a5,0xac
ffffffffc02008e0:	cdc78793          	addi	a5,a5,-804 # ffffffffc02ac5b8 <idleproc>
ffffffffc02008e4:	639c                	ld	a5,0(a5)
ffffffffc02008e6:	04f71763          	bne	a4,a5,ffffffffc0200934 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008ea:	11043603          	ld	a2,272(s0)
ffffffffc02008ee:	11843583          	ld	a1,280(s0)
}
ffffffffc02008f2:	6442                	ld	s0,16(sp)
ffffffffc02008f4:	60e2                	ld	ra,24(sp)
ffffffffc02008f6:	64a2                	ld	s1,8(sp)
ffffffffc02008f8:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc02008fa:	0000406f          	j	ffffffffc02048fa <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008fe:	11843703          	ld	a4,280(s0)
ffffffffc0200902:	47bd                	li	a5,15
ffffffffc0200904:	05500613          	li	a2,85
ffffffffc0200908:	05700693          	li	a3,87
ffffffffc020090c:	faf719e3          	bne	a4,a5,ffffffffc02008be <pgfault_handler+0x36>
ffffffffc0200910:	bf4d                	j	ffffffffc02008c2 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200912:	000ac797          	auipc	a5,0xac
ffffffffc0200916:	c9e78793          	addi	a5,a5,-866 # ffffffffc02ac5b0 <current>
ffffffffc020091a:	639c                	ld	a5,0(a5)
ffffffffc020091c:	cf85                	beqz	a5,ffffffffc0200954 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	11043603          	ld	a2,272(s0)
ffffffffc0200922:	11843583          	ld	a1,280(s0)
}
ffffffffc0200926:	6442                	ld	s0,16(sp)
ffffffffc0200928:	60e2                	ld	ra,24(sp)
ffffffffc020092a:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc020092c:	7788                	ld	a0,40(a5)
}
ffffffffc020092e:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200930:	7cb0306f          	j	ffffffffc02048fa <do_pgfault>
        assert(current == idleproc);
ffffffffc0200934:	00006697          	auipc	a3,0x6
ffffffffc0200938:	04c68693          	addi	a3,a3,76 # ffffffffc0206980 <commands+0x4a8>
ffffffffc020093c:	00006617          	auipc	a2,0x6
ffffffffc0200940:	05c60613          	addi	a2,a2,92 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0200944:	06b00593          	li	a1,107
ffffffffc0200948:	00006517          	auipc	a0,0x6
ffffffffc020094c:	06850513          	addi	a0,a0,104 # ffffffffc02069b0 <commands+0x4d8>
ffffffffc0200950:	b35ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200954:	8522                	mv	a0,s0
ffffffffc0200956:	ed1ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0; // spp被置位说明中断前是内核模式
ffffffffc020095a:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020095e:	11043583          	ld	a1,272(s0)
ffffffffc0200962:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0; // spp被置位说明中断前是内核模式
ffffffffc0200966:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020096a:	e399                	bnez	a5,ffffffffc0200970 <pgfault_handler+0xe8>
ffffffffc020096c:	05500613          	li	a2,85
ffffffffc0200970:	11843703          	ld	a4,280(s0)
ffffffffc0200974:	47bd                	li	a5,15
ffffffffc0200976:	02f70663          	beq	a4,a5,ffffffffc02009a2 <pgfault_handler+0x11a>
ffffffffc020097a:	05200693          	li	a3,82
ffffffffc020097e:	00006517          	auipc	a0,0x6
ffffffffc0200982:	fe250513          	addi	a0,a0,-30 # ffffffffc0206960 <commands+0x488>
ffffffffc0200986:	809ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc020098a:	00006617          	auipc	a2,0x6
ffffffffc020098e:	03e60613          	addi	a2,a2,62 # ffffffffc02069c8 <commands+0x4f0>
ffffffffc0200992:	07200593          	li	a1,114
ffffffffc0200996:	00006517          	auipc	a0,0x6
ffffffffc020099a:	01a50513          	addi	a0,a0,26 # ffffffffc02069b0 <commands+0x4d8>
ffffffffc020099e:	ae7ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009a2:	05700693          	li	a3,87
ffffffffc02009a6:	bfe1                	j	ffffffffc020097e <pgfault_handler+0xf6>

ffffffffc02009a8 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009a8:	11853783          	ld	a5,280(a0)
ffffffffc02009ac:	577d                	li	a4,-1
ffffffffc02009ae:	8305                	srli	a4,a4,0x1
ffffffffc02009b0:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009b2:	472d                	li	a4,11
ffffffffc02009b4:	08f76763          	bltu	a4,a5,ffffffffc0200a42 <interrupt_handler+0x9a>
ffffffffc02009b8:	00006717          	auipc	a4,0x6
ffffffffc02009bc:	cfc70713          	addi	a4,a4,-772 # ffffffffc02066b4 <commands+0x1dc>
ffffffffc02009c0:	078a                	slli	a5,a5,0x2
ffffffffc02009c2:	97ba                	add	a5,a5,a4
ffffffffc02009c4:	439c                	lw	a5,0(a5)
ffffffffc02009c6:	97ba                	add	a5,a5,a4
ffffffffc02009c8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ca:	00006517          	auipc	a0,0x6
ffffffffc02009ce:	f5650513          	addi	a0,a0,-170 # ffffffffc0206920 <commands+0x448>
ffffffffc02009d2:	fbcff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009d6:	00006517          	auipc	a0,0x6
ffffffffc02009da:	f2a50513          	addi	a0,a0,-214 # ffffffffc0206900 <commands+0x428>
ffffffffc02009de:	fb0ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009e2:	00006517          	auipc	a0,0x6
ffffffffc02009e6:	ede50513          	addi	a0,a0,-290 # ffffffffc02068c0 <commands+0x3e8>
ffffffffc02009ea:	fa4ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	ef250513          	addi	a0,a0,-270 # ffffffffc02068e0 <commands+0x408>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	f4650513          	addi	a0,a0,-186 # ffffffffc0206940 <commands+0x468>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a06:	1141                	addi	sp,sp,-16
ffffffffc0200a08:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a0a:	b63ff0ef          	jal	ra,ffffffffc020056c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a0e:	000ac797          	auipc	a5,0xac
ffffffffc0200a12:	bc278793          	addi	a5,a5,-1086 # ffffffffc02ac5d0 <ticks>
ffffffffc0200a16:	639c                	ld	a5,0(a5)
ffffffffc0200a18:	06400713          	li	a4,100
ffffffffc0200a1c:	0785                	addi	a5,a5,1
ffffffffc0200a1e:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a22:	000ac697          	auipc	a3,0xac
ffffffffc0200a26:	baf6b723          	sd	a5,-1106(a3) # ffffffffc02ac5d0 <ticks>
ffffffffc0200a2a:	eb09                	bnez	a4,ffffffffc0200a3c <interrupt_handler+0x94>
ffffffffc0200a2c:	000ac797          	auipc	a5,0xac
ffffffffc0200a30:	b8478793          	addi	a5,a5,-1148 # ffffffffc02ac5b0 <current>
ffffffffc0200a34:	639c                	ld	a5,0(a5)
ffffffffc0200a36:	c399                	beqz	a5,ffffffffc0200a3c <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a38:	4705                	li	a4,1
ffffffffc0200a3a:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a3c:	60a2                	ld	ra,8(sp)
ffffffffc0200a3e:	0141                	addi	sp,sp,16
ffffffffc0200a40:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a42:	de5ff06f          	j	ffffffffc0200826 <print_trapframe>

ffffffffc0200a46 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a46:	11853783          	ld	a5,280(a0)
ffffffffc0200a4a:	473d                	li	a4,15
ffffffffc0200a4c:	1af76e63          	bltu	a4,a5,ffffffffc0200c08 <exception_handler+0x1c2>
ffffffffc0200a50:	00006717          	auipc	a4,0x6
ffffffffc0200a54:	c9470713          	addi	a4,a4,-876 # ffffffffc02066e4 <commands+0x20c>
ffffffffc0200a58:	078a                	slli	a5,a5,0x2
ffffffffc0200a5a:	97ba                	add	a5,a5,a4
ffffffffc0200a5c:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a5e:	1101                	addi	sp,sp,-32
ffffffffc0200a60:	e822                	sd	s0,16(sp)
ffffffffc0200a62:	ec06                	sd	ra,24(sp)
ffffffffc0200a64:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a66:	97ba                	add	a5,a5,a4
ffffffffc0200a68:	842a                	mv	s0,a0
ffffffffc0200a6a:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a6c:	00006517          	auipc	a0,0x6
ffffffffc0200a70:	dac50513          	addi	a0,a0,-596 # ffffffffc0206818 <commands+0x340>
ffffffffc0200a74:	f1aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a78:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a7c:	60e2                	ld	ra,24(sp)
ffffffffc0200a7e:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a80:	0791                	addi	a5,a5,4
ffffffffc0200a82:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a86:	6442                	ld	s0,16(sp)
ffffffffc0200a88:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200a8a:	3c00506f          	j	ffffffffc0205e4a <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200a8e:	00006517          	auipc	a0,0x6
ffffffffc0200a92:	daa50513          	addi	a0,a0,-598 # ffffffffc0206838 <commands+0x360>
}
ffffffffc0200a96:	6442                	ld	s0,16(sp)
ffffffffc0200a98:	60e2                	ld	ra,24(sp)
ffffffffc0200a9a:	64a2                	ld	s1,8(sp)
ffffffffc0200a9c:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200a9e:	ef0ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200aa2:	00006517          	auipc	a0,0x6
ffffffffc0200aa6:	db650513          	addi	a0,a0,-586 # ffffffffc0206858 <commands+0x380>
ffffffffc0200aaa:	b7f5                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200aac:	00006517          	auipc	a0,0x6
ffffffffc0200ab0:	dcc50513          	addi	a0,a0,-564 # ffffffffc0206878 <commands+0x3a0>
ffffffffc0200ab4:	b7cd                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ab6:	00006517          	auipc	a0,0x6
ffffffffc0200aba:	dda50513          	addi	a0,a0,-550 # ffffffffc0206890 <commands+0x3b8>
ffffffffc0200abe:	ed0ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ac2:	8522                	mv	a0,s0
ffffffffc0200ac4:	dc5ff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200ac8:	84aa                	mv	s1,a0
ffffffffc0200aca:	14051163          	bnez	a0,ffffffffc0200c0c <exception_handler+0x1c6>
}
ffffffffc0200ace:	60e2                	ld	ra,24(sp)
ffffffffc0200ad0:	6442                	ld	s0,16(sp)
ffffffffc0200ad2:	64a2                	ld	s1,8(sp)
ffffffffc0200ad4:	6105                	addi	sp,sp,32
ffffffffc0200ad6:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200ad8:	00006517          	auipc	a0,0x6
ffffffffc0200adc:	dd050513          	addi	a0,a0,-560 # ffffffffc02068a8 <commands+0x3d0>
ffffffffc0200ae0:	eaeff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae4:	8522                	mv	a0,s0
ffffffffc0200ae6:	da3ff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200aea:	84aa                	mv	s1,a0
ffffffffc0200aec:	d16d                	beqz	a0,ffffffffc0200ace <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200aee:	8522                	mv	a0,s0
ffffffffc0200af0:	d37ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200af4:	86a6                	mv	a3,s1
ffffffffc0200af6:	00006617          	auipc	a2,0x6
ffffffffc0200afa:	cd260613          	addi	a2,a2,-814 # ffffffffc02067c8 <commands+0x2f0>
ffffffffc0200afe:	0f800593          	li	a1,248
ffffffffc0200b02:	00006517          	auipc	a0,0x6
ffffffffc0200b06:	eae50513          	addi	a0,a0,-338 # ffffffffc02069b0 <commands+0x4d8>
ffffffffc0200b0a:	97bff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b0e:	00006517          	auipc	a0,0x6
ffffffffc0200b12:	c1a50513          	addi	a0,a0,-998 # ffffffffc0206728 <commands+0x250>
ffffffffc0200b16:	b741                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b18:	00006517          	auipc	a0,0x6
ffffffffc0200b1c:	c3050513          	addi	a0,a0,-976 # ffffffffc0206748 <commands+0x270>
ffffffffc0200b20:	bf9d                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b22:	00006517          	auipc	a0,0x6
ffffffffc0200b26:	c4650513          	addi	a0,a0,-954 # ffffffffc0206768 <commands+0x290>
ffffffffc0200b2a:	b7b5                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b2c:	00006517          	auipc	a0,0x6
ffffffffc0200b30:	c5450513          	addi	a0,a0,-940 # ffffffffc0206780 <commands+0x2a8>
ffffffffc0200b34:	e5aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b38:	6458                	ld	a4,136(s0)
ffffffffc0200b3a:	47a9                	li	a5,10
ffffffffc0200b3c:	f8f719e3          	bne	a4,a5,ffffffffc0200ace <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b40:	10843783          	ld	a5,264(s0)
ffffffffc0200b44:	0791                	addi	a5,a5,4
ffffffffc0200b46:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b4a:	300050ef          	jal	ra,ffffffffc0205e4a <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b4e:	000ac797          	auipc	a5,0xac
ffffffffc0200b52:	a6278793          	addi	a5,a5,-1438 # ffffffffc02ac5b0 <current>
ffffffffc0200b56:	639c                	ld	a5,0(a5)
ffffffffc0200b58:	8522                	mv	a0,s0
}
ffffffffc0200b5a:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b5c:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b5e:	60e2                	ld	ra,24(sp)
ffffffffc0200b60:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b62:	6589                	lui	a1,0x2
ffffffffc0200b64:	95be                	add	a1,a1,a5
}
ffffffffc0200b66:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b68:	2220006f          	j	ffffffffc0200d8a <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b6c:	00006517          	auipc	a0,0x6
ffffffffc0200b70:	c2450513          	addi	a0,a0,-988 # ffffffffc0206790 <commands+0x2b8>
ffffffffc0200b74:	b70d                	j	ffffffffc0200a96 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b76:	00006517          	auipc	a0,0x6
ffffffffc0200b7a:	c3a50513          	addi	a0,a0,-966 # ffffffffc02067b0 <commands+0x2d8>
ffffffffc0200b7e:	e10ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b82:	8522                	mv	a0,s0
ffffffffc0200b84:	d05ff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200b88:	84aa                	mv	s1,a0
ffffffffc0200b8a:	d131                	beqz	a0,ffffffffc0200ace <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b8c:	8522                	mv	a0,s0
ffffffffc0200b8e:	c99ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b92:	86a6                	mv	a3,s1
ffffffffc0200b94:	00006617          	auipc	a2,0x6
ffffffffc0200b98:	c3460613          	addi	a2,a2,-972 # ffffffffc02067c8 <commands+0x2f0>
ffffffffc0200b9c:	0cd00593          	li	a1,205
ffffffffc0200ba0:	00006517          	auipc	a0,0x6
ffffffffc0200ba4:	e1050513          	addi	a0,a0,-496 # ffffffffc02069b0 <commands+0x4d8>
ffffffffc0200ba8:	8ddff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bac:	00006517          	auipc	a0,0x6
ffffffffc0200bb0:	c5450513          	addi	a0,a0,-940 # ffffffffc0206800 <commands+0x328>
ffffffffc0200bb4:	ddaff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bb8:	8522                	mv	a0,s0
ffffffffc0200bba:	ccfff0ef          	jal	ra,ffffffffc0200888 <pgfault_handler>
ffffffffc0200bbe:	84aa                	mv	s1,a0
ffffffffc0200bc0:	f00507e3          	beqz	a0,ffffffffc0200ace <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bc4:	8522                	mv	a0,s0
ffffffffc0200bc6:	c61ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bca:	86a6                	mv	a3,s1
ffffffffc0200bcc:	00006617          	auipc	a2,0x6
ffffffffc0200bd0:	bfc60613          	addi	a2,a2,-1028 # ffffffffc02067c8 <commands+0x2f0>
ffffffffc0200bd4:	0d700593          	li	a1,215
ffffffffc0200bd8:	00006517          	auipc	a0,0x6
ffffffffc0200bdc:	dd850513          	addi	a0,a0,-552 # ffffffffc02069b0 <commands+0x4d8>
ffffffffc0200be0:	8a5ff0ef          	jal	ra,ffffffffc0200484 <__panic>
}
ffffffffc0200be4:	6442                	ld	s0,16(sp)
ffffffffc0200be6:	60e2                	ld	ra,24(sp)
ffffffffc0200be8:	64a2                	ld	s1,8(sp)
ffffffffc0200bea:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200bec:	c3bff06f          	j	ffffffffc0200826 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	bf860613          	addi	a2,a2,-1032 # ffffffffc02067e8 <commands+0x310>
ffffffffc0200bf8:	0d100593          	li	a1,209
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	db450513          	addi	a0,a0,-588 # ffffffffc02069b0 <commands+0x4d8>
ffffffffc0200c04:	881ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200c08:	c1fff06f          	j	ffffffffc0200826 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c0c:	8522                	mv	a0,s0
ffffffffc0200c0e:	c19ff0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c12:	86a6                	mv	a3,s1
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	bb460613          	addi	a2,a2,-1100 # ffffffffc02067c8 <commands+0x2f0>
ffffffffc0200c1c:	0f100593          	li	a1,241
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	d9050513          	addi	a0,a0,-624 # ffffffffc02069b0 <commands+0x4d8>
ffffffffc0200c28:	85dff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200c2c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c2c:	1101                	addi	sp,sp,-32
ffffffffc0200c2e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c30:	000ac417          	auipc	s0,0xac
ffffffffc0200c34:	98040413          	addi	s0,s0,-1664 # ffffffffc02ac5b0 <current>
ffffffffc0200c38:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c3a:	ec06                	sd	ra,24(sp)
ffffffffc0200c3c:	e426                	sd	s1,8(sp)
ffffffffc0200c3e:	e04a                	sd	s2,0(sp)
ffffffffc0200c40:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c44:	cf1d                	beqz	a4,ffffffffc0200c82 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0; // spp被置位说明中断前是内核模式
ffffffffc0200c46:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c4a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;   // 拿到进入前的中断帧，也就是中断前栈上的情况
ffffffffc0200c4e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0; // spp被置位说明中断前是内核模式
ffffffffc0200c50:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c54:	0206c463          	bltz	a3,ffffffffc0200c7c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c58:	defff0ef          	jal	ra,ffffffffc0200a46 <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c5c:	601c                	ld	a5,0(s0)
ffffffffc0200c5e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c62:	e499                	bnez	s1,ffffffffc0200c70 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c64:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c68:	8b05                	andi	a4,a4,1
ffffffffc0200c6a:	e339                	bnez	a4,ffffffffc0200cb0 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c6c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c6e:	eb95                	bnez	a5,ffffffffc0200ca2 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c70:	60e2                	ld	ra,24(sp)
ffffffffc0200c72:	6442                	ld	s0,16(sp)
ffffffffc0200c74:	64a2                	ld	s1,8(sp)
ffffffffc0200c76:	6902                	ld	s2,0(sp)
ffffffffc0200c78:	6105                	addi	sp,sp,32
ffffffffc0200c7a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c7c:	d2dff0ef          	jal	ra,ffffffffc02009a8 <interrupt_handler>
ffffffffc0200c80:	bff1                	j	ffffffffc0200c5c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c82:	0006c963          	bltz	a3,ffffffffc0200c94 <trap+0x68>
}
ffffffffc0200c86:	6442                	ld	s0,16(sp)
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200c90:	db7ff06f          	j	ffffffffc0200a46 <exception_handler>
}
ffffffffc0200c94:	6442                	ld	s0,16(sp)
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200c9e:	d0bff06f          	j	ffffffffc02009a8 <interrupt_handler>
}
ffffffffc0200ca2:	6442                	ld	s0,16(sp)
ffffffffc0200ca4:	60e2                	ld	ra,24(sp)
ffffffffc0200ca6:	64a2                	ld	s1,8(sp)
ffffffffc0200ca8:	6902                	ld	s2,0(sp)
ffffffffc0200caa:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cac:	0a80506f          	j	ffffffffc0205d54 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cb0:	555d                	li	a0,-9
ffffffffc0200cb2:	4b8040ef          	jal	ra,ffffffffc020516a <do_exit>
ffffffffc0200cb6:	601c                	ld	a5,0(s0)
ffffffffc0200cb8:	bf55                	j	ffffffffc0200c6c <trap+0x40>
	...

ffffffffc0200cbc <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cbc:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cc0:	00011463          	bnez	sp,ffffffffc0200cc8 <__alltraps+0xc>
ffffffffc0200cc4:	14002173          	csrr	sp,sscratch
ffffffffc0200cc8:	712d                	addi	sp,sp,-288
ffffffffc0200cca:	e002                	sd	zero,0(sp)
ffffffffc0200ccc:	e406                	sd	ra,8(sp)
ffffffffc0200cce:	ec0e                	sd	gp,24(sp)
ffffffffc0200cd0:	f012                	sd	tp,32(sp)
ffffffffc0200cd2:	f416                	sd	t0,40(sp)
ffffffffc0200cd4:	f81a                	sd	t1,48(sp)
ffffffffc0200cd6:	fc1e                	sd	t2,56(sp)
ffffffffc0200cd8:	e0a2                	sd	s0,64(sp)
ffffffffc0200cda:	e4a6                	sd	s1,72(sp)
ffffffffc0200cdc:	e8aa                	sd	a0,80(sp)
ffffffffc0200cde:	ecae                	sd	a1,88(sp)
ffffffffc0200ce0:	f0b2                	sd	a2,96(sp)
ffffffffc0200ce2:	f4b6                	sd	a3,104(sp)
ffffffffc0200ce4:	f8ba                	sd	a4,112(sp)
ffffffffc0200ce6:	fcbe                	sd	a5,120(sp)
ffffffffc0200ce8:	e142                	sd	a6,128(sp)
ffffffffc0200cea:	e546                	sd	a7,136(sp)
ffffffffc0200cec:	e94a                	sd	s2,144(sp)
ffffffffc0200cee:	ed4e                	sd	s3,152(sp)
ffffffffc0200cf0:	f152                	sd	s4,160(sp)
ffffffffc0200cf2:	f556                	sd	s5,168(sp)
ffffffffc0200cf4:	f95a                	sd	s6,176(sp)
ffffffffc0200cf6:	fd5e                	sd	s7,184(sp)
ffffffffc0200cf8:	e1e2                	sd	s8,192(sp)
ffffffffc0200cfa:	e5e6                	sd	s9,200(sp)
ffffffffc0200cfc:	e9ea                	sd	s10,208(sp)
ffffffffc0200cfe:	edee                	sd	s11,216(sp)
ffffffffc0200d00:	f1f2                	sd	t3,224(sp)
ffffffffc0200d02:	f5f6                	sd	t4,232(sp)
ffffffffc0200d04:	f9fa                	sd	t5,240(sp)
ffffffffc0200d06:	fdfe                	sd	t6,248(sp)
ffffffffc0200d08:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d0c:	100024f3          	csrr	s1,sstatus
ffffffffc0200d10:	14102973          	csrr	s2,sepc
ffffffffc0200d14:	143029f3          	csrr	s3,stval
ffffffffc0200d18:	14202a73          	csrr	s4,scause
ffffffffc0200d1c:	e822                	sd	s0,16(sp)
ffffffffc0200d1e:	e226                	sd	s1,256(sp)
ffffffffc0200d20:	e64a                	sd	s2,264(sp)
ffffffffc0200d22:	ea4e                	sd	s3,272(sp)
ffffffffc0200d24:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d26:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d28:	f05ff0ef          	jal	ra,ffffffffc0200c2c <trap>

ffffffffc0200d2c <__trapret>:
    # trap 函数完毕就会返回到下面
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d2c:	6492                	ld	s1,256(sp)
ffffffffc0200d2e:	6932                	ld	s2,264(sp)
ffffffffc0200d30:	1004f413          	andi	s0,s1,256
ffffffffc0200d34:	e401                	bnez	s0,ffffffffc0200d3c <__trapret+0x10>
ffffffffc0200d36:	1200                	addi	s0,sp,288
ffffffffc0200d38:	14041073          	csrw	sscratch,s0
ffffffffc0200d3c:	10049073          	csrw	sstatus,s1
ffffffffc0200d40:	14191073          	csrw	sepc,s2
ffffffffc0200d44:	60a2                	ld	ra,8(sp)
ffffffffc0200d46:	61e2                	ld	gp,24(sp)
ffffffffc0200d48:	7202                	ld	tp,32(sp)
ffffffffc0200d4a:	72a2                	ld	t0,40(sp)
ffffffffc0200d4c:	7342                	ld	t1,48(sp)
ffffffffc0200d4e:	73e2                	ld	t2,56(sp)
ffffffffc0200d50:	6406                	ld	s0,64(sp)
ffffffffc0200d52:	64a6                	ld	s1,72(sp)
ffffffffc0200d54:	6546                	ld	a0,80(sp)
ffffffffc0200d56:	65e6                	ld	a1,88(sp)
ffffffffc0200d58:	7606                	ld	a2,96(sp)
ffffffffc0200d5a:	76a6                	ld	a3,104(sp)
ffffffffc0200d5c:	7746                	ld	a4,112(sp)
ffffffffc0200d5e:	77e6                	ld	a5,120(sp)
ffffffffc0200d60:	680a                	ld	a6,128(sp)
ffffffffc0200d62:	68aa                	ld	a7,136(sp)
ffffffffc0200d64:	694a                	ld	s2,144(sp)
ffffffffc0200d66:	69ea                	ld	s3,152(sp)
ffffffffc0200d68:	7a0a                	ld	s4,160(sp)
ffffffffc0200d6a:	7aaa                	ld	s5,168(sp)
ffffffffc0200d6c:	7b4a                	ld	s6,176(sp)
ffffffffc0200d6e:	7bea                	ld	s7,184(sp)
ffffffffc0200d70:	6c0e                	ld	s8,192(sp)
ffffffffc0200d72:	6cae                	ld	s9,200(sp)
ffffffffc0200d74:	6d4e                	ld	s10,208(sp)
ffffffffc0200d76:	6dee                	ld	s11,216(sp)
ffffffffc0200d78:	7e0e                	ld	t3,224(sp)
ffffffffc0200d7a:	7eae                	ld	t4,232(sp)
ffffffffc0200d7c:	7f4e                	ld	t5,240(sp)
ffffffffc0200d7e:	7fee                	ld	t6,248(sp)
ffffffffc0200d80:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d82:	10200073          	sret

ffffffffc0200d86 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d86:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d88:	b755                	j	ffffffffc0200d2c <__trapret>

ffffffffc0200d8a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d8a:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76b0>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d8e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d92:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200d96:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200d9a:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200d9e:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200da2:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200da6:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200daa:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dae:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200db0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200db2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200db4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200db6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200db8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dba:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dbc:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dbe:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dc0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dc2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dc4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dc6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dc8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dca:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dcc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dce:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200dd0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dd2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200dd4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dd6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dd8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dda:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200ddc:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dde:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200de0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200de2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200de4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200de6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200de8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dea:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200dec:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dee:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200df0:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200df2:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200df4:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200df6:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200df8:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200dfa:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200dfc:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200dfe:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e00:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e02:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e04:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e06:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e08:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e0a:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e0c:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e0e:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e10:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e12:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e14:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e16:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e18:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e1a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e1c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e1e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e20:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e22:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e24:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e26:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e28:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e2a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e2c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e2e:	812e                	mv	sp,a1
ffffffffc0200e30:	bdf5                	j	ffffffffc0200d2c <__trapret>

ffffffffc0200e32 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e32:	000ab797          	auipc	a5,0xab
ffffffffc0200e36:	7a678793          	addi	a5,a5,1958 # ffffffffc02ac5d8 <free_area>
ffffffffc0200e3a:	e79c                	sd	a5,8(a5)
ffffffffc0200e3c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e3e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e42:	8082                	ret

ffffffffc0200e44 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e44:	000ab517          	auipc	a0,0xab
ffffffffc0200e48:	7a456503          	lwu	a0,1956(a0) # ffffffffc02ac5e8 <free_area+0x10>
ffffffffc0200e4c:	8082                	ret

ffffffffc0200e4e <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e4e:	715d                	addi	sp,sp,-80
ffffffffc0200e50:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e52:	000ab917          	auipc	s2,0xab
ffffffffc0200e56:	78690913          	addi	s2,s2,1926 # ffffffffc02ac5d8 <free_area>
ffffffffc0200e5a:	00893783          	ld	a5,8(s2)
ffffffffc0200e5e:	e486                	sd	ra,72(sp)
ffffffffc0200e60:	e0a2                	sd	s0,64(sp)
ffffffffc0200e62:	fc26                	sd	s1,56(sp)
ffffffffc0200e64:	f44e                	sd	s3,40(sp)
ffffffffc0200e66:	f052                	sd	s4,32(sp)
ffffffffc0200e68:	ec56                	sd	s5,24(sp)
ffffffffc0200e6a:	e85a                	sd	s6,16(sp)
ffffffffc0200e6c:	e45e                	sd	s7,8(sp)
ffffffffc0200e6e:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e70:	31278463          	beq	a5,s2,ffffffffc0201178 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e74:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e78:	8305                	srli	a4,a4,0x1
ffffffffc0200e7a:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e7c:	30070263          	beqz	a4,ffffffffc0201180 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e80:	4401                	li	s0,0
ffffffffc0200e82:	4481                	li	s1,0
ffffffffc0200e84:	a031                	j	ffffffffc0200e90 <default_check+0x42>
ffffffffc0200e86:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e8a:	8b09                	andi	a4,a4,2
ffffffffc0200e8c:	2e070a63          	beqz	a4,ffffffffc0201180 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200e90:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e94:	679c                	ld	a5,8(a5)
ffffffffc0200e96:	2485                	addiw	s1,s1,1
ffffffffc0200e98:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e9a:	ff2796e3          	bne	a5,s2,ffffffffc0200e86 <default_check+0x38>
ffffffffc0200e9e:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200ea0:	05c010ef          	jal	ra,ffffffffc0201efc <nr_free_pages>
ffffffffc0200ea4:	73351e63          	bne	a0,s3,ffffffffc02015e0 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ea8:	4505                	li	a0,1
ffffffffc0200eaa:	785000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200eae:	8a2a                	mv	s4,a0
ffffffffc0200eb0:	46050863          	beqz	a0,ffffffffc0201320 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200eb4:	4505                	li	a0,1
ffffffffc0200eb6:	779000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200eba:	89aa                	mv	s3,a0
ffffffffc0200ebc:	74050263          	beqz	a0,ffffffffc0201600 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ec0:	4505                	li	a0,1
ffffffffc0200ec2:	76d000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200ec6:	8aaa                	mv	s5,a0
ffffffffc0200ec8:	4c050c63          	beqz	a0,ffffffffc02013a0 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ecc:	2d3a0a63          	beq	s4,s3,ffffffffc02011a0 <default_check+0x352>
ffffffffc0200ed0:	2caa0863          	beq	s4,a0,ffffffffc02011a0 <default_check+0x352>
ffffffffc0200ed4:	2ca98663          	beq	s3,a0,ffffffffc02011a0 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ed8:	000a2783          	lw	a5,0(s4)
ffffffffc0200edc:	2e079263          	bnez	a5,ffffffffc02011c0 <default_check+0x372>
ffffffffc0200ee0:	0009a783          	lw	a5,0(s3)
ffffffffc0200ee4:	2c079e63          	bnez	a5,ffffffffc02011c0 <default_check+0x372>
ffffffffc0200ee8:	411c                	lw	a5,0(a0)
ffffffffc0200eea:	2c079b63          	bnez	a5,ffffffffc02011c0 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200eee:	000ab797          	auipc	a5,0xab
ffffffffc0200ef2:	71a78793          	addi	a5,a5,1818 # ffffffffc02ac608 <pages>
ffffffffc0200ef6:	639c                	ld	a5,0(a5)
ffffffffc0200ef8:	00008717          	auipc	a4,0x8
ffffffffc0200efc:	b0070713          	addi	a4,a4,-1280 # ffffffffc02089f8 <nbase>
ffffffffc0200f00:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f02:	000ab717          	auipc	a4,0xab
ffffffffc0200f06:	69670713          	addi	a4,a4,1686 # ffffffffc02ac598 <npage>
ffffffffc0200f0a:	6314                	ld	a3,0(a4)
ffffffffc0200f0c:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f10:	8719                	srai	a4,a4,0x6
ffffffffc0200f12:	9732                	add	a4,a4,a2
ffffffffc0200f14:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f16:	0732                	slli	a4,a4,0xc
ffffffffc0200f18:	2cd77463          	bleu	a3,a4,ffffffffc02011e0 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f1c:	40f98733          	sub	a4,s3,a5
ffffffffc0200f20:	8719                	srai	a4,a4,0x6
ffffffffc0200f22:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f24:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f26:	4ed77d63          	bleu	a3,a4,ffffffffc0201420 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f2a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f2e:	8799                	srai	a5,a5,0x6
ffffffffc0200f30:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f32:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f34:	34d7f663          	bleu	a3,a5,ffffffffc0201280 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f38:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f3a:	00093c03          	ld	s8,0(s2)
ffffffffc0200f3e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f42:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f46:	000ab797          	auipc	a5,0xab
ffffffffc0200f4a:	6927bd23          	sd	s2,1690(a5) # ffffffffc02ac5e0 <free_area+0x8>
ffffffffc0200f4e:	000ab797          	auipc	a5,0xab
ffffffffc0200f52:	6927b523          	sd	s2,1674(a5) # ffffffffc02ac5d8 <free_area>
    nr_free = 0;
ffffffffc0200f56:	000ab797          	auipc	a5,0xab
ffffffffc0200f5a:	6807a923          	sw	zero,1682(a5) # ffffffffc02ac5e8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f5e:	6d1000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200f62:	2e051f63          	bnez	a0,ffffffffc0201260 <default_check+0x412>
    free_page(p0);
ffffffffc0200f66:	4585                	li	a1,1
ffffffffc0200f68:	8552                	mv	a0,s4
ffffffffc0200f6a:	74d000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    free_page(p1);
ffffffffc0200f6e:	4585                	li	a1,1
ffffffffc0200f70:	854e                	mv	a0,s3
ffffffffc0200f72:	745000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    free_page(p2);
ffffffffc0200f76:	4585                	li	a1,1
ffffffffc0200f78:	8556                	mv	a0,s5
ffffffffc0200f7a:	73d000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f7e:	01092703          	lw	a4,16(s2)
ffffffffc0200f82:	478d                	li	a5,3
ffffffffc0200f84:	2af71e63          	bne	a4,a5,ffffffffc0201240 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f88:	4505                	li	a0,1
ffffffffc0200f8a:	6a5000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200f8e:	89aa                	mv	s3,a0
ffffffffc0200f90:	28050863          	beqz	a0,ffffffffc0201220 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f94:	4505                	li	a0,1
ffffffffc0200f96:	699000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200f9a:	8aaa                	mv	s5,a0
ffffffffc0200f9c:	3e050263          	beqz	a0,ffffffffc0201380 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fa0:	4505                	li	a0,1
ffffffffc0200fa2:	68d000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200fa6:	8a2a                	mv	s4,a0
ffffffffc0200fa8:	3a050c63          	beqz	a0,ffffffffc0201360 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fac:	4505                	li	a0,1
ffffffffc0200fae:	681000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200fb2:	38051763          	bnez	a0,ffffffffc0201340 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fb6:	4585                	li	a1,1
ffffffffc0200fb8:	854e                	mv	a0,s3
ffffffffc0200fba:	6fd000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fbe:	00893783          	ld	a5,8(s2)
ffffffffc0200fc2:	23278f63          	beq	a5,s2,ffffffffc0201200 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fc6:	4505                	li	a0,1
ffffffffc0200fc8:	667000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200fcc:	32a99a63          	bne	s3,a0,ffffffffc0201300 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fd0:	4505                	li	a0,1
ffffffffc0200fd2:	65d000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0200fd6:	30051563          	bnez	a0,ffffffffc02012e0 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fda:	01092783          	lw	a5,16(s2)
ffffffffc0200fde:	2e079163          	bnez	a5,ffffffffc02012c0 <default_check+0x472>
    free_page(p);
ffffffffc0200fe2:	854e                	mv	a0,s3
ffffffffc0200fe4:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fe6:	000ab797          	auipc	a5,0xab
ffffffffc0200fea:	5f87b923          	sd	s8,1522(a5) # ffffffffc02ac5d8 <free_area>
ffffffffc0200fee:	000ab797          	auipc	a5,0xab
ffffffffc0200ff2:	5f77b923          	sd	s7,1522(a5) # ffffffffc02ac5e0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200ff6:	000ab797          	auipc	a5,0xab
ffffffffc0200ffa:	5f67a923          	sw	s6,1522(a5) # ffffffffc02ac5e8 <free_area+0x10>
    free_page(p);
ffffffffc0200ffe:	6b9000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    free_page(p1);
ffffffffc0201002:	4585                	li	a1,1
ffffffffc0201004:	8556                	mv	a0,s5
ffffffffc0201006:	6b1000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    free_page(p2);
ffffffffc020100a:	4585                	li	a1,1
ffffffffc020100c:	8552                	mv	a0,s4
ffffffffc020100e:	6a9000ef          	jal	ra,ffffffffc0201eb6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201012:	4515                	li	a0,5
ffffffffc0201014:	61b000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0201018:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020101a:	28050363          	beqz	a0,ffffffffc02012a0 <default_check+0x452>
ffffffffc020101e:	651c                	ld	a5,8(a0)
ffffffffc0201020:	8385                	srli	a5,a5,0x1
ffffffffc0201022:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201024:	54079e63          	bnez	a5,ffffffffc0201580 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201028:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020102a:	00093b03          	ld	s6,0(s2)
ffffffffc020102e:	00893a83          	ld	s5,8(s2)
ffffffffc0201032:	000ab797          	auipc	a5,0xab
ffffffffc0201036:	5b27b323          	sd	s2,1446(a5) # ffffffffc02ac5d8 <free_area>
ffffffffc020103a:	000ab797          	auipc	a5,0xab
ffffffffc020103e:	5b27b323          	sd	s2,1446(a5) # ffffffffc02ac5e0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201042:	5ed000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0201046:	50051d63          	bnez	a0,ffffffffc0201560 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020104a:	08098a13          	addi	s4,s3,128
ffffffffc020104e:	8552                	mv	a0,s4
ffffffffc0201050:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201052:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0201056:	000ab797          	auipc	a5,0xab
ffffffffc020105a:	5807a923          	sw	zero,1426(a5) # ffffffffc02ac5e8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020105e:	659000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201062:	4511                	li	a0,4
ffffffffc0201064:	5cb000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0201068:	4c051c63          	bnez	a0,ffffffffc0201540 <default_check+0x6f2>
ffffffffc020106c:	0889b783          	ld	a5,136(s3)
ffffffffc0201070:	8385                	srli	a5,a5,0x1
ffffffffc0201072:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201074:	4a078663          	beqz	a5,ffffffffc0201520 <default_check+0x6d2>
ffffffffc0201078:	0909a703          	lw	a4,144(s3)
ffffffffc020107c:	478d                	li	a5,3
ffffffffc020107e:	4af71163          	bne	a4,a5,ffffffffc0201520 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201082:	450d                	li	a0,3
ffffffffc0201084:	5ab000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0201088:	8c2a                	mv	s8,a0
ffffffffc020108a:	46050b63          	beqz	a0,ffffffffc0201500 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc020108e:	4505                	li	a0,1
ffffffffc0201090:	59f000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0201094:	44051663          	bnez	a0,ffffffffc02014e0 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc0201098:	438a1463          	bne	s4,s8,ffffffffc02014c0 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020109c:	4585                	li	a1,1
ffffffffc020109e:	854e                	mv	a0,s3
ffffffffc02010a0:	617000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    free_pages(p1, 3);
ffffffffc02010a4:	458d                	li	a1,3
ffffffffc02010a6:	8552                	mv	a0,s4
ffffffffc02010a8:	60f000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
ffffffffc02010ac:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010b0:	04098c13          	addi	s8,s3,64
ffffffffc02010b4:	8385                	srli	a5,a5,0x1
ffffffffc02010b6:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010b8:	3e078463          	beqz	a5,ffffffffc02014a0 <default_check+0x652>
ffffffffc02010bc:	0109a703          	lw	a4,16(s3)
ffffffffc02010c0:	4785                	li	a5,1
ffffffffc02010c2:	3cf71f63          	bne	a4,a5,ffffffffc02014a0 <default_check+0x652>
ffffffffc02010c6:	008a3783          	ld	a5,8(s4)
ffffffffc02010ca:	8385                	srli	a5,a5,0x1
ffffffffc02010cc:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010ce:	3a078963          	beqz	a5,ffffffffc0201480 <default_check+0x632>
ffffffffc02010d2:	010a2703          	lw	a4,16(s4)
ffffffffc02010d6:	478d                	li	a5,3
ffffffffc02010d8:	3af71463          	bne	a4,a5,ffffffffc0201480 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010dc:	4505                	li	a0,1
ffffffffc02010de:	551000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc02010e2:	36a99f63          	bne	s3,a0,ffffffffc0201460 <default_check+0x612>
    free_page(p0);
ffffffffc02010e6:	4585                	li	a1,1
ffffffffc02010e8:	5cf000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010ec:	4509                	li	a0,2
ffffffffc02010ee:	541000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc02010f2:	34aa1763          	bne	s4,a0,ffffffffc0201440 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc02010f6:	4589                	li	a1,2
ffffffffc02010f8:	5bf000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    free_page(p2);
ffffffffc02010fc:	4585                	li	a1,1
ffffffffc02010fe:	8562                	mv	a0,s8
ffffffffc0201100:	5b7000ef          	jal	ra,ffffffffc0201eb6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201104:	4515                	li	a0,5
ffffffffc0201106:	529000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc020110a:	89aa                	mv	s3,a0
ffffffffc020110c:	48050a63          	beqz	a0,ffffffffc02015a0 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201110:	4505                	li	a0,1
ffffffffc0201112:	51d000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0201116:	2e051563          	bnez	a0,ffffffffc0201400 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020111a:	01092783          	lw	a5,16(s2)
ffffffffc020111e:	2c079163          	bnez	a5,ffffffffc02013e0 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201122:	4595                	li	a1,5
ffffffffc0201124:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201126:	000ab797          	auipc	a5,0xab
ffffffffc020112a:	4d77a123          	sw	s7,1218(a5) # ffffffffc02ac5e8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020112e:	000ab797          	auipc	a5,0xab
ffffffffc0201132:	4b67b523          	sd	s6,1194(a5) # ffffffffc02ac5d8 <free_area>
ffffffffc0201136:	000ab797          	auipc	a5,0xab
ffffffffc020113a:	4b57b523          	sd	s5,1194(a5) # ffffffffc02ac5e0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020113e:	579000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    return listelm->next;
ffffffffc0201142:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201146:	01278963          	beq	a5,s2,ffffffffc0201158 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020114a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020114e:	679c                	ld	a5,8(a5)
ffffffffc0201150:	34fd                	addiw	s1,s1,-1
ffffffffc0201152:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201154:	ff279be3          	bne	a5,s2,ffffffffc020114a <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0201158:	26049463          	bnez	s1,ffffffffc02013c0 <default_check+0x572>
    assert(total == 0);
ffffffffc020115c:	46041263          	bnez	s0,ffffffffc02015c0 <default_check+0x772>
}
ffffffffc0201160:	60a6                	ld	ra,72(sp)
ffffffffc0201162:	6406                	ld	s0,64(sp)
ffffffffc0201164:	74e2                	ld	s1,56(sp)
ffffffffc0201166:	7942                	ld	s2,48(sp)
ffffffffc0201168:	79a2                	ld	s3,40(sp)
ffffffffc020116a:	7a02                	ld	s4,32(sp)
ffffffffc020116c:	6ae2                	ld	s5,24(sp)
ffffffffc020116e:	6b42                	ld	s6,16(sp)
ffffffffc0201170:	6ba2                	ld	s7,8(sp)
ffffffffc0201172:	6c02                	ld	s8,0(sp)
ffffffffc0201174:	6161                	addi	sp,sp,80
ffffffffc0201176:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201178:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020117a:	4401                	li	s0,0
ffffffffc020117c:	4481                	li	s1,0
ffffffffc020117e:	b30d                	j	ffffffffc0200ea0 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201180:	00006697          	auipc	a3,0x6
ffffffffc0201184:	bd068693          	addi	a3,a3,-1072 # ffffffffc0206d50 <commands+0x878>
ffffffffc0201188:	00006617          	auipc	a2,0x6
ffffffffc020118c:	81060613          	addi	a2,a2,-2032 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201190:	0f000593          	li	a1,240
ffffffffc0201194:	00006517          	auipc	a0,0x6
ffffffffc0201198:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0206d60 <commands+0x888>
ffffffffc020119c:	ae8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011a0:	00006697          	auipc	a3,0x6
ffffffffc02011a4:	c5868693          	addi	a3,a3,-936 # ffffffffc0206df8 <commands+0x920>
ffffffffc02011a8:	00005617          	auipc	a2,0x5
ffffffffc02011ac:	7f060613          	addi	a2,a2,2032 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02011b0:	0bd00593          	li	a1,189
ffffffffc02011b4:	00006517          	auipc	a0,0x6
ffffffffc02011b8:	bac50513          	addi	a0,a0,-1108 # ffffffffc0206d60 <commands+0x888>
ffffffffc02011bc:	ac8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011c0:	00006697          	auipc	a3,0x6
ffffffffc02011c4:	c6068693          	addi	a3,a3,-928 # ffffffffc0206e20 <commands+0x948>
ffffffffc02011c8:	00005617          	auipc	a2,0x5
ffffffffc02011cc:	7d060613          	addi	a2,a2,2000 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02011d0:	0be00593          	li	a1,190
ffffffffc02011d4:	00006517          	auipc	a0,0x6
ffffffffc02011d8:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0206d60 <commands+0x888>
ffffffffc02011dc:	aa8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011e0:	00006697          	auipc	a3,0x6
ffffffffc02011e4:	c8068693          	addi	a3,a3,-896 # ffffffffc0206e60 <commands+0x988>
ffffffffc02011e8:	00005617          	auipc	a2,0x5
ffffffffc02011ec:	7b060613          	addi	a2,a2,1968 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02011f0:	0c000593          	li	a1,192
ffffffffc02011f4:	00006517          	auipc	a0,0x6
ffffffffc02011f8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0206d60 <commands+0x888>
ffffffffc02011fc:	a88ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201200:	00006697          	auipc	a3,0x6
ffffffffc0201204:	ce868693          	addi	a3,a3,-792 # ffffffffc0206ee8 <commands+0xa10>
ffffffffc0201208:	00005617          	auipc	a2,0x5
ffffffffc020120c:	79060613          	addi	a2,a2,1936 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201210:	0d900593          	li	a1,217
ffffffffc0201214:	00006517          	auipc	a0,0x6
ffffffffc0201218:	b4c50513          	addi	a0,a0,-1204 # ffffffffc0206d60 <commands+0x888>
ffffffffc020121c:	a68ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201220:	00006697          	auipc	a3,0x6
ffffffffc0201224:	b7868693          	addi	a3,a3,-1160 # ffffffffc0206d98 <commands+0x8c0>
ffffffffc0201228:	00005617          	auipc	a2,0x5
ffffffffc020122c:	77060613          	addi	a2,a2,1904 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201230:	0d200593          	li	a1,210
ffffffffc0201234:	00006517          	auipc	a0,0x6
ffffffffc0201238:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0206d60 <commands+0x888>
ffffffffc020123c:	a48ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 3);
ffffffffc0201240:	00006697          	auipc	a3,0x6
ffffffffc0201244:	c9868693          	addi	a3,a3,-872 # ffffffffc0206ed8 <commands+0xa00>
ffffffffc0201248:	00005617          	auipc	a2,0x5
ffffffffc020124c:	75060613          	addi	a2,a2,1872 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201250:	0d000593          	li	a1,208
ffffffffc0201254:	00006517          	auipc	a0,0x6
ffffffffc0201258:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0206d60 <commands+0x888>
ffffffffc020125c:	a28ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201260:	00006697          	auipc	a3,0x6
ffffffffc0201264:	c6068693          	addi	a3,a3,-928 # ffffffffc0206ec0 <commands+0x9e8>
ffffffffc0201268:	00005617          	auipc	a2,0x5
ffffffffc020126c:	73060613          	addi	a2,a2,1840 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201270:	0cb00593          	li	a1,203
ffffffffc0201274:	00006517          	auipc	a0,0x6
ffffffffc0201278:	aec50513          	addi	a0,a0,-1300 # ffffffffc0206d60 <commands+0x888>
ffffffffc020127c:	a08ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201280:	00006697          	auipc	a3,0x6
ffffffffc0201284:	c2068693          	addi	a3,a3,-992 # ffffffffc0206ea0 <commands+0x9c8>
ffffffffc0201288:	00005617          	auipc	a2,0x5
ffffffffc020128c:	71060613          	addi	a2,a2,1808 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201290:	0c200593          	li	a1,194
ffffffffc0201294:	00006517          	auipc	a0,0x6
ffffffffc0201298:	acc50513          	addi	a0,a0,-1332 # ffffffffc0206d60 <commands+0x888>
ffffffffc020129c:	9e8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != NULL);
ffffffffc02012a0:	00006697          	auipc	a3,0x6
ffffffffc02012a4:	c9068693          	addi	a3,a3,-880 # ffffffffc0206f30 <commands+0xa58>
ffffffffc02012a8:	00005617          	auipc	a2,0x5
ffffffffc02012ac:	6f060613          	addi	a2,a2,1776 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02012b0:	0f800593          	li	a1,248
ffffffffc02012b4:	00006517          	auipc	a0,0x6
ffffffffc02012b8:	aac50513          	addi	a0,a0,-1364 # ffffffffc0206d60 <commands+0x888>
ffffffffc02012bc:	9c8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc02012c0:	00006697          	auipc	a3,0x6
ffffffffc02012c4:	c6068693          	addi	a3,a3,-928 # ffffffffc0206f20 <commands+0xa48>
ffffffffc02012c8:	00005617          	auipc	a2,0x5
ffffffffc02012cc:	6d060613          	addi	a2,a2,1744 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02012d0:	0df00593          	li	a1,223
ffffffffc02012d4:	00006517          	auipc	a0,0x6
ffffffffc02012d8:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0206d60 <commands+0x888>
ffffffffc02012dc:	9a8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012e0:	00006697          	auipc	a3,0x6
ffffffffc02012e4:	be068693          	addi	a3,a3,-1056 # ffffffffc0206ec0 <commands+0x9e8>
ffffffffc02012e8:	00005617          	auipc	a2,0x5
ffffffffc02012ec:	6b060613          	addi	a2,a2,1712 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02012f0:	0dd00593          	li	a1,221
ffffffffc02012f4:	00006517          	auipc	a0,0x6
ffffffffc02012f8:	a6c50513          	addi	a0,a0,-1428 # ffffffffc0206d60 <commands+0x888>
ffffffffc02012fc:	988ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201300:	00006697          	auipc	a3,0x6
ffffffffc0201304:	c0068693          	addi	a3,a3,-1024 # ffffffffc0206f00 <commands+0xa28>
ffffffffc0201308:	00005617          	auipc	a2,0x5
ffffffffc020130c:	69060613          	addi	a2,a2,1680 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201310:	0dc00593          	li	a1,220
ffffffffc0201314:	00006517          	auipc	a0,0x6
ffffffffc0201318:	a4c50513          	addi	a0,a0,-1460 # ffffffffc0206d60 <commands+0x888>
ffffffffc020131c:	968ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201320:	00006697          	auipc	a3,0x6
ffffffffc0201324:	a7868693          	addi	a3,a3,-1416 # ffffffffc0206d98 <commands+0x8c0>
ffffffffc0201328:	00005617          	auipc	a2,0x5
ffffffffc020132c:	67060613          	addi	a2,a2,1648 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201330:	0b900593          	li	a1,185
ffffffffc0201334:	00006517          	auipc	a0,0x6
ffffffffc0201338:	a2c50513          	addi	a0,a0,-1492 # ffffffffc0206d60 <commands+0x888>
ffffffffc020133c:	948ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201340:	00006697          	auipc	a3,0x6
ffffffffc0201344:	b8068693          	addi	a3,a3,-1152 # ffffffffc0206ec0 <commands+0x9e8>
ffffffffc0201348:	00005617          	auipc	a2,0x5
ffffffffc020134c:	65060613          	addi	a2,a2,1616 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201350:	0d600593          	li	a1,214
ffffffffc0201354:	00006517          	auipc	a0,0x6
ffffffffc0201358:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0206d60 <commands+0x888>
ffffffffc020135c:	928ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201360:	00006697          	auipc	a3,0x6
ffffffffc0201364:	a7868693          	addi	a3,a3,-1416 # ffffffffc0206dd8 <commands+0x900>
ffffffffc0201368:	00005617          	auipc	a2,0x5
ffffffffc020136c:	63060613          	addi	a2,a2,1584 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201370:	0d400593          	li	a1,212
ffffffffc0201374:	00006517          	auipc	a0,0x6
ffffffffc0201378:	9ec50513          	addi	a0,a0,-1556 # ffffffffc0206d60 <commands+0x888>
ffffffffc020137c:	908ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201380:	00006697          	auipc	a3,0x6
ffffffffc0201384:	a3868693          	addi	a3,a3,-1480 # ffffffffc0206db8 <commands+0x8e0>
ffffffffc0201388:	00005617          	auipc	a2,0x5
ffffffffc020138c:	61060613          	addi	a2,a2,1552 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201390:	0d300593          	li	a1,211
ffffffffc0201394:	00006517          	auipc	a0,0x6
ffffffffc0201398:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0206d60 <commands+0x888>
ffffffffc020139c:	8e8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013a0:	00006697          	auipc	a3,0x6
ffffffffc02013a4:	a3868693          	addi	a3,a3,-1480 # ffffffffc0206dd8 <commands+0x900>
ffffffffc02013a8:	00005617          	auipc	a2,0x5
ffffffffc02013ac:	5f060613          	addi	a2,a2,1520 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02013b0:	0bb00593          	li	a1,187
ffffffffc02013b4:	00006517          	auipc	a0,0x6
ffffffffc02013b8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0206d60 <commands+0x888>
ffffffffc02013bc:	8c8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(count == 0);
ffffffffc02013c0:	00006697          	auipc	a3,0x6
ffffffffc02013c4:	cc068693          	addi	a3,a3,-832 # ffffffffc0207080 <commands+0xba8>
ffffffffc02013c8:	00005617          	auipc	a2,0x5
ffffffffc02013cc:	5d060613          	addi	a2,a2,1488 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02013d0:	12500593          	li	a1,293
ffffffffc02013d4:	00006517          	auipc	a0,0x6
ffffffffc02013d8:	98c50513          	addi	a0,a0,-1652 # ffffffffc0206d60 <commands+0x888>
ffffffffc02013dc:	8a8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc02013e0:	00006697          	auipc	a3,0x6
ffffffffc02013e4:	b4068693          	addi	a3,a3,-1216 # ffffffffc0206f20 <commands+0xa48>
ffffffffc02013e8:	00005617          	auipc	a2,0x5
ffffffffc02013ec:	5b060613          	addi	a2,a2,1456 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02013f0:	11a00593          	li	a1,282
ffffffffc02013f4:	00006517          	auipc	a0,0x6
ffffffffc02013f8:	96c50513          	addi	a0,a0,-1684 # ffffffffc0206d60 <commands+0x888>
ffffffffc02013fc:	888ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201400:	00006697          	auipc	a3,0x6
ffffffffc0201404:	ac068693          	addi	a3,a3,-1344 # ffffffffc0206ec0 <commands+0x9e8>
ffffffffc0201408:	00005617          	auipc	a2,0x5
ffffffffc020140c:	59060613          	addi	a2,a2,1424 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201410:	11800593          	li	a1,280
ffffffffc0201414:	00006517          	auipc	a0,0x6
ffffffffc0201418:	94c50513          	addi	a0,a0,-1716 # ffffffffc0206d60 <commands+0x888>
ffffffffc020141c:	868ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201420:	00006697          	auipc	a3,0x6
ffffffffc0201424:	a6068693          	addi	a3,a3,-1440 # ffffffffc0206e80 <commands+0x9a8>
ffffffffc0201428:	00005617          	auipc	a2,0x5
ffffffffc020142c:	57060613          	addi	a2,a2,1392 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201430:	0c100593          	li	a1,193
ffffffffc0201434:	00006517          	auipc	a0,0x6
ffffffffc0201438:	92c50513          	addi	a0,a0,-1748 # ffffffffc0206d60 <commands+0x888>
ffffffffc020143c:	848ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201440:	00006697          	auipc	a3,0x6
ffffffffc0201444:	c0068693          	addi	a3,a3,-1024 # ffffffffc0207040 <commands+0xb68>
ffffffffc0201448:	00005617          	auipc	a2,0x5
ffffffffc020144c:	55060613          	addi	a2,a2,1360 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201450:	11200593          	li	a1,274
ffffffffc0201454:	00006517          	auipc	a0,0x6
ffffffffc0201458:	90c50513          	addi	a0,a0,-1780 # ffffffffc0206d60 <commands+0x888>
ffffffffc020145c:	828ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201460:	00006697          	auipc	a3,0x6
ffffffffc0201464:	bc068693          	addi	a3,a3,-1088 # ffffffffc0207020 <commands+0xb48>
ffffffffc0201468:	00005617          	auipc	a2,0x5
ffffffffc020146c:	53060613          	addi	a2,a2,1328 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201470:	11000593          	li	a1,272
ffffffffc0201474:	00006517          	auipc	a0,0x6
ffffffffc0201478:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0206d60 <commands+0x888>
ffffffffc020147c:	808ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201480:	00006697          	auipc	a3,0x6
ffffffffc0201484:	b7868693          	addi	a3,a3,-1160 # ffffffffc0206ff8 <commands+0xb20>
ffffffffc0201488:	00005617          	auipc	a2,0x5
ffffffffc020148c:	51060613          	addi	a2,a2,1296 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201490:	10e00593          	li	a1,270
ffffffffc0201494:	00006517          	auipc	a0,0x6
ffffffffc0201498:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0206d60 <commands+0x888>
ffffffffc020149c:	fe9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014a0:	00006697          	auipc	a3,0x6
ffffffffc02014a4:	b3068693          	addi	a3,a3,-1232 # ffffffffc0206fd0 <commands+0xaf8>
ffffffffc02014a8:	00005617          	auipc	a2,0x5
ffffffffc02014ac:	4f060613          	addi	a2,a2,1264 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02014b0:	10d00593          	li	a1,269
ffffffffc02014b4:	00006517          	auipc	a0,0x6
ffffffffc02014b8:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0206d60 <commands+0x888>
ffffffffc02014bc:	fc9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014c0:	00006697          	auipc	a3,0x6
ffffffffc02014c4:	b0068693          	addi	a3,a3,-1280 # ffffffffc0206fc0 <commands+0xae8>
ffffffffc02014c8:	00005617          	auipc	a2,0x5
ffffffffc02014cc:	4d060613          	addi	a2,a2,1232 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02014d0:	10800593          	li	a1,264
ffffffffc02014d4:	00006517          	auipc	a0,0x6
ffffffffc02014d8:	88c50513          	addi	a0,a0,-1908 # ffffffffc0206d60 <commands+0x888>
ffffffffc02014dc:	fa9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014e0:	00006697          	auipc	a3,0x6
ffffffffc02014e4:	9e068693          	addi	a3,a3,-1568 # ffffffffc0206ec0 <commands+0x9e8>
ffffffffc02014e8:	00005617          	auipc	a2,0x5
ffffffffc02014ec:	4b060613          	addi	a2,a2,1200 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02014f0:	10700593          	li	a1,263
ffffffffc02014f4:	00006517          	auipc	a0,0x6
ffffffffc02014f8:	86c50513          	addi	a0,a0,-1940 # ffffffffc0206d60 <commands+0x888>
ffffffffc02014fc:	f89fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201500:	00006697          	auipc	a3,0x6
ffffffffc0201504:	aa068693          	addi	a3,a3,-1376 # ffffffffc0206fa0 <commands+0xac8>
ffffffffc0201508:	00005617          	auipc	a2,0x5
ffffffffc020150c:	49060613          	addi	a2,a2,1168 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201510:	10600593          	li	a1,262
ffffffffc0201514:	00006517          	auipc	a0,0x6
ffffffffc0201518:	84c50513          	addi	a0,a0,-1972 # ffffffffc0206d60 <commands+0x888>
ffffffffc020151c:	f69fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201520:	00006697          	auipc	a3,0x6
ffffffffc0201524:	a5068693          	addi	a3,a3,-1456 # ffffffffc0206f70 <commands+0xa98>
ffffffffc0201528:	00005617          	auipc	a2,0x5
ffffffffc020152c:	47060613          	addi	a2,a2,1136 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201530:	10500593          	li	a1,261
ffffffffc0201534:	00006517          	auipc	a0,0x6
ffffffffc0201538:	82c50513          	addi	a0,a0,-2004 # ffffffffc0206d60 <commands+0x888>
ffffffffc020153c:	f49fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201540:	00006697          	auipc	a3,0x6
ffffffffc0201544:	a1868693          	addi	a3,a3,-1512 # ffffffffc0206f58 <commands+0xa80>
ffffffffc0201548:	00005617          	auipc	a2,0x5
ffffffffc020154c:	45060613          	addi	a2,a2,1104 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201550:	10400593          	li	a1,260
ffffffffc0201554:	00006517          	auipc	a0,0x6
ffffffffc0201558:	80c50513          	addi	a0,a0,-2036 # ffffffffc0206d60 <commands+0x888>
ffffffffc020155c:	f29fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201560:	00006697          	auipc	a3,0x6
ffffffffc0201564:	96068693          	addi	a3,a3,-1696 # ffffffffc0206ec0 <commands+0x9e8>
ffffffffc0201568:	00005617          	auipc	a2,0x5
ffffffffc020156c:	43060613          	addi	a2,a2,1072 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201570:	0fe00593          	li	a1,254
ffffffffc0201574:	00005517          	auipc	a0,0x5
ffffffffc0201578:	7ec50513          	addi	a0,a0,2028 # ffffffffc0206d60 <commands+0x888>
ffffffffc020157c:	f09fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201580:	00006697          	auipc	a3,0x6
ffffffffc0201584:	9c068693          	addi	a3,a3,-1600 # ffffffffc0206f40 <commands+0xa68>
ffffffffc0201588:	00005617          	auipc	a2,0x5
ffffffffc020158c:	41060613          	addi	a2,a2,1040 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201590:	0f900593          	li	a1,249
ffffffffc0201594:	00005517          	auipc	a0,0x5
ffffffffc0201598:	7cc50513          	addi	a0,a0,1996 # ffffffffc0206d60 <commands+0x888>
ffffffffc020159c:	ee9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015a0:	00006697          	auipc	a3,0x6
ffffffffc02015a4:	ac068693          	addi	a3,a3,-1344 # ffffffffc0207060 <commands+0xb88>
ffffffffc02015a8:	00005617          	auipc	a2,0x5
ffffffffc02015ac:	3f060613          	addi	a2,a2,1008 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02015b0:	11700593          	li	a1,279
ffffffffc02015b4:	00005517          	auipc	a0,0x5
ffffffffc02015b8:	7ac50513          	addi	a0,a0,1964 # ffffffffc0206d60 <commands+0x888>
ffffffffc02015bc:	ec9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == 0);
ffffffffc02015c0:	00006697          	auipc	a3,0x6
ffffffffc02015c4:	ad068693          	addi	a3,a3,-1328 # ffffffffc0207090 <commands+0xbb8>
ffffffffc02015c8:	00005617          	auipc	a2,0x5
ffffffffc02015cc:	3d060613          	addi	a2,a2,976 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02015d0:	12600593          	li	a1,294
ffffffffc02015d4:	00005517          	auipc	a0,0x5
ffffffffc02015d8:	78c50513          	addi	a0,a0,1932 # ffffffffc0206d60 <commands+0x888>
ffffffffc02015dc:	ea9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015e0:	00005697          	auipc	a3,0x5
ffffffffc02015e4:	79868693          	addi	a3,a3,1944 # ffffffffc0206d78 <commands+0x8a0>
ffffffffc02015e8:	00005617          	auipc	a2,0x5
ffffffffc02015ec:	3b060613          	addi	a2,a2,944 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02015f0:	0f300593          	li	a1,243
ffffffffc02015f4:	00005517          	auipc	a0,0x5
ffffffffc02015f8:	76c50513          	addi	a0,a0,1900 # ffffffffc0206d60 <commands+0x888>
ffffffffc02015fc:	e89fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201600:	00005697          	auipc	a3,0x5
ffffffffc0201604:	7b868693          	addi	a3,a3,1976 # ffffffffc0206db8 <commands+0x8e0>
ffffffffc0201608:	00005617          	auipc	a2,0x5
ffffffffc020160c:	39060613          	addi	a2,a2,912 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201610:	0ba00593          	li	a1,186
ffffffffc0201614:	00005517          	auipc	a0,0x5
ffffffffc0201618:	74c50513          	addi	a0,a0,1868 # ffffffffc0206d60 <commands+0x888>
ffffffffc020161c:	e69fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201620 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201620:	1141                	addi	sp,sp,-16
ffffffffc0201622:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201624:	16058e63          	beqz	a1,ffffffffc02017a0 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201628:	00659693          	slli	a3,a1,0x6
ffffffffc020162c:	96aa                	add	a3,a3,a0
ffffffffc020162e:	02d50d63          	beq	a0,a3,ffffffffc0201668 <default_free_pages+0x48>
ffffffffc0201632:	651c                	ld	a5,8(a0)
ffffffffc0201634:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201636:	14079563          	bnez	a5,ffffffffc0201780 <default_free_pages+0x160>
ffffffffc020163a:	651c                	ld	a5,8(a0)
ffffffffc020163c:	8385                	srli	a5,a5,0x1
ffffffffc020163e:	8b85                	andi	a5,a5,1
ffffffffc0201640:	14079063          	bnez	a5,ffffffffc0201780 <default_free_pages+0x160>
ffffffffc0201644:	87aa                	mv	a5,a0
ffffffffc0201646:	a809                	j	ffffffffc0201658 <default_free_pages+0x38>
ffffffffc0201648:	6798                	ld	a4,8(a5)
ffffffffc020164a:	8b05                	andi	a4,a4,1
ffffffffc020164c:	12071a63          	bnez	a4,ffffffffc0201780 <default_free_pages+0x160>
ffffffffc0201650:	6798                	ld	a4,8(a5)
ffffffffc0201652:	8b09                	andi	a4,a4,2
ffffffffc0201654:	12071663          	bnez	a4,ffffffffc0201780 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201658:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc020165c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201660:	04078793          	addi	a5,a5,64
ffffffffc0201664:	fed792e3          	bne	a5,a3,ffffffffc0201648 <default_free_pages+0x28>
    base->property = n;
ffffffffc0201668:	2581                	sext.w	a1,a1
ffffffffc020166a:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020166c:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201670:	4789                	li	a5,2
ffffffffc0201672:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201676:	000ab697          	auipc	a3,0xab
ffffffffc020167a:	f6268693          	addi	a3,a3,-158 # ffffffffc02ac5d8 <free_area>
ffffffffc020167e:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201680:	669c                	ld	a5,8(a3)
ffffffffc0201682:	9db9                	addw	a1,a1,a4
ffffffffc0201684:	000ab717          	auipc	a4,0xab
ffffffffc0201688:	f6b72223          	sw	a1,-156(a4) # ffffffffc02ac5e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc020168c:	0cd78163          	beq	a5,a3,ffffffffc020174e <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201690:	fe878713          	addi	a4,a5,-24
ffffffffc0201694:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201696:	4801                	li	a6,0
ffffffffc0201698:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc020169c:	00e56a63          	bltu	a0,a4,ffffffffc02016b0 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016a0:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016a2:	04d70f63          	beq	a4,a3,ffffffffc0201700 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016a6:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016a8:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016ac:	fee57ae3          	bleu	a4,a0,ffffffffc02016a0 <default_free_pages+0x80>
ffffffffc02016b0:	00080663          	beqz	a6,ffffffffc02016bc <default_free_pages+0x9c>
ffffffffc02016b4:	000ab817          	auipc	a6,0xab
ffffffffc02016b8:	f2b83223          	sd	a1,-220(a6) # ffffffffc02ac5d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016bc:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016be:	e390                	sd	a2,0(a5)
ffffffffc02016c0:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016c2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016c4:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016c6:	06d58a63          	beq	a1,a3,ffffffffc020173a <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016ca:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016ce:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016d2:	02061793          	slli	a5,a2,0x20
ffffffffc02016d6:	83e9                	srli	a5,a5,0x1a
ffffffffc02016d8:	97ba                	add	a5,a5,a4
ffffffffc02016da:	04f51b63          	bne	a0,a5,ffffffffc0201730 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016de:	491c                	lw	a5,16(a0)
ffffffffc02016e0:	9e3d                	addw	a2,a2,a5
ffffffffc02016e2:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016e6:	57f5                	li	a5,-3
ffffffffc02016e8:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016ec:	01853803          	ld	a6,24(a0)
ffffffffc02016f0:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02016f2:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02016f4:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02016f8:	659c                	ld	a5,8(a1)
ffffffffc02016fa:	01063023          	sd	a6,0(a2)
ffffffffc02016fe:	a815                	j	ffffffffc0201732 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201700:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201702:	f114                	sd	a3,32(a0)
ffffffffc0201704:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201706:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201708:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020170a:	00d70563          	beq	a4,a3,ffffffffc0201714 <default_free_pages+0xf4>
ffffffffc020170e:	4805                	li	a6,1
ffffffffc0201710:	87ba                	mv	a5,a4
ffffffffc0201712:	bf59                	j	ffffffffc02016a8 <default_free_pages+0x88>
ffffffffc0201714:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201716:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201718:	00d78d63          	beq	a5,a3,ffffffffc0201732 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc020171c:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201720:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201724:	02061793          	slli	a5,a2,0x20
ffffffffc0201728:	83e9                	srli	a5,a5,0x1a
ffffffffc020172a:	97ba                	add	a5,a5,a4
ffffffffc020172c:	faf509e3          	beq	a0,a5,ffffffffc02016de <default_free_pages+0xbe>
ffffffffc0201730:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201732:	fe878713          	addi	a4,a5,-24
ffffffffc0201736:	00d78963          	beq	a5,a3,ffffffffc0201748 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020173a:	4910                	lw	a2,16(a0)
ffffffffc020173c:	02061693          	slli	a3,a2,0x20
ffffffffc0201740:	82e9                	srli	a3,a3,0x1a
ffffffffc0201742:	96aa                	add	a3,a3,a0
ffffffffc0201744:	00d70e63          	beq	a4,a3,ffffffffc0201760 <default_free_pages+0x140>
}
ffffffffc0201748:	60a2                	ld	ra,8(sp)
ffffffffc020174a:	0141                	addi	sp,sp,16
ffffffffc020174c:	8082                	ret
ffffffffc020174e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201750:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201754:	e398                	sd	a4,0(a5)
ffffffffc0201756:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201758:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020175a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020175c:	0141                	addi	sp,sp,16
ffffffffc020175e:	8082                	ret
            base->property += p->property;
ffffffffc0201760:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201764:	ff078693          	addi	a3,a5,-16
ffffffffc0201768:	9e39                	addw	a2,a2,a4
ffffffffc020176a:	c910                	sw	a2,16(a0)
ffffffffc020176c:	5775                	li	a4,-3
ffffffffc020176e:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201772:	6398                	ld	a4,0(a5)
ffffffffc0201774:	679c                	ld	a5,8(a5)
}
ffffffffc0201776:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201778:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020177a:	e398                	sd	a4,0(a5)
ffffffffc020177c:	0141                	addi	sp,sp,16
ffffffffc020177e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201780:	00006697          	auipc	a3,0x6
ffffffffc0201784:	92068693          	addi	a3,a3,-1760 # ffffffffc02070a0 <commands+0xbc8>
ffffffffc0201788:	00005617          	auipc	a2,0x5
ffffffffc020178c:	21060613          	addi	a2,a2,528 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201790:	08300593          	li	a1,131
ffffffffc0201794:	00005517          	auipc	a0,0x5
ffffffffc0201798:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206d60 <commands+0x888>
ffffffffc020179c:	ce9fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc02017a0:	00006697          	auipc	a3,0x6
ffffffffc02017a4:	92868693          	addi	a3,a3,-1752 # ffffffffc02070c8 <commands+0xbf0>
ffffffffc02017a8:	00005617          	auipc	a2,0x5
ffffffffc02017ac:	1f060613          	addi	a2,a2,496 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02017b0:	08000593          	li	a1,128
ffffffffc02017b4:	00005517          	auipc	a0,0x5
ffffffffc02017b8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0206d60 <commands+0x888>
ffffffffc02017bc:	cc9fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02017c0 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017c0:	c959                	beqz	a0,ffffffffc0201856 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017c2:	000ab597          	auipc	a1,0xab
ffffffffc02017c6:	e1658593          	addi	a1,a1,-490 # ffffffffc02ac5d8 <free_area>
ffffffffc02017ca:	0105a803          	lw	a6,16(a1)
ffffffffc02017ce:	862a                	mv	a2,a0
ffffffffc02017d0:	02081793          	slli	a5,a6,0x20
ffffffffc02017d4:	9381                	srli	a5,a5,0x20
ffffffffc02017d6:	00a7ee63          	bltu	a5,a0,ffffffffc02017f2 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017da:	87ae                	mv	a5,a1
ffffffffc02017dc:	a801                	j	ffffffffc02017ec <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017de:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017e2:	02071693          	slli	a3,a4,0x20
ffffffffc02017e6:	9281                	srli	a3,a3,0x20
ffffffffc02017e8:	00c6f763          	bleu	a2,a3,ffffffffc02017f6 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02017ec:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02017ee:	feb798e3          	bne	a5,a1,ffffffffc02017de <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02017f2:	4501                	li	a0,0
}
ffffffffc02017f4:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02017f6:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc02017fa:	dd6d                	beqz	a0,ffffffffc02017f4 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02017fc:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201800:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201804:	00060e1b          	sext.w	t3,a2
ffffffffc0201808:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc020180c:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201810:	02d67863          	bleu	a3,a2,ffffffffc0201840 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201814:	061a                	slli	a2,a2,0x6
ffffffffc0201816:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201818:	41c7073b          	subw	a4,a4,t3
ffffffffc020181c:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020181e:	00860693          	addi	a3,a2,8
ffffffffc0201822:	4709                	li	a4,2
ffffffffc0201824:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201828:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020182c:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201830:	0105a803          	lw	a6,16(a1)
ffffffffc0201834:	e314                	sd	a3,0(a4)
ffffffffc0201836:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020183a:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc020183c:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201840:	41c8083b          	subw	a6,a6,t3
ffffffffc0201844:	000ab717          	auipc	a4,0xab
ffffffffc0201848:	db072223          	sw	a6,-604(a4) # ffffffffc02ac5e8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020184c:	5775                	li	a4,-3
ffffffffc020184e:	17c1                	addi	a5,a5,-16
ffffffffc0201850:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201854:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201856:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201858:	00006697          	auipc	a3,0x6
ffffffffc020185c:	87068693          	addi	a3,a3,-1936 # ffffffffc02070c8 <commands+0xbf0>
ffffffffc0201860:	00005617          	auipc	a2,0x5
ffffffffc0201864:	13860613          	addi	a2,a2,312 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201868:	06200593          	li	a1,98
ffffffffc020186c:	00005517          	auipc	a0,0x5
ffffffffc0201870:	4f450513          	addi	a0,a0,1268 # ffffffffc0206d60 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201874:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201876:	c0ffe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020187a <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020187a:	1141                	addi	sp,sp,-16
ffffffffc020187c:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020187e:	c1ed                	beqz	a1,ffffffffc0201960 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201880:	00659693          	slli	a3,a1,0x6
ffffffffc0201884:	96aa                	add	a3,a3,a0
ffffffffc0201886:	02d50463          	beq	a0,a3,ffffffffc02018ae <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020188a:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020188c:	87aa                	mv	a5,a0
ffffffffc020188e:	8b05                	andi	a4,a4,1
ffffffffc0201890:	e709                	bnez	a4,ffffffffc020189a <default_init_memmap+0x20>
ffffffffc0201892:	a07d                	j	ffffffffc0201940 <default_init_memmap+0xc6>
ffffffffc0201894:	6798                	ld	a4,8(a5)
ffffffffc0201896:	8b05                	andi	a4,a4,1
ffffffffc0201898:	c745                	beqz	a4,ffffffffc0201940 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc020189a:	0007a823          	sw	zero,16(a5)
ffffffffc020189e:	0007b423          	sd	zero,8(a5)
ffffffffc02018a2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018a6:	04078793          	addi	a5,a5,64
ffffffffc02018aa:	fed795e3          	bne	a5,a3,ffffffffc0201894 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018ae:	2581                	sext.w	a1,a1
ffffffffc02018b0:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018b2:	4789                	li	a5,2
ffffffffc02018b4:	00850713          	addi	a4,a0,8
ffffffffc02018b8:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018bc:	000ab697          	auipc	a3,0xab
ffffffffc02018c0:	d1c68693          	addi	a3,a3,-740 # ffffffffc02ac5d8 <free_area>
ffffffffc02018c4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018c6:	669c                	ld	a5,8(a3)
ffffffffc02018c8:	9db9                	addw	a1,a1,a4
ffffffffc02018ca:	000ab717          	auipc	a4,0xab
ffffffffc02018ce:	d0b72f23          	sw	a1,-738(a4) # ffffffffc02ac5e8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018d2:	04d78a63          	beq	a5,a3,ffffffffc0201926 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018d6:	fe878713          	addi	a4,a5,-24
ffffffffc02018da:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018dc:	4801                	li	a6,0
ffffffffc02018de:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018e2:	00e56a63          	bltu	a0,a4,ffffffffc02018f6 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018e6:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018e8:	02d70563          	beq	a4,a3,ffffffffc0201912 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018ec:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018ee:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02018f2:	fee57ae3          	bleu	a4,a0,ffffffffc02018e6 <default_init_memmap+0x6c>
ffffffffc02018f6:	00080663          	beqz	a6,ffffffffc0201902 <default_init_memmap+0x88>
ffffffffc02018fa:	000ab717          	auipc	a4,0xab
ffffffffc02018fe:	ccb73f23          	sd	a1,-802(a4) # ffffffffc02ac5d8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201902:	6398                	ld	a4,0(a5)
}
ffffffffc0201904:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201906:	e390                	sd	a2,0(a5)
ffffffffc0201908:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020190a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020190c:	ed18                	sd	a4,24(a0)
ffffffffc020190e:	0141                	addi	sp,sp,16
ffffffffc0201910:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201912:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201914:	f114                	sd	a3,32(a0)
ffffffffc0201916:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201918:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020191a:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020191c:	00d70e63          	beq	a4,a3,ffffffffc0201938 <default_init_memmap+0xbe>
ffffffffc0201920:	4805                	li	a6,1
ffffffffc0201922:	87ba                	mv	a5,a4
ffffffffc0201924:	b7e9                	j	ffffffffc02018ee <default_init_memmap+0x74>
}
ffffffffc0201926:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201928:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020192c:	e398                	sd	a4,0(a5)
ffffffffc020192e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201930:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201932:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201934:	0141                	addi	sp,sp,16
ffffffffc0201936:	8082                	ret
ffffffffc0201938:	60a2                	ld	ra,8(sp)
ffffffffc020193a:	e290                	sd	a2,0(a3)
ffffffffc020193c:	0141                	addi	sp,sp,16
ffffffffc020193e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201940:	00005697          	auipc	a3,0x5
ffffffffc0201944:	79068693          	addi	a3,a3,1936 # ffffffffc02070d0 <commands+0xbf8>
ffffffffc0201948:	00005617          	auipc	a2,0x5
ffffffffc020194c:	05060613          	addi	a2,a2,80 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201950:	04900593          	li	a1,73
ffffffffc0201954:	00005517          	auipc	a0,0x5
ffffffffc0201958:	40c50513          	addi	a0,a0,1036 # ffffffffc0206d60 <commands+0x888>
ffffffffc020195c:	b29fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc0201960:	00005697          	auipc	a3,0x5
ffffffffc0201964:	76868693          	addi	a3,a3,1896 # ffffffffc02070c8 <commands+0xbf0>
ffffffffc0201968:	00005617          	auipc	a2,0x5
ffffffffc020196c:	03060613          	addi	a2,a2,48 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201970:	04600593          	li	a1,70
ffffffffc0201974:	00005517          	auipc	a0,0x5
ffffffffc0201978:	3ec50513          	addi	a0,a0,1004 # ffffffffc0206d60 <commands+0x888>
ffffffffc020197c:	b09fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201980 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201980:	c125                	beqz	a0,ffffffffc02019e0 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201982:	e1a5                	bnez	a1,ffffffffc02019e2 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201984:	100027f3          	csrr	a5,sstatus
ffffffffc0201988:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020198a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020198c:	e3bd                	bnez	a5,ffffffffc02019f2 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020198e:	0009f797          	auipc	a5,0x9f
ffffffffc0201992:	7da78793          	addi	a5,a5,2010 # ffffffffc02a1168 <slobfree>
ffffffffc0201996:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201998:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020199a:	00a7fa63          	bleu	a0,a5,ffffffffc02019ae <slob_free+0x2e>
ffffffffc020199e:	00e56c63          	bltu	a0,a4,ffffffffc02019b6 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019a2:	00e7fa63          	bleu	a4,a5,ffffffffc02019b6 <slob_free+0x36>
    return 0;
ffffffffc02019a6:	87ba                	mv	a5,a4
ffffffffc02019a8:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019aa:	fea7eae3          	bltu	a5,a0,ffffffffc020199e <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ae:	fee7ece3          	bltu	a5,a4,ffffffffc02019a6 <slob_free+0x26>
ffffffffc02019b2:	fee57ae3          	bleu	a4,a0,ffffffffc02019a6 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019b6:	4110                	lw	a2,0(a0)
ffffffffc02019b8:	00461693          	slli	a3,a2,0x4
ffffffffc02019bc:	96aa                	add	a3,a3,a0
ffffffffc02019be:	08d70b63          	beq	a4,a3,ffffffffc0201a54 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019c2:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019c4:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019c6:	00469713          	slli	a4,a3,0x4
ffffffffc02019ca:	973e                	add	a4,a4,a5
ffffffffc02019cc:	08e50f63          	beq	a0,a4,ffffffffc0201a6a <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019d0:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019d2:	0009f717          	auipc	a4,0x9f
ffffffffc02019d6:	78f73b23          	sd	a5,1942(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc02019da:	c199                	beqz	a1,ffffffffc02019e0 <slob_free+0x60>
        intr_enable();
ffffffffc02019dc:	c55fe06f          	j	ffffffffc0200630 <intr_enable>
ffffffffc02019e0:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019e2:	05bd                	addi	a1,a1,15
ffffffffc02019e4:	8191                	srli	a1,a1,0x4
ffffffffc02019e6:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019e8:	100027f3          	csrr	a5,sstatus
ffffffffc02019ec:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019ee:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019f0:	dfd9                	beqz	a5,ffffffffc020198e <slob_free+0xe>
{
ffffffffc02019f2:	1101                	addi	sp,sp,-32
ffffffffc02019f4:	e42a                	sd	a0,8(sp)
ffffffffc02019f6:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02019f8:	c3ffe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019fc:	0009f797          	auipc	a5,0x9f
ffffffffc0201a00:	76c78793          	addi	a5,a5,1900 # ffffffffc02a1168 <slobfree>
ffffffffc0201a04:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a06:	6522                	ld	a0,8(sp)
ffffffffc0201a08:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a0a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a0c:	00a7fa63          	bleu	a0,a5,ffffffffc0201a20 <slob_free+0xa0>
ffffffffc0201a10:	00e56c63          	bltu	a0,a4,ffffffffc0201a28 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a14:	00e7fa63          	bleu	a4,a5,ffffffffc0201a28 <slob_free+0xa8>
    return 0;
ffffffffc0201a18:	87ba                	mv	a5,a4
ffffffffc0201a1a:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a1c:	fea7eae3          	bltu	a5,a0,ffffffffc0201a10 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a20:	fee7ece3          	bltu	a5,a4,ffffffffc0201a18 <slob_free+0x98>
ffffffffc0201a24:	fee57ae3          	bleu	a4,a0,ffffffffc0201a18 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a28:	4110                	lw	a2,0(a0)
ffffffffc0201a2a:	00461693          	slli	a3,a2,0x4
ffffffffc0201a2e:	96aa                	add	a3,a3,a0
ffffffffc0201a30:	04d70763          	beq	a4,a3,ffffffffc0201a7e <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a34:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a36:	4394                	lw	a3,0(a5)
ffffffffc0201a38:	00469713          	slli	a4,a3,0x4
ffffffffc0201a3c:	973e                	add	a4,a4,a5
ffffffffc0201a3e:	04e50663          	beq	a0,a4,ffffffffc0201a8a <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a42:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a44:	0009f717          	auipc	a4,0x9f
ffffffffc0201a48:	72f73223          	sd	a5,1828(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc0201a4c:	e58d                	bnez	a1,ffffffffc0201a76 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a4e:	60e2                	ld	ra,24(sp)
ffffffffc0201a50:	6105                	addi	sp,sp,32
ffffffffc0201a52:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a54:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a56:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a58:	9e35                	addw	a2,a2,a3
ffffffffc0201a5a:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a5c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a5e:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a60:	00469713          	slli	a4,a3,0x4
ffffffffc0201a64:	973e                	add	a4,a4,a5
ffffffffc0201a66:	f6e515e3          	bne	a0,a4,ffffffffc02019d0 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a6a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a6c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a6e:	9eb9                	addw	a3,a3,a4
ffffffffc0201a70:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a72:	e790                	sd	a2,8(a5)
ffffffffc0201a74:	bfb9                	j	ffffffffc02019d2 <slob_free+0x52>
}
ffffffffc0201a76:	60e2                	ld	ra,24(sp)
ffffffffc0201a78:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a7a:	bb7fe06f          	j	ffffffffc0200630 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a7e:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a80:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a82:	9e35                	addw	a2,a2,a3
ffffffffc0201a84:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a86:	e518                	sd	a4,8(a0)
ffffffffc0201a88:	b77d                	j	ffffffffc0201a36 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a8a:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a8c:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a8e:	9eb9                	addw	a3,a3,a4
ffffffffc0201a90:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a92:	e790                	sd	a2,8(a5)
ffffffffc0201a94:	bf45                	j	ffffffffc0201a44 <slob_free+0xc4>

ffffffffc0201a96 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201a96:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a98:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201a9a:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a9e:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aa0:	38e000ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
  if(!page)
ffffffffc0201aa4:	c139                	beqz	a0,ffffffffc0201aea <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aa6:	000ab797          	auipc	a5,0xab
ffffffffc0201aaa:	b6278793          	addi	a5,a5,-1182 # ffffffffc02ac608 <pages>
ffffffffc0201aae:	6394                	ld	a3,0(a5)
ffffffffc0201ab0:	00007797          	auipc	a5,0x7
ffffffffc0201ab4:	f4878793          	addi	a5,a5,-184 # ffffffffc02089f8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201ab8:	000ab717          	auipc	a4,0xab
ffffffffc0201abc:	ae070713          	addi	a4,a4,-1312 # ffffffffc02ac598 <npage>
    return page - pages + nbase;
ffffffffc0201ac0:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ac4:	6388                	ld	a0,0(a5)
ffffffffc0201ac6:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201ac8:	57fd                	li	a5,-1
ffffffffc0201aca:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201acc:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201ace:	83b1                	srli	a5,a5,0xc
ffffffffc0201ad0:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ad2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ad4:	00e7ff63          	bleu	a4,a5,ffffffffc0201af2 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201ad8:	000ab797          	auipc	a5,0xab
ffffffffc0201adc:	b2078793          	addi	a5,a5,-1248 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0201ae0:	6388                	ld	a0,0(a5)
}
ffffffffc0201ae2:	60a2                	ld	ra,8(sp)
ffffffffc0201ae4:	9536                	add	a0,a0,a3
ffffffffc0201ae6:	0141                	addi	sp,sp,16
ffffffffc0201ae8:	8082                	ret
ffffffffc0201aea:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201aec:	4501                	li	a0,0
}
ffffffffc0201aee:	0141                	addi	sp,sp,16
ffffffffc0201af0:	8082                	ret
ffffffffc0201af2:	00005617          	auipc	a2,0x5
ffffffffc0201af6:	63e60613          	addi	a2,a2,1598 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0201afa:	06900593          	li	a1,105
ffffffffc0201afe:	00005517          	auipc	a0,0x5
ffffffffc0201b02:	65a50513          	addi	a0,a0,1626 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0201b06:	97ffe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201b0a <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b0a:	7179                	addi	sp,sp,-48
ffffffffc0201b0c:	f406                	sd	ra,40(sp)
ffffffffc0201b0e:	f022                	sd	s0,32(sp)
ffffffffc0201b10:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b12:	01050713          	addi	a4,a0,16
ffffffffc0201b16:	6785                	lui	a5,0x1
ffffffffc0201b18:	0cf77b63          	bleu	a5,a4,ffffffffc0201bee <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b1c:	00f50413          	addi	s0,a0,15
ffffffffc0201b20:	8011                	srli	s0,s0,0x4
ffffffffc0201b22:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b24:	10002673          	csrr	a2,sstatus
ffffffffc0201b28:	8a09                	andi	a2,a2,2
ffffffffc0201b2a:	ea5d                	bnez	a2,ffffffffc0201be0 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b2c:	0009f497          	auipc	s1,0x9f
ffffffffc0201b30:	63c48493          	addi	s1,s1,1596 # ffffffffc02a1168 <slobfree>
ffffffffc0201b34:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b36:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b38:	4398                	lw	a4,0(a5)
ffffffffc0201b3a:	0a875763          	ble	s0,a4,ffffffffc0201be8 <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b3e:	00f68a63          	beq	a3,a5,ffffffffc0201b52 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b42:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b44:	4118                	lw	a4,0(a0)
ffffffffc0201b46:	02875763          	ble	s0,a4,ffffffffc0201b74 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b4a:	6094                	ld	a3,0(s1)
ffffffffc0201b4c:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b4e:	fef69ae3          	bne	a3,a5,ffffffffc0201b42 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b52:	ea39                	bnez	a2,ffffffffc0201ba8 <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b54:	4501                	li	a0,0
ffffffffc0201b56:	f41ff0ef          	jal	ra,ffffffffc0201a96 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b5a:	cd29                	beqz	a0,ffffffffc0201bb4 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b5c:	6585                	lui	a1,0x1
ffffffffc0201b5e:	e23ff0ef          	jal	ra,ffffffffc0201980 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b62:	10002673          	csrr	a2,sstatus
ffffffffc0201b66:	8a09                	andi	a2,a2,2
ffffffffc0201b68:	ea1d                	bnez	a2,ffffffffc0201b9e <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b6a:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b6c:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b6e:	4118                	lw	a4,0(a0)
ffffffffc0201b70:	fc874de3          	blt	a4,s0,ffffffffc0201b4a <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b74:	04e40663          	beq	s0,a4,ffffffffc0201bc0 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b78:	00441693          	slli	a3,s0,0x4
ffffffffc0201b7c:	96aa                	add	a3,a3,a0
ffffffffc0201b7e:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b80:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201b82:	9f01                	subw	a4,a4,s0
ffffffffc0201b84:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b86:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b88:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201b8a:	0009f717          	auipc	a4,0x9f
ffffffffc0201b8e:	5cf73f23          	sd	a5,1502(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc0201b92:	ee15                	bnez	a2,ffffffffc0201bce <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201b94:	70a2                	ld	ra,40(sp)
ffffffffc0201b96:	7402                	ld	s0,32(sp)
ffffffffc0201b98:	64e2                	ld	s1,24(sp)
ffffffffc0201b9a:	6145                	addi	sp,sp,48
ffffffffc0201b9c:	8082                	ret
        intr_disable();
ffffffffc0201b9e:	a99fe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
ffffffffc0201ba2:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201ba4:	609c                	ld	a5,0(s1)
ffffffffc0201ba6:	b7d9                	j	ffffffffc0201b6c <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201ba8:	a89fe0ef          	jal	ra,ffffffffc0200630 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bac:	4501                	li	a0,0
ffffffffc0201bae:	ee9ff0ef          	jal	ra,ffffffffc0201a96 <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bb2:	f54d                	bnez	a0,ffffffffc0201b5c <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bb4:	70a2                	ld	ra,40(sp)
ffffffffc0201bb6:	7402                	ld	s0,32(sp)
ffffffffc0201bb8:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bba:	4501                	li	a0,0
}
ffffffffc0201bbc:	6145                	addi	sp,sp,48
ffffffffc0201bbe:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bc0:	6518                	ld	a4,8(a0)
ffffffffc0201bc2:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201bc4:	0009f717          	auipc	a4,0x9f
ffffffffc0201bc8:	5af73223          	sd	a5,1444(a4) # ffffffffc02a1168 <slobfree>
    if (flag) {
ffffffffc0201bcc:	d661                	beqz	a2,ffffffffc0201b94 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201bce:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bd0:	a61fe0ef          	jal	ra,ffffffffc0200630 <intr_enable>
}
ffffffffc0201bd4:	70a2                	ld	ra,40(sp)
ffffffffc0201bd6:	7402                	ld	s0,32(sp)
ffffffffc0201bd8:	6522                	ld	a0,8(sp)
ffffffffc0201bda:	64e2                	ld	s1,24(sp)
ffffffffc0201bdc:	6145                	addi	sp,sp,48
ffffffffc0201bde:	8082                	ret
        intr_disable();
ffffffffc0201be0:	a57fe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
ffffffffc0201be4:	4605                	li	a2,1
ffffffffc0201be6:	b799                	j	ffffffffc0201b2c <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201be8:	853e                	mv	a0,a5
ffffffffc0201bea:	87b6                	mv	a5,a3
ffffffffc0201bec:	b761                	j	ffffffffc0201b74 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201bee:	00005697          	auipc	a3,0x5
ffffffffc0201bf2:	5e268693          	addi	a3,a3,1506 # ffffffffc02071d0 <default_pmm_manager+0xf0>
ffffffffc0201bf6:	00005617          	auipc	a2,0x5
ffffffffc0201bfa:	da260613          	addi	a2,a2,-606 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0201bfe:	06400593          	li	a1,100
ffffffffc0201c02:	00005517          	auipc	a0,0x5
ffffffffc0201c06:	5ee50513          	addi	a0,a0,1518 # ffffffffc02071f0 <default_pmm_manager+0x110>
ffffffffc0201c0a:	87bfe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201c0e <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c0e:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c10:	00005517          	auipc	a0,0x5
ffffffffc0201c14:	5f850513          	addi	a0,a0,1528 # ffffffffc0207208 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c18:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c1a:	d74fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c1e:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c20:	00005517          	auipc	a0,0x5
ffffffffc0201c24:	59050513          	addi	a0,a0,1424 # ffffffffc02071b0 <default_pmm_manager+0xd0>
}
ffffffffc0201c28:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c2a:	d64fe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c2e <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c2e:	4501                	li	a0,0
ffffffffc0201c30:	8082                	ret

ffffffffc0201c32 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c32:	1101                	addi	sp,sp,-32
ffffffffc0201c34:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c36:	6905                	lui	s2,0x1
{
ffffffffc0201c38:	e822                	sd	s0,16(sp)
ffffffffc0201c3a:	ec06                	sd	ra,24(sp)
ffffffffc0201c3c:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c3e:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85a1>
{
ffffffffc0201c42:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c44:	04a7fc63          	bleu	a0,a5,ffffffffc0201c9c <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c48:	4561                	li	a0,24
ffffffffc0201c4a:	ec1ff0ef          	jal	ra,ffffffffc0201b0a <slob_alloc.isra.1.constprop.3>
ffffffffc0201c4e:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c50:	cd21                	beqz	a0,ffffffffc0201ca8 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c52:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c56:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c58:	00f95763          	ble	a5,s2,ffffffffc0201c66 <kmalloc+0x34>
ffffffffc0201c5c:	6705                	lui	a4,0x1
ffffffffc0201c5e:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c60:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c62:	fef74ee3          	blt	a4,a5,ffffffffc0201c5e <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c66:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c68:	e2fff0ef          	jal	ra,ffffffffc0201a96 <__slob_get_free_pages.isra.0>
ffffffffc0201c6c:	e488                	sd	a0,8(s1)
ffffffffc0201c6e:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c70:	c935                	beqz	a0,ffffffffc0201ce4 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c72:	100027f3          	csrr	a5,sstatus
ffffffffc0201c76:	8b89                	andi	a5,a5,2
ffffffffc0201c78:	e3a1                	bnez	a5,ffffffffc0201cb8 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c7a:	000ab797          	auipc	a5,0xab
ffffffffc0201c7e:	90e78793          	addi	a5,a5,-1778 # ffffffffc02ac588 <bigblocks>
ffffffffc0201c82:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c84:	000ab717          	auipc	a4,0xab
ffffffffc0201c88:	90973223          	sd	s1,-1788(a4) # ffffffffc02ac588 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c8c:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201c8e:	8522                	mv	a0,s0
ffffffffc0201c90:	60e2                	ld	ra,24(sp)
ffffffffc0201c92:	6442                	ld	s0,16(sp)
ffffffffc0201c94:	64a2                	ld	s1,8(sp)
ffffffffc0201c96:	6902                	ld	s2,0(sp)
ffffffffc0201c98:	6105                	addi	sp,sp,32
ffffffffc0201c9a:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c9c:	0541                	addi	a0,a0,16
ffffffffc0201c9e:	e6dff0ef          	jal	ra,ffffffffc0201b0a <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201ca2:	01050413          	addi	s0,a0,16
ffffffffc0201ca6:	f565                	bnez	a0,ffffffffc0201c8e <kmalloc+0x5c>
ffffffffc0201ca8:	4401                	li	s0,0
}
ffffffffc0201caa:	8522                	mv	a0,s0
ffffffffc0201cac:	60e2                	ld	ra,24(sp)
ffffffffc0201cae:	6442                	ld	s0,16(sp)
ffffffffc0201cb0:	64a2                	ld	s1,8(sp)
ffffffffc0201cb2:	6902                	ld	s2,0(sp)
ffffffffc0201cb4:	6105                	addi	sp,sp,32
ffffffffc0201cb6:	8082                	ret
        intr_disable();
ffffffffc0201cb8:	97ffe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cbc:	000ab797          	auipc	a5,0xab
ffffffffc0201cc0:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02ac588 <bigblocks>
ffffffffc0201cc4:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cc6:	000ab717          	auipc	a4,0xab
ffffffffc0201cca:	8c973123          	sd	s1,-1854(a4) # ffffffffc02ac588 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cce:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cd0:	961fe0ef          	jal	ra,ffffffffc0200630 <intr_enable>
ffffffffc0201cd4:	6480                	ld	s0,8(s1)
}
ffffffffc0201cd6:	60e2                	ld	ra,24(sp)
ffffffffc0201cd8:	64a2                	ld	s1,8(sp)
ffffffffc0201cda:	8522                	mv	a0,s0
ffffffffc0201cdc:	6442                	ld	s0,16(sp)
ffffffffc0201cde:	6902                	ld	s2,0(sp)
ffffffffc0201ce0:	6105                	addi	sp,sp,32
ffffffffc0201ce2:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ce4:	45e1                	li	a1,24
ffffffffc0201ce6:	8526                	mv	a0,s1
ffffffffc0201ce8:	c99ff0ef          	jal	ra,ffffffffc0201980 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201cec:	b74d                	j	ffffffffc0201c8e <kmalloc+0x5c>

ffffffffc0201cee <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201cee:	c175                	beqz	a0,ffffffffc0201dd2 <kfree+0xe4>
{
ffffffffc0201cf0:	1101                	addi	sp,sp,-32
ffffffffc0201cf2:	e426                	sd	s1,8(sp)
ffffffffc0201cf4:	ec06                	sd	ra,24(sp)
ffffffffc0201cf6:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201cf8:	03451793          	slli	a5,a0,0x34
ffffffffc0201cfc:	84aa                	mv	s1,a0
ffffffffc0201cfe:	eb8d                	bnez	a5,ffffffffc0201d30 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d00:	100027f3          	csrr	a5,sstatus
ffffffffc0201d04:	8b89                	andi	a5,a5,2
ffffffffc0201d06:	efc9                	bnez	a5,ffffffffc0201da0 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d08:	000ab797          	auipc	a5,0xab
ffffffffc0201d0c:	88078793          	addi	a5,a5,-1920 # ffffffffc02ac588 <bigblocks>
ffffffffc0201d10:	6394                	ld	a3,0(a5)
ffffffffc0201d12:	ce99                	beqz	a3,ffffffffc0201d30 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d14:	669c                	ld	a5,8(a3)
ffffffffc0201d16:	6a80                	ld	s0,16(a3)
ffffffffc0201d18:	0af50e63          	beq	a0,a5,ffffffffc0201dd4 <kfree+0xe6>
    return 0;
ffffffffc0201d1c:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d1e:	c801                	beqz	s0,ffffffffc0201d2e <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d20:	6418                	ld	a4,8(s0)
ffffffffc0201d22:	681c                	ld	a5,16(s0)
ffffffffc0201d24:	00970f63          	beq	a4,s1,ffffffffc0201d42 <kfree+0x54>
ffffffffc0201d28:	86a2                	mv	a3,s0
ffffffffc0201d2a:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d2c:	f875                	bnez	s0,ffffffffc0201d20 <kfree+0x32>
    if (flag) {
ffffffffc0201d2e:	e659                	bnez	a2,ffffffffc0201dbc <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d30:	6442                	ld	s0,16(sp)
ffffffffc0201d32:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d34:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d38:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d3a:	4581                	li	a1,0
}
ffffffffc0201d3c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d3e:	c43ff06f          	j	ffffffffc0201980 <slob_free>
				*last = bb->next;
ffffffffc0201d42:	ea9c                	sd	a5,16(a3)
ffffffffc0201d44:	e641                	bnez	a2,ffffffffc0201dcc <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d46:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d4a:	4018                	lw	a4,0(s0)
ffffffffc0201d4c:	08f4ea63          	bltu	s1,a5,ffffffffc0201de0 <kfree+0xf2>
ffffffffc0201d50:	000ab797          	auipc	a5,0xab
ffffffffc0201d54:	8a878793          	addi	a5,a5,-1880 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0201d58:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d5a:	000ab797          	auipc	a5,0xab
ffffffffc0201d5e:	83e78793          	addi	a5,a5,-1986 # ffffffffc02ac598 <npage>
ffffffffc0201d62:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d64:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d66:	80b1                	srli	s1,s1,0xc
ffffffffc0201d68:	08f4f963          	bleu	a5,s1,ffffffffc0201dfa <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d6c:	00007797          	auipc	a5,0x7
ffffffffc0201d70:	c8c78793          	addi	a5,a5,-884 # ffffffffc02089f8 <nbase>
ffffffffc0201d74:	639c                	ld	a5,0(a5)
ffffffffc0201d76:	000ab697          	auipc	a3,0xab
ffffffffc0201d7a:	89268693          	addi	a3,a3,-1902 # ffffffffc02ac608 <pages>
ffffffffc0201d7e:	6288                	ld	a0,0(a3)
ffffffffc0201d80:	8c9d                	sub	s1,s1,a5
ffffffffc0201d82:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d84:	4585                	li	a1,1
ffffffffc0201d86:	9526                	add	a0,a0,s1
ffffffffc0201d88:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d8c:	12a000ef          	jal	ra,ffffffffc0201eb6 <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d90:	8522                	mv	a0,s0
}
ffffffffc0201d92:	6442                	ld	s0,16(sp)
ffffffffc0201d94:	60e2                	ld	ra,24(sp)
ffffffffc0201d96:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d98:	45e1                	li	a1,24
}
ffffffffc0201d9a:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d9c:	be5ff06f          	j	ffffffffc0201980 <slob_free>
        intr_disable();
ffffffffc0201da0:	897fe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201da4:	000aa797          	auipc	a5,0xaa
ffffffffc0201da8:	7e478793          	addi	a5,a5,2020 # ffffffffc02ac588 <bigblocks>
ffffffffc0201dac:	6394                	ld	a3,0(a5)
ffffffffc0201dae:	c699                	beqz	a3,ffffffffc0201dbc <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201db0:	669c                	ld	a5,8(a3)
ffffffffc0201db2:	6a80                	ld	s0,16(a3)
ffffffffc0201db4:	00f48763          	beq	s1,a5,ffffffffc0201dc2 <kfree+0xd4>
        return 1;
ffffffffc0201db8:	4605                	li	a2,1
ffffffffc0201dba:	b795                	j	ffffffffc0201d1e <kfree+0x30>
        intr_enable();
ffffffffc0201dbc:	875fe0ef          	jal	ra,ffffffffc0200630 <intr_enable>
ffffffffc0201dc0:	bf85                	j	ffffffffc0201d30 <kfree+0x42>
				*last = bb->next;
ffffffffc0201dc2:	000aa797          	auipc	a5,0xaa
ffffffffc0201dc6:	7c87b323          	sd	s0,1990(a5) # ffffffffc02ac588 <bigblocks>
ffffffffc0201dca:	8436                	mv	s0,a3
ffffffffc0201dcc:	865fe0ef          	jal	ra,ffffffffc0200630 <intr_enable>
ffffffffc0201dd0:	bf9d                	j	ffffffffc0201d46 <kfree+0x58>
ffffffffc0201dd2:	8082                	ret
ffffffffc0201dd4:	000aa797          	auipc	a5,0xaa
ffffffffc0201dd8:	7a87ba23          	sd	s0,1972(a5) # ffffffffc02ac588 <bigblocks>
ffffffffc0201ddc:	8436                	mv	s0,a3
ffffffffc0201dde:	b7a5                	j	ffffffffc0201d46 <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201de0:	86a6                	mv	a3,s1
ffffffffc0201de2:	00005617          	auipc	a2,0x5
ffffffffc0201de6:	38660613          	addi	a2,a2,902 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc0201dea:	06e00593          	li	a1,110
ffffffffc0201dee:	00005517          	auipc	a0,0x5
ffffffffc0201df2:	36a50513          	addi	a0,a0,874 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0201df6:	e8efe0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201dfa:	00005617          	auipc	a2,0x5
ffffffffc0201dfe:	39660613          	addi	a2,a2,918 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc0201e02:	06200593          	li	a1,98
ffffffffc0201e06:	00005517          	auipc	a0,0x5
ffffffffc0201e0a:	35250513          	addi	a0,a0,850 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0201e0e:	e76fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e12 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e12:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e14:	00005617          	auipc	a2,0x5
ffffffffc0201e18:	37c60613          	addi	a2,a2,892 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc0201e1c:	06200593          	li	a1,98
ffffffffc0201e20:	00005517          	auipc	a0,0x5
ffffffffc0201e24:	33850513          	addi	a0,a0,824 # ffffffffc0207158 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e28:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e2a:	e5afe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201e2e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e2e:	715d                	addi	sp,sp,-80
ffffffffc0201e30:	e0a2                	sd	s0,64(sp)
ffffffffc0201e32:	fc26                	sd	s1,56(sp)
ffffffffc0201e34:	f84a                	sd	s2,48(sp)
ffffffffc0201e36:	f44e                	sd	s3,40(sp)
ffffffffc0201e38:	f052                	sd	s4,32(sp)
ffffffffc0201e3a:	ec56                	sd	s5,24(sp)
ffffffffc0201e3c:	e486                	sd	ra,72(sp)
ffffffffc0201e3e:	842a                	mv	s0,a0
ffffffffc0201e40:	000aa497          	auipc	s1,0xaa
ffffffffc0201e44:	7b048493          	addi	s1,s1,1968 # ffffffffc02ac5f0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e48:	4985                	li	s3,1
ffffffffc0201e4a:	000aaa17          	auipc	s4,0xaa
ffffffffc0201e4e:	75ea0a13          	addi	s4,s4,1886 # ffffffffc02ac5a8 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e52:	0005091b          	sext.w	s2,a0
ffffffffc0201e56:	000aba97          	auipc	s5,0xab
ffffffffc0201e5a:	892a8a93          	addi	s5,s5,-1902 # ffffffffc02ac6e8 <check_mm_struct>
ffffffffc0201e5e:	a00d                	j	ffffffffc0201e80 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e60:	609c                	ld	a5,0(s1)
ffffffffc0201e62:	6f9c                	ld	a5,24(a5)
ffffffffc0201e64:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e66:	4601                	li	a2,0
ffffffffc0201e68:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e6a:	ed0d                	bnez	a0,ffffffffc0201ea4 <alloc_pages+0x76>
ffffffffc0201e6c:	0289ec63          	bltu	s3,s0,ffffffffc0201ea4 <alloc_pages+0x76>
ffffffffc0201e70:	000a2783          	lw	a5,0(s4)
ffffffffc0201e74:	2781                	sext.w	a5,a5
ffffffffc0201e76:	c79d                	beqz	a5,ffffffffc0201ea4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e78:	000ab503          	ld	a0,0(s5)
ffffffffc0201e7c:	47d010ef          	jal	ra,ffffffffc0203af8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e80:	100027f3          	csrr	a5,sstatus
ffffffffc0201e84:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e86:	8522                	mv	a0,s0
ffffffffc0201e88:	dfe1                	beqz	a5,ffffffffc0201e60 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e8a:	facfe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
ffffffffc0201e8e:	609c                	ld	a5,0(s1)
ffffffffc0201e90:	8522                	mv	a0,s0
ffffffffc0201e92:	6f9c                	ld	a5,24(a5)
ffffffffc0201e94:	9782                	jalr	a5
ffffffffc0201e96:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e98:	f98fe0ef          	jal	ra,ffffffffc0200630 <intr_enable>
ffffffffc0201e9c:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e9e:	4601                	li	a2,0
ffffffffc0201ea0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201ea2:	d569                	beqz	a0,ffffffffc0201e6c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201ea4:	60a6                	ld	ra,72(sp)
ffffffffc0201ea6:	6406                	ld	s0,64(sp)
ffffffffc0201ea8:	74e2                	ld	s1,56(sp)
ffffffffc0201eaa:	7942                	ld	s2,48(sp)
ffffffffc0201eac:	79a2                	ld	s3,40(sp)
ffffffffc0201eae:	7a02                	ld	s4,32(sp)
ffffffffc0201eb0:	6ae2                	ld	s5,24(sp)
ffffffffc0201eb2:	6161                	addi	sp,sp,80
ffffffffc0201eb4:	8082                	ret

ffffffffc0201eb6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eb6:	100027f3          	csrr	a5,sstatus
ffffffffc0201eba:	8b89                	andi	a5,a5,2
ffffffffc0201ebc:	eb89                	bnez	a5,ffffffffc0201ece <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ebe:	000aa797          	auipc	a5,0xaa
ffffffffc0201ec2:	73278793          	addi	a5,a5,1842 # ffffffffc02ac5f0 <pmm_manager>
ffffffffc0201ec6:	639c                	ld	a5,0(a5)
ffffffffc0201ec8:	0207b303          	ld	t1,32(a5)
ffffffffc0201ecc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ece:	1101                	addi	sp,sp,-32
ffffffffc0201ed0:	ec06                	sd	ra,24(sp)
ffffffffc0201ed2:	e822                	sd	s0,16(sp)
ffffffffc0201ed4:	e426                	sd	s1,8(sp)
ffffffffc0201ed6:	842a                	mv	s0,a0
ffffffffc0201ed8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201eda:	f5cfe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ede:	000aa797          	auipc	a5,0xaa
ffffffffc0201ee2:	71278793          	addi	a5,a5,1810 # ffffffffc02ac5f0 <pmm_manager>
ffffffffc0201ee6:	639c                	ld	a5,0(a5)
ffffffffc0201ee8:	85a6                	mv	a1,s1
ffffffffc0201eea:	8522                	mv	a0,s0
ffffffffc0201eec:	739c                	ld	a5,32(a5)
ffffffffc0201eee:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ef0:	6442                	ld	s0,16(sp)
ffffffffc0201ef2:	60e2                	ld	ra,24(sp)
ffffffffc0201ef4:	64a2                	ld	s1,8(sp)
ffffffffc0201ef6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201ef8:	f38fe06f          	j	ffffffffc0200630 <intr_enable>

ffffffffc0201efc <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201efc:	100027f3          	csrr	a5,sstatus
ffffffffc0201f00:	8b89                	andi	a5,a5,2
ffffffffc0201f02:	eb89                	bnez	a5,ffffffffc0201f14 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f04:	000aa797          	auipc	a5,0xaa
ffffffffc0201f08:	6ec78793          	addi	a5,a5,1772 # ffffffffc02ac5f0 <pmm_manager>
ffffffffc0201f0c:	639c                	ld	a5,0(a5)
ffffffffc0201f0e:	0287b303          	ld	t1,40(a5)
ffffffffc0201f12:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f14:	1141                	addi	sp,sp,-16
ffffffffc0201f16:	e406                	sd	ra,8(sp)
ffffffffc0201f18:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f1a:	f1cfe0ef          	jal	ra,ffffffffc0200636 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f1e:	000aa797          	auipc	a5,0xaa
ffffffffc0201f22:	6d278793          	addi	a5,a5,1746 # ffffffffc02ac5f0 <pmm_manager>
ffffffffc0201f26:	639c                	ld	a5,0(a5)
ffffffffc0201f28:	779c                	ld	a5,40(a5)
ffffffffc0201f2a:	9782                	jalr	a5
ffffffffc0201f2c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f2e:	f02fe0ef          	jal	ra,ffffffffc0200630 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f32:	8522                	mv	a0,s0
ffffffffc0201f34:	60a2                	ld	ra,8(sp)
ffffffffc0201f36:	6402                	ld	s0,0(sp)
ffffffffc0201f38:	0141                	addi	sp,sp,16
ffffffffc0201f3a:	8082                	ret

ffffffffc0201f3c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f3c:	7139                	addi	sp,sp,-64
ffffffffc0201f3e:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f40:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f44:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f48:	048e                	slli	s1,s1,0x3
ffffffffc0201f4a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f4c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f4e:	f04a                	sd	s2,32(sp)
ffffffffc0201f50:	ec4e                	sd	s3,24(sp)
ffffffffc0201f52:	e852                	sd	s4,16(sp)
ffffffffc0201f54:	fc06                	sd	ra,56(sp)
ffffffffc0201f56:	f822                	sd	s0,48(sp)
ffffffffc0201f58:	e456                	sd	s5,8(sp)
ffffffffc0201f5a:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f5c:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f60:	892e                	mv	s2,a1
ffffffffc0201f62:	8a32                	mv	s4,a2
ffffffffc0201f64:	000aa997          	auipc	s3,0xaa
ffffffffc0201f68:	63498993          	addi	s3,s3,1588 # ffffffffc02ac598 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f6c:	e7bd                	bnez	a5,ffffffffc0201fda <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f6e:	12060c63          	beqz	a2,ffffffffc02020a6 <get_pte+0x16a>
ffffffffc0201f72:	4505                	li	a0,1
ffffffffc0201f74:	ebbff0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0201f78:	842a                	mv	s0,a0
ffffffffc0201f7a:	12050663          	beqz	a0,ffffffffc02020a6 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f7e:	000aab17          	auipc	s6,0xaa
ffffffffc0201f82:	68ab0b13          	addi	s6,s6,1674 # ffffffffc02ac608 <pages>
ffffffffc0201f86:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201f8a:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f8c:	000aa997          	auipc	s3,0xaa
ffffffffc0201f90:	60c98993          	addi	s3,s3,1548 # ffffffffc02ac598 <npage>
    return page - pages + nbase;
ffffffffc0201f94:	40a40533          	sub	a0,s0,a0
ffffffffc0201f98:	00080ab7          	lui	s5,0x80
ffffffffc0201f9c:	8519                	srai	a0,a0,0x6
ffffffffc0201f9e:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fa2:	c01c                	sw	a5,0(s0)
ffffffffc0201fa4:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fa6:	9556                	add	a0,a0,s5
ffffffffc0201fa8:	83b1                	srli	a5,a5,0xc
ffffffffc0201faa:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fac:	0532                	slli	a0,a0,0xc
ffffffffc0201fae:	14e7f363          	bleu	a4,a5,ffffffffc02020f4 <get_pte+0x1b8>
ffffffffc0201fb2:	000aa797          	auipc	a5,0xaa
ffffffffc0201fb6:	64678793          	addi	a5,a5,1606 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0201fba:	639c                	ld	a5,0(a5)
ffffffffc0201fbc:	6605                	lui	a2,0x1
ffffffffc0201fbe:	4581                	li	a1,0
ffffffffc0201fc0:	953e                	add	a0,a0,a5
ffffffffc0201fc2:	3b6040ef          	jal	ra,ffffffffc0206378 <memset>
    return page - pages + nbase;
ffffffffc0201fc6:	000b3683          	ld	a3,0(s6)
ffffffffc0201fca:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fce:	8699                	srai	a3,a3,0x6
ffffffffc0201fd0:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fd2:	06aa                	slli	a3,a3,0xa
ffffffffc0201fd4:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fd8:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fda:	77fd                	lui	a5,0xfffff
ffffffffc0201fdc:	068a                	slli	a3,a3,0x2
ffffffffc0201fde:	0009b703          	ld	a4,0(s3)
ffffffffc0201fe2:	8efd                	and	a3,a3,a5
ffffffffc0201fe4:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201fe8:	0ce7f163          	bleu	a4,a5,ffffffffc02020aa <get_pte+0x16e>
ffffffffc0201fec:	000aaa97          	auipc	s5,0xaa
ffffffffc0201ff0:	60ca8a93          	addi	s5,s5,1548 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0201ff4:	000ab403          	ld	s0,0(s5)
ffffffffc0201ff8:	01595793          	srli	a5,s2,0x15
ffffffffc0201ffc:	1ff7f793          	andi	a5,a5,511
ffffffffc0202000:	96a2                	add	a3,a3,s0
ffffffffc0202002:	00379413          	slli	s0,a5,0x3
ffffffffc0202006:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0202008:	6014                	ld	a3,0(s0)
ffffffffc020200a:	0016f793          	andi	a5,a3,1
ffffffffc020200e:	e3ad                	bnez	a5,ffffffffc0202070 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202010:	080a0b63          	beqz	s4,ffffffffc02020a6 <get_pte+0x16a>
ffffffffc0202014:	4505                	li	a0,1
ffffffffc0202016:	e19ff0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc020201a:	84aa                	mv	s1,a0
ffffffffc020201c:	c549                	beqz	a0,ffffffffc02020a6 <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc020201e:	000aab17          	auipc	s6,0xaa
ffffffffc0202022:	5eab0b13          	addi	s6,s6,1514 # ffffffffc02ac608 <pages>
ffffffffc0202026:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020202a:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc020202c:	00080a37          	lui	s4,0x80
ffffffffc0202030:	40a48533          	sub	a0,s1,a0
ffffffffc0202034:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202036:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020203a:	c09c                	sw	a5,0(s1)
ffffffffc020203c:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020203e:	9552                	add	a0,a0,s4
ffffffffc0202040:	83b1                	srli	a5,a5,0xc
ffffffffc0202042:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202044:	0532                	slli	a0,a0,0xc
ffffffffc0202046:	08e7fa63          	bleu	a4,a5,ffffffffc02020da <get_pte+0x19e>
ffffffffc020204a:	000ab783          	ld	a5,0(s5)
ffffffffc020204e:	6605                	lui	a2,0x1
ffffffffc0202050:	4581                	li	a1,0
ffffffffc0202052:	953e                	add	a0,a0,a5
ffffffffc0202054:	324040ef          	jal	ra,ffffffffc0206378 <memset>
    return page - pages + nbase;
ffffffffc0202058:	000b3683          	ld	a3,0(s6)
ffffffffc020205c:	40d486b3          	sub	a3,s1,a3
ffffffffc0202060:	8699                	srai	a3,a3,0x6
ffffffffc0202062:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202064:	06aa                	slli	a3,a3,0xa
ffffffffc0202066:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020206a:	e014                	sd	a3,0(s0)
ffffffffc020206c:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202070:	068a                	slli	a3,a3,0x2
ffffffffc0202072:	757d                	lui	a0,0xfffff
ffffffffc0202074:	8ee9                	and	a3,a3,a0
ffffffffc0202076:	00c6d793          	srli	a5,a3,0xc
ffffffffc020207a:	04e7f463          	bleu	a4,a5,ffffffffc02020c2 <get_pte+0x186>
ffffffffc020207e:	000ab503          	ld	a0,0(s5)
ffffffffc0202082:	00c95793          	srli	a5,s2,0xc
ffffffffc0202086:	1ff7f793          	andi	a5,a5,511
ffffffffc020208a:	96aa                	add	a3,a3,a0
ffffffffc020208c:	00379513          	slli	a0,a5,0x3
ffffffffc0202090:	9536                	add	a0,a0,a3
}
ffffffffc0202092:	70e2                	ld	ra,56(sp)
ffffffffc0202094:	7442                	ld	s0,48(sp)
ffffffffc0202096:	74a2                	ld	s1,40(sp)
ffffffffc0202098:	7902                	ld	s2,32(sp)
ffffffffc020209a:	69e2                	ld	s3,24(sp)
ffffffffc020209c:	6a42                	ld	s4,16(sp)
ffffffffc020209e:	6aa2                	ld	s5,8(sp)
ffffffffc02020a0:	6b02                	ld	s6,0(sp)
ffffffffc02020a2:	6121                	addi	sp,sp,64
ffffffffc02020a4:	8082                	ret
            return NULL;
ffffffffc02020a6:	4501                	li	a0,0
ffffffffc02020a8:	b7ed                	j	ffffffffc0202092 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020aa:	00005617          	auipc	a2,0x5
ffffffffc02020ae:	08660613          	addi	a2,a2,134 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02020b2:	0e300593          	li	a1,227
ffffffffc02020b6:	00005517          	auipc	a0,0x5
ffffffffc02020ba:	18a50513          	addi	a0,a0,394 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc02020be:	bc6fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020c2:	00005617          	auipc	a2,0x5
ffffffffc02020c6:	06e60613          	addi	a2,a2,110 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02020ca:	0ee00593          	li	a1,238
ffffffffc02020ce:	00005517          	auipc	a0,0x5
ffffffffc02020d2:	17250513          	addi	a0,a0,370 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc02020d6:	baefe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020da:	86aa                	mv	a3,a0
ffffffffc02020dc:	00005617          	auipc	a2,0x5
ffffffffc02020e0:	05460613          	addi	a2,a2,84 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02020e4:	0eb00593          	li	a1,235
ffffffffc02020e8:	00005517          	auipc	a0,0x5
ffffffffc02020ec:	15850513          	addi	a0,a0,344 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc02020f0:	b94fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020f4:	86aa                	mv	a3,a0
ffffffffc02020f6:	00005617          	auipc	a2,0x5
ffffffffc02020fa:	03a60613          	addi	a2,a2,58 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02020fe:	0df00593          	li	a1,223
ffffffffc0202102:	00005517          	auipc	a0,0x5
ffffffffc0202106:	13e50513          	addi	a0,a0,318 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020210a:	b7afe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020210e <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020210e:	1141                	addi	sp,sp,-16
ffffffffc0202110:	e022                	sd	s0,0(sp)
ffffffffc0202112:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202114:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202116:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202118:	e25ff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
    if (ptep_store != NULL) {
ffffffffc020211c:	c011                	beqz	s0,ffffffffc0202120 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020211e:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202120:	c129                	beqz	a0,ffffffffc0202162 <get_page+0x54>
ffffffffc0202122:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202124:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202126:	0017f713          	andi	a4,a5,1
ffffffffc020212a:	e709                	bnez	a4,ffffffffc0202134 <get_page+0x26>
}
ffffffffc020212c:	60a2                	ld	ra,8(sp)
ffffffffc020212e:	6402                	ld	s0,0(sp)
ffffffffc0202130:	0141                	addi	sp,sp,16
ffffffffc0202132:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202134:	000aa717          	auipc	a4,0xaa
ffffffffc0202138:	46470713          	addi	a4,a4,1124 # ffffffffc02ac598 <npage>
ffffffffc020213c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020213e:	078a                	slli	a5,a5,0x2
ffffffffc0202140:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202142:	02e7f563          	bleu	a4,a5,ffffffffc020216c <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202146:	000aa717          	auipc	a4,0xaa
ffffffffc020214a:	4c270713          	addi	a4,a4,1218 # ffffffffc02ac608 <pages>
ffffffffc020214e:	6308                	ld	a0,0(a4)
ffffffffc0202150:	60a2                	ld	ra,8(sp)
ffffffffc0202152:	6402                	ld	s0,0(sp)
ffffffffc0202154:	fff80737          	lui	a4,0xfff80
ffffffffc0202158:	97ba                	add	a5,a5,a4
ffffffffc020215a:	079a                	slli	a5,a5,0x6
ffffffffc020215c:	953e                	add	a0,a0,a5
ffffffffc020215e:	0141                	addi	sp,sp,16
ffffffffc0202160:	8082                	ret
ffffffffc0202162:	60a2                	ld	ra,8(sp)
ffffffffc0202164:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0202166:	4501                	li	a0,0
}
ffffffffc0202168:	0141                	addi	sp,sp,16
ffffffffc020216a:	8082                	ret
ffffffffc020216c:	ca7ff0ef          	jal	ra,ffffffffc0201e12 <pa2page.part.4>

ffffffffc0202170 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202170:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202172:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202176:	ec86                	sd	ra,88(sp)
ffffffffc0202178:	e8a2                	sd	s0,80(sp)
ffffffffc020217a:	e4a6                	sd	s1,72(sp)
ffffffffc020217c:	e0ca                	sd	s2,64(sp)
ffffffffc020217e:	fc4e                	sd	s3,56(sp)
ffffffffc0202180:	f852                	sd	s4,48(sp)
ffffffffc0202182:	f456                	sd	s5,40(sp)
ffffffffc0202184:	f05a                	sd	s6,32(sp)
ffffffffc0202186:	ec5e                	sd	s7,24(sp)
ffffffffc0202188:	e862                	sd	s8,16(sp)
ffffffffc020218a:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020218c:	03479713          	slli	a4,a5,0x34
ffffffffc0202190:	eb71                	bnez	a4,ffffffffc0202264 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc0202192:	002007b7          	lui	a5,0x200
ffffffffc0202196:	842e                	mv	s0,a1
ffffffffc0202198:	0af5e663          	bltu	a1,a5,ffffffffc0202244 <unmap_range+0xd4>
ffffffffc020219c:	8932                	mv	s2,a2
ffffffffc020219e:	0ac5f363          	bleu	a2,a1,ffffffffc0202244 <unmap_range+0xd4>
ffffffffc02021a2:	4785                	li	a5,1
ffffffffc02021a4:	07fe                	slli	a5,a5,0x1f
ffffffffc02021a6:	08c7ef63          	bltu	a5,a2,ffffffffc0202244 <unmap_range+0xd4>
ffffffffc02021aa:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021ac:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021ae:	000aac97          	auipc	s9,0xaa
ffffffffc02021b2:	3eac8c93          	addi	s9,s9,1002 # ffffffffc02ac598 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021b6:	000aac17          	auipc	s8,0xaa
ffffffffc02021ba:	452c0c13          	addi	s8,s8,1106 # ffffffffc02ac608 <pages>
ffffffffc02021be:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021c2:	00200b37          	lui	s6,0x200
ffffffffc02021c6:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021ca:	4601                	li	a2,0
ffffffffc02021cc:	85a2                	mv	a1,s0
ffffffffc02021ce:	854e                	mv	a0,s3
ffffffffc02021d0:	d6dff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc02021d4:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021d6:	cd21                	beqz	a0,ffffffffc020222e <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021d8:	611c                	ld	a5,0(a0)
ffffffffc02021da:	e38d                	bnez	a5,ffffffffc02021fc <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021dc:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021de:	ff2466e3          	bltu	s0,s2,ffffffffc02021ca <unmap_range+0x5a>
}
ffffffffc02021e2:	60e6                	ld	ra,88(sp)
ffffffffc02021e4:	6446                	ld	s0,80(sp)
ffffffffc02021e6:	64a6                	ld	s1,72(sp)
ffffffffc02021e8:	6906                	ld	s2,64(sp)
ffffffffc02021ea:	79e2                	ld	s3,56(sp)
ffffffffc02021ec:	7a42                	ld	s4,48(sp)
ffffffffc02021ee:	7aa2                	ld	s5,40(sp)
ffffffffc02021f0:	7b02                	ld	s6,32(sp)
ffffffffc02021f2:	6be2                	ld	s7,24(sp)
ffffffffc02021f4:	6c42                	ld	s8,16(sp)
ffffffffc02021f6:	6ca2                	ld	s9,8(sp)
ffffffffc02021f8:	6125                	addi	sp,sp,96
ffffffffc02021fa:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02021fc:	0017f713          	andi	a4,a5,1
ffffffffc0202200:	df71                	beqz	a4,ffffffffc02021dc <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202202:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202206:	078a                	slli	a5,a5,0x2
ffffffffc0202208:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020220a:	06e7fd63          	bleu	a4,a5,ffffffffc0202284 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc020220e:	000c3503          	ld	a0,0(s8)
ffffffffc0202212:	97de                	add	a5,a5,s7
ffffffffc0202214:	079a                	slli	a5,a5,0x6
ffffffffc0202216:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202218:	411c                	lw	a5,0(a0)
ffffffffc020221a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020221e:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202220:	cf11                	beqz	a4,ffffffffc020223c <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202222:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202226:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020222a:	9452                	add	s0,s0,s4
ffffffffc020222c:	bf4d                	j	ffffffffc02021de <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020222e:	945a                	add	s0,s0,s6
ffffffffc0202230:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202234:	d45d                	beqz	s0,ffffffffc02021e2 <unmap_range+0x72>
ffffffffc0202236:	f9246ae3          	bltu	s0,s2,ffffffffc02021ca <unmap_range+0x5a>
ffffffffc020223a:	b765                	j	ffffffffc02021e2 <unmap_range+0x72>
            free_page(page);
ffffffffc020223c:	4585                	li	a1,1
ffffffffc020223e:	c79ff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
ffffffffc0202242:	b7c5                	j	ffffffffc0202222 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202244:	00005697          	auipc	a3,0x5
ffffffffc0202248:	5a468693          	addi	a3,a3,1444 # ffffffffc02077e8 <default_pmm_manager+0x708>
ffffffffc020224c:	00004617          	auipc	a2,0x4
ffffffffc0202250:	74c60613          	addi	a2,a2,1868 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202254:	11000593          	li	a1,272
ffffffffc0202258:	00005517          	auipc	a0,0x5
ffffffffc020225c:	fe850513          	addi	a0,a0,-24 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202260:	a24fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202264:	00005697          	auipc	a3,0x5
ffffffffc0202268:	55468693          	addi	a3,a3,1364 # ffffffffc02077b8 <default_pmm_manager+0x6d8>
ffffffffc020226c:	00004617          	auipc	a2,0x4
ffffffffc0202270:	72c60613          	addi	a2,a2,1836 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202274:	10f00593          	li	a1,271
ffffffffc0202278:	00005517          	auipc	a0,0x5
ffffffffc020227c:	fc850513          	addi	a0,a0,-56 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202280:	a04fe0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202284:	b8fff0ef          	jal	ra,ffffffffc0201e12 <pa2page.part.4>

ffffffffc0202288 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202288:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020228a:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020228e:	fc86                	sd	ra,120(sp)
ffffffffc0202290:	f8a2                	sd	s0,112(sp)
ffffffffc0202292:	f4a6                	sd	s1,104(sp)
ffffffffc0202294:	f0ca                	sd	s2,96(sp)
ffffffffc0202296:	ecce                	sd	s3,88(sp)
ffffffffc0202298:	e8d2                	sd	s4,80(sp)
ffffffffc020229a:	e4d6                	sd	s5,72(sp)
ffffffffc020229c:	e0da                	sd	s6,64(sp)
ffffffffc020229e:	fc5e                	sd	s7,56(sp)
ffffffffc02022a0:	f862                	sd	s8,48(sp)
ffffffffc02022a2:	f466                	sd	s9,40(sp)
ffffffffc02022a4:	f06a                	sd	s10,32(sp)
ffffffffc02022a6:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022a8:	03479713          	slli	a4,a5,0x34
ffffffffc02022ac:	1c071163          	bnez	a4,ffffffffc020246e <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022b0:	002007b7          	lui	a5,0x200
ffffffffc02022b4:	20f5e563          	bltu	a1,a5,ffffffffc02024be <exit_range+0x236>
ffffffffc02022b8:	8b32                	mv	s6,a2
ffffffffc02022ba:	20c5f263          	bleu	a2,a1,ffffffffc02024be <exit_range+0x236>
ffffffffc02022be:	4785                	li	a5,1
ffffffffc02022c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02022c2:	1ec7ee63          	bltu	a5,a2,ffffffffc02024be <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022c6:	c00009b7          	lui	s3,0xc0000
ffffffffc02022ca:	400007b7          	lui	a5,0x40000
ffffffffc02022ce:	0135f9b3          	and	s3,a1,s3
ffffffffc02022d2:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022d4:	c0000337          	lui	t1,0xc0000
ffffffffc02022d8:	00698933          	add	s2,s3,t1
ffffffffc02022dc:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022e0:	1ff97913          	andi	s2,s2,511
ffffffffc02022e4:	8e2a                	mv	t3,a0
ffffffffc02022e6:	090e                	slli	s2,s2,0x3
ffffffffc02022e8:	9972                	add	s2,s2,t3
ffffffffc02022ea:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022ee:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc02022f2:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc02022f4:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022f8:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc02022fa:	000aad17          	auipc	s10,0xaa
ffffffffc02022fe:	29ed0d13          	addi	s10,s10,670 # ffffffffc02ac598 <npage>
    return KADDR(page2pa(page));
ffffffffc0202302:	00cddd93          	srli	s11,s11,0xc
ffffffffc0202306:	000aa717          	auipc	a4,0xaa
ffffffffc020230a:	2f270713          	addi	a4,a4,754 # ffffffffc02ac5f8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc020230e:	000aae97          	auipc	t4,0xaa
ffffffffc0202312:	2fae8e93          	addi	t4,t4,762 # ffffffffc02ac608 <pages>
        if (pde1&PTE_V){
ffffffffc0202316:	e79d                	bnez	a5,ffffffffc0202344 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0202318:	12098963          	beqz	s3,ffffffffc020244a <exit_range+0x1c2>
ffffffffc020231c:	400007b7          	lui	a5,0x40000
ffffffffc0202320:	84ce                	mv	s1,s3
ffffffffc0202322:	97ce                	add	a5,a5,s3
ffffffffc0202324:	1369f363          	bleu	s6,s3,ffffffffc020244a <exit_range+0x1c2>
ffffffffc0202328:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020232a:	00698933          	add	s2,s3,t1
ffffffffc020232e:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202332:	1ff97913          	andi	s2,s2,511
ffffffffc0202336:	090e                	slli	s2,s2,0x3
ffffffffc0202338:	9972                	add	s2,s2,t3
ffffffffc020233a:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc020233e:	001bf793          	andi	a5,s7,1
ffffffffc0202342:	dbf9                	beqz	a5,ffffffffc0202318 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202344:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202348:	0b8a                	slli	s7,s7,0x2
ffffffffc020234a:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc020234e:	14fbfc63          	bleu	a5,s7,ffffffffc02024a6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202352:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202356:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0202358:	000806b7          	lui	a3,0x80
ffffffffc020235c:	96d6                	add	a3,a3,s5
ffffffffc020235e:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202362:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0202366:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202368:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020236a:	12f67263          	bleu	a5,a2,ffffffffc020248e <exit_range+0x206>
ffffffffc020236e:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202372:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202374:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202378:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020237a:	00080837          	lui	a6,0x80
ffffffffc020237e:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0202380:	00200c37          	lui	s8,0x200
ffffffffc0202384:	a801                	j	ffffffffc0202394 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0202386:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0202388:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020238a:	c0d9                	beqz	s1,ffffffffc0202410 <exit_range+0x188>
ffffffffc020238c:	0934f263          	bleu	s3,s1,ffffffffc0202410 <exit_range+0x188>
ffffffffc0202390:	0d64fc63          	bleu	s6,s1,ffffffffc0202468 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202394:	0154d413          	srli	s0,s1,0x15
ffffffffc0202398:	1ff47413          	andi	s0,s0,511
ffffffffc020239c:	040e                	slli	s0,s0,0x3
ffffffffc020239e:	9452                	add	s0,s0,s4
ffffffffc02023a0:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023a2:	0017f693          	andi	a3,a5,1
ffffffffc02023a6:	d2e5                	beqz	a3,ffffffffc0202386 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023a8:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023ac:	00279513          	slli	a0,a5,0x2
ffffffffc02023b0:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023b2:	0eb57a63          	bleu	a1,a0,ffffffffc02024a6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023b6:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023b8:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023bc:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023c0:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023c2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023c4:	0cb7f563          	bleu	a1,a5,ffffffffc020248e <exit_range+0x206>
ffffffffc02023c8:	631c                	ld	a5,0(a4)
ffffffffc02023ca:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023cc:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023d0:	629c                	ld	a5,0(a3)
ffffffffc02023d2:	8b85                	andi	a5,a5,1
ffffffffc02023d4:	fbd5                	bnez	a5,ffffffffc0202388 <exit_range+0x100>
ffffffffc02023d6:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023d8:	fed59ce3          	bne	a1,a3,ffffffffc02023d0 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023dc:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023e0:	4585                	li	a1,1
ffffffffc02023e2:	e072                	sd	t3,0(sp)
ffffffffc02023e4:	953e                	add	a0,a0,a5
ffffffffc02023e6:	ad1ff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
                d0start += PTSIZE;
ffffffffc02023ea:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023ec:	00043023          	sd	zero,0(s0)
ffffffffc02023f0:	000aae97          	auipc	t4,0xaa
ffffffffc02023f4:	218e8e93          	addi	t4,t4,536 # ffffffffc02ac608 <pages>
ffffffffc02023f8:	6e02                	ld	t3,0(sp)
ffffffffc02023fa:	c0000337          	lui	t1,0xc0000
ffffffffc02023fe:	fff808b7          	lui	a7,0xfff80
ffffffffc0202402:	00080837          	lui	a6,0x80
ffffffffc0202406:	000aa717          	auipc	a4,0xaa
ffffffffc020240a:	1f270713          	addi	a4,a4,498 # ffffffffc02ac5f8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020240e:	fcbd                	bnez	s1,ffffffffc020238c <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202410:	f00c84e3          	beqz	s9,ffffffffc0202318 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202414:	000d3783          	ld	a5,0(s10)
ffffffffc0202418:	e072                	sd	t3,0(sp)
ffffffffc020241a:	08fbf663          	bleu	a5,s7,ffffffffc02024a6 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020241e:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202422:	67a2                	ld	a5,8(sp)
ffffffffc0202424:	4585                	li	a1,1
ffffffffc0202426:	953e                	add	a0,a0,a5
ffffffffc0202428:	a8fff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc020242c:	00093023          	sd	zero,0(s2)
ffffffffc0202430:	000aa717          	auipc	a4,0xaa
ffffffffc0202434:	1c870713          	addi	a4,a4,456 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0202438:	c0000337          	lui	t1,0xc0000
ffffffffc020243c:	6e02                	ld	t3,0(sp)
ffffffffc020243e:	000aae97          	auipc	t4,0xaa
ffffffffc0202442:	1cae8e93          	addi	t4,t4,458 # ffffffffc02ac608 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0202446:	ec099be3          	bnez	s3,ffffffffc020231c <exit_range+0x94>
}
ffffffffc020244a:	70e6                	ld	ra,120(sp)
ffffffffc020244c:	7446                	ld	s0,112(sp)
ffffffffc020244e:	74a6                	ld	s1,104(sp)
ffffffffc0202450:	7906                	ld	s2,96(sp)
ffffffffc0202452:	69e6                	ld	s3,88(sp)
ffffffffc0202454:	6a46                	ld	s4,80(sp)
ffffffffc0202456:	6aa6                	ld	s5,72(sp)
ffffffffc0202458:	6b06                	ld	s6,64(sp)
ffffffffc020245a:	7be2                	ld	s7,56(sp)
ffffffffc020245c:	7c42                	ld	s8,48(sp)
ffffffffc020245e:	7ca2                	ld	s9,40(sp)
ffffffffc0202460:	7d02                	ld	s10,32(sp)
ffffffffc0202462:	6de2                	ld	s11,24(sp)
ffffffffc0202464:	6109                	addi	sp,sp,128
ffffffffc0202466:	8082                	ret
            if (free_pd0) {
ffffffffc0202468:	ea0c8ae3          	beqz	s9,ffffffffc020231c <exit_range+0x94>
ffffffffc020246c:	b765                	j	ffffffffc0202414 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020246e:	00005697          	auipc	a3,0x5
ffffffffc0202472:	34a68693          	addi	a3,a3,842 # ffffffffc02077b8 <default_pmm_manager+0x6d8>
ffffffffc0202476:	00004617          	auipc	a2,0x4
ffffffffc020247a:	52260613          	addi	a2,a2,1314 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020247e:	12000593          	li	a1,288
ffffffffc0202482:	00005517          	auipc	a0,0x5
ffffffffc0202486:	dbe50513          	addi	a0,a0,-578 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020248a:	ffbfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc020248e:	00005617          	auipc	a2,0x5
ffffffffc0202492:	ca260613          	addi	a2,a2,-862 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0202496:	06900593          	li	a1,105
ffffffffc020249a:	00005517          	auipc	a0,0x5
ffffffffc020249e:	cbe50513          	addi	a0,a0,-834 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02024a2:	fe3fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024a6:	00005617          	auipc	a2,0x5
ffffffffc02024aa:	cea60613          	addi	a2,a2,-790 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc02024ae:	06200593          	li	a1,98
ffffffffc02024b2:	00005517          	auipc	a0,0x5
ffffffffc02024b6:	ca650513          	addi	a0,a0,-858 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02024ba:	fcbfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024be:	00005697          	auipc	a3,0x5
ffffffffc02024c2:	32a68693          	addi	a3,a3,810 # ffffffffc02077e8 <default_pmm_manager+0x708>
ffffffffc02024c6:	00004617          	auipc	a2,0x4
ffffffffc02024ca:	4d260613          	addi	a2,a2,1234 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02024ce:	12100593          	li	a1,289
ffffffffc02024d2:	00005517          	auipc	a0,0x5
ffffffffc02024d6:	d6e50513          	addi	a0,a0,-658 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc02024da:	fabfd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02024de <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024de:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024e0:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024e2:	e426                	sd	s1,8(sp)
ffffffffc02024e4:	ec06                	sd	ra,24(sp)
ffffffffc02024e6:	e822                	sd	s0,16(sp)
ffffffffc02024e8:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024ea:	a53ff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
    if (ptep != NULL) {
ffffffffc02024ee:	c511                	beqz	a0,ffffffffc02024fa <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02024f0:	611c                	ld	a5,0(a0)
ffffffffc02024f2:	842a                	mv	s0,a0
ffffffffc02024f4:	0017f713          	andi	a4,a5,1
ffffffffc02024f8:	e711                	bnez	a4,ffffffffc0202504 <page_remove+0x26>
}
ffffffffc02024fa:	60e2                	ld	ra,24(sp)
ffffffffc02024fc:	6442                	ld	s0,16(sp)
ffffffffc02024fe:	64a2                	ld	s1,8(sp)
ffffffffc0202500:	6105                	addi	sp,sp,32
ffffffffc0202502:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202504:	000aa717          	auipc	a4,0xaa
ffffffffc0202508:	09470713          	addi	a4,a4,148 # ffffffffc02ac598 <npage>
ffffffffc020250c:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020250e:	078a                	slli	a5,a5,0x2
ffffffffc0202510:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202512:	02e7fe63          	bleu	a4,a5,ffffffffc020254e <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0202516:	000aa717          	auipc	a4,0xaa
ffffffffc020251a:	0f270713          	addi	a4,a4,242 # ffffffffc02ac608 <pages>
ffffffffc020251e:	6308                	ld	a0,0(a4)
ffffffffc0202520:	fff80737          	lui	a4,0xfff80
ffffffffc0202524:	97ba                	add	a5,a5,a4
ffffffffc0202526:	079a                	slli	a5,a5,0x6
ffffffffc0202528:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020252a:	411c                	lw	a5,0(a0)
ffffffffc020252c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202530:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202532:	cb11                	beqz	a4,ffffffffc0202546 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202534:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202538:	12048073          	sfence.vma	s1
}
ffffffffc020253c:	60e2                	ld	ra,24(sp)
ffffffffc020253e:	6442                	ld	s0,16(sp)
ffffffffc0202540:	64a2                	ld	s1,8(sp)
ffffffffc0202542:	6105                	addi	sp,sp,32
ffffffffc0202544:	8082                	ret
            free_page(page);
ffffffffc0202546:	4585                	li	a1,1
ffffffffc0202548:	96fff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
ffffffffc020254c:	b7e5                	j	ffffffffc0202534 <page_remove+0x56>
ffffffffc020254e:	8c5ff0ef          	jal	ra,ffffffffc0201e12 <pa2page.part.4>

ffffffffc0202552 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202552:	7179                	addi	sp,sp,-48
ffffffffc0202554:	e44e                	sd	s3,8(sp)
ffffffffc0202556:	89b2                	mv	s3,a2
ffffffffc0202558:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020255a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020255c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020255e:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202560:	ec26                	sd	s1,24(sp)
ffffffffc0202562:	f406                	sd	ra,40(sp)
ffffffffc0202564:	e84a                	sd	s2,16(sp)
ffffffffc0202566:	e052                	sd	s4,0(sp)
ffffffffc0202568:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020256a:	9d3ff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
    if (ptep == NULL) {
ffffffffc020256e:	cd49                	beqz	a0,ffffffffc0202608 <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202570:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202572:	611c                	ld	a5,0(a0)
ffffffffc0202574:	892a                	mv	s2,a0
ffffffffc0202576:	0016871b          	addiw	a4,a3,1
ffffffffc020257a:	c018                	sw	a4,0(s0)
ffffffffc020257c:	0017f713          	andi	a4,a5,1
ffffffffc0202580:	ef05                	bnez	a4,ffffffffc02025b8 <page_insert+0x66>
ffffffffc0202582:	000aa797          	auipc	a5,0xaa
ffffffffc0202586:	08678793          	addi	a5,a5,134 # ffffffffc02ac608 <pages>
ffffffffc020258a:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc020258c:	8c19                	sub	s0,s0,a4
ffffffffc020258e:	000806b7          	lui	a3,0x80
ffffffffc0202592:	8419                	srai	s0,s0,0x6
ffffffffc0202594:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202596:	042a                	slli	s0,s0,0xa
ffffffffc0202598:	8c45                	or	s0,s0,s1
ffffffffc020259a:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020259e:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025a2:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025a6:	4501                	li	a0,0
}
ffffffffc02025a8:	70a2                	ld	ra,40(sp)
ffffffffc02025aa:	7402                	ld	s0,32(sp)
ffffffffc02025ac:	64e2                	ld	s1,24(sp)
ffffffffc02025ae:	6942                	ld	s2,16(sp)
ffffffffc02025b0:	69a2                	ld	s3,8(sp)
ffffffffc02025b2:	6a02                	ld	s4,0(sp)
ffffffffc02025b4:	6145                	addi	sp,sp,48
ffffffffc02025b6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025b8:	000aa717          	auipc	a4,0xaa
ffffffffc02025bc:	fe070713          	addi	a4,a4,-32 # ffffffffc02ac598 <npage>
ffffffffc02025c0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025c2:	078a                	slli	a5,a5,0x2
ffffffffc02025c4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025c6:	04e7f363          	bleu	a4,a5,ffffffffc020260c <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025ca:	000aaa17          	auipc	s4,0xaa
ffffffffc02025ce:	03ea0a13          	addi	s4,s4,62 # ffffffffc02ac608 <pages>
ffffffffc02025d2:	000a3703          	ld	a4,0(s4)
ffffffffc02025d6:	fff80537          	lui	a0,0xfff80
ffffffffc02025da:	953e                	add	a0,a0,a5
ffffffffc02025dc:	051a                	slli	a0,a0,0x6
ffffffffc02025de:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025e0:	00a40a63          	beq	s0,a0,ffffffffc02025f4 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025e4:	411c                	lw	a5,0(a0)
ffffffffc02025e6:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025ea:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02025ec:	c691                	beqz	a3,ffffffffc02025f8 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025ee:	12098073          	sfence.vma	s3
ffffffffc02025f2:	bf69                	j	ffffffffc020258c <page_insert+0x3a>
ffffffffc02025f4:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02025f6:	bf59                	j	ffffffffc020258c <page_insert+0x3a>
            free_page(page);
ffffffffc02025f8:	4585                	li	a1,1
ffffffffc02025fa:	8bdff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
ffffffffc02025fe:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202602:	12098073          	sfence.vma	s3
ffffffffc0202606:	b759                	j	ffffffffc020258c <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202608:	5571                	li	a0,-4
ffffffffc020260a:	bf79                	j	ffffffffc02025a8 <page_insert+0x56>
ffffffffc020260c:	807ff0ef          	jal	ra,ffffffffc0201e12 <pa2page.part.4>

ffffffffc0202610 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202610:	00005797          	auipc	a5,0x5
ffffffffc0202614:	ad078793          	addi	a5,a5,-1328 # ffffffffc02070e0 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202618:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020261a:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020261c:	00005517          	auipc	a0,0x5
ffffffffc0202620:	c4c50513          	addi	a0,a0,-948 # ffffffffc0207268 <default_pmm_manager+0x188>
void pmm_init(void) {
ffffffffc0202624:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202626:	000aa717          	auipc	a4,0xaa
ffffffffc020262a:	fcf73523          	sd	a5,-54(a4) # ffffffffc02ac5f0 <pmm_manager>
void pmm_init(void) {
ffffffffc020262e:	e0a2                	sd	s0,64(sp)
ffffffffc0202630:	fc26                	sd	s1,56(sp)
ffffffffc0202632:	f84a                	sd	s2,48(sp)
ffffffffc0202634:	f44e                	sd	s3,40(sp)
ffffffffc0202636:	f052                	sd	s4,32(sp)
ffffffffc0202638:	ec56                	sd	s5,24(sp)
ffffffffc020263a:	e85a                	sd	s6,16(sp)
ffffffffc020263c:	e45e                	sd	s7,8(sp)
ffffffffc020263e:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202640:	000aa417          	auipc	s0,0xaa
ffffffffc0202644:	fb040413          	addi	s0,s0,-80 # ffffffffc02ac5f0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202648:	b47fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc020264c:	601c                	ld	a5,0(s0)
ffffffffc020264e:	000aa497          	auipc	s1,0xaa
ffffffffc0202652:	f4a48493          	addi	s1,s1,-182 # ffffffffc02ac598 <npage>
ffffffffc0202656:	000aa917          	auipc	s2,0xaa
ffffffffc020265a:	fb290913          	addi	s2,s2,-78 # ffffffffc02ac608 <pages>
ffffffffc020265e:	679c                	ld	a5,8(a5)
ffffffffc0202660:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202662:	57f5                	li	a5,-3
ffffffffc0202664:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202666:	00005517          	auipc	a0,0x5
ffffffffc020266a:	c1a50513          	addi	a0,a0,-998 # ffffffffc0207280 <default_pmm_manager+0x1a0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020266e:	000aa717          	auipc	a4,0xaa
ffffffffc0202672:	f8f73523          	sd	a5,-118(a4) # ffffffffc02ac5f8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0202676:	b19fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020267a:	46c5                	li	a3,17
ffffffffc020267c:	06ee                	slli	a3,a3,0x1b
ffffffffc020267e:	40100613          	li	a2,1025
ffffffffc0202682:	16fd                	addi	a3,a3,-1
ffffffffc0202684:	0656                	slli	a2,a2,0x15
ffffffffc0202686:	07e005b7          	lui	a1,0x7e00
ffffffffc020268a:	00005517          	auipc	a0,0x5
ffffffffc020268e:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0207298 <default_pmm_manager+0x1b8>
ffffffffc0202692:	afdfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202696:	777d                	lui	a4,0xfffff
ffffffffc0202698:	000ab797          	auipc	a5,0xab
ffffffffc020269c:	06778793          	addi	a5,a5,103 # ffffffffc02ad6ff <end+0xfff>
ffffffffc02026a0:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026a2:	00088737          	lui	a4,0x88
ffffffffc02026a6:	000aa697          	auipc	a3,0xaa
ffffffffc02026aa:	eee6b923          	sd	a4,-270(a3) # ffffffffc02ac598 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026ae:	000aa717          	auipc	a4,0xaa
ffffffffc02026b2:	f4f73d23          	sd	a5,-166(a4) # ffffffffc02ac608 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026b6:	4701                	li	a4,0
ffffffffc02026b8:	4685                	li	a3,1
ffffffffc02026ba:	fff80837          	lui	a6,0xfff80
ffffffffc02026be:	a019                	j	ffffffffc02026c4 <pmm_init+0xb4>
ffffffffc02026c0:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026c4:	00671613          	slli	a2,a4,0x6
ffffffffc02026c8:	97b2                	add	a5,a5,a2
ffffffffc02026ca:	07a1                	addi	a5,a5,8
ffffffffc02026cc:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026d0:	6090                	ld	a2,0(s1)
ffffffffc02026d2:	0705                	addi	a4,a4,1
ffffffffc02026d4:	010607b3          	add	a5,a2,a6
ffffffffc02026d8:	fef764e3          	bltu	a4,a5,ffffffffc02026c0 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026dc:	00093503          	ld	a0,0(s2)
ffffffffc02026e0:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026e4:	00661693          	slli	a3,a2,0x6
ffffffffc02026e8:	97aa                	add	a5,a5,a0
ffffffffc02026ea:	96be                	add	a3,a3,a5
ffffffffc02026ec:	c02007b7          	lui	a5,0xc0200
ffffffffc02026f0:	7af6ed63          	bltu	a3,a5,ffffffffc0202eaa <pmm_init+0x89a>
ffffffffc02026f4:	000aa997          	auipc	s3,0xaa
ffffffffc02026f8:	f0498993          	addi	s3,s3,-252 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc02026fc:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202700:	47c5                	li	a5,17
ffffffffc0202702:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202704:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202706:	02f6f763          	bleu	a5,a3,ffffffffc0202734 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020270a:	6585                	lui	a1,0x1
ffffffffc020270c:	15fd                	addi	a1,a1,-1
ffffffffc020270e:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202710:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202714:	48c77a63          	bleu	a2,a4,ffffffffc0202ba8 <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0202718:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020271a:	75fd                	lui	a1,0xfffff
ffffffffc020271c:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020271e:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202720:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202722:	40d786b3          	sub	a3,a5,a3
ffffffffc0202726:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202728:	00c6d593          	srli	a1,a3,0xc
ffffffffc020272c:	953a                	add	a0,a0,a4
ffffffffc020272e:	9602                	jalr	a2
ffffffffc0202730:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202734:	00005517          	auipc	a0,0x5
ffffffffc0202738:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02072c0 <default_pmm_manager+0x1e0>
ffffffffc020273c:	a53fd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202740:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202742:	000aa417          	auipc	s0,0xaa
ffffffffc0202746:	e4e40413          	addi	s0,s0,-434 # ffffffffc02ac590 <boot_pgdir>
    pmm_manager->check();
ffffffffc020274a:	7b9c                	ld	a5,48(a5)
ffffffffc020274c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020274e:	00005517          	auipc	a0,0x5
ffffffffc0202752:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02072d8 <default_pmm_manager+0x1f8>
ffffffffc0202756:	a39fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020275a:	00009697          	auipc	a3,0x9
ffffffffc020275e:	8a668693          	addi	a3,a3,-1882 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202762:	000aa797          	auipc	a5,0xaa
ffffffffc0202766:	e2d7b723          	sd	a3,-466(a5) # ffffffffc02ac590 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020276a:	c02007b7          	lui	a5,0xc0200
ffffffffc020276e:	10f6eae3          	bltu	a3,a5,ffffffffc0203082 <pmm_init+0xa72>
ffffffffc0202772:	0009b783          	ld	a5,0(s3)
ffffffffc0202776:	8e9d                	sub	a3,a3,a5
ffffffffc0202778:	000aa797          	auipc	a5,0xaa
ffffffffc020277c:	e8d7b423          	sd	a3,-376(a5) # ffffffffc02ac600 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202780:	f7cff0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202784:	6098                	ld	a4,0(s1)
ffffffffc0202786:	c80007b7          	lui	a5,0xc8000
ffffffffc020278a:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc020278c:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020278e:	0ce7eae3          	bltu	a5,a4,ffffffffc0203062 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202792:	6008                	ld	a0,0(s0)
ffffffffc0202794:	44050463          	beqz	a0,ffffffffc0202bdc <pmm_init+0x5cc>
ffffffffc0202798:	6785                	lui	a5,0x1
ffffffffc020279a:	17fd                	addi	a5,a5,-1
ffffffffc020279c:	8fe9                	and	a5,a5,a0
ffffffffc020279e:	2781                	sext.w	a5,a5
ffffffffc02027a0:	42079e63          	bnez	a5,ffffffffc0202bdc <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027a4:	4601                	li	a2,0
ffffffffc02027a6:	4581                	li	a1,0
ffffffffc02027a8:	967ff0ef          	jal	ra,ffffffffc020210e <get_page>
ffffffffc02027ac:	78051b63          	bnez	a0,ffffffffc0202f42 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027b0:	4505                	li	a0,1
ffffffffc02027b2:	e7cff0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc02027b6:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027b8:	6008                	ld	a0,0(s0)
ffffffffc02027ba:	4681                	li	a3,0
ffffffffc02027bc:	4601                	li	a2,0
ffffffffc02027be:	85d6                	mv	a1,s5
ffffffffc02027c0:	d93ff0ef          	jal	ra,ffffffffc0202552 <page_insert>
ffffffffc02027c4:	7a051f63          	bnez	a0,ffffffffc0202f82 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027c8:	6008                	ld	a0,0(s0)
ffffffffc02027ca:	4601                	li	a2,0
ffffffffc02027cc:	4581                	li	a1,0
ffffffffc02027ce:	f6eff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc02027d2:	78050863          	beqz	a0,ffffffffc0202f62 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02027d6:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027d8:	0017f713          	andi	a4,a5,1
ffffffffc02027dc:	3e070463          	beqz	a4,ffffffffc0202bc4 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02027e0:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027e2:	078a                	slli	a5,a5,0x2
ffffffffc02027e4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027e6:	3ce7f163          	bleu	a4,a5,ffffffffc0202ba8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ea:	00093683          	ld	a3,0(s2)
ffffffffc02027ee:	fff80637          	lui	a2,0xfff80
ffffffffc02027f2:	97b2                	add	a5,a5,a2
ffffffffc02027f4:	079a                	slli	a5,a5,0x6
ffffffffc02027f6:	97b6                	add	a5,a5,a3
ffffffffc02027f8:	72fa9563          	bne	s5,a5,ffffffffc0202f22 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc02027fc:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8590>
ffffffffc0202800:	4785                	li	a5,1
ffffffffc0202802:	70fb9063          	bne	s7,a5,ffffffffc0202f02 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202806:	6008                	ld	a0,0(s0)
ffffffffc0202808:	76fd                	lui	a3,0xfffff
ffffffffc020280a:	611c                	ld	a5,0(a0)
ffffffffc020280c:	078a                	slli	a5,a5,0x2
ffffffffc020280e:	8ff5                	and	a5,a5,a3
ffffffffc0202810:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202814:	66e67e63          	bleu	a4,a2,ffffffffc0202e90 <pmm_init+0x880>
ffffffffc0202818:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020281c:	97e2                	add	a5,a5,s8
ffffffffc020281e:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8590>
ffffffffc0202822:	0b0a                	slli	s6,s6,0x2
ffffffffc0202824:	00db7b33          	and	s6,s6,a3
ffffffffc0202828:	00cb5793          	srli	a5,s6,0xc
ffffffffc020282c:	56e7f863          	bleu	a4,a5,ffffffffc0202d9c <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202830:	4601                	li	a2,0
ffffffffc0202832:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202834:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202836:	f06ff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020283a:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020283c:	55651063          	bne	a0,s6,ffffffffc0202d7c <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202840:	4505                	li	a0,1
ffffffffc0202842:	decff0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0202846:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202848:	6008                	ld	a0,0(s0)
ffffffffc020284a:	46d1                	li	a3,20
ffffffffc020284c:	6605                	lui	a2,0x1
ffffffffc020284e:	85da                	mv	a1,s6
ffffffffc0202850:	d03ff0ef          	jal	ra,ffffffffc0202552 <page_insert>
ffffffffc0202854:	50051463          	bnez	a0,ffffffffc0202d5c <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202858:	6008                	ld	a0,0(s0)
ffffffffc020285a:	4601                	li	a2,0
ffffffffc020285c:	6585                	lui	a1,0x1
ffffffffc020285e:	edeff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc0202862:	4c050d63          	beqz	a0,ffffffffc0202d3c <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0202866:	611c                	ld	a5,0(a0)
ffffffffc0202868:	0107f713          	andi	a4,a5,16
ffffffffc020286c:	4a070863          	beqz	a4,ffffffffc0202d1c <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202870:	8b91                	andi	a5,a5,4
ffffffffc0202872:	48078563          	beqz	a5,ffffffffc0202cfc <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202876:	6008                	ld	a0,0(s0)
ffffffffc0202878:	611c                	ld	a5,0(a0)
ffffffffc020287a:	8bc1                	andi	a5,a5,16
ffffffffc020287c:	46078063          	beqz	a5,ffffffffc0202cdc <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202880:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5570>
ffffffffc0202884:	43779c63          	bne	a5,s7,ffffffffc0202cbc <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202888:	4681                	li	a3,0
ffffffffc020288a:	6605                	lui	a2,0x1
ffffffffc020288c:	85d6                	mv	a1,s5
ffffffffc020288e:	cc5ff0ef          	jal	ra,ffffffffc0202552 <page_insert>
ffffffffc0202892:	40051563          	bnez	a0,ffffffffc0202c9c <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0202896:	000aa703          	lw	a4,0(s5)
ffffffffc020289a:	4789                	li	a5,2
ffffffffc020289c:	3ef71063          	bne	a4,a5,ffffffffc0202c7c <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028a0:	000b2783          	lw	a5,0(s6)
ffffffffc02028a4:	3a079c63          	bnez	a5,ffffffffc0202c5c <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028a8:	6008                	ld	a0,0(s0)
ffffffffc02028aa:	4601                	li	a2,0
ffffffffc02028ac:	6585                	lui	a1,0x1
ffffffffc02028ae:	e8eff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc02028b2:	38050563          	beqz	a0,ffffffffc0202c3c <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028b6:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028b8:	00177793          	andi	a5,a4,1
ffffffffc02028bc:	30078463          	beqz	a5,ffffffffc0202bc4 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028c0:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028c2:	00271793          	slli	a5,a4,0x2
ffffffffc02028c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028c8:	2ed7f063          	bleu	a3,a5,ffffffffc0202ba8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028cc:	00093683          	ld	a3,0(s2)
ffffffffc02028d0:	fff80637          	lui	a2,0xfff80
ffffffffc02028d4:	97b2                	add	a5,a5,a2
ffffffffc02028d6:	079a                	slli	a5,a5,0x6
ffffffffc02028d8:	97b6                	add	a5,a5,a3
ffffffffc02028da:	32fa9163          	bne	s5,a5,ffffffffc0202bfc <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028de:	8b41                	andi	a4,a4,16
ffffffffc02028e0:	70071163          	bnez	a4,ffffffffc0202fe2 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028e4:	6008                	ld	a0,0(s0)
ffffffffc02028e6:	4581                	li	a1,0
ffffffffc02028e8:	bf7ff0ef          	jal	ra,ffffffffc02024de <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02028ec:	000aa703          	lw	a4,0(s5)
ffffffffc02028f0:	4785                	li	a5,1
ffffffffc02028f2:	6cf71863          	bne	a4,a5,ffffffffc0202fc2 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc02028f6:	000b2783          	lw	a5,0(s6)
ffffffffc02028fa:	6a079463          	bnez	a5,ffffffffc0202fa2 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02028fe:	6008                	ld	a0,0(s0)
ffffffffc0202900:	6585                	lui	a1,0x1
ffffffffc0202902:	bddff0ef          	jal	ra,ffffffffc02024de <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202906:	000aa783          	lw	a5,0(s5)
ffffffffc020290a:	50079363          	bnez	a5,ffffffffc0202e10 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc020290e:	000b2783          	lw	a5,0(s6)
ffffffffc0202912:	4c079f63          	bnez	a5,ffffffffc0202df0 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202916:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020291a:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020291c:	000ab783          	ld	a5,0(s5)
ffffffffc0202920:	078a                	slli	a5,a5,0x2
ffffffffc0202922:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202924:	28c7f263          	bleu	a2,a5,ffffffffc0202ba8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202928:	fff80737          	lui	a4,0xfff80
ffffffffc020292c:	00093503          	ld	a0,0(s2)
ffffffffc0202930:	97ba                	add	a5,a5,a4
ffffffffc0202932:	079a                	slli	a5,a5,0x6
ffffffffc0202934:	00f50733          	add	a4,a0,a5
ffffffffc0202938:	4314                	lw	a3,0(a4)
ffffffffc020293a:	4705                	li	a4,1
ffffffffc020293c:	48e69a63          	bne	a3,a4,ffffffffc0202dd0 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202940:	8799                	srai	a5,a5,0x6
ffffffffc0202942:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202946:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0202948:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020294a:	8331                	srli	a4,a4,0xc
ffffffffc020294c:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020294e:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202950:	46c77363          	bleu	a2,a4,ffffffffc0202db6 <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202954:	0009b683          	ld	a3,0(s3)
ffffffffc0202958:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020295a:	639c                	ld	a5,0(a5)
ffffffffc020295c:	078a                	slli	a5,a5,0x2
ffffffffc020295e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202960:	24c7f463          	bleu	a2,a5,ffffffffc0202ba8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202964:	416787b3          	sub	a5,a5,s6
ffffffffc0202968:	079a                	slli	a5,a5,0x6
ffffffffc020296a:	953e                	add	a0,a0,a5
ffffffffc020296c:	4585                	li	a1,1
ffffffffc020296e:	d48ff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202972:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0202976:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202978:	078a                	slli	a5,a5,0x2
ffffffffc020297a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020297c:	22e7f663          	bleu	a4,a5,ffffffffc0202ba8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202980:	00093503          	ld	a0,0(s2)
ffffffffc0202984:	416787b3          	sub	a5,a5,s6
ffffffffc0202988:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020298a:	953e                	add	a0,a0,a5
ffffffffc020298c:	4585                	li	a1,1
ffffffffc020298e:	d28ff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202992:	601c                	ld	a5,0(s0)
ffffffffc0202994:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202998:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc020299c:	d60ff0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>
ffffffffc02029a0:	68aa1163          	bne	s4,a0,ffffffffc0203022 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029a4:	00005517          	auipc	a0,0x5
ffffffffc02029a8:	c4450513          	addi	a0,a0,-956 # ffffffffc02075e8 <default_pmm_manager+0x508>
ffffffffc02029ac:	fe2fd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02029b0:	d4cff0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029b4:	6098                	ld	a4,0(s1)
ffffffffc02029b6:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029ba:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029bc:	00c71693          	slli	a3,a4,0xc
ffffffffc02029c0:	18d7f563          	bleu	a3,a5,ffffffffc0202b4a <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029c4:	83b1                	srli	a5,a5,0xc
ffffffffc02029c6:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029c8:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029cc:	1ae7f163          	bleu	a4,a5,ffffffffc0202b6e <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029d0:	7bfd                	lui	s7,0xfffff
ffffffffc02029d2:	6b05                	lui	s6,0x1
ffffffffc02029d4:	a029                	j	ffffffffc02029de <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029d6:	00cad713          	srli	a4,s5,0xc
ffffffffc02029da:	18f77a63          	bleu	a5,a4,ffffffffc0202b6e <pmm_init+0x55e>
ffffffffc02029de:	0009b583          	ld	a1,0(s3)
ffffffffc02029e2:	4601                	li	a2,0
ffffffffc02029e4:	95d6                	add	a1,a1,s5
ffffffffc02029e6:	d56ff0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc02029ea:	16050263          	beqz	a0,ffffffffc0202b4e <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029ee:	611c                	ld	a5,0(a0)
ffffffffc02029f0:	078a                	slli	a5,a5,0x2
ffffffffc02029f2:	0177f7b3          	and	a5,a5,s7
ffffffffc02029f6:	19579963          	bne	a5,s5,ffffffffc0202b88 <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029fa:	609c                	ld	a5,0(s1)
ffffffffc02029fc:	9ada                	add	s5,s5,s6
ffffffffc02029fe:	6008                	ld	a0,0(s0)
ffffffffc0202a00:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a04:	fceae9e3          	bltu	s5,a4,ffffffffc02029d6 <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a08:	611c                	ld	a5,0(a0)
ffffffffc0202a0a:	62079c63          	bnez	a5,ffffffffc0203042 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a0e:	4505                	li	a0,1
ffffffffc0202a10:	c1eff0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0202a14:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a16:	6008                	ld	a0,0(s0)
ffffffffc0202a18:	4699                	li	a3,6
ffffffffc0202a1a:	10000613          	li	a2,256
ffffffffc0202a1e:	85d6                	mv	a1,s5
ffffffffc0202a20:	b33ff0ef          	jal	ra,ffffffffc0202552 <page_insert>
ffffffffc0202a24:	1e051c63          	bnez	a0,ffffffffc0202c1c <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a28:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a2c:	4785                	li	a5,1
ffffffffc0202a2e:	44f71163          	bne	a4,a5,ffffffffc0202e70 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a32:	6008                	ld	a0,0(s0)
ffffffffc0202a34:	6b05                	lui	s6,0x1
ffffffffc0202a36:	4699                	li	a3,6
ffffffffc0202a38:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8490>
ffffffffc0202a3c:	85d6                	mv	a1,s5
ffffffffc0202a3e:	b15ff0ef          	jal	ra,ffffffffc0202552 <page_insert>
ffffffffc0202a42:	40051763          	bnez	a0,ffffffffc0202e50 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a46:	000aa703          	lw	a4,0(s5)
ffffffffc0202a4a:	4789                	li	a5,2
ffffffffc0202a4c:	3ef71263          	bne	a4,a5,ffffffffc0202e30 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a50:	00005597          	auipc	a1,0x5
ffffffffc0202a54:	cd058593          	addi	a1,a1,-816 # ffffffffc0207720 <default_pmm_manager+0x640>
ffffffffc0202a58:	10000513          	li	a0,256
ffffffffc0202a5c:	0c3030ef          	jal	ra,ffffffffc020631e <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a60:	100b0593          	addi	a1,s6,256
ffffffffc0202a64:	10000513          	li	a0,256
ffffffffc0202a68:	0c9030ef          	jal	ra,ffffffffc0206330 <strcmp>
ffffffffc0202a6c:	44051b63          	bnez	a0,ffffffffc0202ec2 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202a70:	00093683          	ld	a3,0(s2)
ffffffffc0202a74:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a78:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a7a:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a7e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a80:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a82:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a84:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a88:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a8c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a8e:	10f77f63          	bleu	a5,a4,ffffffffc0202bac <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a92:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a96:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a9a:	96be                	add	a3,a3,a5
ffffffffc0202a9c:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52a00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aa0:	03b030ef          	jal	ra,ffffffffc02062da <strlen>
ffffffffc0202aa4:	54051f63          	bnez	a0,ffffffffc0203002 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202aa8:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202aac:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202aae:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52900>
ffffffffc0202ab2:	068a                	slli	a3,a3,0x2
ffffffffc0202ab4:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ab6:	0ef6f963          	bleu	a5,a3,ffffffffc0202ba8 <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202aba:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202abe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ac0:	0efb7663          	bleu	a5,s6,ffffffffc0202bac <pmm_init+0x59c>
ffffffffc0202ac4:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202ac8:	4585                	li	a1,1
ffffffffc0202aca:	8556                	mv	a0,s5
ffffffffc0202acc:	99b6                	add	s3,s3,a3
ffffffffc0202ace:	be8ff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ad2:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202ad6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ad8:	078a                	slli	a5,a5,0x2
ffffffffc0202ada:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202adc:	0ce7f663          	bleu	a4,a5,ffffffffc0202ba8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ae0:	00093503          	ld	a0,0(s2)
ffffffffc0202ae4:	fff809b7          	lui	s3,0xfff80
ffffffffc0202ae8:	97ce                	add	a5,a5,s3
ffffffffc0202aea:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202aec:	953e                	add	a0,a0,a5
ffffffffc0202aee:	4585                	li	a1,1
ffffffffc0202af0:	bc6ff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202af4:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202af8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202afa:	078a                	slli	a5,a5,0x2
ffffffffc0202afc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202afe:	0ae7f563          	bleu	a4,a5,ffffffffc0202ba8 <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b02:	00093503          	ld	a0,0(s2)
ffffffffc0202b06:	97ce                	add	a5,a5,s3
ffffffffc0202b08:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b0a:	953e                	add	a0,a0,a5
ffffffffc0202b0c:	4585                	li	a1,1
ffffffffc0202b0e:	ba8ff0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b12:	601c                	ld	a5,0(s0)
ffffffffc0202b14:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b18:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b1c:	be0ff0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>
ffffffffc0202b20:	3caa1163          	bne	s4,a0,ffffffffc0202ee2 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b24:	00005517          	auipc	a0,0x5
ffffffffc0202b28:	c7450513          	addi	a0,a0,-908 # ffffffffc0207798 <default_pmm_manager+0x6b8>
ffffffffc0202b2c:	e62fd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202b30:	6406                	ld	s0,64(sp)
ffffffffc0202b32:	60a6                	ld	ra,72(sp)
ffffffffc0202b34:	74e2                	ld	s1,56(sp)
ffffffffc0202b36:	7942                	ld	s2,48(sp)
ffffffffc0202b38:	79a2                	ld	s3,40(sp)
ffffffffc0202b3a:	7a02                	ld	s4,32(sp)
ffffffffc0202b3c:	6ae2                	ld	s5,24(sp)
ffffffffc0202b3e:	6b42                	ld	s6,16(sp)
ffffffffc0202b40:	6ba2                	ld	s7,8(sp)
ffffffffc0202b42:	6c02                	ld	s8,0(sp)
ffffffffc0202b44:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b46:	8c8ff06f          	j	ffffffffc0201c0e <kmalloc_init>
ffffffffc0202b4a:	6008                	ld	a0,0(s0)
ffffffffc0202b4c:	bd75                	j	ffffffffc0202a08 <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b4e:	00005697          	auipc	a3,0x5
ffffffffc0202b52:	aba68693          	addi	a3,a3,-1350 # ffffffffc0207608 <default_pmm_manager+0x528>
ffffffffc0202b56:	00004617          	auipc	a2,0x4
ffffffffc0202b5a:	e4260613          	addi	a2,a2,-446 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202b5e:	22800593          	li	a1,552
ffffffffc0202b62:	00004517          	auipc	a0,0x4
ffffffffc0202b66:	6de50513          	addi	a0,a0,1758 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202b6a:	91bfd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202b6e:	86d6                	mv	a3,s5
ffffffffc0202b70:	00004617          	auipc	a2,0x4
ffffffffc0202b74:	5c060613          	addi	a2,a2,1472 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0202b78:	22800593          	li	a1,552
ffffffffc0202b7c:	00004517          	auipc	a0,0x4
ffffffffc0202b80:	6c450513          	addi	a0,a0,1732 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202b84:	901fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b88:	00005697          	auipc	a3,0x5
ffffffffc0202b8c:	ac068693          	addi	a3,a3,-1344 # ffffffffc0207648 <default_pmm_manager+0x568>
ffffffffc0202b90:	00004617          	auipc	a2,0x4
ffffffffc0202b94:	e0860613          	addi	a2,a2,-504 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202b98:	22900593          	li	a1,553
ffffffffc0202b9c:	00004517          	auipc	a0,0x4
ffffffffc0202ba0:	6a450513          	addi	a0,a0,1700 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202ba4:	8e1fd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0202ba8:	a6aff0ef          	jal	ra,ffffffffc0201e12 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bac:	00004617          	auipc	a2,0x4
ffffffffc0202bb0:	58460613          	addi	a2,a2,1412 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0202bb4:	06900593          	li	a1,105
ffffffffc0202bb8:	00004517          	auipc	a0,0x4
ffffffffc0202bbc:	5a050513          	addi	a0,a0,1440 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0202bc0:	8c5fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bc4:	00005617          	auipc	a2,0x5
ffffffffc0202bc8:	81460613          	addi	a2,a2,-2028 # ffffffffc02073d8 <default_pmm_manager+0x2f8>
ffffffffc0202bcc:	07400593          	li	a1,116
ffffffffc0202bd0:	00004517          	auipc	a0,0x4
ffffffffc0202bd4:	58850513          	addi	a0,a0,1416 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0202bd8:	8adfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202bdc:	00004697          	auipc	a3,0x4
ffffffffc0202be0:	73c68693          	addi	a3,a3,1852 # ffffffffc0207318 <default_pmm_manager+0x238>
ffffffffc0202be4:	00004617          	auipc	a2,0x4
ffffffffc0202be8:	db460613          	addi	a2,a2,-588 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202bec:	1ec00593          	li	a1,492
ffffffffc0202bf0:	00004517          	auipc	a0,0x4
ffffffffc0202bf4:	65050513          	addi	a0,a0,1616 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202bf8:	88dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202bfc:	00005697          	auipc	a3,0x5
ffffffffc0202c00:	80468693          	addi	a3,a3,-2044 # ffffffffc0207400 <default_pmm_manager+0x320>
ffffffffc0202c04:	00004617          	auipc	a2,0x4
ffffffffc0202c08:	d9460613          	addi	a2,a2,-620 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202c0c:	20800593          	li	a1,520
ffffffffc0202c10:	00004517          	auipc	a0,0x4
ffffffffc0202c14:	63050513          	addi	a0,a0,1584 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202c18:	86dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c1c:	00005697          	auipc	a3,0x5
ffffffffc0202c20:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0207678 <default_pmm_manager+0x598>
ffffffffc0202c24:	00004617          	auipc	a2,0x4
ffffffffc0202c28:	d7460613          	addi	a2,a2,-652 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202c2c:	23100593          	li	a1,561
ffffffffc0202c30:	00004517          	auipc	a0,0x4
ffffffffc0202c34:	61050513          	addi	a0,a0,1552 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202c38:	84dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c3c:	00005697          	auipc	a3,0x5
ffffffffc0202c40:	85468693          	addi	a3,a3,-1964 # ffffffffc0207490 <default_pmm_manager+0x3b0>
ffffffffc0202c44:	00004617          	auipc	a2,0x4
ffffffffc0202c48:	d5460613          	addi	a2,a2,-684 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202c4c:	20700593          	li	a1,519
ffffffffc0202c50:	00004517          	auipc	a0,0x4
ffffffffc0202c54:	5f050513          	addi	a0,a0,1520 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202c58:	82dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c5c:	00005697          	auipc	a3,0x5
ffffffffc0202c60:	8fc68693          	addi	a3,a3,-1796 # ffffffffc0207558 <default_pmm_manager+0x478>
ffffffffc0202c64:	00004617          	auipc	a2,0x4
ffffffffc0202c68:	d3460613          	addi	a2,a2,-716 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202c6c:	20600593          	li	a1,518
ffffffffc0202c70:	00004517          	auipc	a0,0x4
ffffffffc0202c74:	5d050513          	addi	a0,a0,1488 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202c78:	80dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c7c:	00005697          	auipc	a3,0x5
ffffffffc0202c80:	8c468693          	addi	a3,a3,-1852 # ffffffffc0207540 <default_pmm_manager+0x460>
ffffffffc0202c84:	00004617          	auipc	a2,0x4
ffffffffc0202c88:	d1460613          	addi	a2,a2,-748 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202c8c:	20500593          	li	a1,517
ffffffffc0202c90:	00004517          	auipc	a0,0x4
ffffffffc0202c94:	5b050513          	addi	a0,a0,1456 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202c98:	fecfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202c9c:	00005697          	auipc	a3,0x5
ffffffffc0202ca0:	87468693          	addi	a3,a3,-1932 # ffffffffc0207510 <default_pmm_manager+0x430>
ffffffffc0202ca4:	00004617          	auipc	a2,0x4
ffffffffc0202ca8:	cf460613          	addi	a2,a2,-780 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202cac:	20400593          	li	a1,516
ffffffffc0202cb0:	00004517          	auipc	a0,0x4
ffffffffc0202cb4:	59050513          	addi	a0,a0,1424 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202cb8:	fccfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cbc:	00005697          	auipc	a3,0x5
ffffffffc0202cc0:	83c68693          	addi	a3,a3,-1988 # ffffffffc02074f8 <default_pmm_manager+0x418>
ffffffffc0202cc4:	00004617          	auipc	a2,0x4
ffffffffc0202cc8:	cd460613          	addi	a2,a2,-812 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202ccc:	20200593          	li	a1,514
ffffffffc0202cd0:	00004517          	auipc	a0,0x4
ffffffffc0202cd4:	57050513          	addi	a0,a0,1392 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202cd8:	facfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202cdc:	00005697          	auipc	a3,0x5
ffffffffc0202ce0:	80468693          	addi	a3,a3,-2044 # ffffffffc02074e0 <default_pmm_manager+0x400>
ffffffffc0202ce4:	00004617          	auipc	a2,0x4
ffffffffc0202ce8:	cb460613          	addi	a2,a2,-844 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202cec:	20100593          	li	a1,513
ffffffffc0202cf0:	00004517          	auipc	a0,0x4
ffffffffc0202cf4:	55050513          	addi	a0,a0,1360 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202cf8:	f8cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202cfc:	00004697          	auipc	a3,0x4
ffffffffc0202d00:	7d468693          	addi	a3,a3,2004 # ffffffffc02074d0 <default_pmm_manager+0x3f0>
ffffffffc0202d04:	00004617          	auipc	a2,0x4
ffffffffc0202d08:	c9460613          	addi	a2,a2,-876 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202d0c:	20000593          	li	a1,512
ffffffffc0202d10:	00004517          	auipc	a0,0x4
ffffffffc0202d14:	53050513          	addi	a0,a0,1328 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202d18:	f6cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d1c:	00004697          	auipc	a3,0x4
ffffffffc0202d20:	7a468693          	addi	a3,a3,1956 # ffffffffc02074c0 <default_pmm_manager+0x3e0>
ffffffffc0202d24:	00004617          	auipc	a2,0x4
ffffffffc0202d28:	c7460613          	addi	a2,a2,-908 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202d2c:	1ff00593          	li	a1,511
ffffffffc0202d30:	00004517          	auipc	a0,0x4
ffffffffc0202d34:	51050513          	addi	a0,a0,1296 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202d38:	f4cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d3c:	00004697          	auipc	a3,0x4
ffffffffc0202d40:	75468693          	addi	a3,a3,1876 # ffffffffc0207490 <default_pmm_manager+0x3b0>
ffffffffc0202d44:	00004617          	auipc	a2,0x4
ffffffffc0202d48:	c5460613          	addi	a2,a2,-940 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202d4c:	1fe00593          	li	a1,510
ffffffffc0202d50:	00004517          	auipc	a0,0x4
ffffffffc0202d54:	4f050513          	addi	a0,a0,1264 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202d58:	f2cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d5c:	00004697          	auipc	a3,0x4
ffffffffc0202d60:	6fc68693          	addi	a3,a3,1788 # ffffffffc0207458 <default_pmm_manager+0x378>
ffffffffc0202d64:	00004617          	auipc	a2,0x4
ffffffffc0202d68:	c3460613          	addi	a2,a2,-972 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202d6c:	1fd00593          	li	a1,509
ffffffffc0202d70:	00004517          	auipc	a0,0x4
ffffffffc0202d74:	4d050513          	addi	a0,a0,1232 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202d78:	f0cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d7c:	00004697          	auipc	a3,0x4
ffffffffc0202d80:	6b468693          	addi	a3,a3,1716 # ffffffffc0207430 <default_pmm_manager+0x350>
ffffffffc0202d84:	00004617          	auipc	a2,0x4
ffffffffc0202d88:	c1460613          	addi	a2,a2,-1004 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202d8c:	1fa00593          	li	a1,506
ffffffffc0202d90:	00004517          	auipc	a0,0x4
ffffffffc0202d94:	4b050513          	addi	a0,a0,1200 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202d98:	eecfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d9c:	86da                	mv	a3,s6
ffffffffc0202d9e:	00004617          	auipc	a2,0x4
ffffffffc0202da2:	39260613          	addi	a2,a2,914 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0202da6:	1f900593          	li	a1,505
ffffffffc0202daa:	00004517          	auipc	a0,0x4
ffffffffc0202dae:	49650513          	addi	a0,a0,1174 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202db2:	ed2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202db6:	86be                	mv	a3,a5
ffffffffc0202db8:	00004617          	auipc	a2,0x4
ffffffffc0202dbc:	37860613          	addi	a2,a2,888 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0202dc0:	06900593          	li	a1,105
ffffffffc0202dc4:	00004517          	auipc	a0,0x4
ffffffffc0202dc8:	39450513          	addi	a0,a0,916 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0202dcc:	eb8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202dd0:	00004697          	auipc	a3,0x4
ffffffffc0202dd4:	7d068693          	addi	a3,a3,2000 # ffffffffc02075a0 <default_pmm_manager+0x4c0>
ffffffffc0202dd8:	00004617          	auipc	a2,0x4
ffffffffc0202ddc:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202de0:	21300593          	li	a1,531
ffffffffc0202de4:	00004517          	auipc	a0,0x4
ffffffffc0202de8:	45c50513          	addi	a0,a0,1116 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202dec:	e98fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202df0:	00004697          	auipc	a3,0x4
ffffffffc0202df4:	76868693          	addi	a3,a3,1896 # ffffffffc0207558 <default_pmm_manager+0x478>
ffffffffc0202df8:	00004617          	auipc	a2,0x4
ffffffffc0202dfc:	ba060613          	addi	a2,a2,-1120 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202e00:	21100593          	li	a1,529
ffffffffc0202e04:	00004517          	auipc	a0,0x4
ffffffffc0202e08:	43c50513          	addi	a0,a0,1084 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202e0c:	e78fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e10:	00004697          	auipc	a3,0x4
ffffffffc0202e14:	77868693          	addi	a3,a3,1912 # ffffffffc0207588 <default_pmm_manager+0x4a8>
ffffffffc0202e18:	00004617          	auipc	a2,0x4
ffffffffc0202e1c:	b8060613          	addi	a2,a2,-1152 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202e20:	21000593          	li	a1,528
ffffffffc0202e24:	00004517          	auipc	a0,0x4
ffffffffc0202e28:	41c50513          	addi	a0,a0,1052 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202e2c:	e58fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e30:	00005697          	auipc	a3,0x5
ffffffffc0202e34:	8d868693          	addi	a3,a3,-1832 # ffffffffc0207708 <default_pmm_manager+0x628>
ffffffffc0202e38:	00004617          	auipc	a2,0x4
ffffffffc0202e3c:	b6060613          	addi	a2,a2,-1184 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202e40:	23400593          	li	a1,564
ffffffffc0202e44:	00004517          	auipc	a0,0x4
ffffffffc0202e48:	3fc50513          	addi	a0,a0,1020 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202e4c:	e38fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e50:	00005697          	auipc	a3,0x5
ffffffffc0202e54:	87868693          	addi	a3,a3,-1928 # ffffffffc02076c8 <default_pmm_manager+0x5e8>
ffffffffc0202e58:	00004617          	auipc	a2,0x4
ffffffffc0202e5c:	b4060613          	addi	a2,a2,-1216 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202e60:	23300593          	li	a1,563
ffffffffc0202e64:	00004517          	auipc	a0,0x4
ffffffffc0202e68:	3dc50513          	addi	a0,a0,988 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202e6c:	e18fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e70:	00005697          	auipc	a3,0x5
ffffffffc0202e74:	84068693          	addi	a3,a3,-1984 # ffffffffc02076b0 <default_pmm_manager+0x5d0>
ffffffffc0202e78:	00004617          	auipc	a2,0x4
ffffffffc0202e7c:	b2060613          	addi	a2,a2,-1248 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202e80:	23200593          	li	a1,562
ffffffffc0202e84:	00004517          	auipc	a0,0x4
ffffffffc0202e88:	3bc50513          	addi	a0,a0,956 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202e8c:	df8fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202e90:	86be                	mv	a3,a5
ffffffffc0202e92:	00004617          	auipc	a2,0x4
ffffffffc0202e96:	29e60613          	addi	a2,a2,670 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0202e9a:	1f800593          	li	a1,504
ffffffffc0202e9e:	00004517          	auipc	a0,0x4
ffffffffc0202ea2:	3a250513          	addi	a0,a0,930 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202ea6:	ddefd0ef          	jal	ra,ffffffffc0200484 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202eaa:	00004617          	auipc	a2,0x4
ffffffffc0202eae:	2be60613          	addi	a2,a2,702 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc0202eb2:	07f00593          	li	a1,127
ffffffffc0202eb6:	00004517          	auipc	a0,0x4
ffffffffc0202eba:	38a50513          	addi	a0,a0,906 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202ebe:	dc6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ec2:	00005697          	auipc	a3,0x5
ffffffffc0202ec6:	87668693          	addi	a3,a3,-1930 # ffffffffc0207738 <default_pmm_manager+0x658>
ffffffffc0202eca:	00004617          	auipc	a2,0x4
ffffffffc0202ece:	ace60613          	addi	a2,a2,-1330 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202ed2:	23800593          	li	a1,568
ffffffffc0202ed6:	00004517          	auipc	a0,0x4
ffffffffc0202eda:	36a50513          	addi	a0,a0,874 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202ede:	da6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ee2:	00004697          	auipc	a3,0x4
ffffffffc0202ee6:	6e668693          	addi	a3,a3,1766 # ffffffffc02075c8 <default_pmm_manager+0x4e8>
ffffffffc0202eea:	00004617          	auipc	a2,0x4
ffffffffc0202eee:	aae60613          	addi	a2,a2,-1362 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202ef2:	24400593          	li	a1,580
ffffffffc0202ef6:	00004517          	auipc	a0,0x4
ffffffffc0202efa:	34a50513          	addi	a0,a0,842 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202efe:	d86fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f02:	00004697          	auipc	a3,0x4
ffffffffc0202f06:	51668693          	addi	a3,a3,1302 # ffffffffc0207418 <default_pmm_manager+0x338>
ffffffffc0202f0a:	00004617          	auipc	a2,0x4
ffffffffc0202f0e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202f12:	1f600593          	li	a1,502
ffffffffc0202f16:	00004517          	auipc	a0,0x4
ffffffffc0202f1a:	32a50513          	addi	a0,a0,810 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202f1e:	d66fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f22:	00004697          	auipc	a3,0x4
ffffffffc0202f26:	4de68693          	addi	a3,a3,1246 # ffffffffc0207400 <default_pmm_manager+0x320>
ffffffffc0202f2a:	00004617          	auipc	a2,0x4
ffffffffc0202f2e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202f32:	1f500593          	li	a1,501
ffffffffc0202f36:	00004517          	auipc	a0,0x4
ffffffffc0202f3a:	30a50513          	addi	a0,a0,778 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202f3e:	d46fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f42:	00004697          	auipc	a3,0x4
ffffffffc0202f46:	40e68693          	addi	a3,a3,1038 # ffffffffc0207350 <default_pmm_manager+0x270>
ffffffffc0202f4a:	00004617          	auipc	a2,0x4
ffffffffc0202f4e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202f52:	1ed00593          	li	a1,493
ffffffffc0202f56:	00004517          	auipc	a0,0x4
ffffffffc0202f5a:	2ea50513          	addi	a0,a0,746 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202f5e:	d26fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f62:	00004697          	auipc	a3,0x4
ffffffffc0202f66:	44668693          	addi	a3,a3,1094 # ffffffffc02073a8 <default_pmm_manager+0x2c8>
ffffffffc0202f6a:	00004617          	auipc	a2,0x4
ffffffffc0202f6e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202f72:	1f400593          	li	a1,500
ffffffffc0202f76:	00004517          	auipc	a0,0x4
ffffffffc0202f7a:	2ca50513          	addi	a0,a0,714 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202f7e:	d06fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f82:	00004697          	auipc	a3,0x4
ffffffffc0202f86:	3f668693          	addi	a3,a3,1014 # ffffffffc0207378 <default_pmm_manager+0x298>
ffffffffc0202f8a:	00004617          	auipc	a2,0x4
ffffffffc0202f8e:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202f92:	1f100593          	li	a1,497
ffffffffc0202f96:	00004517          	auipc	a0,0x4
ffffffffc0202f9a:	2aa50513          	addi	a0,a0,682 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202f9e:	ce6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fa2:	00004697          	auipc	a3,0x4
ffffffffc0202fa6:	5b668693          	addi	a3,a3,1462 # ffffffffc0207558 <default_pmm_manager+0x478>
ffffffffc0202faa:	00004617          	auipc	a2,0x4
ffffffffc0202fae:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202fb2:	20d00593          	li	a1,525
ffffffffc0202fb6:	00004517          	auipc	a0,0x4
ffffffffc0202fba:	28a50513          	addi	a0,a0,650 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202fbe:	cc6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fc2:	00004697          	auipc	a3,0x4
ffffffffc0202fc6:	45668693          	addi	a3,a3,1110 # ffffffffc0207418 <default_pmm_manager+0x338>
ffffffffc0202fca:	00004617          	auipc	a2,0x4
ffffffffc0202fce:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202fd2:	20c00593          	li	a1,524
ffffffffc0202fd6:	00004517          	auipc	a0,0x4
ffffffffc0202fda:	26a50513          	addi	a0,a0,618 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202fde:	ca6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202fe2:	00004697          	auipc	a3,0x4
ffffffffc0202fe6:	58e68693          	addi	a3,a3,1422 # ffffffffc0207570 <default_pmm_manager+0x490>
ffffffffc0202fea:	00004617          	auipc	a2,0x4
ffffffffc0202fee:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0202ff2:	20900593          	li	a1,521
ffffffffc0202ff6:	00004517          	auipc	a0,0x4
ffffffffc0202ffa:	24a50513          	addi	a0,a0,586 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0202ffe:	c86fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203002:	00004697          	auipc	a3,0x4
ffffffffc0203006:	76e68693          	addi	a3,a3,1902 # ffffffffc0207770 <default_pmm_manager+0x690>
ffffffffc020300a:	00004617          	auipc	a2,0x4
ffffffffc020300e:	98e60613          	addi	a2,a2,-1650 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203012:	23b00593          	li	a1,571
ffffffffc0203016:	00004517          	auipc	a0,0x4
ffffffffc020301a:	22a50513          	addi	a0,a0,554 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020301e:	c66fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203022:	00004697          	auipc	a3,0x4
ffffffffc0203026:	5a668693          	addi	a3,a3,1446 # ffffffffc02075c8 <default_pmm_manager+0x4e8>
ffffffffc020302a:	00004617          	auipc	a2,0x4
ffffffffc020302e:	96e60613          	addi	a2,a2,-1682 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203032:	21b00593          	li	a1,539
ffffffffc0203036:	00004517          	auipc	a0,0x4
ffffffffc020303a:	20a50513          	addi	a0,a0,522 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020303e:	c46fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203042:	00004697          	auipc	a3,0x4
ffffffffc0203046:	61e68693          	addi	a3,a3,1566 # ffffffffc0207660 <default_pmm_manager+0x580>
ffffffffc020304a:	00004617          	auipc	a2,0x4
ffffffffc020304e:	94e60613          	addi	a2,a2,-1714 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203052:	22d00593          	li	a1,557
ffffffffc0203056:	00004517          	auipc	a0,0x4
ffffffffc020305a:	1ea50513          	addi	a0,a0,490 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020305e:	c26fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203062:	00004697          	auipc	a3,0x4
ffffffffc0203066:	29668693          	addi	a3,a3,662 # ffffffffc02072f8 <default_pmm_manager+0x218>
ffffffffc020306a:	00004617          	auipc	a2,0x4
ffffffffc020306e:	92e60613          	addi	a2,a2,-1746 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203072:	1eb00593          	li	a1,491
ffffffffc0203076:	00004517          	auipc	a0,0x4
ffffffffc020307a:	1ca50513          	addi	a0,a0,458 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020307e:	c06fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203082:	00004617          	auipc	a2,0x4
ffffffffc0203086:	0e660613          	addi	a2,a2,230 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc020308a:	0c100593          	li	a1,193
ffffffffc020308e:	00004517          	auipc	a0,0x4
ffffffffc0203092:	1b250513          	addi	a0,a0,434 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0203096:	beefd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020309a <copy_range>:
               bool share) {
ffffffffc020309a:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020309c:	00d66733          	or	a4,a2,a3
               bool share) {
ffffffffc02030a0:	fc86                	sd	ra,120(sp)
ffffffffc02030a2:	f8a2                	sd	s0,112(sp)
ffffffffc02030a4:	f4a6                	sd	s1,104(sp)
ffffffffc02030a6:	f0ca                	sd	s2,96(sp)
ffffffffc02030a8:	ecce                	sd	s3,88(sp)
ffffffffc02030aa:	e8d2                	sd	s4,80(sp)
ffffffffc02030ac:	e4d6                	sd	s5,72(sp)
ffffffffc02030ae:	e0da                	sd	s6,64(sp)
ffffffffc02030b0:	fc5e                	sd	s7,56(sp)
ffffffffc02030b2:	f862                	sd	s8,48(sp)
ffffffffc02030b4:	f466                	sd	s9,40(sp)
ffffffffc02030b6:	f06a                	sd	s10,32(sp)
ffffffffc02030b8:	ec6e                	sd	s11,24(sp)
ffffffffc02030ba:	e42a                	sd	a0,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030bc:	03471793          	slli	a5,a4,0x34
ffffffffc02030c0:	1c079f63          	bnez	a5,ffffffffc020329e <copy_range+0x204>
    assert(USER_ACCESS(start, end));
ffffffffc02030c4:	00200737          	lui	a4,0x200
ffffffffc02030c8:	8db2                	mv	s11,a2
ffffffffc02030ca:	18e66a63          	bltu	a2,a4,ffffffffc020325e <copy_range+0x1c4>
ffffffffc02030ce:	8436                	mv	s0,a3
ffffffffc02030d0:	18d67763          	bleu	a3,a2,ffffffffc020325e <copy_range+0x1c4>
ffffffffc02030d4:	4705                	li	a4,1
ffffffffc02030d6:	077e                	slli	a4,a4,0x1f
ffffffffc02030d8:	18d76363          	bltu	a4,a3,ffffffffc020325e <copy_range+0x1c4>
ffffffffc02030dc:	5a7d                	li	s4,-1
ffffffffc02030de:	84ae                	mv	s1,a1
        start += PGSIZE;
ffffffffc02030e0:	6905                	lui	s2,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030e2:	000a9b17          	auipc	s6,0xa9
ffffffffc02030e6:	4b6b0b13          	addi	s6,s6,1206 # ffffffffc02ac598 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030ea:	000a9a97          	auipc	s5,0xa9
ffffffffc02030ee:	51ea8a93          	addi	s5,s5,1310 # ffffffffc02ac608 <pages>
    return page - pages + nbase;
ffffffffc02030f2:	00080bb7          	lui	s7,0x80
    return KADDR(page2pa(page));
ffffffffc02030f6:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02030fa:	4601                	li	a2,0
ffffffffc02030fc:	85ee                	mv	a1,s11
ffffffffc02030fe:	8526                	mv	a0,s1
ffffffffc0203100:	e3dfe0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc0203104:	8c2a                	mv	s8,a0
        if (ptep == NULL) {
ffffffffc0203106:	c961                	beqz	a0,ffffffffc02031d6 <copy_range+0x13c>
        if (*ptep & PTE_V) {
ffffffffc0203108:	6118                	ld	a4,0(a0)
ffffffffc020310a:	8b05                	andi	a4,a4,1
ffffffffc020310c:	e705                	bnez	a4,ffffffffc0203134 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc020310e:	9dca                	add	s11,s11,s2
    } while (start != 0 && start < end);
ffffffffc0203110:	fe8de5e3          	bltu	s11,s0,ffffffffc02030fa <copy_range+0x60>
    return 0;
ffffffffc0203114:	4501                	li	a0,0
}
ffffffffc0203116:	70e6                	ld	ra,120(sp)
ffffffffc0203118:	7446                	ld	s0,112(sp)
ffffffffc020311a:	74a6                	ld	s1,104(sp)
ffffffffc020311c:	7906                	ld	s2,96(sp)
ffffffffc020311e:	69e6                	ld	s3,88(sp)
ffffffffc0203120:	6a46                	ld	s4,80(sp)
ffffffffc0203122:	6aa6                	ld	s5,72(sp)
ffffffffc0203124:	6b06                	ld	s6,64(sp)
ffffffffc0203126:	7be2                	ld	s7,56(sp)
ffffffffc0203128:	7c42                	ld	s8,48(sp)
ffffffffc020312a:	7ca2                	ld	s9,40(sp)
ffffffffc020312c:	7d02                	ld	s10,32(sp)
ffffffffc020312e:	6de2                	ld	s11,24(sp)
ffffffffc0203130:	6109                	addi	sp,sp,128
ffffffffc0203132:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203134:	6522                	ld	a0,8(sp)
ffffffffc0203136:	4605                	li	a2,1
ffffffffc0203138:	85ee                	mv	a1,s11
ffffffffc020313a:	e03fe0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc020313e:	89aa                	mv	s3,a0
ffffffffc0203140:	c945                	beqz	a0,ffffffffc02031f0 <copy_range+0x156>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203142:	000c3703          	ld	a4,0(s8) # 200000 <_binary_obj___user_exit_out_size+0x1f5570>
    if (!(pte & PTE_V)) {
ffffffffc0203146:	00177693          	andi	a3,a4,1
ffffffffc020314a:	01f77c13          	andi	s8,a4,31
ffffffffc020314e:	0e068c63          	beqz	a3,ffffffffc0203246 <copy_range+0x1ac>
    if (PPN(pa) >= npage) {
ffffffffc0203152:	000b3603          	ld	a2,0(s6)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203156:	070a                	slli	a4,a4,0x2
ffffffffc0203158:	00c75693          	srli	a3,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc020315c:	0cc6f963          	bleu	a2,a3,ffffffffc020322e <copy_range+0x194>
    return &pages[PPN(pa) - nbase];
ffffffffc0203160:	000ab703          	ld	a4,0(s5)
ffffffffc0203164:	fff807b7          	lui	a5,0xfff80
ffffffffc0203168:	96be                	add	a3,a3,a5
ffffffffc020316a:	069a                	slli	a3,a3,0x6
            struct Page *npage = alloc_page();
ffffffffc020316c:	4505                	li	a0,1
ffffffffc020316e:	00d70cb3          	add	s9,a4,a3
ffffffffc0203172:	cbdfe0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0203176:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc0203178:	080c8b63          	beqz	s9,ffffffffc020320e <copy_range+0x174>
            assert(npage != NULL);
ffffffffc020317c:	10050163          	beqz	a0,ffffffffc020327e <copy_range+0x1e4>
    return page - pages + nbase;
ffffffffc0203180:	000ab603          	ld	a2,0(s5)
    return KADDR(page2pa(page));
ffffffffc0203184:	000b3503          	ld	a0,0(s6)
    return page - pages + nbase;
ffffffffc0203188:	40cc86b3          	sub	a3,s9,a2
ffffffffc020318c:	8699                	srai	a3,a3,0x6
ffffffffc020318e:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0203190:	0146f733          	and	a4,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0203194:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203196:	06a77063          	bleu	a0,a4,ffffffffc02031f6 <copy_range+0x15c>
    return page - pages + nbase;
ffffffffc020319a:	40cd0733          	sub	a4,s10,a2
    return KADDR(page2pa(page));
ffffffffc020319e:	000a9797          	auipc	a5,0xa9
ffffffffc02031a2:	45a78793          	addi	a5,a5,1114 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc02031a6:	6390                	ld	a2,0(a5)
    return page - pages + nbase;
ffffffffc02031a8:	8719                	srai	a4,a4,0x6
ffffffffc02031aa:	975e                	add	a4,a4,s7
    return KADDR(page2pa(page));
ffffffffc02031ac:	014778b3          	and	a7,a4,s4
ffffffffc02031b0:	00c685b3          	add	a1,a3,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02031b4:	0732                	slli	a4,a4,0xc
    return KADDR(page2pa(page));
ffffffffc02031b6:	02a8ff63          	bleu	a0,a7,ffffffffc02031f4 <copy_range+0x15a>
ffffffffc02031ba:	00c70cb3          	add	s9,a4,a2
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02031be:	8566                	mv	a0,s9
ffffffffc02031c0:	6605                	lui	a2,0x1
ffffffffc02031c2:	1c8030ef          	jal	ra,ffffffffc020638a <memcpy>
            page_insert(nptep, npage, dst_kvaddr, perm);
ffffffffc02031c6:	86e2                	mv	a3,s8
ffffffffc02031c8:	8666                	mv	a2,s9
ffffffffc02031ca:	85ea                	mv	a1,s10
ffffffffc02031cc:	854e                	mv	a0,s3
ffffffffc02031ce:	b84ff0ef          	jal	ra,ffffffffc0202552 <page_insert>
        start += PGSIZE;
ffffffffc02031d2:	9dca                	add	s11,s11,s2
ffffffffc02031d4:	bf35                	j	ffffffffc0203110 <copy_range+0x76>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02031d6:	00200737          	lui	a4,0x200
ffffffffc02031da:	00ed87b3          	add	a5,s11,a4
ffffffffc02031de:	ffe00737          	lui	a4,0xffe00
ffffffffc02031e2:	00e7fdb3          	and	s11,a5,a4
    } while (start != 0 && start < end);
ffffffffc02031e6:	f20d87e3          	beqz	s11,ffffffffc0203114 <copy_range+0x7a>
ffffffffc02031ea:	f08de8e3          	bltu	s11,s0,ffffffffc02030fa <copy_range+0x60>
ffffffffc02031ee:	b71d                	j	ffffffffc0203114 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc02031f0:	5571                	li	a0,-4
ffffffffc02031f2:	b715                	j	ffffffffc0203116 <copy_range+0x7c>
ffffffffc02031f4:	86ba                	mv	a3,a4
ffffffffc02031f6:	00004617          	auipc	a2,0x4
ffffffffc02031fa:	f3a60613          	addi	a2,a2,-198 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02031fe:	06900593          	li	a1,105
ffffffffc0203202:	00004517          	auipc	a0,0x4
ffffffffc0203206:	f5650513          	addi	a0,a0,-170 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc020320a:	a7afd0ef          	jal	ra,ffffffffc0200484 <__panic>
            assert(page != NULL);
ffffffffc020320e:	00004697          	auipc	a3,0x4
ffffffffc0203212:	01268693          	addi	a3,a3,18 # ffffffffc0207220 <default_pmm_manager+0x140>
ffffffffc0203216:	00003617          	auipc	a2,0x3
ffffffffc020321a:	78260613          	addi	a2,a2,1922 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020321e:	17200593          	li	a1,370
ffffffffc0203222:	00004517          	auipc	a0,0x4
ffffffffc0203226:	01e50513          	addi	a0,a0,30 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020322a:	a5afd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020322e:	00004617          	auipc	a2,0x4
ffffffffc0203232:	f6260613          	addi	a2,a2,-158 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc0203236:	06200593          	li	a1,98
ffffffffc020323a:	00004517          	auipc	a0,0x4
ffffffffc020323e:	f1e50513          	addi	a0,a0,-226 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0203242:	a42fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203246:	00004617          	auipc	a2,0x4
ffffffffc020324a:	19260613          	addi	a2,a2,402 # ffffffffc02073d8 <default_pmm_manager+0x2f8>
ffffffffc020324e:	07400593          	li	a1,116
ffffffffc0203252:	00004517          	auipc	a0,0x4
ffffffffc0203256:	f0650513          	addi	a0,a0,-250 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc020325a:	a2afd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020325e:	00004697          	auipc	a3,0x4
ffffffffc0203262:	58a68693          	addi	a3,a3,1418 # ffffffffc02077e8 <default_pmm_manager+0x708>
ffffffffc0203266:	00003617          	auipc	a2,0x3
ffffffffc020326a:	73260613          	addi	a2,a2,1842 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020326e:	15e00593          	li	a1,350
ffffffffc0203272:	00004517          	auipc	a0,0x4
ffffffffc0203276:	fce50513          	addi	a0,a0,-50 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020327a:	a0afd0ef          	jal	ra,ffffffffc0200484 <__panic>
            assert(npage != NULL);
ffffffffc020327e:	00004697          	auipc	a3,0x4
ffffffffc0203282:	fb268693          	addi	a3,a3,-78 # ffffffffc0207230 <default_pmm_manager+0x150>
ffffffffc0203286:	00003617          	auipc	a2,0x3
ffffffffc020328a:	71260613          	addi	a2,a2,1810 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020328e:	17300593          	li	a1,371
ffffffffc0203292:	00004517          	auipc	a0,0x4
ffffffffc0203296:	fae50513          	addi	a0,a0,-82 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc020329a:	9eafd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020329e:	00004697          	auipc	a3,0x4
ffffffffc02032a2:	51a68693          	addi	a3,a3,1306 # ffffffffc02077b8 <default_pmm_manager+0x6d8>
ffffffffc02032a6:	00003617          	auipc	a2,0x3
ffffffffc02032aa:	6f260613          	addi	a2,a2,1778 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02032ae:	15d00593          	li	a1,349
ffffffffc02032b2:	00004517          	auipc	a0,0x4
ffffffffc02032b6:	f8e50513          	addi	a0,a0,-114 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc02032ba:	9cafd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02032be <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032be:	12058073          	sfence.vma	a1
}
ffffffffc02032c2:	8082                	ret

ffffffffc02032c4 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032c4:	7179                	addi	sp,sp,-48
ffffffffc02032c6:	e84a                	sd	s2,16(sp)
ffffffffc02032c8:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032ca:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032cc:	f022                	sd	s0,32(sp)
ffffffffc02032ce:	ec26                	sd	s1,24(sp)
ffffffffc02032d0:	e44e                	sd	s3,8(sp)
ffffffffc02032d2:	f406                	sd	ra,40(sp)
ffffffffc02032d4:	84ae                	mv	s1,a1
ffffffffc02032d6:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032d8:	b57fe0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc02032dc:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02032de:	cd1d                	beqz	a0,ffffffffc020331c <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02032e0:	85aa                	mv	a1,a0
ffffffffc02032e2:	86ce                	mv	a3,s3
ffffffffc02032e4:	8626                	mv	a2,s1
ffffffffc02032e6:	854a                	mv	a0,s2
ffffffffc02032e8:	a6aff0ef          	jal	ra,ffffffffc0202552 <page_insert>
ffffffffc02032ec:	e121                	bnez	a0,ffffffffc020332c <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc02032ee:	000a9797          	auipc	a5,0xa9
ffffffffc02032f2:	2ba78793          	addi	a5,a5,698 # ffffffffc02ac5a8 <swap_init_ok>
ffffffffc02032f6:	439c                	lw	a5,0(a5)
ffffffffc02032f8:	2781                	sext.w	a5,a5
ffffffffc02032fa:	c38d                	beqz	a5,ffffffffc020331c <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc02032fc:	000a9797          	auipc	a5,0xa9
ffffffffc0203300:	3ec78793          	addi	a5,a5,1004 # ffffffffc02ac6e8 <check_mm_struct>
ffffffffc0203304:	6388                	ld	a0,0(a5)
ffffffffc0203306:	c919                	beqz	a0,ffffffffc020331c <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203308:	4681                	li	a3,0
ffffffffc020330a:	8622                	mv	a2,s0
ffffffffc020330c:	85a6                	mv	a1,s1
ffffffffc020330e:	7da000ef          	jal	ra,ffffffffc0203ae8 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203312:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203314:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203316:	4785                	li	a5,1
ffffffffc0203318:	02f71063          	bne	a4,a5,ffffffffc0203338 <pgdir_alloc_page+0x74>
}
ffffffffc020331c:	8522                	mv	a0,s0
ffffffffc020331e:	70a2                	ld	ra,40(sp)
ffffffffc0203320:	7402                	ld	s0,32(sp)
ffffffffc0203322:	64e2                	ld	s1,24(sp)
ffffffffc0203324:	6942                	ld	s2,16(sp)
ffffffffc0203326:	69a2                	ld	s3,8(sp)
ffffffffc0203328:	6145                	addi	sp,sp,48
ffffffffc020332a:	8082                	ret
            free_page(page);
ffffffffc020332c:	8522                	mv	a0,s0
ffffffffc020332e:	4585                	li	a1,1
ffffffffc0203330:	b87fe0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
            return NULL;
ffffffffc0203334:	4401                	li	s0,0
ffffffffc0203336:	b7dd                	j	ffffffffc020331c <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0203338:	00004697          	auipc	a3,0x4
ffffffffc020333c:	f1868693          	addi	a3,a3,-232 # ffffffffc0207250 <default_pmm_manager+0x170>
ffffffffc0203340:	00003617          	auipc	a2,0x3
ffffffffc0203344:	65860613          	addi	a2,a2,1624 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203348:	1cc00593          	li	a1,460
ffffffffc020334c:	00004517          	auipc	a0,0x4
ffffffffc0203350:	ef450513          	addi	a0,a0,-268 # ffffffffc0207240 <default_pmm_manager+0x160>
ffffffffc0203354:	930fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203358 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0203358:	7135                	addi	sp,sp,-160
ffffffffc020335a:	ed06                	sd	ra,152(sp)
ffffffffc020335c:	e922                	sd	s0,144(sp)
ffffffffc020335e:	e526                	sd	s1,136(sp)
ffffffffc0203360:	e14a                	sd	s2,128(sp)
ffffffffc0203362:	fcce                	sd	s3,120(sp)
ffffffffc0203364:	f8d2                	sd	s4,112(sp)
ffffffffc0203366:	f4d6                	sd	s5,104(sp)
ffffffffc0203368:	f0da                	sd	s6,96(sp)
ffffffffc020336a:	ecde                	sd	s7,88(sp)
ffffffffc020336c:	e8e2                	sd	s8,80(sp)
ffffffffc020336e:	e4e6                	sd	s9,72(sp)
ffffffffc0203370:	e0ea                	sd	s10,64(sp)
ffffffffc0203372:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203374:	6dc010ef          	jal	ra,ffffffffc0204a50 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0203378:	000a9797          	auipc	a5,0xa9
ffffffffc020337c:	32078793          	addi	a5,a5,800 # ffffffffc02ac698 <max_swap_offset>
ffffffffc0203380:	6394                	ld	a3,0(a5)
ffffffffc0203382:	010007b7          	lui	a5,0x1000
ffffffffc0203386:	17e1                	addi	a5,a5,-8
ffffffffc0203388:	ff968713          	addi	a4,a3,-7
ffffffffc020338c:	4ae7ee63          	bltu	a5,a4,ffffffffc0203848 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203390:	0009e797          	auipc	a5,0x9e
ffffffffc0203394:	d9878793          	addi	a5,a5,-616 # ffffffffc02a1128 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203398:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc020339a:	000a9697          	auipc	a3,0xa9
ffffffffc020339e:	20f6b323          	sd	a5,518(a3) # ffffffffc02ac5a0 <sm>
     int r = sm->init();
ffffffffc02033a2:	9702                	jalr	a4
ffffffffc02033a4:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033a6:	c10d                	beqz	a0,ffffffffc02033c8 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033a8:	60ea                	ld	ra,152(sp)
ffffffffc02033aa:	644a                	ld	s0,144(sp)
ffffffffc02033ac:	8556                	mv	a0,s5
ffffffffc02033ae:	64aa                	ld	s1,136(sp)
ffffffffc02033b0:	690a                	ld	s2,128(sp)
ffffffffc02033b2:	79e6                	ld	s3,120(sp)
ffffffffc02033b4:	7a46                	ld	s4,112(sp)
ffffffffc02033b6:	7aa6                	ld	s5,104(sp)
ffffffffc02033b8:	7b06                	ld	s6,96(sp)
ffffffffc02033ba:	6be6                	ld	s7,88(sp)
ffffffffc02033bc:	6c46                	ld	s8,80(sp)
ffffffffc02033be:	6ca6                	ld	s9,72(sp)
ffffffffc02033c0:	6d06                	ld	s10,64(sp)
ffffffffc02033c2:	7de2                	ld	s11,56(sp)
ffffffffc02033c4:	610d                	addi	sp,sp,160
ffffffffc02033c6:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033c8:	000a9797          	auipc	a5,0xa9
ffffffffc02033cc:	1d878793          	addi	a5,a5,472 # ffffffffc02ac5a0 <sm>
ffffffffc02033d0:	639c                	ld	a5,0(a5)
ffffffffc02033d2:	00004517          	auipc	a0,0x4
ffffffffc02033d6:	45e50513          	addi	a0,a0,1118 # ffffffffc0207830 <default_pmm_manager+0x750>
    return listelm->next;
ffffffffc02033da:	000a9417          	auipc	s0,0xa9
ffffffffc02033de:	1fe40413          	addi	s0,s0,510 # ffffffffc02ac5d8 <free_area>
ffffffffc02033e2:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02033e4:	4785                	li	a5,1
ffffffffc02033e6:	000a9717          	auipc	a4,0xa9
ffffffffc02033ea:	1cf72123          	sw	a5,450(a4) # ffffffffc02ac5a8 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033ee:	da1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02033f2:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02033f4:	36878e63          	beq	a5,s0,ffffffffc0203770 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02033f8:	ff07b703          	ld	a4,-16(a5)
ffffffffc02033fc:	8305                	srli	a4,a4,0x1
ffffffffc02033fe:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203400:	36070c63          	beqz	a4,ffffffffc0203778 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203404:	4481                	li	s1,0
ffffffffc0203406:	4901                	li	s2,0
ffffffffc0203408:	a031                	j	ffffffffc0203414 <swap_init+0xbc>
ffffffffc020340a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020340e:	8b09                	andi	a4,a4,2
ffffffffc0203410:	36070463          	beqz	a4,ffffffffc0203778 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203414:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203418:	679c                	ld	a5,8(a5)
ffffffffc020341a:	2905                	addiw	s2,s2,1
ffffffffc020341c:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020341e:	fe8796e3          	bne	a5,s0,ffffffffc020340a <swap_init+0xb2>
ffffffffc0203422:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203424:	ad9fe0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>
ffffffffc0203428:	69351863          	bne	a0,s3,ffffffffc0203ab8 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020342c:	8626                	mv	a2,s1
ffffffffc020342e:	85ca                	mv	a1,s2
ffffffffc0203430:	00004517          	auipc	a0,0x4
ffffffffc0203434:	41850513          	addi	a0,a0,1048 # ffffffffc0207848 <default_pmm_manager+0x768>
ffffffffc0203438:	d57fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020343c:	3dd000ef          	jal	ra,ffffffffc0204018 <mm_create>
ffffffffc0203440:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203442:	60050b63          	beqz	a0,ffffffffc0203a58 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203446:	000a9797          	auipc	a5,0xa9
ffffffffc020344a:	2a278793          	addi	a5,a5,674 # ffffffffc02ac6e8 <check_mm_struct>
ffffffffc020344e:	639c                	ld	a5,0(a5)
ffffffffc0203450:	62079463          	bnez	a5,ffffffffc0203a78 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203454:	000a9797          	auipc	a5,0xa9
ffffffffc0203458:	13c78793          	addi	a5,a5,316 # ffffffffc02ac590 <boot_pgdir>
ffffffffc020345c:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203460:	000a9797          	auipc	a5,0xa9
ffffffffc0203464:	28a7b423          	sd	a0,648(a5) # ffffffffc02ac6e8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0203468:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020346c:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203470:	4e079863          	bnez	a5,ffffffffc0203960 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203474:	6599                	lui	a1,0x6
ffffffffc0203476:	460d                	li	a2,3
ffffffffc0203478:	6505                	lui	a0,0x1
ffffffffc020347a:	3eb000ef          	jal	ra,ffffffffc0204064 <vma_create>
ffffffffc020347e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203480:	50050063          	beqz	a0,ffffffffc0203980 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc0203484:	855e                	mv	a0,s7
ffffffffc0203486:	44b000ef          	jal	ra,ffffffffc02040d0 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020348a:	00004517          	auipc	a0,0x4
ffffffffc020348e:	42e50513          	addi	a0,a0,1070 # ffffffffc02078b8 <default_pmm_manager+0x7d8>
ffffffffc0203492:	cfdfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0203496:	018bb503          	ld	a0,24(s7) # 80018 <_binary_obj___user_exit_out_size+0x75588>
ffffffffc020349a:	4605                	li	a2,1
ffffffffc020349c:	6585                	lui	a1,0x1
ffffffffc020349e:	a9ffe0ef          	jal	ra,ffffffffc0201f3c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034a2:	4e050f63          	beqz	a0,ffffffffc02039a0 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034a6:	00004517          	auipc	a0,0x4
ffffffffc02034aa:	46250513          	addi	a0,a0,1122 # ffffffffc0207908 <default_pmm_manager+0x828>
ffffffffc02034ae:	000a9997          	auipc	s3,0xa9
ffffffffc02034b2:	16298993          	addi	s3,s3,354 # ffffffffc02ac610 <check_rp>
ffffffffc02034b6:	cd9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034ba:	000a9a17          	auipc	s4,0xa9
ffffffffc02034be:	176a0a13          	addi	s4,s4,374 # ffffffffc02ac630 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034c2:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034c4:	4505                	li	a0,1
ffffffffc02034c6:	969fe0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc02034ca:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034ce:	32050d63          	beqz	a0,ffffffffc0203808 <swap_init+0x4b0>
ffffffffc02034d2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034d4:	8b89                	andi	a5,a5,2
ffffffffc02034d6:	30079963          	bnez	a5,ffffffffc02037e8 <swap_init+0x490>
ffffffffc02034da:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034dc:	ff4c14e3          	bne	s8,s4,ffffffffc02034c4 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02034e0:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02034e2:	000a9c17          	auipc	s8,0xa9
ffffffffc02034e6:	12ec0c13          	addi	s8,s8,302 # ffffffffc02ac610 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02034ea:	ec3e                	sd	a5,24(sp)
ffffffffc02034ec:	641c                	ld	a5,8(s0)
ffffffffc02034ee:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02034f0:	481c                	lw	a5,16(s0)
ffffffffc02034f2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02034f4:	000a9797          	auipc	a5,0xa9
ffffffffc02034f8:	0e87b623          	sd	s0,236(a5) # ffffffffc02ac5e0 <free_area+0x8>
ffffffffc02034fc:	000a9797          	auipc	a5,0xa9
ffffffffc0203500:	0c87be23          	sd	s0,220(a5) # ffffffffc02ac5d8 <free_area>
     nr_free = 0;
ffffffffc0203504:	000a9797          	auipc	a5,0xa9
ffffffffc0203508:	0e07a223          	sw	zero,228(a5) # ffffffffc02ac5e8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020350c:	000c3503          	ld	a0,0(s8)
ffffffffc0203510:	4585                	li	a1,1
ffffffffc0203512:	0c21                	addi	s8,s8,8
ffffffffc0203514:	9a3fe0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203518:	ff4c1ae3          	bne	s8,s4,ffffffffc020350c <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020351c:	01042c03          	lw	s8,16(s0)
ffffffffc0203520:	4791                	li	a5,4
ffffffffc0203522:	50fc1b63          	bne	s8,a5,ffffffffc0203a38 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203526:	00004517          	auipc	a0,0x4
ffffffffc020352a:	46a50513          	addi	a0,a0,1130 # ffffffffc0207990 <default_pmm_manager+0x8b0>
ffffffffc020352e:	c61fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203532:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203534:	000a9797          	auipc	a5,0xa9
ffffffffc0203538:	0607ac23          	sw	zero,120(a5) # ffffffffc02ac5ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020353c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc020353e:	000a9797          	auipc	a5,0xa9
ffffffffc0203542:	06e78793          	addi	a5,a5,110 # ffffffffc02ac5ac <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203546:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8590>
     assert(pgfault_num==1);
ffffffffc020354a:	4398                	lw	a4,0(a5)
ffffffffc020354c:	4585                	li	a1,1
ffffffffc020354e:	2701                	sext.w	a4,a4
ffffffffc0203550:	38b71863          	bne	a4,a1,ffffffffc02038e0 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203554:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0203558:	4394                	lw	a3,0(a5)
ffffffffc020355a:	2681                	sext.w	a3,a3
ffffffffc020355c:	3ae69263          	bne	a3,a4,ffffffffc0203900 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203560:	6689                	lui	a3,0x2
ffffffffc0203562:	462d                	li	a2,11
ffffffffc0203564:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7590>
     assert(pgfault_num==2);
ffffffffc0203568:	4398                	lw	a4,0(a5)
ffffffffc020356a:	4589                	li	a1,2
ffffffffc020356c:	2701                	sext.w	a4,a4
ffffffffc020356e:	2eb71963          	bne	a4,a1,ffffffffc0203860 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203572:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0203576:	4394                	lw	a3,0(a5)
ffffffffc0203578:	2681                	sext.w	a3,a3
ffffffffc020357a:	30e69363          	bne	a3,a4,ffffffffc0203880 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc020357e:	668d                	lui	a3,0x3
ffffffffc0203580:	4631                	li	a2,12
ffffffffc0203582:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6590>
     assert(pgfault_num==3);
ffffffffc0203586:	4398                	lw	a4,0(a5)
ffffffffc0203588:	458d                	li	a1,3
ffffffffc020358a:	2701                	sext.w	a4,a4
ffffffffc020358c:	30b71a63          	bne	a4,a1,ffffffffc02038a0 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203590:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0203594:	4394                	lw	a3,0(a5)
ffffffffc0203596:	2681                	sext.w	a3,a3
ffffffffc0203598:	32e69463          	bne	a3,a4,ffffffffc02038c0 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc020359c:	6691                	lui	a3,0x4
ffffffffc020359e:	4635                	li	a2,13
ffffffffc02035a0:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5590>
     assert(pgfault_num==4);
ffffffffc02035a4:	4398                	lw	a4,0(a5)
ffffffffc02035a6:	2701                	sext.w	a4,a4
ffffffffc02035a8:	37871c63          	bne	a4,s8,ffffffffc0203920 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035ac:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035b0:	439c                	lw	a5,0(a5)
ffffffffc02035b2:	2781                	sext.w	a5,a5
ffffffffc02035b4:	38e79663          	bne	a5,a4,ffffffffc0203940 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035b8:	481c                	lw	a5,16(s0)
ffffffffc02035ba:	40079363          	bnez	a5,ffffffffc02039c0 <swap_init+0x668>
ffffffffc02035be:	000a9797          	auipc	a5,0xa9
ffffffffc02035c2:	07278793          	addi	a5,a5,114 # ffffffffc02ac630 <swap_in_seq_no>
ffffffffc02035c6:	000a9717          	auipc	a4,0xa9
ffffffffc02035ca:	09270713          	addi	a4,a4,146 # ffffffffc02ac658 <swap_out_seq_no>
ffffffffc02035ce:	000a9617          	auipc	a2,0xa9
ffffffffc02035d2:	08a60613          	addi	a2,a2,138 # ffffffffc02ac658 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035d6:	56fd                	li	a3,-1
ffffffffc02035d8:	c394                	sw	a3,0(a5)
ffffffffc02035da:	c314                	sw	a3,0(a4)
ffffffffc02035dc:	0791                	addi	a5,a5,4
ffffffffc02035de:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02035e0:	fef61ce3          	bne	a2,a5,ffffffffc02035d8 <swap_init+0x280>
ffffffffc02035e4:	000a9697          	auipc	a3,0xa9
ffffffffc02035e8:	0d468693          	addi	a3,a3,212 # ffffffffc02ac6b8 <check_ptep>
ffffffffc02035ec:	000a9817          	auipc	a6,0xa9
ffffffffc02035f0:	02480813          	addi	a6,a6,36 # ffffffffc02ac610 <check_rp>
ffffffffc02035f4:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02035f6:	000a9c97          	auipc	s9,0xa9
ffffffffc02035fa:	fa2c8c93          	addi	s9,s9,-94 # ffffffffc02ac598 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02035fe:	00005d97          	auipc	s11,0x5
ffffffffc0203602:	3fad8d93          	addi	s11,s11,1018 # ffffffffc02089f8 <nbase>
ffffffffc0203606:	000a9c17          	auipc	s8,0xa9
ffffffffc020360a:	002c0c13          	addi	s8,s8,2 # ffffffffc02ac608 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc020360e:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203612:	4601                	li	a2,0
ffffffffc0203614:	85ea                	mv	a1,s10
ffffffffc0203616:	855a                	mv	a0,s6
ffffffffc0203618:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020361a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020361c:	921fe0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc0203620:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203622:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203624:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0203626:	20050163          	beqz	a0,ffffffffc0203828 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020362a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020362c:	0017f613          	andi	a2,a5,1
ffffffffc0203630:	1a060063          	beqz	a2,ffffffffc02037d0 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203634:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203638:	078a                	slli	a5,a5,0x2
ffffffffc020363a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020363c:	14c7fe63          	bleu	a2,a5,ffffffffc0203798 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203640:	000db703          	ld	a4,0(s11)
ffffffffc0203644:	000c3603          	ld	a2,0(s8)
ffffffffc0203648:	00083583          	ld	a1,0(a6)
ffffffffc020364c:	8f99                	sub	a5,a5,a4
ffffffffc020364e:	079a                	slli	a5,a5,0x6
ffffffffc0203650:	e43a                	sd	a4,8(sp)
ffffffffc0203652:	97b2                	add	a5,a5,a2
ffffffffc0203654:	14f59e63          	bne	a1,a5,ffffffffc02037b0 <swap_init+0x458>
ffffffffc0203658:	6785                	lui	a5,0x1
ffffffffc020365a:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020365c:	6795                	lui	a5,0x5
ffffffffc020365e:	06a1                	addi	a3,a3,8
ffffffffc0203660:	0821                	addi	a6,a6,8
ffffffffc0203662:	fafd16e3          	bne	s10,a5,ffffffffc020360e <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0203666:	00004517          	auipc	a0,0x4
ffffffffc020366a:	3d250513          	addi	a0,a0,978 # ffffffffc0207a38 <default_pmm_manager+0x958>
ffffffffc020366e:	b21fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc0203672:	000a9797          	auipc	a5,0xa9
ffffffffc0203676:	f2e78793          	addi	a5,a5,-210 # ffffffffc02ac5a0 <sm>
ffffffffc020367a:	639c                	ld	a5,0(a5)
ffffffffc020367c:	7f9c                	ld	a5,56(a5)
ffffffffc020367e:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203680:	40051c63          	bnez	a0,ffffffffc0203a98 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc0203684:	77a2                	ld	a5,40(sp)
ffffffffc0203686:	000a9717          	auipc	a4,0xa9
ffffffffc020368a:	f6f72123          	sw	a5,-158(a4) # ffffffffc02ac5e8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc020368e:	67e2                	ld	a5,24(sp)
ffffffffc0203690:	000a9717          	auipc	a4,0xa9
ffffffffc0203694:	f4f73423          	sd	a5,-184(a4) # ffffffffc02ac5d8 <free_area>
ffffffffc0203698:	7782                	ld	a5,32(sp)
ffffffffc020369a:	000a9717          	auipc	a4,0xa9
ffffffffc020369e:	f4f73323          	sd	a5,-186(a4) # ffffffffc02ac5e0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036a2:	0009b503          	ld	a0,0(s3)
ffffffffc02036a6:	4585                	li	a1,1
ffffffffc02036a8:	09a1                	addi	s3,s3,8
ffffffffc02036aa:	80dfe0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036ae:	ff499ae3          	bne	s3,s4,ffffffffc02036a2 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036b2:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036b6:	855e                	mv	a0,s7
ffffffffc02036b8:	2e7000ef          	jal	ra,ffffffffc020419e <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036bc:	000a9797          	auipc	a5,0xa9
ffffffffc02036c0:	ed478793          	addi	a5,a5,-300 # ffffffffc02ac590 <boot_pgdir>
ffffffffc02036c4:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036c6:	000a9697          	auipc	a3,0xa9
ffffffffc02036ca:	0206b123          	sd	zero,34(a3) # ffffffffc02ac6e8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036ce:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036d2:	6394                	ld	a3,0(a5)
ffffffffc02036d4:	068a                	slli	a3,a3,0x2
ffffffffc02036d6:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036d8:	0ce6f063          	bleu	a4,a3,ffffffffc0203798 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02036dc:	67a2                	ld	a5,8(sp)
ffffffffc02036de:	000c3503          	ld	a0,0(s8)
ffffffffc02036e2:	8e9d                	sub	a3,a3,a5
ffffffffc02036e4:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02036e6:	8699                	srai	a3,a3,0x6
ffffffffc02036e8:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02036ea:	57fd                	li	a5,-1
ffffffffc02036ec:	83b1                	srli	a5,a5,0xc
ffffffffc02036ee:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02036f0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02036f2:	2ee7f763          	bleu	a4,a5,ffffffffc02039e0 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02036f6:	000a9797          	auipc	a5,0xa9
ffffffffc02036fa:	f0278793          	addi	a5,a5,-254 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc02036fe:	639c                	ld	a5,0(a5)
ffffffffc0203700:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203702:	629c                	ld	a5,0(a3)
ffffffffc0203704:	078a                	slli	a5,a5,0x2
ffffffffc0203706:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203708:	08e7f863          	bleu	a4,a5,ffffffffc0203798 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020370c:	69a2                	ld	s3,8(sp)
ffffffffc020370e:	4585                	li	a1,1
ffffffffc0203710:	413787b3          	sub	a5,a5,s3
ffffffffc0203714:	079a                	slli	a5,a5,0x6
ffffffffc0203716:	953e                	add	a0,a0,a5
ffffffffc0203718:	f9efe0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020371c:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203720:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203724:	078a                	slli	a5,a5,0x2
ffffffffc0203726:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203728:	06e7f863          	bleu	a4,a5,ffffffffc0203798 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc020372c:	000c3503          	ld	a0,0(s8)
ffffffffc0203730:	413787b3          	sub	a5,a5,s3
ffffffffc0203734:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203736:	4585                	li	a1,1
ffffffffc0203738:	953e                	add	a0,a0,a5
ffffffffc020373a:	f7cfe0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
     pgdir[0] = 0;
ffffffffc020373e:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203742:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203746:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203748:	00878963          	beq	a5,s0,ffffffffc020375a <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc020374c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203750:	679c                	ld	a5,8(a5)
ffffffffc0203752:	397d                	addiw	s2,s2,-1
ffffffffc0203754:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203756:	fe879be3          	bne	a5,s0,ffffffffc020374c <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020375a:	28091f63          	bnez	s2,ffffffffc02039f8 <swap_init+0x6a0>
     assert(total==0);
ffffffffc020375e:	2a049d63          	bnez	s1,ffffffffc0203a18 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203762:	00004517          	auipc	a0,0x4
ffffffffc0203766:	32650513          	addi	a0,a0,806 # ffffffffc0207a88 <default_pmm_manager+0x9a8>
ffffffffc020376a:	a25fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020376e:	b92d                	j	ffffffffc02033a8 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203770:	4481                	li	s1,0
ffffffffc0203772:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203774:	4981                	li	s3,0
ffffffffc0203776:	b17d                	j	ffffffffc0203424 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0203778:	00003697          	auipc	a3,0x3
ffffffffc020377c:	5d868693          	addi	a3,a3,1496 # ffffffffc0206d50 <commands+0x878>
ffffffffc0203780:	00003617          	auipc	a2,0x3
ffffffffc0203784:	21860613          	addi	a2,a2,536 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203788:	0bc00593          	li	a1,188
ffffffffc020378c:	00004517          	auipc	a0,0x4
ffffffffc0203790:	09450513          	addi	a0,a0,148 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203794:	cf1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203798:	00004617          	auipc	a2,0x4
ffffffffc020379c:	9f860613          	addi	a2,a2,-1544 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc02037a0:	06200593          	li	a1,98
ffffffffc02037a4:	00004517          	auipc	a0,0x4
ffffffffc02037a8:	9b450513          	addi	a0,a0,-1612 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02037ac:	cd9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037b0:	00004697          	auipc	a3,0x4
ffffffffc02037b4:	26068693          	addi	a3,a3,608 # ffffffffc0207a10 <default_pmm_manager+0x930>
ffffffffc02037b8:	00003617          	auipc	a2,0x3
ffffffffc02037bc:	1e060613          	addi	a2,a2,480 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02037c0:	0fc00593          	li	a1,252
ffffffffc02037c4:	00004517          	auipc	a0,0x4
ffffffffc02037c8:	05c50513          	addi	a0,a0,92 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc02037cc:	cb9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037d0:	00004617          	auipc	a2,0x4
ffffffffc02037d4:	c0860613          	addi	a2,a2,-1016 # ffffffffc02073d8 <default_pmm_manager+0x2f8>
ffffffffc02037d8:	07400593          	li	a1,116
ffffffffc02037dc:	00004517          	auipc	a0,0x4
ffffffffc02037e0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02037e4:	ca1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02037e8:	00004697          	auipc	a3,0x4
ffffffffc02037ec:	16068693          	addi	a3,a3,352 # ffffffffc0207948 <default_pmm_manager+0x868>
ffffffffc02037f0:	00003617          	auipc	a2,0x3
ffffffffc02037f4:	1a860613          	addi	a2,a2,424 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02037f8:	0dd00593          	li	a1,221
ffffffffc02037fc:	00004517          	auipc	a0,0x4
ffffffffc0203800:	02450513          	addi	a0,a0,36 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203804:	c81fc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203808:	00004697          	auipc	a3,0x4
ffffffffc020380c:	12868693          	addi	a3,a3,296 # ffffffffc0207930 <default_pmm_manager+0x850>
ffffffffc0203810:	00003617          	auipc	a2,0x3
ffffffffc0203814:	18860613          	addi	a2,a2,392 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203818:	0dc00593          	li	a1,220
ffffffffc020381c:	00004517          	auipc	a0,0x4
ffffffffc0203820:	00450513          	addi	a0,a0,4 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203824:	c61fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203828:	00004697          	auipc	a3,0x4
ffffffffc020382c:	1d068693          	addi	a3,a3,464 # ffffffffc02079f8 <default_pmm_manager+0x918>
ffffffffc0203830:	00003617          	auipc	a2,0x3
ffffffffc0203834:	16860613          	addi	a2,a2,360 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203838:	0fb00593          	li	a1,251
ffffffffc020383c:	00004517          	auipc	a0,0x4
ffffffffc0203840:	fe450513          	addi	a0,a0,-28 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203844:	c41fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203848:	00004617          	auipc	a2,0x4
ffffffffc020384c:	fb860613          	addi	a2,a2,-72 # ffffffffc0207800 <default_pmm_manager+0x720>
ffffffffc0203850:	02800593          	li	a1,40
ffffffffc0203854:	00004517          	auipc	a0,0x4
ffffffffc0203858:	fcc50513          	addi	a0,a0,-52 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020385c:	c29fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203860:	00004697          	auipc	a3,0x4
ffffffffc0203864:	16868693          	addi	a3,a3,360 # ffffffffc02079c8 <default_pmm_manager+0x8e8>
ffffffffc0203868:	00003617          	auipc	a2,0x3
ffffffffc020386c:	13060613          	addi	a2,a2,304 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203870:	09700593          	li	a1,151
ffffffffc0203874:	00004517          	auipc	a0,0x4
ffffffffc0203878:	fac50513          	addi	a0,a0,-84 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020387c:	c09fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203880:	00004697          	auipc	a3,0x4
ffffffffc0203884:	14868693          	addi	a3,a3,328 # ffffffffc02079c8 <default_pmm_manager+0x8e8>
ffffffffc0203888:	00003617          	auipc	a2,0x3
ffffffffc020388c:	11060613          	addi	a2,a2,272 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203890:	09900593          	li	a1,153
ffffffffc0203894:	00004517          	auipc	a0,0x4
ffffffffc0203898:	f8c50513          	addi	a0,a0,-116 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020389c:	be9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc02038a0:	00004697          	auipc	a3,0x4
ffffffffc02038a4:	13868693          	addi	a3,a3,312 # ffffffffc02079d8 <default_pmm_manager+0x8f8>
ffffffffc02038a8:	00003617          	auipc	a2,0x3
ffffffffc02038ac:	0f060613          	addi	a2,a2,240 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02038b0:	09b00593          	li	a1,155
ffffffffc02038b4:	00004517          	auipc	a0,0x4
ffffffffc02038b8:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc02038bc:	bc9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc02038c0:	00004697          	auipc	a3,0x4
ffffffffc02038c4:	11868693          	addi	a3,a3,280 # ffffffffc02079d8 <default_pmm_manager+0x8f8>
ffffffffc02038c8:	00003617          	auipc	a2,0x3
ffffffffc02038cc:	0d060613          	addi	a2,a2,208 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02038d0:	09d00593          	li	a1,157
ffffffffc02038d4:	00004517          	auipc	a0,0x4
ffffffffc02038d8:	f4c50513          	addi	a0,a0,-180 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc02038dc:	ba9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc02038e0:	00004697          	auipc	a3,0x4
ffffffffc02038e4:	0d868693          	addi	a3,a3,216 # ffffffffc02079b8 <default_pmm_manager+0x8d8>
ffffffffc02038e8:	00003617          	auipc	a2,0x3
ffffffffc02038ec:	0b060613          	addi	a2,a2,176 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02038f0:	09300593          	li	a1,147
ffffffffc02038f4:	00004517          	auipc	a0,0x4
ffffffffc02038f8:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc02038fc:	b89fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203900:	00004697          	auipc	a3,0x4
ffffffffc0203904:	0b868693          	addi	a3,a3,184 # ffffffffc02079b8 <default_pmm_manager+0x8d8>
ffffffffc0203908:	00003617          	auipc	a2,0x3
ffffffffc020390c:	09060613          	addi	a2,a2,144 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203910:	09500593          	li	a1,149
ffffffffc0203914:	00004517          	auipc	a0,0x4
ffffffffc0203918:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020391c:	b69fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203920:	00004697          	auipc	a3,0x4
ffffffffc0203924:	0c868693          	addi	a3,a3,200 # ffffffffc02079e8 <default_pmm_manager+0x908>
ffffffffc0203928:	00003617          	auipc	a2,0x3
ffffffffc020392c:	07060613          	addi	a2,a2,112 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203930:	09f00593          	li	a1,159
ffffffffc0203934:	00004517          	auipc	a0,0x4
ffffffffc0203938:	eec50513          	addi	a0,a0,-276 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020393c:	b49fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203940:	00004697          	auipc	a3,0x4
ffffffffc0203944:	0a868693          	addi	a3,a3,168 # ffffffffc02079e8 <default_pmm_manager+0x908>
ffffffffc0203948:	00003617          	auipc	a2,0x3
ffffffffc020394c:	05060613          	addi	a2,a2,80 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203950:	0a100593          	li	a1,161
ffffffffc0203954:	00004517          	auipc	a0,0x4
ffffffffc0203958:	ecc50513          	addi	a0,a0,-308 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020395c:	b29fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203960:	00004697          	auipc	a3,0x4
ffffffffc0203964:	f3868693          	addi	a3,a3,-200 # ffffffffc0207898 <default_pmm_manager+0x7b8>
ffffffffc0203968:	00003617          	auipc	a2,0x3
ffffffffc020396c:	03060613          	addi	a2,a2,48 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203970:	0cc00593          	li	a1,204
ffffffffc0203974:	00004517          	auipc	a0,0x4
ffffffffc0203978:	eac50513          	addi	a0,a0,-340 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020397c:	b09fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(vma != NULL);
ffffffffc0203980:	00004697          	auipc	a3,0x4
ffffffffc0203984:	f2868693          	addi	a3,a3,-216 # ffffffffc02078a8 <default_pmm_manager+0x7c8>
ffffffffc0203988:	00003617          	auipc	a2,0x3
ffffffffc020398c:	01060613          	addi	a2,a2,16 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203990:	0cf00593          	li	a1,207
ffffffffc0203994:	00004517          	auipc	a0,0x4
ffffffffc0203998:	e8c50513          	addi	a0,a0,-372 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc020399c:	ae9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039a0:	00004697          	auipc	a3,0x4
ffffffffc02039a4:	f5068693          	addi	a3,a3,-176 # ffffffffc02078f0 <default_pmm_manager+0x810>
ffffffffc02039a8:	00003617          	auipc	a2,0x3
ffffffffc02039ac:	ff060613          	addi	a2,a2,-16 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02039b0:	0d700593          	li	a1,215
ffffffffc02039b4:	00004517          	auipc	a0,0x4
ffffffffc02039b8:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc02039bc:	ac9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert( nr_free == 0);         
ffffffffc02039c0:	00003697          	auipc	a3,0x3
ffffffffc02039c4:	56068693          	addi	a3,a3,1376 # ffffffffc0206f20 <commands+0xa48>
ffffffffc02039c8:	00003617          	auipc	a2,0x3
ffffffffc02039cc:	fd060613          	addi	a2,a2,-48 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02039d0:	0f300593          	li	a1,243
ffffffffc02039d4:	00004517          	auipc	a0,0x4
ffffffffc02039d8:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc02039dc:	aa9fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02039e0:	00003617          	auipc	a2,0x3
ffffffffc02039e4:	75060613          	addi	a2,a2,1872 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02039e8:	06900593          	li	a1,105
ffffffffc02039ec:	00003517          	auipc	a0,0x3
ffffffffc02039f0:	76c50513          	addi	a0,a0,1900 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02039f4:	a91fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(count==0);
ffffffffc02039f8:	00004697          	auipc	a3,0x4
ffffffffc02039fc:	07068693          	addi	a3,a3,112 # ffffffffc0207a68 <default_pmm_manager+0x988>
ffffffffc0203a00:	00003617          	auipc	a2,0x3
ffffffffc0203a04:	f9860613          	addi	a2,a2,-104 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203a08:	11d00593          	li	a1,285
ffffffffc0203a0c:	00004517          	auipc	a0,0x4
ffffffffc0203a10:	e1450513          	addi	a0,a0,-492 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203a14:	a71fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total==0);
ffffffffc0203a18:	00004697          	auipc	a3,0x4
ffffffffc0203a1c:	06068693          	addi	a3,a3,96 # ffffffffc0207a78 <default_pmm_manager+0x998>
ffffffffc0203a20:	00003617          	auipc	a2,0x3
ffffffffc0203a24:	f7860613          	addi	a2,a2,-136 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203a28:	11e00593          	li	a1,286
ffffffffc0203a2c:	00004517          	auipc	a0,0x4
ffffffffc0203a30:	df450513          	addi	a0,a0,-524 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203a34:	a51fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a38:	00004697          	auipc	a3,0x4
ffffffffc0203a3c:	f3068693          	addi	a3,a3,-208 # ffffffffc0207968 <default_pmm_manager+0x888>
ffffffffc0203a40:	00003617          	auipc	a2,0x3
ffffffffc0203a44:	f5860613          	addi	a2,a2,-168 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203a48:	0ea00593          	li	a1,234
ffffffffc0203a4c:	00004517          	auipc	a0,0x4
ffffffffc0203a50:	dd450513          	addi	a0,a0,-556 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203a54:	a31fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(mm != NULL);
ffffffffc0203a58:	00004697          	auipc	a3,0x4
ffffffffc0203a5c:	e1868693          	addi	a3,a3,-488 # ffffffffc0207870 <default_pmm_manager+0x790>
ffffffffc0203a60:	00003617          	auipc	a2,0x3
ffffffffc0203a64:	f3860613          	addi	a2,a2,-200 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203a68:	0c400593          	li	a1,196
ffffffffc0203a6c:	00004517          	auipc	a0,0x4
ffffffffc0203a70:	db450513          	addi	a0,a0,-588 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203a74:	a11fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a78:	00004697          	auipc	a3,0x4
ffffffffc0203a7c:	e0868693          	addi	a3,a3,-504 # ffffffffc0207880 <default_pmm_manager+0x7a0>
ffffffffc0203a80:	00003617          	auipc	a2,0x3
ffffffffc0203a84:	f1860613          	addi	a2,a2,-232 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203a88:	0c700593          	li	a1,199
ffffffffc0203a8c:	00004517          	auipc	a0,0x4
ffffffffc0203a90:	d9450513          	addi	a0,a0,-620 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203a94:	9f1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(ret==0);
ffffffffc0203a98:	00004697          	auipc	a3,0x4
ffffffffc0203a9c:	fc868693          	addi	a3,a3,-56 # ffffffffc0207a60 <default_pmm_manager+0x980>
ffffffffc0203aa0:	00003617          	auipc	a2,0x3
ffffffffc0203aa4:	ef860613          	addi	a2,a2,-264 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203aa8:	10200593          	li	a1,258
ffffffffc0203aac:	00004517          	auipc	a0,0x4
ffffffffc0203ab0:	d7450513          	addi	a0,a0,-652 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203ab4:	9d1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203ab8:	00003697          	auipc	a3,0x3
ffffffffc0203abc:	2c068693          	addi	a3,a3,704 # ffffffffc0206d78 <commands+0x8a0>
ffffffffc0203ac0:	00003617          	auipc	a2,0x3
ffffffffc0203ac4:	ed860613          	addi	a2,a2,-296 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203ac8:	0bf00593          	li	a1,191
ffffffffc0203acc:	00004517          	auipc	a0,0x4
ffffffffc0203ad0:	d5450513          	addi	a0,a0,-684 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203ad4:	9b1fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203ad8 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203ad8:	000a9797          	auipc	a5,0xa9
ffffffffc0203adc:	ac878793          	addi	a5,a5,-1336 # ffffffffc02ac5a0 <sm>
ffffffffc0203ae0:	639c                	ld	a5,0(a5)
ffffffffc0203ae2:	0107b303          	ld	t1,16(a5)
ffffffffc0203ae6:	8302                	jr	t1

ffffffffc0203ae8 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203ae8:	000a9797          	auipc	a5,0xa9
ffffffffc0203aec:	ab878793          	addi	a5,a5,-1352 # ffffffffc02ac5a0 <sm>
ffffffffc0203af0:	639c                	ld	a5,0(a5)
ffffffffc0203af2:	0207b303          	ld	t1,32(a5)
ffffffffc0203af6:	8302                	jr	t1

ffffffffc0203af8 <swap_out>:
{
ffffffffc0203af8:	711d                	addi	sp,sp,-96
ffffffffc0203afa:	ec86                	sd	ra,88(sp)
ffffffffc0203afc:	e8a2                	sd	s0,80(sp)
ffffffffc0203afe:	e4a6                	sd	s1,72(sp)
ffffffffc0203b00:	e0ca                	sd	s2,64(sp)
ffffffffc0203b02:	fc4e                	sd	s3,56(sp)
ffffffffc0203b04:	f852                	sd	s4,48(sp)
ffffffffc0203b06:	f456                	sd	s5,40(sp)
ffffffffc0203b08:	f05a                	sd	s6,32(sp)
ffffffffc0203b0a:	ec5e                	sd	s7,24(sp)
ffffffffc0203b0c:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b0e:	cde9                	beqz	a1,ffffffffc0203be8 <swap_out+0xf0>
ffffffffc0203b10:	8ab2                	mv	s5,a2
ffffffffc0203b12:	892a                	mv	s2,a0
ffffffffc0203b14:	8a2e                	mv	s4,a1
ffffffffc0203b16:	4401                	li	s0,0
ffffffffc0203b18:	000a9997          	auipc	s3,0xa9
ffffffffc0203b1c:	a8898993          	addi	s3,s3,-1400 # ffffffffc02ac5a0 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b20:	00004b17          	auipc	s6,0x4
ffffffffc0203b24:	fe8b0b13          	addi	s6,s6,-24 # ffffffffc0207b08 <default_pmm_manager+0xa28>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b28:	00004b97          	auipc	s7,0x4
ffffffffc0203b2c:	fc8b8b93          	addi	s7,s7,-56 # ffffffffc0207af0 <default_pmm_manager+0xa10>
ffffffffc0203b30:	a825                	j	ffffffffc0203b68 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b32:	67a2                	ld	a5,8(sp)
ffffffffc0203b34:	8626                	mv	a2,s1
ffffffffc0203b36:	85a2                	mv	a1,s0
ffffffffc0203b38:	7f94                	ld	a3,56(a5)
ffffffffc0203b3a:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b3c:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b3e:	82b1                	srli	a3,a3,0xc
ffffffffc0203b40:	0685                	addi	a3,a3,1
ffffffffc0203b42:	e4cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b46:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b48:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b4a:	7d1c                	ld	a5,56(a0)
ffffffffc0203b4c:	83b1                	srli	a5,a5,0xc
ffffffffc0203b4e:	0785                	addi	a5,a5,1
ffffffffc0203b50:	07a2                	slli	a5,a5,0x8
ffffffffc0203b52:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b56:	b60fe0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b5a:	01893503          	ld	a0,24(s2) # 1018 <_binary_obj___user_faultread_out_size-0x8578>
ffffffffc0203b5e:	85a6                	mv	a1,s1
ffffffffc0203b60:	f5eff0ef          	jal	ra,ffffffffc02032be <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b64:	048a0d63          	beq	s4,s0,ffffffffc0203bbe <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b68:	0009b783          	ld	a5,0(s3)
ffffffffc0203b6c:	8656                	mv	a2,s5
ffffffffc0203b6e:	002c                	addi	a1,sp,8
ffffffffc0203b70:	7b9c                	ld	a5,48(a5)
ffffffffc0203b72:	854a                	mv	a0,s2
ffffffffc0203b74:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b76:	e12d                	bnez	a0,ffffffffc0203bd8 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b78:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b7a:	01893503          	ld	a0,24(s2)
ffffffffc0203b7e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203b80:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b82:	85a6                	mv	a1,s1
ffffffffc0203b84:	bb8fe0ef          	jal	ra,ffffffffc0201f3c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b88:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b8a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b8c:	8b85                	andi	a5,a5,1
ffffffffc0203b8e:	cfb9                	beqz	a5,ffffffffc0203bec <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203b90:	65a2                	ld	a1,8(sp)
ffffffffc0203b92:	7d9c                	ld	a5,56(a1)
ffffffffc0203b94:	83b1                	srli	a5,a5,0xc
ffffffffc0203b96:	00178513          	addi	a0,a5,1
ffffffffc0203b9a:	0522                	slli	a0,a0,0x8
ffffffffc0203b9c:	6ed000ef          	jal	ra,ffffffffc0204a88 <swapfs_write>
ffffffffc0203ba0:	d949                	beqz	a0,ffffffffc0203b32 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203ba2:	855e                	mv	a0,s7
ffffffffc0203ba4:	deafc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203ba8:	0009b783          	ld	a5,0(s3)
ffffffffc0203bac:	6622                	ld	a2,8(sp)
ffffffffc0203bae:	4681                	li	a3,0
ffffffffc0203bb0:	739c                	ld	a5,32(a5)
ffffffffc0203bb2:	85a6                	mv	a1,s1
ffffffffc0203bb4:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bb6:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bb8:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bba:	fa8a17e3          	bne	s4,s0,ffffffffc0203b68 <swap_out+0x70>
}
ffffffffc0203bbe:	8522                	mv	a0,s0
ffffffffc0203bc0:	60e6                	ld	ra,88(sp)
ffffffffc0203bc2:	6446                	ld	s0,80(sp)
ffffffffc0203bc4:	64a6                	ld	s1,72(sp)
ffffffffc0203bc6:	6906                	ld	s2,64(sp)
ffffffffc0203bc8:	79e2                	ld	s3,56(sp)
ffffffffc0203bca:	7a42                	ld	s4,48(sp)
ffffffffc0203bcc:	7aa2                	ld	s5,40(sp)
ffffffffc0203bce:	7b02                	ld	s6,32(sp)
ffffffffc0203bd0:	6be2                	ld	s7,24(sp)
ffffffffc0203bd2:	6c42                	ld	s8,16(sp)
ffffffffc0203bd4:	6125                	addi	sp,sp,96
ffffffffc0203bd6:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bd8:	85a2                	mv	a1,s0
ffffffffc0203bda:	00004517          	auipc	a0,0x4
ffffffffc0203bde:	ece50513          	addi	a0,a0,-306 # ffffffffc0207aa8 <default_pmm_manager+0x9c8>
ffffffffc0203be2:	dacfc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203be6:	bfe1                	j	ffffffffc0203bbe <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203be8:	4401                	li	s0,0
ffffffffc0203bea:	bfd1                	j	ffffffffc0203bbe <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bec:	00004697          	auipc	a3,0x4
ffffffffc0203bf0:	eec68693          	addi	a3,a3,-276 # ffffffffc0207ad8 <default_pmm_manager+0x9f8>
ffffffffc0203bf4:	00003617          	auipc	a2,0x3
ffffffffc0203bf8:	da460613          	addi	a2,a2,-604 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203bfc:	06800593          	li	a1,104
ffffffffc0203c00:	00004517          	auipc	a0,0x4
ffffffffc0203c04:	c2050513          	addi	a0,a0,-992 # ffffffffc0207820 <default_pmm_manager+0x740>
ffffffffc0203c08:	87dfc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203c0c <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203c0c:	000a9797          	auipc	a5,0xa9
ffffffffc0203c10:	acc78793          	addi	a5,a5,-1332 # ffffffffc02ac6d8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203c14:	f51c                	sd	a5,40(a0)
ffffffffc0203c16:	e79c                	sd	a5,8(a5)
ffffffffc0203c18:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203c1a:	4501                	li	a0,0
ffffffffc0203c1c:	8082                	ret

ffffffffc0203c1e <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203c1e:	4501                	li	a0,0
ffffffffc0203c20:	8082                	ret

ffffffffc0203c22 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203c22:	4501                	li	a0,0
ffffffffc0203c24:	8082                	ret

ffffffffc0203c26 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203c26:	4501                	li	a0,0
ffffffffc0203c28:	8082                	ret

ffffffffc0203c2a <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203c2a:	711d                	addi	sp,sp,-96
ffffffffc0203c2c:	fc4e                	sd	s3,56(sp)
ffffffffc0203c2e:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c30:	00004517          	auipc	a0,0x4
ffffffffc0203c34:	f1850513          	addi	a0,a0,-232 # ffffffffc0207b48 <default_pmm_manager+0xa68>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c38:	698d                	lui	s3,0x3
ffffffffc0203c3a:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203c3c:	e8a2                	sd	s0,80(sp)
ffffffffc0203c3e:	e4a6                	sd	s1,72(sp)
ffffffffc0203c40:	ec86                	sd	ra,88(sp)
ffffffffc0203c42:	e0ca                	sd	s2,64(sp)
ffffffffc0203c44:	f456                	sd	s5,40(sp)
ffffffffc0203c46:	f05a                	sd	s6,32(sp)
ffffffffc0203c48:	ec5e                	sd	s7,24(sp)
ffffffffc0203c4a:	e862                	sd	s8,16(sp)
ffffffffc0203c4c:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203c4e:	000a9417          	auipc	s0,0xa9
ffffffffc0203c52:	95e40413          	addi	s0,s0,-1698 # ffffffffc02ac5ac <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203c56:	d38fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203c5a:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6590>
    assert(pgfault_num==4);
ffffffffc0203c5e:	4004                	lw	s1,0(s0)
ffffffffc0203c60:	4791                	li	a5,4
ffffffffc0203c62:	2481                	sext.w	s1,s1
ffffffffc0203c64:	14f49963          	bne	s1,a5,ffffffffc0203db6 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c68:	00004517          	auipc	a0,0x4
ffffffffc0203c6c:	f2050513          	addi	a0,a0,-224 # ffffffffc0207b88 <default_pmm_manager+0xaa8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c70:	6a85                	lui	s5,0x1
ffffffffc0203c72:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203c74:	d1afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203c78:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8590>
    assert(pgfault_num==4);
ffffffffc0203c7c:	00042903          	lw	s2,0(s0)
ffffffffc0203c80:	2901                	sext.w	s2,s2
ffffffffc0203c82:	2a991a63          	bne	s2,s1,ffffffffc0203f36 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c86:	00004517          	auipc	a0,0x4
ffffffffc0203c8a:	f2a50513          	addi	a0,a0,-214 # ffffffffc0207bb0 <default_pmm_manager+0xad0>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c8e:	6b91                	lui	s7,0x4
ffffffffc0203c90:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203c92:	cfcfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203c96:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5590>
    assert(pgfault_num==4);
ffffffffc0203c9a:	4004                	lw	s1,0(s0)
ffffffffc0203c9c:	2481                	sext.w	s1,s1
ffffffffc0203c9e:	27249c63          	bne	s1,s2,ffffffffc0203f16 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203ca2:	00004517          	auipc	a0,0x4
ffffffffc0203ca6:	f3650513          	addi	a0,a0,-202 # ffffffffc0207bd8 <default_pmm_manager+0xaf8>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203caa:	6909                	lui	s2,0x2
ffffffffc0203cac:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cae:	ce0fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203cb2:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7590>
    assert(pgfault_num==4);
ffffffffc0203cb6:	401c                	lw	a5,0(s0)
ffffffffc0203cb8:	2781                	sext.w	a5,a5
ffffffffc0203cba:	22979e63          	bne	a5,s1,ffffffffc0203ef6 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203cbe:	00004517          	auipc	a0,0x4
ffffffffc0203cc2:	f4250513          	addi	a0,a0,-190 # ffffffffc0207c00 <default_pmm_manager+0xb20>
ffffffffc0203cc6:	cc8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203cca:	6795                	lui	a5,0x5
ffffffffc0203ccc:	4739                	li	a4,14
ffffffffc0203cce:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4590>
    assert(pgfault_num==5);
ffffffffc0203cd2:	4004                	lw	s1,0(s0)
ffffffffc0203cd4:	4795                	li	a5,5
ffffffffc0203cd6:	2481                	sext.w	s1,s1
ffffffffc0203cd8:	1ef49f63          	bne	s1,a5,ffffffffc0203ed6 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203cdc:	00004517          	auipc	a0,0x4
ffffffffc0203ce0:	efc50513          	addi	a0,a0,-260 # ffffffffc0207bd8 <default_pmm_manager+0xaf8>
ffffffffc0203ce4:	caafc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203ce8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203cec:	401c                	lw	a5,0(s0)
ffffffffc0203cee:	2781                	sext.w	a5,a5
ffffffffc0203cf0:	1c979363          	bne	a5,s1,ffffffffc0203eb6 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203cf4:	00004517          	auipc	a0,0x4
ffffffffc0203cf8:	e9450513          	addi	a0,a0,-364 # ffffffffc0207b88 <default_pmm_manager+0xaa8>
ffffffffc0203cfc:	c92fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d00:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203d04:	401c                	lw	a5,0(s0)
ffffffffc0203d06:	4719                	li	a4,6
ffffffffc0203d08:	2781                	sext.w	a5,a5
ffffffffc0203d0a:	18e79663          	bne	a5,a4,ffffffffc0203e96 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d0e:	00004517          	auipc	a0,0x4
ffffffffc0203d12:	eca50513          	addi	a0,a0,-310 # ffffffffc0207bd8 <default_pmm_manager+0xaf8>
ffffffffc0203d16:	c78fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d1a:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203d1e:	401c                	lw	a5,0(s0)
ffffffffc0203d20:	471d                	li	a4,7
ffffffffc0203d22:	2781                	sext.w	a5,a5
ffffffffc0203d24:	14e79963          	bne	a5,a4,ffffffffc0203e76 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d28:	00004517          	auipc	a0,0x4
ffffffffc0203d2c:	e2050513          	addi	a0,a0,-480 # ffffffffc0207b48 <default_pmm_manager+0xa68>
ffffffffc0203d30:	c5efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203d34:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203d38:	401c                	lw	a5,0(s0)
ffffffffc0203d3a:	4721                	li	a4,8
ffffffffc0203d3c:	2781                	sext.w	a5,a5
ffffffffc0203d3e:	10e79c63          	bne	a5,a4,ffffffffc0203e56 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d42:	00004517          	auipc	a0,0x4
ffffffffc0203d46:	e6e50513          	addi	a0,a0,-402 # ffffffffc0207bb0 <default_pmm_manager+0xad0>
ffffffffc0203d4a:	c44fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d4e:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203d52:	401c                	lw	a5,0(s0)
ffffffffc0203d54:	4725                	li	a4,9
ffffffffc0203d56:	2781                	sext.w	a5,a5
ffffffffc0203d58:	0ce79f63          	bne	a5,a4,ffffffffc0203e36 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d5c:	00004517          	auipc	a0,0x4
ffffffffc0203d60:	ea450513          	addi	a0,a0,-348 # ffffffffc0207c00 <default_pmm_manager+0xb20>
ffffffffc0203d64:	c2afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d68:	6795                	lui	a5,0x5
ffffffffc0203d6a:	4739                	li	a4,14
ffffffffc0203d6c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4590>
    assert(pgfault_num==10);
ffffffffc0203d70:	4004                	lw	s1,0(s0)
ffffffffc0203d72:	47a9                	li	a5,10
ffffffffc0203d74:	2481                	sext.w	s1,s1
ffffffffc0203d76:	0af49063          	bne	s1,a5,ffffffffc0203e16 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d7a:	00004517          	auipc	a0,0x4
ffffffffc0203d7e:	e0e50513          	addi	a0,a0,-498 # ffffffffc0207b88 <default_pmm_manager+0xaa8>
ffffffffc0203d82:	c0cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203d86:	6785                	lui	a5,0x1
ffffffffc0203d88:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8590>
ffffffffc0203d8c:	06979563          	bne	a5,s1,ffffffffc0203df6 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203d90:	401c                	lw	a5,0(s0)
ffffffffc0203d92:	472d                	li	a4,11
ffffffffc0203d94:	2781                	sext.w	a5,a5
ffffffffc0203d96:	04e79063          	bne	a5,a4,ffffffffc0203dd6 <_fifo_check_swap+0x1ac>
}
ffffffffc0203d9a:	60e6                	ld	ra,88(sp)
ffffffffc0203d9c:	6446                	ld	s0,80(sp)
ffffffffc0203d9e:	64a6                	ld	s1,72(sp)
ffffffffc0203da0:	6906                	ld	s2,64(sp)
ffffffffc0203da2:	79e2                	ld	s3,56(sp)
ffffffffc0203da4:	7a42                	ld	s4,48(sp)
ffffffffc0203da6:	7aa2                	ld	s5,40(sp)
ffffffffc0203da8:	7b02                	ld	s6,32(sp)
ffffffffc0203daa:	6be2                	ld	s7,24(sp)
ffffffffc0203dac:	6c42                	ld	s8,16(sp)
ffffffffc0203dae:	6ca2                	ld	s9,8(sp)
ffffffffc0203db0:	4501                	li	a0,0
ffffffffc0203db2:	6125                	addi	sp,sp,96
ffffffffc0203db4:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203db6:	00004697          	auipc	a3,0x4
ffffffffc0203dba:	c3268693          	addi	a3,a3,-974 # ffffffffc02079e8 <default_pmm_manager+0x908>
ffffffffc0203dbe:	00003617          	auipc	a2,0x3
ffffffffc0203dc2:	bda60613          	addi	a2,a2,-1062 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203dc6:	05100593          	li	a1,81
ffffffffc0203dca:	00004517          	auipc	a0,0x4
ffffffffc0203dce:	da650513          	addi	a0,a0,-602 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203dd2:	eb2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==11);
ffffffffc0203dd6:	00004697          	auipc	a3,0x4
ffffffffc0203dda:	eda68693          	addi	a3,a3,-294 # ffffffffc0207cb0 <default_pmm_manager+0xbd0>
ffffffffc0203dde:	00003617          	auipc	a2,0x3
ffffffffc0203de2:	bba60613          	addi	a2,a2,-1094 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203de6:	07300593          	li	a1,115
ffffffffc0203dea:	00004517          	auipc	a0,0x4
ffffffffc0203dee:	d8650513          	addi	a0,a0,-634 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203df2:	e92fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203df6:	00004697          	auipc	a3,0x4
ffffffffc0203dfa:	e9268693          	addi	a3,a3,-366 # ffffffffc0207c88 <default_pmm_manager+0xba8>
ffffffffc0203dfe:	00003617          	auipc	a2,0x3
ffffffffc0203e02:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203e06:	07100593          	li	a1,113
ffffffffc0203e0a:	00004517          	auipc	a0,0x4
ffffffffc0203e0e:	d6650513          	addi	a0,a0,-666 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203e12:	e72fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==10);
ffffffffc0203e16:	00004697          	auipc	a3,0x4
ffffffffc0203e1a:	e6268693          	addi	a3,a3,-414 # ffffffffc0207c78 <default_pmm_manager+0xb98>
ffffffffc0203e1e:	00003617          	auipc	a2,0x3
ffffffffc0203e22:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203e26:	06f00593          	li	a1,111
ffffffffc0203e2a:	00004517          	auipc	a0,0x4
ffffffffc0203e2e:	d4650513          	addi	a0,a0,-698 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203e32:	e52fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==9);
ffffffffc0203e36:	00004697          	auipc	a3,0x4
ffffffffc0203e3a:	e3268693          	addi	a3,a3,-462 # ffffffffc0207c68 <default_pmm_manager+0xb88>
ffffffffc0203e3e:	00003617          	auipc	a2,0x3
ffffffffc0203e42:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203e46:	06c00593          	li	a1,108
ffffffffc0203e4a:	00004517          	auipc	a0,0x4
ffffffffc0203e4e:	d2650513          	addi	a0,a0,-730 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203e52:	e32fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==8);
ffffffffc0203e56:	00004697          	auipc	a3,0x4
ffffffffc0203e5a:	e0268693          	addi	a3,a3,-510 # ffffffffc0207c58 <default_pmm_manager+0xb78>
ffffffffc0203e5e:	00003617          	auipc	a2,0x3
ffffffffc0203e62:	b3a60613          	addi	a2,a2,-1222 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203e66:	06900593          	li	a1,105
ffffffffc0203e6a:	00004517          	auipc	a0,0x4
ffffffffc0203e6e:	d0650513          	addi	a0,a0,-762 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203e72:	e12fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==7);
ffffffffc0203e76:	00004697          	auipc	a3,0x4
ffffffffc0203e7a:	dd268693          	addi	a3,a3,-558 # ffffffffc0207c48 <default_pmm_manager+0xb68>
ffffffffc0203e7e:	00003617          	auipc	a2,0x3
ffffffffc0203e82:	b1a60613          	addi	a2,a2,-1254 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203e86:	06600593          	li	a1,102
ffffffffc0203e8a:	00004517          	auipc	a0,0x4
ffffffffc0203e8e:	ce650513          	addi	a0,a0,-794 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203e92:	df2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==6);
ffffffffc0203e96:	00004697          	auipc	a3,0x4
ffffffffc0203e9a:	da268693          	addi	a3,a3,-606 # ffffffffc0207c38 <default_pmm_manager+0xb58>
ffffffffc0203e9e:	00003617          	auipc	a2,0x3
ffffffffc0203ea2:	afa60613          	addi	a2,a2,-1286 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203ea6:	06300593          	li	a1,99
ffffffffc0203eaa:	00004517          	auipc	a0,0x4
ffffffffc0203eae:	cc650513          	addi	a0,a0,-826 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203eb2:	dd2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0203eb6:	00004697          	auipc	a3,0x4
ffffffffc0203eba:	d7268693          	addi	a3,a3,-654 # ffffffffc0207c28 <default_pmm_manager+0xb48>
ffffffffc0203ebe:	00003617          	auipc	a2,0x3
ffffffffc0203ec2:	ada60613          	addi	a2,a2,-1318 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203ec6:	06000593          	li	a1,96
ffffffffc0203eca:	00004517          	auipc	a0,0x4
ffffffffc0203ece:	ca650513          	addi	a0,a0,-858 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203ed2:	db2fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0203ed6:	00004697          	auipc	a3,0x4
ffffffffc0203eda:	d5268693          	addi	a3,a3,-686 # ffffffffc0207c28 <default_pmm_manager+0xb48>
ffffffffc0203ede:	00003617          	auipc	a2,0x3
ffffffffc0203ee2:	aba60613          	addi	a2,a2,-1350 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203ee6:	05d00593          	li	a1,93
ffffffffc0203eea:	00004517          	auipc	a0,0x4
ffffffffc0203eee:	c8650513          	addi	a0,a0,-890 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203ef2:	d92fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203ef6:	00004697          	auipc	a3,0x4
ffffffffc0203efa:	af268693          	addi	a3,a3,-1294 # ffffffffc02079e8 <default_pmm_manager+0x908>
ffffffffc0203efe:	00003617          	auipc	a2,0x3
ffffffffc0203f02:	a9a60613          	addi	a2,a2,-1382 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203f06:	05a00593          	li	a1,90
ffffffffc0203f0a:	00004517          	auipc	a0,0x4
ffffffffc0203f0e:	c6650513          	addi	a0,a0,-922 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203f12:	d72fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f16:	00004697          	auipc	a3,0x4
ffffffffc0203f1a:	ad268693          	addi	a3,a3,-1326 # ffffffffc02079e8 <default_pmm_manager+0x908>
ffffffffc0203f1e:	00003617          	auipc	a2,0x3
ffffffffc0203f22:	a7a60613          	addi	a2,a2,-1414 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203f26:	05700593          	li	a1,87
ffffffffc0203f2a:	00004517          	auipc	a0,0x4
ffffffffc0203f2e:	c4650513          	addi	a0,a0,-954 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203f32:	d52fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f36:	00004697          	auipc	a3,0x4
ffffffffc0203f3a:	ab268693          	addi	a3,a3,-1358 # ffffffffc02079e8 <default_pmm_manager+0x908>
ffffffffc0203f3e:	00003617          	auipc	a2,0x3
ffffffffc0203f42:	a5a60613          	addi	a2,a2,-1446 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203f46:	05400593          	li	a1,84
ffffffffc0203f4a:	00004517          	auipc	a0,0x4
ffffffffc0203f4e:	c2650513          	addi	a0,a0,-986 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203f52:	d32fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203f56 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203f56:	751c                	ld	a5,40(a0)
{
ffffffffc0203f58:	1141                	addi	sp,sp,-16
ffffffffc0203f5a:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203f5c:	cf91                	beqz	a5,ffffffffc0203f78 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203f5e:	ee0d                	bnez	a2,ffffffffc0203f98 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203f60:	679c                	ld	a5,8(a5)
}
ffffffffc0203f62:	60a2                	ld	ra,8(sp)
ffffffffc0203f64:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203f66:	6394                	ld	a3,0(a5)
ffffffffc0203f68:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203f6a:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203f6e:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203f70:	e314                	sd	a3,0(a4)
ffffffffc0203f72:	e19c                	sd	a5,0(a1)
}
ffffffffc0203f74:	0141                	addi	sp,sp,16
ffffffffc0203f76:	8082                	ret
         assert(head != NULL);
ffffffffc0203f78:	00004697          	auipc	a3,0x4
ffffffffc0203f7c:	d6868693          	addi	a3,a3,-664 # ffffffffc0207ce0 <default_pmm_manager+0xc00>
ffffffffc0203f80:	00003617          	auipc	a2,0x3
ffffffffc0203f84:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203f88:	04100593          	li	a1,65
ffffffffc0203f8c:	00004517          	auipc	a0,0x4
ffffffffc0203f90:	be450513          	addi	a0,a0,-1052 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203f94:	cf0fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(in_tick==0);
ffffffffc0203f98:	00004697          	auipc	a3,0x4
ffffffffc0203f9c:	d5868693          	addi	a3,a3,-680 # ffffffffc0207cf0 <default_pmm_manager+0xc10>
ffffffffc0203fa0:	00003617          	auipc	a2,0x3
ffffffffc0203fa4:	9f860613          	addi	a2,a2,-1544 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203fa8:	04200593          	li	a1,66
ffffffffc0203fac:	00004517          	auipc	a0,0x4
ffffffffc0203fb0:	bc450513          	addi	a0,a0,-1084 # ffffffffc0207b70 <default_pmm_manager+0xa90>
ffffffffc0203fb4:	cd0fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203fb8 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0203fb8:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203fbc:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0203fbe:	cb09                	beqz	a4,ffffffffc0203fd0 <_fifo_map_swappable+0x18>
ffffffffc0203fc0:	cb81                	beqz	a5,ffffffffc0203fd0 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203fc2:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203fc4:	e398                	sd	a4,0(a5)
}
ffffffffc0203fc6:	4501                	li	a0,0
ffffffffc0203fc8:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0203fca:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0203fcc:	f614                	sd	a3,40(a2)
ffffffffc0203fce:	8082                	ret
{
ffffffffc0203fd0:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0203fd2:	00004697          	auipc	a3,0x4
ffffffffc0203fd6:	cee68693          	addi	a3,a3,-786 # ffffffffc0207cc0 <default_pmm_manager+0xbe0>
ffffffffc0203fda:	00003617          	auipc	a2,0x3
ffffffffc0203fde:	9be60613          	addi	a2,a2,-1602 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0203fe2:	03200593          	li	a1,50
ffffffffc0203fe6:	00004517          	auipc	a0,0x4
ffffffffc0203fea:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0207b70 <default_pmm_manager+0xa90>
{
ffffffffc0203fee:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203ff0:	c94fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203ff4 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203ff4:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203ff6:	00004697          	auipc	a3,0x4
ffffffffc0203ffa:	d2268693          	addi	a3,a3,-734 # ffffffffc0207d18 <default_pmm_manager+0xc38>
ffffffffc0203ffe:	00003617          	auipc	a2,0x3
ffffffffc0204002:	99a60613          	addi	a2,a2,-1638 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204006:	06d00593          	li	a1,109
ffffffffc020400a:	00004517          	auipc	a0,0x4
ffffffffc020400e:	d2e50513          	addi	a0,a0,-722 # ffffffffc0207d38 <default_pmm_manager+0xc58>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204012:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204014:	c70fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204018 <mm_create>:
mm_create(void) {
ffffffffc0204018:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020401a:	04000513          	li	a0,64
mm_create(void) {
ffffffffc020401e:	e022                	sd	s0,0(sp)
ffffffffc0204020:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204022:	c11fd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc0204026:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc0204028:	c515                	beqz	a0,ffffffffc0204054 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020402a:	000a8797          	auipc	a5,0xa8
ffffffffc020402e:	57e78793          	addi	a5,a5,1406 # ffffffffc02ac5a8 <swap_init_ok>
ffffffffc0204032:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0204034:	e408                	sd	a0,8(s0)
ffffffffc0204036:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204038:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020403c:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0204040:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204044:	2781                	sext.w	a5,a5
ffffffffc0204046:	ef81                	bnez	a5,ffffffffc020405e <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0204048:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc020404c:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc0204050:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204054:	8522                	mv	a0,s0
ffffffffc0204056:	60a2                	ld	ra,8(sp)
ffffffffc0204058:	6402                	ld	s0,0(sp)
ffffffffc020405a:	0141                	addi	sp,sp,16
ffffffffc020405c:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020405e:	a7bff0ef          	jal	ra,ffffffffc0203ad8 <swap_init_mm>
ffffffffc0204062:	b7ed                	j	ffffffffc020404c <mm_create+0x34>

ffffffffc0204064 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204064:	1101                	addi	sp,sp,-32
ffffffffc0204066:	e04a                	sd	s2,0(sp)
ffffffffc0204068:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020406a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020406e:	e822                	sd	s0,16(sp)
ffffffffc0204070:	e426                	sd	s1,8(sp)
ffffffffc0204072:	ec06                	sd	ra,24(sp)
ffffffffc0204074:	84ae                	mv	s1,a1
ffffffffc0204076:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204078:	bbbfd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
    if (vma != NULL) {
ffffffffc020407c:	c509                	beqz	a0,ffffffffc0204086 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020407e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204082:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204084:	cd00                	sw	s0,24(a0)
}
ffffffffc0204086:	60e2                	ld	ra,24(sp)
ffffffffc0204088:	6442                	ld	s0,16(sp)
ffffffffc020408a:	64a2                	ld	s1,8(sp)
ffffffffc020408c:	6902                	ld	s2,0(sp)
ffffffffc020408e:	6105                	addi	sp,sp,32
ffffffffc0204090:	8082                	ret

ffffffffc0204092 <find_vma>:
    if (mm != NULL) {
ffffffffc0204092:	c51d                	beqz	a0,ffffffffc02040c0 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204094:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204096:	c781                	beqz	a5,ffffffffc020409e <find_vma+0xc>
ffffffffc0204098:	6798                	ld	a4,8(a5)
ffffffffc020409a:	02e5f663          	bleu	a4,a1,ffffffffc02040c6 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020409e:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02040a0:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02040a2:	00f50f63          	beq	a0,a5,ffffffffc02040c0 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02040a6:	fe87b703          	ld	a4,-24(a5)
ffffffffc02040aa:	fee5ebe3          	bltu	a1,a4,ffffffffc02040a0 <find_vma+0xe>
ffffffffc02040ae:	ff07b703          	ld	a4,-16(a5)
ffffffffc02040b2:	fee5f7e3          	bleu	a4,a1,ffffffffc02040a0 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02040b6:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02040b8:	c781                	beqz	a5,ffffffffc02040c0 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02040ba:	e91c                	sd	a5,16(a0)
}
ffffffffc02040bc:	853e                	mv	a0,a5
ffffffffc02040be:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02040c0:	4781                	li	a5,0
}
ffffffffc02040c2:	853e                	mv	a0,a5
ffffffffc02040c4:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02040c6:	6b98                	ld	a4,16(a5)
ffffffffc02040c8:	fce5fbe3          	bleu	a4,a1,ffffffffc020409e <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02040cc:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc02040ce:	b7fd                	j	ffffffffc02040bc <find_vma+0x2a>

ffffffffc02040d0 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc02040d0:	6590                	ld	a2,8(a1)
ffffffffc02040d2:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8580>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02040d6:	1141                	addi	sp,sp,-16
ffffffffc02040d8:	e406                	sd	ra,8(sp)
ffffffffc02040da:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02040dc:	01066863          	bltu	a2,a6,ffffffffc02040ec <insert_vma_struct+0x1c>
ffffffffc02040e0:	a8b9                	j	ffffffffc020413e <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02040e2:	fe87b683          	ld	a3,-24(a5)
ffffffffc02040e6:	04d66763          	bltu	a2,a3,ffffffffc0204134 <insert_vma_struct+0x64>
ffffffffc02040ea:	873e                	mv	a4,a5
ffffffffc02040ec:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02040ee:	fef51ae3          	bne	a0,a5,ffffffffc02040e2 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02040f2:	02a70463          	beq	a4,a0,ffffffffc020411a <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02040f6:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02040fa:	fe873883          	ld	a7,-24(a4)
ffffffffc02040fe:	08d8f063          	bleu	a3,a7,ffffffffc020417e <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204102:	04d66e63          	bltu	a2,a3,ffffffffc020415e <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0204106:	00f50a63          	beq	a0,a5,ffffffffc020411a <insert_vma_struct+0x4a>
ffffffffc020410a:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020410e:	0506e863          	bltu	a3,a6,ffffffffc020415e <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0204112:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204116:	02c6f263          	bleu	a2,a3,ffffffffc020413a <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020411a:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020411c:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020411e:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0204122:	e390                	sd	a2,0(a5)
ffffffffc0204124:	e710                	sd	a2,8(a4)
}
ffffffffc0204126:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0204128:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020412a:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020412c:	2685                	addiw	a3,a3,1
ffffffffc020412e:	d114                	sw	a3,32(a0)
}
ffffffffc0204130:	0141                	addi	sp,sp,16
ffffffffc0204132:	8082                	ret
    if (le_prev != list) {
ffffffffc0204134:	fca711e3          	bne	a4,a0,ffffffffc02040f6 <insert_vma_struct+0x26>
ffffffffc0204138:	bfd9                	j	ffffffffc020410e <insert_vma_struct+0x3e>
ffffffffc020413a:	ebbff0ef          	jal	ra,ffffffffc0203ff4 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020413e:	00004697          	auipc	a3,0x4
ffffffffc0204142:	cea68693          	addi	a3,a3,-790 # ffffffffc0207e28 <default_pmm_manager+0xd48>
ffffffffc0204146:	00003617          	auipc	a2,0x3
ffffffffc020414a:	85260613          	addi	a2,a2,-1966 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020414e:	07400593          	li	a1,116
ffffffffc0204152:	00004517          	auipc	a0,0x4
ffffffffc0204156:	be650513          	addi	a0,a0,-1050 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020415a:	b2afc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020415e:	00004697          	auipc	a3,0x4
ffffffffc0204162:	d0a68693          	addi	a3,a3,-758 # ffffffffc0207e68 <default_pmm_manager+0xd88>
ffffffffc0204166:	00003617          	auipc	a2,0x3
ffffffffc020416a:	83260613          	addi	a2,a2,-1998 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020416e:	06c00593          	li	a1,108
ffffffffc0204172:	00004517          	auipc	a0,0x4
ffffffffc0204176:	bc650513          	addi	a0,a0,-1082 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020417a:	b0afc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020417e:	00004697          	auipc	a3,0x4
ffffffffc0204182:	cca68693          	addi	a3,a3,-822 # ffffffffc0207e48 <default_pmm_manager+0xd68>
ffffffffc0204186:	00003617          	auipc	a2,0x3
ffffffffc020418a:	81260613          	addi	a2,a2,-2030 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020418e:	06b00593          	li	a1,107
ffffffffc0204192:	00004517          	auipc	a0,0x4
ffffffffc0204196:	ba650513          	addi	a0,a0,-1114 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020419a:	aeafc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020419e <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020419e:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc02041a0:	1141                	addi	sp,sp,-16
ffffffffc02041a2:	e406                	sd	ra,8(sp)
ffffffffc02041a4:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02041a6:	e78d                	bnez	a5,ffffffffc02041d0 <mm_destroy+0x32>
ffffffffc02041a8:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02041aa:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02041ac:	00a40c63          	beq	s0,a0,ffffffffc02041c4 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02041b0:	6118                	ld	a4,0(a0)
ffffffffc02041b2:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc02041b4:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02041b6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02041b8:	e398                	sd	a4,0(a5)
ffffffffc02041ba:	b35fd0ef          	jal	ra,ffffffffc0201cee <kfree>
    return listelm->next;
ffffffffc02041be:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02041c0:	fea418e3          	bne	s0,a0,ffffffffc02041b0 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc02041c4:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02041c6:	6402                	ld	s0,0(sp)
ffffffffc02041c8:	60a2                	ld	ra,8(sp)
ffffffffc02041ca:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc02041cc:	b23fd06f          	j	ffffffffc0201cee <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02041d0:	00004697          	auipc	a3,0x4
ffffffffc02041d4:	cb868693          	addi	a3,a3,-840 # ffffffffc0207e88 <default_pmm_manager+0xda8>
ffffffffc02041d8:	00002617          	auipc	a2,0x2
ffffffffc02041dc:	7c060613          	addi	a2,a2,1984 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02041e0:	09400593          	li	a1,148
ffffffffc02041e4:	00004517          	auipc	a0,0x4
ffffffffc02041e8:	b5450513          	addi	a0,a0,-1196 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02041ec:	a98fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02041f0 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    // 全是对齐到page的
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041f0:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02041f2:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041f4:	17fd                	addi	a5,a5,-1
ffffffffc02041f6:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02041f8:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02041fa:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02041fe:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204200:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0204202:	fc06                	sd	ra,56(sp)
ffffffffc0204204:	f04a                	sd	s2,32(sp)
ffffffffc0204206:	ec4e                	sd	s3,24(sp)
ffffffffc0204208:	e852                	sd	s4,16(sp)
ffffffffc020420a:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020420c:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0204210:	002007b7          	lui	a5,0x200
ffffffffc0204214:	01047433          	and	s0,s0,a6
ffffffffc0204218:	06f4e363          	bltu	s1,a5,ffffffffc020427e <mm_map+0x8e>
ffffffffc020421c:	0684f163          	bleu	s0,s1,ffffffffc020427e <mm_map+0x8e>
ffffffffc0204220:	4785                	li	a5,1
ffffffffc0204222:	07fe                	slli	a5,a5,0x1f
ffffffffc0204224:	0487ed63          	bltu	a5,s0,ffffffffc020427e <mm_map+0x8e>
ffffffffc0204228:	89aa                	mv	s3,a0
ffffffffc020422a:	8a3a                	mv	s4,a4
ffffffffc020422c:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc020422e:	c931                	beqz	a0,ffffffffc0204282 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {   //如果已经有冲突的vma说明虚拟地址已经被分配出去了
ffffffffc0204230:	85a6                	mv	a1,s1
ffffffffc0204232:	e61ff0ef          	jal	ra,ffffffffc0204092 <find_vma>
ffffffffc0204236:	c501                	beqz	a0,ffffffffc020423e <mm_map+0x4e>
ffffffffc0204238:	651c                	ld	a5,8(a0)
ffffffffc020423a:	0487e263          	bltu	a5,s0,ffffffffc020427e <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020423e:	03000513          	li	a0,48
ffffffffc0204242:	9f1fd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc0204246:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204248:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc020424a:	02090163          	beqz	s2,ffffffffc020426c <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020424e:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc0204250:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204254:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204258:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc020425c:	85ca                	mv	a1,s2
ffffffffc020425e:	e73ff0ef          	jal	ra,ffffffffc02040d0 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204262:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204264:	000a0463          	beqz	s4,ffffffffc020426c <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204268:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020426c:	70e2                	ld	ra,56(sp)
ffffffffc020426e:	7442                	ld	s0,48(sp)
ffffffffc0204270:	74a2                	ld	s1,40(sp)
ffffffffc0204272:	7902                	ld	s2,32(sp)
ffffffffc0204274:	69e2                	ld	s3,24(sp)
ffffffffc0204276:	6a42                	ld	s4,16(sp)
ffffffffc0204278:	6aa2                	ld	s5,8(sp)
ffffffffc020427a:	6121                	addi	sp,sp,64
ffffffffc020427c:	8082                	ret
        return -E_INVAL;
ffffffffc020427e:	5575                	li	a0,-3
ffffffffc0204280:	b7f5                	j	ffffffffc020426c <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204282:	00003697          	auipc	a3,0x3
ffffffffc0204286:	5ee68693          	addi	a3,a3,1518 # ffffffffc0207870 <default_pmm_manager+0x790>
ffffffffc020428a:	00002617          	auipc	a2,0x2
ffffffffc020428e:	70e60613          	addi	a2,a2,1806 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204292:	0a800593          	li	a1,168
ffffffffc0204296:	00004517          	auipc	a0,0x4
ffffffffc020429a:	aa250513          	addi	a0,a0,-1374 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020429e:	9e6fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02042a2 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc02042a2:	7139                	addi	sp,sp,-64
ffffffffc02042a4:	fc06                	sd	ra,56(sp)
ffffffffc02042a6:	f822                	sd	s0,48(sp)
ffffffffc02042a8:	f426                	sd	s1,40(sp)
ffffffffc02042aa:	f04a                	sd	s2,32(sp)
ffffffffc02042ac:	ec4e                	sd	s3,24(sp)
ffffffffc02042ae:	e852                	sd	s4,16(sp)
ffffffffc02042b0:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02042b2:	c535                	beqz	a0,ffffffffc020431e <dup_mmap+0x7c>
ffffffffc02042b4:	892a                	mv	s2,a0
ffffffffc02042b6:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02042b8:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02042ba:	e59d                	bnez	a1,ffffffffc02042e8 <dup_mmap+0x46>
ffffffffc02042bc:	a08d                	j	ffffffffc020431e <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02042be:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02042c0:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5578>
        insert_vma_struct(to, nvma);
ffffffffc02042c4:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc02042c6:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc02042ca:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc02042ce:	e03ff0ef          	jal	ra,ffffffffc02040d0 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc02042d2:	ff043683          	ld	a3,-16(s0)
ffffffffc02042d6:	fe843603          	ld	a2,-24(s0)
ffffffffc02042da:	6c8c                	ld	a1,24(s1)
ffffffffc02042dc:	01893503          	ld	a0,24(s2)
ffffffffc02042e0:	4701                	li	a4,0
ffffffffc02042e2:	db9fe0ef          	jal	ra,ffffffffc020309a <copy_range>
ffffffffc02042e6:	e105                	bnez	a0,ffffffffc0204306 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc02042e8:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc02042ea:	02848863          	beq	s1,s0,ffffffffc020431a <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042ee:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02042f2:	fe843a83          	ld	s5,-24(s0)
ffffffffc02042f6:	ff043a03          	ld	s4,-16(s0)
ffffffffc02042fa:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042fe:	935fd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc0204302:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0204304:	fd4d                	bnez	a0,ffffffffc02042be <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0204306:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0204308:	70e2                	ld	ra,56(sp)
ffffffffc020430a:	7442                	ld	s0,48(sp)
ffffffffc020430c:	74a2                	ld	s1,40(sp)
ffffffffc020430e:	7902                	ld	s2,32(sp)
ffffffffc0204310:	69e2                	ld	s3,24(sp)
ffffffffc0204312:	6a42                	ld	s4,16(sp)
ffffffffc0204314:	6aa2                	ld	s5,8(sp)
ffffffffc0204316:	6121                	addi	sp,sp,64
ffffffffc0204318:	8082                	ret
    return 0;
ffffffffc020431a:	4501                	li	a0,0
ffffffffc020431c:	b7f5                	j	ffffffffc0204308 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc020431e:	00004697          	auipc	a3,0x4
ffffffffc0204322:	aca68693          	addi	a3,a3,-1334 # ffffffffc0207de8 <default_pmm_manager+0xd08>
ffffffffc0204326:	00002617          	auipc	a2,0x2
ffffffffc020432a:	67260613          	addi	a2,a2,1650 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020432e:	0c100593          	li	a1,193
ffffffffc0204332:	00004517          	auipc	a0,0x4
ffffffffc0204336:	a0650513          	addi	a0,a0,-1530 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020433a:	94afc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020433e <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020433e:	1101                	addi	sp,sp,-32
ffffffffc0204340:	ec06                	sd	ra,24(sp)
ffffffffc0204342:	e822                	sd	s0,16(sp)
ffffffffc0204344:	e426                	sd	s1,8(sp)
ffffffffc0204346:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204348:	c531                	beqz	a0,ffffffffc0204394 <exit_mmap+0x56>
ffffffffc020434a:	591c                	lw	a5,48(a0)
ffffffffc020434c:	84aa                	mv	s1,a0
ffffffffc020434e:	e3b9                	bnez	a5,ffffffffc0204394 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0204350:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204352:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204356:	02850663          	beq	a0,s0,ffffffffc0204382 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020435a:	ff043603          	ld	a2,-16(s0)
ffffffffc020435e:	fe843583          	ld	a1,-24(s0)
ffffffffc0204362:	854a                	mv	a0,s2
ffffffffc0204364:	e0dfd0ef          	jal	ra,ffffffffc0202170 <unmap_range>
ffffffffc0204368:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020436a:	fe8498e3          	bne	s1,s0,ffffffffc020435a <exit_mmap+0x1c>
ffffffffc020436e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc0204370:	00848c63          	beq	s1,s0,ffffffffc0204388 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204374:	ff043603          	ld	a2,-16(s0)
ffffffffc0204378:	fe843583          	ld	a1,-24(s0)
ffffffffc020437c:	854a                	mv	a0,s2
ffffffffc020437e:	f0bfd0ef          	jal	ra,ffffffffc0202288 <exit_range>
ffffffffc0204382:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204384:	fe8498e3          	bne	s1,s0,ffffffffc0204374 <exit_mmap+0x36>
    }
}
ffffffffc0204388:	60e2                	ld	ra,24(sp)
ffffffffc020438a:	6442                	ld	s0,16(sp)
ffffffffc020438c:	64a2                	ld	s1,8(sp)
ffffffffc020438e:	6902                	ld	s2,0(sp)
ffffffffc0204390:	6105                	addi	sp,sp,32
ffffffffc0204392:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204394:	00004697          	auipc	a3,0x4
ffffffffc0204398:	a7468693          	addi	a3,a3,-1420 # ffffffffc0207e08 <default_pmm_manager+0xd28>
ffffffffc020439c:	00002617          	auipc	a2,0x2
ffffffffc02043a0:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02043a4:	0d700593          	li	a1,215
ffffffffc02043a8:	00004517          	auipc	a0,0x4
ffffffffc02043ac:	99050513          	addi	a0,a0,-1648 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02043b0:	8d4fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02043b4 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02043b4:	7139                	addi	sp,sp,-64
ffffffffc02043b6:	f822                	sd	s0,48(sp)
ffffffffc02043b8:	f426                	sd	s1,40(sp)
ffffffffc02043ba:	fc06                	sd	ra,56(sp)
ffffffffc02043bc:	f04a                	sd	s2,32(sp)
ffffffffc02043be:	ec4e                	sd	s3,24(sp)
ffffffffc02043c0:	e852                	sd	s4,16(sp)
ffffffffc02043c2:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02043c4:	c55ff0ef          	jal	ra,ffffffffc0204018 <mm_create>
    assert(mm != NULL);
ffffffffc02043c8:	842a                	mv	s0,a0
ffffffffc02043ca:	03200493          	li	s1,50
ffffffffc02043ce:	e919                	bnez	a0,ffffffffc02043e4 <vmm_init+0x30>
ffffffffc02043d0:	a989                	j	ffffffffc0204822 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc02043d2:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02043d4:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02043d6:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02043da:	14ed                	addi	s1,s1,-5
ffffffffc02043dc:	8522                	mv	a0,s0
ffffffffc02043de:	cf3ff0ef          	jal	ra,ffffffffc02040d0 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc02043e2:	c88d                	beqz	s1,ffffffffc0204414 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02043e4:	03000513          	li	a0,48
ffffffffc02043e8:	84bfd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc02043ec:	85aa                	mv	a1,a0
ffffffffc02043ee:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02043f2:	f165                	bnez	a0,ffffffffc02043d2 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc02043f4:	00003697          	auipc	a3,0x3
ffffffffc02043f8:	4b468693          	addi	a3,a3,1204 # ffffffffc02078a8 <default_pmm_manager+0x7c8>
ffffffffc02043fc:	00002617          	auipc	a2,0x2
ffffffffc0204400:	59c60613          	addi	a2,a2,1436 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204404:	11400593          	li	a1,276
ffffffffc0204408:	00004517          	auipc	a0,0x4
ffffffffc020440c:	93050513          	addi	a0,a0,-1744 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc0204410:	874fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0204414:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204418:	1f900913          	li	s2,505
ffffffffc020441c:	a819                	j	ffffffffc0204432 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020441e:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204420:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204422:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204426:	0495                	addi	s1,s1,5
ffffffffc0204428:	8522                	mv	a0,s0
ffffffffc020442a:	ca7ff0ef          	jal	ra,ffffffffc02040d0 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020442e:	03248a63          	beq	s1,s2,ffffffffc0204462 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204432:	03000513          	li	a0,48
ffffffffc0204436:	ffcfd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc020443a:	85aa                	mv	a1,a0
ffffffffc020443c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204440:	fd79                	bnez	a0,ffffffffc020441e <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204442:	00003697          	auipc	a3,0x3
ffffffffc0204446:	46668693          	addi	a3,a3,1126 # ffffffffc02078a8 <default_pmm_manager+0x7c8>
ffffffffc020444a:	00002617          	auipc	a2,0x2
ffffffffc020444e:	54e60613          	addi	a2,a2,1358 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204452:	11a00593          	li	a1,282
ffffffffc0204456:	00004517          	auipc	a0,0x4
ffffffffc020445a:	8e250513          	addi	a0,a0,-1822 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020445e:	826fc0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204462:	6418                	ld	a4,8(s0)
ffffffffc0204464:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204466:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020446a:	2ee40063          	beq	s0,a4,ffffffffc020474a <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020446e:	fe873603          	ld	a2,-24(a4)
ffffffffc0204472:	ffe78693          	addi	a3,a5,-2
ffffffffc0204476:	24d61a63          	bne	a2,a3,ffffffffc02046ca <vmm_init+0x316>
ffffffffc020447a:	ff073683          	ld	a3,-16(a4)
ffffffffc020447e:	24f69663          	bne	a3,a5,ffffffffc02046ca <vmm_init+0x316>
ffffffffc0204482:	0795                	addi	a5,a5,5
ffffffffc0204484:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204486:	feb792e3          	bne	a5,a1,ffffffffc020446a <vmm_init+0xb6>
ffffffffc020448a:	491d                	li	s2,7
ffffffffc020448c:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020448e:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204492:	85a6                	mv	a1,s1
ffffffffc0204494:	8522                	mv	a0,s0
ffffffffc0204496:	bfdff0ef          	jal	ra,ffffffffc0204092 <find_vma>
ffffffffc020449a:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020449c:	30050763          	beqz	a0,ffffffffc02047aa <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02044a0:	00148593          	addi	a1,s1,1
ffffffffc02044a4:	8522                	mv	a0,s0
ffffffffc02044a6:	bedff0ef          	jal	ra,ffffffffc0204092 <find_vma>
ffffffffc02044aa:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02044ac:	2c050f63          	beqz	a0,ffffffffc020478a <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02044b0:	85ca                	mv	a1,s2
ffffffffc02044b2:	8522                	mv	a0,s0
ffffffffc02044b4:	bdfff0ef          	jal	ra,ffffffffc0204092 <find_vma>
        assert(vma3 == NULL);
ffffffffc02044b8:	2a051963          	bnez	a0,ffffffffc020476a <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02044bc:	00348593          	addi	a1,s1,3
ffffffffc02044c0:	8522                	mv	a0,s0
ffffffffc02044c2:	bd1ff0ef          	jal	ra,ffffffffc0204092 <find_vma>
        assert(vma4 == NULL);
ffffffffc02044c6:	32051263          	bnez	a0,ffffffffc02047ea <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02044ca:	00448593          	addi	a1,s1,4
ffffffffc02044ce:	8522                	mv	a0,s0
ffffffffc02044d0:	bc3ff0ef          	jal	ra,ffffffffc0204092 <find_vma>
        assert(vma5 == NULL);
ffffffffc02044d4:	2e051b63          	bnez	a0,ffffffffc02047ca <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02044d8:	008a3783          	ld	a5,8(s4)
ffffffffc02044dc:	20979763          	bne	a5,s1,ffffffffc02046ea <vmm_init+0x336>
ffffffffc02044e0:	010a3783          	ld	a5,16(s4)
ffffffffc02044e4:	21279363          	bne	a5,s2,ffffffffc02046ea <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02044e8:	0089b783          	ld	a5,8(s3)
ffffffffc02044ec:	20979f63          	bne	a5,s1,ffffffffc020470a <vmm_init+0x356>
ffffffffc02044f0:	0109b783          	ld	a5,16(s3)
ffffffffc02044f4:	21279b63          	bne	a5,s2,ffffffffc020470a <vmm_init+0x356>
ffffffffc02044f8:	0495                	addi	s1,s1,5
ffffffffc02044fa:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02044fc:	f9549be3          	bne	s1,s5,ffffffffc0204492 <vmm_init+0xde>
ffffffffc0204500:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204502:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204504:	85a6                	mv	a1,s1
ffffffffc0204506:	8522                	mv	a0,s0
ffffffffc0204508:	b8bff0ef          	jal	ra,ffffffffc0204092 <find_vma>
ffffffffc020450c:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0204510:	c90d                	beqz	a0,ffffffffc0204542 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204512:	6914                	ld	a3,16(a0)
ffffffffc0204514:	6510                	ld	a2,8(a0)
ffffffffc0204516:	00004517          	auipc	a0,0x4
ffffffffc020451a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc0207fa0 <default_pmm_manager+0xec0>
ffffffffc020451e:	c71fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0204522:	00004697          	auipc	a3,0x4
ffffffffc0204526:	aa668693          	addi	a3,a3,-1370 # ffffffffc0207fc8 <default_pmm_manager+0xee8>
ffffffffc020452a:	00002617          	auipc	a2,0x2
ffffffffc020452e:	46e60613          	addi	a2,a2,1134 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204532:	13c00593          	li	a1,316
ffffffffc0204536:	00004517          	auipc	a0,0x4
ffffffffc020453a:	80250513          	addi	a0,a0,-2046 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020453e:	f47fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204542:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0204544:	fd2490e3          	bne	s1,s2,ffffffffc0204504 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204548:	8522                	mv	a0,s0
ffffffffc020454a:	c55ff0ef          	jal	ra,ffffffffc020419e <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020454e:	00004517          	auipc	a0,0x4
ffffffffc0204552:	a9250513          	addi	a0,a0,-1390 # ffffffffc0207fe0 <default_pmm_manager+0xf00>
ffffffffc0204556:	c39fb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020455a:	9a3fd0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>
ffffffffc020455e:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0204560:	ab9ff0ef          	jal	ra,ffffffffc0204018 <mm_create>
ffffffffc0204564:	000a8797          	auipc	a5,0xa8
ffffffffc0204568:	18a7b223          	sd	a0,388(a5) # ffffffffc02ac6e8 <check_mm_struct>
ffffffffc020456c:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020456e:	36050663          	beqz	a0,ffffffffc02048da <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204572:	000a8797          	auipc	a5,0xa8
ffffffffc0204576:	01e78793          	addi	a5,a5,30 # ffffffffc02ac590 <boot_pgdir>
ffffffffc020457a:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020457e:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204582:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204586:	2c079e63          	bnez	a5,ffffffffc0204862 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020458a:	03000513          	li	a0,48
ffffffffc020458e:	ea4fd0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc0204592:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204594:	18050b63          	beqz	a0,ffffffffc020472a <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204598:	002007b7          	lui	a5,0x200
ffffffffc020459c:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020459e:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02045a0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02045a2:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc02045a4:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc02045a6:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc02045aa:	b27ff0ef          	jal	ra,ffffffffc02040d0 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02045ae:	10000593          	li	a1,256
ffffffffc02045b2:	8526                	mv	a0,s1
ffffffffc02045b4:	adfff0ef          	jal	ra,ffffffffc0204092 <find_vma>
ffffffffc02045b8:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02045bc:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02045c0:	2ca41163          	bne	s0,a0,ffffffffc0204882 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc02045c4:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5570>
        sum += i;
ffffffffc02045c8:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02045ca:	fee79de3          	bne	a5,a4,ffffffffc02045c4 <vmm_init+0x210>
        sum += i;
ffffffffc02045ce:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc02045d0:	10000793          	li	a5,256
        sum += i;
ffffffffc02045d4:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x823a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc02045d8:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc02045dc:	0007c683          	lbu	a3,0(a5)
ffffffffc02045e0:	0785                	addi	a5,a5,1
ffffffffc02045e2:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc02045e4:	fec79ce3          	bne	a5,a2,ffffffffc02045dc <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc02045e8:	2c071963          	bnez	a4,ffffffffc02048ba <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc02045ec:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02045f0:	000a8a97          	auipc	s5,0xa8
ffffffffc02045f4:	fa8a8a93          	addi	s5,s5,-88 # ffffffffc02ac598 <npage>
ffffffffc02045f8:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02045fc:	078a                	slli	a5,a5,0x2
ffffffffc02045fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204600:	20e7f563          	bleu	a4,a5,ffffffffc020480a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204604:	00004697          	auipc	a3,0x4
ffffffffc0204608:	3f468693          	addi	a3,a3,1012 # ffffffffc02089f8 <nbase>
ffffffffc020460c:	0006ba03          	ld	s4,0(a3)
ffffffffc0204610:	414786b3          	sub	a3,a5,s4
ffffffffc0204614:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204616:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204618:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020461a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020461c:	83b1                	srli	a5,a5,0xc
ffffffffc020461e:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204620:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204622:	28e7f063          	bleu	a4,a5,ffffffffc02048a2 <vmm_init+0x4ee>
ffffffffc0204626:	000a8797          	auipc	a5,0xa8
ffffffffc020462a:	fd278793          	addi	a5,a5,-46 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc020462e:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0204630:	4581                	li	a1,0
ffffffffc0204632:	854a                	mv	a0,s2
ffffffffc0204634:	9436                	add	s0,s0,a3
ffffffffc0204636:	ea9fd0ef          	jal	ra,ffffffffc02024de <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020463a:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020463c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204640:	078a                	slli	a5,a5,0x2
ffffffffc0204642:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204644:	1ce7f363          	bleu	a4,a5,ffffffffc020480a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204648:	000a8417          	auipc	s0,0xa8
ffffffffc020464c:	fc040413          	addi	s0,s0,-64 # ffffffffc02ac608 <pages>
ffffffffc0204650:	6008                	ld	a0,0(s0)
ffffffffc0204652:	414787b3          	sub	a5,a5,s4
ffffffffc0204656:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204658:	953e                	add	a0,a0,a5
ffffffffc020465a:	4585                	li	a1,1
ffffffffc020465c:	85bfd0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204660:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204664:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204668:	078a                	slli	a5,a5,0x2
ffffffffc020466a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020466c:	18e7ff63          	bleu	a4,a5,ffffffffc020480a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204670:	6008                	ld	a0,0(s0)
ffffffffc0204672:	414787b3          	sub	a5,a5,s4
ffffffffc0204676:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204678:	4585                	li	a1,1
ffffffffc020467a:	953e                	add	a0,a0,a5
ffffffffc020467c:	83bfd0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    pgdir[0] = 0;
ffffffffc0204680:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204684:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204688:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020468c:	8526                	mv	a0,s1
ffffffffc020468e:	b11ff0ef          	jal	ra,ffffffffc020419e <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204692:	000a8797          	auipc	a5,0xa8
ffffffffc0204696:	0407bb23          	sd	zero,86(a5) # ffffffffc02ac6e8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020469a:	863fd0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>
ffffffffc020469e:	1aa99263          	bne	s3,a0,ffffffffc0204842 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02046a2:	00004517          	auipc	a0,0x4
ffffffffc02046a6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc0208070 <default_pmm_manager+0xf90>
ffffffffc02046aa:	ae5fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc02046ae:	7442                	ld	s0,48(sp)
ffffffffc02046b0:	70e2                	ld	ra,56(sp)
ffffffffc02046b2:	74a2                	ld	s1,40(sp)
ffffffffc02046b4:	7902                	ld	s2,32(sp)
ffffffffc02046b6:	69e2                	ld	s3,24(sp)
ffffffffc02046b8:	6a42                	ld	s4,16(sp)
ffffffffc02046ba:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02046bc:	00004517          	auipc	a0,0x4
ffffffffc02046c0:	9d450513          	addi	a0,a0,-1580 # ffffffffc0208090 <default_pmm_manager+0xfb0>
}
ffffffffc02046c4:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02046c6:	ac9fb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02046ca:	00003697          	auipc	a3,0x3
ffffffffc02046ce:	7ee68693          	addi	a3,a3,2030 # ffffffffc0207eb8 <default_pmm_manager+0xdd8>
ffffffffc02046d2:	00002617          	auipc	a2,0x2
ffffffffc02046d6:	2c660613          	addi	a2,a2,710 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02046da:	12300593          	li	a1,291
ffffffffc02046de:	00003517          	auipc	a0,0x3
ffffffffc02046e2:	65a50513          	addi	a0,a0,1626 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02046e6:	d9ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc02046ea:	00004697          	auipc	a3,0x4
ffffffffc02046ee:	85668693          	addi	a3,a3,-1962 # ffffffffc0207f40 <default_pmm_manager+0xe60>
ffffffffc02046f2:	00002617          	auipc	a2,0x2
ffffffffc02046f6:	2a660613          	addi	a2,a2,678 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02046fa:	13300593          	li	a1,307
ffffffffc02046fe:	00003517          	auipc	a0,0x3
ffffffffc0204702:	63a50513          	addi	a0,a0,1594 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc0204706:	d7ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020470a:	00004697          	auipc	a3,0x4
ffffffffc020470e:	86668693          	addi	a3,a3,-1946 # ffffffffc0207f70 <default_pmm_manager+0xe90>
ffffffffc0204712:	00002617          	auipc	a2,0x2
ffffffffc0204716:	28660613          	addi	a2,a2,646 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020471a:	13400593          	li	a1,308
ffffffffc020471e:	00003517          	auipc	a0,0x3
ffffffffc0204722:	61a50513          	addi	a0,a0,1562 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc0204726:	d5ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(vma != NULL);
ffffffffc020472a:	00003697          	auipc	a3,0x3
ffffffffc020472e:	17e68693          	addi	a3,a3,382 # ffffffffc02078a8 <default_pmm_manager+0x7c8>
ffffffffc0204732:	00002617          	auipc	a2,0x2
ffffffffc0204736:	26660613          	addi	a2,a2,614 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020473a:	15300593          	li	a1,339
ffffffffc020473e:	00003517          	auipc	a0,0x3
ffffffffc0204742:	5fa50513          	addi	a0,a0,1530 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc0204746:	d3ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020474a:	00003697          	auipc	a3,0x3
ffffffffc020474e:	75668693          	addi	a3,a3,1878 # ffffffffc0207ea0 <default_pmm_manager+0xdc0>
ffffffffc0204752:	00002617          	auipc	a2,0x2
ffffffffc0204756:	24660613          	addi	a2,a2,582 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020475a:	12100593          	li	a1,289
ffffffffc020475e:	00003517          	auipc	a0,0x3
ffffffffc0204762:	5da50513          	addi	a0,a0,1498 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc0204766:	d1ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma3 == NULL);
ffffffffc020476a:	00003697          	auipc	a3,0x3
ffffffffc020476e:	7a668693          	addi	a3,a3,1958 # ffffffffc0207f10 <default_pmm_manager+0xe30>
ffffffffc0204772:	00002617          	auipc	a2,0x2
ffffffffc0204776:	22660613          	addi	a2,a2,550 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020477a:	12d00593          	li	a1,301
ffffffffc020477e:	00003517          	auipc	a0,0x3
ffffffffc0204782:	5ba50513          	addi	a0,a0,1466 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc0204786:	cfffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2 != NULL);
ffffffffc020478a:	00003697          	auipc	a3,0x3
ffffffffc020478e:	77668693          	addi	a3,a3,1910 # ffffffffc0207f00 <default_pmm_manager+0xe20>
ffffffffc0204792:	00002617          	auipc	a2,0x2
ffffffffc0204796:	20660613          	addi	a2,a2,518 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020479a:	12b00593          	li	a1,299
ffffffffc020479e:	00003517          	auipc	a0,0x3
ffffffffc02047a2:	59a50513          	addi	a0,a0,1434 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02047a6:	cdffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1 != NULL);
ffffffffc02047aa:	00003697          	auipc	a3,0x3
ffffffffc02047ae:	74668693          	addi	a3,a3,1862 # ffffffffc0207ef0 <default_pmm_manager+0xe10>
ffffffffc02047b2:	00002617          	auipc	a2,0x2
ffffffffc02047b6:	1e660613          	addi	a2,a2,486 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02047ba:	12900593          	li	a1,297
ffffffffc02047be:	00003517          	auipc	a0,0x3
ffffffffc02047c2:	57a50513          	addi	a0,a0,1402 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02047c6:	cbffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma5 == NULL);
ffffffffc02047ca:	00003697          	auipc	a3,0x3
ffffffffc02047ce:	76668693          	addi	a3,a3,1894 # ffffffffc0207f30 <default_pmm_manager+0xe50>
ffffffffc02047d2:	00002617          	auipc	a2,0x2
ffffffffc02047d6:	1c660613          	addi	a2,a2,454 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02047da:	13100593          	li	a1,305
ffffffffc02047de:	00003517          	auipc	a0,0x3
ffffffffc02047e2:	55a50513          	addi	a0,a0,1370 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02047e6:	c9ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma4 == NULL);
ffffffffc02047ea:	00003697          	auipc	a3,0x3
ffffffffc02047ee:	73668693          	addi	a3,a3,1846 # ffffffffc0207f20 <default_pmm_manager+0xe40>
ffffffffc02047f2:	00002617          	auipc	a2,0x2
ffffffffc02047f6:	1a660613          	addi	a2,a2,422 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02047fa:	12f00593          	li	a1,303
ffffffffc02047fe:	00003517          	auipc	a0,0x3
ffffffffc0204802:	53a50513          	addi	a0,a0,1338 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc0204806:	c7ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020480a:	00003617          	auipc	a2,0x3
ffffffffc020480e:	98660613          	addi	a2,a2,-1658 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc0204812:	06200593          	li	a1,98
ffffffffc0204816:	00003517          	auipc	a0,0x3
ffffffffc020481a:	94250513          	addi	a0,a0,-1726 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc020481e:	c67fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(mm != NULL);
ffffffffc0204822:	00003697          	auipc	a3,0x3
ffffffffc0204826:	04e68693          	addi	a3,a3,78 # ffffffffc0207870 <default_pmm_manager+0x790>
ffffffffc020482a:	00002617          	auipc	a2,0x2
ffffffffc020482e:	16e60613          	addi	a2,a2,366 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204832:	10d00593          	li	a1,269
ffffffffc0204836:	00003517          	auipc	a0,0x3
ffffffffc020483a:	50250513          	addi	a0,a0,1282 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020483e:	c47fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204842:	00004697          	auipc	a3,0x4
ffffffffc0204846:	80668693          	addi	a3,a3,-2042 # ffffffffc0208048 <default_pmm_manager+0xf68>
ffffffffc020484a:	00002617          	auipc	a2,0x2
ffffffffc020484e:	14e60613          	addi	a2,a2,334 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204852:	17100593          	li	a1,369
ffffffffc0204856:	00003517          	auipc	a0,0x3
ffffffffc020485a:	4e250513          	addi	a0,a0,1250 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020485e:	c27fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204862:	00003697          	auipc	a3,0x3
ffffffffc0204866:	03668693          	addi	a3,a3,54 # ffffffffc0207898 <default_pmm_manager+0x7b8>
ffffffffc020486a:	00002617          	auipc	a2,0x2
ffffffffc020486e:	12e60613          	addi	a2,a2,302 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204872:	15000593          	li	a1,336
ffffffffc0204876:	00003517          	auipc	a0,0x3
ffffffffc020487a:	4c250513          	addi	a0,a0,1218 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020487e:	c07fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204882:	00003697          	auipc	a3,0x3
ffffffffc0204886:	79668693          	addi	a3,a3,1942 # ffffffffc0208018 <default_pmm_manager+0xf38>
ffffffffc020488a:	00002617          	auipc	a2,0x2
ffffffffc020488e:	10e60613          	addi	a2,a2,270 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0204892:	15800593          	li	a1,344
ffffffffc0204896:	00003517          	auipc	a0,0x3
ffffffffc020489a:	4a250513          	addi	a0,a0,1186 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc020489e:	be7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02048a2:	00003617          	auipc	a2,0x3
ffffffffc02048a6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02048aa:	06900593          	li	a1,105
ffffffffc02048ae:	00003517          	auipc	a0,0x3
ffffffffc02048b2:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02048b6:	bcffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(sum == 0);
ffffffffc02048ba:	00003697          	auipc	a3,0x3
ffffffffc02048be:	77e68693          	addi	a3,a3,1918 # ffffffffc0208038 <default_pmm_manager+0xf58>
ffffffffc02048c2:	00002617          	auipc	a2,0x2
ffffffffc02048c6:	0d660613          	addi	a2,a2,214 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02048ca:	16400593          	li	a1,356
ffffffffc02048ce:	00003517          	auipc	a0,0x3
ffffffffc02048d2:	46a50513          	addi	a0,a0,1130 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02048d6:	baffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc02048da:	00003697          	auipc	a3,0x3
ffffffffc02048de:	72668693          	addi	a3,a3,1830 # ffffffffc0208000 <default_pmm_manager+0xf20>
ffffffffc02048e2:	00002617          	auipc	a2,0x2
ffffffffc02048e6:	0b660613          	addi	a2,a2,182 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02048ea:	14c00593          	li	a1,332
ffffffffc02048ee:	00003517          	auipc	a0,0x3
ffffffffc02048f2:	44a50513          	addi	a0,a0,1098 # ffffffffc0207d38 <default_pmm_manager+0xc58>
ffffffffc02048f6:	b8ffb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02048fa <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02048fa:	1101                	addi	sp,sp,-32
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02048fc:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc02048fe:	e822                	sd	s0,16(sp)
ffffffffc0204900:	e426                	sd	s1,8(sp)
ffffffffc0204902:	ec06                	sd	ra,24(sp)
ffffffffc0204904:	e04a                	sd	s2,0(sp)
ffffffffc0204906:	8432                	mv	s0,a2
ffffffffc0204908:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020490a:	f88ff0ef          	jal	ra,ffffffffc0204092 <find_vma>

    pgfault_num++;
ffffffffc020490e:	000a8797          	auipc	a5,0xa8
ffffffffc0204912:	c9e78793          	addi	a5,a5,-866 # ffffffffc02ac5ac <pgfault_num>
ffffffffc0204916:	439c                	lw	a5,0(a5)
ffffffffc0204918:	2785                	addiw	a5,a5,1
ffffffffc020491a:	000a8717          	auipc	a4,0xa8
ffffffffc020491e:	c8f72923          	sw	a5,-878(a4) # ffffffffc02ac5ac <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204922:	cd21                	beqz	a0,ffffffffc020497a <do_pgfault+0x80>
ffffffffc0204924:	651c                	ld	a5,8(a0)
ffffffffc0204926:	04f46a63          	bltu	s0,a5,ffffffffc020497a <do_pgfault+0x80>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020492a:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc020492c:	4941                	li	s2,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020492e:	8b89                	andi	a5,a5,2
ffffffffc0204930:	e78d                	bnez	a5,ffffffffc020495a <do_pgfault+0x60>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204932:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204934:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204936:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204938:	85a2                	mv	a1,s0
ffffffffc020493a:	4605                	li	a2,1
ffffffffc020493c:	e00fd0ef          	jal	ra,ffffffffc0201f3c <get_pte>
ffffffffc0204940:	cd31                	beqz	a0,ffffffffc020499c <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204942:	610c                	ld	a1,0(a0)
ffffffffc0204944:	cd89                	beqz	a1,ffffffffc020495e <do_pgfault+0x64>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204946:	000a8797          	auipc	a5,0xa8
ffffffffc020494a:	c6278793          	addi	a5,a5,-926 # ffffffffc02ac5a8 <swap_init_ok>
ffffffffc020494e:	439c                	lw	a5,0(a5)
ffffffffc0204950:	2781                	sext.w	a5,a5
ffffffffc0204952:	cf8d                	beqz	a5,ffffffffc020498c <do_pgfault+0x92>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            page->pra_vaddr = addr;
ffffffffc0204954:	02003c23          	sd	zero,56(zero) # 38 <_binary_obj___user_faultread_out_size-0x9558>
ffffffffc0204958:	9002                	ebreak
        perm |= READ_WRITE;
ffffffffc020495a:	495d                	li	s2,23
ffffffffc020495c:	bfd9                	j	ffffffffc0204932 <do_pgfault+0x38>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020495e:	6c88                	ld	a0,24(s1)
ffffffffc0204960:	864a                	mv	a2,s2
ffffffffc0204962:	85a2                	mv	a1,s0
ffffffffc0204964:	961fe0ef          	jal	ra,ffffffffc02032c4 <pgdir_alloc_page>
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
   ret = 0;
ffffffffc0204968:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc020496a:	c129                	beqz	a0,ffffffffc02049ac <do_pgfault+0xb2>
failed:
    return ret;
}
ffffffffc020496c:	60e2                	ld	ra,24(sp)
ffffffffc020496e:	6442                	ld	s0,16(sp)
ffffffffc0204970:	64a2                	ld	s1,8(sp)
ffffffffc0204972:	6902                	ld	s2,0(sp)
ffffffffc0204974:	853e                	mv	a0,a5
ffffffffc0204976:	6105                	addi	sp,sp,32
ffffffffc0204978:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc020497a:	85a2                	mv	a1,s0
ffffffffc020497c:	00003517          	auipc	a0,0x3
ffffffffc0204980:	3cc50513          	addi	a0,a0,972 # ffffffffc0207d48 <default_pmm_manager+0xc68>
ffffffffc0204984:	80bfb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204988:	57f5                	li	a5,-3
        goto failed;
ffffffffc020498a:	b7cd                	j	ffffffffc020496c <do_pgfault+0x72>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc020498c:	00003517          	auipc	a0,0x3
ffffffffc0204990:	43450513          	addi	a0,a0,1076 # ffffffffc0207dc0 <default_pmm_manager+0xce0>
ffffffffc0204994:	ffafb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204998:	57f1                	li	a5,-4
            goto failed;
ffffffffc020499a:	bfc9                	j	ffffffffc020496c <do_pgfault+0x72>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc020499c:	00003517          	auipc	a0,0x3
ffffffffc02049a0:	3dc50513          	addi	a0,a0,988 # ffffffffc0207d78 <default_pmm_manager+0xc98>
ffffffffc02049a4:	feafb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02049a8:	57f1                	li	a5,-4
        goto failed;
ffffffffc02049aa:	b7c9                	j	ffffffffc020496c <do_pgfault+0x72>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc02049ac:	00003517          	auipc	a0,0x3
ffffffffc02049b0:	3ec50513          	addi	a0,a0,1004 # ffffffffc0207d98 <default_pmm_manager+0xcb8>
ffffffffc02049b4:	fdafb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc02049b8:	57f1                	li	a5,-4
            goto failed;
ffffffffc02049ba:	bf4d                	j	ffffffffc020496c <do_pgfault+0x72>

ffffffffc02049bc <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc02049bc:	7179                	addi	sp,sp,-48
ffffffffc02049be:	f022                	sd	s0,32(sp)
ffffffffc02049c0:	f406                	sd	ra,40(sp)
ffffffffc02049c2:	ec26                	sd	s1,24(sp)
ffffffffc02049c4:	e84a                	sd	s2,16(sp)
ffffffffc02049c6:	e44e                	sd	s3,8(sp)
ffffffffc02049c8:	e052                	sd	s4,0(sp)
ffffffffc02049ca:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc02049cc:	c135                	beqz	a0,ffffffffc0204a30 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc02049ce:	002007b7          	lui	a5,0x200
ffffffffc02049d2:	04f5e663          	bltu	a1,a5,ffffffffc0204a1e <user_mem_check+0x62>
ffffffffc02049d6:	00c584b3          	add	s1,a1,a2
ffffffffc02049da:	0495f263          	bleu	s1,a1,ffffffffc0204a1e <user_mem_check+0x62>
ffffffffc02049de:	4785                	li	a5,1
ffffffffc02049e0:	07fe                	slli	a5,a5,0x1f
ffffffffc02049e2:	0297ee63          	bltu	a5,s1,ffffffffc0204a1e <user_mem_check+0x62>
ffffffffc02049e6:	892a                	mv	s2,a0
ffffffffc02049e8:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049ea:	6a05                	lui	s4,0x1
ffffffffc02049ec:	a821                	j	ffffffffc0204a04 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049ee:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049f2:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02049f4:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc02049f6:	c685                	beqz	a3,ffffffffc0204a1e <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc02049f8:	c399                	beqz	a5,ffffffffc02049fe <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc02049fa:	02e46263          	bltu	s0,a4,ffffffffc0204a1e <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc02049fe:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204a00:	04947663          	bleu	s1,s0,ffffffffc0204a4c <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204a04:	85a2                	mv	a1,s0
ffffffffc0204a06:	854a                	mv	a0,s2
ffffffffc0204a08:	e8aff0ef          	jal	ra,ffffffffc0204092 <find_vma>
ffffffffc0204a0c:	c909                	beqz	a0,ffffffffc0204a1e <user_mem_check+0x62>
ffffffffc0204a0e:	6518                	ld	a4,8(a0)
ffffffffc0204a10:	00e46763          	bltu	s0,a4,ffffffffc0204a1e <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204a14:	4d1c                	lw	a5,24(a0)
ffffffffc0204a16:	fc099ce3          	bnez	s3,ffffffffc02049ee <user_mem_check+0x32>
ffffffffc0204a1a:	8b85                	andi	a5,a5,1
ffffffffc0204a1c:	f3ed                	bnez	a5,ffffffffc02049fe <user_mem_check+0x42>
            return 0;
ffffffffc0204a1e:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204a20:	70a2                	ld	ra,40(sp)
ffffffffc0204a22:	7402                	ld	s0,32(sp)
ffffffffc0204a24:	64e2                	ld	s1,24(sp)
ffffffffc0204a26:	6942                	ld	s2,16(sp)
ffffffffc0204a28:	69a2                	ld	s3,8(sp)
ffffffffc0204a2a:	6a02                	ld	s4,0(sp)
ffffffffc0204a2c:	6145                	addi	sp,sp,48
ffffffffc0204a2e:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204a30:	c02007b7          	lui	a5,0xc0200
ffffffffc0204a34:	4501                	li	a0,0
ffffffffc0204a36:	fef5e5e3          	bltu	a1,a5,ffffffffc0204a20 <user_mem_check+0x64>
ffffffffc0204a3a:	962e                	add	a2,a2,a1
ffffffffc0204a3c:	fec5f2e3          	bleu	a2,a1,ffffffffc0204a20 <user_mem_check+0x64>
ffffffffc0204a40:	c8000537          	lui	a0,0xc8000
ffffffffc0204a44:	0505                	addi	a0,a0,1
ffffffffc0204a46:	00a63533          	sltu	a0,a2,a0
ffffffffc0204a4a:	bfd9                	j	ffffffffc0204a20 <user_mem_check+0x64>
        return 1;
ffffffffc0204a4c:	4505                	li	a0,1
ffffffffc0204a4e:	bfc9                	j	ffffffffc0204a20 <user_mem_check+0x64>

ffffffffc0204a50 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204a50:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204a52:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204a54:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204a56:	ba9fb0ef          	jal	ra,ffffffffc02005fe <ide_device_valid>
ffffffffc0204a5a:	cd01                	beqz	a0,ffffffffc0204a72 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204a5c:	4505                	li	a0,1
ffffffffc0204a5e:	ba7fb0ef          	jal	ra,ffffffffc0200604 <ide_device_size>
}
ffffffffc0204a62:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204a64:	810d                	srli	a0,a0,0x3
ffffffffc0204a66:	000a8797          	auipc	a5,0xa8
ffffffffc0204a6a:	c2a7b923          	sd	a0,-974(a5) # ffffffffc02ac698 <max_swap_offset>
}
ffffffffc0204a6e:	0141                	addi	sp,sp,16
ffffffffc0204a70:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204a72:	00003617          	auipc	a2,0x3
ffffffffc0204a76:	63660613          	addi	a2,a2,1590 # ffffffffc02080a8 <default_pmm_manager+0xfc8>
ffffffffc0204a7a:	45b5                	li	a1,13
ffffffffc0204a7c:	00003517          	auipc	a0,0x3
ffffffffc0204a80:	64c50513          	addi	a0,a0,1612 # ffffffffc02080c8 <default_pmm_manager+0xfe8>
ffffffffc0204a84:	a01fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204a88 <swapfs_write>:
swapfs_read(swap_entry_t entry, struct Page *page) {
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204a88:	1141                	addi	sp,sp,-16
ffffffffc0204a8a:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204a8c:	00855793          	srli	a5,a0,0x8
ffffffffc0204a90:	cfb9                	beqz	a5,ffffffffc0204aee <swapfs_write+0x66>
ffffffffc0204a92:	000a8717          	auipc	a4,0xa8
ffffffffc0204a96:	c0670713          	addi	a4,a4,-1018 # ffffffffc02ac698 <max_swap_offset>
ffffffffc0204a9a:	6318                	ld	a4,0(a4)
ffffffffc0204a9c:	04e7f963          	bleu	a4,a5,ffffffffc0204aee <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204aa0:	000a8717          	auipc	a4,0xa8
ffffffffc0204aa4:	b6870713          	addi	a4,a4,-1176 # ffffffffc02ac608 <pages>
ffffffffc0204aa8:	6310                	ld	a2,0(a4)
ffffffffc0204aaa:	00004717          	auipc	a4,0x4
ffffffffc0204aae:	f4e70713          	addi	a4,a4,-178 # ffffffffc02089f8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204ab2:	000a8697          	auipc	a3,0xa8
ffffffffc0204ab6:	ae668693          	addi	a3,a3,-1306 # ffffffffc02ac598 <npage>
    return page - pages + nbase;
ffffffffc0204aba:	40c58633          	sub	a2,a1,a2
ffffffffc0204abe:	630c                	ld	a1,0(a4)
ffffffffc0204ac0:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204ac2:	577d                	li	a4,-1
ffffffffc0204ac4:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204ac6:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204ac8:	8331                	srli	a4,a4,0xc
ffffffffc0204aca:	8f71                	and	a4,a4,a2
ffffffffc0204acc:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ad0:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204ad2:	02d77a63          	bleu	a3,a4,ffffffffc0204b06 <swapfs_write+0x7e>
ffffffffc0204ad6:	000a8797          	auipc	a5,0xa8
ffffffffc0204ada:	b2278793          	addi	a5,a5,-1246 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0204ade:	639c                	ld	a5,0(a5)
}
ffffffffc0204ae0:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ae2:	46a1                	li	a3,8
ffffffffc0204ae4:	963e                	add	a2,a2,a5
ffffffffc0204ae6:	4505                	li	a0,1
}
ffffffffc0204ae8:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204aea:	b21fb06f          	j	ffffffffc020060a <ide_write_secs>
ffffffffc0204aee:	86aa                	mv	a3,a0
ffffffffc0204af0:	00003617          	auipc	a2,0x3
ffffffffc0204af4:	5f060613          	addi	a2,a2,1520 # ffffffffc02080e0 <default_pmm_manager+0x1000>
ffffffffc0204af8:	45e5                	li	a1,25
ffffffffc0204afa:	00003517          	auipc	a0,0x3
ffffffffc0204afe:	5ce50513          	addi	a0,a0,1486 # ffffffffc02080c8 <default_pmm_manager+0xfe8>
ffffffffc0204b02:	983fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204b06:	86b2                	mv	a3,a2
ffffffffc0204b08:	06900593          	li	a1,105
ffffffffc0204b0c:	00002617          	auipc	a2,0x2
ffffffffc0204b10:	62460613          	addi	a2,a2,1572 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0204b14:	00002517          	auipc	a0,0x2
ffffffffc0204b18:	64450513          	addi	a0,a0,1604 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0204b1c:	969fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204b20 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204b20:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204b22:	9402                	jalr	s0

	jal do_exit
ffffffffc0204b24:	646000ef          	jal	ra,ffffffffc020516a <do_exit>

ffffffffc0204b28 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204b28:	000a8797          	auipc	a5,0xa8
ffffffffc0204b2c:	a8878793          	addi	a5,a5,-1400 # ffffffffc02ac5b0 <current>
ffffffffc0204b30:	639c                	ld	a5,0(a5)
ffffffffc0204b32:	73c8                	ld	a0,160(a5)
ffffffffc0204b34:	a52fc06f          	j	ffffffffc0200d86 <forkrets>

ffffffffc0204b38 <user_main>:
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);    // problem:这儿不是exit吗，不应该是hello吗
ffffffffc0204b38:	000a8797          	auipc	a5,0xa8
ffffffffc0204b3c:	a7878793          	addi	a5,a5,-1416 # ffffffffc02ac5b0 <current>
ffffffffc0204b40:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204b42:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE(exit);    // problem:这儿不是exit吗，不应该是hello吗
ffffffffc0204b44:	00004617          	auipc	a2,0x4
ffffffffc0204b48:	98c60613          	addi	a2,a2,-1652 # ffffffffc02084d0 <default_pmm_manager+0x13f0>
ffffffffc0204b4c:	43cc                	lw	a1,4(a5)
ffffffffc0204b4e:	00004517          	auipc	a0,0x4
ffffffffc0204b52:	98a50513          	addi	a0,a0,-1654 # ffffffffc02084d8 <default_pmm_manager+0x13f8>
user_main(void *arg) {
ffffffffc0204b56:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE(exit);    // problem:这儿不是exit吗，不应该是hello吗
ffffffffc0204b58:	e36fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204b5c:	00004797          	auipc	a5,0x4
ffffffffc0204b60:	97478793          	addi	a5,a5,-1676 # ffffffffc02084d0 <default_pmm_manager+0x13f0>
ffffffffc0204b64:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204b68:	f2c70713          	addi	a4,a4,-212 # aa90 <_binary_obj___user_exit_out_size>
ffffffffc0204b6c:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204b6e:	853e                	mv	a0,a5
ffffffffc0204b70:	00025717          	auipc	a4,0x25
ffffffffc0204b74:	64870713          	addi	a4,a4,1608 # ffffffffc022a1b8 <_binary_obj___user_exit_out_start>
ffffffffc0204b78:	f03a                	sd	a4,32(sp)
ffffffffc0204b7a:	f43e                	sd	a5,40(sp)
ffffffffc0204b7c:	e802                	sd	zero,16(sp)
ffffffffc0204b7e:	75c010ef          	jal	ra,ffffffffc02062da <strlen>
ffffffffc0204b82:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204b84:	4511                	li	a0,4
ffffffffc0204b86:	55a2                	lw	a1,40(sp)
ffffffffc0204b88:	4662                	lw	a2,24(sp)
ffffffffc0204b8a:	5682                	lw	a3,32(sp)
ffffffffc0204b8c:	4722                	lw	a4,8(sp)
ffffffffc0204b8e:	48a9                	li	a7,10
ffffffffc0204b90:	9002                	ebreak
ffffffffc0204b92:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204b94:	65c2                	ld	a1,16(sp)
ffffffffc0204b96:	00004517          	auipc	a0,0x4
ffffffffc0204b9a:	96a50513          	addi	a0,a0,-1686 # ffffffffc0208500 <default_pmm_manager+0x1420>
ffffffffc0204b9e:	df0fb0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
    panic("user_main execve failed.\n");
ffffffffc0204ba2:	00004617          	auipc	a2,0x4
ffffffffc0204ba6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0208510 <default_pmm_manager+0x1430>
ffffffffc0204baa:	34100593          	li	a1,833
ffffffffc0204bae:	00004517          	auipc	a0,0x4
ffffffffc0204bb2:	98250513          	addi	a0,a0,-1662 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0204bb6:	8cffb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204bba <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204bba:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204bbc:	1141                	addi	sp,sp,-16
ffffffffc0204bbe:	e406                	sd	ra,8(sp)
ffffffffc0204bc0:	c02007b7          	lui	a5,0xc0200
ffffffffc0204bc4:	04f6e263          	bltu	a3,a5,ffffffffc0204c08 <put_pgdir+0x4e>
ffffffffc0204bc8:	000a8797          	auipc	a5,0xa8
ffffffffc0204bcc:	a3078793          	addi	a5,a5,-1488 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0204bd0:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204bd2:	000a8797          	auipc	a5,0xa8
ffffffffc0204bd6:	9c678793          	addi	a5,a5,-1594 # ffffffffc02ac598 <npage>
ffffffffc0204bda:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204bdc:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204bde:	82b1                	srli	a3,a3,0xc
ffffffffc0204be0:	04f6f063          	bleu	a5,a3,ffffffffc0204c20 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204be4:	00004797          	auipc	a5,0x4
ffffffffc0204be8:	e1478793          	addi	a5,a5,-492 # ffffffffc02089f8 <nbase>
ffffffffc0204bec:	639c                	ld	a5,0(a5)
ffffffffc0204bee:	000a8717          	auipc	a4,0xa8
ffffffffc0204bf2:	a1a70713          	addi	a4,a4,-1510 # ffffffffc02ac608 <pages>
ffffffffc0204bf6:	6308                	ld	a0,0(a4)
}
ffffffffc0204bf8:	60a2                	ld	ra,8(sp)
ffffffffc0204bfa:	8e9d                	sub	a3,a3,a5
ffffffffc0204bfc:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204bfe:	4585                	li	a1,1
ffffffffc0204c00:	9536                	add	a0,a0,a3
}
ffffffffc0204c02:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204c04:	ab2fd06f          	j	ffffffffc0201eb6 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204c08:	00002617          	auipc	a2,0x2
ffffffffc0204c0c:	56060613          	addi	a2,a2,1376 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc0204c10:	06e00593          	li	a1,110
ffffffffc0204c14:	00002517          	auipc	a0,0x2
ffffffffc0204c18:	54450513          	addi	a0,a0,1348 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0204c1c:	869fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204c20:	00002617          	auipc	a2,0x2
ffffffffc0204c24:	57060613          	addi	a2,a2,1392 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc0204c28:	06200593          	li	a1,98
ffffffffc0204c2c:	00002517          	auipc	a0,0x2
ffffffffc0204c30:	52c50513          	addi	a0,a0,1324 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0204c34:	851fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204c38 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204c38:	1101                	addi	sp,sp,-32
ffffffffc0204c3a:	e426                	sd	s1,8(sp)
ffffffffc0204c3c:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204c3e:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204c40:	ec06                	sd	ra,24(sp)
ffffffffc0204c42:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204c44:	9eafd0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
ffffffffc0204c48:	c125                	beqz	a0,ffffffffc0204ca8 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204c4a:	000a8797          	auipc	a5,0xa8
ffffffffc0204c4e:	9be78793          	addi	a5,a5,-1602 # ffffffffc02ac608 <pages>
ffffffffc0204c52:	6394                	ld	a3,0(a5)
ffffffffc0204c54:	00004797          	auipc	a5,0x4
ffffffffc0204c58:	da478793          	addi	a5,a5,-604 # ffffffffc02089f8 <nbase>
ffffffffc0204c5c:	6380                	ld	s0,0(a5)
ffffffffc0204c5e:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204c62:	000a8717          	auipc	a4,0xa8
ffffffffc0204c66:	93670713          	addi	a4,a4,-1738 # ffffffffc02ac598 <npage>
    return page - pages + nbase;
ffffffffc0204c6a:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204c6c:	57fd                	li	a5,-1
ffffffffc0204c6e:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204c70:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204c72:	83b1                	srli	a5,a5,0xc
ffffffffc0204c74:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c76:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204c78:	02e7fa63          	bleu	a4,a5,ffffffffc0204cac <setup_pgdir+0x74>
ffffffffc0204c7c:	000a8797          	auipc	a5,0xa8
ffffffffc0204c80:	97c78793          	addi	a5,a5,-1668 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0204c84:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);  // 设置内核虚拟空间
ffffffffc0204c86:	000a8797          	auipc	a5,0xa8
ffffffffc0204c8a:	90a78793          	addi	a5,a5,-1782 # ffffffffc02ac590 <boot_pgdir>
ffffffffc0204c8e:	638c                	ld	a1,0(a5)
ffffffffc0204c90:	9436                	add	s0,s0,a3
ffffffffc0204c92:	6605                	lui	a2,0x1
ffffffffc0204c94:	8522                	mv	a0,s0
ffffffffc0204c96:	6f4010ef          	jal	ra,ffffffffc020638a <memcpy>
    return 0;
ffffffffc0204c9a:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204c9c:	ec80                	sd	s0,24(s1)
}
ffffffffc0204c9e:	60e2                	ld	ra,24(sp)
ffffffffc0204ca0:	6442                	ld	s0,16(sp)
ffffffffc0204ca2:	64a2                	ld	s1,8(sp)
ffffffffc0204ca4:	6105                	addi	sp,sp,32
ffffffffc0204ca6:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204ca8:	5571                	li	a0,-4
ffffffffc0204caa:	bfd5                	j	ffffffffc0204c9e <setup_pgdir+0x66>
ffffffffc0204cac:	00002617          	auipc	a2,0x2
ffffffffc0204cb0:	48460613          	addi	a2,a2,1156 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc0204cb4:	06900593          	li	a1,105
ffffffffc0204cb8:	00002517          	auipc	a0,0x2
ffffffffc0204cbc:	4a050513          	addi	a0,a0,1184 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0204cc0:	fc4fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204cc4 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204cc4:	1101                	addi	sp,sp,-32
ffffffffc0204cc6:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204cc8:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ccc:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204cce:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204cd0:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204cd2:	8522                	mv	a0,s0
ffffffffc0204cd4:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204cd6:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204cd8:	6a0010ef          	jal	ra,ffffffffc0206378 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204cdc:	8522                	mv	a0,s0
}
ffffffffc0204cde:	6442                	ld	s0,16(sp)
ffffffffc0204ce0:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ce2:	85a6                	mv	a1,s1
}
ffffffffc0204ce4:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ce6:	463d                	li	a2,15
}
ffffffffc0204ce8:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204cea:	6a00106f          	j	ffffffffc020638a <memcpy>

ffffffffc0204cee <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204cee:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204cf0:	000a8797          	auipc	a5,0xa8
ffffffffc0204cf4:	8c078793          	addi	a5,a5,-1856 # ffffffffc02ac5b0 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204cf8:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204cfa:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204cfc:	ec06                	sd	ra,24(sp)
ffffffffc0204cfe:	e822                	sd	s0,16(sp)
ffffffffc0204d00:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204d02:	02a48b63          	beq	s1,a0,ffffffffc0204d38 <proc_run+0x4a>
ffffffffc0204d06:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d08:	100027f3          	csrr	a5,sstatus
ffffffffc0204d0c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204d0e:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d10:	e3a9                	bnez	a5,ffffffffc0204d52 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204d12:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204d14:	000a8717          	auipc	a4,0xa8
ffffffffc0204d18:	88873e23          	sd	s0,-1892(a4) # ffffffffc02ac5b0 <current>
ffffffffc0204d1c:	577d                	li	a4,-1
ffffffffc0204d1e:	177e                	slli	a4,a4,0x3f
ffffffffc0204d20:	83b1                	srli	a5,a5,0xc
ffffffffc0204d22:	8fd9                	or	a5,a5,a4
ffffffffc0204d24:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(proc->context));
ffffffffc0204d28:	03040593          	addi	a1,s0,48
ffffffffc0204d2c:	03048513          	addi	a0,s1,48
ffffffffc0204d30:	73f000ef          	jal	ra,ffffffffc0205c6e <switch_to>
    if (flag) {
ffffffffc0204d34:	00091863          	bnez	s2,ffffffffc0204d44 <proc_run+0x56>
}
ffffffffc0204d38:	60e2                	ld	ra,24(sp)
ffffffffc0204d3a:	6442                	ld	s0,16(sp)
ffffffffc0204d3c:	64a2                	ld	s1,8(sp)
ffffffffc0204d3e:	6902                	ld	s2,0(sp)
ffffffffc0204d40:	6105                	addi	sp,sp,32
ffffffffc0204d42:	8082                	ret
ffffffffc0204d44:	6442                	ld	s0,16(sp)
ffffffffc0204d46:	60e2                	ld	ra,24(sp)
ffffffffc0204d48:	64a2                	ld	s1,8(sp)
ffffffffc0204d4a:	6902                	ld	s2,0(sp)
ffffffffc0204d4c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204d4e:	8e3fb06f          	j	ffffffffc0200630 <intr_enable>
        intr_disable();
ffffffffc0204d52:	8e5fb0ef          	jal	ra,ffffffffc0200636 <intr_disable>
        return 1;
ffffffffc0204d56:	4905                	li	s2,1
ffffffffc0204d58:	bf6d                	j	ffffffffc0204d12 <proc_run+0x24>

ffffffffc0204d5a <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204d5a:	0005071b          	sext.w	a4,a0
ffffffffc0204d5e:	6789                	lui	a5,0x2
ffffffffc0204d60:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204d64:	17f9                	addi	a5,a5,-2
ffffffffc0204d66:	04d7e063          	bltu	a5,a3,ffffffffc0204da6 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204d6a:	1141                	addi	sp,sp,-16
ffffffffc0204d6c:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204d6e:	45a9                	li	a1,10
ffffffffc0204d70:	842a                	mv	s0,a0
ffffffffc0204d72:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204d74:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204d76:	154010ef          	jal	ra,ffffffffc0205eca <hash32>
ffffffffc0204d7a:	02051693          	slli	a3,a0,0x20
ffffffffc0204d7e:	82f1                	srli	a3,a3,0x1c
ffffffffc0204d80:	000a3517          	auipc	a0,0xa3
ffffffffc0204d84:	7f850513          	addi	a0,a0,2040 # ffffffffc02a8578 <hash_list>
ffffffffc0204d88:	96aa                	add	a3,a3,a0
ffffffffc0204d8a:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204d8c:	a029                	j	ffffffffc0204d96 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204d8e:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7664>
ffffffffc0204d92:	00870c63          	beq	a4,s0,ffffffffc0204daa <find_proc+0x50>
ffffffffc0204d96:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204d98:	fef69be3          	bne	a3,a5,ffffffffc0204d8e <find_proc+0x34>
}
ffffffffc0204d9c:	60a2                	ld	ra,8(sp)
ffffffffc0204d9e:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204da0:	4501                	li	a0,0
}
ffffffffc0204da2:	0141                	addi	sp,sp,16
ffffffffc0204da4:	8082                	ret
    return NULL;
ffffffffc0204da6:	4501                	li	a0,0
}
ffffffffc0204da8:	8082                	ret
ffffffffc0204daa:	60a2                	ld	ra,8(sp)
ffffffffc0204dac:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204dae:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204db2:	0141                	addi	sp,sp,16
ffffffffc0204db4:	8082                	ret

ffffffffc0204db6 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204db6:	7159                	addi	sp,sp,-112
ffffffffc0204db8:	e4ce                	sd	s3,72(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204dba:	000a8997          	auipc	s3,0xa8
ffffffffc0204dbe:	80e98993          	addi	s3,s3,-2034 # ffffffffc02ac5c8 <nr_process>
ffffffffc0204dc2:	0009a703          	lw	a4,0(s3)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204dc6:	f486                	sd	ra,104(sp)
ffffffffc0204dc8:	f0a2                	sd	s0,96(sp)
ffffffffc0204dca:	eca6                	sd	s1,88(sp)
ffffffffc0204dcc:	e8ca                	sd	s2,80(sp)
ffffffffc0204dce:	e0d2                	sd	s4,64(sp)
ffffffffc0204dd0:	fc56                	sd	s5,56(sp)
ffffffffc0204dd2:	f85a                	sd	s6,48(sp)
ffffffffc0204dd4:	f45e                	sd	s7,40(sp)
ffffffffc0204dd6:	f062                	sd	s8,32(sp)
ffffffffc0204dd8:	ec66                	sd	s9,24(sp)
ffffffffc0204dda:	e86a                	sd	s10,16(sp)
ffffffffc0204ddc:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204dde:	6785                	lui	a5,0x1
ffffffffc0204de0:	2af75e63          	ble	a5,a4,ffffffffc020509c <do_fork+0x2e6>
ffffffffc0204de4:	892a                	mv	s2,a0
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204de6:	10800513          	li	a0,264
ffffffffc0204dea:	84ae                	mv	s1,a1
ffffffffc0204dec:	8432                	mv	s0,a2
ffffffffc0204dee:	e45fc0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
ffffffffc0204df2:	8baa                	mv	s7,a0
    if((proc = alloc_proc()) == NULL){
ffffffffc0204df4:	28050263          	beqz	a0,ffffffffc0205078 <do_fork+0x2c2>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204df8:	4509                	li	a0,2
ffffffffc0204dfa:	834fd0ef          	jal	ra,ffffffffc0201e2e <alloc_pages>
    if (page != NULL) {
ffffffffc0204dfe:	26050a63          	beqz	a0,ffffffffc0205072 <do_fork+0x2bc>
    return page - pages + nbase;
ffffffffc0204e02:	000a8a17          	auipc	s4,0xa8
ffffffffc0204e06:	806a0a13          	addi	s4,s4,-2042 # ffffffffc02ac608 <pages>
ffffffffc0204e0a:	000a3683          	ld	a3,0(s4)
ffffffffc0204e0e:	00004a97          	auipc	s5,0x4
ffffffffc0204e12:	beaa8a93          	addi	s5,s5,-1046 # ffffffffc02089f8 <nbase>
ffffffffc0204e16:	000ab783          	ld	a5,0(s5)
ffffffffc0204e1a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e1e:	000a7b17          	auipc	s6,0xa7
ffffffffc0204e22:	77ab0b13          	addi	s6,s6,1914 # ffffffffc02ac598 <npage>
    return page - pages + nbase;
ffffffffc0204e26:	8699                	srai	a3,a3,0x6
ffffffffc0204e28:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204e2a:	000b3703          	ld	a4,0(s6)
ffffffffc0204e2e:	57fd                	li	a5,-1
ffffffffc0204e30:	83b1                	srli	a5,a5,0xc
ffffffffc0204e32:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e34:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e36:	26e7f563          	bleu	a4,a5,ffffffffc02050a0 <do_fork+0x2ea>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204e3a:	000a7797          	auipc	a5,0xa7
ffffffffc0204e3e:	77678793          	addi	a5,a5,1910 # ffffffffc02ac5b0 <current>
ffffffffc0204e42:	6398                	ld	a4,0(a5)
ffffffffc0204e44:	000a7c97          	auipc	s9,0xa7
ffffffffc0204e48:	7b4c8c93          	addi	s9,s9,1972 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0204e4c:	000cb783          	ld	a5,0(s9)
ffffffffc0204e50:	02873c03          	ld	s8,40(a4)
ffffffffc0204e54:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204e56:	00dbb823          	sd	a3,16(s7)
    if (oldmm == NULL) {
ffffffffc0204e5a:	020c0a63          	beqz	s8,ffffffffc0204e8e <do_fork+0xd8>
    if (clone_flags & CLONE_VM) {
ffffffffc0204e5e:	10097913          	andi	s2,s2,256
ffffffffc0204e62:	18090563          	beqz	s2,ffffffffc0204fec <do_fork+0x236>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0204e66:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e6a:	018c3783          	ld	a5,24(s8)
ffffffffc0204e6e:	c02006b7          	lui	a3,0xc0200
ffffffffc0204e72:	2705                	addiw	a4,a4,1
ffffffffc0204e74:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0204e78:	038bb423          	sd	s8,40(s7)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0204e7c:	22d7ee63          	bltu	a5,a3,ffffffffc02050b8 <do_fork+0x302>
ffffffffc0204e80:	000cb703          	ld	a4,0(s9)
ffffffffc0204e84:	010bb683          	ld	a3,16(s7)
ffffffffc0204e88:	8f99                	sub	a5,a5,a4
ffffffffc0204e8a:	0afbb423          	sd	a5,168(s7)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204e8e:	6789                	lui	a5,0x2
ffffffffc0204e90:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76b0>
ffffffffc0204e94:	96be                	add	a3,a3,a5
ffffffffc0204e96:	0adbb023          	sd	a3,160(s7)
    *(proc->tf) = *tf;
ffffffffc0204e9a:	87b6                	mv	a5,a3
ffffffffc0204e9c:	12040813          	addi	a6,s0,288
ffffffffc0204ea0:	6008                	ld	a0,0(s0)
ffffffffc0204ea2:	640c                	ld	a1,8(s0)
ffffffffc0204ea4:	6810                	ld	a2,16(s0)
ffffffffc0204ea6:	6c18                	ld	a4,24(s0)
ffffffffc0204ea8:	e388                	sd	a0,0(a5)
ffffffffc0204eaa:	e78c                	sd	a1,8(a5)
ffffffffc0204eac:	eb90                	sd	a2,16(a5)
ffffffffc0204eae:	ef98                	sd	a4,24(a5)
ffffffffc0204eb0:	02040413          	addi	s0,s0,32
ffffffffc0204eb4:	02078793          	addi	a5,a5,32
ffffffffc0204eb8:	ff0414e3          	bne	s0,a6,ffffffffc0204ea0 <do_fork+0xea>
    proc->tf->gpr.a0 = 0;
ffffffffc0204ebc:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204ec0:	12048463          	beqz	s1,ffffffffc0204fe8 <do_fork+0x232>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204ec4:	0009c797          	auipc	a5,0x9c
ffffffffc0204ec8:	2ac78793          	addi	a5,a5,684 # ffffffffc02a1170 <last_pid.1691>
ffffffffc0204ecc:	439c                	lw	a5,0(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204ece:	ea84                	sd	s1,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204ed0:	00000717          	auipc	a4,0x0
ffffffffc0204ed4:	c5870713          	addi	a4,a4,-936 # ffffffffc0204b28 <forkret>
    if (++ last_pid >= MAX_PID) {
ffffffffc0204ed8:	0017851b          	addiw	a0,a5,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204edc:	02ebb823          	sd	a4,48(s7)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204ee0:	02dbbc23          	sd	a3,56(s7)
    if (++ last_pid >= MAX_PID) {
ffffffffc0204ee4:	0009c717          	auipc	a4,0x9c
ffffffffc0204ee8:	28a72623          	sw	a0,652(a4) # ffffffffc02a1170 <last_pid.1691>
ffffffffc0204eec:	6789                	lui	a5,0x2
ffffffffc0204eee:	18f55763          	ble	a5,a0,ffffffffc020507c <do_fork+0x2c6>
    if (last_pid >= next_safe) {
ffffffffc0204ef2:	0009c797          	auipc	a5,0x9c
ffffffffc0204ef6:	28278793          	addi	a5,a5,642 # ffffffffc02a1174 <next_safe.1690>
ffffffffc0204efa:	439c                	lw	a5,0(a5)
ffffffffc0204efc:	000a7417          	auipc	s0,0xa7
ffffffffc0204f00:	7f440413          	addi	s0,s0,2036 # ffffffffc02ac6f0 <proc_list>
ffffffffc0204f04:	06f54063          	blt	a0,a5,ffffffffc0204f64 <do_fork+0x1ae>
        next_safe = MAX_PID;
ffffffffc0204f08:	6789                	lui	a5,0x2
ffffffffc0204f0a:	0009c717          	auipc	a4,0x9c
ffffffffc0204f0e:	26f72523          	sw	a5,618(a4) # ffffffffc02a1174 <next_safe.1690>
ffffffffc0204f12:	4581                	li	a1,0
ffffffffc0204f14:	87aa                	mv	a5,a0
ffffffffc0204f16:	000a7417          	auipc	s0,0xa7
ffffffffc0204f1a:	7da40413          	addi	s0,s0,2010 # ffffffffc02ac6f0 <proc_list>
    repeat:
ffffffffc0204f1e:	6889                	lui	a7,0x2
ffffffffc0204f20:	882e                	mv	a6,a1
ffffffffc0204f22:	6609                	lui	a2,0x2
        le = list;
ffffffffc0204f24:	000a7697          	auipc	a3,0xa7
ffffffffc0204f28:	7cc68693          	addi	a3,a3,1996 # ffffffffc02ac6f0 <proc_list>
ffffffffc0204f2c:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0204f2e:	00868f63          	beq	a3,s0,ffffffffc0204f4c <do_fork+0x196>
            if (proc->pid == last_pid) {
ffffffffc0204f32:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0204f36:	0ae78463          	beq	a5,a4,ffffffffc0204fde <do_fork+0x228>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0204f3a:	fee7d9e3          	ble	a4,a5,ffffffffc0204f2c <do_fork+0x176>
ffffffffc0204f3e:	fec757e3          	ble	a2,a4,ffffffffc0204f2c <do_fork+0x176>
ffffffffc0204f42:	6694                	ld	a3,8(a3)
ffffffffc0204f44:	863a                	mv	a2,a4
ffffffffc0204f46:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0204f48:	fe8695e3          	bne	a3,s0,ffffffffc0204f32 <do_fork+0x17c>
ffffffffc0204f4c:	c591                	beqz	a1,ffffffffc0204f58 <do_fork+0x1a2>
ffffffffc0204f4e:	0009c717          	auipc	a4,0x9c
ffffffffc0204f52:	22f72123          	sw	a5,546(a4) # ffffffffc02a1170 <last_pid.1691>
ffffffffc0204f56:	853e                	mv	a0,a5
ffffffffc0204f58:	00080663          	beqz	a6,ffffffffc0204f64 <do_fork+0x1ae>
ffffffffc0204f5c:	0009c797          	auipc	a5,0x9c
ffffffffc0204f60:	20c7ac23          	sw	a2,536(a5) # ffffffffc02a1174 <next_safe.1690>
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f64:	45a9                	li	a1,10
    proc->pid = get_pid();
ffffffffc0204f66:	00aba223          	sw	a0,4(s7)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204f6a:	2501                	sext.w	a0,a0
ffffffffc0204f6c:	75f000ef          	jal	ra,ffffffffc0205eca <hash32>
ffffffffc0204f70:	1502                	slli	a0,a0,0x20
ffffffffc0204f72:	000a3797          	auipc	a5,0xa3
ffffffffc0204f76:	60678793          	addi	a5,a5,1542 # ffffffffc02a8578 <hash_list>
ffffffffc0204f7a:	8171                	srli	a0,a0,0x1c
ffffffffc0204f7c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204f7e:	6518                	ld	a4,8(a0)
ffffffffc0204f80:	0d8b8793          	addi	a5,s7,216
ffffffffc0204f84:	6414                	ld	a3,8(s0)
    prev->next = next->prev = elm;
ffffffffc0204f86:	e31c                	sd	a5,0(a4)
ffffffffc0204f88:	e51c                	sd	a5,8(a0)
    nr_process ++;
ffffffffc0204f8a:	0009a783          	lw	a5,0(s3)
    elm->next = next;
ffffffffc0204f8e:	0eebb023          	sd	a4,224(s7)
    elm->prev = prev;
ffffffffc0204f92:	0cabbc23          	sd	a0,216(s7)
    list_add(&proc_list, &(proc->list_link));  // 插入proc_list
ffffffffc0204f96:	0c8b8713          	addi	a4,s7,200
    prev->next = next->prev = elm;
ffffffffc0204f9a:	e298                	sd	a4,0(a3)
    nr_process ++;
ffffffffc0204f9c:	2785                	addiw	a5,a5,1
    elm->next = next;
ffffffffc0204f9e:	0cdbb823          	sd	a3,208(s7)
    wakeup_proc(proc);  // 设置为RUNNABLE
ffffffffc0204fa2:	855e                	mv	a0,s7
    elm->prev = prev;
ffffffffc0204fa4:	0c8bb423          	sd	s0,200(s7)
    prev->next = next->prev = elm;
ffffffffc0204fa8:	000a7697          	auipc	a3,0xa7
ffffffffc0204fac:	74e6b823          	sd	a4,1872(a3) # ffffffffc02ac6f8 <proc_list+0x8>
    nr_process ++;
ffffffffc0204fb0:	000a7717          	auipc	a4,0xa7
ffffffffc0204fb4:	60f72c23          	sw	a5,1560(a4) # ffffffffc02ac5c8 <nr_process>
    wakeup_proc(proc);  // 设置为RUNNABLE
ffffffffc0204fb8:	521000ef          	jal	ra,ffffffffc0205cd8 <wakeup_proc>
    ret = proc->pid;
ffffffffc0204fbc:	004ba503          	lw	a0,4(s7)
}
ffffffffc0204fc0:	70a6                	ld	ra,104(sp)
ffffffffc0204fc2:	7406                	ld	s0,96(sp)
ffffffffc0204fc4:	64e6                	ld	s1,88(sp)
ffffffffc0204fc6:	6946                	ld	s2,80(sp)
ffffffffc0204fc8:	69a6                	ld	s3,72(sp)
ffffffffc0204fca:	6a06                	ld	s4,64(sp)
ffffffffc0204fcc:	7ae2                	ld	s5,56(sp)
ffffffffc0204fce:	7b42                	ld	s6,48(sp)
ffffffffc0204fd0:	7ba2                	ld	s7,40(sp)
ffffffffc0204fd2:	7c02                	ld	s8,32(sp)
ffffffffc0204fd4:	6ce2                	ld	s9,24(sp)
ffffffffc0204fd6:	6d42                	ld	s10,16(sp)
ffffffffc0204fd8:	6da2                	ld	s11,8(sp)
ffffffffc0204fda:	6165                	addi	sp,sp,112
ffffffffc0204fdc:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc0204fde:	2785                	addiw	a5,a5,1
ffffffffc0204fe0:	0ac7d563          	ble	a2,a5,ffffffffc020508a <do_fork+0x2d4>
ffffffffc0204fe4:	4585                	li	a1,1
ffffffffc0204fe6:	b799                	j	ffffffffc0204f2c <do_fork+0x176>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204fe8:	84b6                	mv	s1,a3
ffffffffc0204fea:	bde9                	j	ffffffffc0204ec4 <do_fork+0x10e>
    if ((mm = mm_create()) == NULL) {
ffffffffc0204fec:	82cff0ef          	jal	ra,ffffffffc0204018 <mm_create>
ffffffffc0204ff0:	8d2a                	mv	s10,a0
ffffffffc0204ff2:	c539                	beqz	a0,ffffffffc0205040 <do_fork+0x28a>
    if (setup_pgdir(mm) != 0) {
ffffffffc0204ff4:	c45ff0ef          	jal	ra,ffffffffc0204c38 <setup_pgdir>
ffffffffc0204ff8:	ed51                	bnez	a0,ffffffffc0205094 <do_fork+0x2de>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0204ffa:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204ffe:	4785                	li	a5,1
ffffffffc0205000:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc0205004:	8b85                	andi	a5,a5,1
ffffffffc0205006:	4905                	li	s2,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205008:	c799                	beqz	a5,ffffffffc0205016 <do_fork+0x260>
        schedule();
ffffffffc020500a:	54b000ef          	jal	ra,ffffffffc0205d54 <schedule>
ffffffffc020500e:	412db7af          	amoor.d	a5,s2,(s11)
ffffffffc0205012:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc0205014:	fbfd                	bnez	a5,ffffffffc020500a <do_fork+0x254>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205016:	85e2                	mv	a1,s8
ffffffffc0205018:	856a                	mv	a0,s10
ffffffffc020501a:	a88ff0ef          	jal	ra,ffffffffc02042a2 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020501e:	57f9                	li	a5,-2
ffffffffc0205020:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc0205024:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205026:	c7d5                	beqz	a5,ffffffffc02050d2 <do_fork+0x31c>
    if (ret != 0) {
ffffffffc0205028:	8c6a                	mv	s8,s10
ffffffffc020502a:	e2050ee3          	beqz	a0,ffffffffc0204e66 <do_fork+0xb0>
    exit_mmap(mm);
ffffffffc020502e:	856a                	mv	a0,s10
ffffffffc0205030:	b0eff0ef          	jal	ra,ffffffffc020433e <exit_mmap>
    put_pgdir(mm);
ffffffffc0205034:	856a                	mv	a0,s10
ffffffffc0205036:	b85ff0ef          	jal	ra,ffffffffc0204bba <put_pgdir>
    mm_destroy(mm);
ffffffffc020503a:	856a                	mv	a0,s10
ffffffffc020503c:	962ff0ef          	jal	ra,ffffffffc020419e <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205040:	010bb683          	ld	a3,16(s7)
    return pa2page(PADDR(kva));
ffffffffc0205044:	c02007b7          	lui	a5,0xc0200
ffffffffc0205048:	0af6ed63          	bltu	a3,a5,ffffffffc0205102 <do_fork+0x34c>
ffffffffc020504c:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc0205050:	000b3703          	ld	a4,0(s6)
    return pa2page(PADDR(kva));
ffffffffc0205054:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205058:	83b1                	srli	a5,a5,0xc
ffffffffc020505a:	08e7f863          	bleu	a4,a5,ffffffffc02050ea <do_fork+0x334>
    return &pages[PPN(pa) - nbase];
ffffffffc020505e:	000ab703          	ld	a4,0(s5)
ffffffffc0205062:	000a3503          	ld	a0,0(s4)
ffffffffc0205066:	4589                	li	a1,2
ffffffffc0205068:	8f99                	sub	a5,a5,a4
ffffffffc020506a:	079a                	slli	a5,a5,0x6
ffffffffc020506c:	953e                	add	a0,a0,a5
ffffffffc020506e:	e49fc0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    kfree(proc);
ffffffffc0205072:	855e                	mv	a0,s7
ffffffffc0205074:	c7bfc0ef          	jal	ra,ffffffffc0201cee <kfree>
    ret = -E_NO_MEM;
ffffffffc0205078:	5571                	li	a0,-4
    return ret;
ffffffffc020507a:	b799                	j	ffffffffc0204fc0 <do_fork+0x20a>
        last_pid = 1;
ffffffffc020507c:	4785                	li	a5,1
ffffffffc020507e:	0009c717          	auipc	a4,0x9c
ffffffffc0205082:	0ef72923          	sw	a5,242(a4) # ffffffffc02a1170 <last_pid.1691>
ffffffffc0205086:	4505                	li	a0,1
ffffffffc0205088:	b541                	j	ffffffffc0204f08 <do_fork+0x152>
                    if (last_pid >= MAX_PID) {
ffffffffc020508a:	0117c363          	blt	a5,a7,ffffffffc0205090 <do_fork+0x2da>
                        last_pid = 1;
ffffffffc020508e:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205090:	4585                	li	a1,1
ffffffffc0205092:	b579                	j	ffffffffc0204f20 <do_fork+0x16a>
    mm_destroy(mm);
ffffffffc0205094:	856a                	mv	a0,s10
ffffffffc0205096:	908ff0ef          	jal	ra,ffffffffc020419e <mm_destroy>
ffffffffc020509a:	b75d                	j	ffffffffc0205040 <do_fork+0x28a>
    int ret = -E_NO_FREE_PROC;
ffffffffc020509c:	556d                	li	a0,-5
ffffffffc020509e:	b70d                	j	ffffffffc0204fc0 <do_fork+0x20a>
    return KADDR(page2pa(page));
ffffffffc02050a0:	00002617          	auipc	a2,0x2
ffffffffc02050a4:	09060613          	addi	a2,a2,144 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02050a8:	06900593          	li	a1,105
ffffffffc02050ac:	00002517          	auipc	a0,0x2
ffffffffc02050b0:	0ac50513          	addi	a0,a0,172 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02050b4:	bd0fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02050b8:	86be                	mv	a3,a5
ffffffffc02050ba:	00002617          	auipc	a2,0x2
ffffffffc02050be:	0ae60613          	addi	a2,a2,174 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc02050c2:	15b00593          	li	a1,347
ffffffffc02050c6:	00003517          	auipc	a0,0x3
ffffffffc02050ca:	46a50513          	addi	a0,a0,1130 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc02050ce:	bb6fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("Unlock failed.\n");
ffffffffc02050d2:	00003617          	auipc	a2,0x3
ffffffffc02050d6:	1f660613          	addi	a2,a2,502 # ffffffffc02082c8 <default_pmm_manager+0x11e8>
ffffffffc02050da:	03100593          	li	a1,49
ffffffffc02050de:	00003517          	auipc	a0,0x3
ffffffffc02050e2:	1fa50513          	addi	a0,a0,506 # ffffffffc02082d8 <default_pmm_manager+0x11f8>
ffffffffc02050e6:	b9efb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02050ea:	00002617          	auipc	a2,0x2
ffffffffc02050ee:	0a660613          	addi	a2,a2,166 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc02050f2:	06200593          	li	a1,98
ffffffffc02050f6:	00002517          	auipc	a0,0x2
ffffffffc02050fa:	06250513          	addi	a0,a0,98 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02050fe:	b86fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205102:	00002617          	auipc	a2,0x2
ffffffffc0205106:	06660613          	addi	a2,a2,102 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc020510a:	06e00593          	li	a1,110
ffffffffc020510e:	00002517          	auipc	a0,0x2
ffffffffc0205112:	04a50513          	addi	a0,a0,74 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0205116:	b6efb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020511a <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020511a:	7129                	addi	sp,sp,-320
ffffffffc020511c:	fa22                	sd	s0,304(sp)
ffffffffc020511e:	f626                	sd	s1,296(sp)
ffffffffc0205120:	f24a                	sd	s2,288(sp)
ffffffffc0205122:	84ae                	mv	s1,a1
ffffffffc0205124:	892a                	mv	s2,a0
ffffffffc0205126:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205128:	4581                	li	a1,0
ffffffffc020512a:	12000613          	li	a2,288
ffffffffc020512e:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205130:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205132:	246010ef          	jal	ra,ffffffffc0206378 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205136:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205138:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020513a:	100027f3          	csrr	a5,sstatus
ffffffffc020513e:	edd7f793          	andi	a5,a5,-291
ffffffffc0205142:	1207e793          	ori	a5,a5,288
ffffffffc0205146:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205148:	860a                	mv	a2,sp
ffffffffc020514a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020514e:	00000797          	auipc	a5,0x0
ffffffffc0205152:	9d278793          	addi	a5,a5,-1582 # ffffffffc0204b20 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205156:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205158:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020515a:	c5dff0ef          	jal	ra,ffffffffc0204db6 <do_fork>
}
ffffffffc020515e:	70f2                	ld	ra,312(sp)
ffffffffc0205160:	7452                	ld	s0,304(sp)
ffffffffc0205162:	74b2                	ld	s1,296(sp)
ffffffffc0205164:	7912                	ld	s2,288(sp)
ffffffffc0205166:	6131                	addi	sp,sp,320
ffffffffc0205168:	8082                	ret

ffffffffc020516a <do_exit>:
do_exit(int error_code) {
ffffffffc020516a:	7179                	addi	sp,sp,-48
ffffffffc020516c:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc020516e:	000a7717          	auipc	a4,0xa7
ffffffffc0205172:	44a70713          	addi	a4,a4,1098 # ffffffffc02ac5b8 <idleproc>
ffffffffc0205176:	000a7917          	auipc	s2,0xa7
ffffffffc020517a:	43a90913          	addi	s2,s2,1082 # ffffffffc02ac5b0 <current>
ffffffffc020517e:	00093783          	ld	a5,0(s2)
ffffffffc0205182:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205184:	f406                	sd	ra,40(sp)
ffffffffc0205186:	f022                	sd	s0,32(sp)
ffffffffc0205188:	ec26                	sd	s1,24(sp)
ffffffffc020518a:	e44e                	sd	s3,8(sp)
ffffffffc020518c:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020518e:	0ce78c63          	beq	a5,a4,ffffffffc0205266 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205192:	000a7417          	auipc	s0,0xa7
ffffffffc0205196:	42e40413          	addi	s0,s0,1070 # ffffffffc02ac5c0 <initproc>
ffffffffc020519a:	6018                	ld	a4,0(s0)
ffffffffc020519c:	0ee78b63          	beq	a5,a4,ffffffffc0205292 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc02051a0:	7784                	ld	s1,40(a5)
ffffffffc02051a2:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02051a4:	c48d                	beqz	s1,ffffffffc02051ce <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02051a6:	000a7797          	auipc	a5,0xa7
ffffffffc02051aa:	45a78793          	addi	a5,a5,1114 # ffffffffc02ac600 <boot_cr3>
ffffffffc02051ae:	639c                	ld	a5,0(a5)
ffffffffc02051b0:	577d                	li	a4,-1
ffffffffc02051b2:	177e                	slli	a4,a4,0x3f
ffffffffc02051b4:	83b1                	srli	a5,a5,0xc
ffffffffc02051b6:	8fd9                	or	a5,a5,a4
ffffffffc02051b8:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02051bc:	589c                	lw	a5,48(s1)
ffffffffc02051be:	fff7871b          	addiw	a4,a5,-1
ffffffffc02051c2:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc02051c4:	cf4d                	beqz	a4,ffffffffc020527e <do_exit+0x114>
        current->mm = NULL;
ffffffffc02051c6:	00093783          	ld	a5,0(s2)
ffffffffc02051ca:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02051ce:	00093783          	ld	a5,0(s2)
ffffffffc02051d2:	470d                	li	a4,3
ffffffffc02051d4:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02051d6:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051da:	100027f3          	csrr	a5,sstatus
ffffffffc02051de:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051e0:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051e2:	e7e1                	bnez	a5,ffffffffc02052aa <do_exit+0x140>
        proc = current->parent;
ffffffffc02051e4:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02051e8:	800007b7          	lui	a5,0x80000
ffffffffc02051ec:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02051ee:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02051f0:	0ec52703          	lw	a4,236(a0)
ffffffffc02051f4:	0af70f63          	beq	a4,a5,ffffffffc02052b2 <do_exit+0x148>
ffffffffc02051f8:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02051fc:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205200:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205202:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) { // problem???
ffffffffc0205204:	7afc                	ld	a5,240(a3)
ffffffffc0205206:	cb95                	beqz	a5,ffffffffc020523a <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205208:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5670>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020520c:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020520e:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205210:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205212:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205216:	10e7b023          	sd	a4,256(a5)
ffffffffc020521a:	c311                	beqz	a4,ffffffffc020521e <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc020521c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020521e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205220:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205222:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205224:	fe9710e3          	bne	a4,s1,ffffffffc0205204 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205228:	0ec52783          	lw	a5,236(a0)
ffffffffc020522c:	fd379ce3          	bne	a5,s3,ffffffffc0205204 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205230:	2a9000ef          	jal	ra,ffffffffc0205cd8 <wakeup_proc>
ffffffffc0205234:	00093683          	ld	a3,0(s2)
ffffffffc0205238:	b7f1                	j	ffffffffc0205204 <do_exit+0x9a>
    if (flag) {
ffffffffc020523a:	020a1363          	bnez	s4,ffffffffc0205260 <do_exit+0xf6>
    schedule();
ffffffffc020523e:	317000ef          	jal	ra,ffffffffc0205d54 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205242:	00093783          	ld	a5,0(s2)
ffffffffc0205246:	00003617          	auipc	a2,0x3
ffffffffc020524a:	06260613          	addi	a2,a2,98 # ffffffffc02082a8 <default_pmm_manager+0x11c8>
ffffffffc020524e:	1f800593          	li	a1,504
ffffffffc0205252:	43d4                	lw	a3,4(a5)
ffffffffc0205254:	00003517          	auipc	a0,0x3
ffffffffc0205258:	2dc50513          	addi	a0,a0,732 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc020525c:	a28fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_enable();
ffffffffc0205260:	bd0fb0ef          	jal	ra,ffffffffc0200630 <intr_enable>
ffffffffc0205264:	bfe9                	j	ffffffffc020523e <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205266:	00003617          	auipc	a2,0x3
ffffffffc020526a:	02260613          	addi	a2,a2,34 # ffffffffc0208288 <default_pmm_manager+0x11a8>
ffffffffc020526e:	1cc00593          	li	a1,460
ffffffffc0205272:	00003517          	auipc	a0,0x3
ffffffffc0205276:	2be50513          	addi	a0,a0,702 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc020527a:	a0afb0ef          	jal	ra,ffffffffc0200484 <__panic>
            exit_mmap(mm);
ffffffffc020527e:	8526                	mv	a0,s1
ffffffffc0205280:	8beff0ef          	jal	ra,ffffffffc020433e <exit_mmap>
            put_pgdir(mm);
ffffffffc0205284:	8526                	mv	a0,s1
ffffffffc0205286:	935ff0ef          	jal	ra,ffffffffc0204bba <put_pgdir>
            mm_destroy(mm);
ffffffffc020528a:	8526                	mv	a0,s1
ffffffffc020528c:	f13fe0ef          	jal	ra,ffffffffc020419e <mm_destroy>
ffffffffc0205290:	bf1d                	j	ffffffffc02051c6 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205292:	00003617          	auipc	a2,0x3
ffffffffc0205296:	00660613          	addi	a2,a2,6 # ffffffffc0208298 <default_pmm_manager+0x11b8>
ffffffffc020529a:	1cf00593          	li	a1,463
ffffffffc020529e:	00003517          	auipc	a0,0x3
ffffffffc02052a2:	29250513          	addi	a0,a0,658 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc02052a6:	9defb0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_disable();
ffffffffc02052aa:	b8cfb0ef          	jal	ra,ffffffffc0200636 <intr_disable>
        return 1;
ffffffffc02052ae:	4a05                	li	s4,1
ffffffffc02052b0:	bf15                	j	ffffffffc02051e4 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc02052b2:	227000ef          	jal	ra,ffffffffc0205cd8 <wakeup_proc>
ffffffffc02052b6:	b789                	j	ffffffffc02051f8 <do_exit+0x8e>

ffffffffc02052b8 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc02052b8:	7139                	addi	sp,sp,-64
ffffffffc02052ba:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc02052bc:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02052c0:	f426                	sd	s1,40(sp)
ffffffffc02052c2:	f04a                	sd	s2,32(sp)
ffffffffc02052c4:	ec4e                	sd	s3,24(sp)
ffffffffc02052c6:	e456                	sd	s5,8(sp)
ffffffffc02052c8:	e05a                	sd	s6,0(sp)
ffffffffc02052ca:	fc06                	sd	ra,56(sp)
ffffffffc02052cc:	f822                	sd	s0,48(sp)
ffffffffc02052ce:	89aa                	mv	s3,a0
ffffffffc02052d0:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc02052d2:	000a7917          	auipc	s2,0xa7
ffffffffc02052d6:	2de90913          	addi	s2,s2,734 # ffffffffc02ac5b0 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052da:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02052dc:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02052de:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc02052e0:	02098f63          	beqz	s3,ffffffffc020531e <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02052e4:	854e                	mv	a0,s3
ffffffffc02052e6:	a75ff0ef          	jal	ra,ffffffffc0204d5a <find_proc>
ffffffffc02052ea:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02052ec:	12050063          	beqz	a0,ffffffffc020540c <do_wait.part.1+0x154>
ffffffffc02052f0:	00093703          	ld	a4,0(s2)
ffffffffc02052f4:	711c                	ld	a5,32(a0)
ffffffffc02052f6:	10e79b63          	bne	a5,a4,ffffffffc020540c <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02052fa:	411c                	lw	a5,0(a0)
ffffffffc02052fc:	02978c63          	beq	a5,s1,ffffffffc0205334 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205300:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205304:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205308:	24d000ef          	jal	ra,ffffffffc0205d54 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020530c:	00093783          	ld	a5,0(s2)
ffffffffc0205310:	0b07a783          	lw	a5,176(a5)
ffffffffc0205314:	8b85                	andi	a5,a5,1
ffffffffc0205316:	d7e9                	beqz	a5,ffffffffc02052e0 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205318:	555d                	li	a0,-9
ffffffffc020531a:	e51ff0ef          	jal	ra,ffffffffc020516a <do_exit>
        proc = current->cptr;
ffffffffc020531e:	00093703          	ld	a4,0(s2)
ffffffffc0205322:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205324:	e409                	bnez	s0,ffffffffc020532e <do_wait.part.1+0x76>
ffffffffc0205326:	a0dd                	j	ffffffffc020540c <do_wait.part.1+0x154>
ffffffffc0205328:	10043403          	ld	s0,256(s0)
ffffffffc020532c:	d871                	beqz	s0,ffffffffc0205300 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020532e:	401c                	lw	a5,0(s0)
ffffffffc0205330:	fe979ce3          	bne	a5,s1,ffffffffc0205328 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205334:	000a7797          	auipc	a5,0xa7
ffffffffc0205338:	28478793          	addi	a5,a5,644 # ffffffffc02ac5b8 <idleproc>
ffffffffc020533c:	639c                	ld	a5,0(a5)
ffffffffc020533e:	0c878d63          	beq	a5,s0,ffffffffc0205418 <do_wait.part.1+0x160>
ffffffffc0205342:	000a7797          	auipc	a5,0xa7
ffffffffc0205346:	27e78793          	addi	a5,a5,638 # ffffffffc02ac5c0 <initproc>
ffffffffc020534a:	639c                	ld	a5,0(a5)
ffffffffc020534c:	0cf40663          	beq	s0,a5,ffffffffc0205418 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205350:	000b0663          	beqz	s6,ffffffffc020535c <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205354:	0e842783          	lw	a5,232(s0)
ffffffffc0205358:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020535c:	100027f3          	csrr	a5,sstatus
ffffffffc0205360:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205362:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205364:	e7d5                	bnez	a5,ffffffffc0205410 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205366:	6c70                	ld	a2,216(s0)
ffffffffc0205368:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020536a:	10043703          	ld	a4,256(s0)
ffffffffc020536e:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205370:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205372:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205374:	6470                	ld	a2,200(s0)
ffffffffc0205376:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205378:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020537a:	e290                	sd	a2,0(a3)
ffffffffc020537c:	c319                	beqz	a4,ffffffffc0205382 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc020537e:	ff7c                	sd	a5,248(a4)
ffffffffc0205380:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205382:	c3d1                	beqz	a5,ffffffffc0205406 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205384:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205388:	000a7797          	auipc	a5,0xa7
ffffffffc020538c:	24078793          	addi	a5,a5,576 # ffffffffc02ac5c8 <nr_process>
ffffffffc0205390:	439c                	lw	a5,0(a5)
ffffffffc0205392:	37fd                	addiw	a5,a5,-1
ffffffffc0205394:	000a7717          	auipc	a4,0xa7
ffffffffc0205398:	22f72a23          	sw	a5,564(a4) # ffffffffc02ac5c8 <nr_process>
    if (flag) {
ffffffffc020539c:	e1b5                	bnez	a1,ffffffffc0205400 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020539e:	6814                	ld	a3,16(s0)
ffffffffc02053a0:	c02007b7          	lui	a5,0xc0200
ffffffffc02053a4:	0af6e263          	bltu	a3,a5,ffffffffc0205448 <do_wait.part.1+0x190>
ffffffffc02053a8:	000a7797          	auipc	a5,0xa7
ffffffffc02053ac:	25078793          	addi	a5,a5,592 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc02053b0:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02053b2:	000a7797          	auipc	a5,0xa7
ffffffffc02053b6:	1e678793          	addi	a5,a5,486 # ffffffffc02ac598 <npage>
ffffffffc02053ba:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02053bc:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02053be:	82b1                	srli	a3,a3,0xc
ffffffffc02053c0:	06f6f863          	bleu	a5,a3,ffffffffc0205430 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc02053c4:	00003797          	auipc	a5,0x3
ffffffffc02053c8:	63478793          	addi	a5,a5,1588 # ffffffffc02089f8 <nbase>
ffffffffc02053cc:	639c                	ld	a5,0(a5)
ffffffffc02053ce:	000a7717          	auipc	a4,0xa7
ffffffffc02053d2:	23a70713          	addi	a4,a4,570 # ffffffffc02ac608 <pages>
ffffffffc02053d6:	6308                	ld	a0,0(a4)
ffffffffc02053d8:	8e9d                	sub	a3,a3,a5
ffffffffc02053da:	069a                	slli	a3,a3,0x6
ffffffffc02053dc:	9536                	add	a0,a0,a3
ffffffffc02053de:	4589                	li	a1,2
ffffffffc02053e0:	ad7fc0ef          	jal	ra,ffffffffc0201eb6 <free_pages>
    kfree(proc);
ffffffffc02053e4:	8522                	mv	a0,s0
ffffffffc02053e6:	909fc0ef          	jal	ra,ffffffffc0201cee <kfree>
    return 0;
ffffffffc02053ea:	4501                	li	a0,0
}
ffffffffc02053ec:	70e2                	ld	ra,56(sp)
ffffffffc02053ee:	7442                	ld	s0,48(sp)
ffffffffc02053f0:	74a2                	ld	s1,40(sp)
ffffffffc02053f2:	7902                	ld	s2,32(sp)
ffffffffc02053f4:	69e2                	ld	s3,24(sp)
ffffffffc02053f6:	6a42                	ld	s4,16(sp)
ffffffffc02053f8:	6aa2                	ld	s5,8(sp)
ffffffffc02053fa:	6b02                	ld	s6,0(sp)
ffffffffc02053fc:	6121                	addi	sp,sp,64
ffffffffc02053fe:	8082                	ret
        intr_enable();
ffffffffc0205400:	a30fb0ef          	jal	ra,ffffffffc0200630 <intr_enable>
ffffffffc0205404:	bf69                	j	ffffffffc020539e <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205406:	701c                	ld	a5,32(s0)
ffffffffc0205408:	fbf8                	sd	a4,240(a5)
ffffffffc020540a:	bfbd                	j	ffffffffc0205388 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc020540c:	5579                	li	a0,-2
ffffffffc020540e:	bff9                	j	ffffffffc02053ec <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205410:	a26fb0ef          	jal	ra,ffffffffc0200636 <intr_disable>
        return 1;
ffffffffc0205414:	4585                	li	a1,1
ffffffffc0205416:	bf81                	j	ffffffffc0205366 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205418:	00003617          	auipc	a2,0x3
ffffffffc020541c:	ed860613          	addi	a2,a2,-296 # ffffffffc02082f0 <default_pmm_manager+0x1210>
ffffffffc0205420:	2ef00593          	li	a1,751
ffffffffc0205424:	00003517          	auipc	a0,0x3
ffffffffc0205428:	10c50513          	addi	a0,a0,268 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc020542c:	858fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205430:	00002617          	auipc	a2,0x2
ffffffffc0205434:	d6060613          	addi	a2,a2,-672 # ffffffffc0207190 <default_pmm_manager+0xb0>
ffffffffc0205438:	06200593          	li	a1,98
ffffffffc020543c:	00002517          	auipc	a0,0x2
ffffffffc0205440:	d1c50513          	addi	a0,a0,-740 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc0205444:	840fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205448:	00002617          	auipc	a2,0x2
ffffffffc020544c:	d2060613          	addi	a2,a2,-736 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc0205450:	06e00593          	li	a1,110
ffffffffc0205454:	00002517          	auipc	a0,0x2
ffffffffc0205458:	d0450513          	addi	a0,a0,-764 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc020545c:	828fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205460 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205460:	1141                	addi	sp,sp,-16
ffffffffc0205462:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205464:	a99fc0ef          	jal	ra,ffffffffc0201efc <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205468:	fc6fc0ef          	jal	ra,ffffffffc0201c2e <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020546c:	4601                	li	a2,0
ffffffffc020546e:	4581                	li	a1,0
ffffffffc0205470:	fffff517          	auipc	a0,0xfffff
ffffffffc0205474:	6c850513          	addi	a0,a0,1736 # ffffffffc0204b38 <user_main>
ffffffffc0205478:	ca3ff0ef          	jal	ra,ffffffffc020511a <kernel_thread>
    if (pid <= 0) {
ffffffffc020547c:	00a04563          	bgtz	a0,ffffffffc0205486 <init_main+0x26>
ffffffffc0205480:	a841                	j	ffffffffc0205510 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205482:	0d3000ef          	jal	ra,ffffffffc0205d54 <schedule>
    if (code_store != NULL) {
ffffffffc0205486:	4581                	li	a1,0
ffffffffc0205488:	4501                	li	a0,0
ffffffffc020548a:	e2fff0ef          	jal	ra,ffffffffc02052b8 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc020548e:	d975                	beqz	a0,ffffffffc0205482 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205490:	00003517          	auipc	a0,0x3
ffffffffc0205494:	ea050513          	addi	a0,a0,-352 # ffffffffc0208330 <default_pmm_manager+0x1250>
ffffffffc0205498:	cf7fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020549c:	000a7797          	auipc	a5,0xa7
ffffffffc02054a0:	12478793          	addi	a5,a5,292 # ffffffffc02ac5c0 <initproc>
ffffffffc02054a4:	639c                	ld	a5,0(a5)
ffffffffc02054a6:	7bf8                	ld	a4,240(a5)
ffffffffc02054a8:	e721                	bnez	a4,ffffffffc02054f0 <init_main+0x90>
ffffffffc02054aa:	7ff8                	ld	a4,248(a5)
ffffffffc02054ac:	e331                	bnez	a4,ffffffffc02054f0 <init_main+0x90>
ffffffffc02054ae:	1007b703          	ld	a4,256(a5)
ffffffffc02054b2:	ef1d                	bnez	a4,ffffffffc02054f0 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc02054b4:	000a7717          	auipc	a4,0xa7
ffffffffc02054b8:	11470713          	addi	a4,a4,276 # ffffffffc02ac5c8 <nr_process>
ffffffffc02054bc:	4314                	lw	a3,0(a4)
ffffffffc02054be:	4709                	li	a4,2
ffffffffc02054c0:	0ae69463          	bne	a3,a4,ffffffffc0205568 <init_main+0x108>
    return listelm->next;
ffffffffc02054c4:	000a7697          	auipc	a3,0xa7
ffffffffc02054c8:	22c68693          	addi	a3,a3,556 # ffffffffc02ac6f0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02054cc:	6698                	ld	a4,8(a3)
ffffffffc02054ce:	0c878793          	addi	a5,a5,200
ffffffffc02054d2:	06f71b63          	bne	a4,a5,ffffffffc0205548 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02054d6:	629c                	ld	a5,0(a3)
ffffffffc02054d8:	04f71863          	bne	a4,a5,ffffffffc0205528 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02054dc:	00003517          	auipc	a0,0x3
ffffffffc02054e0:	f3c50513          	addi	a0,a0,-196 # ffffffffc0208418 <default_pmm_manager+0x1338>
ffffffffc02054e4:	cabfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02054e8:	60a2                	ld	ra,8(sp)
ffffffffc02054ea:	4501                	li	a0,0
ffffffffc02054ec:	0141                	addi	sp,sp,16
ffffffffc02054ee:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02054f0:	00003697          	auipc	a3,0x3
ffffffffc02054f4:	e6868693          	addi	a3,a3,-408 # ffffffffc0208358 <default_pmm_manager+0x1278>
ffffffffc02054f8:	00001617          	auipc	a2,0x1
ffffffffc02054fc:	4a060613          	addi	a2,a2,1184 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205500:	35400593          	li	a1,852
ffffffffc0205504:	00003517          	auipc	a0,0x3
ffffffffc0205508:	02c50513          	addi	a0,a0,44 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc020550c:	f79fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205510:	00003617          	auipc	a2,0x3
ffffffffc0205514:	e0060613          	addi	a2,a2,-512 # ffffffffc0208310 <default_pmm_manager+0x1230>
ffffffffc0205518:	34c00593          	li	a1,844
ffffffffc020551c:	00003517          	auipc	a0,0x3
ffffffffc0205520:	01450513          	addi	a0,a0,20 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205524:	f61fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205528:	00003697          	auipc	a3,0x3
ffffffffc020552c:	ec068693          	addi	a3,a3,-320 # ffffffffc02083e8 <default_pmm_manager+0x1308>
ffffffffc0205530:	00001617          	auipc	a2,0x1
ffffffffc0205534:	46860613          	addi	a2,a2,1128 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205538:	35700593          	li	a1,855
ffffffffc020553c:	00003517          	auipc	a0,0x3
ffffffffc0205540:	ff450513          	addi	a0,a0,-12 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205544:	f41fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205548:	00003697          	auipc	a3,0x3
ffffffffc020554c:	e7068693          	addi	a3,a3,-400 # ffffffffc02083b8 <default_pmm_manager+0x12d8>
ffffffffc0205550:	00001617          	auipc	a2,0x1
ffffffffc0205554:	44860613          	addi	a2,a2,1096 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205558:	35600593          	li	a1,854
ffffffffc020555c:	00003517          	auipc	a0,0x3
ffffffffc0205560:	fd450513          	addi	a0,a0,-44 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205564:	f21fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_process == 2);
ffffffffc0205568:	00003697          	auipc	a3,0x3
ffffffffc020556c:	e4068693          	addi	a3,a3,-448 # ffffffffc02083a8 <default_pmm_manager+0x12c8>
ffffffffc0205570:	00001617          	auipc	a2,0x1
ffffffffc0205574:	42860613          	addi	a2,a2,1064 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205578:	35500593          	li	a1,853
ffffffffc020557c:	00003517          	auipc	a0,0x3
ffffffffc0205580:	fb450513          	addi	a0,a0,-76 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205584:	f01fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205588 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205588:	7135                	addi	sp,sp,-160
ffffffffc020558a:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020558c:	000a7a17          	auipc	s4,0xa7
ffffffffc0205590:	024a0a13          	addi	s4,s4,36 # ffffffffc02ac5b0 <current>
ffffffffc0205594:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205598:	e14a                	sd	s2,128(sp)
ffffffffc020559a:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020559c:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055a0:	fcce                	sd	s3,120(sp)
ffffffffc02055a2:	842e                	mv	s0,a1
ffffffffc02055a4:	89aa                	mv	s3,a0
ffffffffc02055a6:	e832                	sd	a2,16(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02055a8:	4681                	li	a3,0
ffffffffc02055aa:	862e                	mv	a2,a1
ffffffffc02055ac:	85aa                	mv	a1,a0
ffffffffc02055ae:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02055b0:	ed06                	sd	ra,152(sp)
ffffffffc02055b2:	e526                	sd	s1,136(sp)
ffffffffc02055b4:	f4d6                	sd	s5,104(sp)
ffffffffc02055b6:	f0da                	sd	s6,96(sp)
ffffffffc02055b8:	ecde                	sd	s7,88(sp)
ffffffffc02055ba:	e8e2                	sd	s8,80(sp)
ffffffffc02055bc:	e4e6                	sd	s9,72(sp)
ffffffffc02055be:	e0ea                	sd	s10,64(sp)
ffffffffc02055c0:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02055c2:	bfaff0ef          	jal	ra,ffffffffc02049bc <user_mem_check>
ffffffffc02055c6:	3e050663          	beqz	a0,ffffffffc02059b2 <do_execve+0x42a>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02055ca:	4641                	li	a2,16
ffffffffc02055cc:	4581                	li	a1,0
ffffffffc02055ce:	1008                	addi	a0,sp,32
ffffffffc02055d0:	5a9000ef          	jal	ra,ffffffffc0206378 <memset>
    memcpy(local_name, name, len);
ffffffffc02055d4:	47bd                	li	a5,15
ffffffffc02055d6:	8622                	mv	a2,s0
ffffffffc02055d8:	0687ee63          	bltu	a5,s0,ffffffffc0205654 <do_execve+0xcc>
ffffffffc02055dc:	85ce                	mv	a1,s3
ffffffffc02055de:	1008                	addi	a0,sp,32
ffffffffc02055e0:	5ab000ef          	jal	ra,ffffffffc020638a <memcpy>
    if (mm != NULL) {
ffffffffc02055e4:	06090f63          	beqz	s2,ffffffffc0205662 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc02055e8:	00002517          	auipc	a0,0x2
ffffffffc02055ec:	28850513          	addi	a0,a0,648 # ffffffffc0207870 <default_pmm_manager+0x790>
ffffffffc02055f0:	bd7fa0ef          	jal	ra,ffffffffc02001c6 <cputs>
        lcr3(boot_cr3);
ffffffffc02055f4:	000a7797          	auipc	a5,0xa7
ffffffffc02055f8:	00c78793          	addi	a5,a5,12 # ffffffffc02ac600 <boot_cr3>
ffffffffc02055fc:	639c                	ld	a5,0(a5)
ffffffffc02055fe:	577d                	li	a4,-1
ffffffffc0205600:	177e                	slli	a4,a4,0x3f
ffffffffc0205602:	83b1                	srli	a5,a5,0xc
ffffffffc0205604:	8fd9                	or	a5,a5,a4
ffffffffc0205606:	18079073          	csrw	satp,a5
ffffffffc020560a:	03092783          	lw	a5,48(s2)
ffffffffc020560e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205612:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205616:	26070f63          	beqz	a4,ffffffffc0205894 <do_execve+0x30c>
        current->mm = NULL;
ffffffffc020561a:	000a3783          	ld	a5,0(s4)
ffffffffc020561e:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205622:	9f7fe0ef          	jal	ra,ffffffffc0204018 <mm_create>
ffffffffc0205626:	892a                	mv	s2,a0
ffffffffc0205628:	c135                	beqz	a0,ffffffffc020568c <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc020562a:	e0eff0ef          	jal	ra,ffffffffc0204c38 <setup_pgdir>
ffffffffc020562e:	e931                	bnez	a0,ffffffffc0205682 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205630:	67c2                	ld	a5,16(sp)
ffffffffc0205632:	4398                	lw	a4,0(a5)
ffffffffc0205634:	464c47b7          	lui	a5,0x464c4
ffffffffc0205638:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aef>
ffffffffc020563c:	04f70a63          	beq	a4,a5,ffffffffc0205690 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205640:	854a                	mv	a0,s2
ffffffffc0205642:	d78ff0ef          	jal	ra,ffffffffc0204bba <put_pgdir>
    mm_destroy(mm);
ffffffffc0205646:	854a                	mv	a0,s2
ffffffffc0205648:	b57fe0ef          	jal	ra,ffffffffc020419e <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020564c:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc020564e:	854e                	mv	a0,s3
ffffffffc0205650:	b1bff0ef          	jal	ra,ffffffffc020516a <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205654:	463d                	li	a2,15
ffffffffc0205656:	85ce                	mv	a1,s3
ffffffffc0205658:	1008                	addi	a0,sp,32
ffffffffc020565a:	531000ef          	jal	ra,ffffffffc020638a <memcpy>
    if (mm != NULL) {
ffffffffc020565e:	f80915e3          	bnez	s2,ffffffffc02055e8 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205662:	000a3783          	ld	a5,0(s4)
ffffffffc0205666:	779c                	ld	a5,40(a5)
ffffffffc0205668:	dfcd                	beqz	a5,ffffffffc0205622 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020566a:	00003617          	auipc	a2,0x3
ffffffffc020566e:	a9660613          	addi	a2,a2,-1386 # ffffffffc0208100 <default_pmm_manager+0x1020>
ffffffffc0205672:	20200593          	li	a1,514
ffffffffc0205676:	00003517          	auipc	a0,0x3
ffffffffc020567a:	eba50513          	addi	a0,a0,-326 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc020567e:	e07fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    mm_destroy(mm);
ffffffffc0205682:	854a                	mv	a0,s2
ffffffffc0205684:	b1bfe0ef          	jal	ra,ffffffffc020419e <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205688:	59f1                	li	s3,-4
ffffffffc020568a:	b7d1                	j	ffffffffc020564e <do_execve+0xc6>
ffffffffc020568c:	59f1                	li	s3,-4
ffffffffc020568e:	b7c1                	j	ffffffffc020564e <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205690:	66c2                	ld	a3,16(sp)
ffffffffc0205692:	0386d703          	lhu	a4,56(a3)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205696:	7280                	ld	s0,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205698:	00371793          	slli	a5,a4,0x3
ffffffffc020569c:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020569e:	9436                	add	s0,s0,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02056a0:	078e                	slli	a5,a5,0x3
ffffffffc02056a2:	97a2                	add	a5,a5,s0
ffffffffc02056a4:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02056a6:	02f47b63          	bleu	a5,s0,ffffffffc02056dc <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc02056aa:	5b7d                	li	s6,-1
ffffffffc02056ac:	00cb5793          	srli	a5,s6,0xc
    return page - pages + nbase;
ffffffffc02056b0:	000a7d97          	auipc	s11,0xa7
ffffffffc02056b4:	f58d8d93          	addi	s11,s11,-168 # ffffffffc02ac608 <pages>
ffffffffc02056b8:	00003d17          	auipc	s10,0x3
ffffffffc02056bc:	340d0d13          	addi	s10,s10,832 # ffffffffc02089f8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02056c0:	e03e                	sd	a5,0(sp)
ffffffffc02056c2:	000a7c97          	auipc	s9,0xa7
ffffffffc02056c6:	ed6c8c93          	addi	s9,s9,-298 # ffffffffc02ac598 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02056ca:	4018                	lw	a4,0(s0)
ffffffffc02056cc:	4785                	li	a5,1
ffffffffc02056ce:	0ef70463          	beq	a4,a5,ffffffffc02057b6 <do_execve+0x22e>
    for (; ph < ph_end; ph ++) {
ffffffffc02056d2:	67e2                	ld	a5,24(sp)
ffffffffc02056d4:	03840413          	addi	s0,s0,56
ffffffffc02056d8:	fef469e3          	bltu	s0,a5,ffffffffc02056ca <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc02056dc:	4701                	li	a4,0
ffffffffc02056de:	46ad                	li	a3,11
ffffffffc02056e0:	00100637          	lui	a2,0x100
ffffffffc02056e4:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02056e8:	854a                	mv	a0,s2
ffffffffc02056ea:	b07fe0ef          	jal	ra,ffffffffc02041f0 <mm_map>
ffffffffc02056ee:	89aa                	mv	s3,a0
ffffffffc02056f0:	18051863          	bnez	a0,ffffffffc0205880 <do_execve+0x2f8>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc02056f4:	01893503          	ld	a0,24(s2)
ffffffffc02056f8:	467d                	li	a2,31
ffffffffc02056fa:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02056fe:	bc7fd0ef          	jal	ra,ffffffffc02032c4 <pgdir_alloc_page>
ffffffffc0205702:	34050463          	beqz	a0,ffffffffc0205a4a <do_execve+0x4c2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205706:	01893503          	ld	a0,24(s2)
ffffffffc020570a:	467d                	li	a2,31
ffffffffc020570c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205710:	bb5fd0ef          	jal	ra,ffffffffc02032c4 <pgdir_alloc_page>
ffffffffc0205714:	30050b63          	beqz	a0,ffffffffc0205a2a <do_execve+0x4a2>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205718:	01893503          	ld	a0,24(s2)
ffffffffc020571c:	467d                	li	a2,31
ffffffffc020571e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205722:	ba3fd0ef          	jal	ra,ffffffffc02032c4 <pgdir_alloc_page>
ffffffffc0205726:	2e050263          	beqz	a0,ffffffffc0205a0a <do_execve+0x482>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020572a:	01893503          	ld	a0,24(s2)
ffffffffc020572e:	467d                	li	a2,31
ffffffffc0205730:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205734:	b91fd0ef          	jal	ra,ffffffffc02032c4 <pgdir_alloc_page>
ffffffffc0205738:	2a050963          	beqz	a0,ffffffffc02059ea <do_execve+0x462>
    mm->mm_count += 1;
ffffffffc020573c:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205740:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205744:	01893683          	ld	a3,24(s2)
ffffffffc0205748:	2785                	addiw	a5,a5,1
ffffffffc020574a:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc020574e:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5598>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205752:	c02007b7          	lui	a5,0xc0200
ffffffffc0205756:	26f6ee63          	bltu	a3,a5,ffffffffc02059d2 <do_execve+0x44a>
ffffffffc020575a:	000a7797          	auipc	a5,0xa7
ffffffffc020575e:	e9e78793          	addi	a5,a5,-354 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0205762:	639c                	ld	a5,0(a5)
ffffffffc0205764:	577d                	li	a4,-1
ffffffffc0205766:	177e                	slli	a4,a4,0x3f
ffffffffc0205768:	8e9d                	sub	a3,a3,a5
ffffffffc020576a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020576e:	f654                	sd	a3,168(a2)
ffffffffc0205770:	8fd9                	or	a5,a5,a4
ffffffffc0205772:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205776:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205778:	4581                	li	a1,0
ffffffffc020577a:	12000613          	li	a2,288
ffffffffc020577e:	8522                	mv	a0,s0
ffffffffc0205780:	3f9000ef          	jal	ra,ffffffffc0206378 <memset>
    set_proc_name(current, local_name);
ffffffffc0205784:	000a3503          	ld	a0,0(s4)
    tf->status =  SSTATUS_SPIE;
ffffffffc0205788:	02000793          	li	a5,32
ffffffffc020578c:	10f43023          	sd	a5,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205790:	100c                	addi	a1,sp,32
ffffffffc0205792:	d32ff0ef          	jal	ra,ffffffffc0204cc4 <set_proc_name>
}
ffffffffc0205796:	60ea                	ld	ra,152(sp)
ffffffffc0205798:	644a                	ld	s0,144(sp)
ffffffffc020579a:	854e                	mv	a0,s3
ffffffffc020579c:	64aa                	ld	s1,136(sp)
ffffffffc020579e:	690a                	ld	s2,128(sp)
ffffffffc02057a0:	79e6                	ld	s3,120(sp)
ffffffffc02057a2:	7a46                	ld	s4,112(sp)
ffffffffc02057a4:	7aa6                	ld	s5,104(sp)
ffffffffc02057a6:	7b06                	ld	s6,96(sp)
ffffffffc02057a8:	6be6                	ld	s7,88(sp)
ffffffffc02057aa:	6c46                	ld	s8,80(sp)
ffffffffc02057ac:	6ca6                	ld	s9,72(sp)
ffffffffc02057ae:	6d06                	ld	s10,64(sp)
ffffffffc02057b0:	7de2                	ld	s11,56(sp)
ffffffffc02057b2:	610d                	addi	sp,sp,160
ffffffffc02057b4:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02057b6:	7410                	ld	a2,40(s0)
ffffffffc02057b8:	701c                	ld	a5,32(s0)
ffffffffc02057ba:	1ef66e63          	bltu	a2,a5,ffffffffc02059b6 <do_execve+0x42e>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02057be:	405c                	lw	a5,4(s0)
ffffffffc02057c0:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02057c4:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc02057c8:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02057ca:	0c071f63          	bnez	a4,ffffffffc02058a8 <do_execve+0x320>
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02057ce:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;     // vm_flags表示的是vma结构中的权限，perm是page的权限
ffffffffc02057d0:	4bc5                	li	s7,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02057d2:	c781                	beqz	a5,ffffffffc02057da <do_execve+0x252>
ffffffffc02057d4:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc02057d8:	4bcd                	li	s7,19
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02057da:	0026f793          	andi	a5,a3,2
ffffffffc02057de:	ebf1                	bnez	a5,ffffffffc02058b2 <do_execve+0x32a>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc02057e0:	0046f793          	andi	a5,a3,4
ffffffffc02057e4:	c399                	beqz	a5,ffffffffc02057ea <do_execve+0x262>
ffffffffc02057e6:	008beb93          	ori	s7,s7,8
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc02057ea:	680c                	ld	a1,16(s0)
ffffffffc02057ec:	4701                	li	a4,0
ffffffffc02057ee:	854a                	mv	a0,s2
ffffffffc02057f0:	a01fe0ef          	jal	ra,ffffffffc02041f0 <mm_map>
ffffffffc02057f4:	89aa                	mv	s3,a0
ffffffffc02057f6:	e549                	bnez	a0,ffffffffc0205880 <do_execve+0x2f8>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02057f8:	01043b03          	ld	s6,16(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc02057fc:	67c2                	ld	a5,16(sp)
        end = ph->p_va + ph->p_filesz;
ffffffffc02057fe:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205802:	00843a83          	ld	s5,8(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205806:	99da                	add	s3,s3,s6
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205808:	9abe                	add	s5,s5,a5
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020580a:	77fd                	lui	a5,0xfffff
ffffffffc020580c:	00fb7c33          	and	s8,s6,a5
        while (start < end) {
ffffffffc0205810:	053b6f63          	bltu	s6,s3,ffffffffc020586e <do_execve+0x2e6>
ffffffffc0205814:	aa69                	j	ffffffffc02059ae <do_execve+0x426>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205816:	6785                	lui	a5,0x1
ffffffffc0205818:	418b0533          	sub	a0,s6,s8
ffffffffc020581c:	9c3e                	add	s8,s8,a5
ffffffffc020581e:	416c0833          	sub	a6,s8,s6
            if (end < la) {
ffffffffc0205822:	0189f463          	bleu	s8,s3,ffffffffc020582a <do_execve+0x2a2>
                size -= la - end;   // 减去end以上page尾部以下的
ffffffffc0205826:	41698833          	sub	a6,s3,s6
    return page - pages + nbase;
ffffffffc020582a:	000db683          	ld	a3,0(s11)
ffffffffc020582e:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205832:	6782                	ld	a5,0(sp)
    return page - pages + nbase;
ffffffffc0205834:	40d486b3          	sub	a3,s1,a3
ffffffffc0205838:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020583a:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc020583e:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205840:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205844:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205846:	16c5fa63          	bleu	a2,a1,ffffffffc02059ba <do_execve+0x432>
ffffffffc020584a:	000a7797          	auipc	a5,0xa7
ffffffffc020584e:	dae78793          	addi	a5,a5,-594 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc0205852:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205856:	85d6                	mv	a1,s5
ffffffffc0205858:	8642                	mv	a2,a6
ffffffffc020585a:	96c6                	add	a3,a3,a7
ffffffffc020585c:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc020585e:	9b42                	add	s6,s6,a6
ffffffffc0205860:	e442                	sd	a6,8(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205862:	329000ef          	jal	ra,ffffffffc020638a <memcpy>
            start += size, from += size;
ffffffffc0205866:	6822                	ld	a6,8(sp)
ffffffffc0205868:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc020586a:	053b7663          	bleu	s3,s6,ffffffffc02058b6 <do_execve+0x32e>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc020586e:	01893503          	ld	a0,24(s2)
ffffffffc0205872:	865e                	mv	a2,s7
ffffffffc0205874:	85e2                	mv	a1,s8
ffffffffc0205876:	a4ffd0ef          	jal	ra,ffffffffc02032c4 <pgdir_alloc_page>
ffffffffc020587a:	84aa                	mv	s1,a0
ffffffffc020587c:	fd49                	bnez	a0,ffffffffc0205816 <do_execve+0x28e>
        ret = -E_NO_MEM;
ffffffffc020587e:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205880:	854a                	mv	a0,s2
ffffffffc0205882:	abdfe0ef          	jal	ra,ffffffffc020433e <exit_mmap>
    put_pgdir(mm);
ffffffffc0205886:	854a                	mv	a0,s2
ffffffffc0205888:	b32ff0ef          	jal	ra,ffffffffc0204bba <put_pgdir>
    mm_destroy(mm);
ffffffffc020588c:	854a                	mv	a0,s2
ffffffffc020588e:	911fe0ef          	jal	ra,ffffffffc020419e <mm_destroy>
    return ret;
ffffffffc0205892:	bb75                	j	ffffffffc020564e <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205894:	854a                	mv	a0,s2
ffffffffc0205896:	aa9fe0ef          	jal	ra,ffffffffc020433e <exit_mmap>
            put_pgdir(mm);
ffffffffc020589a:	854a                	mv	a0,s2
ffffffffc020589c:	b1eff0ef          	jal	ra,ffffffffc0204bba <put_pgdir>
            mm_destroy(mm);
ffffffffc02058a0:	854a                	mv	a0,s2
ffffffffc02058a2:	8fdfe0ef          	jal	ra,ffffffffc020419e <mm_destroy>
ffffffffc02058a6:	bb95                	j	ffffffffc020561a <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02058a8:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02058ac:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc02058ae:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc02058b0:	f395                	bnez	a5,ffffffffc02057d4 <do_execve+0x24c>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc02058b2:	4bdd                	li	s7,23
ffffffffc02058b4:	b735                	j	ffffffffc02057e0 <do_execve+0x258>
ffffffffc02058b6:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc02058ba:	7414                	ld	a3,40(s0)
ffffffffc02058bc:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc02058be:	098b7163          	bleu	s8,s6,ffffffffc0205940 <do_execve+0x3b8>
            if (start == end) {
ffffffffc02058c2:	e16988e3          	beq	s3,s6,ffffffffc02056d2 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02058c6:	6505                	lui	a0,0x1
ffffffffc02058c8:	955a                	add	a0,a0,s6
ffffffffc02058ca:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc02058ce:	41698ab3          	sub	s5,s3,s6
            if (end < la) {
ffffffffc02058d2:	0d89fb63          	bleu	s8,s3,ffffffffc02059a8 <do_execve+0x420>
    return page - pages + nbase;
ffffffffc02058d6:	000db683          	ld	a3,0(s11)
ffffffffc02058da:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc02058de:	6782                	ld	a5,0(sp)
    return page - pages + nbase;
ffffffffc02058e0:	40d486b3          	sub	a3,s1,a3
ffffffffc02058e4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02058e6:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02058ea:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc02058ec:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02058f0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02058f2:	0cc5f463          	bleu	a2,a1,ffffffffc02059ba <do_execve+0x432>
ffffffffc02058f6:	000a7617          	auipc	a2,0xa7
ffffffffc02058fa:	d0260613          	addi	a2,a2,-766 # ffffffffc02ac5f8 <va_pa_offset>
ffffffffc02058fe:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205902:	4581                	li	a1,0
ffffffffc0205904:	8656                	mv	a2,s5
ffffffffc0205906:	96c2                	add	a3,a3,a6
ffffffffc0205908:	9536                	add	a0,a0,a3
ffffffffc020590a:	26f000ef          	jal	ra,ffffffffc0206378 <memset>
            start += size;
ffffffffc020590e:	016a8733          	add	a4,s5,s6
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205912:	0389f463          	bleu	s8,s3,ffffffffc020593a <do_execve+0x3b2>
ffffffffc0205916:	dae98ee3          	beq	s3,a4,ffffffffc02056d2 <do_execve+0x14a>
ffffffffc020591a:	00003697          	auipc	a3,0x3
ffffffffc020591e:	80e68693          	addi	a3,a3,-2034 # ffffffffc0208128 <default_pmm_manager+0x1048>
ffffffffc0205922:	00001617          	auipc	a2,0x1
ffffffffc0205926:	07660613          	addi	a2,a2,118 # ffffffffc0206998 <commands+0x4c0>
ffffffffc020592a:	25700593          	li	a1,599
ffffffffc020592e:	00003517          	auipc	a0,0x3
ffffffffc0205932:	c0250513          	addi	a0,a0,-1022 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205936:	b4ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc020593a:	ff8710e3          	bne	a4,s8,ffffffffc020591a <do_execve+0x392>
ffffffffc020593e:	8b62                	mv	s6,s8
ffffffffc0205940:	000a7a97          	auipc	s5,0xa7
ffffffffc0205944:	cb8a8a93          	addi	s5,s5,-840 # ffffffffc02ac5f8 <va_pa_offset>
        while (start < end) {
ffffffffc0205948:	053b6763          	bltu	s6,s3,ffffffffc0205996 <do_execve+0x40e>
ffffffffc020594c:	b359                	j	ffffffffc02056d2 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc020594e:	6785                	lui	a5,0x1
ffffffffc0205950:	418b0533          	sub	a0,s6,s8
ffffffffc0205954:	9c3e                	add	s8,s8,a5
ffffffffc0205956:	416c0633          	sub	a2,s8,s6
            if (end < la) {
ffffffffc020595a:	0189f463          	bleu	s8,s3,ffffffffc0205962 <do_execve+0x3da>
                size -= la - end;
ffffffffc020595e:	41698633          	sub	a2,s3,s6
    return page - pages + nbase;
ffffffffc0205962:	000db683          	ld	a3,0(s11)
ffffffffc0205966:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc020596a:	6782                	ld	a5,0(sp)
    return page - pages + nbase;
ffffffffc020596c:	40d486b3          	sub	a3,s1,a3
ffffffffc0205970:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205972:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205976:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205978:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020597c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020597e:	02b87e63          	bleu	a1,a6,ffffffffc02059ba <do_execve+0x432>
ffffffffc0205982:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205986:	9b32                	add	s6,s6,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205988:	4581                	li	a1,0
ffffffffc020598a:	96c2                	add	a3,a3,a6
ffffffffc020598c:	9536                	add	a0,a0,a3
ffffffffc020598e:	1eb000ef          	jal	ra,ffffffffc0206378 <memset>
        while (start < end) {
ffffffffc0205992:	d53b70e3          	bleu	s3,s6,ffffffffc02056d2 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205996:	01893503          	ld	a0,24(s2)
ffffffffc020599a:	865e                	mv	a2,s7
ffffffffc020599c:	85e2                	mv	a1,s8
ffffffffc020599e:	927fd0ef          	jal	ra,ffffffffc02032c4 <pgdir_alloc_page>
ffffffffc02059a2:	84aa                	mv	s1,a0
ffffffffc02059a4:	f54d                	bnez	a0,ffffffffc020594e <do_execve+0x3c6>
ffffffffc02059a6:	bde1                	j	ffffffffc020587e <do_execve+0x2f6>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02059a8:	416c0ab3          	sub	s5,s8,s6
ffffffffc02059ac:	b72d                	j	ffffffffc02058d6 <do_execve+0x34e>
        while (start < end) {
ffffffffc02059ae:	89da                	mv	s3,s6
ffffffffc02059b0:	b729                	j	ffffffffc02058ba <do_execve+0x332>
        return -E_INVAL;
ffffffffc02059b2:	59f5                	li	s3,-3
ffffffffc02059b4:	b3cd                	j	ffffffffc0205796 <do_execve+0x20e>
            ret = -E_INVAL_ELF;
ffffffffc02059b6:	59e1                	li	s3,-8
ffffffffc02059b8:	b5e1                	j	ffffffffc0205880 <do_execve+0x2f8>
ffffffffc02059ba:	00001617          	auipc	a2,0x1
ffffffffc02059be:	77660613          	addi	a2,a2,1910 # ffffffffc0207130 <default_pmm_manager+0x50>
ffffffffc02059c2:	06900593          	li	a1,105
ffffffffc02059c6:	00001517          	auipc	a0,0x1
ffffffffc02059ca:	79250513          	addi	a0,a0,1938 # ffffffffc0207158 <default_pmm_manager+0x78>
ffffffffc02059ce:	ab7fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059d2:	00001617          	auipc	a2,0x1
ffffffffc02059d6:	79660613          	addi	a2,a2,1942 # ffffffffc0207168 <default_pmm_manager+0x88>
ffffffffc02059da:	27200593          	li	a1,626
ffffffffc02059de:	00003517          	auipc	a0,0x3
ffffffffc02059e2:	b5250513          	addi	a0,a0,-1198 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc02059e6:	a9ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059ea:	00003697          	auipc	a3,0x3
ffffffffc02059ee:	85668693          	addi	a3,a3,-1962 # ffffffffc0208240 <default_pmm_manager+0x1160>
ffffffffc02059f2:	00001617          	auipc	a2,0x1
ffffffffc02059f6:	fa660613          	addi	a2,a2,-90 # ffffffffc0206998 <commands+0x4c0>
ffffffffc02059fa:	26d00593          	li	a1,621
ffffffffc02059fe:	00003517          	auipc	a0,0x3
ffffffffc0205a02:	b3250513          	addi	a0,a0,-1230 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205a06:	a7ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a0a:	00002697          	auipc	a3,0x2
ffffffffc0205a0e:	7ee68693          	addi	a3,a3,2030 # ffffffffc02081f8 <default_pmm_manager+0x1118>
ffffffffc0205a12:	00001617          	auipc	a2,0x1
ffffffffc0205a16:	f8660613          	addi	a2,a2,-122 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205a1a:	26c00593          	li	a1,620
ffffffffc0205a1e:	00003517          	auipc	a0,0x3
ffffffffc0205a22:	b1250513          	addi	a0,a0,-1262 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205a26:	a5ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205a2a:	00002697          	auipc	a3,0x2
ffffffffc0205a2e:	78668693          	addi	a3,a3,1926 # ffffffffc02081b0 <default_pmm_manager+0x10d0>
ffffffffc0205a32:	00001617          	auipc	a2,0x1
ffffffffc0205a36:	f6660613          	addi	a2,a2,-154 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205a3a:	26b00593          	li	a1,619
ffffffffc0205a3e:	00003517          	auipc	a0,0x3
ffffffffc0205a42:	af250513          	addi	a0,a0,-1294 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205a46:	a3ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205a4a:	00002697          	auipc	a3,0x2
ffffffffc0205a4e:	71e68693          	addi	a3,a3,1822 # ffffffffc0208168 <default_pmm_manager+0x1088>
ffffffffc0205a52:	00001617          	auipc	a2,0x1
ffffffffc0205a56:	f4660613          	addi	a2,a2,-186 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205a5a:	26a00593          	li	a1,618
ffffffffc0205a5e:	00003517          	auipc	a0,0x3
ffffffffc0205a62:	ad250513          	addi	a0,a0,-1326 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205a66:	a1ffa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205a6a <do_yield>:
    current->need_resched = 1;
ffffffffc0205a6a:	000a7797          	auipc	a5,0xa7
ffffffffc0205a6e:	b4678793          	addi	a5,a5,-1210 # ffffffffc02ac5b0 <current>
ffffffffc0205a72:	639c                	ld	a5,0(a5)
ffffffffc0205a74:	4705                	li	a4,1
}
ffffffffc0205a76:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205a78:	ef98                	sd	a4,24(a5)
}
ffffffffc0205a7a:	8082                	ret

ffffffffc0205a7c <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205a7c:	1101                	addi	sp,sp,-32
ffffffffc0205a7e:	e822                	sd	s0,16(sp)
ffffffffc0205a80:	e426                	sd	s1,8(sp)
ffffffffc0205a82:	ec06                	sd	ra,24(sp)
ffffffffc0205a84:	842e                	mv	s0,a1
ffffffffc0205a86:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205a88:	cd81                	beqz	a1,ffffffffc0205aa0 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205a8a:	000a7797          	auipc	a5,0xa7
ffffffffc0205a8e:	b2678793          	addi	a5,a5,-1242 # ffffffffc02ac5b0 <current>
ffffffffc0205a92:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205a94:	4685                	li	a3,1
ffffffffc0205a96:	4611                	li	a2,4
ffffffffc0205a98:	7788                	ld	a0,40(a5)
ffffffffc0205a9a:	f23fe0ef          	jal	ra,ffffffffc02049bc <user_mem_check>
ffffffffc0205a9e:	c909                	beqz	a0,ffffffffc0205ab0 <do_wait+0x34>
ffffffffc0205aa0:	85a2                	mv	a1,s0
}
ffffffffc0205aa2:	6442                	ld	s0,16(sp)
ffffffffc0205aa4:	60e2                	ld	ra,24(sp)
ffffffffc0205aa6:	8526                	mv	a0,s1
ffffffffc0205aa8:	64a2                	ld	s1,8(sp)
ffffffffc0205aaa:	6105                	addi	sp,sp,32
ffffffffc0205aac:	80dff06f          	j	ffffffffc02052b8 <do_wait.part.1>
ffffffffc0205ab0:	60e2                	ld	ra,24(sp)
ffffffffc0205ab2:	6442                	ld	s0,16(sp)
ffffffffc0205ab4:	64a2                	ld	s1,8(sp)
ffffffffc0205ab6:	5575                	li	a0,-3
ffffffffc0205ab8:	6105                	addi	sp,sp,32
ffffffffc0205aba:	8082                	ret

ffffffffc0205abc <do_kill>:
do_kill(int pid) {
ffffffffc0205abc:	1141                	addi	sp,sp,-16
ffffffffc0205abe:	e406                	sd	ra,8(sp)
ffffffffc0205ac0:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205ac2:	a98ff0ef          	jal	ra,ffffffffc0204d5a <find_proc>
ffffffffc0205ac6:	cd0d                	beqz	a0,ffffffffc0205b00 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205ac8:	0b052703          	lw	a4,176(a0)
ffffffffc0205acc:	00177693          	andi	a3,a4,1
ffffffffc0205ad0:	e695                	bnez	a3,ffffffffc0205afc <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205ad2:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205ad6:	00176713          	ori	a4,a4,1
ffffffffc0205ada:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205ade:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205ae0:	0006c763          	bltz	a3,ffffffffc0205aee <do_kill+0x32>
}
ffffffffc0205ae4:	8522                	mv	a0,s0
ffffffffc0205ae6:	60a2                	ld	ra,8(sp)
ffffffffc0205ae8:	6402                	ld	s0,0(sp)
ffffffffc0205aea:	0141                	addi	sp,sp,16
ffffffffc0205aec:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205aee:	1ea000ef          	jal	ra,ffffffffc0205cd8 <wakeup_proc>
}
ffffffffc0205af2:	8522                	mv	a0,s0
ffffffffc0205af4:	60a2                	ld	ra,8(sp)
ffffffffc0205af6:	6402                	ld	s0,0(sp)
ffffffffc0205af8:	0141                	addi	sp,sp,16
ffffffffc0205afa:	8082                	ret
        return -E_KILLED;
ffffffffc0205afc:	545d                	li	s0,-9
ffffffffc0205afe:	b7dd                	j	ffffffffc0205ae4 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205b00:	5475                	li	s0,-3
ffffffffc0205b02:	b7cd                	j	ffffffffc0205ae4 <do_kill+0x28>

ffffffffc0205b04 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205b04:	000a7797          	auipc	a5,0xa7
ffffffffc0205b08:	bec78793          	addi	a5,a5,-1044 # ffffffffc02ac6f0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205b0c:	1101                	addi	sp,sp,-32
ffffffffc0205b0e:	000a7717          	auipc	a4,0xa7
ffffffffc0205b12:	bef73523          	sd	a5,-1046(a4) # ffffffffc02ac6f8 <proc_list+0x8>
ffffffffc0205b16:	000a7717          	auipc	a4,0xa7
ffffffffc0205b1a:	bcf73d23          	sd	a5,-1062(a4) # ffffffffc02ac6f0 <proc_list>
ffffffffc0205b1e:	ec06                	sd	ra,24(sp)
ffffffffc0205b20:	e822                	sd	s0,16(sp)
ffffffffc0205b22:	e426                	sd	s1,8(sp)
ffffffffc0205b24:	000a3797          	auipc	a5,0xa3
ffffffffc0205b28:	a5478793          	addi	a5,a5,-1452 # ffffffffc02a8578 <hash_list>
ffffffffc0205b2c:	000a7717          	auipc	a4,0xa7
ffffffffc0205b30:	a4c70713          	addi	a4,a4,-1460 # ffffffffc02ac578 <is_panic>
ffffffffc0205b34:	e79c                	sd	a5,8(a5)
ffffffffc0205b36:	e39c                	sd	a5,0(a5)
ffffffffc0205b38:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205b3a:	fee79de3          	bne	a5,a4,ffffffffc0205b34 <proc_init+0x30>
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0205b3e:	10800513          	li	a0,264
ffffffffc0205b42:	8f0fc0ef          	jal	ra,ffffffffc0201c32 <kmalloc>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205b46:	000a7717          	auipc	a4,0xa7
ffffffffc0205b4a:	a6a73923          	sd	a0,-1422(a4) # ffffffffc02ac5b8 <idleproc>
ffffffffc0205b4e:	000a7497          	auipc	s1,0xa7
ffffffffc0205b52:	a6a48493          	addi	s1,s1,-1430 # ffffffffc02ac5b8 <idleproc>
ffffffffc0205b56:	c559                	beqz	a0,ffffffffc0205be4 <proc_init+0xe0>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205b58:	4709                	li	a4,2
ffffffffc0205b5a:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205b5c:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205b5e:	00003717          	auipc	a4,0x3
ffffffffc0205b62:	4a270713          	addi	a4,a4,1186 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205b66:	00003597          	auipc	a1,0x3
ffffffffc0205b6a:	8ea58593          	addi	a1,a1,-1814 # ffffffffc0208450 <default_pmm_manager+0x1370>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205b6e:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205b70:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205b72:	952ff0ef          	jal	ra,ffffffffc0204cc4 <set_proc_name>
    nr_process ++;
ffffffffc0205b76:	000a7797          	auipc	a5,0xa7
ffffffffc0205b7a:	a5278793          	addi	a5,a5,-1454 # ffffffffc02ac5c8 <nr_process>
ffffffffc0205b7e:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205b80:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205b82:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205b84:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205b86:	4581                	li	a1,0
ffffffffc0205b88:	00000517          	auipc	a0,0x0
ffffffffc0205b8c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0205460 <init_main>
    nr_process ++;
ffffffffc0205b90:	000a7697          	auipc	a3,0xa7
ffffffffc0205b94:	a2f6ac23          	sw	a5,-1480(a3) # ffffffffc02ac5c8 <nr_process>
    current = idleproc;
ffffffffc0205b98:	000a7797          	auipc	a5,0xa7
ffffffffc0205b9c:	a0e7bc23          	sd	a4,-1512(a5) # ffffffffc02ac5b0 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205ba0:	d7aff0ef          	jal	ra,ffffffffc020511a <kernel_thread>
    if (pid <= 0) {
ffffffffc0205ba4:	08a05c63          	blez	a0,ffffffffc0205c3c <proc_init+0x138>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205ba8:	9b2ff0ef          	jal	ra,ffffffffc0204d5a <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205bac:	00003597          	auipc	a1,0x3
ffffffffc0205bb0:	8cc58593          	addi	a1,a1,-1844 # ffffffffc0208478 <default_pmm_manager+0x1398>
    initproc = find_proc(pid);
ffffffffc0205bb4:	000a7797          	auipc	a5,0xa7
ffffffffc0205bb8:	a0a7b623          	sd	a0,-1524(a5) # ffffffffc02ac5c0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205bbc:	908ff0ef          	jal	ra,ffffffffc0204cc4 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205bc0:	609c                	ld	a5,0(s1)
ffffffffc0205bc2:	cfa9                	beqz	a5,ffffffffc0205c1c <proc_init+0x118>
ffffffffc0205bc4:	43dc                	lw	a5,4(a5)
ffffffffc0205bc6:	ebb9                	bnez	a5,ffffffffc0205c1c <proc_init+0x118>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205bc8:	000a7797          	auipc	a5,0xa7
ffffffffc0205bcc:	9f878793          	addi	a5,a5,-1544 # ffffffffc02ac5c0 <initproc>
ffffffffc0205bd0:	639c                	ld	a5,0(a5)
ffffffffc0205bd2:	c78d                	beqz	a5,ffffffffc0205bfc <proc_init+0xf8>
ffffffffc0205bd4:	43dc                	lw	a5,4(a5)
ffffffffc0205bd6:	02879363          	bne	a5,s0,ffffffffc0205bfc <proc_init+0xf8>
}
ffffffffc0205bda:	60e2                	ld	ra,24(sp)
ffffffffc0205bdc:	6442                	ld	s0,16(sp)
ffffffffc0205bde:	64a2                	ld	s1,8(sp)
ffffffffc0205be0:	6105                	addi	sp,sp,32
ffffffffc0205be2:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205be4:	00003617          	auipc	a2,0x3
ffffffffc0205be8:	85460613          	addi	a2,a2,-1964 # ffffffffc0208438 <default_pmm_manager+0x1358>
ffffffffc0205bec:	36900593          	li	a1,873
ffffffffc0205bf0:	00003517          	auipc	a0,0x3
ffffffffc0205bf4:	94050513          	addi	a0,a0,-1728 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205bf8:	88dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205bfc:	00003697          	auipc	a3,0x3
ffffffffc0205c00:	8ac68693          	addi	a3,a3,-1876 # ffffffffc02084a8 <default_pmm_manager+0x13c8>
ffffffffc0205c04:	00001617          	auipc	a2,0x1
ffffffffc0205c08:	d9460613          	addi	a2,a2,-620 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205c0c:	37e00593          	li	a1,894
ffffffffc0205c10:	00003517          	auipc	a0,0x3
ffffffffc0205c14:	92050513          	addi	a0,a0,-1760 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205c18:	86dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205c1c:	00003697          	auipc	a3,0x3
ffffffffc0205c20:	86468693          	addi	a3,a3,-1948 # ffffffffc0208480 <default_pmm_manager+0x13a0>
ffffffffc0205c24:	00001617          	auipc	a2,0x1
ffffffffc0205c28:	d7460613          	addi	a2,a2,-652 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205c2c:	37d00593          	li	a1,893
ffffffffc0205c30:	00003517          	auipc	a0,0x3
ffffffffc0205c34:	90050513          	addi	a0,a0,-1792 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205c38:	84dfa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205c3c:	00003617          	auipc	a2,0x3
ffffffffc0205c40:	81c60613          	addi	a2,a2,-2020 # ffffffffc0208458 <default_pmm_manager+0x1378>
ffffffffc0205c44:	37700593          	li	a1,887
ffffffffc0205c48:	00003517          	auipc	a0,0x3
ffffffffc0205c4c:	8e850513          	addi	a0,a0,-1816 # ffffffffc0208530 <default_pmm_manager+0x1450>
ffffffffc0205c50:	835fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205c54 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205c54:	1141                	addi	sp,sp,-16
ffffffffc0205c56:	e022                	sd	s0,0(sp)
ffffffffc0205c58:	e406                	sd	ra,8(sp)
ffffffffc0205c5a:	000a7417          	auipc	s0,0xa7
ffffffffc0205c5e:	95640413          	addi	s0,s0,-1706 # ffffffffc02ac5b0 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205c62:	6018                	ld	a4,0(s0)
ffffffffc0205c64:	6f1c                	ld	a5,24(a4)
ffffffffc0205c66:	dffd                	beqz	a5,ffffffffc0205c64 <cpu_idle+0x10>
            schedule();
ffffffffc0205c68:	0ec000ef          	jal	ra,ffffffffc0205d54 <schedule>
ffffffffc0205c6c:	bfdd                	j	ffffffffc0205c62 <cpu_idle+0xe>

ffffffffc0205c6e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205c6e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205c72:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205c76:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205c78:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205c7a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205c7e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205c82:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205c86:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205c8a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205c8e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205c92:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205c96:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205c9a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205c9e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205ca2:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205ca6:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205caa:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205cac:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205cae:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205cb2:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205cb6:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205cba:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205cbe:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205cc2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205cc6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205cca:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205cce:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205cd2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205cd6:	8082                	ret

ffffffffc0205cd8 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205cd8:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205cda:	1101                	addi	sp,sp,-32
ffffffffc0205cdc:	ec06                	sd	ra,24(sp)
ffffffffc0205cde:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ce0:	478d                	li	a5,3
ffffffffc0205ce2:	04f70a63          	beq	a4,a5,ffffffffc0205d36 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205ce6:	100027f3          	csrr	a5,sstatus
ffffffffc0205cea:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205cec:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205cee:	ef8d                	bnez	a5,ffffffffc0205d28 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205cf0:	4789                	li	a5,2
ffffffffc0205cf2:	00f70f63          	beq	a4,a5,ffffffffc0205d10 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205cf6:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205cf8:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205cfc:	e409                	bnez	s0,ffffffffc0205d06 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205cfe:	60e2                	ld	ra,24(sp)
ffffffffc0205d00:	6442                	ld	s0,16(sp)
ffffffffc0205d02:	6105                	addi	sp,sp,32
ffffffffc0205d04:	8082                	ret
ffffffffc0205d06:	6442                	ld	s0,16(sp)
ffffffffc0205d08:	60e2                	ld	ra,24(sp)
ffffffffc0205d0a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205d0c:	925fa06f          	j	ffffffffc0200630 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205d10:	00003617          	auipc	a2,0x3
ffffffffc0205d14:	87060613          	addi	a2,a2,-1936 # ffffffffc0208580 <default_pmm_manager+0x14a0>
ffffffffc0205d18:	45c9                	li	a1,18
ffffffffc0205d1a:	00003517          	auipc	a0,0x3
ffffffffc0205d1e:	84e50513          	addi	a0,a0,-1970 # ffffffffc0208568 <default_pmm_manager+0x1488>
ffffffffc0205d22:	fcefa0ef          	jal	ra,ffffffffc02004f0 <__warn>
ffffffffc0205d26:	bfd9                	j	ffffffffc0205cfc <wakeup_proc+0x24>
ffffffffc0205d28:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205d2a:	90dfa0ef          	jal	ra,ffffffffc0200636 <intr_disable>
        return 1;
ffffffffc0205d2e:	6522                	ld	a0,8(sp)
ffffffffc0205d30:	4405                	li	s0,1
ffffffffc0205d32:	4118                	lw	a4,0(a0)
ffffffffc0205d34:	bf75                	j	ffffffffc0205cf0 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d36:	00003697          	auipc	a3,0x3
ffffffffc0205d3a:	81268693          	addi	a3,a3,-2030 # ffffffffc0208548 <default_pmm_manager+0x1468>
ffffffffc0205d3e:	00001617          	auipc	a2,0x1
ffffffffc0205d42:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206998 <commands+0x4c0>
ffffffffc0205d46:	45a5                	li	a1,9
ffffffffc0205d48:	00003517          	auipc	a0,0x3
ffffffffc0205d4c:	82050513          	addi	a0,a0,-2016 # ffffffffc0208568 <default_pmm_manager+0x1488>
ffffffffc0205d50:	f34fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205d54 <schedule>:

void
schedule(void) {
ffffffffc0205d54:	1141                	addi	sp,sp,-16
ffffffffc0205d56:	e406                	sd	ra,8(sp)
ffffffffc0205d58:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d5a:	100027f3          	csrr	a5,sstatus
ffffffffc0205d5e:	8b89                	andi	a5,a5,2
ffffffffc0205d60:	4401                	li	s0,0
ffffffffc0205d62:	e3d1                	bnez	a5,ffffffffc0205de6 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205d64:	000a7797          	auipc	a5,0xa7
ffffffffc0205d68:	84c78793          	addi	a5,a5,-1972 # ffffffffc02ac5b0 <current>
ffffffffc0205d6c:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205d70:	000a7797          	auipc	a5,0xa7
ffffffffc0205d74:	84878793          	addi	a5,a5,-1976 # ffffffffc02ac5b8 <idleproc>
ffffffffc0205d78:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205d7a:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7578>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205d7e:	04a88e63          	beq	a7,a0,ffffffffc0205dda <schedule+0x86>
ffffffffc0205d82:	0c888693          	addi	a3,a7,200
ffffffffc0205d86:	000a7617          	auipc	a2,0xa7
ffffffffc0205d8a:	96a60613          	addi	a2,a2,-1686 # ffffffffc02ac6f0 <proc_list>
        le = last;
ffffffffc0205d8e:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205d90:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205d92:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205d94:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205d96:	00c78863          	beq	a5,a2,ffffffffc0205da6 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205d9a:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205d9e:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205da2:	01070463          	beq	a4,a6,ffffffffc0205daa <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205da6:	fef697e3          	bne	a3,a5,ffffffffc0205d94 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205daa:	c589                	beqz	a1,ffffffffc0205db4 <schedule+0x60>
ffffffffc0205dac:	4198                	lw	a4,0(a1)
ffffffffc0205dae:	4789                	li	a5,2
ffffffffc0205db0:	00f70e63          	beq	a4,a5,ffffffffc0205dcc <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205db4:	451c                	lw	a5,8(a0)
ffffffffc0205db6:	2785                	addiw	a5,a5,1
ffffffffc0205db8:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205dba:	00a88463          	beq	a7,a0,ffffffffc0205dc2 <schedule+0x6e>
            proc_run(next);
ffffffffc0205dbe:	f31fe0ef          	jal	ra,ffffffffc0204cee <proc_run>
    if (flag) {
ffffffffc0205dc2:	e419                	bnez	s0,ffffffffc0205dd0 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205dc4:	60a2                	ld	ra,8(sp)
ffffffffc0205dc6:	6402                	ld	s0,0(sp)
ffffffffc0205dc8:	0141                	addi	sp,sp,16
ffffffffc0205dca:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205dcc:	852e                	mv	a0,a1
ffffffffc0205dce:	b7dd                	j	ffffffffc0205db4 <schedule+0x60>
}
ffffffffc0205dd0:	6402                	ld	s0,0(sp)
ffffffffc0205dd2:	60a2                	ld	ra,8(sp)
ffffffffc0205dd4:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc0205dd6:	85bfa06f          	j	ffffffffc0200630 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205dda:	000a7617          	auipc	a2,0xa7
ffffffffc0205dde:	91660613          	addi	a2,a2,-1770 # ffffffffc02ac6f0 <proc_list>
ffffffffc0205de2:	86b2                	mv	a3,a2
ffffffffc0205de4:	b76d                	j	ffffffffc0205d8e <schedule+0x3a>
        intr_disable();
ffffffffc0205de6:	851fa0ef          	jal	ra,ffffffffc0200636 <intr_disable>
        return 1;
ffffffffc0205dea:	4405                	li	s0,1
ffffffffc0205dec:	bfa5                	j	ffffffffc0205d64 <schedule+0x10>

ffffffffc0205dee <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205dee:	000a6797          	auipc	a5,0xa6
ffffffffc0205df2:	7c278793          	addi	a5,a5,1986 # ffffffffc02ac5b0 <current>
ffffffffc0205df6:	639c                	ld	a5,0(a5)
}
ffffffffc0205df8:	43c8                	lw	a0,4(a5)
ffffffffc0205dfa:	8082                	ret

ffffffffc0205dfc <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205dfc:	4501                	li	a0,0
ffffffffc0205dfe:	8082                	ret

ffffffffc0205e00 <sys_putc>:
    cputchar(c);
ffffffffc0205e00:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205e02:	1141                	addi	sp,sp,-16
ffffffffc0205e04:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205e06:	bbcfa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc0205e0a:	60a2                	ld	ra,8(sp)
ffffffffc0205e0c:	4501                	li	a0,0
ffffffffc0205e0e:	0141                	addi	sp,sp,16
ffffffffc0205e10:	8082                	ret

ffffffffc0205e12 <sys_kill>:
    return do_kill(pid);
ffffffffc0205e12:	4108                	lw	a0,0(a0)
ffffffffc0205e14:	ca9ff06f          	j	ffffffffc0205abc <do_kill>

ffffffffc0205e18 <sys_yield>:
    return do_yield();
ffffffffc0205e18:	c53ff06f          	j	ffffffffc0205a6a <do_yield>

ffffffffc0205e1c <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205e1c:	6d14                	ld	a3,24(a0)
ffffffffc0205e1e:	6910                	ld	a2,16(a0)
ffffffffc0205e20:	650c                	ld	a1,8(a0)
ffffffffc0205e22:	6108                	ld	a0,0(a0)
ffffffffc0205e24:	f64ff06f          	j	ffffffffc0205588 <do_execve>

ffffffffc0205e28 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205e28:	650c                	ld	a1,8(a0)
ffffffffc0205e2a:	4108                	lw	a0,0(a0)
ffffffffc0205e2c:	c51ff06f          	j	ffffffffc0205a7c <do_wait>

ffffffffc0205e30 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205e30:	000a6797          	auipc	a5,0xa6
ffffffffc0205e34:	78078793          	addi	a5,a5,1920 # ffffffffc02ac5b0 <current>
ffffffffc0205e38:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0205e3a:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0205e3c:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205e3e:	6a0c                	ld	a1,16(a2)
ffffffffc0205e40:	f77fe06f          	j	ffffffffc0204db6 <do_fork>

ffffffffc0205e44 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205e44:	4108                	lw	a0,0(a0)
ffffffffc0205e46:	b24ff06f          	j	ffffffffc020516a <do_exit>

ffffffffc0205e4a <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0205e4a:	715d                	addi	sp,sp,-80
ffffffffc0205e4c:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205e4e:	000a6497          	auipc	s1,0xa6
ffffffffc0205e52:	76248493          	addi	s1,s1,1890 # ffffffffc02ac5b0 <current>
ffffffffc0205e56:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0205e58:	e0a2                	sd	s0,64(sp)
ffffffffc0205e5a:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205e5c:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0205e5e:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205e60:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205e62:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205e66:	0327ee63          	bltu	a5,s2,ffffffffc0205ea2 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0205e6a:	00391713          	slli	a4,s2,0x3
ffffffffc0205e6e:	00002797          	auipc	a5,0x2
ffffffffc0205e72:	77a78793          	addi	a5,a5,1914 # ffffffffc02085e8 <syscalls>
ffffffffc0205e76:	97ba                	add	a5,a5,a4
ffffffffc0205e78:	639c                	ld	a5,0(a5)
ffffffffc0205e7a:	c785                	beqz	a5,ffffffffc0205ea2 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0205e7c:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0205e7e:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0205e80:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0205e82:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0205e84:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0205e86:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0205e88:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0205e8a:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0205e8c:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0205e8e:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205e90:	0028                	addi	a0,sp,8
ffffffffc0205e92:	9782                	jalr	a5
ffffffffc0205e94:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205e96:	60a6                	ld	ra,72(sp)
ffffffffc0205e98:	6406                	ld	s0,64(sp)
ffffffffc0205e9a:	74e2                	ld	s1,56(sp)
ffffffffc0205e9c:	7942                	ld	s2,48(sp)
ffffffffc0205e9e:	6161                	addi	sp,sp,80
ffffffffc0205ea0:	8082                	ret
    print_trapframe(tf);
ffffffffc0205ea2:	8522                	mv	a0,s0
ffffffffc0205ea4:	983fa0ef          	jal	ra,ffffffffc0200826 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205ea8:	609c                	ld	a5,0(s1)
ffffffffc0205eaa:	86ca                	mv	a3,s2
ffffffffc0205eac:	00002617          	auipc	a2,0x2
ffffffffc0205eb0:	6f460613          	addi	a2,a2,1780 # ffffffffc02085a0 <default_pmm_manager+0x14c0>
ffffffffc0205eb4:	43d8                	lw	a4,4(a5)
ffffffffc0205eb6:	06c00593          	li	a1,108
ffffffffc0205eba:	0b478793          	addi	a5,a5,180
ffffffffc0205ebe:	00002517          	auipc	a0,0x2
ffffffffc0205ec2:	71250513          	addi	a0,a0,1810 # ffffffffc02085d0 <default_pmm_manager+0x14f0>
ffffffffc0205ec6:	dbefa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205eca <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205eca:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205ece:	2785                	addiw	a5,a5,1
ffffffffc0205ed0:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0205ed4:	02000793          	li	a5,32
ffffffffc0205ed8:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0205edc:	00b5553b          	srlw	a0,a0,a1
ffffffffc0205ee0:	8082                	ret

ffffffffc0205ee2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205ee2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205ee6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0205ee8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205eec:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0205eee:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205ef2:	f022                	sd	s0,32(sp)
ffffffffc0205ef4:	ec26                	sd	s1,24(sp)
ffffffffc0205ef6:	e84a                	sd	s2,16(sp)
ffffffffc0205ef8:	f406                	sd	ra,40(sp)
ffffffffc0205efa:	e44e                	sd	s3,8(sp)
ffffffffc0205efc:	84aa                	mv	s1,a0
ffffffffc0205efe:	892e                	mv	s2,a1
ffffffffc0205f00:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0205f04:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0205f06:	03067e63          	bleu	a6,a2,ffffffffc0205f42 <printnum+0x60>
ffffffffc0205f0a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0205f0c:	00805763          	blez	s0,ffffffffc0205f1a <printnum+0x38>
ffffffffc0205f10:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205f12:	85ca                	mv	a1,s2
ffffffffc0205f14:	854e                	mv	a0,s3
ffffffffc0205f16:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0205f18:	fc65                	bnez	s0,ffffffffc0205f10 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f1a:	1a02                	slli	s4,s4,0x20
ffffffffc0205f1c:	020a5a13          	srli	s4,s4,0x20
ffffffffc0205f20:	00003797          	auipc	a5,0x3
ffffffffc0205f24:	9e878793          	addi	a5,a5,-1560 # ffffffffc0208908 <error_string+0xc8>
ffffffffc0205f28:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205f2a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f2c:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0205f30:	70a2                	ld	ra,40(sp)
ffffffffc0205f32:	69a2                	ld	s3,8(sp)
ffffffffc0205f34:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f36:	85ca                	mv	a1,s2
ffffffffc0205f38:	8326                	mv	t1,s1
}
ffffffffc0205f3a:	6942                	ld	s2,16(sp)
ffffffffc0205f3c:	64e2                	ld	s1,24(sp)
ffffffffc0205f3e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205f40:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0205f42:	03065633          	divu	a2,a2,a6
ffffffffc0205f46:	8722                	mv	a4,s0
ffffffffc0205f48:	f9bff0ef          	jal	ra,ffffffffc0205ee2 <printnum>
ffffffffc0205f4c:	b7f9                	j	ffffffffc0205f1a <printnum+0x38>

ffffffffc0205f4e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205f4e:	7119                	addi	sp,sp,-128
ffffffffc0205f50:	f4a6                	sd	s1,104(sp)
ffffffffc0205f52:	f0ca                	sd	s2,96(sp)
ffffffffc0205f54:	e8d2                	sd	s4,80(sp)
ffffffffc0205f56:	e4d6                	sd	s5,72(sp)
ffffffffc0205f58:	e0da                	sd	s6,64(sp)
ffffffffc0205f5a:	fc5e                	sd	s7,56(sp)
ffffffffc0205f5c:	f862                	sd	s8,48(sp)
ffffffffc0205f5e:	f06a                	sd	s10,32(sp)
ffffffffc0205f60:	fc86                	sd	ra,120(sp)
ffffffffc0205f62:	f8a2                	sd	s0,112(sp)
ffffffffc0205f64:	ecce                	sd	s3,88(sp)
ffffffffc0205f66:	f466                	sd	s9,40(sp)
ffffffffc0205f68:	ec6e                	sd	s11,24(sp)
ffffffffc0205f6a:	892a                	mv	s2,a0
ffffffffc0205f6c:	84ae                	mv	s1,a1
ffffffffc0205f6e:	8d32                	mv	s10,a2
ffffffffc0205f70:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0205f72:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205f74:	00002a17          	auipc	s4,0x2
ffffffffc0205f78:	774a0a13          	addi	s4,s4,1908 # ffffffffc02086e8 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205f7c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205f80:	00003c17          	auipc	s8,0x3
ffffffffc0205f84:	8c0c0c13          	addi	s8,s8,-1856 # ffffffffc0208840 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205f88:	000d4503          	lbu	a0,0(s10)
ffffffffc0205f8c:	02500793          	li	a5,37
ffffffffc0205f90:	001d0413          	addi	s0,s10,1
ffffffffc0205f94:	00f50e63          	beq	a0,a5,ffffffffc0205fb0 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0205f98:	c521                	beqz	a0,ffffffffc0205fe0 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205f9a:	02500993          	li	s3,37
ffffffffc0205f9e:	a011                	j	ffffffffc0205fa2 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0205fa0:	c121                	beqz	a0,ffffffffc0205fe0 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0205fa2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205fa4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0205fa6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205fa8:	fff44503          	lbu	a0,-1(s0)
ffffffffc0205fac:	ff351ae3          	bne	a0,s3,ffffffffc0205fa0 <vprintfmt+0x52>
ffffffffc0205fb0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0205fb4:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0205fb8:	4981                	li	s3,0
ffffffffc0205fba:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0205fbc:	5cfd                	li	s9,-1
ffffffffc0205fbe:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205fc0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0205fc4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205fc6:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0205fca:	0ff6f693          	andi	a3,a3,255
ffffffffc0205fce:	00140d13          	addi	s10,s0,1
ffffffffc0205fd2:	20d5e563          	bltu	a1,a3,ffffffffc02061dc <vprintfmt+0x28e>
ffffffffc0205fd6:	068a                	slli	a3,a3,0x2
ffffffffc0205fd8:	96d2                	add	a3,a3,s4
ffffffffc0205fda:	4294                	lw	a3,0(a3)
ffffffffc0205fdc:	96d2                	add	a3,a3,s4
ffffffffc0205fde:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205fe0:	70e6                	ld	ra,120(sp)
ffffffffc0205fe2:	7446                	ld	s0,112(sp)
ffffffffc0205fe4:	74a6                	ld	s1,104(sp)
ffffffffc0205fe6:	7906                	ld	s2,96(sp)
ffffffffc0205fe8:	69e6                	ld	s3,88(sp)
ffffffffc0205fea:	6a46                	ld	s4,80(sp)
ffffffffc0205fec:	6aa6                	ld	s5,72(sp)
ffffffffc0205fee:	6b06                	ld	s6,64(sp)
ffffffffc0205ff0:	7be2                	ld	s7,56(sp)
ffffffffc0205ff2:	7c42                	ld	s8,48(sp)
ffffffffc0205ff4:	7ca2                	ld	s9,40(sp)
ffffffffc0205ff6:	7d02                	ld	s10,32(sp)
ffffffffc0205ff8:	6de2                	ld	s11,24(sp)
ffffffffc0205ffa:	6109                	addi	sp,sp,128
ffffffffc0205ffc:	8082                	ret
    if (lflag >= 2) {
ffffffffc0205ffe:	4705                	li	a4,1
ffffffffc0206000:	008a8593          	addi	a1,s5,8
ffffffffc0206004:	01074463          	blt	a4,a6,ffffffffc020600c <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0206008:	26080363          	beqz	a6,ffffffffc020626e <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020600c:	000ab603          	ld	a2,0(s5)
ffffffffc0206010:	46c1                	li	a3,16
ffffffffc0206012:	8aae                	mv	s5,a1
ffffffffc0206014:	a06d                	j	ffffffffc02060be <vprintfmt+0x170>
            goto reswitch;
ffffffffc0206016:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020601a:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020601c:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020601e:	b765                	j	ffffffffc0205fc6 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0206020:	000aa503          	lw	a0,0(s5)
ffffffffc0206024:	85a6                	mv	a1,s1
ffffffffc0206026:	0aa1                	addi	s5,s5,8
ffffffffc0206028:	9902                	jalr	s2
            break;
ffffffffc020602a:	bfb9                	j	ffffffffc0205f88 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020602c:	4705                	li	a4,1
ffffffffc020602e:	008a8993          	addi	s3,s5,8
ffffffffc0206032:	01074463          	blt	a4,a6,ffffffffc020603a <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0206036:	22080463          	beqz	a6,ffffffffc020625e <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020603a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc020603e:	24044463          	bltz	s0,ffffffffc0206286 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0206042:	8622                	mv	a2,s0
ffffffffc0206044:	8ace                	mv	s5,s3
ffffffffc0206046:	46a9                	li	a3,10
ffffffffc0206048:	a89d                	j	ffffffffc02060be <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc020604a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020604e:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0206050:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0206052:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206056:	8fb5                	xor	a5,a5,a3
ffffffffc0206058:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020605c:	1ad74363          	blt	a4,a3,ffffffffc0206202 <vprintfmt+0x2b4>
ffffffffc0206060:	00369793          	slli	a5,a3,0x3
ffffffffc0206064:	97e2                	add	a5,a5,s8
ffffffffc0206066:	639c                	ld	a5,0(a5)
ffffffffc0206068:	18078d63          	beqz	a5,ffffffffc0206202 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc020606c:	86be                	mv	a3,a5
ffffffffc020606e:	00000617          	auipc	a2,0x0
ffffffffc0206072:	36260613          	addi	a2,a2,866 # ffffffffc02063d0 <etext+0x2e>
ffffffffc0206076:	85a6                	mv	a1,s1
ffffffffc0206078:	854a                	mv	a0,s2
ffffffffc020607a:	240000ef          	jal	ra,ffffffffc02062ba <printfmt>
ffffffffc020607e:	b729                	j	ffffffffc0205f88 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0206080:	00144603          	lbu	a2,1(s0)
ffffffffc0206084:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206086:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206088:	bf3d                	j	ffffffffc0205fc6 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc020608a:	4705                	li	a4,1
ffffffffc020608c:	008a8593          	addi	a1,s5,8
ffffffffc0206090:	01074463          	blt	a4,a6,ffffffffc0206098 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0206094:	1e080263          	beqz	a6,ffffffffc0206278 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0206098:	000ab603          	ld	a2,0(s5)
ffffffffc020609c:	46a1                	li	a3,8
ffffffffc020609e:	8aae                	mv	s5,a1
ffffffffc02060a0:	a839                	j	ffffffffc02060be <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02060a2:	03000513          	li	a0,48
ffffffffc02060a6:	85a6                	mv	a1,s1
ffffffffc02060a8:	e03e                	sd	a5,0(sp)
ffffffffc02060aa:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02060ac:	85a6                	mv	a1,s1
ffffffffc02060ae:	07800513          	li	a0,120
ffffffffc02060b2:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02060b4:	0aa1                	addi	s5,s5,8
ffffffffc02060b6:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02060ba:	6782                	ld	a5,0(sp)
ffffffffc02060bc:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02060be:	876e                	mv	a4,s11
ffffffffc02060c0:	85a6                	mv	a1,s1
ffffffffc02060c2:	854a                	mv	a0,s2
ffffffffc02060c4:	e1fff0ef          	jal	ra,ffffffffc0205ee2 <printnum>
            break;
ffffffffc02060c8:	b5c1                	j	ffffffffc0205f88 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02060ca:	000ab603          	ld	a2,0(s5)
ffffffffc02060ce:	0aa1                	addi	s5,s5,8
ffffffffc02060d0:	1c060663          	beqz	a2,ffffffffc020629c <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02060d4:	00160413          	addi	s0,a2,1
ffffffffc02060d8:	17b05c63          	blez	s11,ffffffffc0206250 <vprintfmt+0x302>
ffffffffc02060dc:	02d00593          	li	a1,45
ffffffffc02060e0:	14b79263          	bne	a5,a1,ffffffffc0206224 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02060e4:	00064783          	lbu	a5,0(a2)
ffffffffc02060e8:	0007851b          	sext.w	a0,a5
ffffffffc02060ec:	c905                	beqz	a0,ffffffffc020611c <vprintfmt+0x1ce>
ffffffffc02060ee:	000cc563          	bltz	s9,ffffffffc02060f8 <vprintfmt+0x1aa>
ffffffffc02060f2:	3cfd                	addiw	s9,s9,-1
ffffffffc02060f4:	036c8263          	beq	s9,s6,ffffffffc0206118 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02060f8:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02060fa:	18098463          	beqz	s3,ffffffffc0206282 <vprintfmt+0x334>
ffffffffc02060fe:	3781                	addiw	a5,a5,-32
ffffffffc0206100:	18fbf163          	bleu	a5,s7,ffffffffc0206282 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0206104:	03f00513          	li	a0,63
ffffffffc0206108:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020610a:	0405                	addi	s0,s0,1
ffffffffc020610c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206110:	3dfd                	addiw	s11,s11,-1
ffffffffc0206112:	0007851b          	sext.w	a0,a5
ffffffffc0206116:	fd61                	bnez	a0,ffffffffc02060ee <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206118:	e7b058e3          	blez	s11,ffffffffc0205f88 <vprintfmt+0x3a>
ffffffffc020611c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020611e:	85a6                	mv	a1,s1
ffffffffc0206120:	02000513          	li	a0,32
ffffffffc0206124:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206126:	e60d81e3          	beqz	s11,ffffffffc0205f88 <vprintfmt+0x3a>
ffffffffc020612a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020612c:	85a6                	mv	a1,s1
ffffffffc020612e:	02000513          	li	a0,32
ffffffffc0206132:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206134:	fe0d94e3          	bnez	s11,ffffffffc020611c <vprintfmt+0x1ce>
ffffffffc0206138:	bd81                	j	ffffffffc0205f88 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020613a:	4705                	li	a4,1
ffffffffc020613c:	008a8593          	addi	a1,s5,8
ffffffffc0206140:	01074463          	blt	a4,a6,ffffffffc0206148 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0206144:	12080063          	beqz	a6,ffffffffc0206264 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206148:	000ab603          	ld	a2,0(s5)
ffffffffc020614c:	46a9                	li	a3,10
ffffffffc020614e:	8aae                	mv	s5,a1
ffffffffc0206150:	b7bd                	j	ffffffffc02060be <vprintfmt+0x170>
ffffffffc0206152:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0206156:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020615a:	846a                	mv	s0,s10
ffffffffc020615c:	b5ad                	j	ffffffffc0205fc6 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc020615e:	85a6                	mv	a1,s1
ffffffffc0206160:	02500513          	li	a0,37
ffffffffc0206164:	9902                	jalr	s2
            break;
ffffffffc0206166:	b50d                	j	ffffffffc0205f88 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206168:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020616c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206170:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206172:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206174:	e40dd9e3          	bgez	s11,ffffffffc0205fc6 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206178:	8de6                	mv	s11,s9
ffffffffc020617a:	5cfd                	li	s9,-1
ffffffffc020617c:	b5a9                	j	ffffffffc0205fc6 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020617e:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0206182:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206186:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206188:	bd3d                	j	ffffffffc0205fc6 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020618a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020618e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206192:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206194:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206198:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020619c:	fcd56ce3          	bltu	a0,a3,ffffffffc0206174 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02061a0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02061a2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02061a6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02061aa:	0196873b          	addw	a4,a3,s9
ffffffffc02061ae:	0017171b          	slliw	a4,a4,0x1
ffffffffc02061b2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02061b6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02061ba:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02061be:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02061c2:	fcd57fe3          	bleu	a3,a0,ffffffffc02061a0 <vprintfmt+0x252>
ffffffffc02061c6:	b77d                	j	ffffffffc0206174 <vprintfmt+0x226>
            if (width < 0)
ffffffffc02061c8:	fffdc693          	not	a3,s11
ffffffffc02061cc:	96fd                	srai	a3,a3,0x3f
ffffffffc02061ce:	00ddfdb3          	and	s11,s11,a3
ffffffffc02061d2:	00144603          	lbu	a2,1(s0)
ffffffffc02061d6:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061d8:	846a                	mv	s0,s10
ffffffffc02061da:	b3f5                	j	ffffffffc0205fc6 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02061dc:	85a6                	mv	a1,s1
ffffffffc02061de:	02500513          	li	a0,37
ffffffffc02061e2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02061e4:	fff44703          	lbu	a4,-1(s0)
ffffffffc02061e8:	02500793          	li	a5,37
ffffffffc02061ec:	8d22                	mv	s10,s0
ffffffffc02061ee:	d8f70de3          	beq	a4,a5,ffffffffc0205f88 <vprintfmt+0x3a>
ffffffffc02061f2:	02500713          	li	a4,37
ffffffffc02061f6:	1d7d                	addi	s10,s10,-1
ffffffffc02061f8:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02061fc:	fee79de3          	bne	a5,a4,ffffffffc02061f6 <vprintfmt+0x2a8>
ffffffffc0206200:	b361                	j	ffffffffc0205f88 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206202:	00002617          	auipc	a2,0x2
ffffffffc0206206:	7e660613          	addi	a2,a2,2022 # ffffffffc02089e8 <error_string+0x1a8>
ffffffffc020620a:	85a6                	mv	a1,s1
ffffffffc020620c:	854a                	mv	a0,s2
ffffffffc020620e:	0ac000ef          	jal	ra,ffffffffc02062ba <printfmt>
ffffffffc0206212:	bb9d                	j	ffffffffc0205f88 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0206214:	00002617          	auipc	a2,0x2
ffffffffc0206218:	7cc60613          	addi	a2,a2,1996 # ffffffffc02089e0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc020621c:	00002417          	auipc	s0,0x2
ffffffffc0206220:	7c540413          	addi	s0,s0,1989 # ffffffffc02089e1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206224:	8532                	mv	a0,a2
ffffffffc0206226:	85e6                	mv	a1,s9
ffffffffc0206228:	e032                	sd	a2,0(sp)
ffffffffc020622a:	e43e                	sd	a5,8(sp)
ffffffffc020622c:	0cc000ef          	jal	ra,ffffffffc02062f8 <strnlen>
ffffffffc0206230:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0206234:	6602                	ld	a2,0(sp)
ffffffffc0206236:	01b05d63          	blez	s11,ffffffffc0206250 <vprintfmt+0x302>
ffffffffc020623a:	67a2                	ld	a5,8(sp)
ffffffffc020623c:	2781                	sext.w	a5,a5
ffffffffc020623e:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206240:	6522                	ld	a0,8(sp)
ffffffffc0206242:	85a6                	mv	a1,s1
ffffffffc0206244:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206246:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206248:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020624a:	6602                	ld	a2,0(sp)
ffffffffc020624c:	fe0d9ae3          	bnez	s11,ffffffffc0206240 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206250:	00064783          	lbu	a5,0(a2)
ffffffffc0206254:	0007851b          	sext.w	a0,a5
ffffffffc0206258:	e8051be3          	bnez	a0,ffffffffc02060ee <vprintfmt+0x1a0>
ffffffffc020625c:	b335                	j	ffffffffc0205f88 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020625e:	000aa403          	lw	s0,0(s5)
ffffffffc0206262:	bbf1                	j	ffffffffc020603e <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0206264:	000ae603          	lwu	a2,0(s5)
ffffffffc0206268:	46a9                	li	a3,10
ffffffffc020626a:	8aae                	mv	s5,a1
ffffffffc020626c:	bd89                	j	ffffffffc02060be <vprintfmt+0x170>
ffffffffc020626e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206272:	46c1                	li	a3,16
ffffffffc0206274:	8aae                	mv	s5,a1
ffffffffc0206276:	b5a1                	j	ffffffffc02060be <vprintfmt+0x170>
ffffffffc0206278:	000ae603          	lwu	a2,0(s5)
ffffffffc020627c:	46a1                	li	a3,8
ffffffffc020627e:	8aae                	mv	s5,a1
ffffffffc0206280:	bd3d                	j	ffffffffc02060be <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0206282:	9902                	jalr	s2
ffffffffc0206284:	b559                	j	ffffffffc020610a <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0206286:	85a6                	mv	a1,s1
ffffffffc0206288:	02d00513          	li	a0,45
ffffffffc020628c:	e03e                	sd	a5,0(sp)
ffffffffc020628e:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0206290:	8ace                	mv	s5,s3
ffffffffc0206292:	40800633          	neg	a2,s0
ffffffffc0206296:	46a9                	li	a3,10
ffffffffc0206298:	6782                	ld	a5,0(sp)
ffffffffc020629a:	b515                	j	ffffffffc02060be <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020629c:	01b05663          	blez	s11,ffffffffc02062a8 <vprintfmt+0x35a>
ffffffffc02062a0:	02d00693          	li	a3,45
ffffffffc02062a4:	f6d798e3          	bne	a5,a3,ffffffffc0206214 <vprintfmt+0x2c6>
ffffffffc02062a8:	00002417          	auipc	s0,0x2
ffffffffc02062ac:	73940413          	addi	s0,s0,1849 # ffffffffc02089e1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02062b0:	02800513          	li	a0,40
ffffffffc02062b4:	02800793          	li	a5,40
ffffffffc02062b8:	bd1d                	j	ffffffffc02060ee <vprintfmt+0x1a0>

ffffffffc02062ba <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02062ba:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02062bc:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02062c0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02062c2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02062c4:	ec06                	sd	ra,24(sp)
ffffffffc02062c6:	f83a                	sd	a4,48(sp)
ffffffffc02062c8:	fc3e                	sd	a5,56(sp)
ffffffffc02062ca:	e0c2                	sd	a6,64(sp)
ffffffffc02062cc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02062ce:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02062d0:	c7fff0ef          	jal	ra,ffffffffc0205f4e <vprintfmt>
}
ffffffffc02062d4:	60e2                	ld	ra,24(sp)
ffffffffc02062d6:	6161                	addi	sp,sp,80
ffffffffc02062d8:	8082                	ret

ffffffffc02062da <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02062da:	00054783          	lbu	a5,0(a0)
ffffffffc02062de:	cb91                	beqz	a5,ffffffffc02062f2 <strlen+0x18>
    size_t cnt = 0;
ffffffffc02062e0:	4781                	li	a5,0
        cnt ++;
ffffffffc02062e2:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02062e4:	00f50733          	add	a4,a0,a5
ffffffffc02062e8:	00074703          	lbu	a4,0(a4)
ffffffffc02062ec:	fb7d                	bnez	a4,ffffffffc02062e2 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02062ee:	853e                	mv	a0,a5
ffffffffc02062f0:	8082                	ret
    size_t cnt = 0;
ffffffffc02062f2:	4781                	li	a5,0
}
ffffffffc02062f4:	853e                	mv	a0,a5
ffffffffc02062f6:	8082                	ret

ffffffffc02062f8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02062f8:	c185                	beqz	a1,ffffffffc0206318 <strnlen+0x20>
ffffffffc02062fa:	00054783          	lbu	a5,0(a0)
ffffffffc02062fe:	cf89                	beqz	a5,ffffffffc0206318 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206300:	4781                	li	a5,0
ffffffffc0206302:	a021                	j	ffffffffc020630a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206304:	00074703          	lbu	a4,0(a4)
ffffffffc0206308:	c711                	beqz	a4,ffffffffc0206314 <strnlen+0x1c>
        cnt ++;
ffffffffc020630a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020630c:	00f50733          	add	a4,a0,a5
ffffffffc0206310:	fef59ae3          	bne	a1,a5,ffffffffc0206304 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0206314:	853e                	mv	a0,a5
ffffffffc0206316:	8082                	ret
    size_t cnt = 0;
ffffffffc0206318:	4781                	li	a5,0
}
ffffffffc020631a:	853e                	mv	a0,a5
ffffffffc020631c:	8082                	ret

ffffffffc020631e <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc020631e:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206320:	0585                	addi	a1,a1,1
ffffffffc0206322:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206326:	0785                	addi	a5,a5,1
ffffffffc0206328:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020632c:	fb75                	bnez	a4,ffffffffc0206320 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc020632e:	8082                	ret

ffffffffc0206330 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206330:	00054783          	lbu	a5,0(a0)
ffffffffc0206334:	0005c703          	lbu	a4,0(a1)
ffffffffc0206338:	cb91                	beqz	a5,ffffffffc020634c <strcmp+0x1c>
ffffffffc020633a:	00e79c63          	bne	a5,a4,ffffffffc0206352 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc020633e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206340:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0206344:	0585                	addi	a1,a1,1
ffffffffc0206346:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020634a:	fbe5                	bnez	a5,ffffffffc020633a <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020634c:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020634e:	9d19                	subw	a0,a0,a4
ffffffffc0206350:	8082                	ret
ffffffffc0206352:	0007851b          	sext.w	a0,a5
ffffffffc0206356:	9d19                	subw	a0,a0,a4
ffffffffc0206358:	8082                	ret

ffffffffc020635a <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020635a:	00054783          	lbu	a5,0(a0)
ffffffffc020635e:	cb91                	beqz	a5,ffffffffc0206372 <strchr+0x18>
        if (*s == c) {
ffffffffc0206360:	00b79563          	bne	a5,a1,ffffffffc020636a <strchr+0x10>
ffffffffc0206364:	a809                	j	ffffffffc0206376 <strchr+0x1c>
ffffffffc0206366:	00b78763          	beq	a5,a1,ffffffffc0206374 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc020636a:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020636c:	00054783          	lbu	a5,0(a0)
ffffffffc0206370:	fbfd                	bnez	a5,ffffffffc0206366 <strchr+0xc>
    }
    return NULL;
ffffffffc0206372:	4501                	li	a0,0
}
ffffffffc0206374:	8082                	ret
ffffffffc0206376:	8082                	ret

ffffffffc0206378 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206378:	ca01                	beqz	a2,ffffffffc0206388 <memset+0x10>
ffffffffc020637a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020637c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020637e:	0785                	addi	a5,a5,1
ffffffffc0206380:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206384:	fec79de3          	bne	a5,a2,ffffffffc020637e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206388:	8082                	ret

ffffffffc020638a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020638a:	ca19                	beqz	a2,ffffffffc02063a0 <memcpy+0x16>
ffffffffc020638c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020638e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206390:	0585                	addi	a1,a1,1
ffffffffc0206392:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206396:	0785                	addi	a5,a5,1
ffffffffc0206398:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020639c:	fec59ae3          	bne	a1,a2,ffffffffc0206390 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02063a0:	8082                	ret
