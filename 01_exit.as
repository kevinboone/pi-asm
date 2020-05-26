// Set exit value to a literal number, by invoking sys_exit
.text

.global _start

_start:
    mov    %r0, $42    
    mov    %r7, $1     // sys_exit is syscall #1
    swi    $0          // invoke syscall 

