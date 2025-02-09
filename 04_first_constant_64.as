// Set exit value to a literal number, by jumping to code that
//  invokes sys_exit. The exit code is in the x0 register
// This example illustrate one way to define a constant, to make
//  the code more readble

.text

SYS_EXIT = 93    // syscall code for sys_exit 

.global _start

// Exit the program.
//   On entry, x0 should hold the exit code
exit:
    mov    x8, SYS_EXIT
    svc    0

_start:
    mov    x0, 44
    b      exit
