# Highlights Feature

Un highlight este definit prin:
- dayId (String)
- savedPath (String)
- thumbnailPath (String)

State-ul cubit-ului este definit printr-o lista de highlight-uri, un bool isLoading si un mesaj nullable de eroare

### Idei Generale
- Le voi salva doar local, folosind hive, pentru ca nu imi trebuie query-uri speciale, in viitor o sa vreau paginatie, dar asta e o problema pentru viitor.

### Cand apare
- Apare in pagina de luna, caz in care lista din state reprezinta toate imaginile din acea luna.
- Se propaga si in pagina de zi, caz in care state-ul nu se schimba, dar display-ul din pagina de zi va stii ce imagine sa foloseasca
- Apare o instanta separata in pagina de galerie, unde lista din state va fi paginata.

## Cum poate userul sa interactioneze cu state-ul

### Poate da load la toate imaginile dintr-o luna
- Folosind cheia unei luni

### Poate updata o noua poza la o zi anume

### Poate sterge o poza dintr-o zi anume

### Poate da load la toate imaginile postate
