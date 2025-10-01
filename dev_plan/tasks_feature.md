# Tasks

Un task este definit prin
- int taskId - unic, dat de server sau negativ daca e obtinut optimistic
- int categoryId
- String content
- bool isStarred
- TaskType taskType - repeatDaily | secondChance | plain
- int? dayTaskId - unic, dat se server, sau negativ daca e obtinut optimistic
- TaskDoneType taskDoneType - notDone | notGreat | onPoint | awesome
- List? of SubtaskEntity subtasks
- int? taskImportance
- int? effortRequired
- int? timeRequired
- int? notGreatDiamonds
- int? onPointDiamonds
- int? awesomeDiamonds
- int? dueTimeInMinutes
- int? notifyTimeInMinutes

Un state este definit prin:
- o lista de taskuri
- un bool isLoading - controlat de getTasks, nu de create / delete / update
- un mesaj nullable de eroare

### Idei Generale
- Un task poate sa nu aiba diamante pentru a face crearea taskului extrem de usoara. In acel caz, este doar un reminder
- Taskurile completate nu pot fi de-completate
- In dataSource si in crearea taskului se folosesc isDailyTask si isSecondChanceTask, dar in entitate apar drept taskType
- Atunci cand se initializeaza o zi se iau:
  - Taskurile care au fost puse in acea zi
  - Taskurile care sunt dailyTasks din ziua trecuta
  - Taskurile din ziua trecuta care nu sunt dailyTasks, nu sunt secondChance si nu au fost facute
- Taskurile vor fi salvate doar local
- Stocarea taskurilor va fi impartita in 2 tabele:
   - Tasks - reprezinta taskuri generale, care nu sunt asociate unei zile si pot fi folosite de mai multe ori
     - int? taskId
     - int categoryId
     - String content
     - int isStarred - casted to bool
     - int isDailyTask - casted to bool
   - DayTasks - reprezinta o intrare a unui task intr-o zi. O zi poate sa aiba mai multe taskuri cu acelasi taskId
     - int? dayTaskId
     - String dayId
     - int taskId
     - int taskDoneType - casted to TaskDoneType
     - int isSecondChance - casted to bool
     - String? encodedSubtasks - 'subtask1~done1^subtask2~done2'
     - int? taskImportance
     - int? effortRequired
     - int? timeRequired
     - int? notGreatDiamonds
     - int? onPointDiamonds
     - int? awesomeDiamonds
     - int? dueTimeInMinutes
     - int? notifyTimeInMinutes

## Elemente importante

### CompletableTaskWidget
Accepta un taskEntity, primaryColor, secondaryColor, onTaskToggled, onSubtaskToggled, onClaimDiamonds, onEdit?, onDelete?
Un task va arata astfel:
- Va avea drept cheie dayTaskId
- Va ocupa tot width-ul, va avea forma de dreptunghi cu rounded corners si va avea culoarea secundara a category-ului
- In partea de sus, stanga, va avea tipul lui cu un icon sau doneType cu icon (daily task, second chance, reminder, regular task)
- In partea de sus, dreapta, va avea fie dueTime daca este valabil, fie importance daca este 4 sau 5 sau mai putin de 5 minute, iar in partea dreapta fara padding, va fi un colt care apare doar daca este starred
- La mijloc, in stanga va avea contentul si in dreapta diamantele onPoint sau diamantele luate daca taskul e facut
- Daca taskul are subtaskuri, vor aparea ca checkboxuri sub content. Taskul poate fi completat doar cand toate checkboxurile sunt completate, caz in care se da complete automat
- Cand userul da scroll in stanga se activeaza editul daca nu e null
- Cand userul da scroll in dreapta se activeaza deleteul daca nu e null
- Cand userul apasa pe el, daca nu are subtaskuri, are loc o animatie subtila in care se micsoreaza
- Cand taskul se completeaza, se roteste in jos, apare Completed cu un icon pentru putin timp, apoi, daca taskul are diamante, userul este cerut sa spuna daca a facut onPoint, notGreat sau awesome. Dupa ce selecteaza sau daca nu are diamante, taskul dispare prin fade, scale down si animatie de shrink.

