# Rich Inputs Feature

Un rich input este definit prin:
- o lista de rich input parts

Un rich input part este definit prin:
- type (RichInputType) - poate fi plain, title, checkboxChecked, checkboxUnchecked, bullet
- content (String)
- padding (int) - transformat ulterior in double

State-ul cubit-ului este definit printr-un rich input, un bool isLoading si un mesaj nullable de eroare.

### Idei Generale
- Voi salva folosind Hive pentru ca nu imi trebuie query-uri speciale
- State-ul rich input-ului depinde de o cheie. Pentru o zi, cheia este de tipul '2025-08-29', pentru o luna este de tipul '2025-08'. Daca mai decid sa pun si in alta parte rich input, doar trebuie sa determin o cheie noua.

### Cand apare
- In pagina de luna cu cheia de tipul '2025-08'
- In pagina de zi cu cheia de tipul '2025-08-29'

## Cum poate userul sa interactioneze cu state-ul
### Poate da load la un rich input anume
- Foloseste cheia rich input-ului
- Daca flagul isLoading e true, sau deja are input-uri, da eroare
- Initial face isLoading true, caz in care apare un mesaj de genul 'loading journal', doar daca nu exista inputuri in state-ul actual, iar dupa ce termina se populeaza rich input si isLoading se face false

### Poate updata rich input-ul actual
- Foloseste noul rich input (adica cu toate partile, chiar daca se updateaza o singura parte)
- Daca flagul isLoading e true, da eroare
- Initial face isLoading true, caz in care nu se intampla nimic, iar dupa ce termina din nou, nu se intampla nimic.
- Se updateaza automat o data la 5 secunde sau cand face o actiune importanta (check, enter, etc.)

## De tinut minte pentru viitoare updateuri
- To do: Undo