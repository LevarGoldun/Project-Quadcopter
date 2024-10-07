% propojENI virtualni prostredi meho projektu (.venv) a Matlab
%pyenv('Version','D:\Пользователи\Admin\Документы\CVUT\_Magistersky projekt\Project-Quadcopter\.venv\Scripts\python.exe')
%% 1. Volani jednoducheho python skriptu
%chceme na vystup ze skriptu promennou L1
myListFile1 = pyrunfile("mklist.py", "L1");
disp(myListFile1)

%chceme na vystup ze skriptu jinou promennou
disp(pyrunfile("mklist.py", "L2"))

disp(pyrunfile("mklist.py", "s"))

%text "random text" je vzdy, protoze vznika pri spusteni .py skriptu

%% 2. Volani skriptu se smyckou
cislo = pyrunfile("loops.py", "i");
disp(cislo)
% tak jak jsem ocekaval, zaprve skript se ukonci a pak cteme promennou

%% 3. Predavame argument(y) z Matlabu do .py skriptu
res = pyrunfile("addac.py","z1", x=3, y=2, x2=0, y2=0);
disp(res)

[res1, res2] = pyrunfile("addac.py",["z1", "z2"], x=3, y=2, x2=0, y2=0);
disp(res1)
disp(res2)

%% 4. Kontrola, ze muzu spustit python skript s knihovnami
%https://www.mathworks.com/help/matlab/matlab_external/create-object-from-python-class.html
% mam pocit, ze musim propojit virtualni prostredi meho projektu (.venv) a
% Matlab --> 1x krat a uplne na zacatku
% pyenv('Version','D:\Пользователи\Admin\Документы\CVUT\_Magistersky projekt\Project-Quadcopter\.venv\Scripts\python.exe')
% |
% V
% ANO, TED FUNGUJE

A1 = [1 2; 3 4];
A2 = [2 3; 1 0];

A1converted = py.numpy.array(A1);
A2converted = py.numpy.array(A2);

parameter = py.int(2);

%result = pyrunfile("test_libraries.py", "ReturnList", A1, A2, param1=parameter);
result = pyrunfile("test_libraries.py", "ReturnList", A=A1converted, B=A2converted, param1=parameter);
%jaky typ vracene promenne
class(result)
class(result{1})
