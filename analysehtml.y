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

int secNb = 0; //Le numéro de section courant
int ssecNb = 0; //Le numéro de sous section courant
int lemNb = 0; //Le numéro de lemme courant
int defNb = 0; //Le numéro de définition courant
int firstWord = 0; //Flag le prochain mot est il le premier mot d'un bloc
int charNb = 0; //Nombre de caractère courant dans la ligne 

//Pour le style
int width = 21; //Largeur de la page en cm 
int fontSize = 4; //Taille de la font en mm
int h1Size = 8; //Taille du titre principal en mm
int h2Size = 7; //Taille des titre de section en mm
int h3Size = 6; //Taille des titres de ssection en mm
int h4Size = 5; //Taille des titres d'environnement en mm

int textIndent = 15; //Taille de l'indentation en mm

char mainTitle[STR_LEN]; //Le titre de l'article si present.

//Type d'une liste
typedef struct _list {
	char name[STR_LEN];
	struct _list* next;
} list;

/**
 * Ajoute un element a une liste
 */
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

/**
 * L'élément est il dans la liste.
 */
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

list *authors; //La liste des autheurs de l'article

int addAuthor(const char *author) {
    authors = addTolist(author, authors);
    return EXIT_SUCCESS;
}

/**
 * Affiche la liste des autheurs.
 */
int printAuthors() {
    list *p = authors; //Poiteur sur la liste
    list *q = p; //Poiteur sur la liste
    if (p!= NULL) { //Si il y a des autheurs
        //Début de la div des autheurs
        printf("   <div id='authors'>\n     <p>\n"); 
        while (p != NULL) { //Parcours de la liste des autheurs.
            q = p;
            printf("    %s<br></br>\n", p->name); //Affichage d'un autheur
            p = p->next;
            free(q); //On en profite pour liberer la memoire.
        }
        printf("   </p>\n   </div>\n"); //Fermeture de la zone des autheurs
    } 
}

//Pour la gestion de la commande \setsize
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
	} else { //Avertissement de l'utilisateur
	    fprintf(stderr, "\\setsize : valeur non reconnue (%s), ignorée\n", word);
	}
	return EXIT_SUCCESS;
}

/**
 * Génération de la partie css
 */
int generateStyle() {
	printf(" <style>\n");
	printf("  p {\n   ");
	printf("font-size: %dmm;\n    ", fontSize); //Pour la fonte
	printf("text-indent: %dmm;\n   ", textIndent);//Pour l'indentation
	printf("}\n\n");
	printf("  h1 {\n   ");
	printf("font-size: %dmm;\n    ", h1Size); //Pour la taille du titre
	printf("text-align: center;\n    ");	
	printf("}\n\n");
	printf("  h2 {\n   ");
	printf("font-size: %dmm;\n    ", h2Size);//Pour la taille des section
	printf("padding-left: 3mm;\n    ");
	printf("}\n\n");
	printf("  h3 {\n   ");
	printf("font-size: %dmm;\n    ", h3Size);//Pour la taille des ssection
	printf("padding-left: 6mm;\n    ");
	printf("}\n\n");
	printf("  h4 {\n   ");
	printf("font-size: %dmm;\n    ", h4Size); //Pour la taille des environnement
	printf("margin-top:0mm;\n    ");
	printf("}\n\n");
	printf("  #page {\n   ");
	printf("width: %dcm;\n    ", width); //Pour la largeur de la page
	printf("}\n\n");
	printf("  #authors {\n   ");
	printf("text-align: right;\n    ");
	printf("}\n\n");
	printf("  div[id^=\"Lemme\"], div[id^=\"Définition\"] {\n   ");
	printf("border: 1px dashed black;\n    ");
	printf("padding: 5mm 5mm 0 5mm;\n    ");
	printf("margin-bottom: 2mm;\n    ");
	printf("}\n");
	printf(" </style>\n");
	
	return EXIT_SUCCESS;
}

/**
 * Commence un document
 */ 
int openDocument() {
	charNb = 0; //Reinitialisation du compteur de caractère
	firstWord = 1; //Le prochain mot est un premier mot
	//Affichage du doctype (html5)
	printf("<!doctype html>\n<head><title>%s</title><meta charset='utf-8'></head>\n<html>\n <body>\n ", mainTitle);
	generateStyle(); //Generation du css
	printf(" <div id='page'>\n"); //Début du corp du document
	printAuthors(); //Affichage des autheurs
	printMainTitle(); //Affichage du titre principal
	return EXIT_SUCCESS;
}

/**
 * Ferme le document
 */
int closeDocument() {
	charNb = 0; //On reinitialise le compteur de mot
	printf(" </div>\n </body>\n</html>\n"); //Fermeture du bloc pour la page
	return EXIT_SUCCESS;
}

/**
 * Démarre un paragraphe
 */
int openPara() {
	charNb = 0; //On réinitialise le compteur de mot
	printf("    <p>\n"); //Début du paragraphe
	return EXIT_SUCCESS;
}

/**
 * Ferme un pragraphe
 */
int closePara() {
	charNb = 0; //On reinitialise le compteur de mot
	printf("\n    </p>\n"); //Fin du paragraphe
	return EXIT_SUCCESS;
}

/**
 * Affichage d'un mot
 */
