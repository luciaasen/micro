;**************************************************************************
; LAB SESSION 4 - EXERCISE 1 MBS 2018
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

; Routine executed by the interruption
CESAR PROC FAR
	PUSH CX DI AX
	MOV CH, key ; Loading the key in a register
	; DS:DX contains the string to be encripted
	MOV DI, DX
	; Depending on the content of AH we encrypt or decrypt
	CMP AH, 13h
	JE DECR
	CMP AH, 12h
	JNE ENDCESAR
ENC:
	MOV CL, [DI] ; CL contains the character
	CMP CL, '$'  ; If the character is the sentinel we stop
	JE PRINTC
	CMP CL, 14
	JNE RIGHT1
	MOV CL, '-'
	JMP FIN1
RIGHT1:
	CMP CL, 76h
	JB WELL
	CMP CL, 'z'
	JNE SUBAS
	MOV CL, 3
	JMP FIN1
SUBAS:
	SUB CL, 5fh
WELL:
	ADD CL, CH   ; Adding to the ascii code the key value
FIN1:
	MOV [DI], CL ; Saving in memory the encripted character
	INC DI
	JMP ENC
DECR:	
	MOV CL, [DI] ; CL contains the character
	CMP CL, '$'  ; If the character is the sentinel we stop
	JE PRINTC
	CMP CL, 3
	JNE CONT1
	MOV CL, 'z'
	JMP OTHERPASS
CONT1:
	CMP CL, '-'
	JNE CONT2
	MOV CL, 14
	JMP OTHERPASS
CONT2:
	CMP CL, 28h
	JA WELL2
	CMP CL, '-'
	JA WELL2
	ADD CL, 5fh
WELL2:
	SUB CL, CH   ; Substracting to the ascii code the key value
OTHERPASS:
	MOV [DI], CL ; Saving in memory the encripted character
PASS:	
	INC DI
	JMP DECR
	
PRINTC:
	; Print the value.
	MOV AH, 9h            ; First we select the interruption type.
						  ; DX already contains the offset of the string
	INT 21H               ; Calling the interruption.

ENDCESAR:	
	POP AX DI CX
	IRET ; The interruption is finished
CESAR ENDP

INSTALL PROC FAR
	MOV AX, 0 
	MOV ES, AX 
	MOV AX, OFFSET CESAR
	MOV BX, CS
	
	; Installing in the interruption 55h
	CLI
	MOV ES:[55h*4], AX 
	MOV ES:[55h*4+2], BX 
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
	MOV ES, DS:[55h*4+2] ; Installer segment
	MOV BX, ES:[02Ch]    ; Segment of enviroment
	CMP BX, 0
	JE UEND              ; If segment is 0 the vector is empty, we do nothing
	MOV AH, 49h          
	INT 21H				 ; Release segment
	
	; Now we set the vector to zero
	CLI
	MOV DS:[55h*4], CX
	MOV DS:[55h*4+2], CX
	STI
UEND:
	POP ES DS CX BX AX
	RET
UNINSTALL ENDP

MAINP PROC FAR
	; Here we check input arguments
	MOV BX, 80h
	MOV AL, [BX]
	
	; Checking the number of arguments
	CMP AL, 3 ; We need 3 to install/uninstall
	JE CHECKARG
	CMP AL, 0 ; No arguments to see status
	JE CHECKSTATUS
	
	; Print the value.
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET errorn_arg ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
	JMP MAINEND

CHECKSTATUS:

	; Printing the team info
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET team_info ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
	
	; Jumping to new line
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET newline   ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.


	; Check status
	MOV CX, 0
	MOV DS, CX
	MOV CX, DS:[55h*4+2]
	MOV BX, DS:[55h*4]
	CMP BX, 0
	JNE CONT
	CMP CX, 0
	JE SHOWNONE
CONT:
	MOV ES, CX
	MOV AX, ES:[BX]
	MOV DI, OFFSET CESAR
	MOV DX, CS:[DI]
	MOV CX, CS
	MOV DS, CX
	CMP AX, DX
	JNE SHOWOTHER
	MOV AX, ES:[BX+2]
	MOV DX, CS:[DI+2]
	CMP AX, DX
	JNE SHOWOTHER

	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET inst_stat ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
	JMP MAINEND
	
SHOWOTHER:	
	; In this case another is driver is installed
	; Print the value.
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET some_stat ; Now we move to dx the offset of the string.
	INT 21H                  ; Calling the interruption.
	JMP MAINEND
	
SHOWNONE:	
	; In this case another is driver is installed
	; Print the value.
	MOV CX, CS
	MOV DS, CX
	MOV AH, 9h               ; First we select the interruption type.
	MOV DX, OFFSET none_stat ; Now we move to dx the offset of the string.
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
	MOV CX, ES:[55h*4+2]
	MOV BX, ES:[55h*4]
	CMP BX, 0
	JNE CHECKSAME
	CMP CX, 0
	JE INST
CHECKSAME:
	MOV ES, CX
	MOV AX, ES:[BX]
	MOV DI, OFFSET CESAR
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

CODE ENDS
END START