### Spusteni kodu Python pres Matlab
* Cilem je spusteni prostredi MUJOCO (ktery uz je naladen v Python) pres kod v Matlab, 
vymenovat si data mezi programy atd.
* Duvodem je, ze Matlab je pro me lepsi prostredi k vykreslovani grafu, navrchu matematickych modelu, reseni ODE atd.

* Verze: Matlab R2024b, Python 3.12 --> kompatibilni

* Pouzitim `pyrun()` ve tvaru `pyrun(code)` nebo `outvars=pyrun(code, outputs)`.
Napriklad `pyrun("print('Hello')")`, `d = pyrun(["a=5.5", "b=5.8", "c=a+b"], "c")`,
`code=["radek1","radek 2","radek 3..."]` a pak `pyrun(code)`.

**DULEZITE**: Spojit Matlab s aktualnim python, abychom meli pristup k knihovnam.
Ukazal jsem nedefolni cestu, ale cestu do .venv prostredi tohoto projektu a to 
pomoci prikazu `pyenv('Version','D:\Пользователи\Admin\Документы\CVUT\
_Magistersky projekt\Project-Quadcopter\.venv\Scripts\python.exe')`.
Delame 1x pri "prvnim" spusteni Matlabu, cesta je zachovana i pro dalsi seance Matlab


1. Spusteni .py skriptu pomoci `myListFile = pyrunfile(file, outputs)`, vice [mklist.py](mklist.py)
2. Co bude, kdyz spustip [loops.py](loops.py) skript se smyckou? **NEPUSTIT SKRIPT S NEKONECNOU SMYCKOU**  
    Skript se spusti-->smycka se skonci-->az potom dostavam hodnotu promenne

3. Predavame argument(y) do [addac.py](addac.py) skriptu a dostavame 
hodnoty pozadovanych promennych zpet

4. Kontrola, ze muzu spustit [test_libraries.py](test_libraries.py) skrip s knihovnami

5. Spusteni skriptu s kvadrokopterou [test_spusteni.py](..%2Ftest_1%2Ftest_spusteni.py) 
z test_1. Musel jsem behem pokusu drobne zmenit skript, a to okomentovanim nazvu xml souboru
a zmensit cas simulace do 10 s. Vstupem v `pyrun()` byla promenna `xml_path` s globalni cestou
do xml souboru kvadrokoptery, na vystup jsem dal promennou `start`, ktera obsahuje cas
spusteni skriptu (`start=time.time()`). MuJoCo se spustil, kvadrkoptera "letala" 10 s a
po skonceni skriptu dostal jsem hodnotu premenne.  
 Dale jsem dal na vystup promennou `data`, která obsahuje veskerou informaci o simulaci.
Samozrejme pozatim obsahuje posledni data (hodnoty) pred skoncenim skriptu (simulace), presto
muzu mit pristup k atributum promenne `data` v Matlab. 


Aktualni problem je, ze musime se dockat skonceni skriptu a az potom 
muzeme mit pristup k pozadovanym promennym .py skriptu. Potrebuju, abych
mohl mit pristup k promennym (posilat a ziskavat hodnoty) **"realtime"**.  
 |  
 |  
 V  
### Python server, Matlab client, TCP/IP
* **ChatGPT doporucil udelat Python jako server a Matlab klientem**, ktery bude posilat
dotazy. Predbezne to funguje jak ja chci, ale potrebuje doladeni: Matlab si nemuze spravne 
precist soket, velky pocet soketu za vterinu atd.
* Zaprve musime spustit server [python_server.py](python_server.py), pak spustit
program [matlab_client.m](matlab_client.m), dale magic 
* Pokracovani v testu 8.5