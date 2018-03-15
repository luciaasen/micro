;**************************************************************************
; LAB SESSION 1 - EXERCISE B MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
	COUNTER db ? ; A byte not initialized
	GRAB dw 0CAFEH ; Two bytes initialized
	TABLE100 db 100 dup(?) ; A table of 100 bytes not initialized
	ERROR1  db "Incorrect data. Try again" ; A string of bytes
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

	;; Moving 6th character of ERROR1 to TABLE100[053h]
	MOV AL, ERROR1[5]
	MOV TABLE100[053H], AL

	;; Copying the content of the variable GRAB to TABLE100[22H]
	;; We assume that the position n of an array is array[n]
	MOV AX, GRAB
	;; TABLE100 is an array of bytes so we need a casting
	MOV WORD PTR TABLE100[2H], AX

	;; Coping most significance byte of GRAB into COUNTER
	;; AX has already the complete value of GRAB
	MOV COUNTER, AH

	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO