all: qwprogs.dat
qwprogs.dat: progs.src *.qc *.qh
	qfcc --warn=error --code=debug --advanced
clean:
	rm -f core *.dat *.pqc *.sym progdefs.h
