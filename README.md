# FastestOpenBSDMirror

Skrypt KSH, ustawiający najszybszy serwer lustrzany bazując na pingu oraz
na podanym przez użytkownika protokole z jakiego ten ma zamiar korzystać
podczas pobierania pakietów z repozytorium. Lista jest pobierana 
samodzielnie przez skrypt, lub może zostać podana jako parametr pozycyjny. 

## Użycie:
1) `git clone https://github.com/xf0r3m/FastestOpenBSDMirror.git`

2) `chmod +x FastestOpenBSDMirror/fastMirror.sh`

3)	`openbsd# . /home/xf0r3m/FastestOpenBSDMirror/fastMirror.sh <http|ftp|rsync>`

### Uwagi:
Aby skrypt miał zastosowanie w systemie musi zostać uruchomiony jak _root_
oraz polecenie musi zostać wykonane w tej samej powłoce (ścieżka do skryptu
musi zostać poprzedzona _kropka[.] oraz spacją [ ]_).
