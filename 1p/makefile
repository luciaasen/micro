all: labs1a.exe 

labs1a.exe: labs1a.obj
	tlink /v labs1a
labs1a.obj: labs1a.asm 
	tasm /zi labs1a.asm,,labs1a.lsm

clean:
	del *.EXE
	del *.OBJ
	del *.LSM
	del *.MAP