* default parameter with initialization for long-term transportation
PARAMETER P_FX_LT;
P_FX_LT = 10;

* this figure represents Algonquin's daily transportation capacity
PARAMETER PC				pipeline capacity;
PC = 2600000;

PARAMETER A_MIN_TARGET(g)
/
1 0
2 0.8
3 0.8
4 0
5 0
6 0
/;

PARAMETER BETA(g)
/
1 0
2 0.9
3 0.9
4 0
5 0
6 0
/;
 
PARAMETER F_ESTIMATED(q, dd, g)		daily gas usage
/
$ondelim
$include 'AUTO_GENERATED/input_fuel_estimates.csv'
$offdelim
/;

PARAMETER C_7(d)		commodity cost of natural gas
/
$ondelim
$include 'AUTO_GENERATED/input_gasCommodityPrice.csv'
$offdelim
/;

PARAMETER C_8(q, d)		gas transportation price
/
$ondelim
$include 'AUTO_GENERATED/gasTransportationPrice.csv'
$offdelim
/;

PARAMETER GD(q, d)		city gas demand scenarios
/
$ondelim
$include 'AUTO_GENERATED/cityGasDemand.csv'
$offdelim
/;

$IFTHEN "%LONG_TERM%" == "YES" 
SET SHORTAGE(q, pp, s)
/
$ondelim
$include 'shortagesLongTerm.csv'
$offdelim
/;

$ELSE
SET SHORTAGE(q, pp, s)
/
$ondelim
$include 'shortagesMediumTerm.csv'
$offdelim
/;

$ENDIF