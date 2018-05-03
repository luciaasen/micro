;**************************************************************************
; LAB SESSION 4 - EXERCISE 3 MBS 2018
; TEAM #6
; AUTHORS:
; Lucia Asencio - lucia.asencio@estudiante.uam.es
; David García Fernández - david.garcia03@estudiante.uam.es
;**************************************************************************

CODE SEGMENT
	ASSUME cs: code
	ORG 256 ; To create .com program

START: JMP MAINP

; Global variables
key DB 9h ; Our key is 6+3 = 9
error_arg DB 'Invalid arguments: /I to install, /U to uninstall, <none> to see actual status.','$'
errorn_arg DB 'Invalid number of arguments.','$'
inst_stat DB 'STATUS: In this moment the driver is installed.','$'
some_stat DB 'STATUS: In this moment a different driver is installed.','$'
request_conf DB 10,'Confirm the installation of the new one (y/n): ','$'
none_stat DB 'STATUS: The driver is not installed.', '$'
current DB 'There is a driver installed.','$'
conf db 2, ?, 2 dup (?), '$' ; Here is stored the confirmation entered by the user
newline db 13,10,'$' ; <- Used to jump to a new line after requesting
team_info DB 'TEAM #6',10, 'AUTHORS: Lucia Asencio, David Garcia','$'
request_c db 'Introduce a command (quit, cod, dec): ','$'
request_enc db 'Introduce a string to be encoded: ','$'
request_dec db 'Introduce a string to be decoded: ','$'
cipher db 20, ?, 21 dup (?) ; Here is stored the string requested to the user

; Routine executed by the interruption
RTC_rsi PROC FAR
	sti
	push ax dx
	mov al, 0Ch
	out 70h, al ; Access to 0Ch register of RTC
	in al, 71h ; Read the 0Ch register
	
	MOV AL, 0Bh
	OUT 70h, AL ; Enable 0Bh register
	IN AL, 71h ; Read the 0Bh register
	TEST AL, 01000000b ; Check if the current mode is periodic interrupt
	JZ final ; If the mode is not the desired one we return the function
	
	; As it is not possible to set a 1Hz frequency we only print 
	; once each two interruptions
	inc cx
	cmp cx, 2
	jne final	
	
	; The character to be printed should be saved in DS:[BX]
	mov ah, 2 ; Function number = 2
	mov dl, [bx]
	mov cx, 0
	cmp dl, '$' ; If is the sentinel we have finished
	je final
	int 21h ; Software interruption to the operating system 
	inc bx
	
final: ; Send EOIs (RTC)
	mov al, 20h
	out 20h, al ; Master PIC
	out 0A0h, al ; Slave PIC
	pop dx ax
	iret
RTC_rsi ENDP

INSTALL PROC FAR
	MOV AX, 0 
	MOV ES, AX 
	MOV AX, OFFSET RTC_rsi
	MOV BX, CS
	
	; Installing in the interruption 55h
	CLI
	MOV ES:[70h*4], AX 
	MOV ES:[70h*4+2], BX 
	STI
	
	; DX must contain the offset of the first
	; instruction after the global variables and
	; procedures that are staying resident
	MOV DX, OFFSET INSTALL
	
	; The program stays resident
	INT 27h
INSTALL ENDP

UNINSTALL PROC FAR
	PUSH AX BX CX DS ES
	MOV CX, 0
	MOV DS, CX           ; Segment of int. vector
	MOV ES, DS:[70h*4+2] ; Installer segment
	MOV BX, ES:[02Ch]    ; Segment of enviroment
	CMP BX, 0
	JE UEND              ; If segment is 0 the vector is empty, we do nothing
	MOV AH, 49h          
	INT 21H				 ; Release segment
	
	; Now we set the vector to zero
	CLI
	MOV DS:[70h*4], CX
	MOV DS:[70h*4+2], CX
	STI
UEND:
	POP ES DS CX BX AX
	RET
UNINSTALL ENDP

confRTC PROC FAR
	PUSH AX
	MOV AL, 0Ah
	; SET the frequency
	OUT 70h, AL ;Enable 0Ah register
	MOV AL, 00101111b ; DV=010b, RS=1111b (7 == 2 Hz)
	; It is not possible to set a frequency lower than 2Hz
	OUT 71h, AL ; Write 0Ah register
	; Active Interrupt
	MOV AL, 0Bh
	OUT 70h, AL ; Enable 0Bh register
	IN AL, 71h ; Read the 0Bh register
	MOV AH, AL
	OR AH, 01000000b ; Set the PIE bit
	MOV AL, 0Bh
	OUT 70h, AL ; Enable the 0Bh register
	MOV AL, AH
	OUT 71h, AL ; Write the 0Bh register
	POP AX
	RET
