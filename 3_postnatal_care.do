*****************************
***Postnatal Care************* 
*****************************

*c_pnc_skill: m52,m72 by var label text. (m52 is added in Recode VI.
    gen m52_skill = 0 if !mi(m52) | !inlist(m50,0,1) 
	gen m72_skill = 0 if !mi(m72) | !inlist(m70,0,1) 
	
	foreach var of varlist m52 m72 {
    decode `var', gen(`var'_lab)
	replace `var'_lab = lower(`var'_lab )
	replace  `var'_skill= 1 if ///
	(regexm(`var'_lab,"doctor|nurse|midwife|aide soignante|assistante accoucheuse|clinical officer|pediatriacian|mch aide|midwile|matrone/|trained|rescuer|auxiliary birth attendant|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|auxiliary|icds|feldsher|mch|vhw|health team|health personnel|gynecolog(ist|y)|internist|pediatrician|family welfare VIsitor|medical assistant|health assistant") ///
	&!regexm(`var'_lab,"na^|-na|traditional birth attendant|vhw|untrained|unqualified|Matrone |empirical midwife|other|obstetrician|health assistant|health fieldworker|health worker") | (regexm(`var'_lab,"trained traditional") & !regexm(`var'_lab,"untrained")) | regexm(`var'_lab,"matron with |gynecology/ obstetrician") | (regexm(`var'_lab,"doctor|health personnel|health professional") & regexm(`var'_lab,"other")))
	replace `var'_skill = . if mi(`var') | `var' == 99 | mi(`var'_lab) |`var' == 98
	}
	if inlist(name, "Kenya2014") {
		replace m52_skill = 0 if  m52 ==22 
	
	}
	/* consider as skilled if contain words in 
	   the first group but don't contain any words in the second group */
	*c_pnc_any : mother OR child receive PNC in first six weeks by skilled health worker
    gen c_pnc_any = 0 if !mi(m70) & !mi(m50) 
    replace c_pnc_any = 1 if ((m71 <= 242 | inrange(m71,301,306) | m71 == 299 ) & m72_skill == 1 ) | ((m51 <= 242 | inrange(m51,301,306) | m51 == 299 ) & m52_skill == 1)
    replace c_pnc_any = . if ((inlist(m71,.,399,998,999)|m72_skill ==.) & m70 !=0) | ((inlist(m51,.,399,998,999) | m52_skill == .) & m50 !=0)
	
	*c_pnc_eff: mother AND child in first 24h by skilled health worker	
	gen c_pnc_eff = 0 if !mi(m70) & !mi(m50) 
    replace c_pnc_eff = 1 if ((inrange(m51,100,124) | m51 == 201 | m51 == 199) & m52_skill == 1) & ((inrange(m71,100,124) | m71 == 201 | m71 ==199) & m72_skill == 1 )
    replace c_pnc_eff = . if ((inlist(m71,.,299,998,999)|m72_skill ==.) & m70 !=0) | ((inlist(m51,.,299,998,999) | m52_skill == .) & m50 !=0)
	
	*c_pnc_eff_q: mother AND child in first 24h by skilled health worker among those with any PNC
	gen c_pnc_eff_q = c_pnc_eff  if c_pnc_any == 1
	
	*c_pnc_eff2: mother AND child in first 24h by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days	
	gen c_pnc_eff2 = . 
	
	capture confirm variable m78a m78b m78d                            //m78* only available for Recode VII
	if _rc == 0 {
	egen check = rowtotal(m78a m78b m78d),mi
	replace c_pnc_eff2 = c_pnc_eff
	replace c_pnc_eff2 = 0 if check != 3
	replace c_pnc_eff2 = . if c_pnc_eff == . 
	}
	
	if inlist(name, "Nigeria2013"){
		egen check = rowtotal(s444aa s444ab s444ac),mi
		replace c_pnc_eff2 = c_pnc_eff
		replace c_pnc_eff2 = 0 if check != 3
		replace c_pnc_eff2 = . if c_pnc_eff == . 
	}
	
	*c_pnc_eff2_q: mother AND child in first 24h weeks by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days among those with any PNC
	gen c_pnc_eff2_q = c_pnc_eff2 if c_pnc_any == 1