### SelectableTaskWidget
Exact la fel ca CompletableTaskWidget, dar nu accepta OnTaskToggled, OnSubtaskToggled sau OnClaimDiamonds, ci doar un OnTaskPressed. Atunci cand se apasa pe el, se executa OnTaskPressed
Vor avea doar content, daily/regular si starred

## Displays

### DayTasksDisplay
Parametri:
- String? dayId

Output:
- sectiune de taskuri scaffold cu shimmer atunci cand isLoading == true
- sectiunea cu taskuri ramase folosind CompletableTask
- sectiunea cu taskuri facute folosind CompletableTask
- Butonul de addTask apare doar daca ziua selectata este ziua curenta si isLoading == false

Inputs:
- cand intra in pagina - getTasksForDay cu argument daca sa si initializeze pagina
- cand da swipe la un task in stanga - edit day task folosind taskId-ul si dayTaskId-ul acelui task
- cand da swipe la un task in dreapta - delete day task folosind dayTaskId-ul acelui task
- cand apasa pe un task
    - daca taskul este done, nu face nimic, nici nu face scale-ul
    - daca taskul este rewarded face animatia de done cu claim
    - daca taskul nu este rewarded face animatia de done, fara claim, si apoi cheama toggle task [animatia de shrink va fi facuta cand se schimba state-ul]
- cand apasa pe un subtask
    - daca taskul este done, nu face nimic
    - daca nu sunt toate subtaskurile completate, cheama toggle subtask
    - daca toate subtaskurile sunt completate si taskul este rewarded, atunci face animatia de done cu claim
    - daca toate subtaskurile sunt completate si taskul nu este rewarded, atunci face animatia de done, fara claim, si apoi cheama toggle task [toggle task se va asigura ca toate subtaskurile vor fi completate]
- cand da claim la diamante
    - cheama claim diamonds cu un int care reprezeinta diamantele luate
    - cheama toggle task
- cand apasa pe addTask
    - daca nu este ziua curenta, nu face nimic
    - daca este ziua curenta, deschide pagina de create task


### ChooseFromExistingTasksDisplay
Parametri:
- TaskFilterType filterType (initial starred)

Output:
- back button
- sectiune de taskuri scaffold cu shimmer care sa apara atunci cand isLoading
- selector care sa arate selected filterType. Atunci cand state-ul este isLoading, optiunile trebuie sa fie disabled
- taskurile filtrate drept SelectableTaskWidget cu titlu corespunzator
- Mesaj de 'No tasks found' atunci cand state nu este isLoading, dar tasks sunt empty

Inputs:
- cand intra in pagina - getFilteredTasks cu argumentul filterType
- cand selecteaza un filtru, se afiseaza filtrul nou selectat in selector si se apeleaza getFilteredTasks cu argumentul filterType
- cand apasa pe un task - da pop la pagina si returneaza taskEntity-ul selectat prin pop
- cand apasa pe back se da pop la pagina


### BrowseTasksDisplay
Parametri: 
- TaskFilterType filterType (initial all)

Output:
- back button
- selector care sa arate selected filterType. Atunci cand state-ul este isLoading, optiunile trebuie sa fie disabled
- taskurile filtrate drept SelectableTaskWidget cu titlu corespunzator
- buton de add task doar daca isLoading este false
- Indicator de isLoading
- Mesaj de 'No tasks found' atunci cand state nu este isLoading, dar tasks sunt empty

Inputs:
- cand intra in pagina - getFilteredTasks 
- cand selecteaza un filtru, se afiseaza filtrul nou selectat in selector si se apeleaza getFilteredTasks 
- cand da swipe la un task la dreapta - delete task cu warning
- cand da swipe la un task la stanga - update task
- cand apasa pe back se da pop la pagina
- cand apasa pe add task - add task cu dayId drept ziua curenta


### CreateTaskDisplay
Parametri:
- String dayId
- TasksCubit previousCubit - in page
  
