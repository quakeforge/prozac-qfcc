qwprogs.dat: preprogs.src *.qc
	qfpreqcc --warn=error --debug
clean:
	rm -f core *.dat *.sym progdefs.h
