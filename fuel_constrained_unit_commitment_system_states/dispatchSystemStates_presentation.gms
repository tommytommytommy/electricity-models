* dispatchSystemStates.gms
*
* This is the GAMS code for the system state unit commitment problem with
* long- and medium-term decisions.

$OFFLISTING
$INCLUDE AUTO_GENERATED/OPTIONS.gms

$INCLUDE STATIC_SETS.gms
$INCLUDE SYSTEMSTATES.gms

$INCLUDE POWERPLANTS.gms
$INCLUDE TIME.gms

$INCLUDE GAS.gms
$INCLUDE LTSA.gms
$INCL$INCLUDE 'AUTO_GENERATED/AUTO_GENERATED_SCENARIO_SETS.gms'

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
/;UDE FCM.gms
$INCLUDE AUTO_GENERATED/MAINTENANCE.gms

VARIABLES
	totalCost						objective value;

POSITIVE VARIABLES
	x(q, s, pp, i)					output of each power plant
	w(q, s, pp, i)					output of each power plant above its minimum
	
	y(q, s, ss, pp, i)				start up decision
	z(q, s, ss, pp, i)				shut down decision

	fx_LT(g)						long-term transportation commitment			  
	fx_ST(q, dd, g)					short-term transportation
	f(q, dd, g)						daily fuel use for electricity

	starts(q, j)					total starts
	fh(q, j)						total firing hours
	umd(q, s, pp, j)				product of binary variables u and md	
	mb(q, pp, j)					variable to indicate maintenance
	md(q, pp, j)					maintenance duration
	moc(q, j)						maintenance cost

	binaryCost(q)					binary cost
	gasGenCost(q, dd)				daily gas generation cost	
	scenarioCost(q)					individual scenario aggregate cost	 
	
	fcc_gas(q, aa, g)				maximum gas contribution to fcc decision
	fcc_nongas(q, aa, g)			maximum nongas contribution of fcc decision
	fcc_j(q, dd, j)					daily contribution of gas plant j to forward capacity
	fcc_nj(q, dd, nj)				daily contribution of non-gas plant nj to forward capacity
	fcc(q, aa, g)					anticipative forward capacity commitment
	
	a_ST(q, dd, g)					percentage of daily gas demand purchased in spot market
	a_LT(q, g)						percentage of daily gas demand covered by long-term contracts
	a_min(g)						actual, average percentage of gas met by long-term contracts
	a_dummy(q, g)					dummy variable
	
	fcc_gas_NA(aa, g)				nonanticipativity
	fcc_j_NA(dd, j)					nonanticipativity
	fcc_NA(aa, g)					nonanticipativity
	
	mb_NA(pp, j)					nonanticipativity;
		 
SOS1 VARIABLE mc(j, l)				maintenance contract selection;
		 
BINARY VARIABLES
	u(q, s, pp, i)					commitment state;

INTEGER VARIABLES
 	efhAcc(q, pp, j)				track accumulated equivalent firing hours;

