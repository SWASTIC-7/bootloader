org 0x7C00
bits 16

main:
    mov ax,0   ;set up data segments
    mov ds,ax  ;destination segment
    mov es,ax  ;extra segment
    mov ss,ax  ;stack segment

    mov sp,0x7C00  ;stack pointer
    mov si,print_message   
    call print
    HLT

halt:
    JMP halt

print:
    push si
    push ax
    push bx

print_loop:
    lodsb
    or al,al
    jz print_done

    mov ah,0x0E
    mov bh, 0
    int 0x10
    jmp print_loop
    
print_done:
    pop bx
    pop ax
    pop si
    ret

print_message: DB "Hello, World!",0x0D,0x0A,0

times 510 - ($-$$) DB 0
DW 0AA55h