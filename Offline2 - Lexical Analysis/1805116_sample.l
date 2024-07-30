%option noyywrap yylineno

%x STR_STATE
%x STR_ERROR_STATE
%x MULTILINE_COMMENT_STATE
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE

%{
#include<iostream>
#include<fstream>
#include"1805116_symbolTable.cpp"
using namespace std;


symbolTable symboltable(7);

int lineCount=1;
int storeLineCount;
int string_line = 0;
int errorCount=0;


string str1 = "";
string str3 = "";
string str4 = "";

ofstream token;
ofstream logFile;

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
		logFile << "Line no " << lineCount<< ":  Token <IF> Lexeme " << yytext <<" found\n\n";
		token << " <IF> ";
}   

"for"		{
		logFile << "Line no " << lineCount << ":  Token <IF> Lexeme " << yytext <<" found\n\n";
		token << " <FOR> ";
}

"do"		{
		logFile << "Line no " << lineCount << ":  Token <DO> Lexeme " << yytext <<" found\n\n";
		token << " <DO> ";
}

"int"		{
		logFile << "Line no " << lineCount << ":  Token <INT> Lexeme " << yytext <<" found\n\n";
		token << " <INT> ";
}

"float"		{
		logFile << "Line no " << lineCount << ":  Token <FLOAT> Lexeme " << yytext <<" found\n\n";
		token << " <FLOAT> ";
}

"void"		{
		logFile << "Line no " << lineCount << ":  Token <VOID> Lexeme " << yytext <<" found\n\n";
		token << " <VOID> ";
}

"switch"		{
		logFile <<  "Line no " << lineCount << ":  Token <SWITCH> Lexeme " << yytext <<" found\n\n";
		token << " <SWITCH> ";
}

"default"		{
		logFile <<"Line no " << lineCount << ":  Token <DEFAULT> Lexeme " << yytext <<" found\n\n";
		token << " <DEFAULT> ";
}

"else"		{
		logFile <<  "Line no " << lineCount << ":  Token <DO> Lexeme " << yytext <<" found\n\n";
		token << " <DO> ";
}

"while"		{
		logFile <<"Line no " << lineCount << ":  Token <WHILE> Lexeme " << yytext <<" found\n\n";
		token << " <WHILE> ";
}

"break"		{
		logFile <<"Line no " << lineCount << ":  Token <BREAK> Lexeme " << yytext <<" found\n\n";
		token << " <BREAK> ";
}

"char"		{
		logFile << "Line no " << lineCount << ":  Token <CHAR> Lexeme " << yytext <<" found\n\n";
		token << " <CHAR> ";
}

"double"		{
		logFile <<  "Line no " << lineCount << ":  Token <DOUBLE> Lexeme " << yytext <<" found\n\n";
		token << " <DOUBLE> ";
}

"return"		{
		logFile << "Line no " << lineCount << ":  Token <RETURN> Lexeme " << yytext <<" found\n\n";
		token << " <RETURN> ";
}

"case"		{
		logFile << "Line no " << lineCount << ":  Token <CASE> Lexeme " << yytext <<" found\n\n";
		token << " <CASE> ";
}

"continue"		{
		logFile << "Line no " << lineCount << ":  Token <CONTINUE> Lexeme " << yytext <<" found\n\n";
		token << " <CONTINUE> ";
}


[0-9]+		{
			logFile <<  "Line no " << lineCount<< ":  Token <CONST_INT> Lexeme " << yytext <<" found\n\n";
			token << " <CONST_INT, " << yytext << "> ";
			bool flag = symboltable.insertCurrScope(yytext,"CONST_INT",logFile);
			if(flag){
				symboltable.printAllScope(logFile);
			}
			else 
				logFile << yytext << " already exists in current ScopeTable" << endl;

			
}

[0-9]*(\.[0-9]+)?([Ee][+-]?[0-9]+)? {
			logFile <<  "Line no " << lineCount<< ":  Token <CONST_FLOAT> Lexeme " << yytext <<" found\n\n";
			token << " <CONST_FLOAT, " << yytext << "> ";
			bool flag = symboltable.insertCurrScope(yytext,"CONST_FLOAT", logFile);
			if(flag){
				symboltable.printAllScope(logFile);
			}
			else 
				logFile << yytext << " already exists in current ScopeTable" << endl;
}

"+"|"-" 	{
			logFile<<"Line no "<< lineCount << ": Token <ADDOP> Lexeme "<< yytext << " found\n\n";
			token << " <ADDOP, " << yytext <<"> ";
}

"*"|"/"|"%" {
			logFile<<"Line no "<< lineCount << ": Token <MULOP> Lexeme "<< yytext << " found\n\n";
			token<<"<MULOP, " << yytext << "> ";
}

