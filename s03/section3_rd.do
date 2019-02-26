* Ec1152 - Section 3
* Original dofile and dataset by Greg Bruich, extra commented by Diana

* Starts Stata with a clean slate, in the directory with your data
clear
set more off
capture log close
cd "C:\Users\diana\Google Drive\Ec1152 - Diana sections\Section_03"
* In case you have a Mac, remember that the grammar for directories is different
* cd "/Users/username/ec1152/section"


// Simplified dataset from Lindo, Sanders and Oreopoulos (2010)
use "section3_probation.dta", replace


*********************
* Variable Creation *
*********************
// Create X, our running variable, GPA centered around the cut-off 1.6
gen X = GPA - 1.6
label var X "Distance from GPA cut-off"
// Create indicator for being above probation threshold
gen T = (X > 0)
label var T "Indicator for being above GPA probation threshold"
// Create interaction and quadratic terms 
gen XT = (X * T)
gen X2 = (X * X)
gen X2T = (X2 * T)


***************
* Plot Graphs *
***************
// Binscatter plot for outcome: Probability of graduating in 4 years
binscatter gradin4 X if inrange(X, -1.2, 1.2), rd(0) nq(40)
graph export "graph_gradin4.png", replace

// Covariate tests: high school grades, gender, age starting school, English language
binscatter hsgrade_pct X if inrange(X, -1.2, 1.2), rd(0) nq(40)
graph export "graph_hsgrade_pct.png", replace
binscatter male X if inrange(X, -1.2, 1.2), rd(0) nq(40)
graph export  "graph_male.png", replace
binscatter age_at_entry X if inrange(X, -1.2, 1.2), rd(0) nq(40)
graph export "graph_age_at_entry.png", replace
binscatter english X if inrange(X, -1.2, 1.2), rd(0) nq(40)
graph export "graph_english.png", replace

// Instead, you can do a loop and make your code cleaner.
// The block below makes exactly the same as the block above!
foreach lcovariate of varlist hsgrade_pct male age_at_entry english {
	binscatter `lcovariate' X if inrange(X, -1.2, 1.2), rd(0) nq(40)
	graph export "graph_`lcovariate'.png", replace
}


// Histogram of running variable
#delimit ;
twoway 
	(histogram X if inrange(X, -1.2, 1.2), discrete frequency fcolor(blue%20)), 
	xline(0, lwidth(thick) )
	title("Number of Observations", size(medium) color(black)) 
	ytitle("Number of students") 
	xtitle("Distance from GPA threshold") 
	graphregion(color(white)) bgcolor(white) 
	legend(off); 
#delimit cr
graph export "graph_histogram.png", replace

/*
// McCrary test (Look at density of running variable around cutoff) 
// Note: this will only work if you first copy DCdensity.ado in your ado folder
// the file can be downloaded at https://eml.berkeley.edu/~jmccrary/DCdensity/
// If you dont know where your ado folder is, write 'sysdir' at the Stata prompt
capture drop Xj Yj r0 fhat se_fhat
DCdensity X if inrange(X, -1.2, 1.2), breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
graph export "graph_mccrary.png", replace
*/


********************************
* Regressions at Discontinuity *
********************************
* Regressions, with running varible X already centered at the threshold
// Linear, w/ global bandwidth
regress gradin4 T X XT, robust
// Linear, w/ 1.5 bandwidth
regress gradin4 T X XT  if abs(X)<1.5, robust
// Quadratic w/ global bandwidth
regress gradin4 T X XT X2 X2T, robust

* Test placebo threshold of 1.0
// Create running variable
gen placeboX = GPA - 1
// Create indicator for no probation
gen placeboT = (placebo > 0)
// Interact distace from cut with indicator for no probation
gen placeboXT = (placeboX * placeboT)
// Placebo Regression  
regress gradin4 placeboT placeboX placeboXT if abs(placeboX)<1, robust

* Repeat linear with global bandwidth with Doughnut Hole
gen doughnuthole = 0
replace doughnuthole = 1 if X>=-0.2 & X<=0.2
regress gradin4 T X XT if abs(X)<1.5 & doughnuthole==0, robust

