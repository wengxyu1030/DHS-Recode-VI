
do "D:\MEASURE UHC DATA\STATA\DO\SC\NewMICSglobals.do"
#delimit ;
global cou 
LaoPDR2017
SierraLeone2017
Iraq2017
KyrgyzRepublic2018
Mongolia2018
Suriname2018
  Gambia2018
  Tunisia2018
  Lesotho2018
  Madagascar2018
  Bangladesh2012
  Belize2015
  Benin2014
  Cameroon2014
  Congorep2014
  CotedIvoire2016
  Cuba2014
  DominicanRepublic2014
  ElSalvador2014
  Guinea2016
  GuineaBissau2014
  Guyana2014
  Kazakhstan2015
  	Kosovo2013
	KyrgyzRepublic2014
	Malawi2013
	Mali2015
	Mauritania2015
	Mexico2015
	Mongolia2013
	Montenegro2013
	Nepal2014
	Nigeria2016
	Palestine2014
	Panama2013
	Paraguay2016
	SaoTomePrincipe2014
	Serbia2014
	Sudan2014
	Swaziland2014
	Thailand2015
	Turkmenistan2015
	Vietnam2013
	Zimbabwe2014
	;
#delimit cr

foreach c in $cou  {

cap use "D:\MEASURE UHC DATA\RAW DATA\MICS\MICS5-`c'\MICS5-`c'wm.dta", clear
cap use "D:\MEASURE UHC DATA\RAW DATA\MICS\MICS6-`c'\MICS6-`c'wm.dta", clear

gen year = substr("`c'",-4,4)		// survey year
destring year, replace
gen survey = "MICS"					// survey name
gen WB_cname = substr("`c'",1,length("`c'")-4)

-- enter code making variable
	
* Country, surveym, year and disease identifiers
	foreach var in entervariables to be aggrgated {
		sum `var' [aw = enterweightvariable]
		gen `var'_0 = r(mean)
		gen N`var'  = r(N)
		drop `var'
		rename `var'_0 `var'
	}
	keep in 1


	gen i = 1
	keep WB_cname year survey Nentervariable entervariables
	save "`c'", replace
}

* stack-up full dataset
	clear
	set obs 1
	foreach c in $cou {
		append using "`c'.dta"
	}
	foreach c in $cou {
		erase "`c'.dta"
	}
	drop in 1


save "D:\EFFECTIVE COVERAGE\DATA\---.dta", replace