EQUATIONS
	objective						define objective function		
	costD(q)						individual scenario costs
	costA(q, dd)					cost of gas generators
	costB(q)						binary costs
	
	eUMD1(q, s, pp, j)				linearization of u * md
	eUMD2(q, s, pp, j)				linearization of u * md
	eUMD3(q, s, pp, j)				linearization of u * md

	demand(q, s, pp)				state demand balance
	eGenerationA(q, s, pp, nj)		calculate generation levels for non-gas plants
	eGenerationB(q, s, pp, j)		calculate generation levels for gas plants

	commit(q, pp, s, ss, i)			commitment state
	commitB(q, s, ss, pp, i)		startup decision constraint		
	commitC(q, s, ss, pp, i)		shutdown decision constraint

	eTechMax(q, s, pp, i)			technical maximum output	
	eTechMin(q, s, pp, i)			technical minimum output
	
 	eMaintMax(q, s, pp, j)			maintenance duration
	eMaintMin(q, s, pp, j)			maintenance duration
	eMaintPeriod(q, pp, j)			maintenance duration	
	
	eDailyGasUsage(q, dd, g)		natural gas use for each day and scenario
	eDailyTransportation(q, dd, g)	short-term fuel transporation required
	ePipeline(q, dd)				natural gas transportation limit

	eCvarST(q, dd, g)				daily fraction of gas demand met with short-term purchases
	eCvarLT(q, g)					average gas demand met with long-term purchases
	eCvarTargetA(g)					require firms to meet a fraction of gas demand with long-term purchases
	eCvarTargetB(q, g)				require firms to meet a fraction of gas demand with long-term purchases

	eTotalFiringHours(q, j)			total firing hours
	eTotalStarts(q, j)				total starts

	eMaintMIF(q, j, l, h)			LTSA MIF cost allocation
	eMaintSOS(j)					LTSA selection
	
	eMaintEFHLower(q, pp, j)		maintenance group assignment based on equivalent firing hours
	eMaintEFHUpper(q, pp, j)		maintenance group assignment based on equivalent firing hours
	eMaintEFHStart(q, pp, j)		maintenance start based on equivalent firing hours
	eMaintIgnoreA(q, pp, j)	
	eMaintIgnoreB(q, pp, j)
	
 	eFCMTarget(q, aa)				forward capacity target
 	eFCMMaxOfferA(q, aa, g)			sum gas and nongas fwd. capacity offers
 	eFCMMaxOfferB(q, aa, g)			do not allow NSE to make a forward capacity offer
 	eFCMMaxOfferC(q, aa, dd, g)		aggregate non-gas forward capacity limit
 	eFCMMaxOfferD(q, dd, nj)		individual non-gas maximum
	eFCMGasA(q, aa, pp, dd, j)		aggregate gas plant technical max
 	eFCMGasB(q, aa, dd, g)			aggregate plant availability based on maintenance
 	eFCMGasC(q, dd, pp, g)			aggregate gas plant availability based on gas supply
 	eFCMGasD(q, pp, dd, j)			individual gas plant availability based on maintenance
 	
	eFCMNonanticipativityA(q, aa, g)
	eFCMNonanticipativityB(q, aa, g)
	
	eMaintNonanticipativity(q, pp, j);
	
	objective..
		totalCost 
		=E= sum((q), P_Q(q) * scenarioCost(q));		
	
	costD(q)..
		scenarioCost(q) 
		=E= sum(dd, gasGenCost(q, dd))
			+ sum((s, pp, nj), x(q, s, pp, nj) * (C_4(nj) * HR(nj) + C_5(nj)) 
				* STATE_DURATION_MONTHLY(q, pp, s))
			+ binaryCost(q) 
			+ sum(j, moc(q, j))
			+ sum((nj, dd), fcc_nj(q, dd, nj) * C_4(nj) * HR(nj))
			+ sum((j, dd), fcc_j(q, dd, j) * C_7(dd) * HR(j));
	
	costA(q, dd)..
		gasGenCost(q, dd)
		=E= sum(g, f(q, dd, g) * C_7(dd))
			+ sum(g, P_FX_LT * fx_LT(g))
			+ sum(g, C_8(q, dd) * fx_ST(q, dd, g));
	
	costB(q)..
		binaryCost(q) 
		=E= sum((s, pp, nj), 
				u(q, s, pp, nj) * C_3(nj) * STATE_DURATION_MONTHLY(q, pp, s) 
				+ sum(ss, STATE_TRANSITIONS_MONTHLY(q, pp, s, ss) * 
					(y(q, s, ss, pp, nj) * C_1(nj) 
					+ z(q, s, ss, pp, nj) * C_2(nj))))
			+ sum((s, pp, j), 
				umd(q, s, pp, j) * C_3(j) * STATE_DURATION_MONTHLY(q, pp, s) 
				+ sum(ss, STATE_TRANSITIONS_MONTHLY(q, pp, s, ss) * 
					(y(q, s, ss, pp, j) * C_1(j) 
					+ z(q, s, ss, pp, j) * C_2(j))));
		
	eUMD1(q, s, pp, j)..
		umd(q, s, pp, j) =L= u(q, s, pp, j);
	
	eUMD2(q, s, pp, j)..			
		umd(q, s, pp, j) =L= 1 - md(q, pp, j);
			
	eUMD3(q, s, pp, j)..			
		umd(q, s, pp, j) =G= u(q, s, pp, j) - md(q, pp, j);		
	
	demand(q, s, pp)..	
		sum(i, x(q, s, pp, i)) 
		=E= ELECTRICITY_DEMAND(q, s) - WIND(q, s);
	
	eGenerationA(q, s, pp, nj)..
		x(q, s, pp, nj) =E= w(q, s, pp, nj) + X_MIN(nj) * u(q, s, pp, nj);

	eGenerationB(q, s, pp, j)..
		x(q, s, pp, j) =E= w(q, s, pp, j) + X_MIN(j) * u(q, s, pp, j);
 
	eTechMax(q, s, pp, nj)..	
		x(q, s, pp, nj) =L= X_MAX(nj) * u(q, s, pp, nj);

	eTechMin(q, s, pp, nj)..	
		x(q, s, pp, nj) =G= X_MIN(nj) * u(q, s, pp, nj);

	eMaintMax(q, s, pp, j)..
		x(q, s, pp, j) =L= X_MAX(j) * umd(q, s, pp, j);

	eMaintMin(q, s, pp, j)..
		x(q, s, pp, j) =G= X_MIN(j) * umd(q, s, pp, j);

	eMaintPeriod(q, pp, j)..
		md(q, pp, j) 
		=E= sum(ppp$((ORD(ppp) <= ORD(pp)) AND (ORD(ppp) > (ORD(pp) - SMD))), 
				mb(q, ppp, j));		

	commit(q, pp, s, ss, i)..	
		u(q, ss, pp, i) 
		=E= u(q, s, pp, i) + y(q, s, ss, pp, i) - z(q, s, ss, pp, i);

	commitB(q, s, ss, pp, i)..
		y(q, s, ss, pp, i) =L= 1;

	commitC(q, s, ss, pp, i)..
		z(q, s, ss, pp, i) =L= 1;

	eDailyGasUsage(q, dd, g)..	
		f(q, dd, g) 
		=E= sum((i, s, pp)$[dayToPeriod(dd, pp) AND FIRM(i, g) AND j(i)], 
				x(q, s, pp, i) * HR(i) * STATE_DURATION_DAILY(q, dd, s));
																									
	eDailyTransportation(q, dd, g)..
		f(q, dd, g) =L= fx_ST(q, dd, g) + fx_LT(g);
	
 	ePipeline(q, dd)..	
		sum(g, fx_ST(q, dd, g)) =L= (PC - GD(q, dd));

	eCvarST(q, dd, g)$[F_ESTIMATED(q, dd, g) NE 0]..
		a_ST(q, dd, g) =G= 1 - (fx_LT(g) / F_ESTIMATED(q, dd, g));	
		
	eCvarLT(q, g)..
		a_LT(q, g) =E= 1 - sum(dd, a_ST(q, dd, g) / CARD(dd));
	
	eCvarTargetA(g)..
		a_min(g) - sum(q, (P_Q(q) * a_dummy(q, g)) / (1 - BETA(g)))
		=G= A_MIN_TARGET(g);
	
	eCvarTargetB(q, g)..
		a_dummy(q, g) =G= a_min(g) - a_LT(q, g);
	
	eTotalFiringHours(q, j)..		
		fh(q, j) =E= sum(pp, sum(s, umd(q, s, pp, j) * STATE_DURATION_MONTHLY(q, pp, s)));
	
	eTotalStarts(q, j)..
		starts(q, j) =E= sum(pp, sum((s, ss), y(q, s, ss, pp, j) * STATE_TRANSITIONS_MONTHLY(q, pp, s, ss)));

	eMaintMIF(q, j, l, h)$[ORD(h) < CARD(h)]..
		starts(q, j) * C_6(l) * (LTSA(l, h, 'FH') - LTSA(l, h+1, 'FH'))
		- fh(q, j) * C_6(l) * (LTSA(l, h, 'ST') - LTSA(l, h+1, 'ST'))  
		+ moc(q, j) * (LTSA(l, h, 'ST') * LTSA(l, h+1, 'FH') - LTSA(l, h+1, 'ST') * LTSA(l, h, 'FH'))
		=G= BIG_M_50000000 * (mc(j, l) - 1);
		
	eMaintSOS(j)..
		sum(l, mc(j, l)) =E= 1;

	eMaintEFHLower(q, pp, j)$[maintenance(pp) and majorGasPlants(j)]..
		efhAcc(q, pp, j) =G= 
			(sum((s, ss, ppp)$[ORD(ppp) < ORD(pp)], 
				y(q, s, ss, ppp, j) * STATE_TRANSITIONS_MONTHLY(q, ppp, s, ss)) * (MFH / MST)
			+ sum((s, ppp)$[ORD(ppp) < ORD(pp)], 
				umd(q, s, ppp, j) * STATE_DURATION_MONTHLY(q, ppp, s)) 
			- MFH) / MFH;

	eMaintEFHUpper(q, pp, j)$[maintenance(pp) and majorGasPlants(j)]..
		efhAcc(q, pp, j) =L= 
			(sum((s, ss, ppp)$[ORD(ppp) < ORD(pp)], 
				y(q, s, ss, ppp, j) * STATE_TRANSITIONS_MONTHLY(q, ppp, s, ss)) * (MFH / MST)
			+ sum((s, ppp)$[ORD(ppp) < ORD(pp)], 
				umd(q, s, ppp, j) * STATE_DURATION_MONTHLY(q, ppp, s))) / MFH;

	eMaintEFHStart(q, pp, j)$[maintenance(pp) and majorGasPlants(j)]..
		mb(q, pp, j) =E= efhAcc(q, pp, j) - efhAcc(q, pp-1, j);
 				
 	eMaintIgnoreA(q, pp, j)$[not majorGasPlants(j)]..
		mb(q, pp, j) =E= 0;

	eMaintIgnoreB(q, pp, j)$[not majorGasPlants(j)]..
		efhAcc(q, pp, j) =E= 0;
 				
 				