Output [Va fi o pagina intreaga, scrollable, care va aparea cu animatie din add button]:
- Category chooser
- Task content cu subtaskuri sub
- Butoane pentru add subtask si starred
- Toggle pentru dailyTask
- Toggle pentru RewardedTask
    - Selector pentru effort
    - Selector pentru importance
    - Stepper pentru time
- Un dropdown cu More Options care devine Fewer options
    - Add to date cu un calendar sub
    - Toggle pentru due time, cand e activat un stepper sub
    - Toggle pentru notify time, cand e activat un
- Buton de cancel si buton de create
- Link choose from existing
- Mesaj de eroare daca este unul

Input [toate input-urile sunt gestionate in ui, doar add task este in cubit, sau get task]:
- category chosen
- task content + subtasks
- starred
- dailyTask
- effort, importance, time, diamonds
- dueTime, notifyTime
- addToDate
- cancel - pop page
- create - call add task [cubitul decide daca sa creeze un task nou sau sa dea assign la unul existing]
- choose from existing - da push la pagina choose from existing tasks, primeste un task id ales sau null daca userul nu a ales nimic, apoi se completeaza content-ul, starred si daily

### UpdateTaskDisplay
Parametri:
- int? dayTaskId - daca este null, se updateaza taskul nu dayTaskul
- TasksCubit previousCubit - in page
  
Output [Va fi o pagina intreaga, scrollable, care va aparea fara animatie]:
- Category chooser
- Task content
- Subtaskuri sub, doar daca dayTaskId != null
- Butoane pentru add subtask (doar daca dayTaskId != null) si starred
- Toggle pentru dailyTask
- Toggle pentru RewardedTask, doar daca dayTaskId != null
    - Selector pentru effort
    - Selector pentru importance
    - Stepper pentru time
- Un dropdown cu More Options care devine Fewer options, doar daca dayTaskId != null
    - Toggle pentru due time, cand e activat un stepper sub
    - Toggle pentru notify time, cand e activat un
- Buton de cancel si buton de update
- Mesaj de eroare daca este unul

Input [toate input-urile sunt gestionate in ui, doar update task este in cubit]:
- category chosen
- task content + subtasks
- starred
- dailyTask
- effort, importance, time, diamonds
- dueTime, notifyTime
- cancel - pop page
- update - call update task


## Cum poate interactiona userul cu stateul

### GetTasksForDay
Cand:
- In pagina unei zile, la inceput

Ce vede userul:
- Imediat ce intra in pagina vor fi niste taskuri gri cu shimmer drept scaffold
- Dupa putin timp, apar taskurile din acea zi

Parametri:
- String dayId
- bool alsoInitialize (dat de pagina, alsoInitialize = !day.isInitialized && day == today)

Ce se intampla:
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se emite un state cu tasks = [], isLoading = true si error = null
- Se cheama functia din repository cu argumentul alsoInitialize
  - In repository, daca alsoInitialize e true, se initializeaza ziua in baza de date
    - Se copiaza intrari in dayTasks cu toate taskurile dailyTasks din ziua trecuta, asa cum au fost in ziua trecuta (due time, diamonds etc.)
    - Se copiaza intrari in dayTasks cu toate taskurile din ziua trecuta care nu sunt dailyTasks, nu au fost completate si nu sunt secondChance, iar apoi secondChance se face true.
  - Apoi, se citeste ziua din baza de date
    - Se citesc toate intrarile din dayTasks cu id-ul zilei, se iau toate taskId-urile si se construiesc TaskModel si DayTaskModel, apoi se construieste TaskEntity
- Se foloseste valoarea returnata din repository
  - Daca este failure, se verifica cubit.isClosed, caz in care nu se face nimic, altfel se emite un state cu eroarea data si isLoading false
  - Daca este succes, se verifica cubit.isClosed, caz in care nu se face nimic, altfel, se emite un state cu taskurile date, isLoading false si error null

