;**************************************************************************
; LAB SESSION 1 - EXERCISE C MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
;-- complete with the data requested
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
	
	MOV BX, 011H
	MOV 
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
