all: progs.src *.qc *.qh
	qfcc --warn=error --advanced
debug: progs.src *.qc *.qh
	qfcc --warn=all --code=debug --advanced -DDEBUG
clean:
	rm -f core *.dat *.pqc *.sym progdefs.h
