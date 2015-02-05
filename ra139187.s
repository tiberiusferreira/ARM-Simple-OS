@@TODO colocar o tempo certo no temporizador para interromper e alternar processos
@@TODO ver o codigo r7 da writes
.section .iv,"a"

_start:		
.org 0x0
interrupt_vector:
	@codigo no endereco 0x00
	b RESET_HANDLER @primeira instrucao a ser executada sempre
.org 0x08
	b SUPERVISOR @software interrupt
.org 0x18
	b IRQ_HANDLER @HARDWARE INTERRUPT
.org 0x100 @para ter certeza que vai ser escrito fora 
@do vetor de interrupcoes
	
RESET_HANDLER:

@------------------Inicializando o Sistema---------------@
@colocando o estado como modo supervisor, mas IRQ/FIQ desabilitados
msr CPSR_c, #0xD3 

@------------------Configurando o GPT ---------------@

@Set interrupt table base address on coprocessor 15.
ldr r0, =interrupt_vector
mcr p15, 0, r0, c12, c0, 0

ldr r0, =0x53FA0000   @OK GPT_CR	
mov r1, #0x00000041
str r1, [r0]

ldr r0, =0x53FA0004 @GPT_PR 
mov r1, #0
str r1, [r0]

ldr r0, =0x53FA0010  @ok GPT_OCR1 
mov r1, #1000  @1000 = valor de quantos em quantos ciclos interromper
str r1, [r0]

ldr r0, =0x53FA000C     @ok GPT_IR
mov r1, #1
str r1, [r0]


@---------------Configuracao do TZIC--------------------@
SET_TZIC:
@ Constantes para os enderecos do TZIC
.set TZIC_BASE,			0x0FFFC000
.set TZIC_INTCTRL,		0x0
.set TZIC_INTSEC1,		0x84 
.set TZIC_ENSET1,		0x104
.set TZIC_PRIOMASK,		0xC
.set TZIC_PRIORITY9,	0x424

@ Liga o controlador de interrupcoes
@ R1 <= TZIC_BASE

ldr	r1, =TZIC_BASE

