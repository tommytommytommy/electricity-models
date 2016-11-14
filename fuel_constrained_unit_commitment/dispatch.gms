* include costs and parameters from these files, but do not print them to
* the debugging output
$OFFLISTING
$INCLUDE SETS.gms
$INCLUDE TIME.gms
$INCLUDE SCENARIOS.gms
$INCLUDE POWERPLANTS.gms


*** DECISION VARIABLES
VARIABLES
    x(kk, nn, tt, i)        total output of each power plant
    w(kk, nn, tt, i)        output of each power plant above its minimum

    y(kk, nn, tt, i)        start decision
    z(kk, nn, tt, i)        shut down decision
    u(kk, nn, tt, i)        commitment state
    
    f(kk, nn, dd, g)        daily gas usage per firm
    fx_ST(kk, nn, dd, g)    short-term transportation per firm
    
    fx_ST_NA(dd, g)         nonanticipativity for daily pipeline capacity decisions
    
    binaryCost(kk, nn)      binary cost
    gasGenCost(kk, nn, dd)  daily gas generation cost
    scenarioCost(kk, nn)    individual scenario aggregate cost
    totalCost               total cost;

* these variables must be greater than or equal to 0
POSITIVE VARIABLE x, w, y, z, f, fx_ST, fx_ST_NA;

* these variables can only take on a value of 0 or 1
BINARY VARIABLE u;


*** OBJECTIVE FUNCTION AND CONSTRAINTS
EQUATIONS
    objective                           define objective function
    costD(kk,nn)                        individual scenario costs
    costA(kk, nn, dd)                   cost of gas generators
    costB(kk, nn)                       binary costs
    
    demand(kk, nn, tt)                  hourly demand
    eGeneration(kk, nn, tt, i)          calculate hourly individual plant generation levels
    
    commit(kk, nn, tt, i)               commitment decision
    commitB(kk, nn, tt, i)              constrain start variable between 0 and 1
    commitC(kk, nn, tt, i)              constrain stop variable between 0 and 1
    
    eTechMin(kk, nn, tt, i)             minimum output constraints
    eTechMax(kk, nn, tt, i)             maximum output constraints
    
    eMaxDownRamp(kk, nn, tt, i)         minimum ramp constraints
    eMaxUpRamp(kk, nn, tt, i)           maximum ramp constraints
    eMinUpTime(kk, nn, tt, i)           minimum down time
    eMinDownTime(kk, nn, tt, i)         minimum up time

    dailyGasUsage(kk, nn, dd, g)	    daily gas usage
    dailyTransportation(kk, nn, dd, g)  short-term fuel transporation required
    pipeline(kk, nn, dd)                natural gas transportation limit
    
    eNonanticipativityA(kk, nn, dd, g)  non-anticipativity for short-term transportation
    ;    
    
    objective..             
        totalCost =E= sum((kk, nn), P_K(kk) * P_N(nn) * scenarioCost(kk, nn));
    
    costD(kk, nn)..             
        scenarioCost(kk, nn)
        =E= sum((tt, nj), x(kk, nn, tt, nj) * (C_4(nj) * HR(nj) + C_5(nj)))
            + sum(dd, gasGenCost(kk, nn, dd))
            + binaryCost(kk, nn);
                    
    costA(kk, nn, dd)..         
        gasGenCost(kk, nn, dd) 
        =E= sum((tt, j)$hourToDay(tt, dd), x(kk, nn, tt, j) * HR(j) * C_7(dd))
            + sum(g, fx_ST(kk, nn, dd, g)) * C_8(nn, dd);   
                                            
    costB(kk, nn)..
        binaryCost(kk, nn)
        =E= sum((i, tt), 
                u(kk, nn, tt, i) * C_3(i) 
                + y(kk, nn, tt, i) * C_1(i) 
                + z(kk, nn, tt, i) * C_2(i));
                                                                                            
    demand(kk, nn, tt)..        
        sum(i, x(kk, nn, tt, i)) 
        =E= ELECTRICITY_DEMAND(kk, tt) - WIND_GENERATION(kk, tt);
    
    eGeneration(kk, nn, tt, i)..
        x(kk, nn, tt, i) =E= w(kk, nn, tt, i) + u(kk, nn, tt, i) * X_MIN(i);
    
    eTechMax(kk, nn, tt, i)..
        x(kk, nn, tt, i) =L= u(kk, nn, tt, i) * X_MAX(i);

    eTechMin(kk, nn, tt, i)..
        x(kk, nn, tt, i) =G= u(kk, nn, tt, i) * X_MIN(i);

    commit(kk, nn, tt, i)..     
        u(kk, nn, tt, i) =E= u(kk, nn, tt--1, i) + y(kk, nn, tt, i) - z(kk, nn, tt, i);
    
    commitB(kk, nn, tt, i)..
        y(kk, nn, tt, i) =L= 1;
    
    commitC(kk, nn, tt, i)..
        z(kk, nn, tt, i) =L= 1;
    
    eMaxUpRamp(kk, nn, tt, i).. 
        w(kk, nn, tt, i) - w(kk, nn, tt--1, i) =L= R(i);

    eMaxDownRamp(kk, nn, tt, i)..
        w(kk, nn, tt--1, i) - w(kk, nn, tt, i) =L= R(i);
    
    eMinUpTime(kk, nn, tt, i).. 
        u(kk, nn, tt, i)
        =G= sum((ttt)$(ORD(ttt) > ORD(tt) - RR(i) and 
            ORD(ttt) <= ORD(tt)), y(kk, nn, ttt, i));
                                                   
    eMinDownTime(kk, nn, tt, i)..
        1 - u(kk, nn, tt, i)
        =G= sum((ttt)$(ORD(ttt) > ORD(tt) - RR(i) and 
            ORD(ttt) <= ORD(tt)), z(kk, nn, ttt, i));
       
	dailyGasUsage(kk, nn, dd, g)..
		f(kk, nn, dd, g)
		=E= sum((tt, j), x(kk, nn, tt, j)$(hourToDay(tt, dd) AND FIRM(j, g)) * HR(j));       
        
    dailyTransportation(kk, nn, dd, g)..
        fx_ST(kk, nn, dd, g) =G= f(kk, nn, dd, g) - fx_LT(g);
    
    pipeline(kk, nn, dd)..  
        sum(g, fx_ST(kk, nn, dd, g)) =L= PC - GD(nn, dd);

    eNonAnticipativityA(kk, nn, dd, g)..
		fx_ST(kk, nn, dd, g) =E= fx_ST_NA(dd, g);


