První pokus o ovládání kvadrokoptéry, ale ve 2D prostoru. 
Test v Python a kontrola v Matlab Simulink (nebo naopak...)
Zdroj https://cookierobotics.com/052/, 
https://www.youtube.com/watch?v=GK1t8YIvGM8&list=PLPNM6NzYyzYqMYNc5e4_xip-yEu1jiVrr&index=2 
a rady od Ing. Michala Kuchaře.

V souboru ...control_0.slx je nejjednodušší ovládání, při kterém se nastavuje úhel natočení kvadrokoptéry. 
Protože systém má 3 stupně volnosti a pouze jeden vstup, pozice x a y kvadrokoptéry se libovolně mění.

V souboru ...contol_1.slx je realizováno kaskádové řízení, 
kde se nastavuje požadovaná poloha x a v závislosti na vzniklé odchylce 
je nastavena žadaná hodnota úhlu náklonu kvadrokoptéry, aby se pohybovala vpravo nebo vlevo.
Ovládá se pouze jeden parametr, moment T, proto výška není konstantní.

Soubor ...contol_2.slx je vylepšením ...contol_1.slx, nejprve byl změněn 2D model kvadrokoptéry, 
takže nyní řídíme dva parametry: normální tahovou sílu a zhruba řečeno delta sílu, 
která právě zavádí nerovnováhu a kvůli níž vzniká točivý moment. 
Lze nastavovat požadovanou polohu kvadrokoptéry ve 2D prostoru.

[installation.md](installation.md)