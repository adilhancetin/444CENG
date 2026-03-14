%option noyywrap
%option yylineno
%{
using namespace std;
#include <vector>
#include "MyFlexLexer.h"
extern MyFlexLexer *lexer;
extern vector<int> numbers;
extern bool is_bridge;
extern void check_ascending();
extern int deck_number;
extern bool null_suit;
%}

digit             [2-9]
rot               [UDLRFB]
rot_prime         {rot}'
layer_rot         [udlrfbxyz]
layer_rot_prime   {layer_rot}'
mid_rot           [MES]
mid_rot_prime     {mid_rot}'
full_rot          [XYZ]
full_rot_prime    {full_rot}'

multiple_rot      ({rot}|{rot_prime}|{layer_rot}|{layer_rot_prime}|{mid_rot}|{mid_rot_prime}|{full_rot}|{full_rot_prime}){digit}
cube_legal_move   ({rot}|{rot_prime}|{layer_rot}|{layer_rot_prime}|{mid_rot}|{mid_rot_prime}|{full_rot}|{full_rot_prime}|{multiple_rot})+

special_cards     [JQKA]
number_array      ({digit}|{special_cards})+
dot               .  


whitesp        [ \n\t\r]*



%%

^{cube_legal_move}    cout << "It is a legal move" << endl;
{number_array}        { is_bridge = true; for(int i=0;yytext[i]!='\0';i++){ if(yytext[i]=='A'){numbers.push_back(13);} else if(yytext[i]=='K'){numbers.push_back(12);} else if(yytext[i]=='Q'){numbers.push_back(11);} else if(yytext[i]=='J'){numbers.push_back(10);} else{numbers.push_back(yytext[i]-'0');} } }
^[^\n]+               { /* ignore invalid last line without newline */ }
\n                    { deck_number = 0; is_bridge=false;  null_suit=false; }
{dot}                 { if(is_bridge){ check_ascending(); }    }
{}
%%