SET FIRM(i, g)          assign plants to firms
/
$ondelim
$include 'powerPlants/input_powerPlantsFirms.csv'
$offdelim
/;

PARAMETER X_MIN(i)      minimum output levels for power plants in MW
/   
$ondelim
$include 'powerPlants/input_powerPlantsXMin.csv'
$offdelim
/;

PARAMETER X_MAX(i)      maximum output levels for power plants in MW
/
$ondelim
$include 'powerPlants/input_powerPlantsXMax.csv'
$offdelim
/;

PARAMETER HR(i)         heat rate for thermal plants in MMBtu per MWh
/
$ondelim
$include 'powerPlants/input_powerPlantsHeatRate.csv'
$offdelim
/;

PARAMETER R(i)          power plant ramp rates
/
$ondelim
$include 'powerPlants/input_powerPlantsRamp.csv'
$offdelim
/;

PARAMETER RR(i)         power plant minimum up and down times
/
$ondelim
$include 'powerPlants/input_powerPlantsMinUpDown.csv'
$offdelim
/;

PARAMETER C_1(i)        start up cost for each plant
/
$ondelim
$include 'powerPlants/input_powerPlantsStartCost.csv'
$offdelim
/;

PARAMETER C_2(i)        shut down cost for each plant
/
$ondelim
$include 'powerPlants/input_powerPlantsStopCost.csv'
$offdelim
/;

PARAMETER C_3(i)        commitment cost in dollars per hour
/
$ondelim
$include 'powerPlants/input_powerPlantsCommitmentCost.csv'
$offdelim
/;

PARAMETER C_4(i)        fuel costs for non-natural gas plants in dollars per MWh
/
$ondelim
$include 'powerPlants/input_powerPlantsFuelCost.csv'
$offdelim
/;

PARAMETER C_5(i)        O&M cost adder in dollars per MWh
/
$ondelim
$include 'powerPlants/input_powerPlantsOperationAndMaintenanceCost.csv'
$offdelim
/;