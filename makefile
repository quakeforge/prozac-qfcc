all: progs.src *.qc *.qh
	qfcc --warn=error --advanced $(CFLAGS)
debug: progs.src *.qc *.qh
	qfcc --warn=all --code=debug --advanced -DDEBUG $(CFLAGS)
clean:
	rm -f core *.dat *.pqc *.sym progdefs.h
