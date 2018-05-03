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

request_c db 'Introduce a command (quit, cod, dec): ','$'
request_enc db 'Introduce a string to be encoded: ','$'
request_dec db 'Introduce a string to be decoded: ','$'
newline db 13,10,'$' ; <- Used to jump to a new line
cipher db 20, ?, 21 dup (?) ; Here is stored the string requested to the user

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

LOOP1:
	; Printing new line
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	
	; Checking if the previous string was a command (dec or cod)
	CMP AL, 12h
	JE COD
	CMP AL, 13h
	JE DECO

	; If not we request a command to the user
	MOV AH, 9h 			     ; First we select the interruption type.
	MOV DX, OFFSET request_c ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
	
	; Reading string
	MOV AH, 0Ah            ; Selecting the interruption.
	MOV DX, OFFSET cipher  ; DX needs the offset of the string.
	INT 21H                ; Reading from keyboard.
	
	; Adding sentinel and checking if the string is a valid command
	CALL ADDSENT
	CALL CHECKCOMMAND
	JMP LOOP1

COD:	

	; Requesting string
	MOV AH, 9h 			       ; First we select the interruption type.
	MOV DX, OFFSET request_enc ; Now we move to dx the offset of the string.
	INT 21H                    ; Calling the interruption.
	
	; Reading string
	MOV AH, 0Ah            ; Selecting the interruption.
	MOV DX, OFFSET cipher  ; DX needs the offset of the string.
	INT 21H                ; Reading from keyboard.
	CALL ADDSENT           ; Adding the sentinel
	
	; Printing new line
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	
	; Codifying
	MOV DX, OFFSET cipher
	ADD DX, 2
	MOV AH, 12h
	INT 55h
	MOV AL, 0
	JMP LOOP1

DECO:

	; First we request an option to the user
	MOV AH, 9h 			       ; First we select the interruption type.
	MOV DX, OFFSET request_dec ; Now we move to dx the offset of the string.
	INT 21H                    ; Calling the interruption.
	
	; Reading string
	MOV AH, 0Ah            ; Selecting the interruption.
	MOV DX, OFFSET cipher  ; DX needs the offset of the string.
	INT 21H                ; Reading from keyboard.
	CALL ADDSENT           ; Adding the sentinel
	
	; Printing new line
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	
	; Decoding
	MOV DX, OFFSET cipher
	ADD DX, 2
	MOV AH, 13h
	INT 55h
	MOV AL, 0
	JMP LOOP1
	
END_PROG:
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
INICIO ENDP

;__________________________________________________________________________
; SUBRUTINE TO ADD A SENTINEL TO THE STRING REQUESTED TO THE USER
;__________________________________________________________________________

ADDSENT PROC NEAR

	MOV BX, 0
	MOV BL, cipher[1]        ; Number of characters read
	ADD BL, 2
	MOV cipher[BX], '$'
	RET 
ADDSENT ENDP

;__________________________________________________________________________
; SUBRUTINE TO CHECK THE COMMAND REQUESTED TO THE USER
; If command is quit the program ends, if it is cod it returns 12h in al,
; if it is dec returns 13h al.
;__________________________________________________________________________

CHECKCOMMAND PROC NEAR
	MOV BX, 0
	MOV BL, cipher[1]
	CMP BL, 4
	JNE CHECK2
	CMP WORD PTR cipher[2], 'uq'
	JNE ENDCHECK
	CMP WORD PTR cipher[4], 'ti'
	JE END_PROG
	JMP ENDCHECK
CHECK2:
	CMP BL, 3
	JNE ENDCHECK
	CMP WORD PTR cipher[2], 'oc'
	JNE CHECK3
	CMP BYTE PTR cipher[4], 'd'
	JNE CHECK3
	MOV AL, 12h
	JMP ENDCHECK
CHECK3:
	CMP WORD PTR cipher[2], 'ed'
	JNE ENDCHECK
	CMP BYTE PTR cipher[4], 'c'
	JNE ENDCHECK
	MOV AL, 13h
	
ENDCHECK:
	RET

CHECKCOMMAND ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
