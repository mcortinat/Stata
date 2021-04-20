*---------------------------------------------------------------*
*			Tarea de análisis de datos administrativos			*
*						Domingo 28 de marzo						*		*																*
*					  Magdalena Cortina Toro					*
*---------------------------------------------------------------*

clear all
version 16.1 // en un MAC
set more off

* Setting path
global path = "/Users/magdalena/Library/Mobile Documents/com~apple~CloudDocs/Research/RIS/"
cd "${path}"

* --1. Importación datos de natalidad EE.UU 1989-1994
use "${path}natl1989.dta"

global Y "1990 1991 1992 1993 1994"
foreach y of global Y{
	append using "${path}natl`y'.dta", force
}

* Chequeo que se hayan pegado todos los años
tab datayear // ok

* -- 2. Restrinja su muestra a las madres que residen en el estado de Texas.
* stateres: "State of residence". 44 = Texas

keep if stateres=="44" // total 1.905.863 datos de Texas
drop if cntyres=="44999" // countys con menos de 100,000 habitantes 
destring stateres, replace
destring cntyres, replace
* me quedo con 1,430,480  observaciones, 28 counties

** guardo la base de datos con nacimientos de Texas, 1989-1994
save "${path}natl89-94-TX.dta", replace


* -- 3. Merge 
** Primero importo las bases de datos con información económica del County para cada año y las pego en una sola base
** creo la base biryr para poder hacer el merge. Esa es la base que identifica el año de nacimiento en la base anterior.
clear all
global I "89 90 91 92 93 94"
foreach i of global I{
	import delimited "${path}cbp`i'co.txt"
	gen datayear=19`i'
	keep if fipstate==48
	gen cntyres = 44000 + fipscty
	drop if cntyres==44999
	save "${path}cbp`i'.dta", replace
	clear all
}

global I "90 91 92 93 94"
use "${path}cbp89.dta"
foreach i of global I{
	append using "${path}cbp`i'.dta"
}

keep if sic=="----" // para dejar solo el total de empleados por condado

save "${path}cbp89-94.dta", replace

** Luego, hago el merge entre la base de nacimientos y la base de CBP.
* cntyres "County of residence"
clear all
use "natl89-94-TX.dta"
merge m:m datayear cntyres using "cbp89-94.dta"

keep if _merge==3
drop _merge
save "${path}natl89-94-TX-cbp.dta", replace

* -- 4. Cree una variable que mida el ratio empleo-población del condado durante el año de la concepción en el condado de residencia de la madre

** primero, abro la base de datos con informacion de poblacion
clear all
use "county_population.dta"
keep if state_name=="Texas" // nº 48 en esta bases
gen cntyres = 44000 + county_fips

drop pop1970-pop1988
drop pop1995-pop2014
drop state_fips-division

merge m:m cntyres using "${path}natl89-94-TX-cbp.dta"

keep if _merge==3
drop _merge

global Y "1989 1990 1991 1992 1993 1994"
gen pop=.
foreach y of global Y{
	replace pop=pop`y' if datayear==`y'
}


** EMP= NUM   Total Mid-March Employees
gen emp_pop=emp/pop

* -- 5. Cree un histograma que muestre la distribución de los ratios de empleo-población
bys datayear cntyres: gen id=_n
order datayear cntyres id
histogram emp_pop if id==1, fcolor(gs12) ytitle(Frecuencia) xtitle(Ratio empleo-población) title(Distribución de ratios empleo-población) subtitle(Condados de TX 1989-1994) scheme(s2mono)
*graph export "${path}Graph.jpg", as(jpg) name("Graph") quality(100) (file /Users/magdalena/Library/Mobile Documents/com~apple~CloudDocs/Research/RIS/Graph.jpg written in JPG format)


* -- 6. Análisis de regresión

*** Variables de resultado:

** Bajo peso al nacer:
gen 		bajopeso=0
replace 	bajopeso=1 	if birwt4==1 | birwt4==2

** Parto anticipado
gen 		part_ant=0
replace 	part_ant=1 	if gestat3==1

** Parto por cesárea
gen 		ces=0
replace 	ces=1 		if delmeth5==3 | delmeth5==4

** Nro total de visitas de atención prenatal: nprev12

*** Variables de control:

** Edad de la madre:
gen 		ageless20=0
replace		ageless20=1 	if mage8==1 | mage8==2
gen			age20_24=0
replace		age20_24=1		if mage8==3
gen			age25_34=0
replace		age25_34=1		if mage8==4 | mage8==5
gen			age35=0
replace		age35=1			if mage8==6 | mage8==7 | mage8==8

** Nivel educacional de la madre: 
gen 		educless12=0
replace 	educless12=1 	if meduc6==1 | meduc6==2
gen			educ12=0
replace 	educ12=1 		if meduc6==3
gen			educ13_15=0
replace 	educ13_15=1		if meduc6==4
gen			educ16=0
replace		educ16=1		if meduc6==5

** Etnicidad de la madre
gen 		white=0
replace		white=1 		if orracem==6
gen			black=0
replace 	black=1			if orracem==7
gen 		hisp=0
replace 	hisp=1			if orracem==1 | orracem==2 | orracem==3 | orracem==4 | orracem==5
gen 		otherrace=0
replace 	otherrace=1		if orracem==8 | orracem==9


** Madre casada
gen 		married=0
replace		married=1 		if dmar==1

** Recién nacida mujer
gen 		girl=0
replace 	girl=1			if csex==2

** Orden de nacimiento: livord9

		** Etiquetas de variables creadas 
		label variable		bajopeso		"Bajo peso al nacer"
		label variable		part_ant		"Parto anticipado"
		label variable		ces				"Parto por cesárea"
		label variable		married			"Madre casada"
		label variable		girl			"Recién nacida niña"
		label variable		emp_pop			"Empleo-población"
		label variable		nprev12			"Visitas prenatales"	
		label variable		white			"Blanco no hispano"
		label variable		black			"Afroeamericano no hispano"
		label variable		hisp			"Hispano"
		label variable		otherrace		"Otra raza"
		label variable		educless12		"Mom education: <12 yr"
		label variable		educ12			"Mom education: 12 yr"
		label variable		educ13_15		"Mom education: 13-15 yr"
		label variable		educ16			"Mom education: 16+ yr"
		label variable		ageless20		"Mom age <20"
		label variable		age20_24		"Mom age 20-24"
		label variable		age25_34		"Mom age 25-35"
		label variable		age35			"Mom age 35+"
		
** date 
gen monthly_date =mofd( mdy(birmon, 1, biryr))
format monthly_date %tm	
	
* // REGRESION // *

** global outcome
global Y "bajopeso part_ant ces nprev12"
** global controls
global X "ageless20 age20_24 age25_34 age35 educless12 educ12 educ13_15 educ16 white black hisp otherrace married girl i.livord9"

foreach i of global Y{
	reg `i' emp_pop $X i.monthly_date if dplural==1, vce(cl cntyres)  // solo nacimientos únicos 
	est store reg_`i'
}
esttab reg_bajopeso reg_part_ant reg_ces reg_nprev12 using reg_1.tex, se label title("Relación entre el empleo-población del condado y la salud infantil") addnotes("Bajo peso al nacer está calificado como menos de 2500 gr.  y parto anticipado como menos de 37 semanas. ") drop (*.monthly_date ageless20 age20_24 age25_34 age35 educless12 educ12 educ13_15 educ16 white black hisp otherrace married girl *.livord9) replace

