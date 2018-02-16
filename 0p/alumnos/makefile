all: alumno.exe alumno1.exe

alumno.exe: alumno.obj
	tlink /v alumno
alumno.obj: alumno.asm
	tasm /zi alumno.asm,,alumno.lsm

alumno1.exe: alumno1.obj
	tlink /v alumno1
alumno1.obj: alumno1.asm
	tasm /zi alumno1.asm,,alumno1.lsm

clean:
	del *.EXE
	del *.OBJ
	del *.LSM
	del *.MAP
