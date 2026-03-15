.model tiny
.code
org 100h


start: jmp main


; _______________________________________________________________________________________________________________________________________
;						
;					              =========== INTERAPT 08h changed==========
;
; _______________________________________________________________________________________________________________________________________



; ======================  compare_intr (void) ========================
;                       
; 	entery:    void
; 	exit:      ---                                    
; 	expected:  ---
;	destr:     ax, di, bp, ds, cs
;
; ===================================================================

compare_intr proc

        push ax
        push ds

        mov ax, cs
        mov ds, ax

        cmp flag, 1
        jne skip_timer_hack

        mov di, 1 

        skip_timer_hack:

        pop ds
        pop ax

        jmp dword ptr cs:[old_ofs_08h]

compare_intr endp




; _______________________________________________________________________________________________________________________________________
;						
;					              =========== INTERAPT 09h changed==========
;
; _______________________________________________________________________________________________________________________________________


; ======================  my_interapt (void) ========================
;                       
; 	entery:    void
; 	exit:      ---                                    
; 	expected:  ---
;	destr:     ax, bx, ds, es
;
; ==================================================================

my_interapt proc
		
		; ======== save registers ========
	
		push bx
		push ax

		push ds
		push es

		; ====== saving regs before interapt =======		

		mov ax, cs
		mov ds, ax								; put ds = cs

		in al, 60h					
		
		cmp al, 4								; if button not ( 6 - open or close window )
		jne default_way

		; ========== if 6 pressed ===========

        mov bx, offset flag
        xor byte ptr [bx], 1

		; ======== proccesing interapt =========

		proces_interapt:

		in  al, 61h
		or  al, 80h
		out 61h, al
		and al, not 80h
		out 61h, al

		mov al, 20h
		out 20h, al

		pop es
		pop ds

		pop ax
		pop bx
	
		iret

		; ========= get registers =========
		
		default_way:

		pop es
		pop ds

		pop ax
		pop bx

		; ======= go to old 09h ========= 

		jmp dword ptr cs:[old_ofs_09h]

my_interapt endp


; _________________________________________________________________________________________________________________________________________________


; ======================================================================
;                                 main
; ======================================================================

main:

        xor ax, ax
        mov es, ax

        mov bx, 36
        mov ax, es:[bx]
        cmp ax, offset my_interapt
        jne install

        mov dx, offset msg_already
        mov ah, 09h
        int 21h
        mov ax, 4C00h
        int 21h

        install:
        mov ax, es:[32]
        mov [old_ofs_08h], ax
        mov ax, es:[34]
        mov [old_seg_08h], ax

        mov ax, es:[36]
        mov [old_ofs_09h], ax
        mov ax, es:[38]
        mov [old_seg_09h], ax

        cli
        
        mov word ptr es:[32], offset compare_intr
        mov word ptr es:[32+2], cs
        
        mov word ptr es:[36], offset my_interapt
        mov word ptr es:[36+2], cs
        
        sti

        mov dx, offset msg_installed
        mov ah, 09h
        int 21h

        mov dx, offset end_label
        shr dx, 4
        inc dx
        mov ax, 3100h
        int 21h


; _________________________________________________________________________________________________________________________________________________



; ======================================================================
; 	      		 	    data
; ======================================================================


flag db 0

old_ofs_09h 	 dw 0				; old 09h offset
old_seg_09h 	 dw 0				; old 09h segment

old_ofs_08h 	 dw 0				; old 08h offset
old_seg_08h 	 dw 0				; old 08h segment

msg_already      db 'Already installed$'	; messages for user
msg_installed    db 'SUCCESSFULLY INSTALLED$'		  

end_label:
end start