"++"|"--" 	{
			logFile<<"Line no "<< lineCount << ": Token <INCOP> Lexeme "<< yytext << " found\n\n";
			token<<"<INCOP, " << yytext << "> ";
}

"<"|"<="|">"|">="|"=="|"!=" {
			logFile<<"Line no "<< lineCount << ": Token <RELOP> Lexeme "<< yytext << " found\n\n";
			token<<"<RELOP, " << yytext << "> ";
}

"="			{
			logFile<<"Line no "<< lineCount << ": Token <ASSIGNOP> Lexeme "<< yytext << " found\n\n";
			token<<"<ASSIGNOP, " << yytext << "> ";
}

"&&"|"||"   {
			logFile<<"Line no "<< lineCount << ": Token <LOGICOP> Lexeme "<< yytext << " found\n\n";
			token<<"<LOGICOP, " << yytext << "> ";
}

"!"			{
			logFile<<"Line no "<< lineCount << ": Token <NOT> Lexeme "<< yytext << " found\n\n";
			token<<"<NOT, " << yytext << "> ";
}

"("			{
			logFile<<"Line no "<< lineCount << ": Token <LPAREN> Lexeme "<< yytext << " found\n\n";
			token<<"<LPAREN, " << yytext << "> ";
}

")"			{
			logFile<<"Line no "<< lineCount << ": Token <RPAREN> Lexeme "<< yytext << " found\n\n";
			token<<"<RPAREN, " << yytext << "> ";
}

"{"			{
			logFile<<"Line no "<< lineCount << ": Token <LCURL> Lexeme "<< yytext << " found\n\n";
			token<<"<LCURL, " << yytext << "> ";
			symboltable.enterScope();
}

"}"			{
			logFile<<"Line no "<< lineCount << ": Token <RCURL> Lexeme "<< yytext << " found\n\n";
			token<<"<RCURL, " << yytext << "> ";
			symboltable.exitScope();
}

"["			{
			logFile<<"Line no "<< lineCount << ": Token <LTHIRD> Lexeme "<< yytext << " found\n\n";
			token<<"<LTHIRD, " << yytext << "> ";
}

"]"			{
			logFile<<"Line no "<< lineCount << ": Token <RTHIRD> Lexeme "<< yytext << " found\n\n";
			token<<"<RTHIRD, " << yytext << "> ";
}

","			{
			logFile<<"Line no "<< lineCount << ": Token <COMMA> Lexeme "<< yytext << " found\n\n";
			token<<"<COMMA, " << yytext << "> ";
}

";"			{
			logFile<<"Line no "<< lineCount << ": Token <SEMICOLON> Lexeme "<< yytext << " found\n\n";
			token<<"<SEMICOLON, " << yytext << "> ";
}

{SPECIAL_CHAR}|{CHAR}  {
			string str = yytext;
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
				logFile << yytext << " already exists in current ScopeTable" << endl;
}

[a-zA-Z_][a-zA-Z0-9_]* {
			logFile <<  "Line no " << lineCount << ":  Token <ID> Lexeme " << yytext <<" found\n\n";
			token << " <ID, " << yytext << "> ";
			bool flag = symboltable.insertCurrScope(yytext,"ID",logFile);
			if(flag){
				symboltable.printAllScope(logFile);
			}
			else 
				logFile << yytext << " already exists in current ScopeTable" << endl;
}

\"		{
		BEGIN STR_STATE;
		storeLineCount = lineCount;
		//string_line++;
		str1.append(yytext);
		str3.append(yytext);
		str4.append(yytext);

}

<STR_STATE>\"	{
		str1.append(yytext);
		str3.append(yytext);
		str4.append(yytext);
		logFile << "Line no " << storeLineCount << ":  TOKEN <STRING> Lexeme " << str4 <<" found --> " <<   "<STRING, "<< str3 << ">\n\n";
		token << "<STRING, "<< str1 << "> ";
		str3 = "";
		str1 = "";
		str4 = "";
		BEGIN INITIAL;

}

<STR_STATE>{SPECIAL_CHAR_STR} {
		str4.append(yytext);
		string str = yytext;
		string str2 = "";
		if(str[1] == 'n'){
			str2 = "\n";
		}
		else if(str[1] == 't'){
			str2 = "\t";
		}
		else if(str[1] == 'f'){
			str2 = "\f";
		}
		else if(str[1] == 'v'){
			str2 = "\v";
		}
		else if(str[1] == 'r'){
			str2 = "\r";
		}
		else if(str[1] == 'a'){
			str2 = "\a";
		}
		else if(str[1] == 'b'){
			str2 = "\b";
		}
		else if(str[1] == '0'){
			str2 = "\0";
		}
		else if(str[1] == '\\'){
			str2 = "\\";
		}
		else if(str[1] == '\''){
			str2 = "\'";
		}	

		str1.append(str2);
		str3.append(str2);
		

}

