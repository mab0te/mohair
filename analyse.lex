%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#ifndef STR_LEN
#define STR_LEN 256
#define LIN_LEN 80
#endif

int comment = 0;
int inDocument = 0;
%}

mot [^ \t\n\f\r\\{}%]+

number [0-9]+
%%


\\author {return(AUTHOR);}

\\setpagewidth {return(WIDTH);}

\\setsize {return(SETSIZE);}

\\setindent {return(INDENT);}

\\begindocument {inDocument = 1; return(INDOC);}

\\title {firstWord = 0;return(TITLE);}

\\para	{firstWord = 1;}

\\section {firstWord = 1;return(SECTION);}

\\ssection {firstWord = 1;return(SSECTION);}

\\lemme { firstWord = 0; return(LEMME);}

\\def {firstWord = 0; return(DEF);}

\\end {firstWord = 1; return(ENDENV);}

\{ {return('{');}

\} {return('}');}

\\\{ {strncpy(yylval.word, "{", STR_LEN); return(WORD);}

\\\} {strncpy(yylval.word, "}", STR_LEN); return(WORD);}

% {comment = 1;}

\\% {strncpy(yylval.word, "%", STR_LEN); return(WORD);}

\\\\ {strncpy(yylval.word, "\\", STR_LEN); return(WORD);}

{number} {if (inDocument) {REJECT;} else {yylval.nb = atoi(yytext); return(NUMBER);}}

{mot} {
  if (!comment) {
	  strncpy(yylval.word, yytext, STR_LEN); 
	  if (firstWord) {
           return(PARA);
	  } else {
	   return(WORD);
	  }
  }
}

\n {if (comment == 1) {
      comment = 0;
    }
   }

. //NE RIEN FAIRE

%%