**** available models
* this is the full fuel-constrained unit commitment model
MODEL fuel_constrained_unit_commitment / all /;

* this model only considers each power plant's operating minimums and maximums
MODEL unit_commitment_simple / objective costD costA costB demand eGeneration eTechMax eTechMin commit commitB commitC /;


*** optimization parameters
* relative difference allowed between the accepted MILP solution 
* and the optimal solution for the fully relaxed problem
OPTION optcr = 0.001;

* maximum time, in seconds, that the solver can run for before GAMS will terminate it
OPTION RESLIM = 3600;

* maximum number of solver iterations allowed before GAMS quits
OPTION ITERLIM = 100000000;

* select which model to solve and which solver to use
* the default MIP solver for GAMS is CPLEX
SOLVE fuel_constrained_unit_commitment USING MIP MINIMIZING totalCost;                              
 
 
*** results output

FILE output_totalCost / output_totalCost.csv /
put output_totalCost;
put "E[totalCost] in dollars";
put /;
put totalCost.l;
putclose output_totalCost;


FILE output_marginalPrices / output_marginalPrices.csv /
put output_marginalPrices;
output_marginalPrices.pw = 100000;
put "E[marginal electricity price]";
put /;
put "hour, dollars per MWh";
put /;
loop(tt,
    put tt.tl;
    put ",";
    put sum([kk, nn], P_K(kk) * P_N(nn) * demand.m(kk, nn, tt));
    put /;
);
putclose output_marginalPrices;


FILE output_dailyPipelineCapacityPurchase / output_dailyPipelineCapacityPurchase.csv /
put output_dailyPipelineCapacityPurchase;
output_dailyPipelineCapacityPurchase.pw = 100000;
put "Pipeline capacity purchase in MMBtu (each row represents: day, [firm's decision])";
put /;

* print header
loop (g,
    put ",";
    put g.tl;
);
put /;

loop(dd,
    put dd.tl;
    put ",";
    loop (g,
        put sum([kk, nn], P_K(kk) * P_N(nn) * fx_ST.l(kk, nn, dd, g));
        put ",";
    );
    put /;
);
putclose output_dailyPipelineCapacityPurchase;


FILE output_generation / output_generation.csv /
put output_generation;
output_generation.pw = 100000;
put "Power plant generation in megawatts (each row represents: hour, [power plant decision])";
put /;

* print header
loop (i,
    put ",";
    put i.tl;
);
put /;

loop(tt,
    put tt.tl;
    put ",";
    loop (i,
        put sum([kk, nn], P_K(kk) * P_N(nn) * x.l(kk, nn, tt, i));
        put ",";
    );
    put /;
);
putclose output_generation;