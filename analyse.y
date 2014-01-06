%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>


#ifndef STR_LEN
#define STR_LEN 256
#define LIN_LEN 80
#endif

int secNb = 0;
int ssecNb = 0;
int lemNb = 0;
int defNb = 0;
int charNb = 0;
int firstWord = 1;


int newline() {
	printf("\n");
	return EXIT_SUCCESS;
}

int indent() {
	printf("    ");
	charNb = 4;
	return EXIT_SUCCESS;
}

int printWord(const char *word) {
	size_t len = strlen(word);
  if (charNb + len <= LIN_LEN) {
		if ((charNb + len) == LIN_LEN ) {
			printf("%s\n", word);
     	charNb = 0;
		} else {
			printf("%s", word);
     	charNb += len;
	  }
  } else {
    printf("\n%s", word);
    charNb = strlen(word);
  }
	return EXIT_SUCCESS;
}

int printMainTitle(const char *word) {
	size_t len;
	int i;
	len = strlen(word);
	if (len > LIN_LEN) {
		fprintf(stderr, "Le titre est trop long. (80 caractères max).\n");
	} else {
		for (i = 0; i < (LIN_LEN - len) / 2; i++){
			printf(" ");						
		}
		printf("%s\n", word);
	}			
	return EXIT_SUCCESS;
}

int printSection(const char *title) {
	secNb++;
    ssecNb = 0;
	if (title == NULL) {
		printf("%d :", secNb);
	} else {
	    printf("%d : %s", secNb, title);
	}
	return EXIT_SUCCESS;
}

int printSubsection(const char *title) {
	ssecNb++;
	if (title == NULL) {
		printf("%d.%d :", secNb, ssecNb);
	} else {
	    printf("%d.%d : %s", secNb, ssecNb, title);
	}
	return EXIT_SUCCESS;
}

//verifier taille totale
int openEnv(const char *env, int *envNb, const char *title) {
	*envNb += 1;
	if (title == NULL) {
		printf("*** %s %d ***", env, *envNb);
	} else {
		printf("*** %s %d : [%s] ***", env, *envNb, title);
	}
	return EXIT_SUCCESS;
}

int closeEnv() {
	printf("***** FIN *****");
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
source : mainTitle content part;

//para -> PARA texte
para : {firstWord = 0; newline(); newline(); indent();} 
		PARA {printWord($2);} texte;

// texte -> WORD texte |
texte : WORD {printWord($1);} texte
      |
      ;


// title -> TITLE '{' mainTitle '}' | 
mainTitle : TITLE '{' titre '}' {printMainTitle($3); firstWord = 1;}
	|
	;

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
        | {newline();newline();} env content
		| {newline();newline();}
        ;

// section -> SECTION '{' titre '}' content ssection | SECTION content ssection
section : SECTION {firstWord = 0;} '{' titre '}' {printSection($4);firstWord = 1;} content ssection 
        | SECTION {printSection(NULL);} content ssection;
 
// ssection -> SSECTION '{' titre '}' content ssection | SSECTION content ssection 
ssection : SSECTION {firstWord = 0;} '{' titre '}' {printSubsection($4);firstWord = 1;} content ssection
         | SSECTION {printSubsection(NULL);} content ssection
         |
		 ;

// env -> LEMME '{' titre '}' texte ENDENV | LEMME texte ENDENV | DEF '{' titre '}' texte ENDENV | DEF texte ENDENV
env : LEMME 
      '{' titre '}' 
      {openEnv("lemme", &lemNb, $3); newline(); indent();}
      texte
      ENDENV
      {newline(); closeEnv();}
    | LEMME
      {openEnv("lemme", &lemNb, NULL);
       newline();
	   indent();
      }
      texte
      ENDENV
      {newline(); closeEnv();}
    | DEF 
      '{' titre '}' 
      {openEnv("definition", &defNb, $3); newline(); indent();}
      texte
      ENDENV
      {newline(); closeEnv();}
    | DEF 
      {openEnv("definition", &defNb, NULL);
       newline();
	   indent();
      }
      texte
      ENDENV
      {newline(); closeEnv();}
	;

%%
#include "lex.yy.c"
//Point d'entré de l'application
int main(int argc, char *argv[]) {
	if (argc < 2) { //Trop peu d'argument
		printf("Usage : %s inputFile [outputFile]", argv[0]);
		exit(EXIT_SUCCESS); 
	}
	if ((yyin = fopen(argv[1], "r")) == NULL) { //Ouverture de l'entré
		fprintf(stderr, "Error while opening %s\n", argv[1]);
		exit(EXIT_FAILURE);
	}
	close(STDOUT_FILENO); //Fermeture de la sortie standard
	if (argc > 2) { //Si sortie fournie
	    //Ouverture de la sortie
	    if ((open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644)) == -1) {
	        perror("Output file :");
		    exit(EXIT_FAILURE);
	    }
	} else {
	    //Ouverture de la sortie par defaut
	    if ((open("a.html", O_WRONLY | O_CREAT | O_TRUNC, 0644)) == -1) {
	        perror("Output file :");
		    exit(EXIT_FAILURE);
	    }
	}
	//Démarrage
	yyparse();
	exit(EXIT_SUCCESS);
}
