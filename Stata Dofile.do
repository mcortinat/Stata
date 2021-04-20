*---------------------------------------------------------------*
*	Data analysis Research Specialist with Johannes Haushofer	*
*						Monday, Febuary 15						*
*				Written in Stata 16.1 on a Mac					*
*---------------------------------------------------------------*

clear all
version 16.1
set more off



* Setting path
global path = "/Users/magdalena/Library/Mobile Documents/com~apple~CloudDocs/Research/LEAP Applicant Task 2021/"
cd "${path}"

* Importing dataset
use "${path}cashtransfers.dta"

*--		1.		---------------------------------------------------------*

* Table to check if randomization was succesful:

ttable2 latitud age gender education, by(treat) 


*--		2.		---------------------------------------------------------*

codebook wvs_happiness // it has the correct labels
codebook wvs_life_sat // it doesn't have value labels

label define 	life_sat 1 "Completely dissatisfied" 10 "Completely satisfied"
label values 	wvs_life_sat life_sat 

* Defining global of outcomes separeted between psychological and household consumption

	global X1	=	"wvs_happiness wvs_life_sat"
	global X2	=	"cons_food cons_social cons_total"

* Regression for psychological effect of the treatment

foreach i of global X1{
	reg `i' treat, vce(cl village)
	est sto reg_`i'
}

* Effects of the cash transfers on hoseholds in treatment villages who were not selected to receive the transfer. 
* (Spilovers)

foreach z of global X2{
	reg `z' purecontrol, vce(cl village)
	est sto reg_`z'
}

* Exporting regression of psychological outcomes
esttab 	reg_wvs_happiness reg_wvs_life_sat using reg_psy.tex, se r2 ar2 label title(Psychological effects of Cash Transfers) replace 

esttab 	reg_cons_food reg_cons_social reg_cons_total using reg_house.tex, se r2 ar2 label title(Household consumption effects of Cash Transfers) addnotes(Control villages: households in treatment villages who were not selected to receive the transfer.) replace 

*--		3.		---------------------------------------------------------*

* Merging villages dataset

* Checking for alphabetical order of villages on "cashtransfers" dataset 
decode village, generate(village1)
sort village1   // Ordering aphabetically the villages
encode village1, gen(village_number)   //  encoding alphabetically
save "${path}cashtransfers_2.dta", replace

* Checking for alphabetical order of villages on "villages" dataset
import excel "${path}villages.xls", sheet("Sheet1") firstrow clear
encode village, gen(village_number)   // Ordering aphabetically the villages
save villages.dta, replace

* Merging 
merge m:m village_number using "/Users/magdalena/Library/Mobile Documents/com~apple~CloudDocs/Research/LEAP Applicant Task 2021/cashtransfers_2.dta", force

* Estimating the effect of the treatment on the price index
reg 	v_price_index treat, vce(cl village_number)
est 	sto reg_price
esttab 	reg_price using reg_price.tex, se r2 ar2 label title(Price Level Effects of the Cash Transfers) replace 


*--		4.		---------------------------------------------------------*

* I didn't have enough time for this question, and for some reason every Stata resource webpage was not working (I double checked in different browsers), so I lost a lot of time and couldn't find a useful resource. I didn't know how to code this part by hard.


*--		BONUS		-----------------------------------------------------*

label define 	Treatment 1 "Treatment" 0 "Control"
label values 	treat Treatment 

graph bar age gender education, over(treat) title(Balance between Treatment and Control group) legend(label(1 "Age") label(2 "Gender") label(3 "Education"))

legend(label(1 "No Scholarship") label(2 "Scholarship")) ytitle("Worked hours")









