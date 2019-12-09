@Enunciado 1
@Breno Moura de Abreu e Nicolas Da Veiga Pereira
@S73
@10/12/2019

.equ SWI_SETSEG8, 0x200 		@display de 8 segmentos
.equ SEG_A, 0x80			@padr�es de cada segmento do display de 8 segmentos
.equ SEG_B, 0x40 		
.equ SEG_C, 0x20 		
.equ SEG_D, 0x08
.equ SEG_E, 0x04
.equ SEG_F, 0x02
.equ SEG_G, 0x01
.equ SEG_P, 0x10

.equ SWI_CheckBlack, 0x202 		@verifica bot�es pretos
.equ LEFT_BLACK_BUTTON,0x02 		@padr�o de bits para o bot�o preto da esquerda
.equ RIGHT_BLACK_BUTTON,0x01 		@padr�o de bits para o bot�o preto da direita

.equ SWI_CheckBlue, 0x203		@verifica bot�es azuis
.equ BLUE_KEY_0, 1<<0  			@bot�o(0)
.equ BLUE_KEY_1, 1<<1 			@bot�o(1)
.equ BLUE_KEY_2, 1<<2  			@bot�o(2)
.equ BLUE_KEY_3, 1<<3  			@bot�o(3)
.equ BLUE_KEY_4, 1<<4  			@bot�o(4)
.equ BLUE_KEY_5, 1<<5 			@bot�o(5)
.equ BLUE_KEY_6, 1<<6  			@bot�o(6)
.equ BLUE_KEY_7, 1<<7 			@bot�o(7)
.equ BLUE_KEY_8, 1<<8 			@bot�o(8)
.equ BLUE_KEY_9, 1<<9 			@bot�o(9)
.equ BLUE_KEY_A, 1<<10 			@bot�o(A)
.equ BLUE_KEY_B, 1<<11 			@bot�o(B)
.equ BLUE_KEY_C, 1<<12 			@bot�o(C)
.equ BLUE_KEY_D, 1<<13 			@bot�o(D)
.equ BLUE_KEY_E, 1<<14 			@bot�o(E)
.equ BLUE_KEY_F, 1<<15 			@bot�o(F)

.equ SWI_DRAW_STRING, 0x204 		@escreve uma string no display LCD
.equ SWI_DRAW_INT, 0x205 		@escreve um inteiro no display LCD
.equ SWI_CLEAR_DISPLAY,0x206 		@limpa display LCD
.equ SWI_DRAW_CHAR, 0x207		@escreve um caractere no display LCD
.equ SWI_CLEAR_LINE, 0x208		@limpa uma linha no display LCD

.equ SWI_EXIT, 0x11 			@termina o programa
.equ SWI_GetTicks, 0x6d 		@pega o tempo naquele instante

.equ ms50, 1000				@intervalo de 50 milisegundos
.equ EmbestTimerMask, 0x7fff 		@valor de 15 bits para efetuar o mascaramento do valor de tempo
.equ Top15bitRange, 0x0000ffff 		@(2^15) -1 = 32,767

.equ VALOR, 15
.equ RODADAS, 7
.equ MAX, 1000
.equ MS, 50

.text

