setwd("~/PosDoc/Coronavirus/ROI/Code/")
library(dplyr)
library(xlsx)
library(readxl)
# Parameters -------------------------------------------------------------------

#Total cost of vaccine clinic setup 
cost_setup = 3022840

#Expenditure on advertisement and awareness campaigns
cost_advertisement = 242986305.11 #242,986,305.11
#Total cost of vaccine storage and transport 
cost_storage_and_transport = 7205179.89
#Cost of vaccine administration (all other costs) 
cost_administration = 1752152923.18 #1,752,152,923.18
#Other vaccination expenses (mobile and homebound vaccinations) 
#Expenses that will benefit all vaccinations. ie. CIR, DOITT developed applications
expenses_benefits = 31000000
# Total cost of vaccines
vaccines_cost = 282663374.8 #282,663,374.8


#Indirect costs
pcpi_nyc = 74472 ## Per-capita personal income NYC
perc_vac_emp = 0.7176 ## proportion of vaccinated people that is employed (18-64 yo)
wdl_vac = 0.5 #work days lost due to visit for vaccination
pm_adverse_1 = 0.517 #proportion of adverse reaction First dose Moderna
pm_adverse_2 = 0.748 #proportion of adverse reaction First dose Moderna
pp_adverse_1 = 0.48 #proportion of adverse reaction First dose Moderna
pp_adverse_2 = 0.642 #proportion of adverse reaction First dose Moderna
pjj_adverse = 0.76 #proportion of adverse reaction First dose Moderna
wdl_adverse_1 = 1.66 #(sd = 1.48)working days lost due to adverse reactions first dose
wdl_adverse_2 = 1.39 #(sd = 0.82)working days lost due to adverse reactions

#Direct costs
cost_outpatient_appointment = 1020.1 #outpatient appointment (symptomatic cases)
n_outpatient_visits = 0.5 #(total number of mild cases / 2) per mild case - ASSUMED
cost_transp_outpatients = 44.49 #for each visit
cost_hosp_nICU = 39499.18 #cost of hospital non-ICU admission
cost_hosp_ICU = 113249.31 #cost of ICU admission
n_ED_visits = 1 #for each severe non-hospitalized case- ASSUMED
cost_ED_care = 3305.01 #cost ED care
n_EMS_calls = 2.5 #per hospitalized case
cost_transp_EMS = 900
cost_lifelost = 455484 #per year of life lost #average of statistical life in US is
# between US$ 9-10 mi with life expectancy of 79 years - REVISE

# Cost of Illness

symp_isolation = 10 #days out of work
# hospitalization - take it from JAMA paper and add another 4 days
duration_hosp_niCU = c(6,6,6,6,6,3) #data for each strain for non-ICU
duration_ICU = c(15,15,15,15,15,7)  #data for each strain for ICU
days_beforeafter = 3.5+4


basedate = as.Date("2020-09-01")
basedate_vac = as.Date("2020-12-14")
enddate = as.Date("2022-01-31")
population = 8336817


idx_1 = 1
idx_2 = 2
#  Reading file function -----------------------------------------------------------------

# Let's create a function to read the incidence file

  read_file_incidence <- function(index,type,strain = c(1,2,3,4,5,6),st2 = "newyorkcity",beta = "121",ag="all"){
    
    data.cases1 = read.table(paste0("data/results_prob_0_",beta,"_",index,"_",st2,"/simlevel_",type,"_inc_",ag,".dat"),',',h = T) 
    data.cases1 = data.cases1[,-1]
    
    data.cases2 = read.table(paste0("data/results_prob_0_",beta,"_",index,"_",st2,"/simlevel_",type,"2_inc_",ag,".dat"),',',h = T) 
    data.cases2 = data.cases2[,-1]
    
    data.cases3 = read.table(paste0("data/results_prob_0_",beta,"_",index,"_",st2,"/simlevel_",type,"3_inc_",ag,".dat"),',',h = T) 
    data.cases3 = data.cases3[,-1]
    
    data.cases4 = read.table(paste0("data/results_prob_0_",beta,"_",index,"_",st2,"/simlevel_",type,"4_inc_",ag,".dat"),',',h = T) 
    data.cases4 = data.cases4[,-1]
    
    data.cases5 = read.table(paste0("data/results_prob_0_",beta,"_",index,"_",st2,"/simlevel_",type,"5_inc_",ag,".dat"),',',h = T) 
    data.cases5 = data.cases5[,-1]
    
    data.cases6 = read.table(paste0("data/results_prob_0_",beta,"_",index,"_",st2,"/simlevel_",type,"6_inc_",ag,".dat"),',',h = T) 
    data.cases6 = data.cases6[,-1]
    
    l = list(data.cases1,data.cases2,data.cases3,data.cases4,data.cases5,data.cases6)
    
    return(l[strain])
  }

