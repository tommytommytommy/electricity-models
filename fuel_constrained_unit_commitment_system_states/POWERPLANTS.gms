SET FIRM(i, g)
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsFirms.csv'
$offdelim
/;

PARAMETER X_MIN(i)
/	
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsXMin.csv'
$offdelim
/;

PARAMETER X_MAX(i)
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsXMax.csv'
$offdelim
/;

PARAMETER HR(i) 		heat rate for thermal plants MMBtu per MWh
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsHR.csv'
$offdelim
/;

PARAMETER R(i)			ramp rate
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsRamp.csv'
$offdelim
/;

PARAMETER RR(i)			minimum up and down times
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsMinUpDown.csv'
$offdelim
/;

PARAMETER C_1(i)		start up cost for each plant
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsC1.csv'
$offdelim
/;

PARAMETER C_2(i)		shut down cost for each plant
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsC2.csv'
$offdelim
/;

PARAMETER C_3(i)		commitment cost dollars per hour
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsC3.csv'
$offdelim
/;

PARAMETER C_4(i)		fuel costs
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsC4.csv'
$offdelim
/;

PARAMETER C_5(i)		O&M cost adder in dollars per MWh
/
$ondelim
$include 'AUTO_GENERATED/input_powerPlantsC5.csv'
$offdelim
/;