* forward capacity market equations
	eFCMTarget(q, aa).. 
		sum(g, fcc(q, aa, g)) =E= FCM(aa);

	eFCMMaxOfferA(q, aa, g).. 	
		fcc(q, aa, g) =L= fcc_nongas(q, aa, g) + fcc_gas(q, aa, g);
 
	eFCMMaxOfferB(q, aa, g)..
		fcc(q, aa, g) =G= 0;

	eFCMMaxOfferC(q, aa, dd, g).. 	
		fcc_nongas(q, aa, g)$[dayToYear(dd, aa)] 
		=L= sum(nj$FIRM(nj, g), fcc_nj(q, dd, nj));
	
	eFCMMaxOfferD(q, dd, nj)..
		fcc_nj(q, dd, nj) =L= X_MAX(nj);

	eFCMGasA(q, aa, pp, dd, j)..
		fcc_j(q, dd, j) =L= X_MAX(j) * (1 - md(q, pp, j)$[dayToPeriod(dd, pp)]);

	eFCMGasB(q, aa, dd, g)..
		fcc_gas(q, aa, g)$[dayToYear(dd, aa)] =L= sum(j$[FIRM(j, g)], fcc_j(q, dd, j));

	eFCMGasC(q, dd, pp, g)$[dayToPeriod(dd, pp)]..
		sum(j$[FIRM(j, g)], fcc_j(q, dd, j) * HR(j)) * sum(s$[SHORTAGE(q, pp, s)], STATE_DURATION_DAILY(q, dd, s)) 
		=L= fx_LT(g) + fx_ST(q, dd, g);

	eFCMNonanticipativityA(q, aa, g)..
		fcc(q, aa, g) =E= fcc_NA(aa, g);

	eFCMNonanticipativityB(q, aa, g)..
		fcc_gas(q, aa, g) =E= fcc_gas_NA(aa, g);
	
	eMaintNonanticipativity(q, pp, j)..
		mb(q, pp, j) =E= mb_NA(pp, j);