# And a function to bootstrap 
  
  fc <- function(d, i){
    return(mean(d[i]))
  }

# Vaccination costs (direct) ----------------------------------------------

# This is using the data about expenses provided by NYC
direct_vaccination_cost = cost_setup+cost_administration+cost_advertisement+
  cost_storage_and_transport+expenses_benefits+vaccines_cost

# Vaccination costs (indirect) -------------------------------------------------------
# calculate the loss of workdays to go to get vaccine from 15-64 y.o.
## Let's read the data that was provided
data_vac = read_excel("data/NYC_Daily_COVID-19_Vax_by_UHF_AgeGroup_2022-02-08_1500.xlsx")
head(data_vac)
tail(data_vac)

#data_vac %>% mutate(DATE = as.Date(DATE)) %>% ggplot()+geom_line(aes(x = DATE,y = N_FULLY_VACCINATED,color = AGE_GROUP))

#clean the number 999
data_vac = data_vac[data_vac$UHF != 999,]
### let's take the sum of facilities
data = data_vac %>% group_by(AGE_GROUP) %>% summarise(partially = sum(N_PARTIALLY_VACCINATED), fully = sum(N_FULLY_VACCINATED))
data
# The age groups are not exactly what we need, but let's use it anyway. 
# This is conservative (overestimates the vaccination cost)

# We want to calculate the number of working days that were spent due to vaccination

working_group = c("15to24","25to44","45to64")
n_vacs_first = sum(data$partially[data$AGE_GROUP %in% working_group])
n_vacs_second = sum(data$fully[data$AGE_GROUP %in% working_group])
# We need to do the same for booster dose

data_booster = read.csv("data/Demo_additional_dose_age_2022-02-08_1500.csv",sep = ";")
head(data_booster)
tail(data_booster)

data_booster$DATE = as.Date(data_booster$DATE)

data_booster_total = data_booster %>% filter(DATE >= as.Date("2020-12-14"), RESIDENCY == "NYC") %>%
  group_by(AGE_GROUP) %>% summarise(total_b = sum(N_ADDITIONAL_VACCINATED))

data_booster_total

working_group = c("18to24","25to34","35to44","45to54","55to64")
n_vacs_booster = sum(data_booster_total$total_b[data_booster_total$AGE_GROUP %in% working_group])
n_days_vac = (n_vacs_first+n_vacs_second+n_vacs_booster)*wdl_vac*perc_vac_emp

# Now, for adverse reaction, we need to calculate the proportion
# of each vaccine that was administered

#Let's read the data

data = read.csv("data/Dose_admin_bymonth_2022-02-08_1500.csv",sep = ";")

# we need to add Janssen to second dose, to be able to use it for fully vaccinated
# in the next section
df = data %>% group_by(VAC_CODE) %>% 
  summarise(total = sum(ALL_DOSES),
            first = sum(ADMIN_DOSE1),
            second  = sum(ADMIN_DOSE2)+sum(ADMIN_SINGLE), booster = sum(ADMIN_ADDITIONAL))

# The total number is in df
vaccines = c("Janssen","Moderna","Pfizer")
pp = df %>% filter(VAC_CODE %in% vaccines)

first = pp$first/sum(pp$first)
second = pp$second/sum(pp$second)
boost = pp$booster/sum(pp$booster)

