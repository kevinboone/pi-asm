// Set exit value to a literal number, by jumping to code that
//  invokes sys_exit. The exit code is in the r0 register
// This example illustrate one way to define a constant, to make
//  the code more readble

.text

SYS_EXIT = 1

.global _start

// Exit the program.
//   On entry, r0 should hold the exit code
exit:
    mov    %r7, $SYS_EXIT
    swi    $0

_start:
    mov    %r0, $44
    b      exit
