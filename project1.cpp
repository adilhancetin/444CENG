#include <iostream>
#include <fstream>
#include <vector>
#include "FlexLexer.h"
#include "MyFlexLexer.h"
using namespace std;

vector<int> numbers;
bool is_bridge = false;
int deck_number = 0;
int card_number = 0;
bool null_suit = false;

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
         cout << "Not a valid bridge game hand notation" << endl;
         numbers.clear();
         is_bridge = false;
         deck_number = 0;
         return;
      }
   }
   cout << "It's a valid bridge game hand notation" << endl;

   card_number += numbers.size();
   if(deck_number==4){
      // a fully valid bridge game notation
      // write to the const string txt_file = string(argv[1]) + "-out.txt";
      if(card_number > 13){
         // valid bridge hand but semantically incorrect
      }

      deck_number = 0;
      null_suit = false;
   }

   numbers.clear();
   is_bridge = false;
}


int main(int argc, char **argv)
{
   
   if(argc <= 1){
      cout << "No input file is available." << endl;
      return 0;
   }

   const string txt_file = string(argv[1]) + ".txt";
   ifstream input_file(txt_file);

   if(input_file.is_open()){

      lexer->switch_streams(&input_file);
      while(lexer->yylex() != 0){
         if(is_bridge){
            check_ascending();
         }
      }
      check_ascending(); 


      input_file.close();
   }

   return 0;
}
