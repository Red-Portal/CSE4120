
CFLAGS=-Wall -Wextra -Wpedantic -O3 -march=native
OBJ=
ODIR=obj
LIBS=-lfl

20161453: util.o main.o lex.yy.o
	$(CC) $? -o $@ $(CFLAGS) $(LIBS)

util.o: util.c
	$(CC) -c util.c $(CFLAGS) $(LIBS)

main.o: main.c
	$(CC) -c main.c $(CFLAGS) $(LIBS)

lex.yy.o: lex.yy.c
	$(CC) -c lex.yy.c $(CFLAGS) $(LIBS)

lex.yy.c: cminus.lex
	$(LEX) $<

.PHONY: clean

clean:
	rm -f *.o *~ 20161453
