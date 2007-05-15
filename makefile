all: progs.src *.qc *.qh
	qfcc --warn=error --code=no-single-cpp --advanced $(CFLAGS)
debug: progs.src *.qc *.qh
	qfcc --warn=all --code=debug,no-single-cpp --advanced -DDEBUG $(CFLAGS)
clean:
	rm -f core *.dat *.pqc *.sym progdefs.h
