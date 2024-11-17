# 3D kaskádové řízení kvadrokoptéry v MuJoCo pomocí Simulink + Matlab

Zkusím implementovat kaskádovou regulaci ve všech směrech v MuJoCo. 
Kvadrokoptéra je ve tvaru obdélníka, takže 2 osy symetrie. 
Kaskádová regulace 2D byla naladěna pro “delší stranu”, pro osu x. 
Pro první pokus použiju stejné PID regulátory i pro “kratší stranu”, osu y.

Kaskádová regulace realizována dle
https://www.youtube.com/watch?v=GK1t8YIvGM8&list=PLPNM6NzYyzYqMYNc5e4_xip-yEu1jiVrr&index=2


### Postup spuštění :
1.	Spustit server [python_server_MuJoCO.py](python_server_MuJoCO.py)
2.	Spustit Matlab kód [matlab_client.m](matlab_client.m) (Správná verze Simulink se otevře automaticky)
3.	Enjoy!


# 3D kaskádové řízení matematické kvadrokoptéry
Odvodil jsem pohybové rovnice kvadrokoptéry bez závaží a vyzkoušel jsem na ní kaskádovou regulaci pro model v MuJoCo. Překvapivě, ale regulace se neposrala. Ale potřebuje doladění pro matematický model. Asi muže byt problém v:
* Nastavené koeficienty v [quad_param_3d.m](quad_param_3d.m), jako odpor vzduchu atd
* Kaskádová regulace generuje “signál” na motory, zatímco pohybové rovnice pracují s otáčkami motoru 
* Chyba v pohybových rovnicích

### Postup spuštění :
1.	Načíst parametry [quad_param_3d.m](quad_param_3d.m)
2.	Spustit správný Simulink ([quad_equation_3d_pokus_rizeni.slx](quad_equation_3d_pokus_rizeni.slx))
3.	Enjoy!