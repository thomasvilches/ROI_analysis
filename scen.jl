
#### nonvac doesn't change the behaviour, vaccinated individuals go to a higher level, but oscilates with nonvac, waning immunity both vaccine and rec
dc = [1;map(y-> 79+y,0:5);map(y->125+y,0:10);map(y->161+y,0:13);map(y->203+y,0:40);map(y->286+y,0:14);map(y->324+y,0:39);map(y->394+y,0:10);map(y->412+y,0:16);map(y->478+y,0:25)]
rc = [1.0;map(y-> 1.0-(0.07/6)*y,1:6);map(y-> 0.93-(0.077/10)*y,1:11);map(y-> 0.853+(0.047/14)*y,1:14);map(y-> 0.90-(0.24/41)*y,1:41);map(y-> 0.66+(0.27/15)*y,1:15);map(y-> 0.93-(0.19/40)*y,1:40);map(y-> 0.74-(0.06/11)*y,1:11);map(y-> 0.68+(0.08/17)*y,1:17);map(y-> 0.76-(0.42/26)*y,1:26)]
run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,1,rc,dc,528,true)
run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,2,rc,dc,528,false)



#### nonvac doesn't change the behaviour, vaccinated individuals go to a higher level, but oscilates with nonvac, waning immunity both vaccine and rec
dc = [1;map(y-> 79+y,0:5);map(y->125+y,0:10);map(y->161+y,0:13);map(y->203+y,0:40);map(y->286+y,0:14);map(y->322+y,0:39);map(y->394+y,0:10);map(y->430+y,0:16);map(y->478+y,0:25)]
rc = [1.0;map(y-> 1.0-(0.07/6)*y,1:6);map(y-> 0.93-(0.077/10)*y,1:11);map(y-> 0.853+(0.047/14)*y,1:14);map(y-> 0.90-(0.24/41)*y,1:41);map(y-> 0.66+(0.27/15)*y,1:15);map(y-> 0.93-(0.19/40)*y,1:40);map(y-> 0.74-(0.06/11)*y,1:11);map(y-> 0.68+(0.08/17)*y,1:17);map(y-> 0.76-(0.43/26)*y,1:26)]
run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,3,rc,dc,528,true)

run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,4,rc,dc,528,false)



#### nonvac doesn't change the behaviour, vaccinated individuals go to a higher level, but oscilates with nonvac, waning immunity both vaccine and rec 46 32
dc = [1;map(y-> 79+y,0:5);map(y->125+y,0:10);map(y->161+y,0:13);map(y->203+y,0:40);map(y->286+y,0:14);map(y->322+y,0:39);map(y->394+y,0:10);map(y->470+y,0:27)]
rc = [1.0;map(y-> 1.0-(0.07/6)*y,1:6);map(y-> 0.93-(0.077/10)*y,1:11);map(y-> 0.853+(0.047/14)*y,1:14);map(y-> 0.90-(0.24/41)*y,1:41);map(y-> 0.66+(0.27/15)*y,1:15);map(y-> 0.93-(0.19/40)*y,1:40);map(y-> 0.74-(0.06/11)*y,1:11);map(y-> 0.68-(0.417/28)*y,1:28)]
run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,5,rc,dc,528,true,441,40) 

#441 40 / 470 27 0.405
# 470 28 0.42
run_param_scen_cal(true,0.1088,"newyorkcity",30,1,1,1,1,1,6,rc,dc,528,false,441,40) 