int printWord(const char *word) {
  size_t len = strlen(word); //Taille du mot
  if (charNb + len <= LIN_LEN) { //Si le mot ne dépasse pas la ligne
	  if ((charNb + len) == LIN_LEN ) { //Si le mot se termine sur le file
		  printf("%s\n", word); //On le fait suivre d'un retour a la ligne
        charNb = 0;//On reinitialise
	  } else { //Le mot ne dépasse pas 
		  printf("%s", word); //On affiche juste le mot
      charNb += len; //On augmente le compteur de mot
	  }
  } else { //Ca depasse
    printf("\n%s", word); //Retour a la ligne puis mot.
    charNb = strlen(word); //On augmente le compteur de mot.
  }
  return EXIT_SUCCESS;
}

/**
 * On affiche le titre principal
 */
int printMainTitle() {
	charNb = 0; //On reinitialise le compteur
	//Affichage du titre et debut de l'intro
	printf("    <h1> %s </h1>\n  <div id='intro'>\n", mainTitle);
	return EXIT_SUCCESS;
}

/**
 * Démarre une section
 */
int printSection(const char *title) {
	secNb++; //On augmente le nombre de section
  ssecNb = 0; // On reinitialise le numero de sous section
	charNb = 0; // On reinitialise le compteur
	printf("  </div>\n  <div id='section%d'>\n", secNb);//Début de section
	if (title == NULL) { //Si le titre est null
		printf("    <h2> %d : </h2>\n", secNb); //Affichage du numero
	} else { // Sinon
	    printf("    <h2> %d : %s </h2>\n", secNb, title); //Affichage du titre
	}
	return EXIT_SUCCESS;
}

/**
 * Démarre une sous section
 */
int printSubsection(const char *title) {
	ssecNb++; //On augmente le numero de section
	charNb = 0; //Reinitialisation du compteur
	printf("  </div>\n  <div id='ssection%d'>\n", ssecNb); //Début de section
	if (title == NULL) { //Si le titre est null
		printf("    <h3> %d.%d : </h3>\n", secNb, ssecNb); //Affichage du numero
	} else {
	  //Affichage du titre
	  printf("    <h3> %d.%d : %s </h3>\n", secNb, ssecNb, title); 
	}
	return EXIT_SUCCESS;
}

/**
 * Démarre un environnement
 */
int openEnv(const char *env, int *envNb, const char *title) {
	*envNb += 1; //On augmente le nombre d'envirronement
	charNb = 0; // On reinitialise le compteur de caractère
	printf("  <div id ='%s%d'>\n", env, *envNb); //Début d'environnement
	if (title == NULL) { //Si titre null
		printf("    <h4> %s %d </h4>\n", env, *envNb); //Affichage du numero
	} else {
	 //Affichage du titre
		printf("    <h4> %s %d : [%s] </h4>\n", env, *envNb, title);
	}
	return EXIT_SUCCESS;
}

/**
 * Ferme un environnement
 */
int closeEnv() {
	charNb = 0; //Reinitialisation des caractère
	printf("  </div>\n"); //Fermeture
	return EXIT_SUCCESS;
}

%}

%union {
  char word[STR_LEN]; //Pour les mots
  int  nb;//Pour les valeurs
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
//source : axiome
source : declarations INDOC {openDocument();} content part {closeDocument();};

//La partie de declaration (style, titres etc...)
declarations : declaration declarations 
				|
				;

//Un element de declaration
declaration : SETSIZE '{' WORD '}' '{' NUMBER '}' {setSize($3, $6);}
			  |INDENT '{' NUMBER '}' {textIndent = $3;}
			  | WIDTH '{' NUMBER '}' {width = $3;}
			  | mainTitle
			  | AUTHOR '{' titre '}' {addAuthor($3);}; 


//Un paragraphe
para : {firstWord = 0;openPara();} 
		PARA {printWord($2);} texte {closePara();};

// Un texte (mot suivi d'un mot)
texte : WORD {printWord($1);}  texte
      |
      ;


// Le titre principal
mainTitle : TITLE '{' titre '}' {strncpy(mainTitle, $3, STR_LEN); firstWord = 1;};


// Contenu du titre principale
titre : WORD  titre {snprintf($$, STR_LEN, "%s %s", $1, $2);}
      | WORD {snprintf($$, STR_LEN, "%s", $1);}
      ;

// Succesion de section
part : section part
     | 
     ;

// Du contenu succession de paragraphe et d'envirronement 
content : para content
        | env content
		    |
        ;

// Une section
section : SECTION {firstWord = 0;} 
          '{' titre '}' 
          {printSection($4);firstWord = 1;} content ssection 
        | SECTION {printSection(NULL);} content ssection
        ;
 
// Une sous section
ssection : SSECTION {firstWord = 0;} 
           '{' titre '}' 
           {printSubsection($4);firstWord = 1;} content ssection
         | SSECTION {printSubsection(NULL);} content ssection
         |;

// Un envirronement (lemme, definition)
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
      {openEnv("Définition", &defNb, $3); openPara();}
      texte
      ENDENV
      {closePara(); closeEnv();}
    | DEF 
      {openEnv("Définition", &defNb, NULL); openPara();
      }
      texte
      ENDENV
      {closePara(); closeEnv();};

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