# number of working days lost due to vaccination
n_days_ad_jensen = (n_vacs_second*second[1]*wdl_adverse_1+n_vacs_booster*boost[1]*wdl_adverse_2)*pjj_adverse*perc_vac_emp
n_days_ad_moderna = 
  (n_vacs_second*second[2]+n_vacs_booster*boost[2])*wdl_adverse_2*pm_adverse_2*perc_vac_emp+
  n_vacs_first*first[2]*wdl_adverse_1*pm_adverse_1*perc_vac_emp
n_days_ad_pfizer = 
  (n_vacs_second*second[3]+n_vacs_booster*boost[3])*wdl_adverse_2*pp_adverse_2*perc_vac_emp+
  n_vacs_first*first[3]*wdl_adverse_1*pp_adverse_1*perc_vac_emp

# total
n_days_work_lost = n_days_vac+n_days_ad_pfizer+n_days_ad_jensen+n_days_ad_moderna

indirect_vaccination_cost = n_days_work_lost*pcpi_nyc/365

# COVID-19 costs ----------------------------------------------------------

# We need to read the real data, re-scale the hospitalization, and rework the
# other outcomes


# Download data from NYC Health Department
temp <- tempfile()
download.file("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/data-by-day.csv",temp)
data.cases <- read.csv(temp,h=T,stringsAsFactors = F)
unlink(temp)
rm(temp)

head(data.cases) # we can see that date is in the wrong format, and let's filter
# from Sept 01, 2020 - Jan 31, 2022
#create collumns with incidence of cases, deaths and hospitalization
data.cases = data.cases %>% mutate(date_of_interest=as.Date(date_of_interest,"%m/%d/%Y")) %>%
  filter(date_of_interest >= basedate,date_of_interest<=enddate) %>%
  mutate(inc_cases = CASE_COUNT+PROBABLE_CASE_COUNT,
         inc_deaths=DEATH_COUNT+PROBABLE_DEATH_COUNT,
         inc_hosp = HOSPITALIZED_COUNT) %>% select(date_of_interest,inc_cases,inc_deaths,inc_hosp)
head(data.cases)



# Illness and Hospitalization (direct) ---------------------------------------------------------

# we want to see the hospitalization scaling factor

#total hospitalization per 100,000 population from the beginning of vaccination
total_hosp = data.cases %>% filter(date_of_interest >= basedate_vac,date_of_interest <= enddate) %>% pull(inc_hosp) %>% sum()/population*100000
total_hosp

#Let's see this number in the simulation

hos_sim = read_file_incidence(idx_1,"hos")
icu_sim = read_file_incidence(idx_1,"icu")

hos = Reduce('+', hos_sim) # adding the strains
icu = Reduce('+', icu_sim)# adding the strains
nn = nrow(hos)
  
v_date = basedate+seq(0,nn-1) #creating a vector with the dates of simulation


sum.sim.hos = sum(hos[v_date >= basedate_vac & v_date <= enddate,])/ncol(hos)
sum.sim.icu = sum(icu[v_date >= basedate_vac & v_date <= enddate,])/ncol(icu)

factor_hos = total_hosp/(sum.sim.hos+sum.sim.icu)
factor_hos

asymp = Reduce('+',read_file_incidence(idx_1,"asymp")) # adding the strains
inf = Reduce('+',read_file_incidence(idx_1,"inf")) # adding the strains
mild = Reduce('+',read_file_incidence(idx_1,"mild")) # adding the strains

# Let's set inf to be severe non-hospitalized
inf_nh = inf - hos - icu
# number of extra hospitalization after scaling
n_extra = (sum.sim.hos+sum.sim.icu)*factor_hos - (sum.sim.hos+sum.sim.icu)

#total number
sum.sim.asymp = sum(asymp[v_date >= basedate_vac & v_date <= enddate,])/ncol(asymp)
sum.sim.mild = sum(mild[v_date >= basedate_vac & v_date <= enddate,])/ncol(mild)
sum.sim.sev = sum(inf_nh[v_date >= basedate_vac & v_date <= enddate,])/ncol(inf_nh)

