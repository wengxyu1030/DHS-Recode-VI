******************************
*** Delivery Care************* 
******************************
gen DHS_phase=substr(v000, 3, 1)
destring DHS_phase, replace

gen country_year="`name'"
gen year = regexs(1) if regexm(country_year, "([0-9][0-9][0-9][0-9])[\-]*[0-9]*[ a-zA-Z]*$")
destring year, replace
gen country = regexs(1) if regexm(country_year, "([a-zA-Z]+)")

rename *,lower   //make lables all lowercase. 
order *,sequential  //make sure variables are in order. 

	*sba_skill: Categories as skilled: doctor, nurse, midwife, auxiliary nurse/midwife...
	if !inlist(name,"Bangladesh2014"){
		foreach var of varlist m3a-m3m {
		local lab: variable label `var' 
		replace `var' = . if ///
		!regexm("`lab'"," trained") & (!regexm("`lab'","doctor|nurse|Assistance|midwife|lady|mifwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|auxiliary birth attendant|physician assistant|professional|ferdsher|feldshare|skilled|birth attendant|hospital/health center worker|auxiliary|icds|feldsher|mch|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|medical assistant|matrone|general practitioner") ///
		|regexm("`lab'","na^|-na|na -|Na- |NA -|husband/partner|mchw|matron |Hilot|family welfare|Family welfare|student|homeopath|hakim|herself|traditionnel|Other|neighbor|provider|vhw|Friend|Relative|fieldworker|Health Worker|other|health worker|friend|relative|traditional birth attendant|hew|health assistant|untrained|unqualified|sub-assistant|empirical midwife|box")) & !(regexm("`lab'","doctor") & regexm("`lab'","other")) & !regexm("`lab'","lady health worker")

		replace `var' = . if !inlist(`var',0,1)
		}
	} 
	if inlist(name,"Bangladesh2014"){ // 
		recode m3a m3b m3c m3d (9 8 =.)
		recode m3e m3f m3g m3h m3i m3j m3k m3l m3m (1 0 8 9 =.)
	}
	if inlist(name,"Chad2014","Congodr2013"){
		recode m3a m3b m3c (9 8 =.)
		recode m3d m3g m3h m3i m3j m3k (1 0 8 9 =.)
	}
	/* do consider as skilled if contain words in 
	   the first group but don't contain any words in the second group */
    egen sba_skill = rowtotal(m3a-m3m),mi
	
	*c_hospdel: child born in hospital of births in last 2 years  
	decode m15, gen(m15_lab)
	replace m15_lab = lower(m15_lab)
	
	gen c_hospdel = 0 if !mi(m15)
	replace c_hospdel = 1 if ///
	regexm(m15_lab,"medical college|surgical") | ///
	(regexm(m15_lab,"hospital") & !regexm(m15_lab,"home")) & !regexm(m15_lab,"center|sub-center|clin|clinic")
	replace c_hospdel = . if mi(m15) | m15 == 99 | mi(m15_lab)	
    // please check this indicator in case it's country specific	
	if inlist(name,"Niger2012"){
		replace c_hospdel = 1 if inrange(m15,22,31) //not including home, other private, abroad and other
	}
	
	*c_facdel: child born in formal health facility of births in last 2 years
	gen c_facdel = 0 if !mi(m15)
	replace c_facdel = 1 if (regexm(m15_lab,"hospital|maternity|health center|clinic|dispensary") & !regexm(m15_lab,"home")) | ///
	!regexm(m15_lab,"home|other private|other$|pharmacy|non medical|private nurse|religious|abroad|india|tba") | regexm(m15_lab,"health home|hospital/clin")
	replace c_facdel = . if mi(m15) | m15 == 99 | mi(m15_lab)
	
	if inlist(name,"Turkey2013"){
	   replace c_hospdel=0 if m15==31
    }
	if inlist(name,"Kenya2014"){
		replace c_hospdel = 0 if inlist(m15,33,32)
		replace c_facdel = 1 if m15==32 
		replace c_facdel = 0 if m15==33 
	}
	if inlist(name,"Yemen2013"){
		replace c_facdel = 1 if m15==31 | m15==41 
	}
	if inlist(name,"Tajikistan2012"){
		replace c_hospdel = 1 if m15==21 | m15==22 | m15==31 /*consider maternity home as hospital*/ 
		replace c_facdel = 1 if m15==21 | m15==22 | m15==23 | m15==31
	}
	if inlist(name,"Armenia2010"){
		replace c_hospdel = 1 if m15==21 | m15==22 | m15==31 | m15==32 /*consider maternity home as hospital, questions on private*/ 
		replace c_facdel = 1 if inlist(m15,21,22,26,24,31,32) 
	}	
	if inlist(name,"Bangladesh2014"){
		replace c_hospdel = 1 if m15==21 | m15==22 | m15==31 /*private hospital/clinic as hospital, public/district hospitals count as well*/ 
		replace c_facdel = 1 if inlist(m15,21,22,23,27) |  m15==31 | m15==41
	}		
	if inlist(name,"Bangladesh2011"){
		replace c_hospdel = 1 if inlist(m15,21,22,23,31,32,41) /*private hospital/clinic as hospital, public/district hospitals, special medical college count as well*/ 
		replace c_facdel = 1 if inlist(m15,21,22,23,24,25,26,31,32,41)
	}		
	if inlist(name,"KyrgyzRepublic2012"){
		replace c_hospdel = 1 if m15==21 | m15==22 /*gov, and maternity home*/ 
		replace c_facdel = 1 if inlist(m15,21,22,23,26) |  m15==31 /*do we include private hospital/clinic?*/
	}		

	*c_earlybreast: child breastfed within 1 hours of birth of births in last 2 years
	gen c_earlybreast = 0
	
	replace c_earlybreast = 1 if inlist(m34,0,100)
	replace c_earlybreast = . if inlist(m34,999,199)
	replace c_earlybreast = . if m34 ==. & m4 != 94 // case where m34 is missing that is not due to "no breastfeed"
	
    *c_skin2skin: child placed on mother's bare skin immediately after birth of births in last 2 years
	capture confirm variable m77
	if _rc == 0{
	gen c_skin2skin = (m77 == 1) if !mi(m77)               
	}
	gen c_skin2skin = .

	if inlist(name, "Armenia2010"){
	drop c_skin2skin
	gen c_skin2skin = (s433a  == 1) if  !mi(s433a)
	}
	
	if inlist(name, "Bangladesh2014"){
	drop c_skin2skin
	gen c_skin2skin = (s435ai  == 1) if   !inlist(s435ai,.,8) 
	}
	
	if inlist(name, "Nepal2011"){
	drop c_skin2skin
	gen c_skin2skin = (s431g  == 1) if   !inlist(s431g,.,8) 
	}
	
	if inlist(name, "Nigeria2013"){
	drop c_skin2skin
	gen c_skin2skin = (s437g  == 1) if   !inlist(s437g,.,8,9) 
	}
	
	if inlist(name, "Philippines2013"){
	drop c_skin2skin
	gen c_skin2skin = (s435  == 1) if   !inlist(s435,.,8,9) 
	}
	
	*c_sba: Skilled birth attendance of births in last 2 years: go to report to verify how "skilled is defined"
	gen c_sba = . 
	replace c_sba = 1 if sba_skill>=1 & sba_skill!=.
	replace c_sba = 0 if sba_skill==0 
	  
	*c_sba_q: child placed on mother's bare skin and breastfeeding initiated immediately after birth among children with sba of births in last 2 years
	gen c_sba_q = (c_skin2skin == 1 & c_earlybreast == 1) if c_sba == 1
	replace c_sba_q = . if c_skin2skin == . | c_earlybreast == .
	
	*c_caesarean: Last birth in last 2 years delivered through caesarean                    
	clonevar c_caesarean = m17
	replace c_caesarean =. if m17==9
	replace c_caesarean = . if inlist(m15,.,99,98)

    *c_sba_eff1: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth)
	if !inlist(name,"Ghana2014","Namibia2013","India2015","KyrgyzRepublic2012","Niger2012","Pakistan2012","Uganda2011","Turkey2013"){
	gen stay = 0
	replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,96) // filter question, based on m15
	}
	if inlist(name,"Turkey2013"){
    gen stay=0
	replace stay=1 if inrange(m61,124,130)|inrange(m61,202,207)
	replace stay=. if inlist(m61,199)&!inlist(m15,11,12,96)
	}
	if inlist(name,"Ghana2014"){
	gen stay = 0
	replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,23,96) // filter question, based on m15
	}	
	if inlist(name,"India2015"){
	gen stay = 0
	replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,21,96) // filter question, based on m15
	}	
	if inlist(name,"Namibia2013","Pakistan2012"){
	gen stay = 0
	replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,36,96) // filter question, based on m15
	}
	if inlist(name,"Niger2012"){
	gen stay = 0
	replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,27,36,96) // filter question, based on m15
	}
	if inlist(name,"KyrgyzRepublic2012"){
	gen stay = 0
	replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,23,96) // filter question, based on m15
	}	
	if inlist(name,"Uganda2011"){
	gen stay = 0
	replace stay = 1 if inrange(m61,124,198)|inrange(m61,200,298)|inrange(m61,301,399)
	replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12,13,96) // filter question, based on m15
	}	
	if inlist(name,"Bangladesh2011"){
		replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,96)  
	}	
	if inlist(name,"Guatemala2014","Jordan2012","Mali2012","Tajikistan2012"){
		replace stay = . if inlist(m61,299,998,999,.) & !inlist(m15,11,12)  
	}
	
	egen staycheck = mean(m61)
	replace stay =. if staycheck == . 

	gen c_sba_eff1 = (c_facdel == 1 & c_sba == 1 & stay == 1 & c_earlybreast == 1) 
	replace c_sba_eff1 = . if c_facdel == . | c_sba == . | stay == . | c_earlybreast == . 
	// you may need to check if this code work for all countries, which is the case in Recode VII. In this case, you don't need if inlist() anymore.
	
	*c_sba_eff1_q: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth) among those with any SBA
	gen c_sba_eff1_q = c_sba_eff1 if c_sba == 1
	
	*c_sba_eff2: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth, skin2skin contact)
	gen c_sba_eff2 = (c_facdel == 1 & c_sba == 1 & stay == 1 & c_earlybreast == 1 & c_skin2skin == 1) 
	replace c_sba_eff2 = . if c_facdel == . | c_sba == . | stay == . | c_earlybreast == . | c_skin2skin == .
	
	*c_sba_eff2_q: Effective delivery care (baby delivered in facility, by skilled provider, mother and child stay in facility for min. 24h, breastfeeding initiated in first 1h after birth, skin2skin contact) among those with any SBA
	gen c_sba_eff2_q =  c_sba_eff2 if c_sba == 1
	
	
