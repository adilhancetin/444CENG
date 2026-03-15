#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cstring>
#include "FlexLexer.h"
#include "MyFlexLexer.h"
using namespace std;

vector<int> numbers;
bool is_bridge = false;
int deck_number = 0;
int card_number = 0;
bool null_suit = false;
string current_line;
bool hand_invalid = false;
ofstream output_file;

int cubic_legal = 0;
int bridge_hand = 0;
int bridge_hand_null = 0;
int bridge_hand_not_sem = 0;
int chem_legal = 0;
int chem_legal_not_sem = 0;
int unrecognized = 0;

void MyFlexLexer::reportToken(const char *label)
{
   cout << "Recognized " << label << " (" << YYText() << ") line:" << yylineno << endl;
}

MyFlexLexer *lexer = new MyFlexLexer();


void check_ascending(){
   deck_number++;
   if(numbers.empty()){
      null_suit = true;
   }

   for(int i=1;i<numbers.size();i++){
      if(numbers[i]<numbers[i-1]){
         hand_invalid = true;
         break;
      }
   }
   if(!hand_invalid){
      card_number += numbers.size();
   }
   if(deck_number==4){
      // a fully valid bridge game notation
      if(hand_invalid){
         output_file << current_line << " => Unrecognized" << endl;
         unrecognized++;
      } else if(card_number > 13){
         // valid bridge hand but semantically incorrect
         output_file << current_line << " => Bridge hand, semantically incorrect" << endl;
         bridge_hand++;
         bridge_hand_not_sem++;
         if(null_suit){
            bridge_hand_null++;
         }
      } else {
         output_file << current_line << " => Bridge hand" << endl;
         bridge_hand++;
         if(null_suit){
            bridge_hand_null++;
         }
      }

      deck_number = 0;
      card_number = 0;
      null_suit = false;
      hand_invalid = false;
      current_line = "";
   }

   numbers.clear();
   is_bridge = false;
}

void write_chemical_result(const char *formula)
{

   if(strlen(formula) > 26){
      output_file << formula << " => Chemical formula, semantically incorrect" << endl;
      chem_legal++;
      chem_legal_not_sem++;
   } else {
      output_file << formula << " => Chemical formula" << endl;
      chem_legal++;
   }
}

int main(int argc, char **argv)
{
   
   if(argc <= 1){
      cout << "File not found!" << endl;
      return 0;
   }

   const string txt_file = string(argv[1]) + ".txt";
   const string out_file = string(argv[1]) + "-out.txt";
   ifstream input_file(txt_file);
   output_file.open(out_file);

   if(!input_file.is_open()){
      cout << "File not found!" << endl;
      output_file.close();
      return 1;
   }

   lexer->switch_streams(&input_file);
   while(lexer->yylex() != 0){
      if(is_bridge){
         check_ascending();
      }
   }
   if(is_bridge || deck_number > 0){
      check_ascending();
   }

   input_file.close();
   output_file.close();

   cout << "# Rubik's Cube Transformations: " << cubic_legal << endl;
   cout << "# Bridge Hands: " << bridge_hand << endl;
   cout << "# Bridge Hands with null suits: " << bridge_hand_null << endl;
   cout << "# Bridge Hands semantically incorrect: " << bridge_hand_not_sem << endl;
   cout << "# Chemical Formulae: " << chem_legal << endl;
   cout << "# Chemical Formulae semantically incorrect: " << chem_legal_not_sem << endl;
   cout << "# Unrecognized: " << unrecognized << endl;

   return 0;
}
