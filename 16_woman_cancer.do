*w_papsmear	Women received a pap smear  (1/0) 
gen w_papsmear = .
// for Peru, w_papsmear2 should be added. Othe country only do w_papsmear code from adepfile. 

*w_mammogram	Women received a mammogram (1/0)
gen w_mammogram = .

capture confirm variable s714dd s714ee 
if _rc==0 {
    replace w_papsmear=1 if s714dd==1 & s714ee==1
	replace w_papsmear=0 if s714dd==0 | s714ee==0
	replace w_papsmear=. if s714dd==9 | s714ee==9
}

capture confirm variable s1017 s1020 
if _rc==0 {
    replace w_mammogram=. if s1017==. | s1017==9 | s1020==9
}

// There may be country specific in recode.

*Add reference period.
gen w_mamogram_ref = . 
gen w_papsmear_ref = .
//if not in adeptfile, please generate value, otherwise keep it missing. 

* Add Age Group.
gen w_mamogram_age = . 
gen w_papsmear_age = . 
//if not in adeptfile, please generate value, otherwise keep it missing. 


// Also may need to add them in the quality control file, as they could be compared with HEFPI database.



