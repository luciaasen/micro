all: dec2ASC.exe labs2a.exe labs2b.exe

dec2ASC.exe: dec2ASC.obj
	tlink /v dec2ASC
dec2ASC.obj: dec2ASC.asm 
	tasm /zi dec2ASC.asm,,dec2ASC.lsm

labs2a.exe: labs2a.obj
	tlink /v labs2a
labs2a.obj: labs2a.asm 
	tasm /zi labs2a.asm,,labs2a.lsm
	
labs2b.exe: labs2b.obj
	tlink /v labs2b
labs2b.obj: labs2b.asm 
	tasm /zi labs2b.asm,,labs2b.lsm
	
clean:
	del *.EXE
	del *.OBJ
	del *.LSM
	del *.MAP
