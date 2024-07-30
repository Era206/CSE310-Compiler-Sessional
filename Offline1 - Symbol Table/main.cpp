#include <bits/stdc++.h>
#include "symbolTable.cpp"
#include <fstream>
using namespace std;


int main()
{
    freopen("input-1.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    char op;
    int n;
    bool flag;
    cin >> n;
    symbolTable* table=new symbolTable(n);
    while(cin >> op){
        if(op == 'I'){
            string name, type;
            cin >> name >> type;
            cout << op << " " << name << " " << type << "\n\n";
            flag = table->insertCurrScope(name,type);
            cout << endl;
        }
        else if(op == 'S'){
            cout << op << "\n\n";
            table->enterScope();
            cout << endl;
        }
        else if(op == 'E'){
            cout << op << "\n\n";
            table->exitScope();
            cout << endl;
        }
        else if(op == 'L'){
            string name;
            cin >> name;
            cout << op << " " << name << "\n\n";
            table->lookUpScope(name);
            cout << endl;
        }
        else if(op == 'D'){
            string name;
            cin >> name;
            cout << op << " " << name << "\n\n";
            flag = table->removeCurrScope(name);
            cout << endl;
        }
        else if(op == 'P'){
            char op1;
            cin >> op1;
            cout << op << " " << op1 << "\n\n\n";
            if(op1 == 'A')
                table->printAllScope();
            else if(op1 == 'C')
                table->printCurrScope();
            cout << endl;
        }
    }
    return 0;
}
