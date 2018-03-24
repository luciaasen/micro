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

request db 'Please, introduce a number between 0 and 15: ', '$'

;; The reading buffer needs the first byte to save the 
;; max. number of bytes to read, another to save 
;; the number of bytes read and another 3 bytes
;; to save both digits of the number and the carriage
;; return.

read db 3, ?, 3 dup (?), '$'
errtxt db 'Number should be less than 15 and greater than 0.', 13, 10,'$'
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
	
	; Requesting a number
	
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET request ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	
	; Reading number
	
	MOV AH, 0Ah            ; Selecting the interruption.
	MOV DX, OFFSET read    ; DX needs the offset of the string.
	INT 21H                ; Reading from keyboard.
	
	CALL DECIMAL           ; Converting to decimal.
	CALL CHECK             ; Checking if the number is valid.
	
	; Now that the number is valid we can 
	; convert it to binary.
	
	MOV BX, 0 	           ; Cleaning BX.
	MOV BL, AL             ; The procedure needs the number in BL
	CALL BINARY            ; Calling the function.
	
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP


;__________________________________________________________________________
; SUBRUTINE TO TRANSLATE A SEQUENCE OF ASCII VALUES TO INTEGER
; INPUT:  A string in the memory position with tag 'read'
; OUTPUT: AL = Decimal value of the string 
;__________________________________________________________________________ 

DECIMAL PROC NEAR

	MOV AL, read[2] ; Saving in AL the firt character read.
	ADD AL, -48     ; Converting it to a non-ascii value.
	
	; Checking if the number of characters is 1 or 2
	
	MOV BL, read[1] ; Number of characters read.
	CMP BL, 2       ; If there is only one character read...
	JNE ONE         ; ...we have finished.
	
	; Converting character 1
	
	MOV CL, 10      ; The first character is the tens.
	MUL CL          ; Multiplying the character.
	
	; Converting character 2
	
	MOV CL, read[3] ; Saving the second character.
	ADD CL, -48     ; Converting it to non-ascii.
	ADD AL, CL      ; Adding the complete number

ONE:
	RET

DECIMAL ENDP

;__________________________________________________________________________
; SUBRUTINE TO CHECK IF A NUMBER BELONG TO RANGE [0,15]
; INPUT:  AL = Number to check.
; OUTPUT: If number does not belong to the range we print an error message
; 		  and stop the execution. 
;__________________________________________________________________________

CHECK PROC NEAR
	CMP AL, 15 ; 15 should be greater or equal to 15.
	JG ERROR   ; In other case we raise the error.
	
	CMP AL, 0  ; AL should be greater or equal to 0.
	JL ERROR   ; In other case we raise the error.
	RET

ERROR:
	; Printing error.
	MOV AH, 9h            ; First we select the interruption type.
	MOV DX, OFFSET errtxt ; Now we move to dx the offset of the string.
	INT 21H               ; Calling the interruption.
	
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
	
CHECK ENDP

;__________________________________________________________________________
; SUBRUTINE TO TRANSLATE AN INTEGER TO BINARY
; INPUT:  BX = Number to be translated to binary.
; OUTPUT: DX = Segment where the string is saved, AX = Offset of the string.
;__________________________________________________________________________ 

BINARY PROC NEAR
	MOV AX, BX ; Moving the number to AX to divide it.
	MOV CL, 2  ; To get the binary characters 
	           ; we need to divide by two.
	MOV BX, 4  ; The number's max. size will be 
	           ; four digits so we write backguards 
			   ; from the fourth position.
	
DIVIDE:
	DIV CL             ; Division.
	ADD BX, -1         ; Decreasing the pointer of the string 
	                   ; to write the next character.
	
	MOV bin[BX], AH    ; Writing the remainder in memory.
	MOV AH, 0          ; Cleaning remainder.
	
	CMP AL, 0          ; If the quotient is not zero we 
	JNE DIVIDE         ; continue with the algorithm.
	
	; If the quotient is zero the algorithm stops.
	
	MOV DX, DS         ; DX contains the string's segment.
	MOV AX, OFFSET bin ; AX contains the OFFSET.
	RET
BINARY ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
