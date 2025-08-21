# Tasks

Un task este definit prin
- taskId - unic, dat de server sau negativ daca e obtinut optimistic
- categoryId
- content
- isRecurring
- diamonds
- isDone

Un state este definit printr-o lista de taskuri, un bool isLoading si un mesaj nullable de erorare

### Idei Generale
- Stateul taskurilor trebuie sa nu depinda de zi deoarce vreau sa pot sa CRUD taskuri si dintr-o luna sau total, nu doar dintr-o zi
- Un task nu poate exista fara o zi asociata, decat in cazul in care a fost sters din acea zi

### Cand apare
- Apare in pagina unei zile - apar doar taskurile zilei curente. Intai apar taskurile nefacute, apoi taskurile facute.
- Apare in pagina unei luni, atunci cand userul apasa pe 'see all tasks'. Taskurile vor fi legate de luna selectata, in acea pagina userul poate selecta alte luni pentru a vedea taskurile lor. Aici se pot adauga taskuri upcoming. In aceasta pagina, taskurile apar astfel:
    - Apar taskurile zilei curente, care inca pot fi facute (nu pot fi completate aici). Asta doar daca luna selectata e luna curenta
    - Apar toate taskurile care nu mai pot fi facute din luna curenta, in ordinea datii
    - Apar toate taskurile facute din luna curenta, in ordinea datii

## Cum poate interactiona userul cu stateul
### Poate crea un task nou
- Foloseste dayId - ziua la care sa adauge taskul, categoryId, content, isRecurring si diamonds
- Daca flagul isLoading e true, nu face nimic, dar da eroare
- Este de tip optimist, adica este bagat in state imediat, dar cu un id negativ, iar abia dupa ce usecaseul a returnat, daca e successful se schimba id-ul, daca nu, se scoate
- Daca creaza taskul intr-o pagina de zi, dayIdul ca fi idul zilei curente, userul nici nu va mai fi intrebat
- Daca creaza taskul in pagina de taskuri, userul va fi intrebat in ce zi din acea luna vrea sa adauge taskul
- Daca cumva, dupa ce returneaza usecaseul, taskul nu mai apare printre taskurile selectate, nu face nimic

### Poate initializa taskurile unei noi zile
- Foloseste dayId - ziua care se initializeaza
- In pagina de luna, atunci cand nu este prezenta ziua curenta, userul poate sa o adauge printr-un buton
- Stateul va fi intai loading, apoi va avea taskurile acelei zile
- Daca o zi este deja initializata, nu mai poate fi initializata inca o data

### Poate citi taskurile unei zile
- Foloseste dayId - ziua pentru care citeste
- Stateul va fi intai loading, apoi va avea taskurile acelei zile

### Poate updata un task
- Foloseste taskId, categoryId, content, isRecurring, diamonds
- Daca flagul isLoading e true, nu face nimic, dar da eroare
- Se updateaza taskul generic, insemnand ca la taskurile recurring se updateaza toate din toate zilele
- Efectul este acelasi indiferent daca e updatat din pagina unei zile sau din pagina de taskuri
- Este de tip optimist, adica este updatat imediat, dar abia dupa ce usecaseul a returnat, daca e successful nu se face nimic, daca nu este, se scoate
- Daca cumva taskId-ul nu apare printre taskurile selectate, nu face nimic optimistic si returneaza eroare
- Daca cumva, dupa ce returneaza usecaseul, taskul nu mai apare printre taskurile selectate, nu face nimic, nu returneaza eroare

### Poate sterge un task
- Foloseste dayId?, taskId, isRecurring
- Daca se sterge din pagina de taskuri (dayId este null), atunci taskul se sterge de tot (red warning inainte)
- Daca se sterge din pagina unei zile (dayId nu este null), dar taskul nu este recurring, se sterge doar din acea zi (yellow warning care spune ca taskul va fi inca vizibil in tasks page)
- Daca se sterge din pagina unei zile, iar taskul este recurring, atunci se sterge doar din acea zi si nu mai este recurring
- Este de tip optimist, adica este sters imediat, dar abia dupa ce usecaseul a returnat, daca e successful nu se face nimic, daca nu este, se adauga la loc
- Daca cumva taskId-ul nu apare printre taskurile selectate, nu face nimic optimistic
- Daca cumva, dupa ce returneaza usecaseul, taskul nu mai apare printre taskurile selectate, nu face nimic

### Poate seta un task drept completat sau nu
- Foloseste dayId, taskId, completed
- Este de tip optimist, adica se seteaza imediat, dar abia dupa ce usecaseul a returnat, daca e successful nu se face nimic, daca nu este, se reseteaza
- Daca cumva taskId-ul nu apare printre taskurile selectate, nu face nimic optimistic
- Daca cumva, dupa ce returneaza usecaseul, taskul nu mai apare printre taskurile selectate, nu face nimic


## De tinut minte pentru viitoare updateuri
- Daca imediat dupa ce a creat taskul, userul iese din acea pagina si taskurile stateului nou nu mai contin taskul creat, atunci nu se updateaza nimic

