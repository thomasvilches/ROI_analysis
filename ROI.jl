using Parameters
using DataFrames
using CSV
using DelimitedFiles
using Bootstrap

@with_kw mutable struct ROIParameters @deftype Float64

    state::Symbol = :newyorkcity
    population::Int64 = 8336817

    wastage_prop = 0.05
    buffer_stock_prop = 0.05

    cost_pfizer = 19.5
    cost_moderna = 15.0
    cost_JJ = 10.0

    loss_vac_day = 0.5 #number of days lost for getting the shot
    
    #adverse reaction
    moderna_first_AR = 0.517
    pfizer_first_AR = 0.48
    JJ_first_AR = 0.76

    moderna_second_AR = 0.748
    pfizer_second_AR = 0.642
    lost_days_AR = 2.0 #Number of working days lost due to reaction

    #####
    governamental_costs = 1.8e7 ###need to look at the table and calculate it
    cost_loss_day = 100.0 ##GDP based

    ##
    lost_days_symptomatic = 10.0 ##we must be carefull
    hosp_daily_cost = 1000.0
    icu_daily_cost = 2000.0

    hosp_cost = 66265.521
    icu_cost = 215655.624

    prop_long_treatment = 0.5
    long_covid_treatment_cost = 10000.0
    disability_weight = 0.5

    number_of_outpatient_visits = 1.0
    cost_visit = 2481.153
end

const p_roi =  ROIParameters()

###ROI

