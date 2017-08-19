$INCLUDE 'AUTO_GENERATED/AUTO_GENERATED_SCENARIO_SETS.gms'

PARAMETER ELECTRICITY_DEMAND(q, s)
/
$ondelim
$include 'AUTO_GENERATED/stateDemandLevels.csv'
$offdelim
/;

PARAMETER WIND(q, s)
/
$ondelim
$include 'AUTO_GENERATED/stateWindLevels.csv'
$offdelim
/;

PARAMETER STATE_DURATION_DAILY(q, d, s)
/
$ondelim
$include 'AUTO_GENERATED/stateDurationsDaily.csv'
$offdelim
/;

PARAMETER STATE_DURATION_MONTHLY(q, p, s)
/
$ondelim
$include 'AUTO_GENERATED/stateDurationsMonthly.csv'
$offdelim
/;

PARAMETER STATE_TRANSITIONS_MONTHLY(q, p, s, ss)
/
$ondelim
$include 'AUTO_GENERATED/stateTransitionsMonthly.csv'
$offdelim
/;