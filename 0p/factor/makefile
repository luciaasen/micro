all: factor.exe factor1.exe factor2.exe

factor.exe: factor.obj
	tlink /v factor
factor.obj: factor.asm 
	tasm /zi factor.asm,,factor.lsm

factor1.exe: factor1.obj
	tlink /v factor1
factor1.obj: factor1.asm 
	tasm /zi factor1.asm,,factor1.lsm

factor2.exe: factor2.obj
	tlink /v factor2
factor2.obj: factor2.asm 
	tasm /zi factor2.asm,,factor2.lsm 	

clean:
	del *.EXE
	del *.OBJ
	del *.LSM
	del *.MAP