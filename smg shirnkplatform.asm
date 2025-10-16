;SMG shrinkplatform so you won't need MOP
;THE SOUND IS THE UNUSED BOING SO YOU CAN PLACE A CUSTOM ONE :)

;BEHAVIOR
00 09 00 00
11 01 00 01
2A 00 00 00 09 00 DD C0 ;change your col pointer
0C 00 00 00 XX XX XX XX ;init function HERE
08 00 00 00
0C 00 00 00 YY YY YY YY ;loop fuction HERE
0C 00 00 00 80 38 39 CC ;asm fuction for col
09 00 00 00
;


;//////////////////////////////////////////

;ASM FUNCTION INIT
ADDIU $sp, $sp, 0xFFE8
SW $ra, 0x0014 ($sp)


LUI $t0, 0x8036 		;carga la parte alta de esa direccion, osea el inicio del struct del objeto
LW  $t0, 0x1160($t0)    	;completa la palabro :c
SW $zero, 0x0040($t0)   		;carga 0 en la variable que luego va a comparar

LW RA, 0x14 (SP)
JR RA
ADDIU SP, SP, 0x0018


;//////////////////////////////////////////


;ASM FUNCTION LOOP
ADDIU $sp, $sp, 0xFFE8
SW $ra, 0x0014 ($sp)

JAL 0x00A8F3F			; cambiar al pasar a hex funcion correcta es 0C 0A 8F 3F
NOP 

LUI $t0, 0x8036 		;carga la parte alta de esa direccion, osea el inicio del struct del objeto
LW  $t0, 0x1160($t0)    	;completa la palabro :c

LW $t2, 0x0040($t0)  		;carga una variable que deberiaaaa estar en 0
BNE $t2, $zero, @@shrink 	;salta si es que la variable no es 0
NOP

BNE $v0, $zero, @@colliding 	;salta si es que esta pisando, entra aqui solo si la variable es 0
NOP
BEQ $zero, zero, @@nocol
NOP




@@colliding:
NOP

LUI a0, 0x3072		;button press: 305A, 3072 boing? unused sound
JAL 0x802CA144 
ORI a0, a0, 0x0081 		
LUI $t0, 0x8036 		;carga la parte alta de esa direccion, osea el inicio del struct del objeto, VUELVE A CARGAR POR EL JAL
LW  $t0, 0x1160($t0)   		;completa la palabro :c
ADDIU $t2, $t2, 0x0001 		;suma t2 = t2 + 1
SW $t2, 0x0040($t0)   		;guarda la variable actualizada





@@shrink:
LUI $t0, 0x8036 		;carga la parte alta de esa direccion, osea el inicio del struct del objeto, VUELVE A CARGAR POR EL JAL
LW  $t0, 0x1160($t0)   		;completa la palabro :c

LUI $t1, 0x3C00  		; osea 0.007 en float
LWC1 $f2, 0x002C($t0)       	; Carga la velocidad de rotación actual Load Word Coprocessor 1 for floats EJE Z
MTC1 $t1, $f4 			;mueve al coprosesador 1 osea para float

SUB.S f2, f2 ,f4       		;LE RESTA EN float ; ahora viene comprobacion para ver si es menor a 0

LUI $t3, 0x0000      		; Cargar 0.0 en parte alta
MTC1  $t3, $f4         		; Mover 0.0 a registro de float
C.LT.S $f2, $f4        		; ¿$f2 < 0.0?
BC1T  @@menor     		; Salta si condición verdadera
NOP                   		; Delay slot obligatorio



LWC1 $f3, 0x0034($t0)       	; Carga la velocidad de rotación actual Load Word Coprocessor 1 for floats EJE Z
MTC1 $t1, $f5 			;mueve al coprosesador 1 osea para float

SUB.S f3, f3 ,f5      		;LE RESTA EN float


SWC1 $f2, 0x002C($t0)  		;GUARDA EL FLOAT eje x
SWC1 $f3, 0x0034($t0) 		;GUARDA EL FLOAT eje z
BEQ $zero, $zero, @@nocol 	;salta al final


@@menor:



NOP
SW $zero, 0x74($t0) ;unload object ,JAL 0x8029ED20 		
NOP



@@nocol:
LW RA, 0x14 (SP)
JR RA
ADDIU SP, SP, 0x0018



