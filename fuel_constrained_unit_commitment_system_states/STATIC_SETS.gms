
* STATIC_SETS.gms
*
* Although the hourly and system state representations do not
* share all of the same sets, sets for both models are stored
* in this common file to prevent duplicate set names with different
* functions from being used

SETS
        l					available LTSAs					/ 1*2 /
        h					LTSA MIF points					/ 1*3 /
        ;

* generic BIG_M parameter; should switch to indicator variables
PARAMETER BIG_M_50000;
BIG_M_50000 = 50000;

PARAMETER BIG_M_50000000;
BIG_M_50000000 = 50000000;