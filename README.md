# C--
## TDP019 Projekt: Datorspråk

```C--``` är ett programmeringsspråk som ingen någonsin bör använda. Dess syntax är inspirerad av ```C++``` med vissa inslag från ```Python```. Det är skapat till projektkursen TDP019 med ruby och rdparse. 

### Installation
För att ladda ned och använda språket, följ nedanstående instruktioner. **OBS!** Dessa instruktioner gäller endast för unix baserade system såsom MacOS eller Linux

För att kunna använda ```C--```, måste du först klona ner dess repo. Gör detta med följande kommando:
```Bash
git clone https://gitlab.liu.se/antno464/tdp019.git && cd tdp019
```
Därefter kör du följande kommando för att installera ```C--```:
```Bash
./install.sh
```
Nu är ```C--``` redo att användas. Om du vill ta bort det repo du laddat ned, kör då följande kommando efter installationen (kör inte kommandot om du önskar att behhålla repot på din dator):
```Bash
cd .. && rm -rf tdp019 && cd
```
### Användning
För att använda ```C--``` och exekvera en fil gör på då följande vis:
```Bash
cmm <file_name>.cmm
```
Säkerställ att du använder filändelsen ```.cmm``` på den filen som ska köras.

### Kom igång
Nu när du har installerat ```C--``` är det dags att skriva ditt första program. ```C--``` har en entrypoint i form av en main funktion. Det är enbart koden inuti denna funktion som kommer exekveras så säkerställ att du alltid skriver din kod i den. Main funktionen ska se ut följande:
```C
void codeGoBrrrrrrr(){
    // your code goes here
}
```
Main funktionen är av typen ```void``` och ska därför inte returnera något. Namnet på funktionen är strikt bestämmt till detta, men antallet 'r' i slutet av den är 
arbiträrt. Det måste dock vara minst 2 stycken 'r'. Detta är för att du själv ska få välja hur entusiastisk du är över din ```C--``` kod.

### Variabler
I ```C--``` finns alla variabeltyper du kan önska. Det finns stöd för ```int```, ```float```, ```bool```, ```char```, ```string``` och även ```array```.
För att skapa en variabel måste du specificera vilken datatyp den ska tillhöra. Denna variabel kan efter detta inte ändra typ vid annan tilldelning senare, utan 
tilldelning av nytt värde måste vara av samma typ. Se exempel på variabeltilldelning nedan:
```C
int i = 10;
float f = 3.14;
bool b = True;
char c = 'c';
string s = "Hello, World!";
```
Om du ska skapa en ```array``` måste du ange vilken datatyp den ska lagra. Detta görs med följande syntax:
```C
array<int> ai = [1, 2, 3];
array<char> ac = ['a', 'b', 'c'];
```
Om du redan skapat en variabel med ett visst värde men behöver ändra på detta värde senare, gör då så här:
```C
int i = 10;
i = 11;
```
Observera att konceptet av en ```const``` inte finns i ```C--``` så alla variabler går att tilldela ett nytt värde, så länge det nya värdet är av samma typ.

### If Satser
En ```if-sats``` skriver du på följande vis:
```C
if(i == 11){
    print("Detta är en if sats");
}
elif(i == 10){
    print("Värdet av i var visst inte 11");
}
else {
    print("Det var tydligen ingen av dem");
}
```
Som du kan se i exemplet ovan är dessa styrstrukurer mycket likt annat du känner igen från andra språk. Det som sticket ut lite är nyckelordet ```elif``` som
potentiellt kan kännas något främmande. 

### Loopar
I ```C--``` finns ```for```- och ```while```-loopar. Dessa fungerar både på det sätt du redan förväntar dig. Syntaxen för dem kommer inte heller vara särskillt 
främmande:
```C
int i = 0;
while(i < 10){
    // code go brrrrrrrr
    i++;
}

for(int c = 10; c > 10; c--){
    // code go brrrrrrrr
}
```
### Olika typer av "crement"
Som du kan se ovan finns det tillgång till increment och decrement i ```C--```. Dessa kan skrivas så som de ser ut i exempelkoden för looparna, men även på andra 
sätt. Se nedan:
```C
int i = 1;
i++; // => 2
i += 3; // => 5
i--; // => 4
i -= 4; // => 0
```
Utöver addition och subtraktion, finns dessa operatorer implementerade för fler matematiska operationer. Dessa kallar vi ```Multiment```, ```Diviment``` och 
```Potensiment```. Se syntax för dessa här:
```C
int i = 2;
i *= 3; // Multiment - => 6
int j = 10;
j /= 2; // Diviment - => 5
int k = 10;
k **= 3; // Potensiment - => 1000
```

