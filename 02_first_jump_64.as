// Set exit value to a literal number, by jumping to code that
//  invokes sys_exit
.text

.global _start

// Exit the program.
//   The exit code is always 42 
exit:
    mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

_start:
    b      exit
