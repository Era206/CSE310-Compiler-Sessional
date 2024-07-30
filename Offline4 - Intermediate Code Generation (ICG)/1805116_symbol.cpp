#include <string>
#include <iostream>
#include <vector>
#include<bits/stdc++.h>
using namespace std;

class global_list{
    string var_name="";
    int var_size=0;
    public:
   
     global_list(){
        var_name = "";
        var_size = 0;
    }
    global_list(string pName, int pType)
    {
        /* data */
        var_name = pName;
        var_size = pType;
    }

    void setVarName(string Name){
        var_name= Name;
    }

    string getVarName(){
        return var_name;
    }

    void setVarSize(int size){
        var_size= size;
    }

    int getVarSize(){
        return var_size;
    }
    
};

class paramList{
    string paramName,paramType;


    public:
    paramList(){
        this->paramName = "";
        this->paramType = "";
    }
    paramList(string pName, string pType)
    {
        /* data */
        this->paramName = pName;
        this->paramType = pType;
    }

    void setParamName(string Name){
        this->paramName= Name;
    }

    string getParamName(){
        return this->paramName;
    }

    void setParamType(string Type){
        this->paramType= Type;
    }

    string getParamType(){
        return this->paramType;
    }
    

};

class symbolInfo{
    string name, type, code, codeName, inScopeName;
    symbolInfo *nextSymbol;

    int arrSize;
    vector<paramList> pList; //for function type symbol
    int extraType; //for normal symbol 0, for array 1, for function -1
    int funcDefinition;
    int isWrongFunction=0;
    string typeSymbol;
    int offset =0;
    

public:

    symbolInfo()
    {
        this->name = "";
        this->type = "";
        this->nextSymbol = nullptr;
        this->arrSize = 0;
        //this->pList = NULL;
        this->extraType = 0;
        this->funcDefinition = 0;
        this->typeSymbol="ID";
        this->offset=0;
        this->code="";
        this->codeName="";
        this->inScopeName="";

    }

    symbolInfo(string sName, string sType){
        this->name = sName;
        this->type = sType;
        this->nextSymbol = nullptr;
        this->arrSize = 0;
        //this->pList = NULL;
        this->extraType = 0;
        this->funcDefinition = 0;
         this->typeSymbol="ID";
         this->offset=0;
          this->code="";
        //this->codeName="";
        this->inScopeName="";
    }

    symbolInfo(symbolInfo* symbol){
        this->name = symbol->getName();
        this->type = symbol->getType();
        this->arrSize = symbol->getArrSize();
        this->nextSymbol = symbol->getNextSymbol();
        this->pList = symbol->getParamList();
        this->extraType = symbol->getExtraType();
        this->funcDefinition = symbol->getFunctionDefinition();
        this->typeSymbol=symbol->getTypeSymbol();
        this->offset = symbol->getOffset();
         this->code=symbol->getCode();
        this->codeName=symbol->getCodeName();
        this->inScopeName=symbol->getInScopeName();
    }

    int arraySymbol(string arrName, string arrType, int aSize){
        this->name = arrName;
        this->type = arrType;
        this->nextSymbol = nullptr;
        this->arrSize = aSize;
        this->extraType = 1;
        this->funcDefinition = 0;
         this->code="";
        this->codeName="";
       this->inScopeName="";
        return extraType;
    }

    int funcSymbol(string fName, string fType,vector<paramList> parList){
        this->name = fName;
        this->type = fType;
        this->nextSymbol = nullptr;
        this->arrSize = 0;
        this->pList = parList;
        this->extraType = -1;
        this->funcDefinition = 0;
         this->code="";
        this->codeName="";
        this->inScopeName="";
        return extraType;
    }

    ~symbolInfo()
    {

    }

    string getName(){
        return this->name;
    }

    void setName(string name){
        this->name = name;
    }

    string getType(){
        return this->type;
    }

    void setType(string type){
        this->type = type;
    }

    symbolInfo* getNextSymbol(){
        return this->nextSymbol;
    }

    void setNextSymbol(symbolInfo *symbol){
        this->nextSymbol = symbol;
    }

    void setArrSize(int aSize){
        this->arrSize = aSize;
    }

    int getArrSize(){
        return this->arrSize;
    }

    void addParameter(string pName, string pType){
        paramList parameter;
        parameter.setParamName(pName);
        parameter.setParamType(pType);
        this->pList.push_back(parameter);
    }

    vector<paramList> getParamList(){
        return this->pList;
    }

