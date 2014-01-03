%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#ifndef STR_LEN
#define STR_LEN 256
#define LIN_LEN 80
#endif

int secNb = 0;
int ssecNb = 0;
int lemNb = 0;
int defNb = 0;
int firstWord = 1;
int charNb = 0;

int openDocument() {
	charNb = 0;
	printf("<html>\n <body>\n <div id='page'>\n");
	return EXIT_SUCCESS;
}

int closeDocument() {
	charNb = 0;
	printf(" </div>\n </body>\n</html>\n");
	return EXIT_SUCCESS;
}

int openPara() {
	charNb = 0;
	printf("    <p>\n");
	return EXIT_SUCCESS;
}

int closePara() {
	charNb = 0;
	printf("\n    </p>\n");
	return EXIT_SUCCESS;
}

//enlever le test du milieu
int printWord(const char *word) {
    size_t len = strlen(word);
    if (charNb + len <= LIN_LEN) {
		if ((charNb + len) == LIN_LEN ) {
			printf("%s\n", word);
        	charNb = 0;
		} else {
			printf("%s ", word);
        	charNb += len + 1;
		}
     } else {
       printf("\n");
       charNb = 0;
    }
	return EXIT_SUCCESS;
}

int printMainTitle(const char *word) {
	charNb = 0;
	printf("    <h1> %s </h1>\n  <div id='intro'>\n", word);
	return EXIT_SUCCESS;
}

int printSection(const char *title) {
	secNb++;
    ssecNb = 0;
	charNb = 0;
	printf("  </div>\n  <div id='section%d'>\n", secNb);
	if (title == NULL) {
		printf("    <h2> %d : </h2>\n", secNb);
	} else {
	    printf("    <h2> %d : %s </h2>\n", secNb, title);
	}
	return EXIT_SUCCESS;
}

int printSubsection(const char *title) {
	ssecNb++;
	charNb = 0;
	printf("  </div>\n  <div id='ssection%d'>\n", ssecNb);
	if (title == NULL) {
		printf("    <h3> %d.%d : </h3>\n", secNb, ssecNb);
	} else {
	    printf("    <h3> %d.%d : %s </h3>\n", secNb, ssecNb, title);
	}
	return EXIT_SUCCESS;
}

//verifier taille totale
int openEnv(const char *env, int *envNb, const char *title) {
	*envNb += 1;
	charNb = 0;
	printf("  <div id ='%s%d'>\n", env, *envNb);
	if (title == NULL) {
		printf("    <h4> %s %d </h4>\n", env, *envNb);
	} else {
		printf("    <h4> %s %d : [%s] </h4>\n", env, *envNb, title);
	}
	return EXIT_SUCCESS;
}

int closeEnv() {
	charNb = 0;
	printf("  </div>\n");
	return EXIT_SUCCESS;
}

%}

%union {
  char word[STR_LEN];
}

%token SECTION
%token SSECTION
%token LEMME
%token DEF
%token <word> WORD
%token ENDENV
%token TITLE
%token <word> PARA

%type <word> titre

%%
//source -> title content part
source : {openDocument();} mainTitle content part {closeDocument();};

//para -> PARA texte
para : {firstWord = 0;openPara();} 
		PARA {printWord($2);} texte {closePara();};

// texte -> WORD texte |
texte : WORD {printWord($1);}  texte
      |
      ;


// title -> TITLE '{' mainTitle '}' | 
mainTitle : TITLE '{' titre '}' {printMainTitle($3); firstWord = 1;}
	|;

// mainTitle -> WORD mainTitle | WORD
titre : WORD  titre {snprintf($$, STR_LEN, "%s %s", $1, $2);}
      | WORD {snprintf($$, STR_LEN, "%s", $1);}
      ;

// part -> section part |  
part : section part
     | 
     ;

// content -> para content | env content | 
content : para content
        | env content
		|
        ;

// section -> SECTION '{' titre '}' content ssection | SECTION content ssection
section : SECTION {firstWord = 0;} '{' titre '}' {printSection($4);firstWord = 1;} content ssection 
        | SECTION {printSection(NULL);} content ssection;
 
// ssection -> SSECTION '{' titre '}' content ssection | SSECTION content ssection 
ssection : SSECTION {firstWord = 0;} '{' titre '}' {printSubsection($4);firstWord = 1;} content ssection
         | SSECTION {printSubsection(NULL);} content ssection
         |;

// env -> LEMME '{' titre '}' texte ENDENV | LEMME texte ENDENV | DEF '{' titre '}' texte ENDENV | DEF texte ENDENV
env : LEMME 
      '{' titre '}' 
      {openEnv("lemme", &lemNb, $3); openPara();}
      texte
      ENDENV
      {closePara(); closeEnv();}
    | LEMME
      {openEnv("lemme", &lemNb, NULL);openPara();
      }
      texte
      ENDENV
      {closePara(); closeEnv();}
    | DEF 
      '{' titre '}' 
      {openEnv("definition", &defNb, $3); openPara();}
      texte
      ENDENV
      {closePara(); closeEnv();}
    | DEF 
      {openEnv("definition", &defNb, NULL); openPara();
      }
      texte
      ENDENV
      {closePara(); closeEnv();};

%%
#include "lex.yy.c"

