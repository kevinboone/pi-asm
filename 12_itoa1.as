// First attempt at writing a number as ASCII -- this example does the
//  conversion by repeated division by 10, and writes out the digits
//  in reverse order (that is, the order the arithmetic provides them). 
// We define a function called putchar to output the individual characters. 
// Note that the itoa1 function in this example cannot cope with 
//  negative numbers

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

/* =========================== mod ==========================================*/
// Calculate the integer remainder of dividing %r0 by %r1. The result is
//  returned in %r0
// The relevant formula is %r0 - (%r1 * (%r0 / %r1)). This works because
//  integer division (sdiv) loses the fraction. It's a bit crude, but
//  easy to understand.
mod:
    push    {r4}
    mov     %r4, %r0
    sdiv    %r0, %r1
    mul     %r0, %r1
    sub     %r4, %r0 
    mov     %r0, %r4
    pop     {r4}

    bx lr

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

/* =========================== putchar  =====================================*/
// Write to standard output the character in %r0. The sys_write function
//  requires an address in memory, not a register value. So we need somehow
//  to store the %r0 value locally before it can be displayed.
putchar:

PUTCHAR_LOCAL = 8           // How much data to reserve on the stack - 8 bytes
    push   {r0, r1, fp, lr} // Store the registers we will overwrite
    sub    sp, $PUTCHAR_LOCAL  // Move the stack _down_ to allow for our data

    mov    %fp, %sp         // %fp will reference the start of our 8-byte area

    mov    %r1, %fp         // Use %r1 to count the position we are writing
    strb   %r0,[%r1]        // Set the character to memory in the stack
    add    %r1, $1          // And increment the offset by one byte
    mov    %r0, $0          // Store the terminating null character
    strb   %r0,[%r1]        // And write it out

    mov    %r0, %fp         // print_str needs an address in %r0
    bl     print_str        // Print the string

    add    sp, $PUTCHAR_LOCAL  // Move the stack pointer over our data area
    pop    {r0, r1, fp, lr} // and restore the registers
    bx     lr
  

/* =========================== itoa1 ========================================*/
//  Outputs the integer as ASCII digits in reverse order, because that's
//   easiest at this stage.
itoa1:
    push   {r0-r2, lr}
    mov    %r2, %r0   // Keep the running total in %r2
    mov    %r1, $10   // Keep the const 10 in r1

itoa_loop:
  
    mov    %r0, %r2
    bl     mod         // Divide running total by 10; remainder left in %r0

    add    %r0, $48    // Add '0' to make the number into an ASCII digit
    bl     putchar     // Print the digit

    sdiv   %r2, %r1    // Divide the running total by 10 
    cmp    %r2, $0     // If there's anything left, repeat the division
    bne    itoa_loop    

    pop    {r0-r2, lr}
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
    mov    %r0, $12345      // Number to be converted goes in %r0
    bl     itoa1            // Convert it

    ldr    %r0, =EOL        // Print a newline, to make the output clearer
    bl     print_str

    // exit
    mov    %r0, $0
    b      exit


