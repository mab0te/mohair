%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define FILE_LEN 256

int comment = 0;
%}

mot [^ \t\n\f\r\\{}%]+

%%
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

(\\)+ {strncpy(yylval.word, "\n", 256); return(WORD);}

{mot} {if (!comment) {
	strncpy(yylval.word, yytext, 256); 
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