$IFTHEN "%LONG_TERM%" == "YES" 

* form long-term model
MODEL longTerm / objective, costD, costA, costB,
				 eUMD1, eUMD2, eUMD3, 
				 demand, eGenerationA, eGenerationB, 
				 commit, commitB, commitC,
				 eTechMax, eTechMin,
				 eMaintMax, eMaintMin, eMaintPeriod,
				 eDailyGasUsage, eDailyTransportation, ePipeline,
				 eTotalFiringHours, eTotalStarts,
				 eMaintMIF, eMaintSOS,
				 eMaintEFHLower, eMaintEFHUpper, eMaintEFHStart,
				 eMaintIgnoreA, eMaintIgnoreB, 
				 eFCMTarget, eFCMMaxOfferA, eFCMMaxOfferB, eFCMMaxOfferC, eFCMMaxOfferD,
				 eFCMGasA, eFCMGasB, eFCMGasC,
				 eCvarST, eCvarLT, eCvarTargetA, eCvarTargetB,				 
				 eFCMNonanticipativityA, eFCMNonanticipativityB /;
				 eMaintNonanticipativity /;

longTerm.optfile = 0;
longTerm.threads = -1;

* declare output files
FILE results_objective_lt / 'results_objective_lt.csv' /;
put results_objective_lt;
put "P_FX_LT, E[totalCost]";
put /;

FILE results_fx_lt / 'results_fx_lt.csv' /;
put results_fx_lt;
results_fx_lt.pw = 32767;
put "g,P_FX_LT,fx_LT";
put /;

FILE results_mc / 'results_mc.csv' /;
put results_mc;
results_mc.pw = 32767;
put "j, P_FX_LT, mc(1), mc(2)"
put /;

FILE results_fcm_lt / 'results_fcm_lt.csv' /;
put results_fcm_lt;
results_fcm_lt.pw = 32767;
put "q, a, g, P_FX_LT, fcc, x_max, marginalPrice";
put /;