<STR_STATE>((\\)?{WHITESPACE}?\n) {
		string str = yytext;
		if(str[0]!='\\'){
			logFile << "Error at line no  " << storeLineCount << ": " << "Unterminated String " << str3 << "\n\n";
			//lineCount++;
			errorCount++;
			str1 = "";
			str3 = "";
			str4 = "";
			BEGIN STR_ERROR_STATE;
		}

		lineCount++;
		str3.append(yytext);

}

<STR_STATE>. {
		str1.append(yytext);
		str3.append(yytext);
		str4.append(yytext);
}

<STR_STATE><<EOF>> {
		logFile << "Error at line no  " << storeLineCount << ": " << "Unterminated String " << str3 << "\n\n";
		errorCount++;
		str1 = "";
		str3 = "";
		str4 = "";
		BEGIN INITIAL;
}

<STR_ERROR_STATE>\" {
		BEGIN INITIAL;
}

<STR_ERROR_STATE>\\n {
		lineCount++;
}

\/\/ 	{
		
		storeLineCount = lineCount;
		str3.append(yytext);
		BEGIN SINGLE_COMMENT_STATE;

}

<SINGLE_COMMENT_STATE>\n {
		
		str3.append(yytext);
		logFile << "Line no " << lineCount << ":  TOKEN <SINGLE_COMMENT> Lexeme " << yytext <<" found --> " <<   "<SINGLE_COMMENT, "<< str3 << ">\n\n";
		str3 = "";
		BEGIN INITIAL;
}


<SINGLE_COMMENT_STATE>((\\){WHITESPACE}?\n) {
	
		lineCount++;
		str3.append(yytext);

}

<SINGLE_COMMENT_STATE>. {
		str3.append(yytext);
}

<SINGLE_COMMENT_STATE><<EOF>> {
		logFile << "Error at line no  " << storeLineCount << ": " << "Unterminated String " << str3 << "\n\n";
		errorCount++;
		str3 = "";
		BEGIN INITIAL;
}

\/\*	{
		BEGIN MULTI_COMMENT_STATE;
		storeLineCount = lineCount;
		str3.append(yytext);
}

<MULTI_COMMENT_STATE>({WHITESPACE}?\n) {
	
		lineCount++;
		str3.append(yytext);

}

<MULTI_COMMENT_STATE>\*\/ {
		
		str3.append(yytext);
		logFile << "Line no " << lineCount << ":  TOKEN <MULTI_COMMENT> Lexeme " << yytext <<" found --> " <<   "<MULTI_COMMENT, "<< str3 << ">\n\n";
		str3 = "";
		lineCount++;
		BEGIN INITIAL;
}

<MULTI_COMMENT_STATE>. {
		str3.append(yytext);
}

<MULTI_COMMENT_STATE><<EOF>> {
		logFile << "Error at line no  " << storeLineCount << ": " << "Unterminated String " << str3 << "\n\n";
		errorCount++;
		str3 = "";
		BEGIN INITIAL;
}

[+-]?([0-9]*\.([0-9]+)?\.[0-9]*)+(\.[0-9]*)* {
		logFile << "Error at line no  " << lineCount << ": " << "Too Many Decimal Points " <<  yytext << "\n\n";
		errorCount++;
}

([0-9]*([Ee][+-]?[0-9]*)+(([0-9]+)?\.[0-9]+)+) {
		logFile << "Error at line no "  << lineCount << ": " << "Ill Formed Number " <<  yytext << "\n\n";
		errorCount++;
}

([a-zA-Z_]+[0-9]+)|([0-9]+[a-zA-Z_]+) {
		logFile << "Error at line no "  << lineCount << ": " << "Invalid prefix on ID or invalid suffix on Number " <<  yytext << "\n\n";
		errorCount++;
} 

'({MULTICHAR}{MULTICHAR}+)' {
		logFile << "Error at line no "  << lineCount << ": " << "Multi Character Constant Error " <<  yytext << "\n\n";
		errorCount++;
}

'' {
		logFile << "Error at line no "  << lineCount << ": " << "Empty Character Constant Error " <<  yytext << "\n\n";
		errorCount++;
}



. {
		logFile << "Error at line no "  << lineCount << ": " << "Unrecognized Character " <<  yytext << "\n\n";
		errorCount++;
}

'{MULTICHAR}*|'{SPECIAL_CHAR_STR}*  {
		logFile << "Error at line no "  << lineCount << ": " << "Unterminated Character " <<  yytext << "\n\n";
		errorCount++;
}

	
%%


int main(int argc,char *argv[]){
	
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
}