%option noyywrap
%option yylineno
        /*----- Seccion de Declaraciones ----------------*/

%{
#include <iostream> // stdout, stdin, cout...
#include <fstream>  // ifstream
#include <utility>  // pair
#include <cstring>  // strlen
#include <cctype>   // isspace
#include "json.h"   // JSON classes

// Colores para la salida por terminal
#define reset "\x1B[0m"
// Color de texto
#define BLK "\x1B[0;30m"
#define RED "\x1B[0;31m"
#define GRN "\x1B[0;32m"
#define YEL "\x1B[0;33m"
#define BLU "\x1B[0;34m"
#define MAG "\x1B[0;35m"
#define CYN "\x1B[0;36m"
#define WHT "\x1B[0;37m"
// Color de fondo
#define BLKB "\x1B[40m"
#define REDB "\x1B[41m"
#define GRNB "\x1B[42m"
#define YELB "\x1B[43m"
#define BLUB "\x1B[44m"
#define MAGB "\x1B[45m"
#define CYNB "\x1B[46m"
#define WHTB "\x1B[47m"
using namespace std;
FILE* fichero;
JSONObject object; 
bool expecting_pair;

void deleteFirstChar(char* str) {
    size_t len = strlen(str)-1;
    memmove(str, str+1, len);
}

void deleteLastChar(char* str) {
    size_t len = strlen(str)-1;
    memmove(str, str, len);
    str[len]='\0';
}

%}

/* Declaramos algunas condiciones de arranque */
%x in_obj
%x in_val
%x in_arr

/* Declaramos los distintos patrones que podemos encontrar en JSON y algunos auxiliares.
 * WHITESPACE: Espacio en blanco, tabulador, salto de línea o retorno de carro
 * CHAR: Carácter válido dentro de una cadena
 * HEX: Dígito hexadecimal
 * SPECIAL_CHAR: Carácter con interpretación especial dentro de una cadena
 * STRING: Cadena de caracteres delimitada por ""
 * DIGIT: Dígito decimal
 * NUMBER: Número expresado en base 10. Admite parte fraccionaria y exponente.
 * VALUE: Valor válido en JSON
 * ARRAY: Array válido en JSON
 * OBJECT: Objeto válido en JSON
 */