FILE results_maintenance_lt / 'results_maintenance_lt.csv' /;
put results_maintenance_lt;
results_maintenance_lt.pw = 32767;
put "q, P_FX_LT, j, MOC, firing hours, starts";
put /;

FILE results_availableGasCapacity_lt / 'results_availableGasCapacity_lt.csv' /;
put results_availableGasCapacity_lt;
results_availableGasCapacity_lt.pw = 32767;
put "q, P_FX_LT, p, g, gasFiredCapacity";
put /;

FILE results_fuelUsage_lt / 'results_fuelUsage_lt.csv' /;
put results_fuelUsage_lt;
results_fuelUsage_lt.pw = 32767;
put "q, PT_FX_LT, day, firm, f, f_LT, f_ST";
put /;

FILE results_generation_lt / 'results_generation_lt.csv' /;
put results_generation_lt;
results_generation_lt.pw = 32767;
put "q, P_FX_LT, p, g, output";
put /;

FILE results_generation_marginal_prices_lt / 'results_generation_marginal_prices_lt.csv' /;
put results_generation_marginal_prices_lt;
results_generation_marginal_prices_lt.pw = 32767;
put "q, P_FX_LT, p, s, marginal price, time duration";
put /;

FILE results_profits_lt / 'results_profits_lt.csv' /;
put results_profits_lt;
results_profits_lt.pw = 32767;
put "P_FX_LT, g, energy revenue, nonconvex costs, gas costs, non-gas costs, forward capacity revenue";
put /;

FILE results_miscellaneous / 'results_miscellaneous.csv' /;
put results_miscellaneous;
results_miscellaneous.pw = 32767;

FILE results_riskAversion / 'results_riskAversion.csv' /;
put results_riskAversion;
results_riskAversion.pw = 32767;
put "P_FX_LT, alpha, beta, g, fx_lt";
put /;

SET ALPHA_INDEX / 1 /;
SET BETA_INDEX / 1, 5, 9 /;

PARAMETER ALPHA_VALUES(ALPHA_INDEX)
/
1 0.2
*2 0.5
*3 0.9
/;

PARAMETER BETA_VALUES(BETA_INDEX)
/ 
1 0.1
* 2 0.2
* 3 0.3
* 4 0.4
5 0.5
* 6 0.6
* 7 0.7
* 8 0.8
9 0.9
/;

