;**************************************************************************
; LAB SESSION 3 - EXERCISE 1 MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************
_TEXT SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS: _TEXT
	PUBLIC _checkSecretNumber, _fillUpAttempt

;__________________________________________________________________________
; ROUTINE THAT IMPLEMENTS THE FUNCTION: 
; unsigned int checkSecretNumber(unsigned char* number);
;__________________________________________________________________________ 

_checkSecretNumber PROC FAR
	; Passing arguments
	push bp 
	mov bp, sp 
	push bx ds cx
	; Saving the parameter
	lds bx, [bp+6] ; Store in DS:BX the pointer 'number'
	
	; Comparing the first digit with the rest
	mov cl, [bx][0] ; CL <- number[0]
	mov ch, [bx][1] ; CH <- number[1]
	cmp cl, ch
	je EQUAL
	mov ch, [bx][2] ; CH <- number[2]
	cmp cl, ch
	je EQUAL
	mov ch, [bx][3] ; CH <- number[3]
	cmp cl, ch
	je EQUAL
	
	; Comparing the second digit with 3rd and 4th
	mov cl, [bx][1] ; CL <- number[1]
	mov ch, [bx][2] ; CH <- number[2]
	cmp cl, ch
	je EQUAL
	mov ch, [bx][3] ; CH <- number[3]
	cmp cl, ch
	je EQUAL
	
	; Comparing the third digit with fourth
	mov cl, [bx][2] ; CL <- number[2]
	mov ch, [bx][3] ; CH <- number[3]
	cmp cl, ch
	je EQUAL
	
	; If there are not matches we should return 0
	mov ax, 0
	jmp FINISH
	
EQUAL:
	mov ax, 1

FINISH:
	; Restoring the stack
	pop cx ds bx
	pop bp
	ret
_checkSecretNumber ENDP

;__________________________________________________________________________
; ROUTINE THAT IMPLEMENTS THE FUNCTION: 
; void fillUpAttempt(unsigned int attempt, unsigned char* attemptDigits);
;__________________________________________________________________________ 
_fillUpAttempt PROC FAR
	; Passing arguments
	push bp 
	mov bp, sp 
	push bx ds cx dx ax si; Saving the registers that we are about to use
	; Saving the parameters
	mov cx, [bp+6] ; Store in CX the value of attempt
	lds bx, [bp+8] ; Store in DS:BX the pointer attempDigits

	call DECIMAL

	; Restoring the stack
	pop si ax dx cx ds bx
	pop bp
	ret

_fillUpAttempt ENDP

;__________________________________________________________________________
; SUBRUTINE TO TRANSLATE AN INTEGER TO AN ARRAY OF DIGITS
; INPUT: CX = Number to be printed in ASCII
; OUTPUT: Saves in the content of DS:CX the digits of the number
;__________________________________________________________________________ 

DECIMAL PROC NEAR
	; Moving the number to AX to divide it.
	MOV AX, CX 
	; To get the decimal character we need to divide by ten.
	MOV CX, 10
	; The number's max. size will be five digits plus the sentinel
	; so we write backguards from the sixth position.
	MOV SI, 4

	; Cleaning the array
	MOV BYTE PTR [BX][0], 0h 
	MOV BYTE PTR [BX][1], 0h
	MOV BYTE PTR [BX][2], 0h
	MOV BYTE PTR [BX][3], 0h
	
DIVIDE:
	; We have to set DX to zero each time we divide because it can
	; point to a different memory position (we are working with 16 bits divisors).
	MOV DX, 0 
	; Division.
	DIV CX 
	; Decreasing the pointer of the string to write the next character.
	DEC SI 
	; We know that the remainder wont be greater than a byte so we use 
	; DL to avoid the use of castings.
	MOV [BX][SI], DL 
	; If the quotient is not zero we continue with the algorithm.
	CMP AX, 0
	JNE DIVIDE
	
	; If the quotient is zero the algorithm stops.
	
	RET
DECIMAL ENDP

_TEXT ENDS
END
