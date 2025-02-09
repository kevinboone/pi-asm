// Outputs a simple message using sys_write 
 
.section .rodata 
msg:
    .ascii "Hello, World\n"

.text
.align 2

SYS_EXIT = 93
SYS_WRITE = 64     // syscall number for sys_write.  
STDOUT = 1         // We're going to write to stdout

.global _start

// Exit the program.
//   On entry, r0 should hold the exit code
exit:
    mov    x8, SYS_EXIT
    svc    0

_start:
    // Use the sys_write syscall to output a string
    mov    x8, SYS_WRITE
    mov    x0, STDOUT
    ldr    x1, =msg  // Store the address of the message in r1
    mov    x2, 13    // Store the length of the message in r2
    svc    0

    // Now exit
    mov    x0, 0
    b      exit