loop(P_FX_LT_INDEX,

* pull out long-term transportation price for this set of runs	
		P_FX_LT = P_FX_LT_RANGE(P_FX_LT_INDEX);

loop (ALPHA_INDEX,
	loop (BETA_INDEX,

		loop(g,
			A_MIN_TARGET(g) = ALPHA_VALUES(ALPHA_INDEX);
			A_MIN_TARGET(g) = ALPHA_VALUES(ALPHA_INDEX);
			BETA(g) = BETA_VALUES(BETA_INDEX);
			BETA(g) = BETA_VALUES(BETA_INDEX);
			);

* model execution
		SOLVE longTerm USING MIP MINIMIZING totalCost;

		put results_riskAversion;
		loop(g,
			put P_FX_LT;
			put ",";			
			put ALPHA_VALUES(ALPHA_INDEX);
			put ",";
			put BETA_VALUES(BETA_INDEX);
			put ","
			put g.tl;
			put ",";
			put fx_LT.l(g);
			put /;
			);		
		);
	);
		
* write out the objective value
		put results_objective_lt;
		put P_FX_LT;
		put ",";
		put totalCost.l;
		put /;
	
* write out long-term fuel commitments
		put results_fx_lt;
		loop(g,
			put g.tl;
			put ",";
			put P_FX_LT;
			put ",";			
			put fx_LT.l(g);
			put /;
			);

* write out long-term maintenance decisions
		put results_mc;
		loop(j,
			put j.tl;
			put ",";
			put P_FX_LT;
			put ",";						
			loop(l$[ORD(l) EQ 1],
				put mc.l(j,l);
				put ",";);
			loop(l$[ORD(l) EQ 2],
				put mc.l(j,l));
			put /;
			);

* write out annual forward capacity commitments and marginal prices
		put results_fcm_lt;

		loop(q,
			loop(aa,
				loop(g,
					put q.tl;
					put ",";
					put aa.tl;
					put ",";
					put g.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";	
					put fcc.l(q, aa, g);
					put ",";
					put sum(i$[FIRM(i, g)], X_MAX(i));
					put ",";
					put eFCMTarget.m(q, aa);
					put /;
					);
				);
			);
		
* write out maintenance results
		put results_maintenance_lt;

		loop(q,
			loop(j,
				put q.tl;
				put ",";
				put P_FX_LT_RANGE(P_FX_LT_INDEX);
				put ",";
				put j.tl;
				put ",";
				put moc.l(q, j);
				put ",";
				put sum((s, pp), umd.l(q, s, pp, j) * STATE_DURATION_MONTHLY(q, pp, s));
				put ",";
				put sum((s, ss, pp), y.l(q, s, ss, pp, j) * STATE_TRANSITIONS_MONTHLY(q, pp, s, ss));
				put /;		
				);
			);		

* write out available gas generation capacity
		put results_availableGasCapacity_lt;

		loop(q,	
			loop(pp,
				loop(g,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put pp.tl;
					put ",";
					put g.tl;
					put ",";
					put sum(j$[FIRM(j, g)], X_MAX(j) * (1-md.l(q, pp, j)));
					put /;
					);
				);
			);		
		
* write out fuel usage
		put results_fuelUsage_lt;
				
		loop(q,	
			loop(dd,
				loop(g,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put dd.tl;
					put ",";
					put g.tl;
					put ",";
					put f.l(q, dd, g);
					put ",";
					put fx_LT.l(g);
					put ",";
					put fx_ST.l(q, dd, g);					
					put /;
					);
				);
			);

* write out power plant generation levels
		put results_generation_lt;
		
		loop(q,
			loop(pp,
				loop(g,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put pp.tl;
					put ",";
					put g.tl;
					put ",";
					put sum((s, i)$FIRM(i, g), x.l(q, s, pp, i) * u.l(q, s, pp, i) * STATE_DURATION_MONTHLY(q, pp, s));
					put /;
					);
				);
			);	

* write out marginal prices for energy
		put results_generation_marginal_prices_lt;
		
		loop(q,
			loop(pp,
				loop(s,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put pp.tl;
					put ",";
					put s.tl;
					put ",";
					put demand.m(q, s, pp);
					put ",";
					put STATE_DURATION_MONTHLY(q, pp, s);
					put /;
					);
				);
			);	

		put results_profits_lt;

		loop(g,
			put P_FX_LT_RANGE(P_FX_LT_INDEX);
			put ",";
			put g.tl;
			put ",";
			put sum((q, pp, s, i)$[FIRM(i, g)], 
						P_Q(q) * x.l(q, s, pp, i) * u.l(q, s, pp, i) * demand.m(q, s, pp));
			put ",";
			put sum(q, P_Q(q) * (sum((s, pp, nj)$FIRM(nj, g), 
				u.l(q, s, pp, nj) * C_3(nj) * STATE_DURATION_MONTHLY(q, pp, s) 
				+ sum(ss, STATE_TRANSITIONS_MONTHLY(q, pp, s, ss) * 
					(y.l(q, s, ss, pp, nj) * C_1(nj) 
					+ z.l(q, s, ss, pp, nj) * C_2(nj))))
				+ sum((s, pp, j)$FIRM(j, g), 
					umd.l(q, s, pp, j) * C_3(j) * STATE_DURATION_MONTHLY(q, pp, s) 
					+ sum(ss, STATE_TRANSITIONS_MONTHLY(q, pp, s, ss) * 
						(y.l(q, s, ss, pp, j) * C_1(j) 
						+ z.l(q, s, ss, pp, j) * C_2(j))))));
			put ",";
			put sum((q, dd), P_Q(q) * (f.l(q, dd, g) * C_7(dd) + P_FX_LT * fx_LT.l(g)));			
			put ",";
			put sum(q, P_Q(q) * (sum((s, pp, nj)$FIRM(nj, g), 
									x.l(q, s, pp, nj) * (C_4(nj) * HR(nj) + C_5(nj)) * STATE_DURATION_MONTHLY(q, pp, s))
									+ sum(j$FIRM(j, g), moc.l(q, j))));
			put ",";			
			put sum((q, aa), P_Q(q) * fcc.l(q, aa, g) * eFCMTarget.m(q, aa));
			put /;
			);

* miscellaneous results
		put results_miscellaneous;

		put "fuel constraint dual variable";
		put /;
		loop(q,
			loop(dd,
				put q.tl;
				put ",";
				put P_FX_LT;
				put ",";
				put dd.tl;
				put ",";
				put ePipeline.m(q, dd);
				put /;
				);
			);
		put //;
		
		put "maintenance start";
		put /;
		loop(q,
			loop(j,
				put q.tl;
				put ",";
				put j.tl;
				put ",";
				put P_FX_LT;
				put ",";	
				loop(pp,
					put mb.l(q, pp, j);
					put ",";
					);
				put /;
				);
			);
		put //;
 
		put "maintenance duration";
		put /;
		loop(q,
			loop(j,
				put q.tl;
				put ",";
				put j.tl;
				put ",";
				put P_FX_LT;
				put ",";	
				loop(pp,
					put md.l(q, pp, j);
					put ",";
					);
				put /;
				);		
			);
		put //;
	 );

