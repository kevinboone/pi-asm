// This example demonstrates how to implement a function (subroutine) 
//  call called 'strlen' that returns the length of a text string in 
//  bytes. 

.section .rodata 
msg:
    .ascii "Hello, World\n\0"

.text
.align 2

SYS_EXIT = 93
SYS_WRITE = 64     // syscall number for sys_write.  
STDOUT = 1

.global _start

/* =========================== exit ========================================*/
// Exit the program.
//   On entry, x0 should hold the exit code
exit:
    mov    x8, SYS_EXIT
    svc    0

/* =========================== strlen ======================================*/
// Calulate the length of a null-terminated string
//   On entry, x0 is the address of the string
//   On exit, x0 is the length of the string, not including
//   the terminating null
strlen:

   stp      x4, x5, [sp, #-16]! 
   sub      sp, sp, #16  // Protect x4 and x5 on the stack 

   mov      x4, 0        // Use x4 as the character count; initially 0
strlen_0:
   ldr      x5,[x0]      // Read into %r5 the value in memory location x0
   cmp      x5, 0        // Compare to zero, the end-of-line terminator
   beq      strlen_1     // If it's equal to zero, jump out of loop
   add      x0, x0, 1    // If not zero, add one to the character count...
   add      x4, x4, 1    //   and to the address we are looking at
   b        strlen_0     // Then do the loop again
strlen_1:
   mov      x0, x4       // Transfer the character count to x0 for return 

   add      sp, sp, #16          // Shrink the stack.
   ldp      x4, x5, [sp], #16    // Restore x4 and x5 

   ret

/* =========================== start ========================================*/
_start:
    ldr    x0, =msg
    bl     strlen 
    // Length of string is now in x0

    // Use the sys_write syscall to output a string
    mov    x2, x0         // Transfer length of the message from x0 to x2
    mov    x0, STDOUT
    mov    x8, SYS_WRITE
    ldr    x1, =msg      // Store the address of the message in x1
    svc    0

    // Now exit
    mov    x0, 0
    b      exit

