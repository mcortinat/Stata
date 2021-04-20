*---------------------------------------------------------------*
*			  Data Task RA Prof. Mathew Notowidigdo 			*
*					  Magdalena Cortina Toro					*
*---------------------------------------------------------------*

clear all
version 16.1 // on a MAC
set more off

* Setting path
global path = "/Users/magdalena/Library/Mobile Documents/com~apple~CloudDocs/Research/Data tasks/Noto task"
cd "${path}"

use "Noto_data_task.dta"

* -- 1. Replicate table 2: Regresion models for the clg/hs low wage gap, 1963-2008

	* time variable, t=1 (1963), t=2 (1964) etc
	gen 	t 		= year - 1962
	gen 	t_2		= (t^2)/100
	gen 	t_3		= (t^3)/1000
	
	gen 	post92	= year-1992
	replace post92	= 0 if post92<0
	

* reg 1: 1963-1987, clg/hs t
reg clphsg_all t eu_lnclg if year<1988
est sto reg1

* reg 2: 1963-2008 clg/hs t 
reg clphsg_all t eu_lnclg
est sto reg2

* reg 3: 1963-2008 clg/hs t post92
reg clphsg_all t eu_lnclg post92
est sto reg3

* reg 4: 1963-2008 clg/hs t post92 t_2
reg clphsg_all t eu_lnclg post92 t_2
est sto reg4

* reg 5: 1963-2008 clg/hs t post92 t_2 t_3
reg clphsg_all t eu_lnclg post92 t_2 t_3
est sto reg5

label variable eu_lnclg "CLC/HS Relative Supply"
label variable t "Time"
label variable t_2 "Time^2/100"
label variable t_3 "Time^3/1000"
label variable post92 "Time x post-1992"

esttab reg1 reg2 reg3 reg4 reg5 using table2.tex, label mtitles("1963-1987"       ) title("Table 1: Regression Model for the College/High School Log Wage Gap, 1963-2008")  replace


* -- 2. Figure 4: Clg/hs relative supply and wage differential, 1963-2008
**** Panel A: residuals from separate OLS regression of the relative supply and relative wage measure on a constant and a linear time trend (t)

reg clphsg_all t
predict y1, res
label variable y1 "Detrended Wage Differential"

reg eu_lnclg t
predict y2, res
label variable y2 "Detrended Relatve Supply"

twoway connected y1 y2 year, msize(tiny small) msymbol(circle X) title("A. Detrended College/High School Wage Differential and Relative Supply, 1963-2008", size(small)) ytitle("Log Points", size(small)) yline(0)
graph export "GraphA.jpg", as(jpg) name("Graph") quality(100) replace


**** Panel B: Fitted values from an OLS regression of the college/hs wage gap for years 1963-1987 on a constant an the college/hs relative supply mesure. Plotted 1988-2008 values are out of sample predictions
reg clphsg_all eu_lnclg t if year<1988
predict y3
label variable y3 "Katz-Murphy Predicted Wage Gap: 1963-1987 Trend"

twoway connected clphsg_all y3 year, msize(tiny small) msymbol(circle X) xline(1987 1992) title("B. Katz-Murphy Prediction Model for the College/High School Wage Gap", size(small)) ytitle("Log Wage Gaps", size(small)) legend(size(7pt))
graph export "GraphB.jpg", as(jpg) name("Graph") quality(100) replace

* -- 3. Trend break that maximizes R2

global Y1 "64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 93 94 95 96 97 98 99"
global Y2 "00 01 02 03 04 05 06 07"

foreach y of global Y1{
	gen post`y' = year-19`y'
	replace post`y' = 0 if post`y'<0
}	

foreach i of global Y2{
	gen post`i' = year-20`i'
	replace post`i' = 0 if post`i'<0
}	

global Y "64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07"
foreach y of global Y{
	qui reg clphsg_all t eu_lnclg post`y'
	generate Rsq_`y' = e(r2) if _n==1 // Store Rsq on 1st row only
}

list Rsq_64-Rsq_07 if year==1963
** the highest Rsq is Rsq_94 = .964344

reg clphsg_all t eu_lnclg post94
est sto reg6
label variable post94 "Time x post-1994"
esttab reg6 using table3.tex, label title("Regression With Trend Break in 1964") replace
