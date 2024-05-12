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
