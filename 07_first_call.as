// This example demonstrates how to implement a function (subroutine) 
//  call called 'strlen' that returns the length of a text string in 
//  bytes. The actual implementation is stubbed out -- we will implement
//  the logic later 

.section .rodata 
msg:
    .ascii "Hello, World\n\0"

.text
.align 2

SYS_EXIT = 1
SYS_WRITE = 4
STDOUT = 1

.global _start

// Exit the program.
//   On entry to exit, r0 should hold the exit code
exit:
    mov    %r7, $SYS_EXIT
    swi    $0

// Calulate the length of a null-terminated string
//   On entry, r0 is the address of the string
//   On exit, r0 is the length of the string, not including
//   the terminating null
strlen:
   ldr    %r0, =10 // 10 is a dummy value. We will calculate it 
                   //  in the next example
   bx     lr

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

