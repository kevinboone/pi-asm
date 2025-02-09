# pi-asm: a set of simple examples for demonstrating ARM assembly language programming on the Raspberry Pi

_Please note that this is a work in progress_.

This series of example demonstrates the essential features of ARM (32-bit)
assembly language programming.  Each example is accompanied by detailed
documentation, which can be seen in <a
href="http://kevinboone.me/pi-asm-00_introduction.html">a series of articles on
my website</a>.

Please note that, since I started writing these examples, two major changes have 
occurred. First, the GNU assembler has changed its default syntax. Second, the
64-bit Linux kernels for ARM no longer work with the 32-bit API. I have started to
convert these examples to the AArch64 API and register set 
-- these are the files whose names end in `_64.as`. I haven't converted them all --
I will do the others if people other than me report success with the first few. 

