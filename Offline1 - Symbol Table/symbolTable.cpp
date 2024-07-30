#include "scopeTable.cpp"
#include<string>
#include<iostream>
using namespace std;

class symbolTable
{

    scopeTable* currentScope;
    int n;
public:
    symbolTable(int n)
    {
        currentScope=nullptr;
        this->n=n;
        enterScope();

    }
    ~symbolTable(){

    }
    //enter new scope under currentscope
    void enterScope(){

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
            cout << "New ScopeTable with id "+ currentScope->getID()+" created" << endl;
        }

    }
    //exit the innermost scope, won't change the scope serial for next scope entry
    void exitScope(){
    if(currentScope==nullptr){
        cout <<"NO CURRENT SCOPE" << endl;
        return;
    }
    scopeTable* scope = currentScope->getparentScope();
    cout << "ScopeTable with id " + currentScope->getID() + " removed\n";
    delete currentScope;
    currentScope = scope;
    }
    //insert symbol in current scope
    bool insertCurrScope(string name, string type){
        if(currentScope==nullptr){
            scopeTable* scope = new scopeTable(n);
            currentScope = scope;
            currentScope->setParentScope(nullptr);
            currentScope->setId();

        }
        return currentScope->Insert(name, type);
    }
    //remove symbol in current scope
    bool removeCurrScope(string name){
        bool flag = currentScope->Delete(name);
        if(flag==false){
            cout<<"Not found" << endl;
        }
        return flag;
    }
    //look up from current scope to root parent scope
    symbolInfo* lookUpScope(string name){
        scopeTable* scope = currentScope;
        symbolInfo* symbol = new symbolInfo();
        while(scope != nullptr){
        symbol = scope->LookUp(name);
        if(symbol != nullptr){
            return symbol;
        }
        scope = scope->getparentScope();
    }

    return nullptr;
    }
    //print current scope table
    void printCurrScope(){
        currentScope->printScopeTable();
    }
    //print all scope table
    void printAllScope(){
        scopeTable* scope = currentScope;
        while(scope!=nullptr){
            scope->printScopeTable();
            scope=scope->getparentScope();
        }
    }

};
