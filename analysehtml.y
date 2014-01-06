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
int firstWord = 0;
int charNb = 0;

int width = 21;
int fontSize = 4;
int h1Size = 12;
int h2Size = 10;
int h3Size = 8;
int h4Size = 6;

int textIndent = 15;

char mainTitle[STR_LEN];

typedef struct _list {
	char name[STR_LEN];
	struct _list* next;
} list;

list *addTolist(const char *n, list* l) {
	if (n == NULL) {
		return(NULL);
	}
	int len = strlen(n);
	list *new =(list *) malloc(sizeof(struct _list));
	strncpy(new->name, n, len);
	new->next=l;
	return(new);
}

list *isInlist(const char *n,list *l){
	if (l == NULL) {
		return NULL;
	}
	list *p = l;
	int len = strlen(n);
	while (p != NULL) {
		if (strcmp(p->name, n) == 0) {
			return p;
		}
		p = p->next;
	}
	return NULL;
} 

list *authors;

int addAuthor(const char *author) {
    authors = addTolist(author, authors);
    return EXIT_SUCCESS;
}

int printAuthors() {
    list *p = authors;
    list *q = p;
    if (p!= NULL) {
        printf("   <div id='authors'>\n     <p>\n");
        while (p != NULL) {
            q = p;
            printf("    %s<br></br>\n", p->name);
            p = p->next;
            free(q);
        }
        printf("   </p>\n   </div>\n");
    } 
}

int setSize(const char *word, int nb) {
	if (strcmp(word,"title") == 0) {
		h1Size = nb;
	} else
	if (strcmp(word,"section") == 0) {
		h2Size = nb;
	} else
	if (strcmp(word,"ssection") == 0) {
		h3Size = nb;
	} else
	if (strcmp(word,"env") == 0) {
		h4Size = nb;
	} else
	if (strcmp(word,"text") == 0) {
		fontSize = nb;
	} else {
	    fprintf(stderr, "\\setsize : valeur non reconnue (%s), ignorée\n", word);
	}
	return EXIT_SUCCESS;
}

int generateStyle() {
	printf(" <style>\n");
	printf("  p {\n   ");
	printf("font-size: %dmm;\n    ", fontSize);
	printf("text-indent: %dmm;\n   ", textIndent);
	printf("}\n\n");
	printf("  h1 {\n   ");
	printf("font-size: %dmm;\n    ", h1Size);
	printf("text-align: center;\n    ");	
	printf("}\n\n");
	printf("  h2 {\n   ");
	printf("font-size: %dmm;\n    ", h2Size);
	printf("}\n\n");
	printf("  h3 {\n   ");
	printf("font-size: %dmm;\n    ", h3Size);
	printf("}\n\n");
	printf("  h4 {\n   ");
	printf("font-size: %dmm;\n    ", h4Size);
	printf("margin-top:0mm;\n    ");
	printf("}\n\n");
	printf("  #page {\n   ");
	printf("width: %dcm;\n    ", width);
	printf("}\n\n");
	printf("  #authors {\n   ");
	printf("text-align: right;\n    ");
	printf("}\n\n");
	printf("  div[id^=\"Lemme\"], div[id^=\"Definition\"] {\n   ");
	printf("border: 1px dashed black;\n    ");
	printf("padding: 5mm 5mm 0 5mm;\n    ");
	printf("}\n");
	printf(" </style>\n");
	return EXIT_SUCCESS;
}


int openDocument() {
	charNb = 0;
	firstWord = 1;
	printf("<!doctype html>\n<head><title>%s</title><meta charset='utf-8'></head>\n<html>\n <body>\n ", mainTitle);
	generateStyle();
	printf(" <div id='page'>\n");
	printAuthors();
	printMainTitle();
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
     printf("\n%s ", word);
     charNb = 0;
   }
	 return EXIT_SUCCESS;
}

int printMainTitle() {
	charNb = 0;
	printf("    <h1> %s </h1>\n  <div id='intro'>\n", mainTitle);
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
  int  nb; 
}

%token INDOC
%token SECTION
%token SSECTION
%token LEMME
%token DEF
%token <word> WORD
%token ENDENV
%token TITLE
%token <word> PARA
%token <nb> NUMBER
%token SETSIZE
%token INDENT
%token WIDTH
%token AUTHOR

%type <word> titre

%%
//source -> title content part
source : declarations INDOC {openDocument();} content part {closeDocument();};

declarations : declaration declarations 
				|
				;

declaration : SETSIZE '{' WORD '}' '{' NUMBER '}' {setSize($3, $6);}
			  |INDENT '{' NUMBER '}' {textIndent = $3;}
			  | WIDTH '{' NUMBER '}' {width = $3;}
			  | mainTitle
			  | AUTHOR '{' titre '}' {addAuthor($3);}; 


//para -> PARA texte
para : {firstWord = 0;openPara();} 
		PARA {printWord($2);} texte {closePara();};

// texte -> WORD texte |
texte : WORD {printWord($1);}  texte
      |
      ;


// title -> TITLE '{' mainTitle '}' | 
mainTitle : TITLE '{' titre '}' {strncpy(mainTitle, $3, STR_LEN); firstWord = 1;};


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
      {openEnv("Lemme", &lemNb, $3); openPara();}
      texte
      ENDENV
      {closePara(); closeEnv();}
    | LEMME
      {openEnv("Lemme", &lemNb, NULL);openPara();
      }
      texte
      ENDENV
      {closePara(); closeEnv();}
    | DEF 
      '{' titre '}' 
      {openEnv("Definition", &defNb, $3); openPara();}
      texte
      ENDENV
      {closePara(); closeEnv();}
    | DEF 
      {openEnv("Definition", &defNb, NULL); openPara();
      }
      texte
      ENDENV
      {closePara(); closeEnv();};

%%
#include "lex.yy.c"

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Usage : %s inputFile [outputFile]", argv[0]);
		exit(EXIT_SUCCESS); 
	}
	if ((yyin = fopen(argv[1], "r")) == NULL) {
		fprintf(stderr, "Error while opening %s\n", argv[1]);
		exit(EXIT_FAILURE);
	}
	close(STDOUT_FILENO);
	if (argc > 2) {
	    if ((open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644)) == -1) {
	        perror("Output file :");
		    exit(EXIT_FAILURE);
	    }
	} else {
	    if ((open("a.html", O_WRONLY | O_CREAT | O_TRUNC, 0644)) == -1) {
	        perror("Output file :");
		    exit(EXIT_FAILURE);
	    }
	}
	yyparse();
	//todo free la liste
	exit(EXIT_SUCCESS);
}






