@Enunciado 1

.equ SWI_SETSEG8, 0x200 	@display de 8 segmentos
.equ SEG_A, 0x80		@padrões de cada segmento do display de 8 segmentos
.equ SEG_B, 0x40 		
.equ SEG_C, 0x20 		
.equ SEG_D, 0x08
.equ SEG_E, 0x04
.equ SEG_F, 0x02
.equ SEG_G, 0x01
.equ SEG_P, 0x10

.equ SWI_CheckBlack, 0x202 	@verifica botões pretos
.equ LEFT_BLACK_BUTTON,0x02 	@padrão de bits para o botão preto da esquerda
.equ RIGHT_BLACK_BUTTON,0x01 	@padrão de bits para o botão preto da direita

.equ SWI_CheckBlue, 0x203	@verifica botões azuis
.equ BLUE_KEY_0, 1<<0  		@botão(0)
.equ BLUE_KEY_1, 1<<1 		@botão(1)
.equ BLUE_KEY_2, 1<<2  		@botão(2)
.equ BLUE_KEY_3, 1<<3  		@botão(3)
.equ BLUE_KEY_4, 1<<4  		@botão(4)
.equ BLUE_KEY_5, 1<<5 		@botão(5)
.equ BLUE_KEY_6, 1<<6  		@botão(6)
.equ BLUE_KEY_7, 1<<7 		@botão(7)
.equ BLUE_KEY_8, 1<<8 		@botão(8)
.equ BLUE_KEY_9, 1<<9 		@botão(9)
.equ BLUE_KEY_A, 1<<10 		@botão(A)
.equ BLUE_KEY_B, 1<<11 		@botão(B)
.equ BLUE_KEY_C, 1<<12 		@botão(C)
.equ BLUE_KEY_D, 1<<13 		@botão(D)
.equ BLUE_KEY_E, 1<<14 		@botão(E)
.equ BLUE_KEY_F, 1<<15 		@botão(F)

.equ SWI_DRAW_STRING, 0x204 	@escreve uma string no display LCD
.equ SWI_DRAW_INT, 0x205 	@escreve um inteiro no display LCD
.equ SWI_CLEAR_DISPLAY,0x206 	@limpa display LCD
.equ SWI_DRAW_CHAR, 0x207	@escreve um caractere no display LCD
.equ SWI_CLEAR_LINE, 0x208	@limpa uma linha no display LCD

.equ SWI_EXIT, 0x11 		@termina o programa
.equ SWI_GetTicks, 0x6d 	@pega o tempo naquele instante

.equ ms50, 1000			@intervalo de 50 milisegundos
.equ EmbestTimerMask, 0x7fff 	@valor de 15 bits para efetuar o mascaramento do valor de tempo
.equ Top15bitRange, 0x0000ffff 	@(2^15) -1 = 32,767

.equ VALOR, 15
.equ RODADAS, 7
.equ MAX, 1000
.equ MS, 50

.text

	
	mov r3, #1		@contador de rodadas
	mov r4, #0		@contador segundos
	mov r5, #0		@contador milésimos de segundos
	mov r13, #0

inicio:
	swi SWI_CLEAR_DISPLAY
	mov r0, #0
	mov r1, #0
	ldr r2, =Rodada
	swi SWI_DRAW_STRING
	mov r0, #7
	mov r1, #0
	mov r2, r3
	swi SWI_DRAW_INT
	mov r0, #8
	mov r1, #0
	mov r2, #':
	swi SWI_DRAW_CHAR
	mov r0, #11
	mov r1, #0
	mov r2, r4
	swi SWI_DRAW_INT
	mov r0, #12
	mov r1, #0
	mov r2, #'.
	swi SWI_DRAW_CHAR
	mov r0, #14
	mov r1, #0
	mov r2, r5
	swi SWI_DRAW_INT
	mov r0, #17
	mov r1, #0
	mov r2, #'s
	swi SWI_DRAW_CHAR

	cmp r13, #0
	beq botaoInicio
	cmp r13, #0
	bge continua

botaoInicio:
	swi SWI_CheckBlack
	cmp r0, #0
	beq botaoInicio

continua:
	mov r13, #1
	ldr r9,=Top15bitRange
	ldr r10,=EmbestTimerMask
	ldr r11,=ms50
	swi SWI_GetTicks 	@pega tempo atual T1
	mov r1,r0 		
	and r1,r1,r10		@transforma o T1 em 15 bits

repetirAteTempo:
	swi SWI_GetTicks 	@pega tempo atual T2
	mov r2,r0 		
	and r2,r2,r10		@transforma o T2 em 15 bits
	cmp r2,r1 		@r2 é maior que r1?
	bge tempoSimples
	sub r12,r9,r1 		@ tempo = 32,676 - T1
	add r12,r9,r2 		@ + T2
	bal verificaInt
	
