.model tiny
.code
org 100h


start: jmp main

main:

        xor ax, ax
        mov es, ax

        mov ax, es:[38]
 
        mov es, ax

        mov es:[296h], 0002h

        mov dx, offset msg_installed
        mov ah, 09h
        int 21h

        mov ax, 4C00h
        int 21h


msg_installed    db 'SUCCESSFULLY INSTALLED$'    

end start