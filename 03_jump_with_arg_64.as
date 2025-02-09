// Set exit value to a specific number, by jumping to code that
//  invokes sys_exit. The exit code is passed in the x0 register
.text

.global _start

// Exit the program.
//   On entry, x0 should hold the exit code
exit:
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

_start:
    mov    x0, 43
    b      exit