function simulation_outcome(path::String)
    
    factor_pop = p_roi.population/100000
    ###prevalence of infections in working-age group

    ###Should we use symp and sev? or just Latent? what are the problems?

    prev_symp = readdlm("$path/simlevel_symp_prev_working.dat",delim = ",",header = true)
    prev_sev = readdlm("$path/simlevel_sev_prev_working.dat",delim = ",",header = true)
    prev_hosp = readdlm("$path/simlevel_hos_prev_working.dat",delim = ",",header = true)
    prev_icu = readdlm("$path/simlevel_icu_prev_working.dat",delim = ",",header = true)

    total_days_symp_w = map(x-> sum(prev_symp[:,x])*factor_pop,2:size(prev_symp,2))#sum(prev_symp[:,2:end],dims=1)
    total_days_sev_w = map(x-> sum(prev_sev[:,x])*factor_pop,2:size(prev_sev,2))
    total_days_hosp_w = map(x-> sum(prev_hosp[:,x])*factor_pop,2:size(prev_hosp,2))
    total_days_icu_w = map(x-> sum(prev_icu[:,x])*factor_pop,2:size(prev_icu,2))

    ### total symptomatic infections/ hospital admission in working-age group
    prev_symp = readdlm("$path/simlevel_symp_inc_working.dat",delim = ",",header = true)
    prev_sev = readdlm("$path/simlevel_sev_inc_working.dat",delim = ",",header = true)
    prev_hosp = readdlm("$path/simlevel_hos_inc_working.dat",delim = ",",header = true)
    prev_icu = readdlm("$path/simlevel_icu_inc_working.dat",delim = ",",header = true)
    
    total_symp_w = map(x-> sum(prev_symp[:,x])*factor_pop,2:size(prev_symp,2))#sum(prev_symp[:,2:end],dims=1)
    total_sev_w = map(x-> sum(prev_sev[:,x])*factor_pop,2:size(prev_sev,2))
    total_hosp_w = map(x-> sum(prev_hosp[:,x])*factor_pop,2:size(prev_hosp,2))
    total_icu_w = map(x-> sum(prev_icu[:,x])*factor_pop,2:size(prev_icu,2))



    ############################################################
    ################# For entire population ####################
    ############################################################

    prev_symp = readdlm("$path/simlevel_symp_prev_all.dat",delim = ",",header = true)
    prev_sev = readdlm("$path/simlevel_sev_prev_all.dat",delim = ",",header = true)
    prev_hosp = readdlm("$path/simlevel_hos_prev_all.dat",delim = ",",header = true)
    prev_icu = readdlm("$path/simlevel_icu_prev_all.dat",delim = ",",header = true)

    total_days_symp = map(x-> sum(prev_symp[:,x])*factor_pop,2:size(prev_symp,2))#sum(prev_symp[:,2:end],dims=1)
    total_days_sev = map(x-> sum(prev_sev[:,x])*factor_pop,2:size(prev_sev,2))
    total_days_hosp = map(x-> sum(prev_hosp[:,x])*factor_pop,2:size(prev_hosp,2))
    total_days_icu = map(x-> sum(prev_icu[:,x])*factor_pop,2:size(prev_icu,2))

    ### total symptomatic infections/ hospital admission in all-age group

    prev_symp = readdlm("$path/simlevel_symp_inc_all.dat",delim = ",",header = true)
    prev_sev = readdlm("$path/simlevel_sev_inc_all.dat",delim = ",",header = true)
    prev_hosp = readdlm("$path/simlevel_hos_inc_all.dat",delim = ",",header = true)
    prev_icu = readdlm("$path/simlevel_icu_inc_all.dat",delim = ",",header = true)
    prev_ded = readdlm("$path/simlevel_ded_inc_all.dat",delim = ",",header = true)
    
    total_symp = map(x-> sum(prev_symp[:,x])*factor_pop,2:size(prev_symp,2))#sum(prev_symp[:,2:end],dims=1)
    total_sev = map(x-> sum(prev_sev[:,x])*factor_pop,2:size(prev_sev,2))
    total_hosp = map(x-> sum(prev_hosp[:,x])*factor_pop,2:size(prev_hosp,2))
    total_icu = map(x-> sum(prev_icu[:,x])*factor_pop,2:size(prev_icu,2))
    total_deaths = map(x-> sum(prev_ded[:,x])*factor_pop,2:size(prev_ded,2))

    
    vaccines = readdlm("$path/vaccine_all.dat")
    
    vaccines_pfizer_1 = vaccines[:,1]*factor_pop
    vaccines_moderna_1 = vaccines[:,2]*factor_pop
    vaccines_JJ_1 = vaccines[:,3]*factor_pop
    vaccines_pfizer_2 = vaccines[:,4]*factor_pop
    vaccines_moderna_2 = vaccines[:,5]*factor_pop
    vaccines_JJ_2 = vaccines[:,6]*factor_pop


    vaccines_pfizer = vaccines_pfizer_1+vaccines_pfizer_2
    vaccines_moderna = vaccines_moderna_1+vaccines_moderna_2
    vaccines_JJ = vaccines_JJ_1+vaccines_JJ_2


    vaccines = readdlm("$path/vaccine_working.dat")
    
    vaccines_w_pfizer_1 = vaccines[:,1]*factor_pop
    vaccines_w_moderna_1 = vaccines[:,2]*factor_pop
    vaccines_w_JJ_1 = vaccines[:,3]*factor_pop
    vaccines_w_pfizer_2 = vaccines[:,4]*factor_pop
    vaccines_w_moderna_2 = vaccines[:,5]*factor_pop
    vaccines_w_JJ_2 = vaccines[:,6]*factor_pop

    vaccines_w_pfizer = vaccines_w_pfizer_1+vaccines_w_pfizer_2
    vaccines_w_moderna = vaccines_w_moderna_1+vaccines_w_moderna_2
    vaccines_w_JJ = vaccines_w_JJ_1+vaccines_w_JJ_2


    ########### years of work lost


    years_w_lost = readdlm("$path/year_of_work.dat")[:,1]
    



    return (total_days_symp_w,total_days_sev_w,total_days_hosp_w,total_days_icu_w,
    total_symp_w,total_sev_w,total_hosp_w,total_icu_w,
    total_days_symp,total_days_sev,total_days_hosp,total_days_icu,
    total_symp,total_sev,total_hosp,total_icu,
    vaccines_w_pfizer,vaccines_w_moderna,vaccines_w_JJ,vaccines_pfizer,vaccines_moderna,vaccines_JJ,
    vaccines_w_pfizer_1,vaccines_w_moderna_1,vaccines_w_JJ_1,vaccines_pfizer_1,vaccines_moderna_1,vaccines_JJ_1,
    vaccines_w_pfizer_2,vaccines_w_moderna_2,vaccines_w_JJ_2,vaccines_pfizer_2,vaccines_moderna_2,vaccines_JJ_2,
    total_deaths,years_w_lost)
end





p_roi.state = "newyorkcity"

folder = "./results_1_$(p_roi.state)" ##supposing index 1 for status quo scenario with vaccination
df_sq = simulation_outcome(folder)


#### No vaccination scenario
folder = "./results_2_$(p_roi.state)" ##supposing index 2 for counterfactual scenario without vaccination
df_cf = simulation_outcome(folder)


df = df_sq

