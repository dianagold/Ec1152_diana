* Ec1152 - Section 6
* Starts Stata with a clean slate, in the directory with your data
clear
set more off
cap log close
* In case you have a PC, change the directory using something like
// cd "C:\Users\username\ec1152\section"
* In case you have a Mac, the grammar for directories is a little different
// cd "/Users/username/ec1152/section"
cd "C:\Users\diana\Google Drive\Ec1152 - Diana sections\Section_06"

* load the data, clearing any data file already open
use "mskd_national_mortratesBY_gnd_hhincpctile_age_year.dta", clear 


* The goal of this exercise is to comment each line below
* to ensure you understand what is being done at each step


* make a dataset of mean mortality rates by age at death for both men and women
collapse (mean) mortrate, by(age_at_d)
* men only, substitute for:
// collapse (mean) mortrate if gnd == "M", by(age_at_d) 
* women only, substitute for:
// collapse (mean) mortrate if gnd == "F", by(age_at_d) 

* generate a new variable containing the log of the mortality rate
generate log_mortrate = log(mortrate)

* Estimate the parameters of the Gompertz model by regressing log mortality rate on age of death 
regress log_mortrate age_at_d

* set the number of observations (aka _N) as 76 rather than 37
* this alows us to fill in missing data up to age 115
set obs 76

* create values for age of death up through age 115
replace age_at_d=_n+39 if missing(age_at_d)

* create fitted (estimated) values of log mortality rate at each age using 
* the parameter estimates from the Gompertz model regression and store these 
* values in a new variable called "log_mortrate_gomp"
predict log_mortrate_gomp

* create a new variable "mortrate_gomp" of the estimated mortlaity rates from
* the Gompertz model by exponentiating log_mortrate_gomp
generate mortrate_gomp = exp(log_mortrate_gomp)

* generate a new variable that contains estimated survival rates called "survival_gomp"
* that takes the value 1 at age 40 (assume survival to age 40).
generate survival_gomp = 1 if age==40

* fill in estimated survival rates between ages 41 and 115
replace survival_gomp = survival_gomp[_n-1] * ( 1 - mortrate_gomp[_n-1] ) if age>40

* present summary statistics of survival rates after age 40
sum survival_gomp if age>40

* display estimated life expectancy by taking 40 and adding sum of survival 
* probabilities between ages 41 and 115
*note: r(sum) stores the sum of the values of survival_gomp if age>40
* from the summarize command run on line 100
display "Estimated life expectancy:"
display 40 + r(sum)


