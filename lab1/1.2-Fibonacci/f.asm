    global _start

    section .data
msg: db "Please input X and Y :",0
number: db '0','1','2','3','4','5','6','7','8','9'
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
        mov rdi, msg     ;addr of msg string
        call printStr

        call readNum
        mov r12, rax

        call readNum
        mov r13, rax

        call fibonacci   ;打印斐波那契数

        mov rax, 60      ;exit NO
        syscall



;printStr([rdi] pointer: char*): void
;call sys_write(unsigned int fd, const char *buf, size_t count), syscall_number=1 (x86_64)
;paramaters for sys_write saevd in rdi, rsi, rdx, syscall_number saved in rax
printStr:
        push rbp
        mov rbp, rsp

        call strLen
        mov rdx, rax ;size
        mov rsi, rdi ;pointer
        mov rax, 1 ;syscall_number: write
        mov rdi, 1 ;file discriptor: stdout
        syscall

        leave
        ret

;strLen([rdi] pointer: char*): long
strLen:
        push rbp
        mov rbp, rsp
        mov rax, 0 ;result
        mov rdx, rdi ;address
strLen_loop:
        cmp [rdx], byte 0  ;end of string?
        je strLen_exit  ;yes, quit
        inc rdx            ;no, point to next
        inc rax            ;counter++
        jmp strLen_loop ;continue
strLen_exit:
        leave ;equals [ move esp, ebp ;pop ebp ] 
        ret


;readNum(): long
;call sys_read(unsigned int fd, const char *buf, size_t count), syscall_number=0 (x86_64)
;paramaters for sys_read saevd in rdi, rsi, rdx, syscall_number saved in rax
readNum:    
        push rbp
        mov rbp, rsp
        xor r8, r8 ;r8 to store result
        sub rsp, 1  ;make room for buffer. 1 byte contains 1 char
readNum_getChar:
        mov rax, 0  ;read
        mov rdi, 0  ;stdin
        mov rsi, rsp ;buffer pointer
        mov rdx, 1 ;length
        syscall
        movzx rax, byte [rsp] ;result is in [rsp], move it to rax
readNum_judge:
        cmp rax, 48 ;<48
        jl readNum_exit 
        cmp rax, 57 ;>57
        jg readNum_exit 

        imul r8, 10
        sub rax, 48 ;-'0'
        add r8, rax 
        jmp readNum_getChar
readNum_exit: 
        mov rax, r8
        leave
        ret

;printNum([rcx] number: long): void
;call sys_write(unsigned int fd, const char *buf, size_t count), syscall_number=1 (x86_64)
;paramaters for sys_write saevd in rdi, rsi, rdx, syscall_number saved in rax
printNum:
        push rbp
        mov rbp, rsp
        push r15
        call getNumLength
        mov r15, rax       ;r15 save the length of the number
        mov r9, 10
printNum_mainLoop:
        cmp r15, 0
        je printNum_exit
printNum_high:
        mov rax, rcx       ;rcx saves the number, rax will be changed lately
        mov r8, 0
printNum_high_getHighLoop:
        cmp rax, 10        ;r10 save the highest digit
        jl printNum_high_write
        xor rdx, rdx
        div r9
        add r8, 1
        jmp printNum_high_getHighLoop
printNum_high_write:
        push rax
        push rcx
        call zeroExtended
        pop rcx
        pop rax
        
        mov r10, rax      ;save the highest digit
        mov rdx, 1        ;size
        mov rsi, number   ;pointer
        add rsi, rax
        mov rax, 1        ;syscall_number: write
        mov rdi, 1        ;file discriptor: stdout
        push rcx
        syscall
        pop rcx

        dec r15           ;r15--
printNum_down:
        cmp r8, 0
        je printNum_down_returnMainLoop
        imul r10, 10
        sub r8, 1
        jmp printNum_down
printNum_down_returnMainLoop:
        sub rcx, r10
        jmp printNum_mainLoop
printNum_exit:
        pop r15
        leave
        ret



;printNum([r8] digit: long, [r15] length: long): void
;in common case, r8 shoule be r15 - 1
;this function will print 0 and let r15 minus 1 until r8 = r15 - 1 
zeroExtended:
        push rbp
        mov rbp, rsp
        inc r8
zeroExtended_loop:
        cmp r8, r15
        je zeroExtended_exit
        mov rdx, 1 ;size
        mov rsi, number ;pointer
        mov rax, 1 ;syscall_number: write
        mov rdi, 1 ;file discriptor: stdout
        push r8
        syscall
        pop r8

        dec r15
        jmp zeroExtended_loop
zeroExtended_exit:
        dec r8
        leave
        ret


;printNum([rcx] number: long): long
getNumLength:
        push rbp
        mov rbp, rsp
        push r8
        push r9
        push rdx
        mov r9, 10            ;r9 saves 10 
        mov r8, 1             ;r8 saves the length
        mov rax, rcx          ;rax saves the number
getNumLength_loop:
        cmp rax, 10
        jl getNumLength_exit
        xor rdx, rdx          ;把 rdx:rax 做被除数,  商 -> rax, 余数 -> rdx
        div r9                ;div后面的r9存放除数 
        add r8, 1             ;length++
        jmp getNumLength_loop       
getNumLength_exit:
        mov rax, r8
        pop rdx
        pop r9
        pop r8
        leave 
        ret


fibonacci:
        push rbp
        mov rbp, rsp
        mov r8, 0  ;r8 save the sequence number
        mov rdx, 0 ;rdx the previous fibonacci number
        mov rcx, 0 ;rdx the current fibonacci number
fibonacci_loop:
        cmp r8, 0
        je fibonacci_loop_setValue_0
        cmp r8, 1
        je fibonacci_loop_setValue_1
        jmp fibonacci_loop_setValue
fibonacci_loop_setValue_0:
        mov rcx, 0
        jmp fibonacci_loop_print
fibonacci_loop_setValue_1:
        mov rcx, 1
        jmp fibonacci_loop_print
fibonacci_loop_setValue:
        mov r9, rcx
        add rcx, rdx
        mov rdx, r9
        jmp fibonacci_loop_print
fibonacci_loop_print:
        cmp r8, r12
        jl fibonacci_returnLoop
        cmp r8, r13
        jg fibonacci_exit
        push r8
        push rcx
        push rdx
        call printColor
        call printNum
        mov rdi, separator  ;addr of string 'line separator'
        call printStr
        pop rdx
        pop rcx
        pop r8
fibonacci_returnLoop:
        inc r8
        jmp fibonacci_loop
fibonacci_exit:
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







