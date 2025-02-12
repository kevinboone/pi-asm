// This example demonstrates nested function calls. The function 
//   print_str calls the function strlen to work out the length of
//   the string it was passed. 

.section .rodata 
msg1:
    .ascii "This is string 1\n\0"
.align 2
msg2:
    .ascii "This is string 2\n\0"

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

    sub      sp, sp, #32
    stp      x4, x5, [sp] 
    stp      x5, x30, [sp, #16] 

    mov      x4, 0        // Use x4 as the character count; initially 0
strlen_0:
    mov      x5, 0
    ldrb     w5,[x0]      // Read into w5 the value in memory location x0
    cmp      w5, 0        // Compare to zero, the end-of-line terminator
    beq      strlen_1     // If it's equal to zero, jump out of loop
    add      x0, x0, 1    // If not zero, add one to the character count...
    add      x4, x4, 1    //   and to the address we are looking at
    b        strlen_0     // Then do the loop again
strlen_1:
    mov      x0, x4       // Transfer the character count to x0 for return 

    ldp      x4, x5, [sp] 
    ldp      x5, x30, [sp, #16] 
    add      sp, sp, #32

    ret 

/* ======================== print_str =======================================*/

// Prints to stdout the text whose address is in the x0 register. The
//  text should be null-terminated
print_str:
    // Store x2-x8 and the LR on the stack
    sub      sp, sp, #64  
    stp      x2, x3, [sp] 
    stp      x4, x5, [sp, #16] 
    stp      x6, x7, [sp, #32]
    stp      x8, x30, [sp, #48]

    mov      x5, x0     // Save string address in x5
    bl       strlen     // Get the length in x0
    mov      x2, x0     // Transfer length to x2
  
    mov      x8, SYS_WRITE
    mov      x1, x5          // Address is in x5
    mov      x0, STDOUT
    mov      x8, SYS_WRITE

    svc      0

    // Restore x2-x8 and the LR from the stack
    ldp      x2, x3, [sp] 
    ldp      x4, x5, [sp, #16] 
    ldp      x6, x7, [sp, #32] 
    ldp      x8, x30, [sp, #48] 
    add      sp, sp, #64  

    ret

/* =========================== start ========================================*/
_start:
    // Print msg1
    ldr      x0, =msg1
    bl       print_str

    // Print msg2
    ldr      x0, =msg2
    bl       print_str

    // Now exit
    mov      x0, 0
    b        exit

