### Implementace kaskadoveho rizeni ~~v MuJoCo~~ v Matlab a kominikace s MuJoCo (Python) pomoci soketu
* V danem testu snazim prepsat kod z test_7 a to tak, ze veskera MuJoCo cast bude v Python a
ridici cast (pid regulatory, kaskadova smycka + grafy) budou napsany v Matlab a mezi Matlab a Python
bude probihat TCP komunikace, ktera byla vyzkousena a overena v test_8. 

### Aktualni vysleky ###
* Kod v Python byl prepsan tak, ze zustaly pouze prikazy spojene s MuJoCo simulaci a 
casti pro komunikaci s Matlab. 
* V Matlab byla premistena ovladaci cast (kaskadova regulace), pid regulatory a vizualizace
dat (grafy)
* **P.S.** Zapve spustit server [python_server_MuJoCO.py](python_server_MuJoCO.py) a pak
client [matlab_client_PID_control.m](matlab_client_PID_control.m)

* Simulace a komunikace tedy funguje...ale samotna kaskadova regulace ne --> 
  1. Prvni otazka, jaku periodu vzorkovani `Ts` potrebuji pro diskretni PID regulatory?
    (**P.S.** Realizovany jako trida v [my_function_pid.m](my_function_pid.m) a funkcnost 
  MELA BY byt stejna jako vychozi trida PID regulatoru v test_7 v 
  [pokus_PID_control.py](..%2Ftest_7_mujoco_quadrotor_control%2Fpokus_PID_control.py))
  2. Logika je takova, ze simulace v MuJoCo je jako realny svet a client Matlab cte kazdou/ych `?`
  sekund data z Python, zpracova je a posila v MuJoCo zpatky, a to jedna vzorkovaci frekvence
  (jo ?)
  3. Pauza cteni dat z MuJoCo je nastavena na 0.1 s, ale vlivem komunikace a dalsiho zpracovani,
  urcuju presneji cas jednoho cyklu zpracovani dat, a to pomoci prikazu `tic` a `toc` v Matlab. 
  Cas jednoho cyklu posilam do instanci PID regulatoru, korekuju `Ts`. ALE pri takovem nastaveni
  periody vzorkovani nefunguje regulace, hlavne jde do nekonecna 
  (nebo do nuly, pokud funguje Anti-Windup) vystup z `PID_F_cmd`, ktery nastavuje celkovy moment
  na kazdem motoru kvadrokoptery (pokud 0, tak kvadrokoptera neleta).
  4. Zacal jsem si hrat s parametrem `Ts` a zjistil jsem, pri jakekoli jine hodnote, nez
  z `tic` a `toc`, regulator `PID_F_cmd` funguje, i kdyz s velkymi skoky...
     (Napr. na radku 66(+-) v [matlab_client_PID_control.m](matlab_client_PID_control.m) je 
  pausa 0.5 s, z `tic` a `toc` dostavam cas jednoho kroku cyklu 0.546 s, pokud `Ts` v
  regulatoru bude 0.546 s, tak regulator nefunguje)
  5. **Takze musim zjisti, proc vznika takovy problem a vyresit...**