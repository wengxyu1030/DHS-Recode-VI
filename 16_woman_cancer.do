
***********************
*** Woman Cancer*******
***********************
	
*w_papsmear	Women received a pap smear  (1/0) 
*w_mammogram	Women received a mammogram (1/0)

gen w_papsmear = .
gen w_mammogram = .

if inlist(name, "Armenia2010"){
    ren v012 wage		
    replace w_papsmear=1 if s714dd==1 & s714ee==1
	replace w_papsmear=0 if s714dd==0 | s714ee==0
	replace w_papsmear=. if s714dd==9 | s714ee==9
    tab wage if w_papsmear!=. /*DHS sample is women aged 17-49*/
    replace w_papsmear=. if wage<20|wage>49	
}

if inlist(name, "Honduras2011"){
    ren v012 wage	
	replace s1011a=. if s1011a==98|s1011a==99
    replace w_papsmear=1 if (s1011==1&s1011a<=23)
    replace w_papsmear=0 if s1011==0
    replace w_papsmear=0 if w_papsmear == . & s1011a>35 & s1011a<100
    replace w_papsmear=. if s1011==.|s1011==9
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
	
	replace w_mammogram=1 if s1012c==1
    replace w_mammogram=0 if s1012c==0|s1012b==0
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<40|wage>49
}

if inlist(name, "Guatemala2014"){
	rename v012 wage
	drop w_papsmear
	gen w_papsmear = 0 if s1013<8
	replace w_papsmear = 1 if wage-s1016<4
	replace w_papsmear = . if s1016==98 | wage == .
	replace w_papsmear =. if s1013==.
}
		
if inlist(name, "DominicanRepublic2013"){
	ren v012 wage
	drop w_papsmear
	gen w_papsmear=(s1039==1|s1039==2)
	replace w_papsmear=. if s1039==.|s1039==8
	tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if wage<20|wage>49
	drop w_mammogram
	gen w_mammogram=(s1038==1|s1038==2)
	tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
	replace w_mammogram=. if wage<40|wage>49
}
	
if inlist(name, "Jordan2012"){
	ren v012 wage
	drop w_papsmear
	gen w_papsmear=0 if s615c!=.
	replace w_papsmear=1 if s615d==1
	replace w_papsmear=. if wage<20|wage>49
}
	
if inlist(name, "Kenya2014"){
	ren v012 wage
	drop w_papsmear
	gen w_papsmear=(s1008ca==1)
	replace w_papsmear=. if s1008b==. & s1008a!=0
	replace w_papsmear=. if wage<20|wage>49
}
	
if inlist(name, "Lesotho2014"){
	ren v012 wage
	drop w_papsmear
	gen w_papsmear=0 if inlist(s1012n,0,1)   // w_papsmear=0 if women never heard of papsmear
	replace w_papsmear =1 if s1012o==1 & inlist(s1012p,1,2)
	replace w_papsmear=. if wage<20|wage>49
}

if inlist(name, "Namibia2013"){
	ren v012 wage
	drop w_papsmear
	gen w_papsmear=0 if inrange(s1010p1,0,1)
	replace w_papsmear =1 if s1010p1==1
	replace w_papsmear=. if wage<20|wage>49
}

if inlist(name, "Tajikistan2012"){
	ren v012 wage
	drop w_papsmear
	gen w_papsmear=0 if inrange(s1034,0,1)
	replace w_papsmear =1 if inrange(s1035,1,3) 
	replace w_papsmear=. if wage<20|wage>49
}
	
capture confirm variable qs415 qs416u 
if _rc==0 {
    ren qs23 wage
    replace w_mammogram=(qs415==1&qs416u==1)
    replace w_mammogram=. if qs415==.|qs415==8|qs415==9|qs416u==9
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<50|wage>69
}
// They may be country specific in surveys.


*Add reference period.
//if not in adeptfile, please generate value, otherwise keep it missing. 
//if the preferred recall is not available (3 years for pap, 2 years for mam) use shortest other available recall 

gen w_mammogram_ref = ""  //use string in the list: "1yr","2yr","5yr","ever"; or missing as ""
gen w_papsmear_ref = ""   //use string in the list: "1yr","2yr","3yr","5yr","ever"; or missing as ""

if inlist(name, "Honduras2011"){
	replace w_mammogram_ref = "ever" 
	replace w_papsmear_ref = "2yr" 
}
	
if inlist(name, "CotedIvoire2011", "Jordan2012", "Guatemala2014", "Kenya2014", "Namibia2013"){
	replace w_papsmear_ref = "ever" 
}
	
if inlist(name, "DominicanRepublic2013" ){
	replace w_papsmear_ref = "2yr" 
	replace w_mammogram_ref = "2yr" 
}
	
if inlist(name, "Armenia2010","Guatemala2014", "Lesotho2014", "Tajikistan2012"){
	replace w_papsmear_ref = "3yr"
}
	
* Add Age Group.
//if not in adeptfile, please generate value, otherwise keep it missing. 

gen w_mammogram_age = "" //use string in the list: "20-49","20-59"; or missing as ""
gen w_papsmear_age = ""  //use string in the list: "40-49","20-59"; or missing as ""

if inlist(name, "Armenia2010","CotedIvoire2011", "Guatemala2014", "Jordan2012", "Kenya2014", "Lesotho2014", "Namibia2013", "Tajikistan2012"){
	replace w_papsmear_age = "20-49" 
}

if inlist(name, "DominicanRepublic2013", "Honduras2011"){
	replace w_papsmear_age = "20-49" 
	replace w_mammogram_age = "40-49" 
}




