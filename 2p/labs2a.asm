
;**************************************************************************
; LAB SESSION 2 - EXERCISE 2 MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

;**************************************************************************
; DATA SEGMENT DEFINITION
DATOS SEGMENT

;***************** DATOS PARA LA MULTIPLICACION *******************

input_vector db 01h, 00h, 01h, 01h

result db 7 dup (0) ; Multiplying vector(1,4) x matrix(4,7) results in a
                    ; vector(1,7) for which we allocate memory

matrix db 1, 0, 0, 0; ;We allocate the 7x4 Transposed Generation Matrix
       db 0, 1, 0, 0  ;to make a better memory access when multiplying
       db 0, 0, 1, 0
       db 0, 0, 0, 1
       db 1, 1, 0, 1
       db 1, 0, 1, 1
       db 0, 1, 1, 1


;***************** DATOS PARA LA IMPRESION *******************

input db 'Input: "X X X X"', 13, 10, '$'
output db 'Output: "X X X X X X X"', 13, 10, '$'
comp db 'Computation:', 13, 10, '$'
fin db '"', 13, 10, '$'
ini db   '      | P1 | P2 | D1 | P4 | D2 | D3 | D4', 13, 10, '$'
word_ db 'Word  | ?  | ?  | X  | ?  | X  | X  | X', 13, 10, '$'
p1 db    'P1    | X  |    | X  |    | X  |    | X', 13, 10, '$'
p2 db    'P2    |    | X  | X  |    |    | X  | X', 13, 10, '$'
p4 db    'P4    |    |    |    | X  | X  | X  | X', 13, 10, '$'

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
    
    ; DX:BX contains the vector to be multiplied
    MOV DH, input_vector[0]
    MOV DL, input_vector[1]
    MOV BH, input_vector[2]
    MOV BL, input_vector[3]

    ; Call the function that multiplies vector x matrix
    CALL MULTIPLY
    ; Call the function that prints all the needed information
    CALL PRINT_RESULTS 

	; PROGRAM END
	MOV AX, 4C00H
	INT 21H

INICIO ENDP


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
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE
END INICIO
