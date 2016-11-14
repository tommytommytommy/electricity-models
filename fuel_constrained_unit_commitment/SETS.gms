SETS   common indices used to demarcate scenarios, time, power plants, and firms

       k                    electricity scenarios           / 1 /
       kk(k)                electricity subset              / 1 /
       
       n                    pipeline capacity scenarios     / 1, 2 /
       nn(n)                pipeline subset                 / 1 /

       t                    hour                            / 1*35064 /                     
       tt(t)                hour subset                     / 1*24 /                    
                                                                                           
       d                    days                            / 1*1461 /                      
       dd(d)                days subset                     / 1 /                          
                                                                                                                                                                                                                                                
       i                    power plants                    / 1,2,3,4,5 /
       j(i)                 gas subset                      / 2,3 /
       nj(i)                nongas subset                   / 1,4,5 /
       g                    individual firms                / 1,2,3,4 / 
                                                                              
                                                                                           
* this alias declares that 'ttt' and 'tt' are equivalent sets and 
* enables the time comparisons needed to enforce minimum power plant
* up and down times
ALIAS(ttt, tt);