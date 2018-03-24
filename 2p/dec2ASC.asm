;**************************************************************************
; LAB SESSION 2 - EXERCISE 1 MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT
result db 7 dup (0) ; The maximum size of a 16 bits number will be 5 characters.
					; also we need space for the sentinel and the linebreak.
					; The initial value is zero, so if the number has less than 
					; five digits those non-used bytes will be blank spaces. 
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
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	; FIRST EXAMPLE -> 65335 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; BX contains the number to be printed.
	MOV BX, 65335 
	
	; Calling the function. BX should have the number to be printed.
	CALL ASCII 
	
	; Print the value.
	MOV AH, 9h            ; First we select the interruption type.
	MOV DX, OFFSET result ; Now we move to dx the offset of the string.
	INT 21H               ; Calling the interruption.
	
	;;;;;;;;;;;;;;;;;;;;;;;;;
	; SECOND EXAMPLE -> 1234 ;
	;;;;;;;;;;;;;;;;;;;;;;;;;
	
	; BX contains the number to be printed.
	MOV BX, 1234
	
	; Calling the function. BX should have the number to be printed.
	CALL ASCII 
	
	; Print the value.
	MOV AH, 9h            ; First we select the interruption type.
	MOV DX, OFFSET result ; Now we move to dx the offset of the string.
	INT 21H               ; Calling the interruption.
	
	;;;;;;;;;;;;;;;;;;;;;;;;
	; THIRD EXAMPLE -> 416 ;
	;;;;;;;;;;;;;;;;;;;;;;;;
	
	; BX contains the number to be printed.
	MOV BX, 416
	
	; Calling the function. BX should have the number to be printed.
	CALL ASCII 
	
	; Print the value.
	MOV AH, 9h            ; First we select the interruption type.
	MOV DX, OFFSET result ; Now we move to dx the offset of the string.
	INT 21H               ; Calling the interruption.
	
	;;;;;;;;;;;;;;;;;;;;;;;
	; FOURTH EXAMPLE -> 0 ;
	;;;;;;;;;;;;;;;;;;;;;;;
	
	; BX contains the number to be printed.
	MOV BX, 7
	
	; Calling the function. BX should have the number to be printed.
	CALL ASCII 
	
	; Print the value.
	MOV AH, 9h            ; First we select the interruption type.
	MOV DX, OFFSET result ; Now we move to dx the offset of the string.
	INT 21H               ; Calling the interruption.
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP


;__________________________________________________________________________
; SUBRUTINE TO TRANSLATE AN INTEGER TO ASCII
; INPUT: BX = Number to be printed in ASCII
; OUTPUT: DX = Segment where the string is saved, AX = Offset of the string
;__________________________________________________________________________ 

ASCII PROC NEAR
	; Moving the number to AX to divide it.
	MOV AX, BX 
	; To get the decimal character we need to divide by ten.
	MOV CX, 10
	; The number's max. size will be five digits plus the sentinel
	; so we write backguards from the sixth position.
	MOV BX, 6 
	
	; We have to make sure that the string in memory is clean,
	; in other case there could be overriden values if we make
	; multiple executions at a time.
	MOV WORD PTR result, 0
	MOV WORD PTR result[2], 0
	MOV result[4], 0
	
	; Writing the sentinel at the end of the string.
	MOV result[BX], '$'
	; Writing the linebreak, if we print multiple numbers we need it.
	ADD BX, -1
	MOV result[BX], 10
DIVIDE:
	; We have to set DX to zero each time we divide because it can
	; point to a different memory position (we are working with 16 bits divisors).
	MOV DX, 0 
	; Division.
	DIV CX 
	; We have to add this value to the remainder to convert it to ASCII.
	ADD DX, 030h
	; Decreasing the pointer of the string to write the next character.
	ADD BX, -1 
	; We know that the remainder wont be greater than a byte so we use 
	; DL to avoid the use of castings.
	MOV result[BX], DL 
	; If the quotient is not zero we continue with the algorithm.
	CMP AX, 0
	JNE DIVIDE
	
	; If the quotient is zero the algorithm stops.
	
	; DX contains the segment where the string is saved.
	MOV DX, DS
	; AX contains the OFFSET.
	MOV AX, OFFSET result
	RET
ASCII ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
