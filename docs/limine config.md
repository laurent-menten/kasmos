
https://github.com/limine-bootloader/limine/blob/v10.x/CONFIG.md

- **path** - The path of the executable.
- **kernel_path** - Alias of path.
- **module_path** - The path to a module. This option can be specified multiple times to specify multiple modules.
- **module_string** - A string to be associated with a module. This option can also be specified multiple times. It applies to the module described by the last module option specified.
- **module_cmdline** - Alias of module_string.
- **resolution** - The resolution to be used. This setting takes the form of <width>x<height>x<bpp>. If the resolution is not available, Limine will pick another one automatically. Omitting <bpp> will default to 32.
- **kaslr** - For relocatable executables, if set to yes, enable kernel address space layout randomisation. KASLR is disabled by default.
- **randomise_hhdm_base** - If set to yes, randomise the base address of the higher half direct map. If set to no, do not. By default it is yes if KASLR is supported and enabled, else it is no.
- **randomize_hhdm_base** - Alias of randomise_hhdm_base.
- **max_paging_mode**, min_paging_mode - Limit the maximum and minimum paging modes to one of the following:
x86-64 and aarch64: 4level, 5level.
riscv64: sv39, sv48, sv57.
loongarch64: 4level.
- **paging_mode** - Equivalent to setting both max_paging_mode and min_paging_mode to the same value.
- **dtb_path** - A device tree blob to pass instead of the one provided by the firmware.