factor_non_hos = (sum(c(sum.sim.asymp,sum.sim.mild,sum.sim.sev))-n_extra)/sum(c(sum.sim.asymp,sum.sim.mild,sum.sim.sev))

# Now we want to bootstrap the mean of those matrices

sum.sim = colSums(mild)
sum.sim.mild = boot::boot(sum.sim,fc,100)$t[,1]

sum.sim = colSums(inf_nh)
sum.sim.inf = boot::boot(sum.sim,fc,100)$t[,1]

sum.sim = colSums(hos)
sum.sim.hos = boot::boot(sum.sim,fc,100)$t[,1]

sum.sim = colSums(icu)
sum.sim.icu = boot::boot(sum.sim,fc,100)$t[,1]

# we increased the hospitalizations by some amount, therefore,
# we decrease the other infections proportionately

sum.sim.mild = sum.sim.mild*factor_non_hos
sum.sim.inf = sum.sim.inf*factor_non_hos

sum.sim.hos = sum.sim.hos*factor_hos
sum.sim.icu = sum.sim.icu*factor_hos


#cost mild infection of hospital
cost_symp = (sum.sim.mild)*
  n_outpatient_visits*(cost_outpatient_appointment+cost_transp_outpatients)
#cost severe non-hospitalized infection
cost_inf = (sum.sim.inf)*cost_ED_care
#cost for hospitalizations
cost_hos = (sum.sim.hos)*(cost_hosp_nICU+n_EMS_calls*cost_transp_EMS)
cost_icu = (sum.sim.icu)*(cost_hosp_ICU+n_EMS_calls*cost_transp_EMS)

cost_hospital = (cost_symp+cost_inf+cost_hos+cost_icu)*population/100000
cost_hospital

###
# For the SCENARIO without vaccination
###

hos_sim = read_file_incidence(idx_2,"hos")
icu_sim = read_file_incidence(idx_2,"icu")

hos = Reduce('+', hos_sim) # adding the strains
icu = Reduce('+', icu_sim)# adding the strains

nn = nrow(hos)
v_date = basedate+seq(0,nn-1) #creating a vector with the dates of simulation

sum.sim.hos2 = sum(hos[v_date >= basedate_vac & v_date <= enddate,])/ncol(hos)
sum.sim.icu2 = sum(icu[v_date >= basedate_vac & v_date <= enddate,])/ncol(icu)


asymp = Reduce('+',read_file_incidence(idx_2,"asymp")) # adding the strains
inf = Reduce('+',read_file_incidence(idx_2,"inf")) # adding the strains
mild = Reduce('+',read_file_incidence(idx_2,"mild")) # adding the strains

# Let's set inf to be severe non-hospitalized
inf_nh = inf - hos - icu
# number of extra hospitalization after scaling
n_extra = (sum.sim.hos2+sum.sim.icu2)*factor_hos - (sum.sim.hos2+sum.sim.icu2)

#total number
sum.sim.asymp2 = sum(asymp[v_date >= basedate_vac & v_date <= enddate,])/ncol(asymp)
sum.sim.mild2 = sum(mild[v_date >= basedate_vac & v_date <= enddate,])/ncol(mild)
sum.sim.sev2 = sum(inf_nh[v_date >= basedate_vac & v_date <= enddate,])/ncol(inf_nh)

factor_non_hos = (sum(c(sum.sim.asymp2,sum.sim.mild2,sum.sim.sev2))-n_extra)/sum(c(sum.sim.asymp2,sum.sim.mild2,sum.sim.sev2))


# Bootstraping

sum.sim = colSums(mild)
sum.sim.mild2 = boot::boot(sum.sim,fc,100)$t[,1]

sum.sim = colSums(inf_nh)
sum.sim.inf2 = boot::boot(sum.sim,fc,100)$t[,1]

sum.sim = colSums(hos)
sum.sim.hos2 = boot::boot(sum.sim,fc,100)$t[,1]

