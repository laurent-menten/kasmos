
; strcmpz(rdi=s1, rsi=s2) -> ZF=1 si égal, ZF=0 sinon ; détruit rax

FUNCTION _strcmpz
.loop:
	mov al, [rdi]
	cmp al, [rsi]
	jne .ne

	test al, al
	je .eq

	inc rdi
	inc rsi
	jmp .loop

.eq:
	cmp byte [rel .z], 0  ; force ZF=1
	ret

.ne:
	cmp byte [rel .o], 1  ; force ZF=0
	ret

.z: db 0
.o: db 1