putclose results_objective_lt;	
putclose results_fx_lt;
putclose results_mc;
putclose results_fcm_lt;
putclose results_maintenance_lt;
putclose results_availableGasCapacity_lt;
putclose results_fuelUsage_lt;
putclose results_generation_lt;	
putclose results_profits_lt;
putclose results_miscellaneous;	

$ELSE

* form medium-term model
MODEL mediumTerm / objective, costD, costA, costB,
				 eUMD1, eUMD2, eUMD3, 
				 demand, eGenerationA, eGenerationB, 
				 commit, commitB, commitC,
				 eTechMax, eTechMin,
				 eMaintMax, eMaintMin, eMaintPeriod,
				 eDailyGasUsage, eDailyTransportation, ePipeline,
				 eTotalFiringHours, eTotalStarts,
				 eMaintMIF, eMaintSOS, 
*				 eMaintEFHLower, eMaintEFHUpper, eMaintEFHStart, 
*	  			  eMaintIgnoreA, eMaintIgnoreB, 
				 eFCMTarget, eFCMMaxOfferA, eFCMMaxOfferB, eFCMMaxOfferC, eFCMMaxOfferD, 
				 eFCMGasA, eFCMGasB, eFCMGasC, 
				 eFCMNonanticipativityA, eFCMNonanticipativityB, eMaintNonanticipativity /;

mediumTerm.optfile = 0;
mediumTerm.threads = -1;

$onecho > cplex.opt
$offecho

* declare output files
FILE results_objective / 'results_objective.csv' /;
put results_objective;
results_objective.pw = 32767;
put "P_FX_LT, E[totalCost]";
put /;

FILE results_fcm / 'results_fcm.csv' /;
put results_fcm;
results_fcm.pw = 32767;
put "q, a, g, P_FX_LT, fcc, x_max, marginal price";
put /;

FILE results_maintenance / 'results_maintenance.csv' /;
put results_maintenance;
results_maintenance.pw = 32767;
put "q, P_FX_LT, j, MOC, firing hours, starts";
put /;

FILE results_availableGasCapacity / 'results_availableGasCapacity.csv' /;
put results_availableGasCapacity;
results_availableGasCapacity.pw = 32767;
put "q, P_FX_LT, p, g, gasFiredCapacity";
put /;

FILE results_fuelUsage / 'results_fuelUsage.csv' /;
put results_fuelUsage;
results_fuelUsage.pw = 32767;
put "q, PT_FX_LT, day, firm, f, f_LT, f_ST";
put /;

FILE results_generation / 'results_generation.csv' /;
put results_generation;
results_generation.pw = 32767;
put "q, P_FX_LT, p, g, output";
put /;

FILE results_generation_marginal_prices / 'results_generation_marginal_prices.csv' /;
put results_generation_marginal_prices;
results_generation_marginal_prices.pw = 32767;
put "q, P_FX_LT, p, s, marginal price, time duration";
put /;

FILE results_profits / 'results_profits.csv' /;
put results_profits;
results_profits.pw = 32767;
put "P_FX_LT, g, energy revenue, nonconvex costs, gas costs, non-gas costs, forward capacity revenue";
put /;

