%{
#include <string>
#include <iostream>
//#include <fstream>
#include<bits/stdc++.h>
#include"1805116_symbol.cpp"

using namespace std;

int yylex(void);
int yyparse(void);


extern FILE *yyin;
//extern ofstream yyin;
ofstream errorFile;
ofstream logFile;
ofstream codeFile;
FILE* inputFile;
symbolTable symboltable(7);


int lineCount=1;
int errorCount=0;
int lineTrack = 0;
int isWrongFunction = 0;
string returnType = "UNKNOWN";
int voidVal = 0;
int voidLine=0;

int labelCount = 0;                     
int tempCount = 0; 
int stackOffset=0;

//string current_func_ret_type   = ERROR;
string parameterCode = "";

vector<global_list*> global_var_list;


void yyerror(const char *str){
    errorFile << "Error at line " << lineCount << ": Syntax Error\n";
	logFile << "Error at line " << lineCount << ": Syntax Error\n";
	errorCount++;
}

vector<string> parseString(string str, char delim) {

	vector<string> vectorString;
    string elements;
    stringstream ss(str);

    while(getline(ss, elements, delim)) {
        vectorString.push_back(elements);
    }
    return vectorString;
}

string tempVar() {
   // cout<< "hello" << endl;
        string temp = "t" + to_string(tempCount++);
        global_list* symbol = new global_list({temp,0});
       
		global_var_list.push_back(symbol);
        return temp;
    }

string getGlobalName(string name, symbolTable st) {
    return name + "_" + to_string(st.getCurrentScope());
}

string new_label() {
	return "L" + to_string(labelCount++);
}

void initializeAssemblyFile() {
    //ofstream codeFile;
    codeFile.open("code.asm");


    codeFile << ".MODEL SMALL\n";
    codeFile << ".STACK 400H\n";
    codeFile << ".DATA\n";
    codeFile << "print_var DW ?\n";
    //asmLineCount += 3;
    //asmDSEnding = asmLineCount;

    for(auto variableSymbol : global_var_list){
        if(variableSymbol->getVarSize()==0)
            codeFile << variableSymbol->getVarName() << " DW ?" <<"\n";
        else
            codeFile << variableSymbol->getVarName() << " DW " + variableSymbol->getVarSize() << " DUP(?)\n";

    }
    codeFile << ".CODE\n";
   
    
}

void dataSegment(string str)
{
 
    codeFile << str << "\n";
  
}
void terminateAssemblyCode() {
   

    codeFile.close();
}

void procPrintln() {
     string code = "";

    code += "PRINTLN PROC NEAR\n";
    code += "\tPUSH AX\n";
    code += "\tPUSH BX\n";
    code += "\tPUSH CX\n";
    code += "\tPUSH DX\n";
    code += "\t\n";

    code += "\tMOV AX, print_var\n";
    code += "\tOR AX, AX\n";
    code += "\tJGE @END_IF1\n";
    code += "\tPUSH AX\n";
    code += "\tMOV DL, '-'\n";
    code += "\tMOV AH, 2\n";
    code += "\tINT 21H\n";
    code += "\tPOP AX\n";
    code += "\tNEG AX\n";
    code += "\n";

    code += "@END_IF1:\n";
    code += "\tXOR CX, CX\n";
    code += "\tMOV BX, 10D\n";
    code += "\n";

    code += "@REPEAT:\n";
    code += "\tXOR DX, DX\n";
    code += "\tDIV BX\n";
    code += "\tPUSH DX\n";
    code += "\tINC CX\n";
    code += "\tOR AX, AX\n";
    code += "\tJNE @REPEAT\n";
    code += "\tMOV AH, 2\n";
    code += "\n";

    code += "@PRINT_LOOP:\n";
    code += "\tPOP DX\n";
    code += "\tOR DL, 30H\n";
    code += "\tINT 21H\n";
    code += "\tLOOP @PRINT_LOOP\n";

    code += "\tMOV DL, 0DH\n";
    code += "\tMOV AH, 2\n";
    code += "\tINT 21H\n";

    code += "\tMOV DL, 0AH\n";
    code += "\tMOV AH, 2\n";
    code += "\tINT 21H\n";

    code += "\tPOP DX\n";
    code += "\tPOP CX\n";
    code += "\tPOP BX\n";
    code += "\tPOP AX\n";

    code += "\tRET\n";
    code += "\n";
    code += "PRINTLN ENDP\n";

    
	//codeFile.open("code.asm");
    codeFile << code << "\n";
    //codeFile.close();
}



%}

%union{
	
	symbolInfo *symbol;
}



         
%token IF FOR  DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE  BREAK CHAR DOUBLE RETURN CASE CONTINUE PRINTLN
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON


%token <symbol> INCOP DECOP ASSIGNOP NOT ADDOP MULOP RELOP LOGICOP

%token <symbol> ID CONST_INT CONST_FLOAT CONST_CHAR

%type <symbol> start program unit func_declaration func_definition parameter_list 
%type <symbol> compound_statement var_declaration type_specifier declaration_list
%type <symbol> statements statement expression_statement variable expression
%type <symbol> logic_expression rel_expression simple_expression term  
%type <symbol> unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
			{

                string total_code = $1->getCode();

			if (errorCount == 0)
			{	
				

				initializeAssemblyFile();
				procPrintln();
				dataSegment(total_code);
                terminateAssemblyCode();
				//fclose(codeFile);
 
				
			}

				$$ = $1;
				logFile << "Line " << lineCount << ": start : program\n\n";
			}
	;
program : program unit
			{
              
				string str = $1->getName() + "\n" + $2->getName();
                
				symbolInfo* si = new symbolInfo();
				si->setName(str);
				si->setType("program");
				$$ = si;
				$$->setCode($1->getCode() + $2->getCode());
				logFile << "Line " << lineCount <<  ": program : program unit\n\n";
				logFile << $$->getName() << "\n\n";
			}
			|   unit
			{
				$$ = $1;
				logFile << "Line " << lineCount <<  ": program : program unit\n\n";
				logFile << $$->getName() << "\n\n"; 

			}
		;
unit :	var_declaration
			{
				$$ = $1;
				logFile << "Line " << lineCount <<  " unit : var_declaration\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| func_declaration
			{
				$$ = $1;
				logFile << "Line " << lineCount <<   " unit : func_declaration\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| func_definition
			{
				$$ = $1;
				logFile << "Line " << lineCount <<  " unit : func_definition\n\n";
				logFile << $$->getName() << "\n\n";
			}
		;


func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
				{
					string functionName = $2->getName();
					string functionType = $1->getName();
					string parameters = $4->getName();

					symbolInfo* existFunction = symboltable.lookUpScope(functionName, logFile);

					//if function is already declared -> error
					if (existFunction != nullptr)	
					{	
						//if(lineTrack!=lineCount){
							logFile << "Error at line " << lineCount << " : Multiple declaration of function '" << functionName << "'\n\n";
							errorFile << "Error at line " + lineCount << " : Multiple declaration of function '" << functionName << "'\n\n";
							errorCount++;
							lineTrack=lineCount;
						//}
					}

					//if function is not declared yet, declare the function
					else	
					{
						vector<string> parametersList = parseString(parameters, ',');
						vector<string> parametersType , parametersId;
					
						//parameters types with ids are individuals now
						for(int i=0; i<parametersList.size(); i++){
							vector<string> str = parseString(parametersList.at(i), ' ');
							parametersType.push_back(str[0]);
							parametersId.push_back(str[1]);// doesn't matter anyway
							
						}

						vector<paramList> parameterList;
						for (int j=0;j<parametersType.size(); j++) {
							string type = parametersType.at(j);
							string name = "";
							paramList* p = new paramList(name, type);	//ekhane name faka coz declaration e ki disi id ta matter korena
							parameterList.push_back(*p);
						}

						symbolInfo funcSymbol;
						funcSymbol.funcSymbol(functionName, functionType, parameterList);
						funcSymbol.setDefinition(0);
						
						symboltable.insertCurrSymbolInfo(funcSymbol, logFile);
					}

					string decName = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ");";
					string decType = "func_declaration";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n";
					logFile << $$->getName() << "\n\n";
					
				}
				| type_specifier ID LPAREN RPAREN SEMICOLON
				{
					string functionName = $2->getName();
					string functionType = $1->getName();

					symbolInfo* existFunction = symboltable.lookUpScope(functionName, logFile);

					//if function is already declared -> error
					if (existFunction != nullptr)	
					{
						//if(lineTrack!=lineCount){
							logFile << "Error at line " << lineCount << " : Multiple declaration of function '" << functionName << "'\n\n";
							errorFile << "Error at line " << lineCount << " : Multiple declaration of function '" << functionName << "'\n\n";
							errorCount++;
							lineTrack=lineCount;
						//}
					}

					//if function is not declared yet, declare the function
					else		
					{
						vector<paramList> parameterList;

						symbolInfo functionSymbol;
						functionSymbol.funcSymbol(functionName, functionType, parameterList);
						functionSymbol.setDefinition(0);//function is not defined
						
						symboltable.insertCurrSymbolInfo(functionSymbol, logFile);
						logFile << "declared function entered in symble table\n\n";
					}

					string decName = $1->getName() + " " + $2->getName() + "();";
					string decType = "func_declaration";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n";
					logFile << $$->getName() << "\n\n";
				}
            ;

func_definition : type_specifier ID LPAREN parameter_list RPAREN 
				{
					isWrongFunction = 0;
					string functionName = $2->getName();
					string functionType = $1->getName();
					string parameters = $4->getName();

					symbolInfo* existFunction = symboltable.lookUpScope(functionName, logFile);
					returnType = functionType;

					//if Function name is already found, check it is defined or not
					if (existFunction != nullptr) 
					{
						//if the symbol is found, check if it's a function
						if (existFunction->getExtraType()==-1)
						{
							if(existFunction->getType()==functionType)
							{
								//check if function is already defined--> error
								if (existFunction->getFunctionDefinition()==1) 
								{
									//if(lineTrack!=lineCount){
										
									logFile << "Error at line " << lineCount << " : Re-definition of function '" << functionName << "'\n\n";
									errorFile << "Error at line " << lineCount << " : Re-definition of function '" << functionName << "'\n\n";
									errorCount++;
									lineTrack=lineCount;
									isWrongFunction = 1;
									//}
								}
								//if function is not defined -> now the rule should be applied, we will define the function
								else	
								{

									//cout << "era" << endl;
									vector<string> parametersList = parseString(parameters, ',');
									vector<paramList> foundParamList;
								
									//parameters types with ids are individuals now
									for(int i=0; i<parametersList.size(); i++){
										vector<string> str = parseString(parametersList.at(i), ' ');
										string name = str[1];
										string type = str[0];
										paramList* p = new paramList(name, type);
										foundParamList.push_back(*p);
								
									}

									

									int flag = 0;
									string givenFuncType = existFunction->getType();
									int givenParamSize = existFunction->getParamList().size();
									
									vector<paramList> givenParamList = existFunction->getParamList();

									
									
									int  foundParamSize = foundParamList.size();
									

									//error check in declared & defined function

									//case-1 : return type mismatched!
									if (givenFuncType != functionType)		
									{
										flag=1;
										//if(lineTrack!=lineCount){
											logFile << "Error at line " << lineCount << " : Function return type doesn't match with declaration\n\n";
											errorFile << "Error at line " << lineCount << " : Function return type doesn't match with declaration\n\n";
											errorCount++;
											lineTrack=lineCount;
											isWrongFunction = 1;
										//}
									}


									//case-2: paramList size mismatch!
									if (givenParamSize != foundParamSize)	
									{
										flag=1;
										//if(lineTrack!=lineCount)
										//{
											logFile << "Error at line " << lineCount << " : Total number of arguments mismatch with declaration in function '" << functionName << "'\n\n";
											errorFile << "Error at line " << lineCount << " : Total number of arguments mismatch with declaration in function '" << functionName << "'\n\n";
											errorCount++;
											lineTrack=lineCount;
											isWrongFunction =1;
										//}
									}

									//case-3: function parameter type mismatched! 
									if (givenParamSize == foundParamSize)
									{
										for (int j=0; j < givenParamSize; j++)
										{
											string givenParameterType = givenParamList.at(j).getParamType();
											string foundParameterType = foundParamList.at(j).getParamType();

											if (givenFuncType != foundParameterType)	
											{
												flag=1;
												//if(lineTrack!=lineCount){
													logFile << "Error at line " << lineCount << " : Type mismatch of function parameter '" << foundParamList.at(j).getParamName() <<"' \n\n";
													errorFile << "Error at line " << lineCount << " : Type mismatch of function parameter '" << foundParamList.at(j).getParamName() << "' \n\n";
													errorCount++;
													lineTrack=lineCount;
													isWrongFunction =1;
												//}
											}
											
										}
									}
									//ei porjonto done
									//cout << "era" << endl;

									if(flag==0){
										//cout << "era" << endl;
										symbolInfo* si = symboltable.lookUpScope(functionName, logFile);
										si->funcSymbol(functionName, functionType, foundParamList);
										si->setDefinition(1);

										symboltable.removeCurrScope(functionName, logFile);
										symboltable.insertCurrSymbolInfo(si, logFile);
									

										symboltable.enterScope();


										//bool  = false;
										for (int i=0; i <foundParamList.size(); i++)
										{
											cout << "era1" << "\n";
											
											

											bool isExist = symboltable.insertCurrScope(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType(), logFile);
											symbolInfo* symbol = symboltable.lookUpScope(foundParamList.at(i).getParamName(), logFile);
											string global_name = getGlobalName(foundParamList.at(i).getParamName(), symboltable);
											symbol->setCodeName(global_name);
											symbolInfo s1 = new symbolInfo(symbol);
											//bool isExist = symboltable.insertCurrSymbolInfo(s1, logFile);

											
                                            global_list* symbol2 = new global_list(global_name, symbol->getArrSize());
                                            
											global_var_list.push_back(symbol2);
											cout << "here" << endl;

											if (!isExist)
											{
												logFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() <<"' in parameter\n\n";
												errorFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() << "' in parameter\n\n";
												errorCount++;
												lineTrack=lineCount;
											}
										}
									}
									else{
										symboltable.enterScope();
									}

								}
							}
							else{
								symboltable.enterScope();
								logFile << "Error at line " << lineCount << " : Return type mismatch with function declaration in function '" << functionName << "'\n\n";
								errorFile << "Error at line " << lineCount << " : Return type mismatch with function declaration in function '" << functionName << "'\n\n";
								errorCount++;
								lineTrack=lineCount;
								isWrongFunction = 1;
							}
						}
						else
						{
							//cout << "era" << endl;
							
							errorFile << "Error at line " << lineCount << " : Multiple declaration of  '" << functionName << "'\n\n";
							logFile << "Error at line " << lineCount << " : Multiple declaration of  '" << functionName << "'\n\n";
							errorCount++;
							lineTrack=lineCount;
							isWrongFunction=1;
							symboltable.enterScope();
							string param_retrieve_code = "";
								vector<string> parametersList = parseString(parameters, ',');
									vector<paramList> foundParamList;
								
									//parameters types with ids are individuals now
									for(int i=0; i<parametersList.size(); i++){
										vector<string> str = parseString(parametersList.at(i), ' ');
										string name = str[1];
										string type = str[0];
										paramList* p = new paramList(name, type);
										foundParamList.push_back(*p);
								
									}

									int  foundParamSize = foundParamList.size();
									for (int i=0; i <foundParamList.size(); i++)
										{
											cout << "era2" << "\n";
											//bool isExist = symboltable.insertCurrScope(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType(), logFile);
											bool isExist = symboltable.insertCurrScope(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType(), logFile);
											//symbolInfo* symbol = symboltable.lookUpScope(foundParamList.at(i).getParamName(), logFile);
											//symbolInfo* symbol = new symbolInfo(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType());
											string global_name = getGlobalName(foundParamList.at(i).getParamName(), symboltable);
											symbolInfo* symbol = symboltable.lookUpScope(foundParamList.at(i).getParamName(), logFile);
											symbol->setCodeName(global_name);
											symbolInfo s1 = new symbolInfo(symbol);
											
                                             global_list* symbol2 = new global_list(global_name, symbol->getArrSize());
											global_var_list.push_back(symbol2);
                                            cout << "here2" << endl;
											param_retrieve_code += "\tPOP " + global_name + "\n";

											if (!isExist)
											{
												logFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() <<"' in parameter\n\n";
												errorFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() << "' in parameter\n\n";
												errorCount++;
												lineTrack=lineCount;
											}
										}
										parameterCode = param_retrieve_code;
							
						}						
					}
					// The Function isn't even declared.
					else	
					{
						
						vector<string> parametersList = parseString(parameters, ',');
							vector<paramList> foundParamList;
						
							//parameters types with ids are individuals now
							for(int i=0; i<parametersList.size(); i++){
								vector<string> str = parseString(parametersList.at(i), ' ');
								string name = str[1];
								string type = str[0];
								paramList* p = new paramList(name, type);
								foundParamList.push_back(*p);
							
							}
						
						symbolInfo si;
						si.funcSymbol(functionName, functionType, foundParamList);
						si.setDefinition(1);

						symboltable.insertCurrSymbolInfo(si, logFile);
						
						
						symboltable.enterScope();
						string param_retrieve_code = "";


						for (int i=0; i < foundParamList.size(); i++)
						{
							//logFile << "int a, int b ekhane jabe \n\n";
							//cout << "era" << endl;
							cout << "era3" << "\n";
							bool isExist = symboltable.insertCurrScope(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType(), logFile);
											
											string global_name = getGlobalName(foundParamList.at(i).getParamName(), symboltable);
											symbolInfo* symbol = symboltable.lookUpScope(foundParamList.at(i).getParamName(), logFile);
											symbol->setCodeName(global_name);
											
											symbolInfo s1 = new symbolInfo(symbol);
											//bool isExist = symboltable.insertCurrSymbolInfo(s1, logFile);

                                             global_list* symbol2 = new global_list(global_name, symbol->getArrSize());
											global_var_list.push_back(symbol2);
                                            cout << "here3" << endl;
											param_retrieve_code += "\tPOP " + global_name + "\n";

									if (!isExist)
									{
										logFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() << "' in parameter\n\n";
										errorFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() << "' in parameter\n\n";
										errorCount++;
										lineTrack=lineCount;
										isWrongFunction=1;
									}
									
						}
						parameterCode = param_retrieve_code;
						
					}
					if(isWrongFunction==1) $2->setIsWrongFunction(1);
				}
				compound_statement
				{
					
					//here $7 is statements covered by lcurl & rcurl

					// $1 - type $2 - id
					string code = "";
				

					if ($2->getName() == "main") {
						code += "MAIN PROC\n";
						code += "\tMOV AX, @DATA\n";
						code += "\tMOV DS, AX\n";

						code += $7->getCode();

						code += "\tMOV AX, 4CH\n";
						code += "\tINT 21H\n";
						code += "MAIN ENDP\n";
						code += "END MAIN\n\n";
					}
					else {
						code += $2->getName() + " PROC\n";

						code += "\tPOP BP		; storing the return pointer in BP\n";
						code += parameterCode;
						code += "\tPUSH BP		; retrieving the return pointer\n";

						code += $7->getCode();
						code += "\tPUSH BP\n";
						code += "\tRET\n";

						code += $2->getName() + " ENDP\n";
					}
					
					string decName = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")"  + $7->getName() + "\n";
					string decType = "func_definition";

					//if(isWrongFunction==1) $7->setName("{}");

					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n";
					logFile << $$->getName() << "\n\n";	
					$$->setCode(code);
					
				}
				| type_specifier ID LPAREN RPAREN
				{
					string functionName = $2->getName();
					string functionType = $1->getName();
					
					symbolInfo* existFunction = symboltable.lookUpScope(functionName, logFile);
					returnType = functionType;
				
					//if Function name is already found, check it is defined or not
					if (existFunction != nullptr) 
					{
						
						//if the symbol is found, check if it's a function
						if(existFunction->getExtraType()==-1){
							//check if function is already defined--> error
							if (existFunction->getFunctionDefinition()==1) 
							{
								logFile << "Error at line " << lineCount << " : Re-definition of function '" << functionName << "'\n\n";
								errorFile << "Error at line " << lineCount << " : Re-definition of function '" << functionName << "'\n\n";
								errorCount++;
								lineTrack=lineCount;
							}
							//if function is not defined -> now the rule should be applied, we will define the function
							else	
							{
								int flag = 0;
								string givenFuncType = existFunction->getType();
								int givenParamSize = existFunction->getParamList().size();
								//vector<ParamList> givenParamList = existFunction->getParamList();
								
								int  foundParamSize = 0;
								
								//error check in declared & defined function

								//case-1 : return type mismatched!
								if (givenFuncType != functionType)		
									{
										flag=1;
										logFile << "Error at line " << lineCount << " : Function return type doesn't match with declaration\n\n";
										errorFile << "Error at line " << lineCount << " : Function return type doesn't match with declaration\n\n";
										errorCount++;
										lineTrack=lineCount;
									}


								//case-2: paramList size mismatch!
								if (givenParamSize != foundParamSize)	
									{
										flag=1;
										logFile << "Error at line " << lineCount << " : Total number of arguments mismatch with declaration in function '" << functionName << "'\n\n";
										errorFile << "Error at line " << lineCount << " : Total number of arguments mismatch with declaration in function '" << functionName << "'\n\n";
										errorCount++;
										lineTrack=lineCount;
									}

								if(flag==0)
									{
										symbolInfo si;
										vector<paramList> foundParamList;
										si.funcSymbol(functionName, functionType, foundParamList);
										si.setDefinition(1);

										symboltable.removeCurrScope(functionName, logFile);
										symboltable.insertCurrSymbolInfo(si, logFile);
										symboltable.enterScope();
								
									}
								else
									{
										symboltable.enterScope();
									}
							}
						}
						else
						{
							symboltable.enterScope();
							logFile << "Error at line " << lineCount << " : Multiple declaration of z '" << functionName << "'\n\n";
							errorFile << "Error at line " << lineCount << " : Multiple declaration of z '" << functionName << "'\n\n";
							errorCount++;
							lineTrack=lineCount;
						}	
							
					}
					// The Function isn't even declared.
					else	
					{
						//logFile << " here you go " << "\n";
						symbolInfo si;
						vector<paramList> foundParamList;
						si.funcSymbol(functionName, functionType, foundParamList);
						si.setDefinition(1);

						symboltable.insertCurrSymbolInfo(si, logFile);
						symboltable.enterScope();
					}
					
				}
				compound_statement
				{
					//here $6 is statements(void) covered by lcurl & rcurl

					string code = "";
					
					if ($2->getName() == "main") {
						code += "MAIN PROC\n";
						code += "\tMOV AX, @DATA\n";
						code += "\tMOV DS, AX\n";

						code += $6->getCode();

						code += "\tMOV AX, 4CH\n";
						code += "\tINT 21H\n";
						code += "MAIN ENDP\n";
						code += "END MAIN\n\n";
					}
					else {
						code += $2->getName() + " PROC\n";
						
						code += "\tPOP BP		; storing the return pointer in BP\n";
						code += $6->getCode();
						code += "\tPUSH BP		; retrieving the return pointer\n";
						code += "\tRET\n";

						code += $2->getName() + " END\n";
					}

					string decName = $1->getName() + " " + $2->getName() + "()" + $6->getName() + "\n";
					string decType = "func_definition";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n";
					logFile << $$->getName() << "\n\n";	
					$$->setCode(code);
					
				}
 			;

parameter_list  : parameter_list COMMA type_specifier ID
				{
					string decName = $1->getName() + "," + $3->getName() + " " + $4->getName();
					string decType = "parameter_list";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " parameter_list : parameter_list COMMA type_specifier ID\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| parameter_list COMMA type_specifier
				{
					string decName = $1->getName() + "," + $3->getName();
					string decType = "parameter_list";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " parameter_list : parameter_list COMMA type_specifier\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| type_specifier ID
				{
					string decName = $1->getName() + " " + $2->getName();
					string decType = "parameter_list";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " parameter_list : type_specifier ID\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| type_specifier
				{
					$$ = $1;
					logFile << "Line " << lineCount <<   " parameter_list : type_specifier\n\n";
					logFile << $$->getName() << "\n\n";
				}
			;

compound_statement 	: LCURL statements RCURL
					{
						string decName = "{\n"+ $2->getName() + "\n}";
						string decType = "compound_statement";


						$$ = new symbolInfo(decName, decType);
						$$->setCode($2->getCode());

						logFile << "Line " << lineCount <<  " compound_statement : LCURL statements RCURL\n\n";
						logFile << $$->getName() << "\n\n";
						
						symboltable.printAllScope(logFile);
						symboltable.exitScope();
					}
				    | LCURL RCURL
					{
						string decName = "{\n\n}";
						string decType = "compound_statement";


						$$ = new symbolInfo(decName, decType);

						logFile << "Line " << lineCount <<  " compound_statement : LCURL RCURL\n\n";
						logFile << $$->getName() << "\n\n";
						
						
					}
				;


var_declaration : type_specifier declaration_list SEMICOLON
				{
					string variableType = $1->getName();

					//check if the variable type is void
					if (variableType == "void")
					{
						logFile << "Error at line " << lineCount << " : Variable type cannot be void.\n\n";
						errorFile << "Error at line " << lineCount << " : Variable type cannot be void.\n\n";
						errorCount++;
						lineTrack=lineCount;
					}
					//if not , proceed
					if(variableType == "int" || variableType == "float")
					{
						string variables = $2->getName();

						vector<string> variableSet = parseString(variables , ',');
						for (int i=0; i<variableSet.size(); i++)
						{
							symbolInfo variableSymbol = new symbolInfo();
                            variableSymbol.setExtraType(0);
							string variable = variableSet.at(i);

							if ((variable.find("[") != string::npos) || (variable.find("]") != string::npos))
							{
								
								stringstream arrayVar(variable);//int A[10](suppose)
								string arrayVarName, intermediate, arrayVariableSize;
								getline(arrayVar, arrayVarName, '[');// arrayVarName = "A"
					
								while(getline(arrayVar, intermediate, '[')){
									//now intermediate the element would be A, 10], recent value of intermediate = "10]"
								}

								stringstream arraySizeToken(intermediate);
								getline(arraySizeToken,arrayVariableSize,']');//arrayVariableSize="10"
								int arrayVarSize = stoi(arrayVariableSize);//arrayVarSize = 10


								
							
								variableSymbol.arraySymbol(arrayVarName, variableType, arrayVarSize);
								//variableSymbol.setCodeName(global_name);
							}
							else
							{
								
								variableSymbol.setName(variable);
								variableSymbol.setType(variableType);


							
							}

							//	check if Multiple declaration of variable
							//bool insert = symboltable.insertCurrSymbolInfo(variableSymbol, logFile);

                            if(symboltable.getCurrentScope()==0){

									variableSymbol.setOffset(0);
									//variableSymbol.setExtraType(int type);
									string global_name = getGlobalName(variableSymbol.getName(), symboltable);
									variableSymbol.setCodeName(global_name);
								
									bool insert = symboltable.insertCurrSymbolInfo(variableSymbol, logFile);
									
								

                                  
                          // symbolInfo* symbol = symboltable.lookUpScope(variableSymbol.getName(), logFile);
						   symbolInfo* symbol = symboltable.lookUpScope(variableSymbol.getName(), logFile);
							
								symbol->setCodeName(global_name);
								
							//variableSymbol.setInScopeName(variableSymbol.getName());

								//cout << symbol->getCodeName() << endl;
                                 global_list* symbol2 = new global_list(global_name, symbol->getArrSize());
                            global_var_list.push_back(symbol2);
                            cout << "here4" << endl;
							//cout << symbol->getInScopeName() << endl;

							if ( !insert ) {
								logFile << "Error at line " << lineCount << " : Multiple declaration of variable '" << variableSymbol.getName()+"' \n\n";
								errorFile << "Error at line " << lineCount << " : Multiple declaration of variable '" << variableSymbol.getName()+"' \n\n";
								errorCount++;
								lineTrack=lineCount;
							} 
						
									
							}
							else{
								stackOffset=stackOffset+2;
								variableSymbol.setOffset(-stackOffset);
								//cout << variableSymbol.getName() << endl;
								string global_name = getGlobalName(variableSymbol.getName(), symboltable);
									variableSymbol.setCodeName(global_name);
								
								bool insert = symboltable.insertCurrSymbolInfo(variableSymbol, logFile);
								//symbolInfo* ss = 
								
								symbolInfo* symbol = symboltable.lookUpScope(variableSymbol.getName(), logFile);
								//string global_name =G(symbol->getName(), symboltable);
									symbol->setCodeName(global_name);
							
                             global_list* symbol2 = new global_list(global_name, symbol->getArrSize());
                            global_var_list.push_back(symbol2);
                            cout << "here5" << endl;
						

								if ( !insert ) {
								logFile << "Error at line " << lineCount << " : Multiple declaration of variable '" << variableSymbol.getName()+"' \n\n";
								errorFile << "Error at line " << lineCount << " : Multiple declaration of variable '" << variableSymbol.getName()+"' \n\n";
								errorCount++;
								lineTrack=lineCount;
							} 

							

						}
					}

					
					string decName = $1->getName() + " " + $2->getName() + ";";
					string decType = "var_declaration";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " var_declaration : type_specifier declaration_list SEMICOLON\n\n";
					logFile << $$->getName() << "\n\n";	
					
				}

                }
			;

type_specifier 	: INT
				{
					$$ = new symbolInfo("int", "int");
					logFile << "Line " << lineCount <<  " type_specifier : INT\n\n";
					logFile << $$->getName() << "\n\n";	
				}
 				| FLOAT
				{
					$$ = new symbolInfo("float", "float");
					logFile << "Line " << lineCount <<  " type_specifier : FLOAT\n\n";
					logFile << $$->getName() << "\n\n";	
				}
		 		| VOID
				{
					$$ = new symbolInfo("void", "void");
					logFile << "Line " << lineCount <<  " type_specifier : VOID\n\n";
					logFile << $$->getName() << "\n\n";	
				}
			;

declaration_list : declaration_list COMMA ID
				{
					
					string decName = $1->getName() + "," + $3->getName();
					string decType = "declaration_list";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " declaration_list : declaration_list COMMA ID\n\n";
					logFile << $$->getName() << "\n\n";
						
				}
		 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
				{
					
					string decName = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]";
					string decType = "declaration_list";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| ID
				{
					$$ = $1;
					logFile << "Line " << lineCount <<  " declaration_list : ID\n\n";
					logFile << $$->getName() << "\n\n";
				}
		 		| ID LTHIRD CONST_INT RTHIRD
				{
					string decName = $1->getName() + "[" + $3->getName() + "]";
					string decType = "declaration_list";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
					logFile << $$->getName() << "\n\n";
				}
			;

statements : statement
			{
				$$ = $1;
				logFile << "Line " << lineCount <<  " statements : statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| statements statement
			{
				string decName = $1->getName() + "\n" + $2->getName();
				string decType = "statements";


				$$ = new symbolInfo(decName, decType);
				$$->setCode($1->getCode() + $2->getCode());

				logFile << "Line " << lineCount <<  " statements : statements statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
		;


statement : var_declaration
			{
				$$ = $1;
				logFile << "Line " << lineCount <<  " statement : var_declaration\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| expression_statement
			{
				$$ = $1;
				logFile << "Line " << lineCount <<  " statement : expression_statement\n\n";
				logFile << $$->getName() << "\n\n";
				//$$->setCode($1->getCode() + $2->getCode());
			}
			| { symboltable.enterScope(); } compound_statement 
			{
				$$ = $2;
				logFile << "Line " << lineCount <<  " statement : compound_statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| FOR LPAREN expression_statement expression_statement expression RPAREN statement
			{

				string code = "";
				
				code += $3->getCode();

				if ( $3->getName() != ";" && $4->getName() != ";")
				{
					string label_1 = new_label();
					string label_2 = new_label();

					code += label_1 + ":\n";
					code += $4->getCode();
					cout <<"1" <<$4->getCodeName() << "\n";
					code += "\tMOV AX, " + $4->getCodeName() + "\n";
					code += "\tCMP AX, 0\n";
					code += "\tJE " + label_2 + "\n";

					code +=$7->getCode();
					code += $5->getCode();
					code += "\tJMP " + label_1 + "\n";
					code += label_2 + ":\n";
				}

				string decName = "for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);
				$$->setCode(code);

				logFile << "Line " << lineCount <<  " statement : IF LPAREN expression_statement expression_statement expression RPAREN statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
			{

				
				string label = new_label();

				string code = "";

				code += "; code segment for IF rule\n";

				code += $3->getCode();
				cout <<"2" <<$3->getCodeName() << "\n";
				code += "\tMOV AX, " + $3->getCodeName() + "\n";
				code += "\tCMP AX, 0\n";
				code += "\tJE " + label + "\n";
				code += $5->getCode();
				code += label + ":\n";

				string decName = "if(" + $3->getName() + ")" + $5->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);
				$$->setCode(code);

				logFile << "Line " << lineCount <<  " statement : IF LPAREN expression RPAREN statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| IF LPAREN expression RPAREN statement ELSE statement
			{

			

				string label_1 = new_label();
				string label_2 = new_label();

				string code = "";

				code += "; code segment for IF ELSE rule\n";

				code += $3->getCode();
				cout <<"3" <<$3->getCodeName() << "\n";
				code += "\tMOV AX, " + $3->getCodeName() + "\n";
				code += "\tCMP AX, 0\n";
				code += "\tJE " + label_1 + "\n";
				code += $5->getCode();
				code += "\tJMP " + label_2 + "\n";
				code += label_1 + ":\n";
				code += $7->getCode();
				code += label_2 + ":\n";

			
				string decName = "if(" + $3->getName() + ")" + $5->getName() + "else" + $7->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);
				$$->setCode(code);

				logFile << "Line " << lineCount <<  " statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| WHILE LPAREN expression RPAREN statement
			{

				
				string code = "";

				string label_1 = new_label();
				string label_2 = new_label();

				code += "; code segment for WHILE rule\n";

				code += label_1 + ":\n";
				code +=  $3->getCode();
				cout <<"4" <<$3->getCodeName() << "\n";
				code += "\tMOV AX, " + $3->getCodeName() + "\n";
				code += "\tCMP AX, 0\n";
				code += "\tJE " + label_2 + "\n";

				code += $5->getCode();
				code += "\tJMP " + label_1 + "\n";
				code += label_2 + ":\n";

				string decName = "while(" + $3->getName() + ")" + $5->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);
				$$->setCode(code);

				logFile << "Line " << lineCount <<  " statement : WHILE LPAREN expression RPAREN statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| PRINTLN LPAREN ID RPAREN SEMICOLON
			{
				string idName = $3->getName();
				symbolInfo* varId = symboltable.lookUpScope(idName, logFile);
				//error check
				//error1- check if the id is declared
				if (varId == nullptr)
				{
					logFile << "Error at line " << lineCount << " : Undeclared Variable '" << idName << "'\n\n";
					errorFile << "Error at line " << lineCount << " : Undeclared Variable '" << idName << "'\n\n";
					errorCount++;
					lineTrack=lineCount;
				}
				//error2-check if the id is actually a variable
				else if (varId->getExtraType()!=0)
				{
					logFile << "Error at line " << lineCount << " : A variable should be inside printf\n\n";
					errorFile << "Error at line " << lineCount << " : A variable should be inside printf\n\n";
					errorCount++;
					lineTrack=lineCount;
				}

				// assembly code
				string code = "";
				//string currentVar = varId->getCodeName();
				cout <<"5" <<varId->getCodeName() << "\n";

				code += "\tMOV AX, " + varId->getCodeName() + "\n";
				code += "\tMOV print_var, AX\n";
				code += "\tCALL PRINTLN\n";

				//$$ = new SymbolInfo("println(" + $3->getName() + ");",	"statement");
				
				
				string decName = "printf(" + $3->getName() + ");";
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);
				$$->setCode(code);

				logFile << "Line " << lineCount <<  " statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| RETURN expression SEMICOLON
			{
			
				//string currentReturnType = $2->getName();
				string code = "";

				if (returnType == "void")
				{
					returnType = "UNKNOWN";
					
					logFile << "Error at line " << lineCount << " : Function type void can't have a return statement\n\n";
					errorFile << "Error at line " << lineCount << " : Function type void can't have a return statement\n\n";
					errorCount++;
					lineTrack=lineCount;

				}

				code += $2->getCode();

				code += "\tPOP BP\n";
				code += "\tPUSH " + $2->getCodeName() + "\n";

				

				
				string decName = "return " + $2->getName() + ";";
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);
				$$->setCode(code);

				logFile << "Line " << lineCount <<  " statement : RETURN expression SEMICOLON\n\n";
				logFile << $$->getName() << "\n\n";
			}
		;

expression_statement : SEMICOLON
					{
						$$ = new symbolInfo(";", "SEMICOLON");
					}
					| expression SEMICOLON
					{
						
						string decName = $1->getName() + ";";
						string decType = "expression_statement";


						$$ = new symbolInfo(decName, decType);
						//cout<<$1->getCode()<<endl;
						$$->setCode($1->getCode());
						$$->setCodeName($1->getCodeName());

						logFile << "Line " << lineCount <<  " expression_statement : expression SEMICOLON\n\n";
						logFile << $$->getName() << "\n\n";
					}
				;

variable :	ID
			{
				
				symbolInfo* currentVarId = symboltable.lookUpScope($1->getName(), logFile);

				
				if (currentVarId != nullptr)
				{
					$$ = new symbolInfo();
					//check if it's an array
					
					if (currentVarId->getExtraType()==1)
					{
						//id cannot be array without LTHIRD expression RTHIRD
						$$->arraySymbol(currentVarId->getName(),"UNKNOWN" , currentVarId->getArrSize());
					}
					else
					{
						
						//cout <<" done\n";
						$$->setName(currentVarId->getName());
						$$->setType(currentVarId->getType());
						$$->setCodeName(currentVarId->getCodeName());
						//cout << $$->getCodeName() << endl;
					}
				}
				else
				{
					$$ = new symbolInfo($1->getName(), "UNKNOWN");
					logFile << "Error at line " << lineCount << " : Undeclared variable '" << $1->getName() << "'\n\n";
					errorFile << "Error at line " << lineCount << " : Undeclared variable '" << $1->getName() << "'\n\n";
					errorCount++;
					lineTrack=lineCount;
				}
			
				logFile << "Line " << lineCount <<  " variable : ID\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| ID LTHIRD expression RTHIRD
			{
				symbolInfo* currentVarId = symboltable.lookUpScope($1->getName(),logFile);
				

				if (currentVarId != nullptr)
				{
					//check if it's an array
					if (currentVarId->getExtraType()==1)	
					{	
						string operateType = currentVarId->getType();
						//	check if array index is non-integer 
						if ($3->getType() != "int")
						{
							
							logFile << "Error at line " << lineCount << " : Non-integer array index of '" << $1->getName() << "'\n\n";
							errorFile << "Error at line " << lineCount << " : Expression inside third brackets not an integer\n\n";
							errorCount++;
							lineTrack=lineCount;
						}
						else if((stoi($3->getName()))>currentVarId->getArrSize()){
							logFile << "Error at line " << lineCount << " : array index out of bound for '" << $1->getName() << "'\n\n";
							errorFile << "Error at line " << lineCount << " : array index out of bound for '" << $1->getName() << "'\n\n";
							errorCount++;
							lineTrack=lineCount;
						}

						
						string decName = $1->getName() + "[" + $3->getName() + "]";
						string decType = currentVarId->getType();



						$$ = new symbolInfo(decName, decType);
						// string global_name = currentVarId->getCodeName();
						string code = "";
						string temp = tempVar();

						code +=  $3->getCode();
						code += "\tMOV SI, " + $3->getCodeName() + "\n";
						code += "\tADD SI, SI\n";
						cout <<"6" <<currentVarId->getCodeName() << "\n";
						code += "\tMOV AX, " + currentVarId->getCodeName() + "[SI]\n";
					//	code += "\tMOV " + temp + ", AX\n";
						temp = currentVarId->getCodeName() + "[" + $3->getCodeName() + "]";
						$$->setCode(code);
						$$->setCodeName(temp);

						

					}
					else
					{
						
						logFile << "Error at line " << lineCount << ": " << currentVarId->getName() << "' not an array\n\n";
						errorFile << "Error at line " << lineCount << ": " << currentVarId->getName() << "' not an array\n\n";
						errorCount++;
						lineTrack=lineCount;

						
						string decName = $1->getName() + "[" + $3->getName() + "]";
						string decType = "UNKNOWN";


						$$ = new symbolInfo(decName, decType);

					}
					
				}
				else
				{
					
					logFile << "Error at line " << lineCount << " : Undeclared variable '" << $1->getName() << "'\n\n";
					errorFile << "Error at line " << lineCount << " : Undeclared variable '" << $1->getName() << "'\n\n";
					errorCount++;
					lineTrack=lineCount;

					
					string decName = $1->getName() + "[" + $3->getName() + "]";
					string decType = "UNKNOWN";


					$$ = new symbolInfo(decName, decType);
				}
				logFile << "Line " << lineCount <<  " variable : ID LTHIRD expression RTHIRD\n\n";
				logFile << $$->getName() << "\n\n";
			}
		;

expression: logic_expression
			{
				$$ = $1;
				
				logFile << "Line " << lineCount <<  " expression : logic_expression\n\n";
				logFile << $$->getName() << "\n\n";
			}
		    | variable ASSIGNOP logic_expression
			{
				symbolInfo* leftExpression  = $1;
				symbolInfo* rightExpression = $3;

				if($1->getType()=="void"||$3->getType()=="void"){
					if($1->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$1->setType("int");
					}
					if($3->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$3->setType("int");
					}
				}
				

				if (leftExpression->getType() != rightExpression->getType())
				{
					//AS WE CAN ASSIGN INT TYPE EXPRESSION IN FLOAT TYPE VARIABLE
					if((leftExpression->getType() != "float" || rightExpression->getType() != "int"))
					{
						//CHECK IF ANY OF THE EXPRESSION IS ARRAY
						if ((leftExpression->getType() == "UNKNOWN" || rightExpression->getType() == "UNKNOWN") && (leftExpression->getExtraType()==1))
						{
							if(lineTrack!=lineCount){
								logFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << leftExpression->getName() << "' is an array\n\n";
								errorFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << leftExpression->getName() << "' is an array\n\n";
								errorCount++;
								lineTrack=lineCount;
							}

						}
						else if ((leftExpression->getType() == "UNKNOWN" || rightExpression->getType() == "UNKNOWN") && (rightExpression->getExtraType()==1))
							{
								if(lineTrack!=lineCount){
									logFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << rightExpression->getName() << "' is an array\n\n";
									errorFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << rightExpression->getName() << "' is an array\n\n";
									errorCount++;
									lineTrack=lineCount;
								}
							}
						
						else
						{
							if(lineTrack!=lineCount){
								logFile << "Error at line " << lineCount << " : Type mismatch \n\n";
								errorFile << "Error at line " << lineCount << " : Type mismatch \n\n";
								errorCount++;
								lineTrack=lineCount;
							}
						}
					}
					
				}
				/*else if((leftExpression->getExtraType()==1)||(rightExpression->getExtraType()==1))
				{
					//CHECK IF ANY OF THE EXPRESSION IS ARRAY
					logFile << "error assignOp check\n";
					if ((leftExpression->getExtraType()==1))
					{
						logFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << leftExpression->getName() << "' is an array\n\n";
						errorFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << leftExpression->getName() << "' is an array\n\n";
						errorCount++;

					}
					else if ((rightExpression->getExtraType()==1))
					{
						logFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << rightExpression->getName() << "' is an array\n\n";
						errorFile << "Error at line " << lineCount << " : Type mismatch. Variable '" << rightExpression->getName() << "' is an array\n\n";
						errorCount++;
					}
						
				}*/

				//string left_asm = $1->getAsm();
				//string right_asm = $3->getAsm();
				
				//string left_code = $1->getCode();
				//string right_code = $3->getCode();

				string code = "";

				code += $1->getCode()+$3->getCode();
				//code += $3->getCode();
				cout <<"7" <<$3->getCodeName() << "\n";

				code += "\tMOV AX, " + $3->getCodeName()+ "\n";
				//cout<<"era "<<$3->getCodeName()<<endl;
				code += "\tMOV " + $1->getCodeName() + ", AX\n";

				
		
				string decName = $1->getName() + $2->getName() + $3->getName();
				string decType = "expression";


				$$ = new symbolInfo(decName, decType);
				$$->setCode(code);
				$$->setCodeName($1->getCodeName());

				logFile << "Line " << lineCount <<  " expression : variable ASSIGNOP logic_expression\n\n";
				logFile << $$->getName() << "\n\n";
			}
		;

logic_expression :	rel_expression
					{
						$$ = $1;
						logFile << "Line " << lineCount <<  " logic_expression : rel_expression\n\n";
						logFile << $$->getName() << "\n\n";
						
					}
					| rel_expression LOGICOP rel_expression
					{
						string operateType = "int";
						symbolInfo* leftExpression  = $1;
						symbolInfo* rightExpression = $3;

					if($1->getType()=="void"||$3->getType()=="void"){
					if($1->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$1->setType("int");
					}
					if($3->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$3->setType("int");
					}
				}
						
						
						if ((leftExpression->getType() != "int") || (rightExpression->getType() != "int"))
						{
							logFile << "Error at line " << lineCount << " : Both operand of " << $2->getName() << " should be integer type\n\n";
							errorFile << "Error at line " << lineCount << " : Both operand of " << $2->getName() << " should be integer type\n\n";
							errorCount++;
							lineTrack=lineCount;

							operateType = "UNKNOWN";
						}


						string logicOp = $2->getName();

						//string left_asm = $1->getCodeName();
						//string right_asm = $3->getCodeName();

						//string left_code = $1->getCode();
						//string right_code = $3->getCode();

						string code = "";
						string temp = tempVar();

						string JE0LEVEL = new_label();
						string JE1LEVEL = new_label();

						code += $1->getCode()+$3->getCode();
						cout << code << endl;
						//code += $3->getCode();

						if (logicOp == "&&")
						{	
							code += "\tMOV AX, " + $1->getCodeName() + "\n";
							code += "\tCMP AX, 0\n";
							code += "\tJE " + JE0LEVEL + "\n";
							code += "\tMOV AX, " + $3->getCodeName() + "\n";
							code += "\tCMP AX, 0\n";
							code += "\tJE " + JE0LEVEL + "\n";
							code += "\tMOV AX, 1\n";
							code += "\tMOV " + temp + ", AX\n";
							code += "\tJMP " + JE1LEVEL + "\n";
							code += JE0LEVEL + ":\n";
							code += "\tMOV AX, 0\n";
							code += "\tMOV " + temp + ", AX\n";
							code += JE1LEVEL + ":\n";
						}
						else
						{
							code += "\tMOV AX, " + $1->getCodeName() + "\n";
							code += "\tCMP AX, 0\n";
							code += "\tJNE " + JE0LEVEL + "\n";
							code += "\tMOV AX, " + $3->getCodeName() + "\n";
							code += "\tCMP AX, 0\n";
							code += "\tJNE " + JE0LEVEL + "\n";
							code += "\tMOV AX, 1\n";
							code += "\tMOV " + temp + ", AX\n";
							code += "\tJMP " + JE1LEVEL + "\n";
							code += JE0LEVEL + ":\n";
							code += "\tMOV AX, 0\n";
							code += "\tMOV " + temp + ", AX\n";
							code += JE1LEVEL + ":\n";
						}

						//$$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName(),	_returnType);
						

						
						string decName = $1->getName() + $2->getName() + $3->getName();
						string decType = operateType;


						$$ = new symbolInfo(decName, decType);
						$$->setCode(code);
						$$->setCodeName(temp);

						logFile << "Line " << lineCount <<  " logic_expression : rel_expression LOGICOP rel_expression\n\n";
						logFile << $$->getName() << "\n\n";
					}
				;

rel_expression	: simple_expression
				{
					$$ = $1;
					logFile << "Line " << lineCount <<  " rel_expression : simple_expression\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| simple_expression RELOP simple_expression
				{
				if($1->getType()=="void"||$3->getType()=="void"){
					if($1->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$1->setType("int");
					}
					if($3->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$3->setType("int");
					}
				}
					string code = "";
					string temp = tempVar();

					string label1 = new_label();
					string label2 = new_label();

					string symbol = $2->getName();

					code += $1->getCode()+$3->getCode();
					//code += $3->getCode();
					cout <<"8" <<$1->getCodeName() << "\n";

					code += "\tMOV AX, " + $1->getCodeName()  + "\n";
					code += "\tCMP AX, " + $3->getCodeName() + "\n";

					if (symbol == "<")
					{
						code += "\tJL " + label2 + "\n";
						code += "\tMOV AX, 0\n";
						code += "\tMOV " + temp + ", AX\n";
						code += "\tJMP " + label1 + "\n";
						code += label2 + ":\n";
						code += "\tMOV AX, 1\n";
						code += "\tMOV " + temp + ", AX\n";
						code += label1 + ":\n";
					}
					else if (symbol == ">")
					{
						code += "\tJG " + label2 + "\n";
						code += "\tMOV AX, 0\n";
						code += "\tMOV " + temp + ", AX\n";
						code += "\tJMP " + label1 + "\n";
						code += label2 + ":\n";
						code += "\tMOV AX, 1\n";
						code += "\tMOV " + temp + ", AX\n";
						code += label1 + ":\n";
					}
					else if (symbol == "<=")
					{
						code += "\tJLE " + label2 + "\n";
						code += "\tMOV AX, 0\n";
						code += "\tMOV " + temp + ", AX\n";
						code += "\tJMP " + label1 + "\n";
						code += label2 + ":\n";
						code += "\tMOV AX, 1\n";
						code += "\tMOV " + temp + ", AX\n";
						code += label1 + ":\n";
					}
					else if (symbol == ">=")
					{
						code += "\tJGE " + label2 + "\n";
						code += "\tMOV AX, 0\n";
						code += "\tMOV " + temp + ", AX\n";
						code += "\tJMP " + label1 + "\n";
						code += label2 + ":\n";
						code += "\tMOV AX, 1\n";
						code += "\tMOV " + temp + ", AX\n";
						code += label1 + ":\n";
					}
					else if (symbol == "==")
					{
						code += "\tJE " + label2 + "\n";
						code += "\tMOV AX, 0\n";
						code += "\tMOV " + temp + ", AX\n";
						code += "\tJMP " + label1 + "\n";
						code += label2 + ":\n";
						code += "\tMOV AX, 1\n";
						code += "\tMOV " + temp + ", AX\n";
						code += label1 + ":\n";
					}
					else
					{
						code += "\tJNE " + label2 + "\n";
						code += "\tMOV AX, 0\n";
						code += "\tMOV " + temp + ", AX\n";
						code += "\tJMP " + label1 + "\n";
						code += label2 + ":\n";
						code += "\tMOV AX, 1\n";
						code += "\tMOV " + temp + ", AX\n";
						code += label1 + ":\n";
					}
					
				
					//	The result of RELOP and LOGICOP should be INTEGER as 2<3 will give result 1, again 2>3 will give result 0, which are integer
					string decName = $1->getName() + $2->getName() + $3->getName();
					string decType ="int";


					$$ = new symbolInfo(decName, decType);
					$$->setCode(code);
					$$->setCodeName(temp);

					logFile << "Line " << lineCount <<  " rel_expression : simple_expression RELOP simple_expression\n\n";
					logFile << $$->getName() << "\n\n";
				}
			;

simple_expression :	term
					{
						$$ = $1;
						logFile << "Line " << lineCount <<  " simple_expression : term\n\n";
						logFile << $$->getName() << "\n\n";
						//cout<<"sonya   a"<<$1->getCode()<<endl;
					}
					| simple_expression ADDOP term
					{
						
					if($1->getType()=="void"||$3->getType()=="void"){
					if($1->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$1->setType("int");
					}
					if($3->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$3->setType("int");
					}
				}
						string expressionType = "int";
						if($1->getType() != $3->getType()){
							if (($1->getType() == "float") || ($3->getType() == "float"))
							{
								expressionType = "float";
							}
						}


						string temp;
						string code = "";

						//string left_code  = $1->getCode();
						//string right_code = $3->getCode();

						string left_asm  = $1->getCodeName();
						string right_asm = $3->getCodeName();

						code += $1->getCode()+$3->getCode();
						//code += $3->getCode();

						if ($2->getName() == "+") {
							
							cout <<"8" <<$1->getCodeName() << "\n";
							code += "\tMOV AX, " + $1->getCodeName()  + "\n";
							code += "\tADD AX, " + $3->getCodeName() + "\n";
							temp = tempVar();
							code += "\tMOV " + temp + ", AX\n";

						}
						else {
							
							cout <<"9" <<$1->getCodeName() << "\n";
							code += "\tMOV AX, " + $1->getCodeName()  + "\n";
							code += "\tSUB AX, " + $3->getCodeName() + "\n";
							temp = tempVar();
							code += "\tMOV "  + temp + ", AX\n";
						}

						string decName = $1->getName() + $2->getName() + $3->getName();
						string decType = expressionType;


						$$ = new symbolInfo(decName, decType);
						$$->setCode(code);
						$$->setCodeName(temp);

						logFile << "Line " << lineCount <<  " simple_expression : simple_expression ADDOP term\n\n";
						logFile << $$->getName() << "\n\n";
					}
				;

term :	unary_expression
		{
			$$ = $1;
			logFile << "Line " << lineCount <<  " term : unary_expression\n\n";
			logFile << $$->getName() << "\n\n";
		}
		|  term MULOP unary_expression
		{

			string expressionType = "UNKNOWN";
			string operatorSymbol = $2->getName();
			//logFile << $1->getType() <<"\n\n";

			//if($1->getType()!="UNKNOWN")
			if($1->getType()=="void"||$3->getType()=="void"){
					if($1->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$1->setType("int");
					}
					if($3->getType()=="void"){
						logFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorFile << "Error at line " << lineCount << " : Void function used in expression\n\n";
						errorCount++;
						lineTrack=lineCount;
						$3->setType("int");
					}
				}
			//{
				if (operatorSymbol == "/")
				{
					expressionType = "int";
					if($1->getType() != $3->getType()){
						if ($1->getType() == "float" ||  $3->getType() == "float")	
							expressionType = "float";
						else												
							expressionType = "float";

					}
					//ERROR CHECK - 0 CAN'T DE DIVIDER
					if ($3->getName() == "0")
					{

						expressionType = "UNKNOWN";
						logFile << "Error at line " << lineCount << " : Divided by zero not possible\n\n";
						errorFile << "Error at line " << lineCount << " : Divided by zero not possible\n\n";
						errorCount++;
						lineTrack=lineCount;
						
					}
				}

				else if (operatorSymbol == "*"){
					expressionType = "int";
					if($1->getType() != $3->getType()){
						if ($1->getType() == "float" ||  $3->getType() == "float")	
							expressionType = "float";
						else												
							expressionType = "int";

					}
				}

				else if(operatorSymbol == "%"){
					//ERROR CHECK - MODULUS CAN'T HAVE NON-INTEGER OPERAND
					if ($1->getType() != "int" ||  $3->getType() != "int")
					{
						expressionType = "UNKNOWN";
						logFile << "Error at line " << lineCount << " : Non-integer operand on modulus operator\n\n";
						errorFile << "Error at line " << lineCount << " : Non-integer operand on modulus operator\n\n";
						errorCount++;
						lineTrack=lineCount;
					}

					else
					{
						expressionType = "int";
						if ($3->getName() == "0")
						{
							expressionType = "UNKNOWN";
							logFile << "Error at line " << lineCount << " : Modulus by zero\n\n";
							errorFile << "Error at line " << lineCount << " : Modulus by zero\n\n";
							errorCount++;
							lineTrack=lineCount;
						}
						
					}
				}
				else
				{
					expressionType = "UNKNOWN";//undeclared type
				}

				// Assembly code
			string code = "";
			string temp = tempVar();

			
			code += $1->getCode()+$3->getCode();
			
			if (operatorSymbol == "*") {
				
				code += "\tMOV AX, " +  $1->getCodeName()+ "\n";
				code += "\tMOV BX, " +  $3->getCodeName() + "\n";
				code += "\tIMUL BX\n";
				code += "\tMOV " + temp + ", AX\n";
				cout <<"10" <<$1->getCodeName() << "\n";

			}
			else {
				cout <<"11" <<$1->getCodeName() << "\n";

				if (operatorSymbol == "/") {
					code += "\tMOV AX, " +  $1->getCodeName() + "\n";
					code += "\tCWD\n";
					code += "\tMOV BX, " + $3->getCodeName()+ "\n";
					code += "\tIDIV BX\n";
					code += "\tMOV " + temp + ", AX\n";
				}
				else {
					code += "\tMOV AX, " +  $1->getCodeName() + "\n";
					code += "\tCWD\n";
					code += "\tMOV BX, " + $3->getCodeName() + "\n";
					code += "\tIDIV BX\n";
					code += "\tMOV " + temp + ", DX\n";
				}
			}

			

			string decName = $1->getName() + $2->getName() + $3->getName();
			string decType = expressionType;


			$$ = new symbolInfo(decName, decType);
			$$->setCode(code);
			$$->setCodeName(temp);

			logFile << "Line " << lineCount <<  " term : term MULOP unary_expression\n\n";
			logFile << $$->getName() << "\n\n";
		}
	;

unary_expression: ADDOP unary_expression
				{

					string temp;
					string code = "";
					

					if ($1->getName() == "-"){
						temp = tempVar();
						code +=  $2->getCode();
						code += "\tMOV AX, " + $2->getCodeName() + "\n";
						code += "\tMOV " + temp + ", AX\n";
						code += "\tNEG " + temp + "\n";
					}
					else {
						temp = $2->getCodeName();
						code =  $2->getCode();
					}

					string decName = $1->getName() + $2->getName();
					string decType = $2->getType();


					$$ = new symbolInfo(decName, decType);
					$$->setCode(code);
					$$->setCodeName(temp);

					logFile << "Line " << lineCount <<  " unary_expression : ADDOP unary_expression\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| NOT unary_expression
				{

					string temp;
					string code = "";
					
					string label1 = new_label();
					string label2 = new_label();

					code += $2->getCode();
					cout <<"12" <<$2->getCodeName() << "\n";


					code += "\tMOV AX, " +  $2->getCodeName() + "\n";
					code += "\tCMP AX, 0\n";
					code += "\tJE " + label2 + "\n";
					code += "\tMOV AX, 0\n";
					code += "\tMOV " +  temp + ", AX\n";
					code += "\tJMP " + label1 + "\n";

					code += label2 + ":\n";
					code += "\tMOV AX, 1\n";
					code += "\tMOV " + temp + ", AX\n";
					code += label1 + ":\n";


					string decName = $1->getName() + $2->getName();
					string decType = $2->getType();


					$$ = new symbolInfo(decName, decType);
					$$->setCode(code);
					$$->setCodeName(temp);

					logFile << "Line " << lineCount <<  " unary_expression : NOT unary_expression\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| factor
				{
					$$ = $1;
					logFile << "Line " << lineCount <<  " unary_expression : factor\n\n";
					logFile << $$->getName() << "\n\n";
				}
			;

factor: variable
		{
			$$ = $1;
			logFile << "Line " << lineCount <<  " factor : variable\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| ID LPAREN argument_list RPAREN
		{
			string functionType = "UNKNOWN";
			string temp;
			string code = "";
			//voidVal=0;

			symbolInfo* functionSymbol = symboltable.lookUpScope($1->getName(), logFile);
			
			//check if the function is even declared!
			if (functionSymbol == nullptr)
			{
				logFile << "Error at line " << lineCount << " : Undeclared function '" << $1->getName() << "'\n\n";
				errorFile << "Error at line " << lineCount << " : Undeclared function '" << $1->getName() << "'\n\n";
				errorCount++;
				lineTrack=lineCount;
			}
			else
			{
				//check whether we're accessing a function or a variable/array
				if (functionSymbol->getExtraType()!=-1)
				{
					logFile << "Error at line " << lineCount << " : Non function Identifier '" << functionSymbol->getName() << "' accessed\n\n";
					errorFile << "Error at line " << lineCount << " : Non function Identifier '" << functionSymbol->getName() << "' accessed\n\n";
					errorCount++;
					lineTrack=lineCount;
					
				}
				else
				{
					functionType = functionSymbol->getType();
						
						vector<string> argumentNames = parseString($3->getName(), ',');
						vector<string> argumentTypes = parseString($3->getType(), ',');
						//asm code
						vector<string> argAsmNames =  parseString($3->getCodeName(), ',');

						
						vector<paramList> parameters = functionSymbol->getParamList();

						//error check - check if numbers of arguments match
						if (parameters.size() != argumentNames.size())	
						{
							//logFile << "Error at line " << lineCount << " : Number of arguments isn't consistent with function '" << functionSymbol->getName() << "'\n\n";
							errorFile << "Error at line " << lineCount << " : Total number of arguments mismatch with declaration in function  '" << functionSymbol->getName() << "'\n\n";
							logFile << "Error at line " << lineCount << " : Total number of arguments mismatch with declaration in function  '" << functionSymbol->getName() << "'\n\n";
							errorCount++;
							lineTrack=lineCount;
						}

						else	
						{
							for (int i=0; i < argumentNames.size(); i++)
							{
								//error check - check if the types of arguments & parameters matches
								if(symboltable.lookUpScope(argumentNames.at(i), logFile)!=nullptr){
									symbolInfo* symbol = symboltable.lookUpScope(argumentNames.at(i), logFile);
									if(symbol->getExtraType()==1){
										logFile << "Error at line " << lineCount << " : Type mismatch, " << argumentNames.at(i) <<" is an array\n\n";
										errorFile << "Error at line " << lineCount << " : Type mismatch, " << argumentNames.at(i) <<" is an array\n\n";
										errorCount++;
										lineTrack=lineCount;
										break;
									}
									else if(symbol->getExtraType()==-1){
										logFile << "Error at line " << lineCount << " : Type mismatch, " << argumentNames.at(i) <<" is a function\n\n";
										errorFile << "Error at line " << lineCount << " : Type mismatch, " << argumentNames.at(i) <<" is a function\n\n";
										errorCount++;
										lineTrack=lineCount;
										break;
									}
								}
								else if (argumentTypes.at(i) != parameters.at(i).getParamType())
								{
									logFile << "Error at line " << lineCount << " :" << i+1 << "th argument mismatch in function '" << functionSymbol->getName() << "'\n\n";
									//errorFile << "expected : " << parameters.at(i).getParamType() << " found : " << argumentTypes.at(i) <<"\n";
									//errorFile << "Error at line " << lineCount << " : Type mismatch on function '" << functionSymbol->getName() << "'s argument '" << parameters.at(i).getParamName() + "'\n\n";
									errorFile << "Error at line " << lineCount << " :" << i+1 << "th argument mismatch in function '" << functionSymbol->getName() << "'\n\n";
									errorCount++;
									lineTrack=lineCount;
									break;
								}
								
							}

							//string code, temp;

							code += "\tPUSH AX\n";
							code += "\tPUSH BX\n";
							code += "\tPUSH CX\n";
							code += "\tPUSH DX\n";

							// Pushing the value of arguments in the stack
							// to get back in the PROC later.

							int count = argAsmNames.size();

							while(count--) {
								code += "\tPUSH " + argAsmNames[count] + "\n";
							}

							code += "\tCALL " + functionSymbol->getName() + "\n";
							temp = tempVar();
							code += "\tPOP " + temp + "\n";

							code += "\tPOP DX\n";
							code += "\tPOP CX\n";
							code += "\tPOP BX\n";
							code += "\tPOP AX\n";
							
						
						}
					//}
				}
			}

			
			
			string decName = $1->getName() + "(" + $3->getName() + ")";
			string decType = functionType;


			$$ = new symbolInfo(decName, decType);
			$$->setCode(code);
			$$->setCodeName(temp);

			logFile << "Line " << lineCount <<  " factor : ID LPAREN argument_list RPAREN\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| LPAREN expression RPAREN
		{
			string decName = "(" + $2->getName() + ")";
			string decType = $2->getType();


			$$ = new symbolInfo(decName, decType);
			$$->setCode($2->getCode());
			$$->setCodeName($2->getCodeName());

			logFile << "Line " << lineCount <<  " factor : LPAREN expression RPAREN\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| CONST_INT
		{
			$$ = yylval.symbol;
			$$->setCodeName(yylval.symbol->getName());
			logFile << "Line " << lineCount <<  " factor : CONST_INT\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| CONST_FLOAT
		{
			$$ = yylval.symbol;
			$$->setCodeName(yylval.symbol->getName());
			logFile << "Line " << lineCount <<  " factor : CONST_FLOAT\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| variable INCOP
		{
			string decName = $1->getName() + $2->getName();
			string decType = $1->getType();


			$$ = new symbolInfo(decName, decType);

			string code = "";
			string temp = tempVar();
			
			code +=  $1->getCode();
			code += "\tMOV AX, " + $1->getCodeName() + "\n";
			code += "\tMOV " + temp + ", AX\n";
			code += "\tINC " + $1->getCodeName() + "\n";

			$$->setCode(code);
			$$->setCodeName(temp);

			logFile << "Line " << lineCount <<  " factor : variable INCOP\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| variable DECOP
		{
			string decName = $1->getName() + $2->getName();
			string decType = $1->getType();


			$$ = new symbolInfo(decName, decType);

			string code = "";
			string temp = tempVar();
			
			code += $1->getCode();
			cout <<"13" <<$1->getCodeName() << "\n";

			code += "\tMOV AX, " + $1->getCodeName() + "\n";
			code += "\tMOV " + temp + ", AX\n";
			code += "\tDEC " + $1->getCodeName() + "\n";

			$$->setCode(code);
			$$->setCodeName(temp);

			logFile << "Line " << lineCount <<  " factor : variable DECOP\n\n";
			logFile << $$->getName() << "\n\n";
		}
	;

argument_list :	arguments
				{
					$$ = $1;
					logFile << "Line " << lineCount <<  " argument_list : arguments\n\n";
					logFile << $$->getName() << "\n\n";
				}
				|
				{
					$$ = new symbolInfo("", "void");
					$$->setCodeName("");
					logFile << "Line " << lineCount <<  " argument_list : \n\n";
					logFile << $$->getName() << "\n\n";
				}
			;

arguments : arguments COMMA logic_expression
			{
				string decName = $1->getName() + "," + $3->getName();
				string decType = $1->getType() + "," + $3->getType();
				string decAsmName = $1->getCodeName()	+ "," + $3->getCodeName();


				$$ = new symbolInfo(decName, decType);
				$$->setCode( $1->getCode() + $3->getCode());
				$$->setCodeName(decAsmName);

				
				logFile << "Line " << lineCount <<  " arguments : arguments COMMA logic_expression\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| logic_expression
			{
				$$ = $1;
				
				logFile << "Line " << lineCount <<  " arguments : logic_expression\n\n";
				logFile << $$->getName() << "\n\n";
			}
		;

%%
int main(int argc,char *argv[])
{
	if(argc!=2){
		cout << "Please provide input file name and try again\n";
		return 0;
	}
	
	inputFile = fopen(argv[1],"r");

	if(inputFile == nullptr){
		cout << "Cannot open specified file\n";
		return 0;
	}
	
	logFile.open("1805116_log.txt");
	errorFile.open("1805116_error.txt");
	
	yyin=inputFile;
	yyparse();

	// Logfile print
	symboltable.printAllScope(logFile);
	
	logFile << "Total lines: " << lineCount << "\n";
	logFile << "Total errors: " << errorCount << "\n";
	

	
	fclose(yyin);
	logFile.close();
	errorFile.close();
	return 0;
}




















	
