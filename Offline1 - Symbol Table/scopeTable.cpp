#include "symbolInfo.cpp"
#include<string>
#include<iostream>
using namespace std;

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
    symbolInfo* LookUp(string name){
        int hashIndex = sdbm(name);
        int listSerial = 0;

        //case-1 no symbol in the particular hash index
        if(symbols[hashIndex]==nullptr) return nullptr;

        //case-2 found the symbol at first address pointed by the hash
        if(symbols[hashIndex]->getName()==name){
            cout << "Found in ScopeTable# "<< getID()<<" at position " << to_string(hashIndex) <<", " << to_string(listSerial) << endl;
            return symbols[hashIndex];
        }

        //case-3 linear search through the pointer list
        listSerial+=1;
        symbolInfo *s = new symbolInfo;
        s = symbols[hashIndex]->getNextSymbol();
        while(s!=nullptr){
            if(s->getName()==name){
                cout <<"Found in ScopeTable# "<< getID()<<" at position " << hashIndex <<", " << listSerial <<endl;
                return s;
            }
            listSerial++;
            s = s->getNextSymbol();
        }
        return nullptr;

    }
    //insert a symbol in scope table
    bool Insert(string name, string type){
        int hashIndex = sdbm(name);

        //check if the symbol already exist
        if(symbols[hashIndex]=nullptr){
        cout << "<" + name << "," << type +"> already exists in current ScopeTable\n";
        return false;
        }

        int listSerial = 0;
        //case-1 no symbol in the particular hash index
        if(symbols[hashIndex]==nullptr){

            symbolInfo *symbol = new symbolInfo();
            symbol->setName(name);
            symbol->setType(type);
            symbol->setNextSymbol(nullptr);

            symbols[hashIndex] = symbol;

            cout << "Inserted in ScopeTable# "+ getID() + " at position " + to_string(hashIndex) + ", " + to_string(listSerial)  <<endl;
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
        cout << "Inserted in ScopeTable# "+ getID() + " at position " + to_string(hashIndex) + ", " + to_string(listSerial) << endl;
            return true;

    }
    return false;
        }

    bool Delete(string name){
        int hashIndex = sdbm(name);
        //if symbol not found
        if(symbols[hashIndex]==nullptr){
            cout << name + " Not Found\n";
            return false;
        }

        int listSerial = 0;

        //case-1 found in first pointer of list
        if(symbols[hashIndex]->getName()==name){
            cout <<"Found in ScopeTable# "<< getID()<<" at position " << hashIndex <<", " << listSerial <<endl;
           if(symbols[hashIndex]->getNextSymbol()==nullptr){
            symbols[hashIndex]=nullptr;
           }
           else{
            symbols[hashIndex]=symbols[hashIndex]->getNextSymbol();
           }
        cout << "Deleted Entry " <<hashIndex<<", " <<listSerial<<" from current ScopeTable"<<endl;
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
                cout <<"Found in ScopeTable# "<< getID()<<" at position " << hashIndex <<", " << listSerial <<endl;
                if(s2->getNextSymbol()==nullptr)
                    s1->setNextSymbol(nullptr);
                else s1->setNextSymbol(s2->getNextSymbol());
                cout << "Deleted Entry " <<hashIndex<<", " <<listSerial<<" from current ScopeTable"<<endl;
                return true;
            }
            s1=s2;
            s2=s1->getNextSymbol();

        }
        cout << name + " Not Found\n";
        return false;

    }

    }

    void printScopeTable(){
        cout << "ScopeTable # " << getID() << endl;
        for(int i=0; i<n; i++){
            cout << i << "-->" ;
            symbolInfo *symbol = nullptr;
            symbol = symbols[i];
            while(symbol!=nullptr){
                cout << " < " << symbol->getName() <<" : "<< symbol->getType() <<">";
                symbol = symbol->getNextSymbol();
            }
            cout << endl;
        }
        cout << endl << endl << endl;
    }

    };






