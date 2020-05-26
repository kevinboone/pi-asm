// This example demonstrates nested function calls. The function 
//   print_str calls the function strlen to work out the length of
//   the string it was passed. 

.section .rodata 
msg1:
    .ascii "String 1\n\0"
.align 2
msg2:
    .ascii "String 2\n\0"

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
   push {r4-r5,lr} // Save the values of %r4 and %r5, and the LR 
   mov %r4, $0     // Use %r4 as the character count; initially 0
strlen_0:
   ldrb  %r5,[r0]  // Read into %r5 the value in memory location %r0
   cmp %r5, #0     // Compare to zero, the end-of-line terminator
   beq strlen_1    // If it's equal to zero, jump out of loop
   add %r0, $1     // If not zero, add one to the character count...
   add %r4, $1     //   and to the address we are looking at
   b strlen_0      // Then do the loop again
strlen_1:
   mov    %r0, %r4 // Transfer the character count to %r0 for return 
   pop {r4-r5,lr}  // Restore the temporary registers and LR
   bx     lr

/* ======================== print_str =======================================*/
// Prints to stdout the text whose address is in the r0 register. The
//  text should be null-terminated
print_str:
    push   {r2-r7, lr}

    mov    %r5, %r0   // Save string address in %r5
    bl     strlen     // Get the length in %r0
    mov    %r2, %r0   // Transfer length to %r2
  
    mov    %r7, $SYS_WRITE
    mov    %r1, %r5  // Address is in r5
    mov    %r0, $STDOUT

    swi    $0

    pop    {r2-r7, lr}  
    bx     lr


/* =========================== start ========================================*/
_start:
    // Print msg1
    ldr    %r0, =msg1
    bl     print_str

    // Print msg2
    ldr    %r0, =msg2
    bl     print_str

    // Now exit
    mov    %r0, $0
    b      exit