### GetFilteredTasks
Cand:
- In pagina de browseTasks, la inceput
- In pagina de browseTasks, atunci cand se schimba filtrul
- In pagina de chooseExistingTask, la inceput
- In pagina de chooseExistingTask, atunci cand se schimba filtrul

Ce vede userul:
- Imediat ce se actioneaza vor fi niste taskuri gri cu shimmer drept scaffold
- Dupa putin timp, apar taskurile filtrate

Parametri:
- TaskFilterType filterType

Ce se intampla:
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se emite un state cu tasks = [], isLoading = true si error = null
- Se cheama functia din repository cu argumentul filterType
  - Daca filtrul este Trashed se uita in dayTasks dupa taskId-urile care nu apar acolo
  - Daca nu, se uita doar in tasks in functie de filtru
- Se foloseste valoarea returnata din repository
  - Daca este failure, se verifica cubit.isClosed, caz in care nu se face nimic, altfel se emite un state cu eroarea data si isLoading false
  - Daca este succes, se verifica cubit.isClosed, caz in care nu se face nimic, altfel, se emite un state cu taskurile date, isLoading false si error null


### AddNewTask
Cand:
- In pagina de create task asociata zilei actuale, atunci cand adauga un task nou

Ce vede userul:
- Se da pop imediat la pagina de createTask
- Imediat ce se intoarce in pagina de dayTasks va aparea taskul nou

Parametri:
- String dayId - ziua in care sa fie adaugat
- int categoryId
- String content
- List of Subtasks
- isStarred
- isDailyTask
- isRewardedTask
- effort, importance, time, diamonds
- isDueTimeActive, dueTime
- isNotifyTimeActive, notifyTime

Ce se intampla:
- Se da pop imediat, in ui, la pagina de createTask, iar crearea are loc in fundal
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se creaza taskul folosind datele si un taskId si dayTaskId optimistic negativ, random
- Daca ziua selectata este today, se adauga imediat optimistic taskul creat cu un id negativ
- Se asteapta crearea lui in repository care returneaza taskId-ul bun
  - Daca content-ul este identic cu alt task, se returneaza taskId-ul acelui task si se updateaza starred si isDaily astfel incat sa fie ca cele selectate acum
  - Se introduce o intrare in Tasks si una in DayTasks
- Se foloseste valoarea returnata
  - Daca este failure, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se sterge taskul optimistic si se adauga mesajul de eroare
  - Daca este succes, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se modifica cu taskul corect, returnat

### UpdateTaskForDay
Cand:
- In pagina de update task asociata taskului selectat, atunci cand updateaza taskul

Ce vede userul:
- Se da pop imediat la pagina de updateTask
- Imediat ce se intoarce in pagina de dayTasks, toate taskurile cu acelasi taskId vor fi updatate doar cu Content, starred si isDaily, iar celelalte vor aparea doar la taskul selectat
- Atunci cand merge pe alte zile, va aparea si acolo taskul updatat

Parametri:
- int taskId - taskul care sa fie updatat
- int dayTaskId - conexiunea care sa fie updatata
- int categoryId
- String content
- List of Subtasks
- isStarred
- isDailyTask
- isRewardedTask
- effort, importance, time, diamonds
- isDueTimeActive, dueTime
- isNotifyTimeActive, notifyTime

Ce se intampla:
- Se da pop imediat, in ui, la pagina de updateTask, iar crearea are loc in fundal
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se creaza noul task folosind datele
- Se updateaza imediat optimistic taskul
- Se asteapta updatarea lui in repository
  - Nu se mai efectueaza operatii de merge
  - Content, isStarred, isDailyTask se pun in Tasks folosind taskId
  - Celelalte se pun in DayTasks folosing dayTaskId
- Se foloseste valoarea returnata
  - Daca este failure, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se inlocuieste taskul optimistic cu cel precedent si se adauga mesajul de eroare
  - Daca este succes, nu se face nimic

### UpdateTask
Cand:
- In pagina de browse tasks, cand da swipe la stanga si apasa pe update, in pagina de update task, dupa ce apasa pe 'Update'

