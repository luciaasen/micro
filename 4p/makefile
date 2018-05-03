all: p4a.com p4b.exe p4c.com

p4a.com: p4a.obj
	tlink /v /t p4a
p4a.obj: p4a.asm 
	tasm /zi p4a.asm,,p4a.lsm

p4b.exe: p4b.obj
	tlink /v p4b
p4b.obj: p4b.asm 
	tasm /zi p4b.asm,,p4b.lsm

p4c.com: p4c.obj
	tlink /v /t p4c
p4c.obj: p4c.asm 
	tasm /zi p4c.asm,,p4c.lsm

	
clean:
	del *.EXE
	del *.COM	
	del *.OBJ
	del *.LSM
	del *.MAP
