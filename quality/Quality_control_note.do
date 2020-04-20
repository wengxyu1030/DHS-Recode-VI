////////////////////////////////////////////////////////////////////////////////////////////////////
*** Debug quality control
////////////////////////////////////////////////////////////////////////////////////////////////////

version 14.0
clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 32767, permanent
capture log close
sca drop _all
matrix drop _all
macro drop _all

******************************
*** Define main root paths ***
******************************

//NOTE FOR WINDOWS USERS : use "/" instead of "\" in your paths

global root "C:/Users/wb500886/WBG/Sven Neelsen - World Bank/MEASURE UHC DATA"

* Define path for data sources
global SOURCE "${root}/RAW DATA/Recode VI"

* Define path for output data
global OUT "${root}/STATA/DATA/SC/FINAL"

* Define path for INTERMEDIATE
global INTER "${root}/STATA/DATA/SC/INTER"

* Define path for do-files
global DO "${root}/STATA/DO/SC/DHS/Recode VI"
 
////Comparison result  
  run "C:\Users\wb500886\WBG\Sven Neelsen - World Bank\MEASURE UHC DATA\STATA\DO\SC\DHS\Recode VI\DHS_Recode_VI.do"
. use "C:\Users\wb500886\WBG\Sven Neelsen - World Bank\MEASURE UHC DATA\STATA\DATA\SC\FINAL\quality_control.dta",clear
  sort flag_hefpi varname_my
  
  br
  br if flag_hefpi == 1
  br if flag_hefpi == 1 | (flag_dhs ==1 & flag_hefpi!=0)
  
////HEFPI
*13_adult: only BD2011DHS has data and is not consistent. 
  /*Fixed: 
    same raw result but different weight
    ignore because the a_* (a_diab_treat) were not using the right code in HEFPI data*/

*c_ITN: wired for some countries, check definition
   /* Fixed:
   ITN should use ml0 instead of m10.  
  Note:  TD2014DHS differ with DHS but same with HEFPI */
   
*c_sba: TD2014  

*c_treatARI:
No provider detailed info on other for RecodeVI
GA6
KE6
KE6
SN6

Using c_treatARI2
 
use "${SOURCE}/DHS-Senegal2012/DHS-Senegal2012birth.dta",clear
    gen hm_age_mon = (v008 - b3)           //hm_age_mon Age in months (children only)
    gen name = "Senegal2012"
	do "${DO}/8_child_illness"
	tab c_ari
	tab c_treatARI
	
	   order h12*,sequential
	   foreach var of varlist h12a-h12x {
	   local lab: variable label `var' 
       replace `var' = 0 if ///
	   regexm("`lab'","( other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|hilot|traditional|cs private medical|cs public sector)") ///
	   & !regexm("`lab'","(ngo|hospital|medical center|traditional practioner$)")  
	   }
	   /* do not consider formal if contain words in 
	   the first group but don't contain any words in the second group */
       
	   egen pro = rowtotal(h12a-h12x)

       gen c_diarrhea_pro = 0 if c_diarrhea == 1
       replace c_diarrhea_pro = 1 if pro >= 1 
       replace c_diarrhea_pro = . if pro == . 	
	
	

*w_bmi_1549: TD2014DHS BD2011DHS (Done)
use "${SOURCE}/DHS-Bangladesh2011/DHS-Bangladesh2011ind.dta",clear
    do "${DO}/5_woman_anthropometrics"
	sum w_bmi_1549
	
	
*c_pnc_skill
use "C:\Users\wb500886\WBG\Sven Neelsen - World Bank\MEASURE UHC DATA\RAW DATA\Recode VI\DHS-Armenia2010\DHS-Armenia2010birth.dta", clear
    *c_pnc_skill: m52,m72 by var label text. (m52 is added in Recode VI.
	gen m52_skill = 0 if !inlist(m50,0,1) 
	gen m72_skill = 0 if !inlist(m70,0,1) 
	
	foreach var of varlist m52 m72 {
    decode `var', gen(`var'_lab)
	replace `var'_lab = lower(`var'_lab )
	replace  `var'_skill= 1 if ///
	(regexm(`var'_lab,"doctor|nurse|midwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|trained|auxiliary birth attendant|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant") ///
	|!regexm(`var'_lab,"na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife")) 
	replace `var'_skill = . if mi(`var') | `var' == 99
	}


/////DHS
   
*c_anc_ir: some ctr. 
 /* surveyid
TD2014DHS
AM2010DHS 
Too high 
*/

*c_ari 
using c_ari2 as the old adept file definition for quality control.

*c_caesarean: only AM2010DHS differ

*c_diarrhea_hmf
/* AM2010DHS only too high */

*c_diarrhea_pro (most)
/* do not compare, but write a code:
Not include: Other, Shop, Market, private traditional, phramacy
Include: public traditional  */

use "C:\Users\wb500886\WBG\Sven Neelsen - World Bank\MEASURE UHC DATA\RAW DATA\Recode VII\DHS-Afghanistan2015\DHS-Afghanistan2015birth.dta", clear
gen name = "Afghanistan2015"
gen c_diarrhea=(h11   ==1|h11   ==2) 						/*symptoms in last two weeks*/
replace c_diarrhea=. if h11   ==8|h11  ==9|h11  ==. 
		
	   order h12*,sequential
	   foreach var of varlist h12a-h12x {
	   local lab: variable label `var' 
       replace `var' = 0 if ///
	   regexm("`lab'","( other|shop|pharmacy|market|kiosk|relative|friend|church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush)") ///
	   & !regexm("`lab'","(ngo|hospital|medical center|worker)")  
	   }
	   /* do not consider formal if contain words in 
	   the first group but don't contain any words in the second group */
       
	   egen pro = rowtotal(h12a-h12x)

       gen c_diarrhea_pro = 0 if c_diarrhea == 1
       replace c_diarrhea_pro = 1 if pro >= 1 
       replace c_diarrhea_pro = . if pro == . 	
	   tab c_diarrhea_pro
	   
	   
(For vaccinations below, I am following the old code, should not be an issue unless mistaken)	   
	   
*c_measles
/* AM2010DHS */

*c_fullimm
/* AM2010DHS */

*c_polio3
/* TD2014DHS */







