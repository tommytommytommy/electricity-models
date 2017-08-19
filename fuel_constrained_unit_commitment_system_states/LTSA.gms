* firing hours threshold before scheduled maintenance
PARAMETER MFH;
MFH = 6000;

* starts threshold before scheduled maintenance
PARAMETER MST;
MST = 200;

* "periods" to take plant offline during for scheduled maintenance
PARAMETER SMD;
SMD = 1;

* these values are all for one contract
PARAMETER C_6(l)
/
1	10000000
2	20000000
/;

SET CONTRACT / FH, ST /;

TABLE LTSA(l, h, CONTRACT)	ltsa parameters
          FH       ST
1 . 1     0        250			
1 . 2     25000    250
1 . 3     25000    0
2 . 1     0        750
2 . 2     25000    750
2 . 3     25000    0;