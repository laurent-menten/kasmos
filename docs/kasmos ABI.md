# Registers usage

## Kernel

- **gs:** thread_control_block (kernel)
- **fs:** cpu_control_block

## User

- **gs:** thread_control_block (user)
- **fs:** /

# Calling convention

The called routine is responsible for preserving every register it uses unless it will contain a return value.

RFlags should be preserved when non conditions flags are modified (DF, IF etc.). Exception is made for specific system control routines.

- **rsp** and **rbp** are used for accessing the stack.
- **rax** is used for primary value.
- **rbx** and **rdx** are used for secondary values.
- **rcx** is used where ever a counter is required.
- **rsi** and **rdi** are used for pointer (source / destination).
- **r8** .. **r14** are have no conventional usage.

- **rax** is the dedicated register for primary return value or a return code.
- Secondary return values should be written using pointers

Only variadic routine will used the stack for arguments passing and only for the optional arguments. In this case, **rcx** is expected to contain the count of arguments. Stack cleanup is the responsability of the caller.


- **r15** is always used as the pointer to the lock structure for concurrency functions
