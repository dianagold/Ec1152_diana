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

collapse (mean) mortrate, by(age_at_d)

generate log_mortrate = log(mortrate)
regress log_mortrate age_at_d

set obs 76
replace age_at_d=_n+39 if missing(age_at_d)

predict log_mortrate_gomp
generate mortrate_gomp = exp(log_mortrate_gomp)

generate survival_gomp = 1 if age==40
replace survival_gomp = survival_gomp[_n-1] * ( 1 - mortrate_gomp[_n-1] ) if age>40

sum survival_gomp if age>40

display "Estimated life expectancy:"
display 40 + r(sum)


