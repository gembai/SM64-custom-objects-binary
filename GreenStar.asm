;GREEN STAR CUSTOM OBJ
;WORKS JUST LIKE NORMAL STAR but make sound and you collect it in air
;PROS: You can have yellow and green
;CONS: both show yellow at collect

;ptsss this is not used *wink*

;BEHAVIOR
00 06 00 00
11 01 00 01
0C 00 00 00 80 2A 41 20
0C 00 00 00 80 2F 24 F4
08 00 00 00
0C 00 00 00 zz zz zz zz //fuction 3
0C 00 00 00 80 2F 25 B0
0C 00 00 00 xx xx xx xx //fuction 1
0C 00 00 00 yy yy yy yy //function 2
09 00 00 00





;//////////////////////////////////////////////

;FUNCTION 1
;FUNCTION THAT CHANGES THE MODEL TO A CUSOM ONE JUST IF THE STAR IS UNCOLLECTED (runs in the loop, after the vanilla ones)
ADDIU SP, SP, 0xFFE8 
SW RA, 0x14(SP)

LI A0, 0x7A	;cargar 0x7A (modelo de estrella amarilla) en A0
JAL 0x802A4F04	;llamar a cur_obj_has_model(u16 modelID)
NOP		;evitar crahseo

BEQZ V0, @@end	;si no es igual (retorna 0), saltar a @@end
NOP		;evitar crahseo



LI A0, 0xC6	;cargar 0xC6 (modelo estrella verde) en A0
JAL 0x802A04C0	;llamar a cur_obj_set_model(s32 modelID)
NOP			; delay slot

@@end:

LW RA, 0x14(SP)
JR RA
ADDIU SP, SP, 0x18



;//////////////////////////////////////////////



;FUNCTION 2
;FUNCTION THAT PLAY SOUND AFTER AN INTERVAL OF TIME IF YOU ARE CLOSE ENOUGH 
ADDIU SP, SP, 0xFFE8
SW RA, 0x14(SP)

;verificar el timer
LUI $t0, 0x8036 		;carga la parte alta de esa direccion, osea el inicio del struct del objeto
LW  $t0, 0x1160($t0)    	;completa la palabro 

; Leer o->oTimer
LW  $t1, 0x0154($t0)        ; T1 = oTimer
LI  $t3, 0x1E			;30 en hex
DIVU $t1, $t3               ; Divide T1 / 30
MFHI $t2                   ; T2 = Resto

BNEZ $t2, @@end            ; Si el resto no es cero, salir
NOP

;calcular distancia de el objeto a mario: 8029E2F8	f32 dist_between_objects(struct Object *obj1, struct Object *obj2);

LUI $t0, 0x8036 		;carga la parte alta de esa direccion, osea el inicio del struct del objeto
LW  $t0, 0x1160($t0)    	;completa la palabro (redundante ya que se llama arriba)


LUI $t4, 0x8036 		;carga la parte alta de esa direccion, osea el inicio del struct del objeto
LW  $t4, 0x1158($t4)    	;completa la palabro DE MARIO
				;ahora mismo esta en t0 el objeto (si mismo), y en t2 el otro objeto (mario)
;llamar a funcion
;comparar con 1000 en float

    ADDU  $a0, $t0, $zero     ; a0 = objeto actual
    ADDU  $a1, $t4, $zero     ; a1 = mario

    JAL   0x8029E2F8          ; llama a dist_between_objects
    NOP                       ; para evitar crasheo xd

    ; Comparar si la distancia es MAYOR a 1000.0
    LUI   $at, 0x44fa         ; 2000.0f
    MTC1  $at, $f2
    C.LT.S $f2, $f0           ; if (2000.0 < distancia)
    BC1T  @@end               ; salta si verdadero (o sea si distancia > 2000.0)
    NOP

;sonar sonido
ADDU  $a0, $zero, $zero         ; a0 = sonido
LUI a0, 0x3074 			;Big star jumping sound
JAL 0x802CA144 			;funcion de sonido
ORI a0, a0, 0x0081 
NOP

@@end:
NOP

LW RA, 0x14(SP)
JR RA
ADDIU SP, SP, 0x18


;//////////////////////////////////////////////


;FUNCTION 3
;SET UNDERWATER STAR DANCE AT TOUCH
ADDIU SP, SP, 0xFFE8
SW RA, 0x14(SP)


LUI T0, 0x8036
LW A1, 0x1158(T0)
JAL 0x802A1424
LW A0, 0x1160(T0)

BEQ V0, R0, @@colliding
NOP

	LUI T0, 0x8034
LH T1, 0xAFA0(T0)
ANDI T1, T1, 0x8000
LUI T2, 0x0001
BEQ T2, R0, @@aPressed
NOP

	
		LUI T1, 0x0000 ;Set state 0x00001303 = UNDERWATER STAR DANCE	
		ORI T1, T1, 0x1303
		SW T1, 0xB17C(T0)



@@aPressed:

@@colliding:

LW RA, 0x14(SP)
JR RA
ADDIU SP, SP, 0x18



