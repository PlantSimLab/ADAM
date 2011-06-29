CC = g++

analysis : cyclone.o PDS.o constants.h PDS.h
	$(CC) -o $@ cyclone.o PDS.o

PDS.o : PDS.cc PDS.h constants.h
	$(CC) -c PDS.cc

cyclone.o : cyclone.cc constants.h PDS.h
	$(CC) -c cyclone.cc

clean : 
	rm analysis PDS.o cyclone.o

