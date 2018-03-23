all: dec2ASC.exe 

dec2ASC.exe: dec2ASC.obj
	tlink /v dec2ASC
dec2ASC.obj: dec2ASC.asm 
	tasm /zi dec2ASC.asm,,dec2ASC.lsm

clean:
	del *.EXE
	del *.OBJ
	del *.LSM
	del *.MAP