sum.sim = colSums(icu)
sum.sim.icu2 = boot::boot(sum.sim,fc,100)$t[,1]

# we increased the hospitalizations by some amount, therefore,
# we decrease the other infections proportionately

sum.sim.mild2 = sum.sim.mild2*factor_non_hos
sum.sim.inf2 = sum.sim.inf2*factor_non_hos

sum.sim.hos2 = sum.sim.hos2*factor_hos
sum.sim.icu2 = sum.sim.icu2*factor_hos

#cost mild infection of hospital
cost_symp = (sum.sim.mild2)*
     n_outpatient_visits*(cost_outpatient_appointment+cost_transp_outpatients)
#cost severe non-hospitalized infection
cost_inf = (sum.sim.inf2)*cost_ED_care
#cost for hospitalizations
cost_hos = (sum.sim.hos2)*(cost_hosp_nICU+n_EMS_calls*cost_transp_EMS)
cost_icu = (sum.sim.icu2)*(cost_hosp_ICU+n_EMS_calls*cost_transp_EMS)

cost_hospital2 = (cost_symp+cost_inf+cost_hos+cost_icu)*population/100000
cost_hospital2

boxplot(cost_hospital2-cost_hospital)


# Illness and Hospitalization (indirect) ---------------------------------------------------------
# 
# LOS: 
#   https://www.medrxiv.org/content/10.1101/2022.01.11.22269045v1
# 
# https://stacks.cdc.gov/view/cdc/113758
# https://stacks.cdc.gov/view/cdc/114452
# REVIEW this code March 10

cost_indirect_ill1 = (sum.sim.mild+sum.sim.inf+sum.sim.hos+sum.sim.icu)*population/100000*symp_isolation*pcpi_nyc/365
cost_indirect_ill2 = (sum.sim.mild2+sum.sim.inf2+sum.sim.hos2+sum.sim.icu2)*population/100000*symp_isolation*pcpi_nyc/365


# Years of Life Lost ------------------------------------------------------

#fist of all, let's find the scaling factor for deaths.

deaths = read_file_incidence(idx_1,"ded")
ded = Reduce('+', deaths)
nn = nrow(ded)
v_date = basedate+seq(0,nn-1) #creating a vector with the dates of simulation
sum.sim.ded = sum(ded[v_date >= basedate_vac & v_date <= enddate,])/ncol(ded)
total_deaths = data.cases %>% filter(date_of_interest >= basedate_vac,date_of_interest <= enddate) %>% pull(inc_deaths) %>% sum()/population*100000
total_deaths
factor_deaths = total_deaths/sum.sim.ded


# Let's read the file containing the amount of people that died at age x in each sim

age_of_death= read.table("data/results_prob_0_121_1_newyorkcity/year_of_death.dat",h=F)
dim(age_of_death)

life_exp = read.csv("data/life_exp.csv",sep = ";",h=F)$V2[1:nrow(age_of_death)]

vyll = as.vector(life_exp %*% as.matrix(age_of_death))

vyll1 = boot::boot(vyll,fc,100)$t[,1]



age_of_death= read.table("data/results_prob_0_121_2_newyorkcity/year_of_death.dat",h=F)
dim(age_of_death)

vyll = as.vector(life_exp %*% as.matrix(age_of_death))

vyll2 = boot::boot(vyll,fc,100)$t[,1]


cost_yll1 = (vyll1)*cost_lifelost*population/100000*factor_deaths
cost_yll2 = (vyll2)*cost_lifelost*population/100000*factor_deaths


cost_yll1 = (vyll1)*126000*population/100000*factor_deaths
cost_yll2 = (vyll2)*126000*population/100000*factor_deaths



# Results -----------------------------------------------------------------

#Initial Value Investment
IVI = direct_vaccination_cost
total_cost_vaccination = indirect_vaccination_cost+cost_hospital+cost_indirect_ill1+cost_yll1
total_cost_no_vac = cost_hospital2+cost_indirect_ill2+cost_yll2