WHITESPACE      [ \t\n\r]
CHAR            [^\\"]
HEX             ([0-9]|[A-F])
SPECIAL_CHAR    \\(\"|\\|\/|b|f|n|r|t|u{HEX}{4})
STRING          \"({CHAR}|{SPECIAL_CHAR}|{WHITESPACE})*\"
DIGIT           [0-9]
NUMBER          -?{DIGIT}+(\.{DIGIT}+)?((e|E)(-|\+){DIGIT}+)?
VALUE           {WHITESPACE}?({STRING}|{NUMBER}|true|false|null){WHITESPACE}?
ARRAY           \[({WHITESPACE}*|{VALUE}(,{VALUE})*)\]
PAIR            {WHITESPACE}?{STRING}:{VALUE}
OBJECT          \{({WHITESPACE}*|{PAIR}(,{PAIR})*)\}

%%
        /*----- Seccion de Reglas ----------------*/
<*>\{           {
                    BEGIN(in_obj);
                    //cout << GRN << yytext << reset;
                }
<in_obj>\}      {
                    if(expecting_pair) {
                        cerr << RED << "ERR:Encontrada ',' al final del objeto. Tras cada ',' debe ir una tupla \"nombre\":\"valor\"" << reset << endl;
                        return -1;
                    }
                    //cout << GRN << yytext << reset;
                    return 0;
                }
<in_obj>,       { expecting_pair = true; }
<in_obj>{PAIR}  {
                    //cout << BLU << yytext << reset;
                    /* Dividimos la cadena por : ya que es el separardor de key,value
                     * Convertimos la cadena en un std::pair y añadimos al objeto
                     */ 
                    char pair[yyleng];
                    strcpy(pair, yytext);

                    char* name = strtok(pair, ":");
                    char* val_str = strtok(NULL, ":");

                    /* remove unwanted " and spaces */
                    while(isspace(name[0]) || name[0] == '"')
                        deleteFirstChar(name);
                    while(isspace(name[strlen(name)-1]) || name[strlen(name)-1] == '"')
                        deleteLastChar(name);

                    while(isspace(val_str[0]))
                        deleteFirstChar(val_str);
                    while(isspace(val_str[strlen(val_str)-1]))
                        deleteLastChar(val_str);

                    //cout << YEL << "Nombre: " << name << " Valor: " << val_str << reset << endl;
                    
                    BEGIN(in_val);
                    YY_BUFFER_STATE yyincpy = YY_CURRENT_BUFFER;
                    YY_BUFFER_STATE buf;
                    buf = yy_scan_string(val_str);
                    int res = yylex();
                    yy_delete_buffer(buf);
                    yy_switch_to_buffer(yyincpy);
                    //cout << RED << res << reset << endl;
                    BEGIN(in_obj);

                    while(val_str[0] == '"')
                        deleteFirstChar(val_str);
                    while(val_str[strlen(val_str)-1] == '"')
                        deleteLastChar(val_str);

                    if(res == -1) {
                        cerr << RED <<"Valor inválido en " << yylineno << reset << endl;
                        return -1;
                    }
                    else {
                        expecting_pair = false; // Hemos encontrado una pareja válida
                        value_t type = (value_t)res;
                        void* data = NULL;
                        size_t size;
                        switch(type) {
                            case str:
                                size=strlen(val_str)+1;
                                data = calloc(size, sizeof(char));  //new char[size];
                                strcpy((char*)data, val_str);
                                break;
                            case num:
                                data = malloc(sizeof(long double)); //new long double;
                                size=sizeof(long double);
                                *(long double*)data = strtold(val_str, NULL);
                                break;
                            case tru:
                                data = malloc(sizeof(bool));    //new bool;
                                size=sizeof(bool);
                                *(bool*)data = true;
                                break;
                            case fal:
                                data = malloc(sizeof(bool));    //new bool;
                                size = sizeof(bool);
                                *(bool*)data = false;
                                break;
                            case nil:
                                data = NULL;
                                size = 0;
                                break;
                            default:
                                return -1;
                        }

                        JSONValue value(type, size, data);
                        object.add_pair(make_pair(name, value));
                        free(data);
                        }
                }

<in_val>{STRING}    { return value_t::str;}
<in_val>{NUMBER}    { return value_t::num;}
<in_val>{OBJECT}    { return value_t::obj;}
<in_val>true        { return value_t::tru;}
<in_val>false       { return value_t::fal;}
<in_val>nil         { return value_t::nil;}
<in_val>.|\n        { return -1;}

<*>{WHITESPACE}     {cout << yytext;}
<*>.|\n            {cout << REDB << yytext << reset;}

%%
        /*----- Seccion de Procedimientos --------*/
int main (int argc, char *argv[])
{
    if (argc == 2)
    {
        fichero = fopen(argv[1], "rt");
        if (fichero == NULL)
        {
            cout << "error de lecura" << endl;
            exit (1);
        }
        cout << reset << "Fichero abierto" << endl;
        /* Hacemos un dump completo del archivo a stdout para probar la lectura */
        char c;
        while((c=getc(fichero)) != EOF)
            cout << c;
        rewind(fichero);
         /* Nuestro lexer asume que 1 archivo = 1 objeto JSON */

        yyin = fichero;
        int res = yylex();
        if(res)
            return 1;
        else {
            cout << "Archivo correcto" << endl;
        }
    }
    else {
        cerr << "Falta argumento del archivo a convertir" << endl;
        exit(1);
    }
/*
    nc = np = nl = 0;
    yyFlexLexer flujo (&fichero,0);
    flujo.yylex();
    escribir_datos(nc,np,nl);
    return 0;
*/
}


