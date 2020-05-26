// Outputs a simple message using sys_write 
 
.text

SYS_EXIT = 1
SYS_WRITE = 4
STDOUT = 1

.global _start

// Exit the program.
//   On entry, r0 should hold the exit code
exit:
    mov    %r7, $SYS_EXIT
    swi    $0

_start:
    // Use the sys_write syscall to output a string
    mov    %r7, $SYS_WRITE
    mov    %r0, $STDOUT
    ldr    %r1, =msg // Store the address of the message in r1
    mov    %r2, $13  // Store the length of the message in r2
    swi    $0

    // Now exit
    mov    %r0, $0
    b      exit

msg:
    .ascii "Hello, World\n"


