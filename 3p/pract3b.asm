;**************************************************************************
; LAB SESSION 3 - EXERCISE 2 MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************
_TEXT SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS: _TEXT
	PUBLIC _computeMatches, _computeSemiMatches

;__________________________________________________________________________
; ROUTINE THAT IMPLEMENTS THE FUNCTION: 
; unsigned int computeMatches(unsigned char* secretNum, unsigned char* attemptDigits);
;__________________________________________________________________________ 

_computeMatches PROC FAR
	; Passing arguments
	push bp 
	mov bp, sp 
	push bx ds cx si es
	; Saving the parameter
	lds bx, [bp+6] ; Store in DS:BX the pointer 'secretNum'
	les si, [bp+10] ; Store in ES:si the pointer 'attemptDigits'
	
	mov ax, 0 ; Initializing the return value
	
	; Comparing the first digit with the rest
	mov cl, [bx][0] ; CL <- secretNum[0]
	mov ch, es:[si][0] ; CH <- attemptDigits[0]
	cmp cl, ch
	jne J1
	add ax, 1
J1:	
	mov cl, [bx][1] ; CL <- secretNum[1]
	mov ch, es:[si][1] ; CH <- attemptDigits[1]
	cmp cl, ch
	jne J2
	add ax, 1
J2:
	mov cl, [bx][2] ; CL <- secretNum[2]
	mov ch, es:[si][2] ; CH <- attemptDigits[2]
	cmp cl, ch
	jne J3
	add ax, 1
J3:
	mov cl, [bx][3] ; CL <- secretNum[3]
	mov ch, es:[si][3] ; CH <- attemptDigits[3]
	cmp cl, ch
	jne FINISH
	add ax, 1

FINISH:
	; Restoring the stack
	pop es si cx ds bx
	pop bp
	ret
_computeMatches ENDP

;__________________________________________________________________________
; ROUTINE THAT IMPLEMENTS THE FUNCTION: 
; unsigned int computeSemiMatches(unsigned char* secretNum, unsigned char* attemptDigits);
;__________________________________________________________________________ 

_computeSemiMatches PROC FAR
	; Passing arguments
	push bp 
	mov bp, sp 
	push bx ds cx si es
	; Saving the parameter
	lds bx, [bp+6] ; Store in DS:BX the pointer 'secretNum'
	les si, [bp+10] ; Store in ES:si the pointer 'attemptDigits'
	
	mov ax, 0 ; Initializing the return value
	
	; As we request the user a number without repeated digits
	; (that control is implemented in the C programm) we can assume
	; that there will not be any repetitions and make easier the assembly code.
	
	; Comparing the first digit with the rest
	mov cl, [bx][0] ; CL <- secretNum[0]
	mov ch, es:[si][1] ; CH <- attemptDigits[1]
	cmp cl, ch
	jne S11
	inc ax ; If they are equal we have a semi-match 
	jmp S2 ; and we can stop comparing the first digit
S11:
	mov ch, es:[si][2] ; CH <- attemptDigits[2]
	cmp cl, ch
	jne S12
	inc ax
	jmp S2
S12:
	mov ch, es:[si][3] ; CH <- attemptDigits[3]
	cmp cl, ch
	jne S2
	inc ax
	
S2:	
	; Comparing the second digit with the rest
	mov cl, [bx][1] ; CL <- secretNum[1]
	mov ch, es:[si][0] ; CH <- attemptDigits[0]
	cmp cl, ch
	jne S21
	inc ax
	jmp S3
S21:
	mov ch, es:[si][2] ; CH <- attemptDigits[2]
	cmp cl, ch
	jne S22
	inc ax
	jmp S3
S22:
	mov ch, es:[si][3] ; CH <- attemptDigits[3]
	cmp cl, ch
	jne S3 
	inc ax

S3:	
; Comparing the third digit with the rest
	mov cl, [bx][2] ; CL <- secretNum[2]
	mov ch, es:[si][0] ; CH <- attemptDigits[0]
	cmp cl, ch
	jne S31
	inc ax
	jmp S4
S31:
	mov ch, es:[si][1] ; CH <- attemptDigits[1]
	cmp cl, ch
	jne S32
	inc ax
	jmp S4
S32:
	mov ch, es:[si][3] ; CH <- attemptDigits[3]
	cmp cl, ch
	jne S4
	inc ax

S4:

	; Comparing the first digit with the rest
	mov cl, [bx][3] ; CL <- secretNum[3]
	mov ch, es:[si][0] ; CH <- attemptDigits[0]
	cmp cl, ch
	jne S41
	inc ax
	jmp FIN
S41:
	mov ch, es:[si][1] ; CH <- attemptDigits[1]
	cmp cl, ch
	jne S42
	inc ax
	jmp FIN
S42:
	mov ch, es:[si][2] ; CH <- attemptDigits[2]
	cmp cl, ch
	jne FIN
	inc ax

FIN:
	; Restoring the stack
	pop es si cx ds bx
	pop bp
	ret
_computeSemiMatches ENDP

_TEXT ENDS
END