confRTC ENDP

offRTC PROC FAR
	PUSH AX
	; Switch off Interrupt
	MOV AL, 0Bh
	OUT 70h, AL ; Enable 0Bh register
	IN AL, 71h ; Read the 0Bh register
	MOV AH, AL
	AND AH, 10111111b ; Set the PIE bit to zero
	MOV AL, 0Bh
	OUT 70h, AL ; Enable the 0Bh register
	MOV AL, AH
	OUT 71h, AL ; Write the 0Bh register
	POP AX
	RET
offRTC ENDP

MAINP PROC NEAR
	; Here we check input arguments
	MOV BX, 80h
	MOV AL, [BX]
	
	; Checking the number of arguments
	CMP AL, 3 ; We need 3 to install/uninstall
	JE CHECKARG
	CMP AL, 0 ; No arguments to see status
	CALL REGULARP
	
	; Print the value.
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET errorn_arg ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
	JMP MAINEND

CHECKARG:
; Checking the args
	MOV BX, 82h
	MOV AX, WORD PTR [BX]
	CMP AX, 492Fh
	; Calling install
	JNE CHECKU
	; First we check if the vector is empty
	; Check status
	MOV CX, 0
	MOV ES, CX
	MOV CX, ES:[70h*4+2]
	MOV BX, ES:[70h*4]
	CMP BX, 0
	JNE CHECKSAME
	CMP CX, 0
	JE INST
CHECKSAME:
	MOV ES, CX
	MOV AX, ES:[BX]
	MOV DI, OFFSET RTC_rsi
	MOV DX, [DI]
	CMP AX, DX
	JNE REQU
	MOV AX, ES:[BX+2]
	MOV DX, [DI+2]
	CMP AX, DX
	JE MAINEND
REQU:
	; Print the value.
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET current   ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
REP_REQU:
	MOV DX, OFFSET request_conf ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
	; Reading number
	MOV AH, 0Ah            ; Selecting the interruption.
	MOV DX, OFFSET conf    ; DX needs the offset of the string.
	INT 21H                ; Reading from keyboard.
	; Printing new line
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	
	; Checking response
	MOV AL, conf[2]
	CMP AL, 79h            ; If response is y we install the new driver.
	JE INST
	CMP AL, 6Eh
	JNE REP_REQU           ; If is n we finish the program. If not we continue asking.
	JMP MAINEND

INST:
	CALL INSTALL
CHECKU:
	CMP AX, 552Fh
	JNE ARGERROR
	; Calling uninstall
	CALL UNINSTALL
	JMP MAINEND
ARGERROR:
	; Print the value.
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET error_arg ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.

MAINEND:
	; Program Ends
	MOV AX, 4C00H
	INT 21H
MAINP ENDP

REGULARP PROC NEAR
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
	CALL ADDSENT ; Adding sentinel
	
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
	MOV BX, DX
	;Printing new line
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	MOV CX, 0
	; Calling the step by step print
	CALL confRTC

; Waiting for the print procedure to finish	
WAIT1:
	CMP BYTE PTR [BX], '$'
	JNE WAIT1
	
	CALL offRTC
	JMP LOOP1

DECO:

	; Requesting string
	MOV AH, 9h 			       ; First we select the interruption type.
	MOV DX, OFFSET request_dec ; Now we move to dx the offset of the string.
	INT 21H                    ; Calling the interruption.
	
	; Reading string
	MOV AH, 0Ah            ; Selecting the interruption.
	MOV DX, OFFSET cipher  ; DX needs the offset of the string.
	INT 21H                ; Reading from keyboard.
	CALL ADDSENT ; Adding sentinel
	
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
	MOV BX, DX
	
	; Printing new line
	MOV AH, 9h 			   ; First we select the interruption type.
	MOV DX, OFFSET newline ; Now we move to dx the offset of the string.
	INT 21H                ; Calling the interruption.
	MOV CX, 0
	CALL confRTC
	JMP WAIT1
	
	
END_PROG:
	; PROGRAM END
	MOV AX, 4C00H
	INT 21H
REGULARP ENDP

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

CODE ENDS
END START