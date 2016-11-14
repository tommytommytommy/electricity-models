PARAMETER P_K(kk)       electricity demand scenarios
/
1   1
/;

PARAMETER P_N(nn)       gas pipeline capacity scenarios
/
1   1
/;

* this figure represents Algonquin's daily transportation capacity 
* (2.6 BCF = 2.6e3 MMCF = 2.6e6 MCF = 2.6e6 MMBTU) 
PARAMETER PC                pipeline capacity;
PC = 2600000;

PARAMETER C_7(d)        commodity cost of natural gas in dollars per MMBtu
/
$ondelim
$include 'input_gasCommodityPrice.csv'
$offdelim
/;

PARAMETER C_8(n, d)     gas transportation price in dollars per MMBtu
/
$ondelim
$include 'input_gasTransportationPrice.csv'
$offdelim
/;

PARAMETER GD(n, d)      non-electric-sector gas demand scenarios in MMBtu
/
$ondelim
$include 'input_nonelectricGasDemand.csv'
$offdelim
/;

PARAMETER fx_LT(g)      long-term firm pipeline capacity in MMBtu
/
$ondelim
$include 'input_longtermFirmPipelineCapacity.csv'
$offdelim
/;

PARAMETER ELECTRICITY_DEMAND(k, t)
/   
$ondelim
$include 'input_electricityDemand.csv'
$offdelim
/;

PARAMETER WIND_GENERATION(k, t)
/   
$ondelim
$include 'input_electricityWindGeneration.csv'
$offdelim
/;