direct_cost_vaccination = p_roi.cost_JJ*df.vaccines_JJ+p_roi.cost_pfizer*df.vaccines_pfizer+p_roi.cost_moderna*df.vaccines_moderna
direct_cost_vaccination *= 1+p_roi.wastage_prop+p_roi.buffer_stock_prop
direct_cost_vaccination += p_roi.cost_delivery_per_dose*(df.vaccines_moderna+df.vaccines_pfizer+df.vaccines_w_JJ)
direct_cost_vaccination += p_roi.governamental_costs #advertisement etc

indirect_cost_vaccination = p_roi.loss_vac_day*p_roi.cost_loss_day*(df.vaccines_w_JJ+df.vaccines_w_pfizer+df.vaccines_w_moderna)+p_roi.cost_loss_day*p_roi.lost_days_AR*(p_roi.JJ_first_AR*df.vaccines_w_JJ_1+p_roi.pfizer_first_AR*df.vaccines_w_pfizer_1+p_roi.moderna_first_AR*df.vaccines_w_moderna_1+p_roi.pfizer_second_AR*df.vaccines_w_pfizer_2+p_roi.moderna_second_AR*df.vaccines_w_moderna_2)


### Cost of COVID-19 illness and hospitalization
###first of all, we need to make sure that hospitalization is in the right scale, that is, the status quo and the data match

data_file = "../incidence_$(p_roi.state).csv"

data = CSV.read(data_file,DataFrame) #make sure it is in a CSV file

total_hosp_data = sum(data.inc_hosp) ###calculate the total number of hospitalization from data. make sure the collumn name is right (when we get the data)
mean_hosp_simulation = mean(df_sq.total_hosp+df_sq.total_icu) #calculate the average number of hospitalization
factor_hosp = total_hosp_data/mean_hosp_simulation

total_death_data = sum(data.inc_deaths) ###calculate the total number of hospitalization from data. make sure the collumn name is right (when we get the data)
mean_death_simulation = mean(df_sq.total_deaths) #calculate the average number of hospitalization
factor_death = total_death_data/mean_death_simulation


### Let's calculate the illness / disease cost for both scenarios
df = df_sq
total_illness_cost_sq = (df.total_symp+df.total_sev)*p_roi.number_of_outpatient_visits*(p_roi.cost_visit+p_roi.transportation_cost) ##medical visit
#total_illness_cost_sq += p_roi.hosp_daily_cost*df.total_days_hosp*factor_hosp+p_roi.icu_daily_cost*df.total_days_icu*factor_hosp ##hospital admission
total_illness_cost_sq += p_roi.hosp_cost*df.total_hosp*factor_hosp+p_roi.icu_cost*df.total_icu*factor_hosp ##hospital admission

#total_illness_cost_sq += p_roi.prop_long_treatment*p_roi.long_covid_treatment_cost*(df.total_sev+df.total_symp-df.total_deaths) ###long treatment
#total_illness_cost_sq += df.years_w_lost*365*p_roi.cost_loss_day #cost for years of work 
total_illness_cost_sq += (df.total_symp_w+df.total_sev_w)*p_roi.lost_days_symptomatic*p_roi.cost_loss_day # cost for symptomatic isolation
##need finish
#total_illness_cost_sq += (df.total_symp_w+df.total_sev_w)*p_roi.prop_long_treatment*p_roi.disability_weight*

### Let's calculate the illness / disease cost for both scenarios
df = df_cf
total_illness_cost_cf = (df.total_symp+df.total_sev)*p_roi.number_of_outpatient_visits*(p_roi.cost_visit+p_roi.transportation_cost) #medical visit
total_illness_cost_cf += p_roi.hosp_daily_cost*df.total_days_hosp*factor_hosp+p_roi.icu_daily_cost*df.total_days_icu*factor_hosp #hospitalization
total_illness_cost_cf += p_roi.prop_long_treatment*p_roi.long_covid_treatment_cost*(df.total_sev+df.total_symp-df.total_deaths) #long treatment
#total_illness_cost_cf += df.years_w_lost*365*p_roi.cost_loss_day #cost for years of work 
total_illness_cost_cf += (df.total_symp_w+df.total_sev_w)*p_roi.lost_days_symptomatic*p_roi.cost_loss_day # cost for symptomatic isolation
#need finish
#total_illness_cost_cf += (df.total_symp_w+df.total_sev_w)*p_roi.prop_long_treatment*p_roi.disability_weight*

