qwprogs.dat: preprogs.src *.qc
	qfpreqcc --warn=error --debug --no-cpp
clean:
	rm -f core *.dat *.pqc *.sym progdefs.h progs.src
