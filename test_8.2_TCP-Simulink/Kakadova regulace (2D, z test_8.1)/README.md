# Kaskádové řízení kvadrokoptéry v MuJoCo pomocí Simulink + Matlab
Po ověření na jednoduchém příkladu [Jednoduche rizeni (z test_8.0)](..%2FJednoduche%20rizeni%20%28z%20test_8.0%29) 
byl kód z testu [test_8.1_mujoco_quadrotor_control_python_server_matlab_client](..%2F..%2Ftest_8.1_mujoco_quadrotor_control_python_server_matlab_client) přepsán a nyní je 
řídicí část (kaskádová smyčka) plně implementována v Simulink a 
kód Matlab slouží pouze pro zpracování dat ze soketů a řízení celé simulace.

Bohužel kvůli velkému počtu bloků a složitým matematickým operacím je 
simulace pomalá. Krok simulace je dán parametrem `timestep` z xml 
souboru kvadrokoptéry. Testoval jsem pro `timestep="0.05"`, `dt="0.01"`, `t="0.1"` 
a střední FPS byl 8-10…
ale přesto simulace a regulace funguje (na výstupů PIDek jsou skoky, ale lze doladit), i když bych chtěl, aby to bylo rychlejší.

### Postup spuštění :
1.	Spustit server [python_server_MuJoCO.py](python_server_MuJoCO.py)
2.	Spustit Matlab kód [matlab_client.m](matlab_client.m) (Správná verze Simulink se otevře automaticky)
3.	Enjoy!