# electricity-models

## Fuel-constrained unit commitment model
Inside the `fuel_constrained_unit_commitment` directory, this repository contains a mixed-integer linear program that describes a fuel-constrained, unit commitment problem for electricity markets. It assumes a welfare-maximizing central planner that makes decisions for all firms, power plants, and consumers in the system. The model formulation supports multiple probabilistic scenarios for electricity demand and available natural gas pipeline capacity by describing the corresponding deterministic equivalent problem. The model formulation also separates power plants by firm, allowing firm-level decisions, such as long-term pipeline capacity purchases, to influence the unit commitment problem.

For a detailed explanation about this model, as well as an overview of the natural gas and electricity problems that motivated its creation, see [https://www.tommyleung.com/dissertation](https://www.tommyleung.com/dissertation).

### How to run the fuel-constrained unit commitment model
This model is written in [GAMS](http://gams.com/) and has been successfully solved using CPLEX. The primary model file is dispatch.gms and should run as is by invoking GAMS with the dispatch file (for example, `gams dispatch.gms`).

This repository contains a small set of data inputs to illustrate how the model works. These inputs describe power plant operating characteristics and important elements about the electricity/gas physical system, such as the hourly electricity demand, hourly wind generation, and daily available natural gas pipeline capacity. The input files are only provided as example data for demonstration and include the following:

1. input_electricityDemand.csv: total electricity demand by hour
2. input_electricityWindGeneration.csv: total wind generation by hour
3. input_gasCommodityPrice.csv: natural gas commodity price by day
4. input_gasTransportationPrice.csv: natural gas transportation price by day
5. input_longtermFirmPipelineCapacity.csv: the amount of long-term, firm natural gas pipeline capacity available to each firm on a daily basis
6. input_nonelectricGasDemand.csv: the amount of natural gas demanded by all other non-electric sectors by day


Inside the `fuel_constrained_unit_commitment/power_plant` directory, these files describe the physical characteristics of each power plant in the system:

1. input_powerPlantsCommitmentCost.csv: the fixed cost required to keep a power plant running on an hourly basis
2. input_powerPlantsFirms.csv: a map that describes which firms own which power plants
3. input_powerPlantsFuelCost.csv: the unit cost of fuel for non-gas-fired power plants
4. input_powerPlantsHeatRate.csv: the amount of fuel that each plant requires to generate a MWh of electricity
5. input_powerPlantsMinUpDown.csv: the minimum time that each power plant must stay on for, once started
6. input_powerPlantsOperationAndMaintenanceCost.csv: a variable cost for each power plant that approximates its maintenance costs
7. input_powerPlantsRamp.csv: the maximum change possible in generation output for a power plant from one hour to the next
8. input_powerPlantsStartCost.csv: the cost of starting each power plant if that plant is off in the previous hour
9. input_powerPlantsStopCost.csv: the cost of stopping each power plant if that plant is on in the previous hour
10. input_powerPlantsXMax.csv: the maximum generation capacity of each power plant
11. input_powerPlantsXMin.csv: the minimum generation level required for each power plant if that plant is turned on

After successfully running the model, GAMS will create in the same directory the following comma-separated-value output files based on the optimal solution:

1. output_totalCost.csv: the objective value of the final solution.
2. output_marginalPrices.csv: the marginal price for each hour.
3. output_dailyPipelineCapacityPurchase.csv: each firm's daily, non-firm pipeline capacity purchases for natural gas.
4. output_generation.csv: each power plant's hourly generation level.

## Fuel-constrained, system-states unit commitment model
The `fuel_constrained_unit_commitment_system_states` directory contains a long-term example of a system-states based unit commitment model that runs over three years across six possible demand and pipeline scenarios for about two hundred power plants. This directory contains a full implementation of the model described in [http://dspace.mit.edu/handle/1721.1/98547](http://dspace.mit.edu/handle/1721.1/98547), with a single example set of inputs. It demonstrates how to convert the hourly fuel-constrained unit commitment problem into the system-states formulation, though it is much less easy to interpret and study given all of the additional embellishments related to long-term pipeline capacity contracts and power plant maintenance.