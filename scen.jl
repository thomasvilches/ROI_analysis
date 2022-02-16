

#### nonvac doesn't change the behaviour, vaccinated individuals go to a higher level, but oscilates with nonvac, waning immunity both vaccine and rec
dc = [1;map(y-> 79+y,0:5);map(y->125+y,0:9);map(y->165+y,0:13);map(y->202+y,0:40);map(y->289+y,0:14);map(y->318+y,0:39);map(y->394+y,0:10);map(y->425+y,0:14)]#;map(y->386+y,0:8);map(y->424+y,0:14)]#]#;map(y->300+y,0:19);map(y->339+y,0:9)]#;map(y->288+y,0:19);map(y->338+y,0:23)]#;map(y->288+y,0:19);map(y->335+y,0:3)]#;map(y->98+y,0:22);map(y->195+y,0:4);map(y->224+y,0:59);map(y->298+y,0:19)]
rc = [1.0;map(y-> 1.0-(0.07/6)*y,1:6);map(y-> 0.93-(0.07/10)*y,1:10);map(y-> 0.86+(0.037/14)*y,1:14);map(y-> 0.897-(0.312/41)*y,1:41);map(y-> 0.585+(0.28/15)*y,1:15);map(y-> 0.865-(0.23/40)*y,1:40);map(y-> 0.635-(0.06/11)*y,1:11);map(y-> 0.575+(0.1/15)*y,1:15)]#;map(y-> 0.62-(0.045/9)*y,1:9);map(y-> 0.575+(0.075/15)*y,1:15)]#]#;map(y-> 0.407+(0.073/20)*y,1:20);map(y-> 0.48-(0.059/10)*y,1:10)]#;map(y-> 0.532+(0.32/20)*y,1:20);map(y-> 0.852-(0.32/24)*y,1:24)]#;map(y-> 1.05-(0.165/4)*y,1:4)]#;map(y->1.0-(0.143/23)*y,1:23);map(y->0.857+(0.04/5)*y,1:5);map(y->0.897-(0.29/60)*y,1:60);map(y->0.607+(0.30/20)*y,1:20)]
run_param_scen_cal(true,0.11,"newyorkcity",30,1,1,1,1,1,1,rc,dc,200,true)



#### nonvac doesn't change the behaviour, vaccinated individuals go to a higher level, but oscilates with nonvac, waning immunity both vaccine and rec
dc = [1;map(y-> 79+y,0:5);map(y->125+y,0:10);map(y->161+y,0:13);map(y->203+y,0:40);map(y->286+y,0:14);map(y->324+y,0:39);map(y->394+y,0:10);map(y->412+y,0:16);map(y->478+y,0:25)]
rc = [1.0;map(y-> 1.0-(0.07/6)*y,1:6);map(y-> 0.93-(0.077/10)*y,1:11);map(y-> 0.853+(0.047/14)*y,1:14);map(y-> 0.90-(0.24/41)*y,1:41);map(y-> 0.66+(0.27/15)*y,1:15);map(y-> 0.93-(0.19/40)*y,1:40);map(y-> 0.74-(0.06/11)*y,1:11);map(y-> 0.68+(0.08/17)*y,1:17);map(y-> 0.76-(0.42/26)*y,1:26)]
run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,1,rc,dc,528,true)
run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,2,rc,dc,528,false)