loop(P_FX_LT_INDEX,

* fix long-term variables
		fx_LT.fx(g) = SOLVED_FX_LT(P_FX_LT_INDEX, g);
		mc.fx(j, l) = SOLVED_MC(P_FX_LT_INDEX, j, l);
		
* solve the medium-term model
		SOLVE mediumTerm USING MIP MINIMIZING totalCost;
	
* write out the objective value
		put results_objective;
		put P_FX_LT;
		put ",";
		put totalCost.l;
		put /;
	
* write out annual forward capacity commitments
		put results_fcm;

		loop(q,
			loop(aa,
				loop(g,
					put q.tl;
					put ",";
					put aa.tl;
					put ",";
					put g.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";	
					put fcc_NA.l(aa, g);
					put ",";
					put sum(i$[FIRM(i, g)], X_MAX(i));
					put ",";					
					put eFCMTarget.m(q, aa);
					put /;
					);
				);
			);

* write out maintenance results
		put results_maintenance;

		loop(q,
			loop(j,
				put q.tl;
				put ",";
				put P_FX_LT_RANGE(P_FX_LT_INDEX);
				put ",";
				put j.tl;
				put ",";
				put moc.l(q, j);
				put ",";
				put sum((s, pp), umd.l(q, s, pp, j) * STATE_DURATION_MONTHLY(q, pp, s));
				put ",";
				put sum((s, ss, pp), y.l(q, s, ss, pp, j) * STATE_TRANSITIONS_MONTHLY(q, pp, s, ss));
				put /;		
				);
			);		

* write out available gas generation capacity
		put results_availableGasCapacity;

		loop(q,	
			loop(pp,
				loop(g,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put pp.tl;
					put ",";
					put g.tl;
					put ",";
					put sum(j$[FIRM(j, g)], X_MAX(j) * (1-md.l(q, pp, j)));
					put /;
					);
				);
			);		
		
* write out fuel usage
		put results_fuelUsage;
				
		loop(q,	
			loop(dd,
				loop(g,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put dd.tl;
					put ",";
					put g.tl;
					put ",";
					put f.l(q, dd, g);
					put ",";
					put fx_LT.l(g);
					put ",";
					put fx_ST.l(q, dd, g);					
					put /;
					);
				);
			);
	
	
* write out power plant generation levels
		put results_generation;
		
		loop(q,
			loop(pp,
				loop(g,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put pp.tl;
					put ",";
					put g.tl;
					put ",";
					put sum((s, i)$FIRM(i, g), x.l(q, s, pp, i) * u.l(q, s, pp, i) * STATE_DURATION_MONTHLY(q, pp, s));
					put /;
					);
				);
			);	

* write out marginal prices for energy
		put results_generation_marginal_prices;
		
		loop(q,
			loop(pp,
				loop(s,
					put q.tl;
					put ",";
					put P_FX_LT_RANGE(P_FX_LT_INDEX);
					put ",";
					put pp.tl;
					put ",";
					put s.tl;
					put ",";
					put demand.m(q, s, pp);
					put ",";
					put STATE_DURATION_MONTHLY(q, pp, s);
					put /;
					);
				);
			);  
			
* write out profits
		put results_profits;

		loop(g,
			put P_FX_LT_RANGE(P_FX_LT_INDEX);
			put ",";
			put g.tl;
			put ",";
			put sum((q, pp, s, i)$[FIRM(i, g)], 
						P_Q(q) * x.l(q, s, pp, i) * u.l(q, s, pp, i) * demand.m(q, s, pp));
			put ",";
			put sum(q, P_Q(q) * (sum((s, pp, nj)$FIRM(nj, g), 
				u.l(q, s, pp, nj) * C_3(nj) * STATE_DURATION_MONTHLY(q, pp, s) 
				+ sum(ss, STATE_TRANSITIONS_MONTHLY(q, pp, s, ss) * 
					(y.l(q, s, ss, pp, nj) * C_1(nj) 
					+ z.l(q, s, ss, pp, nj) * C_2(nj))))
				+ sum((s, pp, j)$FIRM(j, g), 
					umd.l(q, s, pp, j) * C_3(j) * STATE_DURATION_MONTHLY(q, pp, s) 
					+ sum(ss, STATE_TRANSITIONS_MONTHLY(q, pp, s, ss) * 
						(y.l(q, s, ss, pp, j) * C_1(j) 
						+ z.l(q, s, ss, pp, j) * C_2(j))))));
			put ",";
			put sum((q, dd), P_Q(q) * (f.l(q, dd, g) * C_7(dd) + P_FX_LT * fx_LT.l(g)));			
			put ",";
			put sum(q, P_Q(q) * (sum((s, pp, nj)$FIRM(nj, g), 
									x.l(q, s, pp, nj) * (C_4(nj) * HR(nj) + C_5(nj)) * STATE_DURATION_MONTHLY(q, pp, s))
									+ sum(j$FIRM(j, g), moc.l(q, j))));
			put ",";			
			put sum((q, aa), P_Q(q) * fcc.l(q, aa, g) * eFCMTarget.m(q, aa));
			put /;
			);

		
	);

putclose results_objective;
putclose results_fcm;
putclose results_maintenance;
putclose results_availableGasCapacity;
putclose results_fuelUsage;
putclose results_generation;
putclose results_profits;

$ENDIF