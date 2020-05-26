// A crude way to implement a modulus operation when the CPU has nothing
//  built in

.text
.align 2

SYS_EXIT = 1
SYS_WRITE = 4
STDOUT = 1

.global _start

/* =========================== exit ========================================*/
// Exit the program.
//   On entry, r0 should hold the exit code
exit:
    mov    %r7, $SYS_EXIT
    swi    $0

/* =========================== mod ==========================================*/
// Calculate the integer remainder after dividing %r0 by %r1. The result is
//  returned in %r0
// The relevant formula is %r0 - (%r1 * (%r0 / %r1)). This works because
//  integer division (sdiv) loses the fraction. It's a bit crude, but
//  easy to understand.
mod:
    push    {r4}
    mov     %r4, %r0
    sdiv    %r0, %r1
    mul     %r0, %r1
    sub     %r4, %r0 
    mov     %r0, %r4
    pop     {r4}

    bx lr


/* =========================== start ========================================*/
_start:
    mov     %r0, $5     // Take the remainder when 5 is divided by 3
    mov     %r1, $3
    bl mod

    // exit
    b       exit        // The result is in %r0, which becomes the exit code




