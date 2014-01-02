%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int secNb = 0;
int ssecNb = 0;
int lemNb = 0;
int defNb = 0;

int charNb = 0;
int firstWord = 1;

%}

%union {
  char word[256];
}

%token SECTION
%token SSECTION
%token LEMME
%token DEF
%token <word> WORD
%token ENDENV
%token TITLE
%token <word> PARA

%%
//source -> content part | part
source : {printf("    "); charNb = 4;} content part;

para : {firstWord = 0; printf("\n\n    "); charNb=4;} PARA {size_t len = strlen($2);
            printf("%s ", $2);
            charNb += len + 1;} texte;

// texte -> WORD texte | WORD
texte : WORD 
        {size_t len = strlen($1);
         if ((charNb + len + 1 < 80) && ($1[len - 1] != '\n')) {
            printf("%s ", $1);
            charNb += len + 1;
         } else if ($1[len - 1] != '\n'){
            printf("\n%s ", $1);
            charNb = len;
         } else {
            printf("\n");
            charNb = 0;
         }
        } 
        texte
      |
      ;

// titre -> WORD titre | titre     
titre : WORD {printf("%s ", $1);} titre 
      | WORD {printf("%s", $1);}
      ;

// part -> section part | part | 
part : section part
     | 
     ;

// content -> texte content | env content | texte | env
content : para content
        | {printf("\n\n");} env content
		| {printf("\n\n");}
        ;

// section -> SECTION '{' titre '}' content ssection | SECTION content ssection
section : SECTION 
            {firstWord = 0;
			 secNb++;
             ssecNb = 0;
             printf("%d : ", secNb);
            } 
            '{' titre '}' {firstWord = 1;}
            content ssection 
        | SECTION 
          {secNb++;
           ssecNb = 0;
           printf("%d : ", secNb);
          } 
          content ssection
        ;
 
// ssection -> SSECTION '{' titre '}' content ssection | SSECTION content ssection 
ssection : SSECTION 
           {firstWord = 0;
			ssecNb++;
            printf("%d.%d : ", secNb, ssecNb);
           } 
           '{' titre '}' {firstWord = 1;}
           content ssection
         | SSECTION 
           {ssecNb++;
            printf("%d.%d : ", secNb, ssecNb);
           } 
           content ssection
         | 
         ;

// env -> LEMME '{' titre '}' texte ENDENV | LEMME texte ENDENV | DEF '{' titre '}' texte ENDENV | DEF texte ENDENV
env : LEMME 
      {lemNb++;
       printf("*** lemme %d : [", lemNb);
      }
      '{' titre '}' 
      {printf("] ***");}
      texte
      ENDENV
      {printf("\n***** FIN *****");}
    | LEMME
      {lemNb++;
       printf("*** lemme %d ***\n    ", lemNb);
       charNb = 4;
      }
      texte
      ENDENV
      {printf("\n***** FIN *****");}
    | DEF 
      {defNb++;
       printf("*** definition %d : [", defNb);
      }
      '{' titre '}' 
      {printf("] ***\n    "); charNb = 4;}
      texte
      ENDENV
      {printf("\n***** FIN *****");}
    | DEF 
      {defNb++;
       printf("*** definition %d ***\n    ", defNb);
       charNb = 4;
      }
      texte
      ENDENV
      {printf("\n***** FIN *****");}
    ;

%%
#include "lex.yy.c"

