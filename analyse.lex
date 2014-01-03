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
%}

mot [^ \t\n\f\r\\{}%]+

%%
\\title {firstWord = 0;return(TITLE);}

\\para	{firstWord = 1;}

\\section {firstWord = 1;return(SECTION);}

\\ssection {firstWord = 1;return(SSECTION);}

\\lemme { firstWord = 0; return(LEMME);}

\\def {firstWord = 0; return(DEF);}

\\end {firstWord = 1; return(ENDENV);}

\{ {return('{');}

\} {return('}');}

% {comment = 1;}

\\% {strncpy(yylval.word, "%", 256); return(WORD);}

(\\)+ {strncpy(yylval.word, "\n", STR_LEN); return(WORD);}

{mot} {if (!comment) {
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