    int getParamListSize(){
        return this->pList.size();
    }

    int getExtraType(){
        return this->extraType; //returns 0 for default, 1 for array, -1 for function,2 for variable
    }

    void setExtraType(int type){
        this->extraType = type;
    }

    void setDefinition(int definition){
        this->funcDefinition = definition;
    }

    int getFunctionDefinition(){
        return this->funcDefinition;
    }

    void setParamList(vector<paramList> parameters){
        this->pList = parameters;
    }

    void setIsWrongFunction(int i){
        this->isWrongFunction = i;
    }

    int getIsWrongFunction(){
        return this->isWrongFunction;
    }

    string getTypeSymbol(){
        return this->typeSymbol;
    }

    void setTypeSymbol(string type){
        this->typeSymbol = type;
    }

    int getOffset(){
        return this->offset;
    }

    void setOffset(int val){
        this->offset=val;
    }
    
    string getCode(){
        return this->code;
    }

    void setCode(string str){
        this->code=str;
    }

    string getCodeName(){
        return this->codeName;
    }

    void setCodeName(string str){
        this->codeName = str;
    }

    string getInScopeName(){
        return this->inScopeName;
    }

    void  setInScopeName(string str){
        this->inScopeName= str;
    }

};

//--------scope-table---------//

class scopeTable
{
    int n;
    symbolInfo **symbols;
    int scopeSerial;
    scopeTable *parentScope;
    string id ="1";

    unsigned long sdbm(string str)
    {
        unsigned long hash = 0;

        for(int i=0;i<str.size();i++)
            hash = str[i] + (hash << 6) + (hash << 16) - hash;

        return hash%n;
    }
public:
    //constructor
    scopeTable(int n)
    {

        parentScope = nullptr;

        symbols= new symbolInfo*[n];
        scopeSerial=0;
        this->n=n;
        for(int i=0; i<n; i++)
        {
            symbols[i] = nullptr;
        }

    }
    //destructor
    ~scopeTable()
    {
        for(int i=0; i<n; i++){
            symbolInfo* symbol = symbols[i];
            symbolInfo* temp = new symbolInfo();
            while(symbol!=nullptr){
                temp=symbol;
                symbol= symbol->getNextSymbol();
                delete temp;
            }
        }

        delete[] symbols;
    }
    //set id
    void setId()
    {
        if(parentScope!=nullptr)
        this->id = parentScope->getID() + "."+ to_string(parentScope->getScopeSerial());
        else
            this->id = to_string(1);
    }
    //get id
    string getID()
    {

        return this->id;
    }
    //set scope serial
    void setScopeSerial()
    {
        //scopeSerial++;
        this->scopeSerial = this->scopeSerial+1;
    }
    //get scope serial
    int getScopeSerial()
    {
        return this->scopeSerial;
    }
    //set parent scope
    void setParentScope(scopeTable *scope)
    {
        this->parentScope = scope;
    }
    //get parent scope
    scopeTable* getparentScope()
    {
        return this->parentScope;
    }
    //look up/ search for a symbol
    symbolInfo* LookUp(string name, ofstream& logFile){
        int hashIndex = sdbm(name);
        int listSerial = 0;

        //case-1 no symbol in the particular hash index
        if(symbols[hashIndex]==nullptr) return nullptr;

        //case-2 found the symbol at first address pointed by the hash
        if(symbols[hashIndex]->getName()==name){
           // cout << "Found in ScopeTable# "<< getID()<<" at position " << to_string(hashIndex) <<", " << to_string(listSerial) << endl;
            return symbols[hashIndex];
        }

        //case-3 linear search through the pointer list
        listSerial+=1;
        symbolInfo *s = new symbolInfo;
        s = symbols[hashIndex]->getNextSymbol();
        while(s!=nullptr){
            if(s->getName()==name){
                //cout <<"Found in ScopeTable# "<< getID()<<" at position " << hashIndex <<", " << listSerial <<endl;
                return s;
            }
            listSerial++;
            s = s->getNextSymbol();
        }
        return nullptr;

    }
    //insert a symbol (with name and type) in scope table
    bool Insert(string name, string type, ofstream& logFile){
        int hashIndex = sdbm(name);

        if(LookUp(name, logFile)!=nullptr){
            return false;
        }

        //check if the symbol already exist
       /* if(symbols[hashIndex]!=nullptr){
        //cout << "<" + name << "," << type +"> already exists in current ScopeTable\n";
        return false;
        }*/

        int listSerial = 0;
        //case-1 no symbol in the particular hash index
        if(symbols[hashIndex]==nullptr){

            symbolInfo *symbol = new symbolInfo();
            symbol->setName(name);
            symbol->setType(type);
            symbol->setNextSymbol(nullptr);
            

            symbols[hashIndex] = symbol;

            //cout << "Inserted in ScopeTable# "+ getID() + " at position " + to_string(hashIndex) + ", " + to_string(listSerial)  <<endl;
            return true;
    }
    //case-2 linear search through the pointer list
    else{

        symbolInfo *s1 = new symbolInfo();
        s1 = symbols[hashIndex];
        symbolInfo *s2 = new symbolInfo();
        s2 = s1->getNextSymbol();
        symbolInfo *symbol = new symbolInfo();

        while(s2!=nullptr){

            s1=s2;
            s2=s1->getNextSymbol();
            listSerial++;
        }

        symbol->setName(name);
        symbol->setType(type);
        symbol->setNextSymbol(nullptr);
        s2=symbol;
        s1->setNextSymbol(s2);

        listSerial++;
        //cout << "Inserted in ScopeTable# "+ getID() + " at position " + to_string(hashIndex) + ", " + to_string(listSerial) << endl;
            return true;

    }
    return false;
        }


