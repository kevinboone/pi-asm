// This example demonstrates how to implement a function (subroutine) 
//  call called 'strlen' that returns the length of a text string in 
//  bytes. The actual implementation is stubbed out -- we will implement
//  the logic later 

.section .rodata 
msg:
    .ascii "Hello, World\n\0"

.text
.align 2

SYS_EXIT = 93
SYS_WRITE = 64     // syscall number for sys_write.  
STDOUT = 1         // We're going to write to stdout

.global _start

// Exit the program.
//   On entry to exit, r0 should hold the exit code
exit:
    mov    x8, SYS_EXIT
    svc    0

// Calulate the length of a null-terminated string
//   On entry, x0 is the address of the string
//   On exit, x0 is the length of the string, not including
//   the terminating null
strlen:
   ldr    x0, =10  // 10 is a dummy value. We will calculate it 
                   //  in the next example
   ret 

_start:
    ldr    x0, =msg
    bl     strlen 
    // Length of string is now in x0

    // Use the sys_write syscall to output a string
    mov    x2, x0          // Transfer length of the message from r0 to r2
    mov    x0, STDOUT
    mov    x8, SYS_WRITE
    ldr    x1, =msg       // Store the address of the message in r1
    svc    0

    // Now exit
    mov    x0, 0
    b      exit

