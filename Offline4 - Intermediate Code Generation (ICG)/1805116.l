%option noyywrap yylineno

%x STR_STATE
%x STR_ERROR_STATE
%x MULTILINE_COMMENT_STATE
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE

%{
#include<iostream>
//#include<fstream>
#include<bits/stdc++.h>
#include"1805116_symbol.cpp"
#include "y.tab.h"
using namespace std;

#define YYSTYPE symbolInfo*

extern symbolTable symboltable;

void yyerror(const char* );

extern int lineCount;
int storeLineCount;
int string_line = 0;
extern int errorCount;
//extern YYSTYPE yylval;


string str1 = "";
string str3 = "";
string str4 = "";

extern ofstream errorFile;
extern ofstream logFile;

%}
  
WHITESPACE [  \f\r\t\v]+
SPECIAL_CHAR '(\\[\\nftbvra0\'])'
CHAR '([ -~]{-}['\\])'
SPECIAL_CHAR_STR (\\[\\nftbvra0\'])
MULTICHAR ([ -~]{-}['\\])



%%
{WHITESPACE}    {    }

\r?\n 		{
		lineCount++;
}
 
"if"         {
		/*logFile << "Line no " << lineCount<< ":  Token <IF> Lexeme " << yytext <<" found\n\n";
		token << " <IF> ";*/
		return IF;
}   

"for"		{
		/*logFile << "Line no " << lineCount << ":  Token <IF> Lexeme " << yytext <<" found\n\n";
		token << " <FOR> ";*/
		return FOR;
}

"do"		{
		/*logFile << "Line no " << lineCount << ":  Token <DO> Lexeme " << yytext <<" found\n\n";
		token << " <DO> ";*/
		return DO;
}

"int"		{
		/*logFile << "Line no " << lineCount << ":  Token <INT> Lexeme " << yytext <<" found\n\n";
		token << " <INT> ";*/
		return INT;
}

"float"		{
		/*logFile << "Line no " << lineCount << ":  Token <FLOAT> Lexeme " << yytext <<" found\n\n";
		token << " <FLOAT> ";*/
		return FLOAT;
}

"void"		{
		/*logFile << "Line no " << lineCount << ":  Token <VOID> Lexeme " << yytext <<" found\n\n";
		token << " <VOID> ";*/
		return VOID;
}

"switch"		{
		/*logFile <<  "Line no " << lineCount << ":  Token <SWITCH> Lexeme " << yytext <<" found\n\n";
		token << " <SWITCH> ";*/
		return SWITCH;
}

"default"		{
		/*logFile <<"Line no " << lineCount << ":  Token <DEFAULT> Lexeme " << yytext <<" found\n\n";
		token << " <DEFAULT> ";*/
		return DEFAULT;
}

"else"		{
		/*logFile <<  "Line no " << lineCount << ":  Token <ELSE> Lexeme " << yytext <<" found\n\n";
		token << " <ELSE> ";*/
		return ELSE;
}

"while"		{
		/*logFile <<"Line no " << lineCount << ":  Token <WHILE> Lexeme " << yytext <<" found\n\n";
		token << " <WHILE> ";*/
		return WHILE;
}

"break"		{
		/*logFile <<"Line no " << lineCount << ":  Token <BREAK> Lexeme " << yytext <<" found\n\n";
		token << " <BREAK> ";*/
		return BREAK;
}

"char"		{
		/*logFile << "Line no " << lineCount << ":  Token <CHAR> Lexeme " << yytext <<" found\n\n";
		token << " <CHAR> ";*/
		return CHAR;
}

"double"		{
		/*logFile <<  "Line no " << lineCount << ":  Token <DOUBLE> Lexeme " << yytext <<" found\n\n";
		token << " <DOUBLE> ";*/
		return DOUBLE;
}

"return"		{
		/*logFile << "Line no " << lineCount << ":  Token <RETURN> Lexeme " << yytext <<" found\n\n";
		token << " <RETURN> ";*/
		return RETURN;
}

"case"		{
		/*logFile << "Line no " << lineCount << ":  Token <CASE> Lexeme " << yytext <<" found\n\n";
		token << " <CASE> ";*/
		return CASE;
}

"continue"		{
		/*logFile << "Line no " << lineCount << ":  Token <CONTINUE> Lexeme " << yytext <<" found\n\n";
		token << " <CONTINUE> ";*/
		return CONTINUE;
}

"println"		{
		return PRINTLN;
}


[0-9]+		{
			/*logFile <<  "Line no " << lineCount<< ":  Token <CONST_INT> Lexeme " << yytext <<" found\n\n";
			token << " <CONST_INT, " << yytext << "> ";
			bool flag = symboltable.insertCurrScope(yytext,"CONST_INT",logFile);
			if(flag){
				symboltable.printAllScope(logFile);
				
			}
			else 
				logFile << yytext << " already exists in current ScopeTable" << endl;*/

			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("int");
			yylval.symbol = (YYSTYPE)si;
			return CONST_INT;

			

			
}

[0-9]*(\.[0-9]+)?([Ee][+-]?[0-9]+)? {
			/*logFile <<  "Line no " << lineCount<< ":  Token <CONST_FLOAT> Lexeme " << yytext <<" found\n\n";
			token << " <CONST_FLOAT, " << yytext << "> ";
			bool flag = symboltable.insertCurrScope(yytext,"CONST_FLOAT", logFile);
			if(flag){
				symboltable.printAllScope(logFile);
			}
			else 
				logFile << yytext << " already exists in current ScopeTable" << endl;*/

			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("float");
			yylval.symbol = (YYSTYPE) si;
			return CONST_FLOAT;

			
}

"+"|"-" 	{
			/*logFile<<"Line no "<< lineCount << ": Token <ADDOP> Lexeme "<< yytext << " found\n\n";
			token << " <ADDOP, " << yytext <<"> ";*/
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			//si->setType("ADDOP");
			si->setType("ID");
			yylval.symbol = (YYSTYPE)si;
			return ADDOP;
}

"*"|"/"|"%" {
			/*logFile<<"Line no "<< lineCount << ": Token <MULOP> Lexeme "<< yytext << " found\n\n";
			token<<"<MULOP, " << yytext << "> ";*/
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("ID");
			yylval.symbol = (YYSTYPE)si;
			return MULOP;
}

"++" 	{
			/*logFile<<"Line no "<< lineCount << ": Token <INCOP> Lexeme "<< yytext << " found\n\n";
			token<<"<INCOP, " << yytext << "> ";*/
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("INCOP");
			yylval.symbol = (YYSTYPE) si;
			return INCOP;

}

"--" 	{
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("DECOP");
			yylval.symbol = (YYSTYPE) si;
			return DECOP;	
}

"<"|"<="|">"|">="|"=="|"!=" {
			/*logFile<<"Line no "<< lineCount << ": Token <RELOP> Lexeme "<< yytext << " found\n\n";
			token<<"<RELOP, " << yytext << "> ";*/
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("ID");
			yylval.symbol = (YYSTYPE) si;
			return RELOP;	

}

"="			{
			/*logFile<<"Line no "<< lineCount << ": Token <ASSIGNOP> Lexeme "<< yytext << " found\n\n";
			token<<"<ASSIGNOP, " << yytext << "> ";*/
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("ASSIGNOP");
			yylval.symbol = (YYSTYPE)si;
			return ASSIGNOP;	
}

"&&"|"||"   {
			/*logFile<<"Line no "<< lineCount << ": Token <LOGICOP> Lexeme "<< yytext << " found\n\n";
			token<<"<LOGICOP, " << yytext << "> ";*/
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("ID");
			yylval.symbol = (YYSTYPE)si;
			return LOGICOP;	
}

"!"			{
			/*logFile<<"Line no "<< lineCount << ": Token <NOT> Lexeme "<< yytext << " found\n\n";
			token<<"<NOT, " << yytext << "> ";*/
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("NOT");
			yylval.symbol = (YYSTYPE) si;
			return NOT;	
}

"("			{
			/*logFile<<"Line no "<< lineCount << ": Token <LPAREN> Lexeme "<< yytext << " found\n\n";
			token<<"<LPAREN, " << yytext << "> ";*/
			return LPAREN;
}

")"			{
			/*logFile<<"Line no "<< lineCount << ": Token <RPAREN> Lexeme "<< yytext << " found\n\n";
			token<<"<RPAREN, " << yytext << "> ";*/
			return RPAREN;
}

"{"			{
			/*logFile<<"Line no "<< lineCount << ": Token <LCURL> Lexeme "<< yytext << " found\n\n";
			token<<"<LCURL, " << yytext << "> ";
			symboltable.enterScope();*/
			return LCURL;
}

"}"			{
			/*logFile<<"Line no "<< lineCount << ": Token <RCURL> Lexeme "<< yytext << " found\n\n";
			token<<"<RCURL, " << yytext << "> ";
			symboltable.exitScope();*/
			return RCURL;
}

"["			{
			/*logFile<<"Line no "<< lineCount << ": Token <LTHIRD> Lexeme "<< yytext << " found\n\n";
			token<<"<LTHIRD, " << yytext << "> ";*/
			return LTHIRD;
}

"]"			{
			/*logFile<<"Line no "<< lineCount << ": Token <RTHIRD> Lexeme "<< yytext << " found\n\n";
			token<<"<RTHIRD, " << yytext << "> ";*/
			return RTHIRD;
}

","			{
			/*logFile<<"Line no "<< lineCount << ": Token <COMMA> Lexeme "<< yytext << " found\n\n";
			token<<"<COMMA, " << yytext << "> ";*/
			return COMMA;
}

";"			{
			/*logFile<<"Line no "<< lineCount << ": Token <SEMICOLON> Lexeme "<< yytext << " found\n\n";
			token<<"<SEMICOLON, " << yytext << "> ";*/
			return SEMICOLON;
}

{SPECIAL_CHAR}|{CHAR}  {
			/*string str = yytext;
			string str2 = "";
			bool flag = false;
			 if(str[1] == '\\'){
			 if(str[2] == 'n'){
			 	str2 = "\\n";
				str = "\n";
			 }
			 else if(str[2] == 't'){
			 	str2 = "\\t";
				str = "\t";
			 }
			 else if(str[2] == 'f'){
			 	str2 = "\\f";
				str = "\f";
			 }
			 else if(str[2] == 'v'){
			 	str2 = "\\v";
				str = "\v";
			 }
			 else if(str[2] == 'r'){
			 	str2 = "\\r";
				str = "\r";
			 }
			 else if(str[2] == 'a'){
			 	str2 = "\a";
				str = "\a";
			 }
			 else if(str[2] == 'b'){
			 	str2 = "\b";
				str = "\b";
			 }
			 else if(str[2] == '0'){
			 	str2 = "\\0";
				str = "\0";
			 }
			 else if(str[2] == '\\'){
			 	str2 = "\\";
				str = "\\";
			 }
			 else if(str[2] == '\''){
			 	str2 = "\\'";
				str = "\'";
			 }	
			 flag = true;
			 	
	}
	if(flag==false){
		str2 = str;
	}
	
		logFile << "Line no " << lineCount<< ":  TOKEN <CONST_CHAR> Lexeme " << yytext <<" found --> " <<   "<CONST_CHAR, "<< str2 << ">\n\n";
		token << "<CONST_CHAR, "<< str << "> ";
		bool flag2 = symboltable.insertCurrScope(yytext,"CONST_CHAR",logFile);
			if(flag2){
				symboltable.printAllScope(logFile);
			}
			else 
				logFile << yytext << " already exists in current ScopeTable" << endl;*/
	
			//symbolInfo* si = new symbolInfo();
			//si->setName(yytext);
			//si->setType("CONST_CHAR");
			//yylval.symbol = si;
			return CONST_CHAR;	

	
}

[a-zA-Z_][a-zA-Z0-9_]* {
			/*logFile <<  "Line no " << lineCount << ":  Token <ID> Lexeme " << yytext <<" found\n\n";
			token << " <ID, " << yytext << "> ";
			bool flag = symboltable.insertCurrScope(yytext,"ID",logFile);
			if(flag){
				symboltable.printAllScope(logFile);
			}
			else 
				logFile << yytext << " already exists in current ScopeTable" << endl;*/
			
			symbolInfo* si = new symbolInfo();
			si->setName(yytext);
			si->setType("ID");
			yylval.symbol = (YYSTYPE)si;
			return ID;
			
}


([a-zA-Z_]+[0-9]+)|([0-9]+[a-zA-Z_]+) {
		logFile << "Error at line no "  << lineCount << ": " << "Invalid prefix on ID or invalid suffix on Number " <<  yytext << "\n\n";
		errorFile << "Error at line no "  << lineCount << ": " << "Invalid prefix on ID or invalid suffix on Number " <<  yytext << "\n\n";
		errorCount++;
} 

'({MULTICHAR}{MULTICHAR}+)' {
		logFile << "Error at line no "  << lineCount << ": " << "Multi Character Constant Error " <<  yytext << "\n\n";
		errorFile << "Error at line no "  << lineCount << ": " << "Multi Character Constant Error " <<  yytext << "\n\n";
		errorCount++;
}

'' {
		logFile << "Error at line no "  << lineCount << ": " << "Empty Character Constant Error " <<  yytext << "\n\n";
		errorFile << "Error at line no "  << lineCount << ": " << "Empty Character Constant Error " <<  yytext << "\n\n";
		errorCount++;
}



. {
		logFile << "Error at line no "  << lineCount << ": " << "Unrecognized Character " <<  yytext << "\n\n";
		errorFile << "Error at line no "  << lineCount << ": " << "Unrecognized Character " <<  yytext << "\n\n";
		errorCount++;
}

'{MULTICHAR}*|'{SPECIAL_CHAR_STR}*  {
		logFile << "Error at line no "  << lineCount << ": " << "Unterminated Character " <<  yytext << "\n\n";
		errorFile << "Error at line no "  << lineCount << ": " << "Unterminated Character " <<  yytext << "\n\n";
		errorCount++;
}

	
%%


/*int main(int argc,char *argv[]){
	
	if(argc!=2){
		cout << "Please provide input file name and try again\n";
		return 0;
	}
	
	FILE *file=fopen(argv[1],"r");
	if(file==NULL){
		cout << "Cannot open specified file\n";
		return 0;
	}
	
	
	token.open("1805116_token.txt");
	logFile.open("1805116_log.txt");
	logFile << endl;
	
	yyin= file;
	yylex();
	fclose(yyin);

	
	symboltable.printAllScope(logFile);
	logFile << " Lines: " << lineCount << endl;
	logFile << " Errors: " << errorCount << endl;

	logFile.close();
	token.close();
	return 0;
}*/