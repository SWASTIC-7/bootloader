org 0x7C00
bits 16

jmp short main
nop

bdb_oem: db "MSWIN4.1"
bdb_bytes_per_sector: dw 512
bdb_sectors_per_cluster: db 1
bdb_reserved_sectors: dw 1
bdb_number_of_fats: db 2
bdb_root_entries: dw 224
bdb_dir_entries_count: dw 0E0h
bdb_total_sectors: dw 2880
bdb_media_descriptor: db 0xF0
bdb_sectors_per_fat: dw 9
bdb_sectors_per_track: dw 18
bdb_number_of_heads: dw 2
bdb_hidden_sectors: dd 0
bdb_large_sector_count: dd 0

ebr_drive_number: db 0
ebr_signature: db 0x29
ebr_volume_id: dd 0x12345678
ebr_volume_label: db "HELLO OS   "
ebr_file_system: db "FAT12   "



main:
    mov ax,0   ;set up data segments
    mov ds,ax  ;destination segment
    mov es,ax  ;extra segment
    mov ss,ax  ;stack segment

    mov sp,0x7C00  ;stack pointer

    mov [ebr_drive_number], dl
    mov ax, 1
    mov cl, 1
    mov bx, 0x7E00
    call disk_read
    
    mov si,print_message   
    call print
    HLT

halt:
    JMP halt

; **********************************************
; Disk reading
; **********************************************
disk_read:
    push ax
    push bx
    push cx
    push dx
    push di

    call lba_to_chs


    mov ah, 0x02
    mov di, 3
    

retry:
    stc 
    int 0x13    
    jnc done_read

    call disk_reset
    dec di
    test di,di
    jnz retry

done_read:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret


disk_read_fail:
    mov si, disk_read_fail_message
    call print
    HLT
    jmp halt

disk_reset:
    pusha
    mov ah, 0
    stc
    int 0x13
    jc disk_read_fail
    popa
     
lba_to_chs:
    push ax
    push bx
    xor dx,dx
    div word [bdb_sectors_per_track]
    inc dx                         ; storing sector number
    mov cx,dx

    

    xor dx,dx
    div word [bdb_number_of_heads]

    mov dh,dl                       ; storing head number
    mov ch,al   
    shl ah, 6
    or cl,ah                      ; storing cylinder number

    pop ax
    mov dl,al
    pop ax

    ret



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
disk_read_fail_message: DB "Disk read failed!",0x0D,0x0A,0
times 510 - ($-$$) DB 0
DW 0AA55h