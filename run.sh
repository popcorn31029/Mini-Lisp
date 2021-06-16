#--debug -t 
bison -d -o y.tab.c final.y
g++ -c -g -I.. y.tab.c 
flex -o lex.yy.c final.l 
g++ -c -g -I.. lex.yy.c
g++ -o final y.tab.o lex.yy.o -ll
rm y.tab.c y.tab.h y.tab.o lex.yy.c lex.yy.o
./final < input.txt
