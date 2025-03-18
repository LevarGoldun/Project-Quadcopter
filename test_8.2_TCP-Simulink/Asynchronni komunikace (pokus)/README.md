# Jednoduché řízení kvadrokoptéry v MuJoCo pomocí Matlab/Simulink (Asynchronní verze) ###

V [Jednoduche rizeni](https://github.com/LevarGoldun/Project-Quadcopter/tree/master/test_8.2_TCP-Simulink/Jednoduche%20rizeni%20(z%20test_8.0)) byl problém v tom, že simulace v MuJoCo a zpracování dat v Simulink 
probíhaly synchronně, tj. každý krok simulace v pythonu se shodoval 
s krokem přenosu a zpracování dat v Simulink. 
Nezdálo se mi to tak košer a jako by ovládání šlo mnohem pomaleji 
z pohledu reálného času. 
Předchozí pokusy byly přepracovány pro asynchronní přenos. 

Tento příklad implementuje jednoduchou regulaci z výše zmíněného testu, 
který nespotřebovává mnoho výpočetních prostředků. 
Zatím nevím, jak bude probíhat simulace a komunikace s 
větším počtem bloků v Simulink.

Komunikace mezi Simulink a Python není přímá, ale pomocí kódu v Matlab. Zkratka:
1.  Matlab kód čte výstupní data ze Simulink
2.	Připravuje data (JSON struktura), kóduje a posílá pomocí soketu do Python
3.	Python čte soket, dekóduje a přirázuje odpovídající data z JSON struktury odpovídajícím MuJoCo proměnným
4.  Python připravuje MuJoCo data (JSON struktura), kóduje a posílá pomocí soketu do Matlab (Simulace v Python pokračuje, paralelně Simulink navrhuje řízení)
5.  Matlab čte soket, dekóduje a přirázuje odpovídající data z JSON struktury odpovídajícím blokům v Simulink (mění jejích parametry)
6.	Krok v Simulink
7.	Bod 1

V Simulink je jednoduchá řídicí smyčka, která každé 2 sekundy (na základě proměnné času 
z Python) mění otáčky motorů na rotorech (řídicí signál v Python).

## Postup spuštění :
1.	Spustit server [async_python_server.py](async_python_server.py)
2.	Spustit Matlab kód [async_matlab_client_v2.m](async_matlab_client_v2.m) (Správná verze Simulink se otevře automaticky)
3.	Enjoy!