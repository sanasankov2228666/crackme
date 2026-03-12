.model tiny
.code
org 100h


start: jmp main

password_leight equ 8
max_leight      equ 8

check_password proc

        push bx
        push cx
        push dx
        push bp
        push di

        ; ======= save regs =======

        mov bp, sp
        sub sp, 10

        mov cx, 5         ; counter
        xor ax, ax     

        ; ======== reset memory ========

        sub bp, 2

        clean_loop:
        mov [bp], ax  
        sub bp, 2
        loop clean_loop

        xor di, di

        add bp, 4

        ; ========= loop input password ==========

        loop_cp:

        cmp di, max_leight
        jge end_input       ; if size = 8

        mov ah, 01h         ; symbol input
        int 21h

        cmp al, 8           ; if backspace
        jne not_backspace

        dec di
        dec bp

        jmp loop_cp

        ; ======== if not backspace ========

        not_backspace:

        cmp al, 13              ; if enter
        je end_input            ; end input

        mov [bp], al

        inc di
        inc bp

        jmp loop_cp

        ; ======= end password input =======

        end_input:

        cmp di, password_leight        ; if another size
        jne get_regs

        mov cx, password_leight
        mov bx, offset password

        mov bp, sp
        add bp, 2

        check_loop:

        mov ah, [bx]
        mov al, [bp]

        inc bx
        inc bp
        
        cmp ah, al
        jne get_regs

        loop check_loop

        mov bp, sp
        mov word ptr [bp], 1

        ; ======= get regs ========

        get_regs:

        mov bp, sp
        mov ax, [bp]
        
        add sp, 10

        pop di
        pop bp
        pop dx
        pop cx
        pop bx

        ret

check_password endp

        
main:

        mov dx, offset enter_password
        mov ah, 09h
        int 21h

        call check_password

        cmp ax, 0
        jne correct

        mov dx, offset incorect_password

        jmp end_program

        correct:

        mov dx, offset success

        end_program:

        mov ah, 09h
        int 21h

        mov ax, 4C00h
		int 21h 



; _________________________________________________________________________________________________________________________________________________



; ======================================================================
; 	      		 	            data
; ======================================================================


enter_password db 'enter_password: $'

success db 13, 10, 'success$'

incorect_password db 13, 10, 'incorect password$'

password db '1a2b3c4d'

end start