tempoSimples:
	sub r12,r2,r1 		@ tempo = T2-T1

verificaInt:
	cmp r2,r11 		@tempo é menor que o intervalo?
	blt repetirAteTempo
	swi SWI_CLEAR_DISPLAY
	ldr r0, =MS
	add r5, r0, r5
	ldr r0, =MAX
	cmp r5, r0
	bge zera
	mov r0, #0
	cmp r0, #0
	beq botaoPreto

zera:
	mov r5, #0
	mov r0, #1
	add r4, r0, r4

botaoPreto:
	swi SWI_CheckBlack
	cmp r0, #0
	beq inicio

	cmp r0, #RIGHT_BLACK_BUTTON
	beq mostraNumero
	bal mostraNumero

mostraNumero:
	swi SWI_GetTicks
	mov r6, r0		@r6 armazena o valor aleatória gerado
	ldr r7, =VALOR
	and r6, r6, r7
	mov r0, #0
	ldr r2, =Digitos
	ldr r0, [r2, r6, lsl#2]
	swi SWI_SETSEG8

botaoAzul:
	mov r0, #0
	swi SWI_CheckBlue
	cmp r0, #0
	beq botaoAzul

	cmp r0,#BLUE_KEY_0
	mov r8, #0
	beq compara
	
	cmp r0,#BLUE_KEY_1
	mov r8, #1
	beq compara

	cmp r0,#BLUE_KEY_2
	mov r8, #2
	beq compara

	cmp r0,#BLUE_KEY_3
	mov r8, #3
	beq compara

	cmp r0,#BLUE_KEY_4
	mov r8, #4
	beq compara

	cmp r0,#BLUE_KEY_5
	mov r8, #5
	beq compara

	cmp r0,#BLUE_KEY_6
	mov r8, #6
	beq compara

	cmp r0,#BLUE_KEY_7
	mov r8, #7
	beq compara

	cmp r0,#BLUE_KEY_8
	mov r8, #8
	beq compara
	
	cmp r0,#BLUE_KEY_9
	mov r8, #9
	beq compara

	cmp r0,#BLUE_KEY_A
	mov r8, #10
	beq compara

	cmp r0,#BLUE_KEY_B
	mov r8, #11
	beq compara

	cmp r0,#BLUE_KEY_C
	mov r8, #12
	beq compara

	cmp r0,#BLUE_KEY_D
	mov r8, #13
	beq compara

	cmp r0,#BLUE_KEY_E
	mov r8, #14
	beq compara

	cmp r0,#BLUE_KEY_F
	mov r8, #15
	beq compara
	
compara:
	mov r0, #0
	cmp r8, r6
	beq acertou
	
	swi SWI_CLEAR_DISPLAY
	mov r0, #0
	mov r1, #0
	ldr r2, =Perdeu
	swi SWI_DRAW_STRING

	cmp r0, #0
	beq fim

acertou:
	swi SWI_CLEAR_DISPLAY
	mov r0, #0
	mov r1, #0
	ldr r2, =Acertou
	swi SWI_DRAW_STRING
	
	mov r0, #1
	add r3, r3, r0
	ldr r0, =RODADAS
	cmp r3, r0
	beq fim
	
	mov r0, #0
	cmp r0, #0
	beq inicio

fim:
	mov r0, #0
	
.data

Rodada: .asciz "Rodada "
Perdeu: .asciz "Perdeu!"
Acertou: .asciz "Acertou!"


Digitos:					@padrões de caracteres do display de 8 segmentos
.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G 	@0
.word SEG_B|SEG_C 				@1
.word SEG_A|SEG_B|SEG_D|SEG_E|SEG_F 		@2
.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_F 		@3
.word SEG_B|SEG_C|SEG_F|SEG_G 			@4
.word SEG_A|SEG_C|SEG_D|SEG_F|SEG_G 		@5
.word SEG_A|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G 	@6
.word SEG_A|SEG_B|SEG_C 			@7
.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @8
.word SEG_A|SEG_B|SEG_C|SEG_F|SEG_G 		@9
.word SEG_A|SEG_B|SEG_C|SEG_E|SEG_F|SEG_G 	@A
.word SEG_C|SEG_D|SEG_E|SEG_F|SEG_G 		@B
.word SEG_A|SEG_D|SEG_E|SEG_G 			@C
.word SEG_B|SEG_C|SEG_D|SEG_E|SEG_F 		@D
.word SEG_A|SEG_D|SEG_E|SEG_F|SEG_G 		@E
.word SEG_A|SEG_E|SEG_F|SEG_G 			@F
.word 0 					@display desligado
.end

swi SWI_EXIT

