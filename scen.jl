
#############################

#461

#### nonvac doesn't change the behaviour, vaccinated individuals go to a higher level, but oscilates with nonvac, waning immunity both vaccine and rec
dc = [1;map(y-> 79+y,0:5);map(y->125+y,0:9);map(y->164+y,0:13);map(y->202+y,0:31);map(y->291+y,0:14);map(y->318+y,0:59);map(y->421+y,0:5)]#]#;map(y->300+y,0:19);map(y->339+y,0:9)]#;map(y->288+y,0:19);map(y->338+y,0:23)]#;map(y->288+y,0:19);map(y->335+y,0:3)]#;map(y->98+y,0:22);map(y->195+y,0:4);map(y->224+y,0:59);map(y->298+y,0:19)]
rc = [1.0;map(y-> 1.0-(0.07/6)*y,1:6);map(y-> 0.93-(0.07/10)*y,1:10);map(y-> 0.86+(0.04/14)*y,1:14);map(y-> 0.9-(0.32/32)*y,1:32);map(y-> 0.58+(0.24/15)*y,1:15);map(y-> 0.82-(0.24/60)*y,1:60);map(y-> 0.58+(0.04/6)*y,1:6)]#]#;map(y-> 0.407+(0.073/20)*y,1:20);map(y-> 0.48-(0.059/10)*y,1:10)]#;map(y-> 0.532+(0.32/20)*y,1:20);map(y-> 0.852-(0.32/24)*y,1:24)]#;map(y-> 1.05-(0.165/4)*y,1:4)]#;map(y->1.0-(0.143/23)*y,1:23);map(y->0.857+(0.04/5)*y,1:5);map(y->0.897-(0.29/60)*y,1:60);map(y->0.607+(0.30/20)*y,1:20)]
run_param_scen_cal(true,0.11,"newyorkcity",30,1,1,1,1,1,125,999,173,7,999,1,2,14,rc,dc,461,true,999,1,1)
run_param_scen_cal(true,0.11,"newyorkcity",30,1,1,1,1,1,125,999,173,7,999,2,2,14,rc,dc,461,false,999,1,1)
