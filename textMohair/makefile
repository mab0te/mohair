textMohair: y.tab.c lex.yy.c
	gcc -o $@ $< -ly -lfl

y.tab.c: analyse.y
	yacc $<

lex.yy.c: analyse.lex
	flex $<
