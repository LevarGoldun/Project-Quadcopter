# Jednoduché řízení kvadrokoptéry v MuJoCo pomocí Simulink + Matlab ###

Dosud řízení kvadrokoptéry probíhalo bud přímo v Python nebo v Matlab a 
poté byla data vyměňována pomocí soketů. Nevýhodou obou metod bylo to, 
že PID regulátor/y byl realizován jako třida v diskrétní formě (možná je to 
výhoda z pohledu rychlosti zpracovaní dat), ale chtěl jsem využit hotové bloky PID 
ze Simulink (a také další bloky pro zpravování nebo vizualizaci dat).

Pomoci ukázkového kódu z [Cizi zdrojovy kod](..%2FCizi%20zdrojovy%20kod) podařilo se mi 
implementovat řídicí část v Simulink a výměnu dat s Python.

**Spojler**…komunikace mezi Simulink a Python není přímá, ale pomocí kódu v Matlab. Zkratka:
1.  Matlab kód čte výstupní data ze Simulink
2.	Připravuje data (JSON struktura), kóduje strukturu a posílá pomocí soketu do Python
3.	Python čte soket, dekóduje a přirázuje odpovídající data z JSON struktury odpovídajícím MuJoCo proměnným  krok simulace
4.	Python připravuje MuJoCo data (JSON struktura), kóduje a posílá pomocí soketu do Matlab
5.	Matlab čte soket, dekóduje a přirázuje odpovídající data z JSON struktury odpovídajícím blokům v Simulink (mění jejích parametry)
6.	Krok v Simulink
7.	Bod 1

V Simulink je jednoduchá řídicí smyčka, která každé 2 sekundy (na základě proměnné času 
z Python) mění moment motorů na rotorech (řídicí signál v Python).

Vzhledem k tomu, že počet bloků v Simulink je malý a neprovádějí se náročné matematické 
operace, je celá simulace relativně rychlá (pokud ji porovnáme s testem [Kakadova regulace (2D, z test_8.1)](..%2FKakadova%20regulace%20%282D%2C%20z%20test_8.1%29)).

## Postup spuštění :
1.	Spustit server [python_server.py](python_server.py)
2.	Spustit Matlab kód [matlab_client.m](matlab_client.m) (Správná verze Simulink se otevře automaticky)
3.	Enjoy!