../qwprogs.dat: preprogs.src *.qc
	qfpreqcc --warn=error
clean:
	rm -f core *.dat progdefs.h
