
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

result db 7 dup (0) ; Multiplying vector(1,4) x matrix(4,7) results in a
                    ; vector(1,7) for which we allocate memory

matrix db 1, 0, 0, 0; ;We allocate the 7x4 Transposed Generation Matrix
       db 0, 1, 0, 0  ;to make a better memory access when multiplying
       db 0, 0, 1, 0
       db 0, 0, 0, 1
       db 1, 1, 0, 1
       db 1, 0, 1, 1
       db 0, 1, 1, 1

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
    MOV DX, 0100h
    MOV BX, 0101h

    ; Calling the function that multiplies vector x matrix
    CALL MULTIPLY

INICIO ENDP


;__________________________________________________________________________
; SUBROUTINE THAT COMPUTES THE MULTIPLICATION OF A VECTOR AND A MATRIX AND
; RETURNS THE RESULT VECTOR MODULO 2
; INPUT:    4 BINARY DIGITS WILL BE READ FROM DX:BX
; OUTPUT:   THE VECTOR WILL BE STORED IN [DX:AX]
;__________________________________________________________________________ 

MULTIPLY PROC NEAR

    MOV SI, 0 ; DI will be the result vector index and matrix row index 
EACH_ROW:
    ; We will write in result[SI], but we need to read matrix[BP + SI*4]
    ; Therefore, we will compute DI <= SI*4
    ; Instead of using MUL, we will use SHL 
    MOV DI, SI                      ; We write a copy of SI in DI
    MOV CL, 2                       ; We want to shift twice
    SHL DI, CL                      ; DI <= 4*DI
    
    MOV AL, BYTE PTR DH             ; Factor1 = input vector BP-th element
    MUL matrix[0][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had in  
    ; SERA AX[0] o AX[1]

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
    
    MOV AL, BYTE PTR DL             ; Factor1 = input vector BP-th element
    MUL matrix[1][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had in  

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
    
    MOV AL, BYTE PTR BH             ; Factor1 = input vector BP-th element
    MUL matrix[2][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had in  

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
    
    MOV AL, BYTE PTR BL             ; Factor1 = input vector BP-th element
    MUL matrix[3][DI]               ; Factor2 = Matrix element multiplied
    ADD result[SI], BYTE PTR AL     ; Result in AX is added to what we had in  

    INC SI                          ; Increment the matrix rows index
    CMP SI, 7                       ; Until we have multiplied the 7 rows
    JNZ EACH_ROW4 

    ; The multiplication is done, now we compute modulo
    ; We use unsigned division (we are working with numbers that are
    ; the result of adding 1's and 0's)
    ; We use 8-bit division because the greatest number we are going to
    ; divide is 1*1 + 1*1 + 1*1 + 1*1 = 4 
    MOV CX, 2 ; CX <= 2 because we are working modulo 2, 2 is the divisor
    MOV DI, 0 ; DI will index the result vector
    

MODULO:
    MOV AH, 00h                    ; AX is the dividend = AH:AL = 00h:result[DI]
    MOV AL, result[DI]             
    DIV CX                         ; AX/2
    MOV result [DI], AH            ; result[DI] <= remainder

    INC DI                         ; We repeat for each element
    CMP DI, 7                      ; of the result vector
    JNZ MODULO

    ; Store result vector position in DX:AX
    MOV DX, DS              ; DX is the segment where the result vector is.
    MOV AX, OFFSET result   ; AX contains the OFFSET of the result vector.
 

    RET
MULTIPLY ENDP

; END OF CODE SEGMENT
CODE ENDS
; END OF PROGRAM. OBS: INCLUDES THE ENTRY OR THE FIRST PROCEDURE
END INICIO
