Pokus o řešení/modelování/řízení jednoduchého systému popsaného soustavou dvou dif. rovnic 1. řádu. 
Výchozí Simulink model je [ODE_model.slx](ODE_model.slx), se kterým porovnávám výsledek v Python.
Hlavní rozdíl mezi soubory spočívá ve způsobu implementace PID regulátoru: buď pomocí knihovny 
[simple_pid](https://pypi.org/project/simple-pid/), nebo pomocí uživatelské funkce 
dle [návodu](https://softinery.com/blog/implementation-of-pid-controller-in-python/).

To nějak funguje s požadovanou přesností jako výchozí model Simulink