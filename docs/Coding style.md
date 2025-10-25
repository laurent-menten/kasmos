
Libraries include file should be splitted:
- *\<name\>_def.inc* for the structures, macros and other definitions, to be used by the library code internally.
- *\<name\>.inc* that included *\<name\>_def.inc* and declare the externs, to be used by kernel code.

Every *\*.inc* file should be guarded with a ifndef/endif construction where \<name\> reflect the file name:

```asm
%ifndef __<name>_INC__
%define __<name>_INC__

; ...

%endif ;__<name>_INC__
```
