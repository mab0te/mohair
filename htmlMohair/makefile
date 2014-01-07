htmlMohair: y.tab.c lex.yy.c
	gcc -o $@ $< -ly -lfl

y.tab.c: analysehtml.y
	yacc $<

lex.yy.c: analysehtml.lex
	flex $<
