// Set exit value to a specific number, by jumping to code that
//  invokes sys_exit. The exit code is passed in the r0 register
.text

.global _start

// Exit the program.
//   On entry, r0 should hold the exit code
exit:
    mov    %r7, $1     // sys_exit is syscall #1
    swi    $0          // invoke syscall 

_start:
    mov    %r0, $43
    b      exit
