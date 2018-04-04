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

;***************** MULTIPLY DATA ********************

bin db 4 dup (0)

result db 7 dup (0) ; Multiplying vector(1,4) x matrix(4,7) results in a
                    ; vector(1,7) for which we allocate memory

matrix db 1, 0, 0, 0; ;We allocate the 7x4 Transposed Generation Matrix
       db 0, 1, 0, 0  ;to make a better memory access when multiplying
       db 0, 0, 1, 0
       db 0, 0, 0, 1
       db 1, 1, 0, 1
       db 1, 0, 1, 1
       db 0, 1, 1, 1


;***************** FORMAT DATA **********************

input db 'Input: "X X X X"', 13, 10, '$'
output db 'Output: "X X X X X X X"', 13, 10, '$'
comp db 'Computation:', 13, 10, '$'
fin db '"', 13, 10, '$'
ini db   '      | P1 | P2 | D1 | P4 | D2 | D3 | D4', 13, 10, '$'
word_ db 'Word  | ?  | ?  | X  | ?  | X  | X  | X', 13, 10, '$'
p1 db    'P1    | X  |    | X  |    | X  |    | X', 13, 10, '$'
p2 db    'P2    |    | X  | X  |    |    | X  | X', 13, 10, '$'
p4 db    'P4    |    |    |    | X  | X  | X  | X', 13, 10, '$'


;***************** REQUEST DATA **********************

request db 'Please, introduce a number between 0 and 15: ', '$'

;; The reading buffer needs the first byte to save the 
;; max. number of bytes to read, another to save 
;; the number of bytes read and another 3 bytes
;; to save both digits of the number and the carriage
;; return.

read db 3, ?, 3 dup (?), '$'
errtxt db 'Number should be less than 15 and greater than 0.', 13, 10, '$'
newline db 13,10,'$' ; <- Used to jump to a new line after request the number
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
	
	; Adding a new line
	
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	
	CALL DECIMAL           ; Converting to decimal.
	CALL CHECK             ; Checking if the number is valid.
	
	; Now that the number is valid we can 
	; convert it to binary.
	
	MOV BX, 0 	           ; Cleaning BX.
	MOV BL, AL             ; The procedure needs the number in BL
	CALL BINARY            ; Calling the function.
	
	; STARTING EDAC
	
    ; DX:BX contains the vector to be multiplied
    MOV DH, bin[0]
    MOV DL, bin[1]
    MOV BH, bin[2]
    MOV BL, bin[3]

    ; Call the function that multiplies vector x matrix
    CALL MULTIPLY
    ; Call the function that prints all the needed information
    CALL PRINT_RESULTS 
	
END_PROG:
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
	
	JMP END_PROG
	
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

;__________________________________________________________________________
; SUBROUTINE THAT COMPUTES THE MULTIPLICATION OF A VECTOR AND A MATRIX AND
; RETURNS THE RESULT VECTOR MODULO 2
; INPUT:    4 BINARY DIGITS WILL BE READ FROM DX AND BX
; OUTPUT:   THE VECTOR SEGMENT WILL BE STORED IN DX, ITS OFFSET IN AX
;__________________________________________________________________________ 

MULTIPLY PROC NEAR
    ; We could not do just a loop to multiply the whole vector, 
    ; as it was contained in two different registers
    ; Therefore, we needed 2 loops, and each of them having 2 iterations
    ; We thought expanding the loop was a better solution as, in the end,
    ; it was easier to understand than the 2 double loops

    MOV SI, 0 ; DI will be the result vector index and matrix row index 
