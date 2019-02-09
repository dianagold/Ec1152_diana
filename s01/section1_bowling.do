* Ec1152 - Section 1
* Original dofile and dataset by Greg Bruich, extra commented by Diana

* It's a great habit to always put a heading on your dofiles
* Anything starting with * is a comment
// Anything starting with // is also comment
* To ease reading, commands are written in full, but Stata understands abbreviations
* such as 'reg' = regress; 'corr' = correlate; 'gen' = generate

* Starts Stata with a clean slate, in the directory with your data
clear
set more off
capture log close
* In case you have a PC, change the directory using something like
* cd "C:\Users\username\ec1152\section"
cd "C:\Users\diana\Dropbox\Documentos\GitHub\Ec1152_sections\s01"
* In case you have a Mac, the grammar for directories is a little different
* cd "/Users/username/ec1152/section"

* Opens our dataset [that you have downloaded on the above folder]
use "data\section1_bowling.dta", replace

* Runs a regression without standardizing variables
regress e_rank_b bowl_per_capita, robust
predict yhat

* Correlation between the variables
correlate e_rank_b bowl_per_capita

* Standardize variables
summarize e_rank_b 
generate y_std = (e_rank_b - r(mean))/r(sd)
summarize bowl_per_capita 
generate x_std = (bowl_per_capita - r(mean))/r(sd)

* Runs a regression with standardized variables
regress y_std x_std,  robust

* Graphs can be made on the fly, like
scatter e_rank_b bowl_per_capita 

* To draw multiple things in the same graph, you can use twoway
twoway (lfitci e_rank_b bowl_per_capita) (scatter e_rank_b bowl_per_capita)


* But you can customize options so they look much nicer
* when you start adding options, to avoid having loooong lines, you break them
* note that 3/ is a break, but 2/ is a comment!
twoway (lfitci e_rank_b bowl_per_capita) (scatter e_rank_b bowl_per_capita), ///
	ytitle("Mean Rank of Kids with Parents' Rank = 25") ///
	xtitle("Number of Bowling Alleys (per 10,000 people)") ///
	xlabel(0(0.2)1.4) 


* When you know you'll break multiple times, you can use #delimit once instead
* Graph showing our regression in a much nicer way
#delimit ;
twoway 
(lfitci e_rank_b bowl_per_capita , fcolor(%50) alcolor(%50) range(0 1.4)) 
	(scatter e_rank_b bowl_per_capita , mcolor(navy%50) msymbol(circle_hollow) ), 
	ytitle("Mean Rank of Kids with Parents' Rank = 25") 
	xtitle("Number of Bowling Alleys (per 10,000 people)") 
	xlabel(0(0.2)1.4) 
	legend(off) 
	graphregion(color(white)) bgcolor(white) ;
;
#delimit cr 
* This line saves the graph to your working dir
graph export "graphs\stata_regression.png", replace

* Doing a similar regression graph, but using the standardized variables
#delimit ; 
twoway 
(lfitci y_std x_std , fcolor(%50) alcolor(%50) range(-1.3 3.4)) 
	(scatter y_std x_std , mcolor(navy%50) msymbol(circle_hollow) ) 
	, ytitle("Standardized Mean Rank of Kids with Parents' Rank = 25") 
	xtitle("Standardized Number of Bowling Alleys (per 10,000 people)") 
	legend(off) 
	graphregion(color(white)) bgcolor(white) ;
;
#delimit cr 
graph export "graphs\stata_std_regression.png", replace

* The end! Those next lines are not really needed
capture log close
exit

/*
Another way to comment out
very useful if you have many lines
that you wish to keep in place
*/
