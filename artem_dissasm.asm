.model tiny
.code
org 100h


; 1.) 11111111111w+esc
; 2.) true sum = 176, ae


start: jmp main

main:

        xor     ax, ax
        mov     es, ax          ; es = 0

        mov     bx, 24h
        xor     si, si

        mov     ax, es:[bx]
        mov     cs:[si+28Eh], ax          ; save old offset

        mov     ax, es:[bx + 2]
        mov     cs:[si + 290h], ax        ; save old segment

        mov     word ptr es:[bx], new_int_9h      ; set new 09h ofs
        mov     word ptr es:[bx + 2], cs          ; set new 09h seg

        mov     si, 6
        mov     word ptr cs:[si + 28Eh], 0Ah      ; data letter number - 10

        add     si, 2                             ; data 2
        mov     bx, 0B0h
        mov     cs:[si + 28Eh], bx                ; data 3

        mov     si, 20h                           ; data 4
        mov     bx, 9111h
        mov     cs:[si + 28Eh], bx

        mov     dx, 2BEh                        ; dx = end code
        add     dx, 22h
        shr     dx, 4                           ; paragraph
        inc     dx                              ; allocate memory for

        mov     ax, 3100h                       ; make tsr
        int     21h 

start endp

; _______________________________________________________________________________________________________________________________________
;						
;					           =========== INTERAPT 09h changed==========
;
; _______________________________________________________________________________________________________________________________________



; ========================  new_int_9h (void) ========================
;                       
; 	entery:    void
; 	exit:      ---                                    
; 	expected:  ---
;	destr:     ax, di, bp, ds, cs
;
; ====================================================================


new_int_9h proc

        push    ax
        push    bx
        push    dx
        push    si
        
        push    es 

        ; ========= save regs ==========

        mov     si, 20h
        mov     ax, cs:[si+28Eh]        ; ax = buffer [si = 20h]
        mov     dx, 9111h               ; canary

        cmp     dx, ax                  ; check if changed canary
        jne     incorect

        xor     ax, ax          ; ax = 0

        in      al, 60h         ; take from port
        mov     si, 1Ch
        cmp     si, ax          ; if enter
        je      enter

        ; jmp     loc_201

        ; loc_201:

        mov     bx, 6                  
        mov     si, cs:[bx + 28Eh]      ; si = buffer[6] = next place
        mov     cs:[si + 28Eh], al      ; buffer[si] = new symbol
        add     si, 1                   ; si ++
        mov     cs:[bx + 28Eh], si      ; put next adres

        ; jmp     default_way

        ; default_way:

        in      al, 61h             ; process interapt
        or      al, 80h

        out     61h, al
        and     al, 7Fh
        out     61h, al
        mov     al, 20h
        out     20h, al             ; EOI put

        pop     es
        pop     si
        pop     dx
        pop     bx
        pop     ax

        push    si

        xor     si, si
        mov     bx, cs:[si+28Eh]        ; offset  old 09h
        mov     dx, cs:[si+290h]        ; segment old 09h

        pop     si

        push    dx                      
        push    bx                      ; push ret adres

        retf                            ; jump on old 09h

        ; ======== if enter =======

        enter:

        call    check_password          ; check password

        xor     bx, bx
        xor     ax, ax

        mov     si, 22h                 ; true flag
        mov     bl, cs:[si+28Eh]
        mov     al, 1  
        cmp     bl, al                  ; if flag = 1
        je      correct

        incorect:

        mov     ax, 0B800h
        mov     es, ax          ; es = VRAM 

        mov     bx, 3E8h
        mov     word ptr es:[bx], 4768h             ; h
        mov     word ptr es:[bx+2], 4761h           ; a
        mov     word ptr es:[bx+6], 476Ch           ; l
        mov     word ptr es:[bx+8], 476Fh           ; o
        mov     word ptr es:[bx+0Ah], 4768h         ; h

        jmp     end_enter

        correct:

        mov     ax, 0B800h
        mov     es, ax          ; es = VRAM 

        mov     bx, 3E8h
        mov     word ptr es:[bx], 2773h             ; s
        mov     word ptr es:[bx+2], 2775h           ; u
        mov     word ptr es:[bx+4], 2763h           ; c
        mov     word ptr es:[bx+6], 2763h           ; c
        mov     word ptr es:[bx+8], 2765h           ; e
        mov     word ptr es:[bx+0Ah], 2773h         ; s
        mov     word ptr es:[bx+0Ch], 2773h         ; s

        jmp     end_enter
        

        end_enter:

        in      al, 61h             ; process interapt
        or      al, 80h
        out     61h, al
        and     al, 7Fh
        out     61h, al
        mov     al, 20h
        out     20h, al             ; EOI

        ; ========== get regs ===========

        pop     es

        pop     si
        pop     dx
        pop     bx
        pop     ax

        iret

new_int_9h endp


; =============================  func (void) ========================
;                       
; 	entery:    void
; 	exit:      ax - checking password flag                                   
; 	expected:  ---
;	destr:     ax, bx, cx, dx, di
;
; ====================================================================


check_password proc 

        push    ax
        push    si
        push    bx
        push    dx
        push    di
        push    es

        ; ======= save regs ========

        mov     bx, 6
        mov     si, cs:[bx+28Eh]        ; si = len 
        mov     bx, 0Ah

        xor     dx, dx                  ; dx = 0
        xor     ax, ax                  ; ax = 0

        ; ========= loop =========

        loop_cp:

        mov     al, cs:[bx+28Eh]
        add     dx, ax
        add     bx, 2                   ; skip scan not pressed scan codes
        cmp     bx, si
        jb      loop_cp

        ; ======= end loop =======

        mov     bx, 8                   ; true sum adres
        mov     ax, cs:[bx+28Eh]        ; ax = password
        cmp     dx, ax                  
        jne     get_regs                ; if different

        ; ========= true =========

        mov     bx, 22h
        xor     ax, ax
        mov     al, 1
        mov     cs:[bx+28Eh], al

        ; jmp     get_regs

        ; ======== get regs ======== 

        get_regs:

        pop     es
        pop     di
        pop     dx
        pop     bx
        pop     si
        pop     ax

        retn

check_password endp


buffer db 36 dup (0)    ; buffer with data

end:

end start