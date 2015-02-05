@Create8processes_delete_PID_4_and_recreate_over_and_over@
.align 4
@Limpando registradores
mov r0, #0
mov r1, #0
mov r3, #0
mov r4, #0
mov r5, #0
mov r6, #0
mov r7, #0
mov r8, #0
mov r9, #0
mov r10, #0
mov r11, #0
mov r12, #0

@@@-------------Imprimindo "Antes do FORK\n"-----------------@@
ldr r1, =string 
mov r2, #14
mov r7, #4
svc 0x0 
@@@-------------Imprimindo "Antes do FORK\n"-----------------@@

@@@-------------Pai 1-----------------@@
PROCESSO_PAI_1:
ldr r1, =string_pai_1
mov r2, #9
mov r7, #4
svc 0x0
mov r7, #0x14 @get pid
svc 0x0

@agora r0 tem o pid
ldr r1, =FatherPID
add r0, r0, #48 @48 para converter para ascii
strb r0, [r1]
mov r2, #1
mov r7, #4
svc 0x0

ldr r1, =NewLine
mov r2, #1
mov r7, #4
svc 0x0


mov r0, #01
mov r1, #11
mov r2, #21
mov r3, #31
mov r4, #41
mov r5, #51
mov r6, #61
mov r7, #71
mov r8, #81
mov r9, #91
mov r10, #101
mov r11, #111
mov r12, #121
mov r14, #141

push {r5-r12}



@@@-------------FORK2-PAI-1-----------------@@
FORK:
mov r7, #2
svc 0x0 @Fazendo FORK
cmp r0, #0
beq PROCESSO_FILHO_1 @Se retornou 0, eh o processo filho
cmp r0, #-1
beq FORK 			
bne FORK
@@@-------------FORK2-PAI-1-----------------@@
@@@-------------Pai 1-----------------@@

@@@--------------------------Filho-------------------------------@@
PROCESSO_FILHO_1:
ldr r1, =string_filho_1
mov r2, #11
mov r7, #4
svc 0x0

mov r7, #0x14 @get pid
svc 0x0



ldr r1, =SonPID
add r0, r0, #48 @48 para converter para ascii
strb r0, [r1]
mov r2, #1
mov r7, #4
svc 0x0

ldr r1, =NewLine
mov r2, #1
mov r7, #4
svc 0x0

mov r0, #0
mov r1, #1
mov r2, #2
mov r3, #3
mov r4, #4
mov r5, #5
mov r6, #6
mov r7, #7
mov r8, #8
mov r9, #9
mov r10, #10
mov r11, #11
mov r12, #12
mov r14, #14

pop {r5-r12}

b inf

@@@--------------------------Filho-------------------------------@@



PROCESSO_4:
mov r7, #0x1
svc 0x0


inf:
mov r7, #0x14 @get pid
svc 0x0
cmp r0, #4
beq PROCESSO_4
b inf
.data
string: .ascii "Antes do FORK\n"
string2: .ascii "Yay APOS FORK\n"
string_filho_1: .ascii "Filho PID: "
string_pai_1: .ascii "Pai PID: "
FatherPID: .ascii "0"
SonPID: .ascii "0"
NewLine: .ascii "\n"