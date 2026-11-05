format ELF64
public _start


section '.bss' writable
bufferChar rb 1
bufferCharMsg rb 1
discardChar rb 1


section '.data' writable
ROWS = 9
COLS = 9
map db '#','#','#','#','#','#','#','#','#'
    db '#','.','.','.','.','.','.','.','#'
    db '#','.','.','.','.','.','.','.','#'
    db '#','.','.','.','.','.','.','.','#'
    db '#','.','.','.','.','.','.','.','#'
    db '#','.','.','.','.','.','.','.','#'
    db '#','.','.','.','.','.','.','.','#'
    db '#','.','.','.','.','.','.','.','#'
    db '#','#','#','#','#','#','#','#','#'

x dq 4
y dq 4

msg1 db 'Ходилки Бродилки FASM edetion',0
msg2 db 'Чтобы вызвать справочник введите: h',0
msgHelp db 'СПРАВОЧНИК',0
msgHelp1 db 'Управление в игре осуществляется путём, ввода одной буквы в консоль',0
msgHelp2 db 'Для управление игроком используются следующие буквы: w,a,s,d',0
msgHelp3 db 'Чтобы выйти из игры введите: q',0
msgHelp4 db 'Для вызов справочника (если что Вы читает этот самый справочник) введите: h',0


section '.main' executable
_start:
    mov rax,msg1
    call printStr
    mov rax,msg2
    call printStr
    call newLine
    call setMan
    call mapDraw
    .iWhile:
        call newLine
        call inputChar
        movzx rax,[bufferCharMsg]
        call unSetMan
        call inputManager
        call setMan
        call newLine
        call mapDraw
        jmp .iWhile


section '.instruction' executable
instruction:
    call newLine
    push rax
    mov rax,msgHelp
    call printStr
    mov rax,msgHelp1
    call printStr
    mov rax,msgHelp2
    call printStr
    mov rax,msgHelp3
    call printStr
    mov rax,msgHelp4
    call printStr
    call newLine
    pop rax
    ret


; INPUT
; rax - строка
; OUTPUT
; rax - длина строки
section '.lenStr' executable
lenStr:
    push rcx
    xor rcx,rcx
    .iter:
        cmp [rax + rcx], byte 0
        je .close
        inc rcx
        jmp .iter
    .close:
        mov rax,rcx
        pop rcx
        ret


; INPUT
; rax - строка
section '.printStr' executable
printStr:
    push rax
    push rbx
    push rcx
    push rdx
    mov rsi,rax
    call lenStr
    mov rdx,rax
    mov rax,1
    mov rdi,1
    syscall
    call newLine
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


section '.inputManager' executable
inputManager:
    push rax
    push rbx
    push rcx
    push rdx

    xor rcx,rcx
    xor rdx,rdx
    cmp al,'q'
    je .gameOver
    cmp al,'h'
    je .help
    cmp al,'w';
    je .up
    cmp al,'a';
    je .left
    cmp al,'d'
    je .right
    cmp al,'s'
    je .down
    jmp .close

    .up:
        call check
        cmp rbx,'.'
        je .upY
        jmp .close
        .upY:
            dec qword [y]
            jmp .close
    .down:
        call check
        cmp rbx,'.'
        je .downY
        jmp .close
        .downY:
            inc qword [y]
            jmp .close
    .left:
        call check
        cmp rbx,'.'
        je .leftY
        jmp .close
        .leftY:
            dec qword [x]
            jmp .close
    .right:
        call check
        cmp rbx,'.'
        je .rightY
        jmp .close
        .rightY:
            inc qword [x]
            jmp .close
    
    .gameOver:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        call exit
    
    .help:
        call instruction

    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret


section '.check' executable
check:
    push rcx
    push rdx
    mov rcx,[x]
    mov rdx,[y]
    cmp al,'w';
    je .up
    cmp al,'a';
    je .left
    cmp al,'d'
    je .right
    cmp al,'s'
    je .down
    jmp .close

    .up:
        dec rdx
        jmp .iter
        jmp .close
    .down:
        inc rdx
        jmp .iter
        jmp .close
    .left:
        dec rcx
        jmp .iter
        jmp .close
    .right:
        inc rcx
        jmp .iter
        jmp .close
    .iter:
        push rax
        call definePoint
        movzx rbx,[map + rax]
        pop rax
    .close:
        pop rdx
        pop rcx
        ret


section '.inputChar' executable
inputChar:
    push rbx
    push rcx
    push rdx
    xor rax,rax
    xor rdi,rdi
    mov rsi,bufferCharMsg
    mov rdx,1
    syscall

    cmp rax,1
    jne .close
    cmp [bufferCharMsg],10
    je .success

    .discard:
        xor rax,rax
        xor rdi,rdi
        mov rsi,discardChar
        mov rdx,1
        syscall
        cmp rax,1
        jne .close
        cmp byte [discardChar],10
        jne .discard
    .success:
        mov rax, 1  
    .close:
        pop rdx
        pop rcx
        pop rbx
        ret


section '.unSetMan' executable
unSetMan:
    push rax
    call definePoint
    mov [map + rax], '.'
    pop rax
    ret


section '.setMan' executable
setMan:
    push rax
    call definePoint
    mov [map + rax], '@'
    pop rax
    ret


; OUTPUT
; rax - число в массиве
section '.definePoint' executable
definePoint:
    mov rax,ROWS
    imul rax,[y]
    add rax,[x]
    ret


; INPUT
; rax - char
section '.printChar' executable
printChar:
    push rax
    push rbx
    push rcx
    push rdx
    mov [bufferChar],al
    mov rax,1
    mov rdi,1
    mov rsi,bufferChar
    mov rdx,1
    syscall
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret


section '.newLine' executable
newLine:
    push rax
    mov rax,10
    call printChar
    pop rax
    ret


section '.mapDraw' executable
mapDraw:
    push rbx
    push rcx
    push rdx
    xor rbx, rbx             ; индекс элемента в map
    xor rcx, rcx             ; номер строки
.row:
    cmp rcx, ROWS
    je .done
    xor rdx, rdx            ; номер столбца
.column:
    cmp rdx, COLS
    je .newline
    movzx rax, byte [map + rbx]
    call printChar
    inc rbx                 ; следующий элемент массива
    inc rdx                 ; следующий столбец
    jmp .column
.newline:
    call newLine
    inc rcx
    jmp .row
.done:
    pop rdx
    pop rcx
    pop rbx
    ret


section '.exit' executable
exit:
    mov rax,60
    xor rdi,rdi
    syscall