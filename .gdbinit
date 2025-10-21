set print demangle on
set demangle-style auto
set print asm-demangle on
set print max-symbolic-offset 0
set disassemble-next-line on

define sri
  stepi
  x/i $pc
  info registers rax rbx rcx rdx rsi rdi rbp rsp r8 r9 r10 r11 r12 r13 r14 r15 rip eflags
end
