;**************************************************************************
; LAB SESSION 2 - EXERCISE 3 MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT

;; The reading buffer needs the first byte to save the 
;; max. number of bytes to read, another to save 
;; the number of bytes read and another 3 bytes
;; to save both digits of the number and the carriage
;; return.
read db 3, ?, 3 dup (?), '$'
errtxt db 'El numero debe ser menor que 15 y mayor que 0.$'
bin db 4 dup (0)
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
	
	; Selecting the interruption
	MOV AH, 0Ah
	; DX needs the offset of the string
	mov DX, OFFSET read
	; Reading from keyboard
	INT 21H
	
	; Converting to decimal
	CALL DECIMAL
	
	; Checking if the number is valid
	CALL CHECK
	
	MOV BX, 0
	MOV BL, AL
	CALL BINARY
	
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP


;__________________________________________________________________________
; SUBRUTINE TO TRANSLATE AN INTEGER TO ASCII
; INPUT: A string in the memory position with tag 'read'
; OUTPUT: AL = Decimal value of the string 
;__________________________________________________________________________ 

DECIMAL PROC NEAR
	; Saving in AL the firt character read
	MOV AL, read[2]
	; Converting it to a non-ascii value
	ADD AL, -48
	
	; Checking if the number of characters is 1 or 2
	; Number of characters read
	MOV BL, read[1]
	CMP BL, 2
	; If there is only one character read we are finished
	JNE ONE
	
	; As there are 2 characters the first of them is the tens
	MOV CL, 10
	MUL CL
	; Now we read the second character
	MOV CL, read[3]
	; Converting it to non-ascii
	ADD CL, -48
	; Adding the complete number
	ADD AL, CL

ONE:
	RET

DECIMAL ENDP

CHECK PROC NEAR
	; 15 should be greater or equal to 15
	CMP AL, 15
	JG ERROR
	; AL should be greater or equal to 0
	CMP AL, 0
	JL ERROR
	RET
ERROR:
	; Printing error.
	MOV AH, 9h ; First we select the interruption type.
	MOV DX, OFFSET errtxt ; Now we move to dx the offset of the string.
	INT 21H ; Calling the interruption.
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
	
CHECK ENDP

;__________________________________________________________________________
; SUBRUTINE TO TRANSLATE AN INTEGER TO BINARY
; INPUT: BX = Number to be translated to BINARY
; OUTPUT: DX = Segment where the string is saved, AX = Offset of the string
;__________________________________________________________________________ 

BINARY PROC NEAR
	; Moving the number to AX to divide it.
	MOV AX, BX 
	; To get the binary characters we need to divide by two.
	MOV CX, 2
	; The number's max. size will be four digits so we write 
	; backguards from the fourth position.
	MOV BX, 4 
	
	; We have to make sure that the string in memory is clean,
	; in other case there could be overriden values if we make
	; multiple executions at a time.
	MOV WORD PTR bin, 0
	MOV WORD PTR bin[2], 0
	
DIVIDE:
	; We have to set DX to zero each time we divide because it can
	; point to a different memory position (we are working with 16 bits divisors).
	MOV DX, 0 
	; Division.
	DIV CX 
	; Decreasing the pointer of the string to write the next character.
	ADD BX, -1 
	; We know that the remainder wont be greater than a byte so we use 
	; DL to avoid the use of castings.
	MOV bin[BX], DL 
	; If the quotient is not zero we continue with the algorithm.
	CMP AX, 0
	JNE DIVIDE
	
	; If the quotient is zero the algorithm stops.
	
	; DX contains the segment where the string is saved.
	MOV DX, DS
	; AX contains the OFFSET.
	MOV AX, OFFSET bin
	RET
BINARY ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