recomecar:				@reinicia o programa a partir daqui	
	mov r3, #1			@contador de rodadas
	mov r4, #0			@contador segundos
	mov r5, #0			@contador mil�simos de segundos
	mov r13, #11

	swi SWI_CLEAR_DISPLAY

	mov r0, #0			@escreve a string 'Rodada' na tela LCD
	mov r1, #0
	ldr r2, =Rodada
	swi SWI_DRAW_STRING

	mov r0, #7			@escreve um inteiro na tela LCD
	mov r1, #0
	mov r2, r3
	swi SWI_DRAW_INT

	mov r0, #10
	mov r1, #0
	mov r2, r4
	swi SWI_DRAW_INT

	mov r0, #11
	mov r1, #0
	mov r2, r4
	swi SWI_DRAW_INT

	mov r0, #13
	mov r1, #0
	mov r2, r5
	swi SWI_DRAW_INT

	mov r0, #14
	mov r1, #0
	mov r2, r5
	swi SWI_DRAW_INT

	mov r0, #15
	mov r1, #0
	mov r2, r5
	swi SWI_DRAW_INT

	mov r0, #0

	mov r6, #16			@apaga o diaplay de 8 segmentos
	ldr r2, =Digitos
	ldr r0, [r2, r6, lsl#2]
	swi SWI_SETSEG8

inicio:
	mov r0, #0
	swi SWI_CheckBlack		@espera o usu�rio apertar um dos bot�es pretos
	cmp r0, #0
	beq inicio

mostraNumero:
	swi SWI_GetTicks		@pega o valor do rel�gio
	mov r6, r0			@r6 armazena o valor aleat�ria gerado
	ldr r7, =VALOR
	and r6, r6, r7			@faz o mascaramento para obter apenas um valor entre 0 e 15
	mov r0, #0
	ldr r2, =Digitos		 
	ldr r0, [r2, r6, lsl#2]		
	swi SWI_SETSEG8			@escreve o valor aleat�rio no display de 8 segmentos	

	mov r0, #7
	mov r1, #0
	mov r2, r3
	swi SWI_DRAW_INT		@escreve o numero da rodada

contagem:				@realiza a contagem de tempo
	ldr r9,=Top15bitRange
	ldr r10,=EmbestTimerMask
	ldr r11,=ms50
	swi SWI_GetTicks 		@pega tempo atual T1
	mov r1,r0 		
	and r1,r1,r10			@transforma o T1 em 15 bits

repetirAteTempo:
	swi SWI_GetTicks 		@pega tempo atual T2
	mov r2,r0 		
	and r2,r2,r10			@transforma o T2 em 15 bits
	cmp r2,r1 			@r2 � maior que r1?
	bge tempoSimples
	sub r12,r9,r1 			@ tempo = 32,676 - T1
	add r12,r9,r2 			@ + T2
	bal verificaInt
	
tempoSimples:
	sub r12,r2,r1 			@ tempo = T2-T1

verificaInt:
	cmp r2,r11 			@caso o tempo seja menor que o intervalo, volta para o loop at� chegar o tempo certo
	blt repetirAteTempo
	ldr r0, =MS
	add r5, r0, r5
	ldr r0, =MAX
	cmp r5, r0
	bge zera			@caso o valor em milisegundos chegue a 1000, pula para zer�-lo
	mov r0, #0			@caso contr�rio continua incrementando
	cmp r0, #0
	beq atualizaTela

zera:					@zera o contador de milisegundos e incrementa o de segundos
	mov r5, #0
	mov r0, #1
	add r4, r0, r4
	add r14, r14, r0
	
	cmp r4, #10
	blt atualizaTela
	mov r13, #10
	
atualizaTela:				@atualiza a tela com os valores de segundos e milisegundos
	mov r0, r13
	mov r1, #0
	mov r2, r4
	swi SWI_DRAW_INT
	
	mov r0, #13
	mov r1, #0
	mov r2, r5
	swi SWI_DRAW_INT
	

botaoAzul:				@verifica se um bot�o azul foi pressionado
	mov r0, #0
	swi SWI_CheckBlue
	cmp r0, #0
	beq contagem

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
	
compara:				@compara o valor aleat�rio com o bot�o pressionado
	mov r0, #0
	cmp r8, r6
	beq acertou			@caso esteja correto pula para 'acertou'
	
	swi SWI_CLEAR_DISPLAY
	mov r0, #0
	mov r1, #0
	ldr r2, =Perdeu
	swi SWI_DRAW_STRING
	b fim				@caso esteja errado, escreve 'Perdeu!' e pula para o fim

acertou:
	mov r0, #1			
	add r3, r3, r0			@incrementa o numero da rodada
	ldr r0, =RODADAS
	cmp r3, r0
	beq ganhou			@confere se a rodada � a de numero 6, caso seja, pula para 'ganhou'
	
	mov r0, #0
	cmp r0, #0
	beq inicio			@caso seja menor que 6 volta para o inicio

ganhou:					@escreve a string 'Ganhou' e os valores de segundos e milisegundos
	mov r0, #0
	mov r1, #0
	ldr r2, =Ganhou
	swi SWI_DRAW_STRING		
	
	mov r0, #30
	mov r1, #0
	mov r2, r4
	swi SWI_DRAW_INT
	
	mov r0, #33
	mov r1, #0
	mov r2, r5
	swi SWI_DRAW_INT


fim:					@espera o usu�rio pressionar um dos bot�es pretos para recome�ar o jogo
	mov r0, #0	
	swi SWI_CheckBlack
	cmp r0, #0
	beq fim
	b recomecar
	
.data					@strings que ser�o utilizadas no programa

Rodada: .asciz "Rodada  :   .   s"
Perdeu: .asciz "Perdeu!"
Ganhou: .asciz "Fim de jogo! Seu tempo final:   .   s"


Digitos:					@padr�es de caracteres do display de 8 segmentos
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

@Bibliografia: The ARMSim# User Guide - R. N. Horspool, W. D. Lyons, M. Serra
@Pode ser encontrado no endere�o: https://www.lri.fr/~de/ARM-Tutorial.pdf