@ Configura interrupcao 39 do GPT como nao segura
mov	r0, #(1 << 7)
str	r0, [r1, #TZIC_INTSEC1]

@ Habilita interrupcao 39 (GPT)
@ reg1 bit 7 (gpt)

mov	r0, #(1 << 7)
str	r0, [r1, #TZIC_ENSET1]

@ Configure interrupt39 priority as 1
@ reg9, byte 3

ldr r0, [r1, #TZIC_PRIORITY9]
bic r0, r0, #0xFF000000
mov r2, #1
orr r0, r0, r2, lsl #24
str r0, [r1, #TZIC_PRIORITY9]

@ Configure PRIOMASK as 0
eor r0, r0, r0
str r0, [r1, #TZIC_PRIOMASK]

@ Habilita o controlador de interrupcoes
mov	r0, #1
str	r0, [r1, #TZIC_INTCTRL]

@----------------Configuracao do UART------------------@
ldr r0, =0x53FBC080 @ok UCR1 
mov r1, #0x0001
str r1, [r0]

ldr r0, =0x53FBC084 @ok UCR2 
ldr r1, =0x2127
str r1, [r0]

ldr r0, =0x53FBC088 @ok UCR3 @=
ldr r1, =0x0704
str r1, [r0]

ldr r0, =0x53FBC08C @ok UCR4
mov r1, #0x7C00
str r1, [r0]

ldr r0, =0x53FBC090 @ok UFCR 
ldr r1, =0x089E
str r1, [r0]

ldr r0, =0x53FBC0A4 @ok UBIR @=
ldr r1, =0x08FF
str r1, [r0]

ldr r0, =0x53FBC0A8 @ok UBMR @=
ldr r1, =0x0C34
str r1, [r0]
		 

@--------------------Inicializando o SP de todos os modos--------------@
.set SVC_STACK, 0x77701000 @nao devo usar.
.set UND_STACK, 0x77702000
.set ABT_STACK, 0x77703000
.set IRQ_STACK, 0x77704000
.set FIQ_STACK, 0x77705000


.set PID1_STACK,0x7770D000
.set PID2_STACK,0x7770C000
.set PID3_STACK,0x7770B000
.set PID4_STACK,0x7770A000
.set PID5_STACK,0x77709000
.set PID6_STACK,0x77708000
.set PID7_STACK,0x77707000
.set PID8_STACK,0x77706000 @=USR STACK da especificacao


.set SVC1_STACK, 0x7770C800





@--------------------Configurando o SP de todos os modos--------------@
 ldr sp, =SVC1_STACK
 msr CPSR_c, #0xDF  @ Enter system mode= USR_MODE, FIQ/IRQ disabled
 ldr sp, =PID1_STACK
 msr CPSR_c, #0xD1  @ Enter FIQ mode, FIQ/IRQ disabled
 ldr sp, =FIQ_STACK
 msr CPSR_c, #0xD2  @ Enter IRQ mode, FIQ/IRQ disabled
 ldr sp, =IRQ_STACK
 msr CPSR_c, #0xD7  @ Enter abort mode, FIQ/IRQ disabled
 ldr sp, =ABT_STACK
 msr CPSR_c, #0xDB  @ Enter undefined mode, FIQ/IRQ disabled
 ldr sp, =UND_STACK
 
@--------------------Inicializando o array de processos ativos--------------@

ldr r0, =processos_ativos
@No comeco o processo 1 esta ativo 
mov r1, #1      @enderecando a bytes
strb r1, [r0]	@setando o primeiro elemento como ativo
mov r1, #0
add r0, r0, #1  @apontando para o prox espaco do vetor
strb r1, [r0]    @colocando o espaco 2 como 0
add r0, r0, #1  @apontando para o prox espaco do vetor
strb r1, [r0]    @colocando o espaco 3 como 0
add r0, r0, #1  @apontando para o prox espaco do vetor
strb r1, [r0]    @colocando o espaco 4 como 0
add r0, r0, #1  @apontando para o prox espaco do vetor
strb r1, [r0]    @colocando o espaco 5 como 0
add r0, r0, #1  @apontando para o prox espaco do vetor
strb r1, [r0]    @colocando o espaco 6 como 0
add r0, r0, #1  @apontando para o prox espaco do vetor
strb r1, [r0]    @colocando o espaco 7 como 0
add r0, r0, #1  @apontando para o prox espaco do vetor
strb r1, [r0]    @colocando o espaco 8 como 0


@--------------------Colocando processo 0 como ativo--------------@
ldr r1, =processo_atual
mov r0, #0				@colocando processo atual como o 0
str r0, [r1]



@--------------------Indo para modo USUARIO e indo para o codigo dele--------------@
msr CPSR_c, #0x10 @indo para modo usuario e HABILITANDO interrupcoes
ldr r0, =0x77802000
mov pc, r0 @indo para o codigo do usuario

@--------------------Cuidando das interrupcoes do GPT--------------@
IRQ_HANDLER:
msr CPSR_c, #0xD2 @modo IRQ sem interrupcoes
push {r0-r1}
ldr r0, =GPT_SR @=0x53FA0008
mov r1, #1
str r1, [r0]		@marcando a interrupcao como ja reconhecida
pop {r0-r1}
b Salvar_contexto_e_alternar_processos @tratar a execucao

@--------------------Cuidando da interrupcao por software--------------@
SUPERVISOR:
@primeiro ir para o modo supervisor e desabilitar IRQ/FIQ
msr CPSR_c, #0xD3
@checar qual chamada foi feita (write, get pid, fork ou exit)
cmp r7, #0x4  @ 4 = write // 0x14 = GET_PID //0x2 = FORK //0x1= EXIT
beq WRITE
cmp r7, #0x14
beq GET_PID
cmp r7, #0x2
beq FORK
cmp r7, #0x1
beq EXIT
@caso contrario, dar erro
mov r0, #-1    @-1 indica erro
movs pc, lr    @retorna ao codigo do usuario

@--------------------WRITE--------------@
@ao chegar aqui, r1=inicio dos dados a escrever
@r2 = quantos bytes escrever
WRITE:
push {r1-r6}
mov r5, #0 @quantidade de bytes ja escritos
mov r6, #1
mov r6, r6, lsl #13 @coloco o bit 1 na posicao 13
WRITE_LACO:
CHECK_READY:
	ldr r0, =0x53FBC094 @ USR1 @=
	ldr r0, [r0]  @preciso checar se o bit 13 eh 1
	and r0, r0, r6
	cmp r0, #0
	beq CHECK_READY
@se aqui, esta pronto para ser escrito
ldr r0, =0x53FBC040 @UTXD onde devo escrever cada char
ldrb r3, [r1] @r3 = valor a ser escrito, b no final indica byte
strb r3, [r0] @escrevendo no UART
add r1, r1, #1 @r5=contador de bytes escritos
add r5, r5, #1 @adiciono 1 ao numero de bytes escritos
cmp r5, r2 @vejo se escrevi tudo que precisava
bne CHECK_READY @se nao, volto para o laco
mov r0, r5 @retornar a quantidade de bytes escritos
pop {r1-r6}
movs pc, lr
	
@--------------------GET_PID--------------@
GET_PID:
ldr r0, =processo_atual
ldr r0, [r0] @coloco em r0 = valor de retorno o pid do processo
add r0, r0, #1 @adiciono 1 porque eu enumero os processos de 0 e nao de 1
movs pc, lr



@--------------------EXIT--------------@
EXIT:
@Pegar o PID para finalizar
ldr r0, =processo_atual
ldr r0, [r0]
@Finalizar = marcar como inativo no vetor de processos ativos
ldr r1, =processos_ativos
add r1, r1, r0 @ir ate ele
mov r0, #0 @marcar como inativo
strb r0, [r1] @escrever
@Trocar processos
b Trocando_processos
  
@--------------------FORK--------------@
@Primeiro, ver se existe algum processo que possa ser
@alocado ou se os oito ja estao alocados
@Lembrar que entra aqui com modo supervisor
FORK:
push {r1-r4} @salvando esses registrados, depois
@salvo eles no vetor de contexto. Se eu nao salvasse eles, iria reescrever
@registradores do processo pai

@Verificando se existe processo nao ativo a ser alocado para o fork
mov r0, #0 @contador, me diz tambem qual o numero do processo inativo
ldr r1, =processos_ativos
loop_verf:
	cmp r0, #8 @ver se ja percorreu todos
	beq Processo_INDISPONIVEL @se ja, dar erro
	ldrb r3, [r1, r0] @colocar em r3 o valor de =processos_ativos + contador
	cmp r3, #0
	beq Processo_disponivel
	add r0, r0, #1
	b loop_verf
@----------------Processo indisponivel----------------------@
Processo_INDISPONIVEL:
pop {r0-r3}
mov r0, #-1 @indica erro
msr CPSR_c, #0x13 @habilitando interrupcoes
movs pc, lr @volta para o codigo do usuario com erro
@----------------Processo indisponivel----------------------@

Processo_disponivel: @r0 = de 0 7 qual processo ativo
@marcar ID do processo a ser filho como ativo (coloca 1)
mov r3, #1 
ldr r1, =processos_ativos
strb r3, [r1, r0]  

@Agora preciso salvar o pc dele, que eh o meu lr estando como supervisor 

ldr r1, =Vetor_de_retorno @r0 aqui = numero do processo inativo que vai virar filho
str r14, [r1, r0, lsl #2] @aqui eh colocado o valor de retorno
@no vetor de retorno e na posicao pos_processo_vetor_processos*4
@logo o 0 fica em 0 bytes, o 1 em 4 bytes, o 2 em 8 bytes etc.

@agora preciso armazenar o contexto do processo
ldr r4, =Contexto_processos
add r4, r4, r0, lsl #6 @ logo r1 = Contexto_processos+PID_filho*64

@Salvando o CPSR, primeiro escrevo ele em r2, depois salvo
mrs r2, SPSR
str r2, [r4], #4 @salvo em r2 e adiciono em r1 o valor 4
@dai eu ja posso salvar outro valor em r1 agora, pois
@ele aponta 4 bytes a frente
@Salvando r0 a r3
mov r3, #0 @salvando r0 #0 = valor de retorno do processo filho
str r3, [r4], #4 @salvando r0
pop {r1} @salvando r1
str r1, [r4], #4
pop {r2} @salvando r2
str r2, [r4], #4
pop {r3} @salvando r3
str r3, [r4], #4
pop {r4}
push {r0-r3}

@Salvando os outros que nao estavam na pilha
ldr r1, =Contexto_processos
add r1, r1, r0, lsl #6 @ logo r1 = Contexto_processos+PID_filho*64
add r1, r1, #20 @adicionando 20 que eh o que ja pulei em cima

@r4-r12
mov r3, r4
str r3, [r1], #4
mov r3, r5
str r3, [r1], #4
mov r3, r6
str r3, [r1], #4
mov r3, r7
str r3, [r1], #4
mov r3, r8
str r3, [r1], #4
mov r3, r9
str r3, [r1], #4
mov r3, r10
str r3, [r1], #4
mov r3, r11
str r3, [r1], #4
mov r3, r12
str r3, [r1], #4



@--------------- Copiando o STACK e Setando R13 e R14 --------------@
push {r4-r8}
ldr r2, =processo_atual 
ldr r2, [r2] @r2 agora tem o numero do processo atual que preciso salvar no espaco do filho
@Apontando r3 para o STACK do processo filho
ldr r3, =PID1_STACK @ USR_STACK
sub r3, r3, r0, lsl #12 @r0 = numero do livre, subtrai 4 MB * PID
@Apontando r4 para o STACK do processo pai
ldr r4, =PID1_STACK @ USR_STACK
sub r4, r4, r2, lsl #12 @r2 = numero processo atual

msr CPSR_c, #0xDF @indo para modo system, porque dai eu posso pegar 
mov r2, r13  @r2 = stack pointer do pai, fim dele, valor menor que o comeco
mov r6, r14  @r6 = LR do pai
@voltando para modo supervisor!!
msr CPSR_c, #0xD3
@@COPIANDO O STACK
	@Vendo se eh necessario copiar
	cmp r4, r2 @comparando o valor do comeco(alto) stack do pai com o do atual dele
	beq acabou @se for igual, acabou a copia
CopiandoStack:
	ldr r7, [r4], #-4 @le o valor e diminui 4 para ler o proximo (descrescente)
	str r7, [r3], #-4 @escreve no stack do filho e desce para escrever o prox
	cmp r4, r2 @comparando o valor do comeco(alto) stack do pai com o do atual dele
	addlt r3, r3, #4
	blt acabou @se for menor, acabou a copia
	b CopiandoStack
acabou:

str r3, [r1], #4 @armazenando o SP dele e aumentando 4 para armazenar o lr
str r6, [r1], #4 @armazenando o lr do filho que deve ser igual ao do pai
pop {r4-r8}
pop {r0-r3}
add r0, r0, #1 @aumento o PID de retorno para o pai, porque indexo do 0
msr CPSR_c, #0x13 @habilitando interrupcoes e indo para supervisor 
movs pc, lr @retorno para o USER_CODE, pro pai

@-------------------------------Salvando Contexto e Trocando Processos-------------@
@Aqui devo ter vindo do GPT
Salvar_contexto_e_alternar_processos:
push {r0-r3}
@Salvando o endereco de retorno
ldr r0, =processo_atual
ldr r0, [r0]
ldr r1, =Vetor_de_retorno
@Como o GTP coloca no LR o PC+8, vou tirar 4
sub r14, r14, #4
str r14, [r1, r0, lsl #2] @salvando no vetor de retorno, na pos PID*4

@Obtendo endereco do vetor de contexto
ldr r1, =Contexto_processos
ldr r0, =processo_atual
ldr r0, [r0]
add r1, r1, r0, lsl #6 @chegando no espaco dedicado ao vetor

@Salvando CPSR
mrs r2, SPSR
str r2, [r1], #4
@Salvando de r0 a r3 (que empilhei mais cedo)
pop {r2}
str r2, [r1], #4
pop {r2}
str r2, [r1], #4
pop {r2}
str r2, [r1], #4
pop {r2}
str r2, [r1], #4
@Agora salvando de r4 ate r12
mov r2, r4
str r2, [r1], #4
mov r2, r5
str r2, [r1], #4
mov r2, r6
str r2, [r1], #4
mov r2, r7
str r2, [r1], #4
mov r2, r8
str r2, [r1], #4
mov r2, r9
str r2, [r1], #4
mov r2, r10
str r2, [r1], #4
mov r2, r11
str r2, [r1], #4
mov r2, r12
str r2, [r1], #4
@Salvando o famigerado r13 e r14 (preciso ir para modo system para isso)
msr CPSR_c, #0xDF @modo system
mov r2, r13
mov r3, r14
@Voltando para modo IRQ
msr CPSR_c, #0xD2 @modo IRQ sem interrupcoes
@Salvando agora r13 e r14
str r2, [r1], #4 @Salvando 
str r3, [r1]


@Trocando processos agora
Trocando_processos:
 ldr r0, =processo_atual
 ldr r1, [r0]
 ldr r0, =processos_ativos
 mov r2, #8
 ver_processo_a_trocar: @procuro o proximo processo ativo depois do atual
 cmp r2, #0 @se ja percorreu, parar
 beq Nenhum_processo_a_trocar
 cmp r1, #7
 moveq r1, #0 @se r1 for 7, retornar ao comeco, ir para 0
 addne r1, r1, #1 @se nao, basta adicionar 1 e continuar procurando
 ldrb r3, [r0, r1] @carrega o byte que diz se o processo esta ativo
 cmp r3, #1
 beq trocar_processo @se for 1, achei, ir troca-lo
 sub r2, r2, #1 @se aqui, nao achei ainda, diminuir o contador
 b ver_processo_a_trocar
 Nenhum_processo_a_trocar:
 @se nao achei, entrar em loop esperando uma interrupcao
 inf_loop:
 b inf_loop
 
 @Aqui eu troco o processo
 trocar_processo:
 ldr r0, =processo_atual
 str r1, [r0]
 @Coloco o endereco de retorno do processo que vou alternar para no lr
 @para depois fazer movs pc, lr normalmente
 ldr r0, =Vetor_de_retorno
 ldr r2, [r0, r1, lsl #2] @pego o pc e coloco em r2
 mov r14, r2
 @Restauro os outros registadores 
 @Primeiro r14 e r13 que sao complicados, preciso coloca-los no r13 e r14
 @do modo usuario
 ldr r0, =Contexto_processos
 add r0, r0, r1, lsl #6 @chego ao valor no vetor de contexto correspondente
 @ao do processo que vou trocar para
 add r0, r0, #60 @chegando ao valor de r14
 ldr r2, [r0], #-4 @r2 = r14
 ldr r3, [r0], #-4 @r3 = r13
 @Mudar para system e colocar la os valores de r13 e r14
 msr CPSR_c, #0xDF @System sem interrupcoes
 mov lr, r2 @colocando r14 em r14
 mov sp, r3 @colocando r13 em r13
 @Voltando para o modo Supervisor
 msr CPSR_c, #0xD3 @Supervisor sem interrupcoes
 @Restaurando o resto dos registradores
ldr r2, [r0], #-4
mov r12, r2
ldr r2, [r0], #-4
mov r11, r2
ldr r2, [r0], #-4
mov r10, r2
ldr r2, [r0], #-4
mov r9, r2
ldr r2, [r0], #-4
mov r8, r2
ldr r2, [r0], #-4
mov r7, r2
ldr r2, [r0], #-4
mov r6, r2
ldr r2, [r0], #-4
mov r5, r2
ldr r2, [r0], #-4
mov r4, r2
@Vou restaurar r3-r0 depois porque se nao fico sem registrador para usar
@Restaurando SPSR que e o primeiro no vetor de contexto, pois e o primeiro
@que gravei
ldr r2, =Contexto_processos
add r2, r2, r1, lsl #6
ldr r3, [r2]
msr SPSR, r3
@Restaurando agora o r3 - r0
ldr r1, [r0], #-4
mov r3, r1
ldr r1, [r0], #-4
mov r2, r1
ldr r1, [r0], #-4
ldr r0, [r0]
@Restaurando a execucao
msr CPSR_c, #0x12 @habilitando interrupcoes e vai para o IRQ
movs pc, lr


 

 

GPT_CR:
.word 0x53fa0000

GPT_SR:
.word 0x53FA0008

GPT_PR:
.word 0x53FA0004

GPT_OCR1:
.word 0x53FA0010

GPT_IR:
.word 0x53FA000C

URXD:
.word 0x53FB0000
UTXD:
.word 0x53FB0040
UCR1:
.word 0x53FBC080
UCR2:
.word 0x53FBC084
UCR3:
.word 0x53FBC088
UCR4:
.word 0x53FBC08C
UFCR:
.word 0x53FBC090
UBIR:
.word 0x53FBC0A4
UBMR:
.word 0x53FBC0A8

USR1:
.word 0x53FBC094
doisumdoissete:
.word 0x2127

zerosetezeroquatro:
.word 0x0704
 
 zerooitonovee:
 .word 0x089E
 zerooitoff:
 .word 0x08FF
 zeroctresquatro:
 .word 0x0C34
 doisdoiszeroum:
 .word 0x2201

processo_atual: .space 4
processos_ativos: .space 8

Vetor_de_retorno: .space 32 @32 bytes, 4 para cada um dos 8 processos
Contexto_processos: .space 512
