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
\\section {return(SECTION);}

\\ssection {return(SSECTION);}

\\lemme {return(LEMME);}

\\def {return(DEF);}

\\end {return(ENDENV);}

\{ {return('{');}

\} {return('}');}

% {comment = 1;}

\\% {strncpy(yylval.word, "%", 256); return(WORD);}

(\\)+ {strncpy(yylval.word, "\n", 256); return(WORD);}

{mot} {if (!comment) {
         strncpy(yylval.word, yytext, 256); 
         return(WORD);
       }
      }

\n {if (comment == 1) {
      comment = 0;
    }
   }

. //NE RIEN FAIRE

%%

