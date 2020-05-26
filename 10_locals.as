// This example demonstrates how to store a function's local data in 
//  a stack frame

.section .rodata 
EOL:
    .ascii "\n\0"

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

/* =========================== test  ========================================*/
// This function writes "OK" by generating the character data in a memory
//  area reserved on the stack, then calling print_str on it

TEST_LOCAL = 8             // How much data to reserve on the stack - 8 bytes
test:
    push   {r0, r1, fp, lr} // Store the registers we will overwrite
    sub    sp, $TEST_LOCAL  // Move the stack _down_ to allow for our data

    mov    %fp, %sp         // %fp will reference the start of our 8-byte area

    mov    %r1, %fp         // Use %r1 to count the position we are writing
    mov    %r0, $79         // Store 'O' (char 79)  
    strb   %r0,[%r1]        // Set the 'O' to memory in the stack
    add    %r1, $1          // And increment the offset by one byte
    mov    %r0, $75         // Store 'K' (char 75)
    strb   %r0,[%r1]        // set the 'K' to memory in the stack
    add    %r1, $1          // And increment the offset again
    mov    %r0, $0          // Store the terminating null character
    strb   %r0,[%r1]        // And write it out

    mov    %r0, %fp         // print_str needs an address in %r0, so copy fp
    bl     print_str        // Print the string
   

    add    sp, $TEST_LOCAL  // Move the stack pointer over our data area
    pop    {r0, r1, fp, lr} // and restore the registers
    bx     lr


/* =========================== start ========================================*/
_start:
    bl     test 
    ldr    %r0, =EOL        // Print a newline, to make the output clearer
    bl     print_str

    // exit
    mov    %r0, $0
    b      exit




