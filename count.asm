; count.asm
;
; Goal:
;   build the lightest container image who print numbers for 1 to 100000 in stdout with line return between each
;
; Current builded image size: 146 B
;
; Build cmd:
;   nasm -f bin -o count count.asm
;
; Author: Etienne Sellan



; Below an hardcoded ELF header to avoid huge header generated by ld/gcc

BITS 32
  org     0x08048000

ehdr:                                                 ; Elf32_Ehdr
              db      0x7F, "ELF", 1, 1, 1, 0         ;   e_ident
  times   8   db      0
              dw      2                               ;   e_type
              dw      3                               ;   e_machine
              dd      1                               ;   e_version
              dd      _start                          ;   e_entry
              dd      phdr - $$                       ;   e_phoff
              dd      0                               ;   e_shoff
              dd      0                               ;   e_flags
              dw      ehdrsize                        ;   e_ehsize
              dw      phdrsize                        ;   e_phentsize
              dw      1                               ;   e_phnum
              dw      0                               ;   e_shentsize
              dw      0                               ;   e_shnum
              dw      0                               ;   e_shstrndx

ehdrsize      equ     $ - ehdr

phdr:                                                 ; Elf32_Phdr
              dd      1                               ;   p_type
              dd      0                               ;   p_offset
              dd      $$                              ;   p_vaddr
              dd      $$                              ;   p_paddr
              dd      filesize                        ;   p_filesz
              dd      filesize                        ;   p_memsz
              dd      5                               ;   p_flags
              dd      0x1000                          ;   p_align

phdrsize      equ     $ - phdr

; Program begin

_start:
  push  eax           ; Store count
  call  print_int     ; Print current count
  xor   edx,edx       ; Clear edx register
  pop   eax           ; Retreive current count
  inc   eax           ; Add +1 to the count
  cmp   eax,100000    ; Check if count > 100000
  jl   _start         ; Continue loop if < 100000

print_int:
  mov   ebx,10        ; Store 10 (divider)
  push  -99           ; Add delimiter for the end of the current number
  push  -38           ; Add line return as digit (48 = first ascii digit, 10 = line return, so 38 before first ascii digit)

  divide:             ; Divide number to print, until < 10
    div   ebx         ; Divide
    push  edx         ; Store rest (as digit of full number)
    xor   edx,edx     ; Clear rest
    cmp   eax,ebx     ; Check if >= 10
    jge   divide      ; Continue to divide if >= 10
   
  print_stack:
    add   eax,48      ; Raw digit to ascii char code
    push  eax         ; Store char
    mov   ecx,esp     ; Store stack pointer (used for sys_write)
    mov   eax,4       ; Sys_write
    xor   ebx,ebx     ; Clear ebx register     \______ these two lines can be replaced by "mov ebx,1" shorter but hevier
    inc   ebx         ; Set 1 to choose stdout /
    xor   edx,edx     ; Clear edx register          \______ these two lines can be replaced by "mov edx,1" shorter but hevier
    inc   edx         ; Set 1 cause we print 1 char /
    int   80h         ; Call sys_write
    pop   eax         ; Retreive stored char
    pop   eax         ; Get next raw digit
    cmp   eax,-99     ; Check if it's the end delimiter
    jg print_stack    ; Continue if it's not the end of number
  ret

filesize      equ     $ - $$