all: qwprogs.dat
qwprogs.dat: progs.src *.qc *.qh
	qfcc --warn=error --debug --quiet
clean:
	rm -f core *.dat *.pqc *.sym progdefs.h
