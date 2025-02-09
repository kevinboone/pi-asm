// Set exit value to a literal number, by invoking sys_exit
.text

.global _start

_start:
    mov    x0, 42    
    mov    x8, 93     // sys_exit is syscall 93 
    svc    0          // invoke syscall 

