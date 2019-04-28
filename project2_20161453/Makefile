
CFLAGS=-g -Wall -Wextra -Wpedantic -O3 -march=native
OBJ=
ODIR=obj
LIBS=-lfl

20161453: util.o main.o scan.o parse.o
	$(CC) $? -o $@ $(CFLAGS) $(LIBS)

util.o: util.c parse.c
	$(CC) -c util.c $(CFLAGS) $(LIBS)

main.o: main.c parse.c
	$(CC) -c main.c $(CFLAGS) $(LIBS)

scan.o: scan.c parse.c
	$(CC) -c scan.c $(CFLAGS) $(LIBS)

parse.o: scan.c parse.c
	$(CC) -c parse.c -fPIC $(CFLAGS) $(LIBS)

parse.c: cminus.y
	bison -g --report=all --defines=bison.h --output=parse.c $<

# dot parse.dot -Tpng -o parse_state.png

scan.c: cminus.lex
	flex --outfile=scan.c $<

.PHONY: clean

clean:
	rm -f *.o *~ 20161453 bison.h scan.c parse.c
