// This example demonstrates how to implement a function (subroutine) 
//  call called 'strlen' that returns the length of a text string in 
//  bytes. 

.section .rodata 
msg:
    .ascii "Hello, World\n\0"

.text
.align 2

SYS_EXIT = 1
SYS_WRITE = 4
STDOUT = 1

.global _start

/* =========================== exit ========================================*/
// Exit the program.
//   On entry, r0 should hold the exit code
exit:
    mov    %r7, $SYS_EXIT
    swi    $0

/* =========================== strlen ======================================*/
// Calulate the length of a null-terminated string
//   On entry, r0 is the address of the string
//   On exit, r0 is the length of the string, not including
//   the terminating null
strlen:
   push     {r4-r5}    // Save the values of %r4 and %r5, which we will use
   mov      %r4, $0    // Use %r4 as the character count; initially 0
strlen_0:
   ldrb     %r5,[r0]   // Read into %r5 the value in memory location %r0
   cmp      %r5, #0    // Compare to zero, the end-of-line terminator
   beq      strlen_1   // If it's equal to zero, jump out of loop
   add      %r0, $1    // If not zero, add one to the character count...
   add      %r4, $1    //   and to the address we are looking at
   b        strlen_0   // Then do the loop again
strlen_1:
   mov      %r0, %r4   // Transfer the character count to %r0 for return 
   pop      {r4-r5}    // Restore the temporary registers 
   bx       lr

/* =========================== start ========================================*/
_start:
    ldr    %r0, =msg
    bl     strlen 
    // Length of string is now in %r0

    // Use the sys_write syscall to output a string
    mov    %r2, %r0  // Transfer length of the message from r0 to r2
    mov    %r7, $SYS_WRITE
    mov    %r0, $STDOUT
    ldr    %r1, =msg // Store the address of the message in r1
    swi    $0

    // Now exit
    mov    %r0, $0
    b      exit