    //insert a symbol in scope table
    bool InsertSymbol(symbolInfo symbolinfo, ofstream& logFile){
        int hashIndex = sdbm(symbolinfo.getName());

        //check if the symbol already exist
        /*if(symbols[hashIndex]!=nullptr){
        logFile << " already exists in current ScopeTable\n";

        return false;
        }*/
        if(LookUp(symbolinfo.getName(), logFile)!=nullptr){
            return false;
        }

        int listSerial = 0;
        //case-1 no symbol in the particular hash index
        if(symbols[hashIndex]==nullptr){
            //logFile << "it's in if\n\n";
            symbolInfo *symbol = new symbolInfo();
            symbol->setName(symbolinfo.getName());
            symbol->setType(symbolinfo.getType());
            symbol->setNextSymbol(nullptr);
            symbol->setArrSize(symbolinfo.getArrSize());
            symbol->setParamList(symbolinfo.getParamList());
            symbol->setDefinition(symbolinfo.getFunctionDefinition());
            symbol->setExtraType(symbolinfo.getExtraType());
       
       
            symbols[hashIndex] = symbol;

            //cout << "Inserted in ScopeTable# "+ getID() + " at position " + to_string(hashIndex) + ", " + to_string(listSerial)  <<endl;
            return true;
    }
    //case-2 linear search through the pointer list
    else{
        //logFile <<"it's in else\n\n";
        symbolInfo *s1 = new symbolInfo();
        s1 = symbols[hashIndex];
        symbolInfo *s2 = new symbolInfo();
        s2 = s1->getNextSymbol();
        symbolInfo *symbol = new symbolInfo();

        while(s2!=nullptr){

            s1=s2;
            s2=s1->getNextSymbol();
            listSerial++;
        }

        /*symbol->setName(symbolinfo.getName());
        symbol->setType(symbolinfo.getType());
        symbol->setNextSymbol(nullptr);*/
        symbol->setName(symbolinfo.getName());
        symbol->setType(symbolinfo.getType());
        symbol->setNextSymbol(nullptr);
        symbol->setArrSize(symbolinfo.getArrSize());
        symbol->setParamList(symbolinfo.getParamList());
        symbol->setDefinition(symbolinfo.getFunctionDefinition());
        symbol->setExtraType(symbolinfo.getExtraType());
        s2=symbol;
        s1->setNextSymbol(s2);

        listSerial++;
        //cout << "Inserted in ScopeTable# "+ getID() + " at position " + to_string(hashIndex) + ", " + to_string(listSerial) << endl;
            return true;

    }
    return false;
        }


