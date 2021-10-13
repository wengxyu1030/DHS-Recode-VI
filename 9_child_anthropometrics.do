*****************************
*** Child anthropometrics ****
******************************   
	if inlist(name,"Turkey2013"){
	preserve
		tempfile tpf1
		use "${SOURCE}/DHS-Turkey2013/DHS-Turkey2013birth.dta", clear	
			keep v001 v002 v003 b16 hw1 hw70 hw71 b3
			drop if hw70==. & hw71==.
			ren (v001 v002 v003 b16 ) (hv001 hv002 hv003 hvidx)
			sort hv001 hv002 hv003 hvidx
		save `tpf1'
	restore
	sort hv001 hv002 hv003 hvidx
	merge 1:1 hv001 hv002 hv003 hvidx using `tpf1'
	tab _m 
	drop if _m ==2
	drop _m hc1 hc70 hc71 hc32
	ren (hw1 hw70 hw71 b3) (hc1 hc70 hc71 hc32)
	}
	
*c_stunted: Child under 5 stunted
    foreach var in hc70 hc71 {
    replace `var'=`var'/100
    }
    replace hc70=. if hc70<-6 | hc70>6
    replace hc71=. if hc71<-6 | hc71>5

    gen c_stunted=1 if hc70<-2
    replace c_stunted=0 if hc70>=-2 & hc70!=.

*c_underweight: Child under 5 underweight
    gen c_underweight=1 if hc71<-2
    replace c_underweight=0 if hc71>=-2 & hc71!=.

							
*ant_sampleweight Child anthropometric sampling weight
    gen ant_sampleweight = hv005/10e6


	
