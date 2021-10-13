************************
*** Sexual health*******
************************ 	

	gen w_married=(v502==1)
	replace w_married=. if v502==.
	
	*w_condom_conc: 18-49y woman who had more than one sexual partner in the last 12 months and used a condom during last intercourse
     ** Concurrent partnerships 
	recode v766b (98 99 =.)
	gen wconc_partnerships=v766b>1 if v766b!=.

     ** Condom usage
	rename v761 wcondom
	recode wcondom (8 9 =.)
	replace wcondom=. if v766b==0 | v766b==.
		
	gen w_condom_conc=1 if wcondom==1 & wconc_partnerships==1
    replace w_condom_conc=0 if wcondom==0 & wconc_partnerships==1
    replace w_condom_conc=. if hm_age_yrs<18

	*w_CPR: Use of modern contraceptive methods of women age 15(!)-49 married or living in union
	gen w_CPR=(v313==3) if v313!=. & w_married==1
	
	*w_unmet_fp 15-49y married or in union with unmet need for family planning (1/0)
	*w_need_fp 15-49y married or in union with need for family planning (1/0)
	*w_metany_fp 15-49y married or in union with need for family planning using modern contraceptives (1/0)
	*w_metmod_fp 15-49y married or in union with need for family planning using any contraceptives (1/0)
	
	 tempfile temp1 temp2 temp3
	 
	 preserve
     do "${DO}/Add unmetFP_DHS.do"
	 gen w_metany_fp = 1 if inlist(unmet,3,4)
     replace w_metany_fp = 0 if inlist(unmet,1,2) 
     keep caseid w_unmet_fp w_metany_fp
	 
     save `temp1'
	 restore
	 
	 preserve
	 do "${DO}/Add unmetFPmod_DHS.do"
     gen w_metmod_fp = 1 if inlist(unmet,3,4)
     replace w_metmod_fp = 0 if inlist(unmet,1,2)
	 
	 gen w_need_fp = 1 if w_metmod_fp!=.
     replace w_need_fp = 0 if inlist(unmet,7,9)
	 
     keep w_metmod_fp  w_need_fp w_metmod_fp caseid
	 save `temp2'
	 
	 merge 1:1 caseid using `temp1'
	 drop _merge
	 save `temp3'
	 restore 
	 
	 merge 1:m caseid using `temp3'
     drop if _m == 1
    
	replace w_metany_fp = . if w_married!=1
	replace w_metmod_fp = . if w_married!=1
	replace w_need_fp = . if w_married!=1
	replace w_unmet_fp = . if w_married!=1
	
    *w_metany_fp_q 15-49y married or in union using modern contraceptives among those with need for family planning who use any contraceptives (1/0)
    gen w_metany_fp_q = (w_CPR == 1) if w_need_fp == 1 
	 
