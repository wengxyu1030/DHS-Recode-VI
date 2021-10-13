********************
*** adult***********
********************
/*
note: 
add [a_bp_meas_ref], [a_inpatient_ref]
use "if inlist" instead of "capture" for sys&dial, in case the variables listed in "capture" appears in other surveys but not related to BP. 
*/
*a_inpatient	18y+ household member hospitalized, recall period as close to 12 months as possible  (1/0)
    gen a_inpatient_1y = . 
	
*a_inpatient_ref	18y+ household member hospitalized recall period (in month), as close to 12 months as possible
    gen a_inpatient_ref = . 

	if inlist(name,"Cameroon2011"){
		replace a_inpatient_1y =(sh715==1) if !inlist(sh715,.,8,9)
		replace a_inpatient_ref =1
	}

	if inlist(name,"Congodr2013"){
		replace a_inpatient_1y =sh21 if sh21<8
		replace a_inpatient_ref =6
	}

	if inlist(name,"Honduras2011"){  
		recode sh90 (8 9 = .)
		replace a_inpatient_1y =sh90  
		replace a_inpatient_ref =12
	}

	if inlist(name,"Namibia2013"){   
		replace a_inpatient_1y = 0 if sh141 !=9
		replace a_inpatient_1y = 1 if sh142 == hvidx 
		replace a_inpatient_1y = . if sh142 == 99
		
		replace a_inpatient_ref = 6 
	}
	
	if inlist(name,"Philippines2013"){
		replace a_inpatient_1y =0 
		
		foreach k in 1 2 3 4 5 6 7 8 9 {
			replace a_inpatient_1y =1 if sh208_`k' == hvidx & sh212_`k'==1 
			replace a_inpatient_1y =. if sh208_`k' == hvidx & sh212_`k'==9 
		}
		
		foreach k in sh222_1 sh222_2 sh222_3 sh222_4 {
			replace a_inpatient_1y =1 if `k' == hvidx & sh220==1
		}

		replace a_inpatient_ref = 12
	}	
	
	if inlist(name,"Rwanda2010"){
		replace a_inpatient_1y =sh23==1 if !inlist(sh23,.,8,9)
		replace a_inpatient_ref =6
	}
	
*a_bp_meas 	 18y+ having their blood pressure measured by health professional, as close to last 1 year as possible 
    gen a_bp_meas = . 
		
*a_bp_treat	18y + being treated for high blood pressure 
    gen a_bp_treat = . 
	
	if inlist(name, "Bangladesh2011") {
		replace a_bp_treat=0 if sh250!=. 
		replace a_bp_treat=1 if sh250==1 
	}

	if inlist(name, "Namibia2013") {
		drop a_bp_treat a_bp_meas
		recode sh318 sh319a sh320 (8 9 =.)
		egen bptreat = rowtotal(sh319a sh320),mi
		gen a_bp_treat = bptreat>=1 if bptreat!=. & sh318==1
		
		gen a_bp_meas=sh317==1 if !inlist(sh317,.,9) 
	}
	
*a_bp_sys & a_bp_dial: 18y+ systolic & diastolic blood pressure (mmHg) in adult population 
	gen a_bp_sys = .
	gen a_bp_dial = .
	
	if inlist(name, "Bangladesh2011") {	
		drop a_bp_sys a_bp_dial
		recode sh246s sh255s sh264s sh246d sh255d sh264d  (994 995 996 998 999 =.) 
		egen a_bp_sys = rowmean(sh246s sh255s sh264s)
		egen a_bp_dial = rowmean(sh246d sh255d sh264d)
    }	
	
	if inlist(name, "Namibia2013") {
		drop a_bp_sys a_bp_dial
		recode sh315a sh324a sh334a sh315a sh324a sh334a (994 995 996 998 999 =.)  
		egen a_bp_sys = rowmean(sh315a sh324a sh334a)
		egen a_bp_dial = rowmean(sh315b sh324b sh334b)
    }	 	

*a_hi_bp140_or_on_med	18y+ with high blood pressure or on treatment for high blood pressure	
	gen a_hi_bp140=.
    replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
    replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
	
	gen a_hi_bp140_or_on_med = .
	replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
    replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0
		
*a_diab_treat				18y+ being treated for raised blood glucose or diabetes 
    gen a_diab_treat = .

	if inlist(name, "Bangladesh2011") {	
		gen a_diab_diag=(sh258==1)
		replace a_diab_diag=. if sh257==.|sh257==8|sh257==9|sh258==9

		replace a_diab_treat=(sh259==1)
		replace a_diab_treat=. if sh257==.|sh257==8|sh257==9|sh259==9
    }		

	if inlist(name, "Benin2011") {	
		drop a_bp_treat a_bp_sys a_bp_dial a_hi_bp140_or_on_med
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Benin2011/DHS-Benin2011ind.dta", clear	
		keep v001 v002 v003 s1011 s1013a s1013d sbp1s sbp2s sbp3s sbp1d sbp2d sbp3d
		save `t1'	
		use "${SOURCE}/DHS-Benin2011/DHS-Benin2011men.dta", clear	
		keep mv001 mv002 mv003 sm814a sm814ca sm814cd smbp1s smbp2s smbp3s smbp1d smbp2d smbp3d	
		ren (mv001 mv002 mv003 sm814a sm814ca sm814cd smbp1s smbp2s smbp3s smbp1d smbp2d smbp3d	) (v001 v002 v003 s1011 s1013a s1013d sbp1s sbp2s sbp3s sbp1d sbp2d sbp3d)
		append using `t1'
		recode sbp1s sbp2s sbp3s sbp1d sbp2d sbp3d (994 995 996 998 999=.)
		
		egen a_bp_sys = rowmean(sbp1s sbp2s sbp3s)
		egen a_bp_dial = rowmean(sbp1d sbp2d sbp3d)
		
		egen bptreat = rowtotal(s1013a s1013d),mi
		gen a_bp_treat = 0 if s1011==1 
		replace a_bp_treat = 1 if bptreat>=1 & bptreat !=. 
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
	
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0
		
		keep v001 v002 v003 a_bp_sys a_bp_dial a_bp_treat a_hi_bp140_or_on_med
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	}
	
	if inlist(name, "Ghana2014") {	
		drop a_bp_treat a_bp_sys a_bp_dial a_hi_bp140_or_on_med
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Ghana2014/DHS-Ghana2014ind.dta", clear	
		keep v001 v002 v003 s101e1 s600ca s1056a s101e2 s600cb s1056b s1033 s1035a
		save `t1'	
		use "${SOURCE}/DHS-Ghana2014/DHS-Ghana2014men.dta", clear	
		keep mv001 mv002 mv003 sm101e1 sm500c1 sm862a sm101e2 sm500c2 sm862b sm836 sm838a
		ren (mv001 mv002 mv003 sm101e1 sm500c1 sm862a sm101e2 sm500c2 sm862b sm836 sm838a) (v001 v002 v003 s101e1 s600ca s1056a s101e2 s600cb s1056b s1033 s1035a)
		append using `t1'
		recode s1033 s1035a (3 8 =.)
		
		egen a_bp_sys = rowmean(s101e1 s600ca s1056a)
		egen a_bp_dial = rowmean(s101e2 s600cb s1056b)
		
		gen a_bp_treat = s1035a if s1033==1   
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
	
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0
		
		keep v001 v002 v003 a_bp_sys a_bp_dial a_bp_treat a_hi_bp140_or_on_med
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	}
	
	if inlist(name, "KyrgyzRepublic2012") {
		drop a_bp_treat a_bp_sys a_bp_dial  a_hi_bp140_or_on_med a_bp_meas_ref
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-KyrgyzRepublic2012/DHS-KyrgyzRepublic2012ind.dta", clear	
		keep v001 v002 v003 s101es s101ed s564s s564d s1027s s1027d s1022 s1023 s1024a s1024b s1024c s1024d s1024e s1024f 
		save `t1'	
		use "${SOURCE}/DHS-KyrgyzRepublic2012/DHS-KyrgyzRepublic2012men.dta", clear	
		keep mv001 mv002 mv003 sm101es sm101ed sm442s sm442d sm831s sm831d sm826 sm827 sm828a sm828b sm828c sm828d sm828e sm828f
		ren (mv001 mv002 mv003 sm101es sm101ed sm442s sm442d sm831s sm831d sm826 sm827 sm828a sm828b sm828c sm828d sm828e sm828f) (v001 v002 v003 s101es s101ed s564s s564d s1027s s1027d s1022 s1023 s1024a s1024b s1024c s1024d s1024e s1024f )
		append using `t1'
		recode s1022 s1023 s1024a s1024b s1024c s1024d s1024e s1024f ( 3 8 =.)
		recode s101es s101ed s564s s564d s1027s s1027d (994 995 = .)
		
		egen a_bp_sys = rowmean(s101es s564s s1027s)
		egen a_bp_dial = rowmean(s101ed s564d s1027d)
		
		egen bptreat = rowtotal(s1024a s1024b s1024c s1024d s1024e s1024f),mi
		gen a_bp_treat = 0 if s1022!=.
		replace a_bp_treat = 1 if bptreat>=1 & bptreat !=. 
		replace a_bp_treat = . if bptreat==. & s1022!=0
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
	
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0
		
		keep v001 v002 v003 a_bp_sys a_bp_dial a_bp_treat a_hi_bp140_or_on_med
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	}		
	

	if inlist(name, "Namibia2013") {
		recode sh327 sh328 sh329a  sh330 (9 =.)

		drop a_diab_treat

		egen diabtreat = rowtotal(sh329a sh330),mi
		gen a_diab_treat = 0 if sh328 ==1 
		replace a_diab_treat = diabtreat>=1 if diabtreat!=.
		replace a_diab_treat = . if diabtreat ==.
	}	
	
	if inlist(name, "Lesotho2014") {
		drop a_bp_treat a_diab_treat a_bp_meas a_hi_bp140 a_hi_bp140_or_on_med a_bp_meas_ref
		
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Lesotho2014/DHS-Lesotho2014ind.dta", clear
		keep v001 v002 v003 sbp1s sbp2s sbp3s sbp1d sbp2d sbp3d s1012a s1012b s1012c s1012e s1012f s1012h s1012ia s1012ib s1012ic s1012id s1012ie s1012if s1012ig 
		recode s1012ia s1012ib s1012ic s1012id s1012ie s1012if s1012ig (3=.)
		recode sbp1s sbp2s sbp3s sbp1d sbp2d sbp3d (994 995 996 =.)
		save `t1'
		
		use "${SOURCE}/DHS-Lesotho2014/DHS-Lesotho2014men.dta", clear
		keep mv001 mv002 mv003 smbp1s smbp1d smbp2s smbp2d smbp3s smbp3d sm812a sm812b sm812c sm812e sm812f sm812h sm812ia sm812ib sm812ic sm812id sm812ie sm812if sm812ig 
		recode smbp1s smbp1d smbp2s smbp2d smbp3s smbp3d (994 995 996 =.)
		recode sm812ia sm812ib sm812ic sm812id sm812ie sm812if sm812ig (3=.)
		ren (mv001 mv002 mv003 smbp1s smbp2s smbp3s smbp1d smbp2d smbp3d sm812a sm812b sm812c sm812e sm812f sm812h sm812ia sm812ib sm812ic sm812id sm812ie sm812if sm812ig) (v001 v002 v003 sbp1s sbp2s sbp3s sbp1d sbp2d sbp3d s1012a s1012b s1012c s1012e s1012f s1012h s1012ia s1012ib s1012ic s1012id s1012ie s1012if s1012ig)
		append using `t1'
		
		egen a_bp_sys = rowmean(sbp1s sbp2s sbp3s)
		egen a_bp_dial = rowmean(sbp1d sbp2d sbp3d)
		
		gen a_diab_diag=(s1012b==1)
		replace a_diab_diag=. if s1012a==.

		gen a_diab_treat = s1012c ==1 
		replace a_diab_treat = . if s1012a==. 
		
		gen a_bp_meas =0 if s1012e ==1 
		replace a_bp_meas =1 if inlist(s1012f,1,2)
		
		egen bptreat = rowtotal(s1012ia s1012ib s1012ic s1012id s1012ie s1012if),mi 
		gen a_bp_treat = bptreat>=1 if s1012h ==1 & bptreat!=.
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
		
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0		
		
		keep v001 v002 v003 a_bp_sys a_bp_dial a_diab_diag a_diab_treat a_bp_meas a_bp_treat a_hi_bp140_or_on_med
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	}		 