Ce vede userul:
- Se da pop imediat la pagina de updateTask
- Taskul din browse tasks va fi updatat
- Atunci cand merge pe pagina unei zile cu acel task, si acolo va fi updatat

Parametri:
- int taskId - taskul care sa fie updatat
- int categoryId
- String content
- List of Subtasks
- isStarred
- isDailyTask
- isRewardedTask
- effort, importance, time, diamonds
- isDueTimeActive, dueTime
- isNotifyTimeActive, notifyTime

Ce se intampla:
- Se da pop imediat, in ui, la pagina de updateTask, iar crearea are loc in fundal
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se creaza noul task folosind datele
- Se updateaza imediat optimistic taskul
- Se asteapta updatarea lui in repository
  - Nu se mai efectueaza operatii de merge
- Se foloseste valoarea returnata
  - Daca este failure, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se inlocuieste taskul optimistic cu cel precedent si se adauga mesajul de eroare
  - Daca este succes, nu se face nimic

### DeleteTaskForDay
Cand:
- In pagina unei zile, cand da swipe la dreapta si apasa pe delete
  
Ce vede userul:
- Doar taskul selectat se sterge imediat, cu animatie de shrink
- Alte taskuri cu acelasi taskId raman

Parametri:
- int dayTaskId - conexiunea care sa fie stearsa

Ce se intampla:
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se sterge imediat, optimistic, taskul selectat
- Se asteapta stergerea lui in repository
  - Se sterge doar din DayTasks
- Se foloseste valoarea returnata
  - Daca este failure, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se readauga taskul si se adauga mesajul de eroare
  - Daca este succes, nu se face nimic

### DeleteTask
Cand:
- In pagina de browse tasks, cand da swipe la dreapta si apasa pe delete, dupa warning
  
Ce vede userul:
- Taskul selectat se va sterge imediat, cu animatie de shrink
- Daca intra pe alte pagini, si acolo va fi sters taskul

Parametri:
- int taskId - taskul care sa fie sters de tot

Ce se intampla:
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se sterge imediat, optimistic, taskul selectat
- Se asteapta stergerea lui in repository
  - Se sterge din Tasks
- Se foloseste valoarea returnata
  - Daca este failure, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se readauga taskul si se adauga mesajul de eroare
  - Daca este succes, nu se face nimic

### ToggleTask
Cand:
- In pagina de day tasks doar daca taskId-ul selectat nu este negativ

Ce vede userul
- Taskul dispare imediat, prin shrinking animation (partea cu completed text si optiunile de claim sunt gestionate de ui)
- Apoi, apare imediat, cu animatie de growing la completed.

Parametri:
- int dayTaskId
- TaskDoneType doneType

Ce se intampla:
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se updateaza imediat optimistic taskul cu doneType-ul corect si toate subtaskurile facute
- Se asteapta updatarea lui in repository
  - Repository updateaza entry-ul din day tasks, inclusiv subtaskurile
- Se foloseste valoarea returnata
  - Daca este failure, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se inlocuieste taskul optimistic cu cel precedent si se adauga mesajul de eroare
  - Daca este succes, nu se face nimic

### ToggleSubtask
Cand:
- In pagina de day tasks doar daca taskId-ul selectat nu este negativ

Ce vede userul
- Subtaskul este imediat toggled, iar daca toate subtaskurile sunt complete, va fi exact ca la toggleTask

Parametri:
- int dayTaskConnection
- int subtaskIndex
- bool done

Ce se intampla:
- Se verifica daca state.isLoading sau cubit.isClosed, caz in care nu se face nimic
- Se updateaza imediat optimistic subtaskul
- Se asteapta updatarea lui in repository
  - Repository updateaza entry-ul din day tasks
- Se foloseste valoarea returnata
  - Daca este failure, se verifica daca cubit.isClosed caz in care nu face nimic, altfel se inlocuieste taskul optimistic cu cel precedent si se adauga mesajul de eroare
  - Daca este succes, nu se face nimic
