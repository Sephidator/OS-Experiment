    global _start

    section .data
separator: db 10,0
color_type: dd 00000000h
color_red:      db  1Bh, '[31;1m', 0
.len            equ $ - color_red
color_green:     db  1Bh, '[32;1m', 0
.len            equ $ - color_green
color_yellow:      db  1Bh, '[33;1m', 0
.len            equ $ - color_yellow
color_blue:     db  1Bh, '[34;1m', 0
.len            equ $ - color_blue
color_purple:      db  1Bh, '[35;1m', 0
.len            equ $ - color_purple
color_white:  db  1Bh, '[37;0m', 0
.len            equ $ - color_white

    section .text
_start: 
        mov r15, [rsp+24]
        
        call printStr

        mov rax, 60      ;exit NO
        syscall



;printStr([rdi] pointer: char*): void
;call sys_write(unsigned int fd, const char *buf, size_t count), syscall_number=1 (x86_64)
;paramaters for sys_write saevd in rdi, rsi, rdx, syscall_number saved in rax
printStr:
        push rbp
        mov rbp, rsp

        call printColor
        mov rax, 1 ;syscall_number: write
        mov rdi, 1 ;file discriptor: stdout
        mov rsi, [r15 + 8]
        mov rdx, [r15 + 16]
        syscall

        leave
        ret

;print the color
printColor:
	push rbp
	mov rbp,rsp
	push rax
	push rdi
	push rsi
	push rdx
        push rcx
	cmp	dword[color_type],0
	je	blue
	cmp	dword[color_type],1
	je	red
	cmp	dword[color_type],2
	je	green
	cmp	dword[color_type],3
	je	yellow
        cmp	dword[color_type],4
	je	purple
	cmp	dword[color_type],5
	je	white
blue:	
	mov	rdi,color_blue
	mov	dword[color_type],1
	jmp	color_end
red:	
	mov	rdi,color_red
	mov	dword[color_type],2
	jmp	color_end
green:	
	mov	rdi,color_green
	mov	dword[color_type],3
	jmp	color_end
yellow:	
	mov	rdi,color_yellow
	mov	dword[color_type],4
        jmp	color_end
purple:	
	mov	rdi,color_purple
	mov	dword[color_type],5
        jmp	color_end
white:	
	mov	rdi,color_white
	mov	dword[color_type],0
color_end:
	call printStr
        pop rcx
        pop rdx
	pop rsi
	pop rdi
	pop rax
	leave
	ret


