*---------------------------------------------------------------*
*	     Data task: RA for Professors Nelson and Van Dijk 		*
*					  Magdalena Cortina Toro					*
*---------------------------------------------------------------*

clear all
version 16.1 // on a MAC
set more off

* Setting path
global path = "/Users/magdalena/Library/Mobile Documents/com~apple~CloudDocs/Research/Data tasks/Nelson-van Dijk"
cd "${path}"
import delimited "RA_21_22.csv"

* Creating new variables

gen		total_wealth		= asset_total - debt_total
gen		total_wealth_hs		= asset_housing - debt_housing
gen		non_hs_wealth		= total_wealth - total_wealth_hs
gen		homeowner			= 0
gen		prop_wealth			= total_wealth_hs/total_wealth
replace homeowner = 1 if total_wealth_hs>0

label var	total_wealth	"Total Wealth"
label var	total_wealth_hs	"Total Wealth Housing"
label var	non_hs_wealth	"Non-Housing Wealth"
label var	prop_wealth		"Housing wealth as a proportion of total wealth"
label var	homeowner		"Homeowner"

save dataSCF.dta, replace

* -- 1.  Trends by race and education
*** Collapsing by percentile 50 (median) to get one observatino by year and by race or any other category needed, with weights.
collapse(p50) asset_total asset_housing debt_total debt_housing income total_wealth total_wealth_hs non_hs_wealth [weight=weight], by(year race)

* Figure 1: Median wealth by race
twoway line total_wealth year if race=="Hispanic", lcolor(dkgreen) lwidth(medthick) || ///
	line total_wealth year if race=="black", lcolor(dkgreen) lpattern(dash) lwidth(medthick) || ///
	line total_wealth year if race=="white", lcolor(cranberry) lwidth(medthick) ///
	lcolor(cranberry) lpattern(dash) lwidth(medthick) ///
	clwidth(thick) clcolor(black) title(Median Wealth by Race) ///
	ytitle(Wealth) xtitle(Year) ///
	legend(order(1 "Hispanic" 2 "Black" 3 "White"))

clear all
use "dataSCF.dta"
collapse(p50) asset_total asset_housing debt_total debt_housing income total_wealth total_wealth_hs non_hs_wealth [weight=weight], by(year education)

* Figure 2: Median Wealth by education level
	twoway line total_wealth year if education=="college degree", lcolor(cranberry) lwidth(medthick) || ///
	line total_wealth year if education=="some college", lcolor(dkgreen)  lwidth(medthick) || ///
	line total_wealth year if education=="no college", lcolor(black) lwidth(medthick) ///
	lcolor(cranberry) lpattern(dash) lwidth(medthick) ///
	clwidth(thick) clcolor(black) title(Median Wealth by Education level, size(small)) ///
	ytitle(Wealth) xtitle(Year) ///
	legend(order(1 "College degree" 2 "Some College" 3 "No College"))


* -- 2. Housing wealth,  white and black households
clear all
use "dataSCF.dta"
collapse(p50) asset_total asset_housing debt_total debt_housing income total_wealth total_wealth_hs non_hs_wealth [weight=weight], by(year race)

* Figure 3: Median housing wealth by race
	twoway line total_wealth_hs year if race=="black", lcolor(dkgreen) lwidth(medthick) || ///
	line total_wealth_hs year if race=="white", lcolor(cranberry) lwidth(medthick) ///
	title(Median Housing Wealth by Race) ///
	ytitle(Wealth) xtitle(Year) ///
	legend(order(1 "Black" 2 "White"))

* Figure 4: Median Housing wealth by race and education level
clear all
use "dataSCF.dta"
collapse(p50) asset_total asset_housing debt_total debt_housing income total_wealth total_wealth_hs non_hs_wealth [weight=weight], by(year race education)

keep if race=="white" | race=="black"
	twoway line total_wealth_hs year if education=="college degree", lcolor(cranberry) lwidth(medthick) || ///
	line total_wealth_hs year if education=="some college", lcolor(dkgreen)  lwidth(medthick) || ///
	line total_wealth_hs year if education=="no college", by(race) lcolor(black) lwidth(medthick) ///
	lcolor(cranberry) lpattern(dash) lwidth(medthick) ///
	clwidth(thick) clcolor(black) ///
	ytitle(Wealth) xtitle(Year) ///
	legend(order(1 "College degree" 2 "Some College" 3 "No College"))

* --  3. Housing wealth, 25-year-old and older homeowners only

clear all
use "dataSCF.dta"

** restricting the data
keep if homeowner==1
keep if age> =25
keep if race=="white" | race=="black"

collapse (median) prop_wealth total_wealth total_wealth_hs non_hs_wealth, by(year race)

* Figure 5: median housing wealth of homeowners by race
	twoway  line total_wealth_hs year if race=="white", lcolor(cranberry) lwidth(medthick) || ///
			line total_wealth_hs year if race=="black", lcolor(black) lwidth(medthick) title("Median Housing Wealth by Race: 1989-2016", size(medium)) xline(2007) ///
			ytitle(Median Wealth, size(small)) xtitle(Year) note(Only 25-year-old and older homeowners) legend(order(1 "Housing Wealth (Black)" 2 "Housing Wealth (White)" ))



* figure 6: Housing wealth as a proportion of Total Wealth, by race
twoway		line prop_wealth year if race=="black", lcolor(cranberry) lwidth(medthick) || ///
			line prop_wealth year if race=="white", lcolor(black) lwidth(medthick) title("Median Total Wealth by Race: 1989-2016", size(medium)) ///
			ytitle(Median Wealth, size(small)) xtitle(Year) note(All observations are in USD. Only 25-year-old and older homeowners) legend(order(1 "Total Wealth (Black)" 2 "Total Wealth (White)" ))
			
list year total_wealth_hs if race=="white"







