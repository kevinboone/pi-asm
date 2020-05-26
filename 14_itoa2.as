// This example implements an integer-to-ASCII method that works in memory,
//  handles negative numbers and (unlike the previous attempt) writes
//  its digits in the correct order.

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


/* =========================== itoa2 ========================================*/
// A better attempt at an itoa function. This version takes two arguments:
//   %r0 - the number to be converted
//   %r1 - address to store resulting digits
// This version also copes with negative numbers. It uses the reverse
//   function from the previous example to put the digits (and the sign)
//   in the proper order.

itoa2:
    push   {r0-r5, lr}

    mov    %r4, $0    // %r4 will remember whether the supplied number
                      //   was negative 
    mov    %r3, %r1   // %r3 contains the address to store the data,
                      //  originally passed in r1
    mov    %r5, %r1   // So does %r5. %r3 will be incremented when building
                      //  the number, so we need to track the original
                      //  start address when it comes time to reverse
                      //  the digits.

    mov    %r2, %r0   // Keep the running total in %r2
    mov    %r1, $10   // Keep the const 10 in r1

    cmp    %r0, $0    // Is the number to be converted less than zero?
    bge    itoa2_loop // If it isn't, skip the negation step

    neg    %r2, %r2   // If we have a negative number, make it positive 
    mov    %r4, $1    //   ... and keep track of the fact it was negative

itoa2_loop:
  
    mov    %r0, %r2
    bl     mod         // Divide running total by 10. mod is now in %r0

    add    %r0, $48    // Add '0' to make the number into an ASCII digit
    strb   %r0, [%r3]  // Store the digit at the address in %r3 
    add    %r3, $1     //   ... and then increment %r3 for the next digit

    sdiv   %r2, %r1    // Divide the running total by 10 
    cmp    %r2, $0     // If there's anything left, repeat the division
    bne    itoa2_loop    

    cmp    %r4, $1     // If %r4 = 1, we started with a negative number...
    bne    itoa2_pos

    mov    %r0, $45    //  ... so store a negative sign (char 45)
    strb   %r0, [%r3]  //  ... at the position %r3 now points
    add    %r3, $1     //  ... and increment %r3 so we can...
itoa2_pos:

    mov    %r0, $0     // Store a null to finish the number string
    strb   %r0, [%r3] 

    mov    %r0, %r5   
    bl     reverse     // Reverse the digits, including the sign. This is
                       //  why we wrote the sign on the end of the number.

    pop    {r0-r5, lr}
    bx     lr


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

/* =========================== print_num ====================================*/
print_num:
PRINTNUM_LOCAL = 16             // Allow space for the largest number,
                                //  plus the minus sign, plus the null;
                                //  Round up to nearest 8 bytes

    push   {r0, r1, fp, lr}     // Store the registers we will overwrite
    sub    sp, $PRINTNUM_LOCAL  // Move the stack _down_ to allow for our data
    mov    %fp, %sp             // %fp references the start of our work area

    mov    %r1, %fp             // For call to itoa2 we need:
    bl     itoa2                //   %r0 = number, %r1 = work area

    mov    %r0, %fp             // Set %r0 to point to the converted number
    bl     print_str            // Print it

    add    sp, $PRINTNUM_LOCAL  // Move the stack pointer over our data area
    pop    {r0, r1, fp, lr}     // and restore the registers
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
    strb   %r0,[%r1]        // Set the 'O' to memory in the stack
    add    %r1, $1          // And increment the offset by one byte
    mov    %r0, $0          // Store the terminating null character
    strb   %r0,[%r1]        // And write it out

    mov    %r0, %fp         // print_str needs an address in %r0, to copy
    bl     print_str        // Print the string

    add    sp, $PUTCHAR_LOCAL  // Move the stack pointer over our data area
    pop    {r0, r1, fp, lr} // and restore the registers
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
    sub    %r5, $1       // %r5 points to the ends of the string

    lsr    %r0, $1       // Divide by two
    mov    %r2, %r0      // %r2 now holds the loop count
    
reverse_loop:            // Repeat the swap, working from the ends inward

    ldrb   %r0, [%r4]    // Read the end characters into %r0 and %r1 
    ldrb   %r1, [%r5] 
    mov    %r3, %r1
    strb   %r3, [%r4]    // Store the reverse end characters
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
   pop    {r4-r5,lr}  // Restore the temporary registers and LR
   bx     lr


/* =========================== start ========================================*/
_start:
    ldr    %r0, =12345      // Number to be converted goes in %r0
    bl     print_num        // Print it 

    ldr    %r0, =EOL        // Print a newline, to make the output clearer
    bl     print_str

    ldr    %r0, =-32720     // Let's try a negative number 
    bl     print_num        // Print it 

    ldr    %r0, =EOL        // Print a newline
    bl     print_str

    // exit
    mov    %r0, $0
    b      exit

