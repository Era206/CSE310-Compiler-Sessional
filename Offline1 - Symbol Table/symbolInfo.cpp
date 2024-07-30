#include<string>
#include<iostream>
using namespace std;


class symbolInfo{
    string Name, Type;
    symbolInfo *nextSymbol;
public:

    symbolInfo()
    {

    }

    ~symbolInfo()
    {

    }
    string getName(){
        return this->Name;
    }
    void setName(string name){
        this->Name = name;
    }

    string getType(){
        return this->Type;
    }
    void setType(string type){
        this->Type = type;
    }

    symbolInfo* getNextSymbol(){
        return this->nextSymbol;
    }
    void setNextSymbol(symbolInfo *symbol){
        this->nextSymbol = symbol;
    }

};