EACH_ROW:
    ; We will write in result[SI], but we need to read matrix[BP + SI*4]
    ; Therefore, we will compute DI <= SI*4
    ; Instead of using MUL, we will use SHL 
    MOV DI, SI                      ; We write a copy of SI in DI
    MOV CL, 2                       ; We want to shift twice
    SHL DI, CL                      ; DI <= 4*DI
    
    MOV AL, BYTE PTR DH             ; Factor1 = input vector 1st element
    MUL matrix[0][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had   
                                    ; in AL
    INC SI                          ; Increment the matrix rows index
    CMP SI, 7                       ; Until we have multiplied the 7 rows
    JNZ EACH_ROW 

    ; Now, we have to repeat the same but with the part of the input vector
    ; that is in DL

    MOV SI, 0 ; DI will be the result vector index and matrix row index 
EACH_ROW2:
    ; Same as before, we will compute DI <= SI*4
    MOV DI, SI                      ; We write a copy of SI in DI
    MOV CL, 2                       ; We want to shift twice
    SHL DI, CL                      ; DI <= 4*DI
    
    MOV AL, BYTE PTR DL             ; Factor1 = input vector 2nd element
    MUL matrix[1][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had  
                                    ; in AL
    INC SI                          ; Increment the matrix rows index
    CMP SI, 7                       ; Until we have multiplied the 7 rows
    JNZ EACH_ROW2 

    ; Now, we have to repeat the same but with the part of the input vector
    ; that is in BH

    MOV SI, 0 ; DI will be the result vector index and matrix row index 
EACH_ROW3:
    ; Same as before, we will compute DI <= SI*4
    MOV DI, SI                      ; We write a copy of SI in DI
    MOV CL, 2                       ; We want to shift twice
    SHL DI, CL                      ; DI <= 4*DI
    
    MOV AL, BYTE PTR BH             ; Factor1 = input vector 3rd element
    MUL matrix[2][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had
                                    ; in AL
    INC SI                          ; Increment the matrix rows index
    CMP SI, 7                       ; Until we have multiplied the 7 rows
    JNZ EACH_ROW3 


    ; Now, we have to repeat the same but with the part of the input vector
    ; that is in BL

    MOV SI, 0 ; DI will be the result vector index and matrix row index 
EACH_ROW4:
    ; Same as before, we will compute DI <= SI*4
    MOV DI, SI                      ; We write a copy of SI in DI
    MOV CL, 2                       ; We want to shift twice
    SHL DI, CL                      ; DI <= 4*DI
    
    MOV AL, BYTE PTR BL             ; Factor1 = input vector 4th element
    MUL matrix[3][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had
                                    ; in AL
    INC SI                          ; Increment the matrix rows index
    CMP SI, 7                       ; Until we have multiplied the 7 rows
    JNZ EACH_ROW4 

    ; Call the function that computes the modulo
    CALL MODULO_RESULT

    ; Store result vector position in DX:AX
    MOV DX, DS              ; DX is the segment where the result vector is.
    MOV AX, OFFSET result   ; AX contains the OFFSET of the result vector.

    RET
MULTIPLY ENDP


;__________________________________________________________________________
; SUBROUTINE THAT COMPUTES A 7 BYTES VECTOR MODULO 2
; INPUT:    7 BYTES VECTOR WILL BE READ FROM result VECTOR, PREVIOUSLY
;           ALLOCATED
; OUTPUT:   THE NEW VECTOR WILL BE STORED IN result VECTOR
;__________________________________________________________________________ 


MODULO_RESULT PROC NEAR

    ; The multiplication is done, now we compute modulo
    ; We use unsigned division (we are working with numbers that are
    ; the result of adding 1's and 0's)
    ; We use 8-bit division because the greatest number we are going to
    ; divide is 1*1 + 1*1 + 1*1 + 1*1 = 4 
    MOV CL, 2  ; CL <= 2 because we are working modulo 2, 2 is the divisor
    MOV DI, 0  ; DI will index the result vector
    

MODULO:
    MOV AH, 00h                    ; AX is the dividend: AH:AL = 00h:result[DI]
    MOV AL, result[DI]             
    DIV CL                         ; AX/2
    MOV result [DI], AH            ; result[DI] <= remainder

    INC DI                         ; We repeat for each element
    CMP DI, 7                      ; of the result vector
    JNZ MODULO
    
    RET
MODULO_RESULT ENDP

;__________________________________________________________________________
; SUBROUTINE THAT PRINTS THE PREVIOUS COMPUTATION RESULT 
; INPUT:    result 7 BYTES VECTOR PREVIOUSLY ALLOCATED  
; OUTPUT:   INPUT, OUTPUT AND COMPUTATION INFORMATION ABOUT THE MULTIPLY
;           FUNCTION
; OBS:      THIS FUNCTION LEAVES REGISTERS DX, AX UNCHANGED
;__________________________________________________________________________ 

PRINT_RESULTS PROC NEAR

    ; Since we want DX:AX to preserve the location of the result vector, 
    ; computed in MULTIPLY, we copy their content in another registers
    MOV BX, AX
    MOV CX, DX
 
    ; ---------- INPUT LINE -----------
    ; We fill the 'X' in the input string with the input vector
    ;To get the ASCII code of register, we add it up with "0"    
    
    MOV AL, result[0]
    ADD AL, "0"
    MOV input[8], AL
    MOV AL, result[1]
    ADD AL, "0"
    MOV input[10], AL
    MOV AL, result[2]
    ADD AL, "0"
    MOV input[12], AL
    MOV AL, result[3]
    ADD AL, "0"
    MOV input[14], AL
    
    ;We print the input string
    MOV DX, OFFSET input    ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H
   
    ; ---------- OUTPUT LINE ----------
    ;We fill the 'X' of the output string with the reordered output vector
    ;To get the ASCII code of register, we add it up with "0"    
    
    MOV AL, result[4]
    ADD AL, "0"
    MOV output[9], AL    ;P1
    MOV AL, result[5]
    ADD AL, "0"
    MOV output[11], AL   ;P2
    MOV AL, result[0]
    ADD AL, "0"
    MOV output[13], AL   ;D1
    MOV AL, result[6]
    ADD AL, "0"    
    MOV output[15], AL   ;P4
    MOV AL, result[1]
    ADD AL, "0"    
    MOV output[17], AL   ;D2
    MOV AL, result[2]
    ADD AL, "0"    
    MOV output[19], AL   ;D3
    MOV AL, result[3]
    ADD AL, "0"    
    MOV output[21], AL   ;D4

    ;We print the output string
    MOV DX, OFFSET output    ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H
         
    ; -------- COMPUTATION MATRIX -------
    ;We print the computation line
    ;To get the ASCII code of register, we add it up with "0"    
    
    MOV DX, OFFSET comp     ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H 
    
    ;We print the first line
    MOV DX, OFFSET ini      ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H
    
    ;We fill the 'X' in 'Word...' line with D1, D2, D3, D4
    ;To get the ASCII code of register, we add it up with "0"    
    MOV AL, result[0]
    ADD AL, "0"    
    MOV word_[18], AL
    MOV AL, result[1]
    ADD AL, "0"    
    MOV word_[28], AL
    MOV AL, result[2]
    ADD AL, "0"    
    MOV word_[33], AL
    MOV AL, result[3]
    ADD AL, "0"    
    MOV word_[38], AL

    ; We print the 'Word...' line
    MOV DX, OFFSET word_     ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H 
 
    ;We fill the 'X' in the 'P1...' line with P1, D1, D2, D4
    ;To get the ASCII code of register, we add it up with "0"    
    MOV AL, result[4]
    ADD AL, "0"    
    MOV p1[8], AL  
    MOV AL, result[0]
    ADD AL, "0"    
    MOV p1[18], AL
    MOV AL, result[1]
    ADD AL, "0"    
    MOV p1[28], AL
    MOV AL, result[3]
    ADD AL, "0"    
    MOV p1[38], AL

    ; We print the 'P1...' line
    MOV DX, OFFSET p1       ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H 

    ;We fill the 'X' in the 'P2...' line with P2, D1, D3, D4
    ;To get the ASCII code of register, we add it up with "0"    
    MOV AL, result[5]
    ADD AL, "0"    
    MOV p2[13], AL
    MOV AL, result[0]
    ADD AL, "0"    
    MOV p2[18], AL
    MOV AL, result[2]
    ADD AL, "0"    
    MOV p2[33], AL
    MOV AL, result[3]
    ADD AL, "0"    
    MOV p2[38], AL

    ; We print the 'P2...' line
    MOV DX, OFFSET p2       ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H 
    
    ;We fill the 'X' in the 'P3...' line with P4, D2, D3, D4
    ;To get the ASCII code of register, we add it up with "0"    
    MOV AL, result[6]
    ADD AL, "0"    
    MOV p4[23], AL
    MOV AL, result[1]
    ADD AL, "0"    
    MOV p4[28], AL
    MOV AL, result[2]
    ADD AL, "0"    
    MOV p4[33], AL
    MOV AL, result[3]
    ADD AL, "0"    
    MOV p4[38], AL

    ; We print the 'P4...' line
    MOV DX, OFFSET p4       ; DX has the offset of the string
    MOV AH, 9               ; Function 9: print ascii string
    INT 21H 
 
    ; We return to AX, DX their initial content 
    MOV AX, BX
    MOV DX, CX 
    
    RET
PRINT_RESULTS ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE (i.e. “INICIO”)
END INICIO