    bool Delete(string name, ofstream& logFile){
        int hashIndex = sdbm(name);
        //if symbol not found
        if(symbols[hashIndex]==nullptr){
            //cout << name + " Not Found\n";
            return false;
        }

        int listSerial = 0;

        //case-1 found in first pointer of list
        if(symbols[hashIndex]->getName()==name){
            //cout <<"Found in ScopeTable# "<< getID()<<" at position " << hashIndex <<", " << listSerial <<endl;
           if(symbols[hashIndex]->getNextSymbol()==nullptr){
            symbols[hashIndex]=nullptr;
           }
           else{
            symbols[hashIndex]=symbols[hashIndex]->getNextSymbol();
           }
        //cout << "Deleted Entry " <<hashIndex<<", " <<listSerial<<" from current ScopeTable"<<endl;
        return true;
        }

        //case-2 linear search through the pointer list
        else{
        symbolInfo *s1 = new symbolInfo();
        s1 = symbols[hashIndex];
        symbolInfo *s2 = new symbolInfo();
        s2 = symbols[hashIndex]->getNextSymbol();
        while(s2!=nullptr){
            listSerial++;
            if(s2->getName()==name){
                //cout <<"Found in ScopeTable# "<< getID()<<" at position " << hashIndex <<", " << listSerial <<endl;
                if(s2->getNextSymbol()==nullptr)
                    s1->setNextSymbol(nullptr);
                else s1->setNextSymbol(s2->getNextSymbol());
                //cout << "Deleted Entry " <<hashIndex<<", " <<listSerial<<" from current ScopeTable"<<endl;
                return true;
            }
            s1=s2;
            s2=s1->getNextSymbol();

        }
        //cout << name + " Not Found\n";
        return false;

    }

    }

    void printScopeTable(ofstream& logFile){
        logFile << "ScopeTable # " << getID() << endl;
        for(int i=0; i<n; i++){
            symbolInfo *symbol = nullptr;
            symbol = symbols[i];
            if(symbol!=nullptr){
                logFile << i << "-->" ;
            while(symbol!=nullptr){
                logFile << " < " << symbol->getName() << " : " << symbol->getTypeSymbol() <<">";
                symbol = symbol->getNextSymbol();
            }
            logFile << "\n";
            }
        }
        logFile << "\n\n\n";
    }

    };

//------symboltable------//

class symbolTable
{

    scopeTable* currentScope;
    int n;
    int scopeCount=0;
public:
    symbolTable(int n)
    {
        //currentScope=nullptr;
        currentScope = new scopeTable(n);
        this->n=n;
        //enterScope();

    }
    ~symbolTable(){

    }
    //enter new scope under currentscope
    void enterScope(){
        scopeCount++;

        scopeTable* scope = new scopeTable(n);

        if(currentScope==nullptr){

            currentScope = scope;
            currentScope->setParentScope(nullptr);
            currentScope->setId();
        }
        else{
            currentScope->setScopeSerial();
            scope->setParentScope(currentScope);
            currentScope = scope;
            currentScope->setId();
            //cout << "New ScopeTable with id "+ currentScope->getID()+" created" << endl;
        }

    }
    //exit the innermost scope, won't change the scope serial for next scope entry
    void exitScope(){
    if(currentScope==nullptr){
        //cout <<"NO CURRENT SCOPE" << endl;
        return;
    }
    scopeTable* scope = currentScope->getparentScope();
    //cout << "ScopeTable with id " + currentScope->getID() + " removed\n";
    delete currentScope;
    currentScope = scope;
    //scopeCount--;
    }
    //insert symbol in current scope
    bool insertCurrScope(string name, string type, ofstream& logFile){
        if(currentScope==nullptr){
            scopeTable* scope = new scopeTable(n);
            currentScope = scope;
            currentScope->setParentScope(nullptr);
            currentScope->setId();

        }
        return currentScope->Insert(name, type, logFile);
    }
    
    bool insertCurrSymbolInfo(symbolInfo symbol, ofstream& logFile)
    {
       // logFile << "done\n";
        return currentScope->InsertSymbol(symbol, logFile);
    }

    //remove symbol in current scope
    bool removeCurrScope(string name, ofstream& logFile){
        bool flag = currentScope->Delete(name,logFile);
        if(flag==false){
           // cout<<"Not found" << endl;
        }
        return flag;
    }
    //look up from current scope to root parent scope
    symbolInfo* lookUpScope(string name, ofstream& logFile){
        scopeTable* scope = currentScope;
        symbolInfo* symbol = new symbolInfo();
        while(scope != nullptr){
        symbol = scope->LookUp(name,logFile);
        if(symbol != nullptr){
            return symbol;
        }
        scope = scope->getparentScope();
    }

    return nullptr;
    }
    //print current scope table
    void printCurrScope(ofstream& logFile){
        currentScope->printScopeTable(logFile);
    }
    //print all scope table
    void printAllScope(ofstream& logFile){
        scopeTable* scope = currentScope;
        while(scope!=nullptr){
            scope->printScopeTable(logFile);
            scope=scope->getparentScope();
        }
    }

    int getCurrentScope(){
        return this->scopeCount;
    }

};

