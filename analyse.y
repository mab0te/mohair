%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int secNb = 0;
int ssecNb = 0;
int lemNb = 0;
int defNb = 0;

int charNb = 0;

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

%%
source : {printf("    "); charNb = 4;} content part
       | part
       ;

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
      | WORD
        {size_t len = strlen($1);
         if ((charNb + len + 1 < 80) && ($1[len - 1] != '\n')) {
            printf("%s", $1);
            charNb += len + 1;
         } else if ($1[len - 1] != '\n'){
            printf("\n%s", $1);
            charNb = len;
         } else {
            printf("\n");
            charNb = 0;
         }
        }
      ;
      
titre : WORD {printf("%s ", $1);} titre 
      | WORD {printf("%s", $1);}
      ;

part : section part
     | section
     |
     ;

content : texte content
        | env content
        | texte
        | env
        ;

section : SECTION 
            {secNb++;
             ssecNb = 0;
             printf("\n\n%d : ", secNb);
            } 
            '{' titre '}' 
            {printf("\n\n    "); charNb = 4;} 
            content ssection 
        | SECTION 
          {secNb++;
           ssecNb = 0;
           printf("%d : \n    ", secNb);
           charNb = 4;
          } 
          content ssection
        ;
     
ssection : SSECTION 
           {ssecNb++;
            printf("\n\n%d.%d : ", secNb, ssecNb);
           } 
           '{' titre '}' 
           {printf("\n\n    "); charNb = 4;} 
           content ssection
         | SSECTION 
           {ssecNb++;
            printf("\n\n%d.%d : \n    ", secNb, ssecNb);
            charNb = 4;
           } 
           content ssection
         | 
         ;

env : LEMME 
      {lemNb++;
       printf("\n\n*** lemme %d : [", lemNb);
      }
      '{' titre '}' 
      {printf("] ***\n    "); charNb = 4;}
      texte
      ENDENV
      {printf("\n***** FIN *****\n\n    "); charNb = 4;}
    | LEMME
      {lemNb++;
       printf("\n\n*** lemme %d ***\n    ", lemNb);
       charNb = 4;
      }
      texte
      ENDENV
      {printf("\n***** FIN *****\n\n    "); charNb = 4;}
    | DEF 
      {defNb++;
       printf("\n\n*** definition %d : [", defNb);
      }
      '{' titre '}' 
      {printf("] ***\n    "); charNb = 4;}
      texte
      ENDENV
      {printf("\n***** FIN *****\n\n    "); charNb = 4;}
    | DEF 
      {defNb++;
       printf("\n\n*** definition %d ***\n    ", defNb);
       charNb = 4;
      }
      texte
      ENDENV
      {printf("\n***** FIN *****\n\n    "); charNb = 4;}
    ;

%%
#include "lex.yy.c"

