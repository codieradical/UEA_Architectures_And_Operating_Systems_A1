

all: 
	as cipher.s utils.s -o cw1.o 
	gcc cw1.o -o cw1


prototype:
	gcc cipher.c utils.c -o cw1

clean:
	rm -f cw1.o cw1