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

Aktualni problem je, ze musime se dockat skonceni skriptu a az potom 
muzeme mit pristup k pozadovanym promennym .py skriptu. Potrebuju, abych
mohl mit pristup k promennym (posilat a ziskavat hodnoty) **"realtime"**.
