;**************************************************************************
; LAB SESSION 1 - EXERCISE C MBS 2018
; TEAM #
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

;**************************************************************************
; ASSEMBLY CODE STRUCTURE EXAMPLE. MBS 2018
;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
;-- complete with the data requested
DATOS ENDS
;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ; initialization example, 64 bytes set to 0
PILA ENDS
;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
RESULT DW 0,0 ; initialization example. 2 WORDS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; CODE SEGMENT DEFINITION
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; BEGINNING OF THE MAIN PROCEDURE
INICIO PROC
; INITIALIZE THE SEGMENT REGISTERS
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; LOAD THE STACK POINTER WITH THE HIGHEST VALUE

	;
	; PROGRAM START
	; Initialize ds, bx y di with the data necessary 
	; to test the address accessed in ex 1 c)
	MOV BX, 0511H
	MOV DS, BX
	MOV BX, 0211H
	MOV DI, 1010H
	 
	; The expected accessed address here is 06344h
	MOV AL, DS:[1234H]
	; The expected accessed address here is 05321H
	MOV AX, [BX]
	; The expected accessed address here is 06120H
	MOV [DI], AL

	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO