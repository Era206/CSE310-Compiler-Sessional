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
FILE* inputFile;
symbolTable symboltable(7);


int lineCount=1;
int errorCount=0;
int lineTrack = 0;
int isWrongFunction = 0;
string returnType = "UNKNOWN";
int voidVal = 0;
int voidLine=0;
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

									if(flag==0){
										symbolInfo* si = symboltable.lookUpScope(functionName, logFile);
										si->funcSymbol(functionName, functionType, foundParamList);
										si->setDefinition(1);

										symboltable.removeCurrScope(functionName, logFile);
										symboltable.insertCurrSymbolInfo(si, logFile);
									

										symboltable.enterScope();


										//bool  = false;
										for (int i=0; i <foundParamList.size(); i++)
										{
											bool isExist = symboltable.insertCurrScope(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType(), logFile);

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
							
							errorFile << "Error at line " << lineCount << " : Multiple declaration of  '" << functionName << "'\n\n";
							logFile << "Error at line " << lineCount << " : Multiple declaration of  '" << functionName << "'\n\n";
							errorCount++;
							lineTrack=lineCount;
							isWrongFunction=1;
							symboltable.enterScope();
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
											bool isExist = symboltable.insertCurrScope(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType(), logFile);

											if (!isExist)
											{
												logFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() <<"' in parameter\n\n";
												errorFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() << "' in parameter\n\n";
												errorCount++;
												lineTrack=lineCount;
											}
										}
							
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


						for (int i=0; i < foundParamList.size(); i++)
						{
							//logFile << "int a, int b ekhane jabe \n\n";
							bool isExist = symboltable.insertCurrScope(foundParamList.at(i).getParamName(), foundParamList.at(i).getParamType(), logFile);
							//logFile << "int a, int b ekhane jabe \n\n";

									if (!isExist)
									{
										logFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() << "' in parameter\n\n";
										errorFile << "Error at line " << lineCount << " : Multiple declaration of '" << foundParamList.at(i).getParamName() << "' in parameter\n\n";
										errorCount++;
										lineTrack=lineCount;
										isWrongFunction=1;
									}
						}
						
					}
					if(isWrongFunction==1) $2->setIsWrongFunction(1);
				}
				compound_statement
				{
					
					//here $7 is statements covered by lcurl & rcurl
					
					string decName = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")"  + $7->getName() + "\n";
					string decType = "func_definition";

					//if(isWrongFunction==1) $7->setName("{}");

					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n";
					logFile << $$->getName() << "\n\n";	
					
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
					string decName = $1->getName() + " " + $2->getName() + "()" + $6->getName() + "\n";
					string decType = "func_definition";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n";
					logFile << $$->getName() << "\n\n";	
					
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
								//logFile <<" check if array declaration works!\n\n";
							}
							else
							{
								
								variableSymbol.setName(variable);
								variableSymbol.setType(variableType);
							}

							//	check if Multiple declaration of variable
							bool insert = symboltable.insertCurrSymbolInfo(variableSymbol, logFile);

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
			}
			| { symboltable.enterScope(); } compound_statement 
			{
				$$ = $2;
				logFile << "Line " << lineCount <<  " statement : compound_statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| FOR LPAREN expression_statement expression_statement expression RPAREN statement
			{
				string decName = "for(" + $3->getName() + $4->getName() + $5->getName() + ")" + $7->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);

				logFile << "Line " << lineCount <<  " statement : IF LPAREN expression_statement expression_statement expression RPAREN statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
			{
				string decName = "if(" + $3->getName() + ")" + $5->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);

				logFile << "Line " << lineCount <<  " statement : IF LPAREN expression RPAREN statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| IF LPAREN expression RPAREN statement ELSE statement
			{
			
				string decName = "if(" + $3->getName() + ")" + $5->getName() + "else" + $7->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);

				logFile << "Line " << lineCount <<  " statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| WHILE LPAREN expression RPAREN statement
			{
				string decName = "while(" + $3->getName() + ")" + $5->getName();
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);

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
				
				string decName = "printf(" + $3->getName() + ");";
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);

				logFile << "Line " << lineCount <<  " statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n";
				logFile << $$->getName() << "\n\n";
			}
			| RETURN expression SEMICOLON
			{
			

				/*if (returnType == "void")
				{
					returnType = "UNKNOWN";
					
					logFile << "Error at line " << lineCount << " : Function type void can't have a return statement\n\n";
					errorFile << "Error at line " << lineCount << " : Function type void can't have a return statement\n\n";
					errorCount++;
					lineTrack=lineCount;

				}*/

				
				string decName = "return " + $2->getName() + ";";
				string decType = "statement";


				$$ = new symbolInfo(decName, decType);

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
						$$->setName(currentVarId->getName());
						$$->setType(currentVarId->getType());
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

				
		
				string decName = $1->getName() + $2->getName() + $3->getName();
				string decType = "expression";


				$$ = new symbolInfo(decName, decType);

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

						
						string decName = $1->getName() + $2->getName() + $3->getName();
						string decType = operateType;


						$$ = new symbolInfo(decName, decType);

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
				
					//	The result of RELOP and LOGICOP should be INTEGER as 2<3 will give result 1, again 2>3 will give result 0, which are integer
					string decName = $1->getName() + $2->getName() + $3->getName();
					string decType ="int";


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " rel_expression : simple_expression RELOP simple_expression\n\n";
					logFile << $$->getName() << "\n\n";
				}
			;

simple_expression :	term
					{
						$$ = $1;
						logFile << "Line " << lineCount <<  " simple_expression : term\n\n";
						logFile << $$->getName() << "\n\n";
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

						string decName = $1->getName() + $2->getName() + $3->getName();
						string decType = expressionType;


						$$ = new symbolInfo(decName, decType);

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
			

			string decName = $1->getName() + $2->getName() + $3->getName();
			string decType = expressionType;


			$$ = new symbolInfo(decName, decType);

			logFile << "Line " << lineCount <<  " term : term MULOP unary_expression\n\n";
			logFile << $$->getName() << "\n\n";
		}
	;

unary_expression: ADDOP unary_expression
				{
					string decName = $1->getName() + $2->getName();
					string decType = $2->getType();


					$$ = new symbolInfo(decName, decType);

					logFile << "Line " << lineCount <<  " unary_expression : ADDOP unary_expression\n\n";
					logFile << $$->getName() << "\n\n";
				}
				| NOT unary_expression
				{
					string decName = $1->getName() + $2->getName();
					string decType = $2->getType();


					$$ = new symbolInfo(decName, decType);

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

					/*if(voidLine==lineCount && voidVal==1){
							logFile << "Error at line " << lineCount << " : Void function can't be used as factor\n\n";
							errorFile << "Error at line " << lineCount << " : Void function can't be used as factor\n\n";
							errorCount++;
							lineTrack=lineCount;
							voidLine=0;
							voidVal=0;
							errorFile << "he\n\n";
						}*/
					
					//check if the return type is void
					/*if (functionType == "void")
					{
						
						logFile << "Error at line " << lineCount << " : Void function can't be used as factor\n\n";
						errorFile << "Error at line " << lineCount << " : Void function can't be used as factor\n\n";
						errorCount++;
						//errorFile << "hello\n\n";
						voidLine=lineCount;
							lineTrack=lineCount;
							voidVal=1;
					}*/
						
						/*else{
							voidLine=lineCount;
							//lineTrack=lineCount;
							voidVal=1;
						}

					}*/
					


					//else
					//{
						
						vector<string> argumentNames = parseString($3->getName(), ',');
						vector<string> argumentTypes = parseString($3->getType(), ',');

						
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
						}
					//}
				}
			}
			
			string decName = $1->getName() + "(" + $3->getName() + ")";
			string decType = functionType;


			$$ = new symbolInfo(decName, decType);

			logFile << "Line " << lineCount <<  " factor : ID LPAREN argument_list RPAREN\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| LPAREN expression RPAREN
		{
			string decName = "(" + $2->getName() + ")";
			string decType = $2->getType();


			$$ = new symbolInfo(decName, decType);

			logFile << "Line " << lineCount <<  " factor : LPAREN expression RPAREN\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| CONST_INT
		{
			$$ = yylval.symbol;
			logFile << "Line " << lineCount <<  " factor : CONST_INT\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| CONST_FLOAT
		{
			$$ = yylval.symbol;
			logFile << "Line " << lineCount <<  " factor : CONST_FLOAT\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| variable INCOP
		{
			string decName = $1->getName() + $2->getName();
			string decType = $1->getType();


			$$ = new symbolInfo(decName, decType);

			logFile << "Line " << lineCount <<  " factor : variable INCOP\n\n";
			logFile << $$->getName() << "\n\n";
		}
		| variable DECOP
		{
			string decName = $1->getName() + $2->getName();
			string decType = $1->getType();


			$$ = new symbolInfo(decName, decType);

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
					logFile << "Line " << lineCount <<  " argument_list : \n\n";
					logFile << $$->getName() << "\n\n";
				}
			;

arguments : arguments COMMA logic_expression
			{
				string decName = $1->getName() + "," + $3->getName();
				string decType = $1->getType() + "," + $3->getType();

				$$ = new symbolInfo(decName, decType);

				
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




















	
