qwprogs.dat: preprogs.src *.qc
	qfpreqcc --warn=error --debug
clean:
	rm -f core *.dat *.pqc *.sym progdefs.h
