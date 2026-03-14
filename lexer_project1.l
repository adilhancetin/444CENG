%option noyywrap
%option yylineno
%{
using namespace std;
#include <fstream>
#include <vector>
#include <string>
#include "MyFlexLexer.h"
extern MyFlexLexer *lexer;
extern vector<int> numbers;
extern bool is_bridge;
extern void check_ascending();
extern int deck_number;
extern bool null_suit;
extern string current_line;
extern bool hand_invalid;
extern int card_number;
extern ofstream output_file;
extern void write_chemical_result(const char *formula);
extern int cubic_legal;
extern int bridge_hand;
extern int bridge_hand_null;
extern int bridge_hand_not_sem;
extern int chem_legal;
extern int chem_legal_not_sem;
extern int unrecognized;
%}

digit             [2-9]
rot               [UDLRFB]
rot_prime         {rot}'
layer_rot         [udlrfb]
layer_rot_prime   {layer_rot}'
mid_rot           [MES]
mid_rot_prime     {mid_rot}'
full_rot          [xyz]
full_rot_prime    {full_rot}'

multiple_rot      ({rot}|{rot_prime}|{layer_rot}|{layer_rot_prime}|{mid_rot}|{mid_rot_prime}|{full_rot}|{full_rot_prime}){digit}
cube_legal_move   ({rot}|{rot_prime}|{layer_rot}|{layer_rot_prime}|{mid_rot}|{mid_rot_prime}|{full_rot}|{full_rot_prime}|{multiple_rot})+

element           (Ac|Ag|Al|Am|Ar|As|At|Au|B|Ba|Be|Bh|Bi|Bk|Br|C|Ca|Cd|Ce|Cf|Cl|Cm|Cn|Co|Cr|Cs|Cu|Db|Ds|Dy|Er|Es|Eu|F|Fe|Fl|Fm|Fr|Ga|Gd|Ge|H|He|Hf|Hg|Ho|Hs|I|In|Ir|K|Kr|La|Li|Lr|Lu|Lv|Md|Mg|Mn|Mo|Mt|N|Na|Nb|Nd|Ne|Nh|Ni|No|Np|O|Og|Os|P|Pa|Pb|Pd|Pm|Po|Pr|Pt|Pu|Ra|Rb|Re|Rf|Rg|Rh|Rn|Ru|S|Sb|Sc|Se|Sg|Si|Sm|Sn|Sr|Ta|Tb|Tc|Te|Th|Ti|Tl|Tm|Ts|U|V|W|Xe|Y|Yb|Zn|Zr)
formula_num       ([2-9]|[1-9][0-9]+)
chemical_couple   {element}({formula_num})?
chemical_formula  [/]({chemical_couple})+[/]

special_cards     [JQKA]
number_array      ({digit}|{special_cards})+
dot               [.]  


whitesp        [ \n\t\r]*



%%

^{cube_legal_move}$   {output_file << yytext << " => Rubik's Cube transformation" << endl; cubic_legal++; }
^{chemical_formula}$  {write_chemical_result(yytext);  }
{number_array}        { is_bridge = true; current_line += yytext; for(int i=0;yytext[i]!='\0';i++){ if(yytext[i]=='A'){numbers.push_back(13);} else if(yytext[i]=='K'){numbers.push_back(12);} else if(yytext[i]=='Q'){numbers.push_back(11);} else if(yytext[i]=='J'){numbers.push_back(10);} else{numbers.push_back(yytext[i]-'0');} } }
^[^2-9JQKA.\n][^\n]*  { output_file << yytext << " => Unrecognized" << endl; unrecognized++; }
\n                    { if(is_bridge || deck_number > 0){ check_ascending(); } deck_number = 0; is_bridge=false; null_suit=false; hand_invalid=false; card_number=0; current_line=""; }
{dot}                 { if(is_bridge || deck_number > 0){ current_line += yytext; check_ascending(); }    }
{}
%%