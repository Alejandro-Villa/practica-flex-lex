%option noyywrap
        /*----- Seccion de Declaraciones ----------------*/

%{
#include <iostream>
#include <fstream>
#include "json.h"
using namespace std;
ifstream fichero;
%}

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
SPECIAL_CHAR    \\(\"|\\|/|b|f|n|r|t|u{HEX}{4})
STRING          \"({CHAR}|{SPECIAL_CHAR}|{WHITESPACE})*\"
DIGIT           [0-9]
NUMBER          -?{DIGIT}+(\.{DIGIT}+)?((e|E)(-|\+){DIGIT}+)?
VALUE           {WHITESPACE}?({STRING}|{NUMBER}|{OBJECT}|{ARRAY}|true|false|null){WHITESPACE}?
ARRAY           \[({WHITESPACE}*|{VALUE}(,{VALUE})*)\]
PAIR            {WHITESPACE}?{STRING}:{VALUE}
OBJECT          \{({WHITESPACE}*|{PAIR}(,{PAIR})*)\}

%%
        /*----- Seccion de Reglas ----------------*/


%%
        /*----- Seccion de Procedimientos --------*/
int main (int argc, char *argv[])
{
    if (argc == 2)
    {
        fichero.open (argv[1]);
        if (!fichero.good())
        {
            cout << "error de lecura" << endl;
            exit (1);
        }
        cout << "Fichero abierto" << endl;
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
