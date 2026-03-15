.model tiny
.code
org 100h


start: jmp main

password_leight equ 8

; ____________________________________________________________________________________________________________________________________


; ======================  input_password (void) ======================
;                       
; 	entery:    void
; 	exit:      ax - checking password flag                                   
; 	expected:  ---
;	destr:     ax, bx, cx, dx, di
;
; ====================================================================

input_password proc

        push bx
        push cx
        push di

        ; ======= save regs =======

        mov bx, offset user_password
        xor di, di

        ; ========= loop input password ==========

        loop_ip:

        cmp di, 8
        jg get_regs         ; if size = 8

        mov ah, 01h         ; symbol input
        int 21h

        cmp al, 8           ; if backspace
        jne not_backspace

        cmp di, 0           ; if password empty symbols
        je loop_ip

        dec di
        dec bx

        jmp loop_ip

        ; ======== if not backspace ========

        not_backspace:

        ; cmp al, ' '            ; if space
        ; jne not_space

        ; inc di
        ; jmp loop_ip

        ; not_space:

        cmp al, 13             ; if enter
        je get_regs            ; end input

        mov [bx], al

        inc di
        inc bx

        jmp loop_ip

        ; ======= get regs ========

        get_regs:

        pop di
        pop cx
        pop bx

        ret

input_password endp


; ____________________________________________________________________________________________________________________________________


; ======================  check_password (void) ======================
;                       
; 	entery:    void
; 	exit:      ax - checking password flag                                   
; 	expected:  ---
;	destr:     ax, bx, cx, di
;
; ====================================================================

check_password proc

        push ax
        push bx
        push cx
        push di

        ; ======= save regs =======

        mov bx, offset user_password
        mov di, offset password
        mov cx, 8

        ; ======== loop =======

        loop_cp:

        cmp cx, 0
        je end_loop_cp

        mov al, [bx]
        xor al, 3fh

        cmp al, [di]
        jne end_check
        
        inc di
        inc bx
        dec cx

        jmp loop_cp

        ; ======== end loop =======

        end_loop_cp:

        mov bx, offset correct_flag
        mov byte ptr [bx], 1

        ; ======= get regs ========

        end_check:

        pop di
        pop cx
        pop bx
        pop ax

        ret

check_password endp

; _______________________________________________________________________________________________________________________________________
      

main:

        mov dx, offset enter_password
        mov ah, 09h
        int 21h

        call input_password
        call check_password

        mov bx, offset correct_flag

        cmp byte ptr [bx], 1
        je correct

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
; 	      		 	   data
; ======================================================================

user_password db 8 dup (0)

correct_flag db 0

password db 0eh, 5eh, 0dh, 5dh, 0ch, 5ch, 0bh, 5bh

enter_password db 'enter password: $'

success db 13, 10, 'success$'

incorect_password db 13, 10, 'incorect password$'

end start