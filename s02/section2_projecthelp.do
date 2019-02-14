* Ec1152 - Section 2
* Original dofile and dataset by Greg Bruich, extra commented by Diana

* Starts Stata with a clean slate, in the directory with your data
clear
set more off
cap log close
* In case you have a PC, change the directory using something like
* cd "C:\Users\username\ec1152\section"
* In case you have a Mac, the grammar for directories is a little different
* cd "/Users/username/ec1152/section"
cd "C:\Users\diana\Dropbox\Documentos\GitHub\Ec1152_diana\s02"

* This will create a "recording" of your commands
log using stata_workshop.log, replace

* Opens our dataset [that you have downloaded on the above folder]
use "data\atlas_ranks.dta", replace

* List data for one place
* This example is for Harvard Yard, its full census tract is 25017353700. 
* That is, state 25, county 017, tract 353700 (2 digits state + 3 digits county + 6 digits tract)
list kfr_pooled* ranks_pooled* if (state==25 & county==17 & tract==353700)

* Calculate non-weighted summary stats
summarize kfr_pooled_p25
summarize kfr_pooled_p25 if state==25
summarize kfr_pooled_p25 if (state==25 & county==17)

* Calculate weighted summary stats
sum kfr_pooled_p25 [aw = count_pooled]
sum kfr_pooled_p25 if state==25 [aw = count_pooled]
sum kfr_pooled_p25 if state==25 & county==17  [aw = count_pooled]

* Run regression to ask whether places that are better for poor kids are better for rich kids
// All the US at once (we didnt ask for this)
regress kfr_pooled_p25 kfr_pooled_p75, robust
twoway (scatter kfr_pooled_p25 kfr_pooled_p75)
graph export "graphs\ugly_scatter1.png", replace

// Just for my county
regress kfr_pooled_p25 kfr_pooled_p75 if (state==25 & county==17), robust
twoway (scatter kfr_pooled_p25 kfr_pooled_p75 if (state==25 & county==17))
graph export "graphs\ugly_scatter2.png", replace

// Makes a nicer graph by customizing options
// This is not needed, but makes it nicer. Check section1 do file as well.
#delimit ;
twoway 
	(lfitci kfr_pooled_p25 kfr_pooled_p75 if (state==25 & county==17) , fcolor(%50) alcolor(%50)) 
	(scatter kfr_pooled_p25 kfr_pooled_p75 if (state==25 & county==17) , mcolor(navy%50) msymbol(circle_hollow) ), 
	ytitle("HH income of Kids with Parents' Rank = 25") 
	xtitle("HH income of Kids with Parents' Rank = 75") 
	legend(off)
	graphregion(color(white)) bgcolor(white) ;
;
#delimit cr 
graph export "graphs\nicer_scatter.png", replace

* Correlations
corr kfr_pooled_p25 kfr_pooled_p75 emp2000 job_density_2013

* Install this package that will do what you want
// net install pr0041.pkg
// help corrci
corrci kfr_pooled_p25 kfr_pooled_p75 emp2000 job_density_2013, level(95)


* You should do more stuff in here... Like doing the correlations only for your county
* testing other graphs and correlating other variables. Explore!


* The end! Those next lines are not really needed
capture log close
exit
