// Set exit value to a literal number, by jumping to code that
//  invokes sys_exit
.text

.global _start

// Exit the program.
//   The exit code is always 42 
exit:
    mov    %r0, $42    
    mov    %r7, $1     // sys_exit is syscall #1
    swi    $0          // invoke syscall 

_start:
    b      exit
