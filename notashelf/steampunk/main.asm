; A number's decimal string is non-primitive if it is k>=2 repeats of a shorter block.
; For lengths 2..8 we test the allowed period lengths via numeric forms:
;  L=2: (a)^2  => divisor 11
;  L=3: (a)^3  => 111
;  L=4: (a)^4  => 1111, (ab)^2 => 101
;  L=5: (a)^5  => 11111
;  L=6: (a)^6  => 111111, (ab)^3 => 10101, (abc)^2 => 1001
;  L=7: (a)^7  => 1111111
;  L=8: (a)^8  => 11111111, (ab)^4 => 1010101, (abcd)^2 => 10001

        global  _start
        section .bss
buf:    resb 32

        section .text
_start:
        xor     r9d, r9d          ; count
        mov     ecx, 1            ; n
        mov     r8d, 10000000

.loop:
        mov     eax, ecx
        cmp     eax, 10
        jb      .next             ; length 1 => primitive

        cmp     eax, 100
        jb      .len2
        cmp     eax, 1000
        jb      .len3
        cmp     eax, 10000
        jb      .len4
        cmp     eax, 100000
        jb      .len5
        cmp     eax, 1000000
        jb      .len6
        cmp     eax, 10000000
        jb      .len7
        jmp     .len8             ; 8 digits (10,000,000 included)

.len2:
        xor     edx, edx
        mov     ebx, 11
        div     ebx
        test    edx, edx
        jnz     .next
        inc     r9d
        jmp     .next

.len3:
        xor     edx, edx
        mov     ebx, 111
        div     ebx
        test    edx, edx
        jnz     .next
        inc     r9d
        jmp     .next

.len4:
        mov     edi, eax
        xor     edx, edx
        mov     ebx, 1111
        div     ebx
        test    edx, edx
        jz      .count
        mov     eax, edi
        xor     edx, edx
        mov     ebx, 101
        div     ebx
        test    edx, edx
        jnz     .next
        cmp     eax, 100          ; two-digit block
        jae     .next
        jmp     .count

.len5:
        xor     edx, edx
        mov     ebx, 11111
        div     ebx
        test    edx, edx
        jnz     .next
        jmp     .count

.len6:
        mov     edi, eax
        xor     edx, edx
        mov     ebx, 111111
        div     ebx
        test    edx, edx
        jz      .count
        mov     eax, edi
        xor     edx, edx
        mov     ebx, 10101
        div     ebx
        test    edx, edx
        jz      .len6_ab
        mov     eax, edi
        xor     edx, edx
        mov     ebx, 1001
        div     ebx
        test    edx, edx
        jnz     .next
        cmp     eax, 1000         ; 3dig block
        jae     .next
        jmp     .count
.len6_ab:
        cmp     eax, 100          ; 2dig block
        jae     .next
        jmp     .count

.len7:
        xor     edx, edx
        mov     ebx, 1111111
        div     ebx
        test    edx, edx
        jnz     .next
        jmp     .count

.len8:
        mov     edi, eax
        xor     edx, edx
        mov     ebx, 11111111
        div     ebx
        test    edx, edx
        jz      .count
        mov     eax, edi
        xor     edx, edx
        mov     ebx, 1010101
        div     ebx
        test    edx, edx
        jz      .len8_ab
        mov     eax, edi
        xor     edx, edx
        mov     ebx, 10001
        div     ebx
        test    edx, edx
        jnz     .next
        cmp     eax, 10000        ; 4dig block
        jae     .next
        jmp     .count
.len8_ab:
        cmp     eax, 100          ; 2dig block
        jae     .next
        jmp     .count

.count:
        inc     r9d

.next:
        inc     ecx
        cmp     ecx, 10000001
        jl      .loop

; Convert r9d to decimal with newline
        mov     eax, r9d
        mov     rsi, buf
        add     rsi, 31
        mov     byte [rsi], 10
        mov     rdi, rsi
        dec     rdi
        test    eax, eax
        jnz     .conv
        mov     byte [rdi], '0'
        jmp     .out_ready
.conv:
        xor     edx, edx
        mov     ebx, 10
.dloop:
        div     ebx
        add     dl, '0'
        mov     [rdi], dl
        dec     rdi
        xor     edx, edx
        test    eax, eax
        jnz     .dloop
        inc     rdi

.out_ready:
        mov     rax, 1            ; write
        mov     rdx, rsi
        sub     rdx, rdi
        inc     rdx               ; include newline
        mov     rsi, rdi
        mov     rdi, 1
        syscall

        mov     rax, 60
        xor     rdi, rdi
        syscall
