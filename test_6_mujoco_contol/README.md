1. Jednoduche kyvado, kyvani v plose XY
2. Ctu polohu telesa z mj.MjData (lze take jednotlivych geometrii) a pak kreslim grafy
3. Pridavam ruzne senzory a zkousim k nim pristup
    * Zaprve musim definovat polohu "site" v nejakem miste na objektu
    * Pri definici senzoru ukazat, na jakem "site" bude umisten
    * profit
4. Data jsou uchovana v mj.MjData(model).sensordata a je to pouze array a musime sbirat odpovidajici elemetny 
matice, ktere reprezentuji nejaky senzor, ktery jsme definovali v .xml souboru.
P.S. Poradi hodnot v mj.MjData(model).sensordata je dano poradi defici senzoru v .xml
5. Kreslim grafy

6. Chci vyzkousek aktuatory, ktere jsou v MuJoCo
7. Hlavni teze kterou jsem pochopil je, ze existuje jako jedna "trida" aktuatoru -->/general, ale
ma spoustu parametru, ktere lze libovolne konfigurovat a tim bude dana dynamika navrzeneho aktuatoru.
Ale v MUJOCO jsou i "pripravene, hotove" aktuatory, kterym se rika "shortcuts".
Kdyz tyto shortcuts nadefinujeme v .xml, tak budou mit v nekterych atributech jiz nastavene 
vlastnosti, aby aktuator odpovidat zvolenemu typu.
8. Vsechne ridici signaly na aktuatory posilame pres `mjData.ctrl`


8. Dulezite take, kde umistime aktuator a jak nakonfigurujeme prevodovku, viz odstavec
https://mujoco.readthedocs.io/en/latest/computation/index.html#passive-forces:~:text=common%20actuator%20types.-,Transmission,-%23
Dulezite pro modelovani kvadrokoptery: **Site transmissions correspond to applying a Cartsian force/torque in the 
frame of a site. When a refsite is not defined (see below), these targets have a fixed zero length
l_i (q)=0 and are useful for modeling jets and propellors: forces and torques which are fixed to the site frame.**
9. Trochu nemuzu pochopit (rozumim myslenku, ale nastavaji potize pri kodovani), jak gear a typ prevodovky souvisi. Vzdy jsou ruzne efekty
-->podivat se na priklady modelu, ktere maji tahove motory...hotove modely kvadrokoptery
10. Ja uz mam vytvoreny model a podle me pohybuje jako skutecna kvadrokoptera, splnuje vsechny zakladni pohyby
napr. dle obrazku https://www.researchgate.net/publication/285595103/figure/fig2/AS:339777892175875@1458020770386/Quadcopter-states-a-Forward-motion-b-backwards-motion-c-movement-left-d.png


11. Ted se koukam na video https://www.youtube.com/watch?v=6B_NDL0ff1c&list=PLc7bpbeTIk75dgBVd07z6_uKN1KQkwFRK&index=19
a autor ridi manipulator:
    * klasicky PD
    * Feedback linearization, tzn. pouziva mat. model generovany z MuJoCo (matice hmotnosti M, matice
    gravitacnich a koriolisovych sil atd.) --> ridi super