# Final value of investiment
FVI = total_cost_no_vac - total_cost_vaccination
ROI = (FVI - IVI)/IVI
total_cost_no_vac
total_cost_vaccination

df = data.frame(cost = c(total_cost_vaccination,total_cost_no_vac),
                scen= c(rep("Vaccination",length(total_cost_vaccination)),rep("No Vaccination",length(total_cost_no_vac))))

boxplot(ROI)




# Better plot -------------------------------------------------------------

factor_cost = total_cost_no_vac/total_cost_vaccination

total_cost_no_vac2 = total_cost_no_vac
total_cost_vaccination2 = total_cost_vaccination*4

df = data.frame(cost = c(total_cost_vaccination2,total_cost_no_vac2),
                scen= c(rep("Vaccination",length(total_cost_vaccination2)),rep("No Vaccination",length(total_cost_no_vac2))))
# 


ggplot(df)+
  geom_violin(aes(x = cost/(1e9), y = scen, fill = scen), size=1, alpha = 0.7)+
  geom_jitter(aes(x = cost/(1e9), y = scen, fill = scen, shape = scen),size=2)+
  scale_x_continuous(sec.axis = sec_axis(~./4,name = "Cost of vaccination scenario (billion US$)"))+
  scale_y_discrete(label = NULL)+
  scale_shape_manual(values = c(21,22),name = NULL)+
  scale_fill_manual(values = c("#7846B4","#82B446"),name = NULL)+
  labs(x="Cost of no-vaccination scenario (billion US$)",y=NULL)+
  theme_bw()+theme(legend.position = "bottom",axis.title = element_text(face="bold"),
                   axis.text.x = element_text(colour="black", size = 15),
                   axis.ticks.y = element_line(size = NA),
                   axis.line.x.top = element_line(color = alpha("#82B446",0.6),size = 1.5),
                   axis.line.x.bottom = element_line(color = alpha("#7846B4",0.6),size = 1.5),
                   axis.text.y.left = element_text(colour="black", size = 14,angle=90,hjust = 0.5),
                   axis.text.y.right = element_text(colour="black", size = 14,angle=270,hjust = 0.5),
                   axis.title.y = element_text(colour="black", size = 18),
                   axis.title.x = element_text(colour="black", size = 18),
                   legend.title = element_text(face="bold",size = 18),
                   legend.text = element_text(size = 14),
                   plot.margin = unit(c(1,0.8,0.2,0.9), "cm"))
ggsave(
  "../figures/cost3.pdf",
  device = "pdf",
  width = 6,
  height = 5,
  dpi = 300,
)

ggsave(
  "../figures/cost3.png",
  device = "png",
  width = 6,
  height = 5,
  dpi = 300,
)




percentage_cost = (total_cost_no_vac - (total_cost_vaccination-direct_vaccination_cost)/direct_vaccination_cost
percentage_cost

dd = as.data.frame(percentage_cost)

ggplot(dd)+
  geom_violin(aes(x = percentage_cost, y = "t"), size=1, fill = "#FF330000", alpha = 0.7)+
  geom_jitter(aes(x = percentage_cost, y = "t"),size=2)+
  scale_y_discrete(label = NULL)+
  scale_shape_manual(values = c(21,22),name = NULL)+
  scale_fill_manual(values = c("#FF33FF","#33FFFF"),name = NULL)+
  labs(x="Proportion of savings",y=NULL)+
  theme_bw()+theme(legend.position = "bottom",axis.title = element_text(face="bold"),
                   axis.text.x = element_text(colour="black", size = 15),
                   axis.ticks.y = element_line(size = NA),
                   axis.text.y.left = element_text(colour="black", size = 14,angle=90,hjust = 0.5),
                   axis.text.y.right = element_text(colour="black", size = 14,angle=270,hjust = 0.5),
                   axis.title.y = element_text(colour="black", size = 18),
                   axis.title.x = element_text(colour="black", size = 18),
                   legend.title = element_text(face="bold",size = 18),
                   legend.text = element_text(size = 14),
                   plot.margin = unit(c(1,0.8,0.2,0.9), "cm"))


