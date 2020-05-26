// This example demonstrates how to reverse the characters of a 
//  null-terminated string, but swapping the characters at the ends
//  and then moving inwards. This process avoids the need to allocate
//  any temporary memory for the operation. 

// NOTE .data, not .rodata
.section .data 
EOL:
    .asciz "\n"
.align 2
msg:
    .asciz "Hello, World"

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

/* =========================== reverse =====================================*/
// Reverse the bytes in the string whose address is in %r0. If the string is
//  less than two bytes long, no change is made (but it is safe to call
//  the function). 
reverse:
    push   {r0-r5,lr}

    mov    %r4, %r0     // %r4 points to the start of the string 
    mov    %r5, %r0     // So does %r5, for now
    bl     strlen       // Get the string length in %r0


    cmp    %r0,$1       // Compare the length with 1
    bls    reverse_done // "Branch if Less or Same" to end of function

    add    %r5, %r0   
    sub    %r5, $1       // %r5 points to the end of the string

    lsr    %r0, $1       // Divide by two
    mov    %r2, %r0      // %r2 now holds the loop count
    
reverse_loop:            // Repeat the swap, working from the ends inward

    ldrb   %r0, [%r4]    // Read the end characters into %r0 and %r1 
    ldrb   %r1, [%r5] 
    mov    %r3, %r1
    strb   %r3, [%r4]    // Store the swapped end characters
    strb   %r0, [%r5]
    add    %r4, $1       // Move the pointers inwards
    sub    %r5, $1

    sub    %r2, $1       // Decrement the loop counter %r2
    cmp    %r2, $0       //   ... and repeat if it is not yet zero
    bne    reverse_loop

reverse_done:
    pop    {r0-r5,lr}
    bx     lr

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


/* =========================== start ========================================*/
_start:
    ldr    %r0, =msg 
    bl     reverse 
    bl     print_str   

    ldr    %r0, =EOL        // Print a newline, to make the output clearer
    bl     print_str

    // exit
    mov    %r0, $0
    b      exit


