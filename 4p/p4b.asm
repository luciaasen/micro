;**************************************************************************
; LAB SESSION 4 - EXERCISE 2 MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT

cipher db 'Hello, testing the Cesars cipher','$'
newline db 13,10,'$' ; <- Used to jump to a new line after requesting

DATOS ENDS

;**************************************************************************
; STACK SEGMENT DEFINITION
PILA SEGMENT STACK "STACK"
PILA ENDS

;**************************************************************************
; EXTRA SEGMENT DEFINITION
EXTRA SEGMENT
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
	
	MOV AX, 10
	MOV BX, 5
	SUB BX, AX
	
	; Codifying
	MOV DX, OFFSET cipher
	MOV AH, 12h
	INT 55h
	
	; Printing new line
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	
	; Decoding
	MOV DX, OFFSET cipher
	MOV AH, 13h
	INT 55h

	
END_PROG:
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
	
INICIO ENDP



; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
