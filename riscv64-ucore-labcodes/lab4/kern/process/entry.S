.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1  # 传参
	jalr s0  # 调用fn

	jal do_exit
