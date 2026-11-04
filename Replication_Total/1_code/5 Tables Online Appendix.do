 log using "${logs}\5 Tables Online Appendix.txt", replace 
  
********************************************************************************	
di "SUMMARY STATISTICS BY COUNTRY (TABLE OA1)"
********************************************************************************
 
use "$data\2_Interim files\country_cleaned.dta", clear
 
bysort country: egen fin_dev1_av=mean(fin_dev1)
bysort country: egen fin_str2_av=mean(fin_str2)

bysort country: egen cotwo_total_per_gdp_av=mean(cotwo_total_per_gdp)

sort country year
drop if country[_n]==country[_n-1]

//

keep country fin_dev1_av fin_str2_av  cotwo_total_per_gdp_av

replace country = "China" if country == "China (People's Republic of)"
replace country = "Macedonia" if country == "Macedonia, FYR"

foreach v of varlist fin_dev1_av fin_str2_av  cotwo_total_per_gdp_av {
    gen `v'_r=string(`v',"%4.3f")
	destring `v'_r, replace
	drop `v'
}

cd "$tables"
dataout, save(TableOA1) tex replace

filefilter "${tables}\\TableOA1.tex" "${tables}\\TableOA1_1.tex", from("\BSdocumentclass[]{article}") to("") replace	
filefilter "${tables}\\TableOA1_1.tex" "${tables}\\TableOA1_2.tex", from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace	
filefilter "${tables}\\TableOA1_2.tex" "${tables}\\TableOA1_3.tex", from("\BSbegin{document}") to("") replace	
filefilter "${tables}\\TableOA1_3.tex" "${tables}\\TableOA1_4.tex", from("\BSbegin{tabular}{lccc} \BShline") to("") replace	
filefilter "${tables}\\TableOA1_4.tex" "${tables}\\TableOA1_5.tex", from("country & fin\BS_dev1\BS_av\BS_r & fin\BS_str2\BS_av\BS_r & cotwo\BS_total\BS_per\BS_gdp\BS_av\BS_r \BS\BS \BShline") to("") replace	
filefilter "${tables}\\TableOA1_5.tex"  "${tables}\\TableOA1_6.tex", from(" Zambia & 0.201 & 0.587 & 0.173 \BS\BS \BShline") to("Zambia & 0.201 & 0.587  & 0.173 \BS\BS") replace	
filefilter "${tables}\\TableOA1_6.tex"  "${tables}\\TableOA1_7.tex", from("\BSend{tabular}") to("") replace	
filefilter "${tables}\\TableOA1_7.tex"  "${tables}\\TableOA1-fin.tex", from("\BSend{document}") to("") replace	

	
cap erase "${tables}\TableOA1.tex"
forvalues i = 1(1)7 {
		cap erase "${tables}\\TableOA1_`i'.tex"
	}
	

	
********************************************************************************	
di "FINANCE AND CARBON EMISSIONS: MECHANISMS (TABLE OA2)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

lab var share_l1 "Sector share"
lab var cotwo_fin_dev1_l1 "Financial development $\times$ CO{2} intensity"
lab var cotwo_fin_str2_l1 "Equity share $\times$ CO{2} intensity"
lab var rd_fin_dev1_l1 "Financial development $\times$ R\&D intensity"
lab var rd_fin_str2_l1 "Equity share $\times$ R\&D intensity"
lab var tang_fin_dev1_l1 "Financial development $\times$ Asset tangibility"
lab var tang_fin_str2_l1 "Equity share $\times$ Asset tangibility"
lab var litig_fin_dev1_l1 "Financial development $\times$ Litigation risk"	
lab var litig_fin_str2_l1 "Equity share $\times$ Litigation risk"

* Panel A. Cross-sector reallocation - R&D intensity, Asset tangibility, Litigation risk
eststo clear
eststo cross_rd: 		reghdfe va_g cotwo_fin_dev1_l1 cotwo_fin_str2_l1 	rd_fin_dev1_l1 rd_fin_str2_l1 		share_l1, absorb(ci it ct) cluster(ci)
eststo cross_asset: 	reghdfe va_g cotwo_fin_dev1_l1 cotwo_fin_str2_l1 	tang_fin_dev1_l1 tang_fin_str2_l1 	share_l1, absorb(ci it ct) cluster(ci)
eststo cross_lit: 		reghdfe va_g cotwo_fin_dev1_l1 cotwo_fin_str2_l1 	litig_fin_dev1_l1 litig_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)

noi esttab 	cross* using "${tables}\\TableOA2a.tex", replace ///
			keep(share_l1 cotwo_fin_dev1_l1 cotwo_fin_str2_l1 rd_fin_dev1_l1 rd_fin_str2_l1 tang_fin_dev1_l1 tang_fin_str2_l1 litig_fin_dev1_l1 litig_fin_str2_l1)  ///
			b(%9.4f) se(%9.4f) f nonum nolines ///
			order(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 rd_fin_dev1_l1 rd_fin_str2_l1 tang_fin_dev1_l1 tang_fin_str2_l1 litig_fin_dev1_l1 litig_fin_str2_l1 share_l1) ///
			stats(r2 N, fmt(2 %15.0fc) /// 
			labels("\hline \addlinespace[1ex] R-squared" "No. Observations")) ///
			label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)		
filefilter "${tables}\\TableOA2a.tex" "${tables}\\TableOA2a-fin.tex", from("CO2") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA2a.tex"

* Panel B. Within-sector efficiency - R&D intensity, Asset tangibility, Litigation risk
eststo clear
eststo within_rd: 		reghdfe cotwo_per_va cotwo_fin_dev1_l1 cotwo_fin_str2_l1 	rd_fin_dev1_l1 rd_fin_str2_l1 		share_l1, absorb(ci it ct) cluster(ci)
eststo within_asset: 	reghdfe cotwo_per_va cotwo_fin_dev1_l1 cotwo_fin_str2_l1 	tang_fin_dev1_l1 tang_fin_str2_l1 	share_l1, absorb(ci it ct) cluster(ci)
eststo within_lit: 		reghdfe cotwo_per_va cotwo_fin_dev1_l1 cotwo_fin_str2_l1 	litig_fin_dev1_l1 litig_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)

estadd local crtsecFE "Yes": within_rd within_asset within_lit
estadd local crtyrFE "Yes": within_rd within_asset within_lit
estadd local secyrFE "Yes": within_rd within_asset within_lit

noi esttab  within* using "${tables}\\TableOA2b.tex", replace ///
			keep(share_l1 cotwo_fin_dev1_l1 cotwo_fin_str2_l1 rd_fin_dev1_l1 rd_fin_str2_l1 tang_fin_dev1_l1 tang_fin_str2_l1 litig_fin_dev1_l1 litig_fin_str2_l1)  ///
			b(%9.4f) se(%9.4f) f nonum nolines ///
			order(cotwo_per_va cotwo_fin_dev1_l1 cotwo_fin_str2_l1 rd_fin_dev1_l1 rd_fin_str2_l1 tang_fin_dev1_l1 tang_fin_str2_l1 litig_fin_dev1_l1 litig_fin_str2_l1 share_l1) ///
			stats(r2 N crtsecFE crtyrFE secyrFE , fmt(2 %15.0fc 0 0 0 ) /// 
			labels("\hline \addlinespace[1ex] R-squared" "No. Observations" ///
				  "\hline \\ \hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" )) ///
			label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)	
filefilter "${tables}\\TableOA2b.tex" "${tables}\\TableOA2b-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA2b.tex"



********************************************************************************	
di "CARBON LEAKAGE, LOW VERSUS HIGH MOBILITY SECTORS (TABLE OA3)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

** Panel A. Low mobility (high transportation costs)
eststo clear
** Imported CO2, total
eststo reg1: reghdfe import_co2_total_ag_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport>0.01 & transport!=., absorb (ci it ct) cluster(ci)
** Imported CO2, households
eststo reg2: reghdfe import_co2_hh_ag_per_gdp 			cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport>0.01 & transport!=., absorb (ci it ct) cluster(ci)
** Imported CO2, same sector
eststo reg3: reghdfe import_co2_ind_same_ag_per_gdp 	cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport>0.01 & transport!=., absorb (ci it ct) cluster(ci)
** Imported CO2, other sectors
eststo reg4: reghdfe import_co2_ind_other_ag_per_gdp 	cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport>0.01 & transport!=., absorb (ci it ct) cluster(ci)
** Imported CO2, GFCF
eststo reg5: reghdfe import_co2_gfcf_ag_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport>0.01 & transport!=., absorb (ci it ct) cluster(ci)
** Imported CO2, government
eststo reg6: reghdfe import_co2_gov_ag_per_gdp 			cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport>0.01 & transport!=., absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	reg1 reg2 reg3 reg4 reg5 reg6
estadd local ctryyrFE "Yes": 	reg1 reg2 reg3 reg4 reg5 reg6
estadd local secyrFE "Yes": 	reg1 reg2 reg3 reg4 reg5 reg6

noi esttab 	reg* using "${tables}\\TableOA3_a.tex", replace ///
			b(%9.4f) se(%9.4f) f nonum nolines keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) ///
			stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
			labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
			label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA3_a.tex" "${tables}\\TableOA3_a-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA3_a.tex"			
			
** Panel B. High mobility (low transportation costs)
eststo clear
** Imported CO2, total
eststo reg1: reghdfe import_co2_total_ag_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport<0.01, absorb (ci it ct) cluster(ci)
** Imported CO2, households
eststo reg2: reghdfe import_co2_hh_ag_per_gdp 			cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport<0.01, absorb (ci it ct) cluster(ci)
** Imported CO2, same sector
eststo reg3: reghdfe import_co2_ind_same_ag_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport<0.01, absorb (ci it ct) cluster(ci)
** Imported CO2, other sectors
eststo reg4: reghdfe import_co2_ind_other_ag_per_gdp 	cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport<0.01, absorb (ci it ct) cluster(ci)
** Imported CO2, GFCF
eststo reg5: reghdfe import_co2_gfcf_ag_per_gdp 			cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport<0.01, absorb (ci it ct) cluster(ci)
** Imported CO2, government
eststo reg6: reghdfe import_co2_gov_ag_per_gdp 			cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if transport<0.01, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	reg1 reg2 reg3 reg4 reg5 reg6
estadd local ctryyrFE "Yes": 	reg1 reg2 reg3 reg4 reg5 reg6
estadd local secyrFE "Yes": 	reg1 reg2 reg3 reg4 reg5 reg6

noi esttab 	reg* using "${tables}\\TableOA3_b.tex", replace ///
			b(%9.4f) se(%9.4f) f nonum nolines keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) ///
			stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
			labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
			label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA3_b.tex" "${tables}\\TableOA3_b-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA3_b.tex"


********************************************************************************	
di "ROBUST SAMPLE: OECD COUNTRIES (TABLE OA4)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var va_oecd_share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear

** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 		cotwo_high_fin_dev1_l1 cotwo_high_fin_str2_l1 va_oecd_share_l1, absorb (ci it ct) cluster (ci)
** value added growth
eststo reg3: reghdfe va_g_oecd 			cotwo_high_fin_dev1_l1 cotwo_high_fin_str2_l1 va_oecd_share_l1, absorb (ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va_oecd 	cotwo_high_fin_dev1_l1 cotwo_high_fin_str2_l1 va_oecd_share_l1, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA4.tex", replace ///
			b(%9.4f) se(%9.4f) f nonum nolines keep(cotwo_high_fin_dev1_l1 cotwo_high_fin_str2_l1 va_oecd_share_l1) ///
			stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
			labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
			label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA4.tex" "${tables}\\TableOA4-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA4.tex"
			
			
********************************************************************************	
di "5-YEAR AVERAGES (TABLE OA5)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear
 

gen pet=1
replace pet=2 if year>1994
replace pet=3 if year>1999
replace pet=4 if year>2004
replace pet=5 if year>2009

bysort country pet: egen fin_dev1_pet=mean(fin_dev1)
bysort country pet: egen fin_str2_pet=mean(fin_str2)

bysort country industry pet: egen cotwo_per_cap_pet=mean(cotwo_per_cap)
bysort country industry pet: egen cotwo_per_gdp_pet=mean(cotwo_per_gdp)
bysort country industry pet: egen va_g_pet=mean(va_g)
bysort country industry pet: egen cotwo_per_va_pet=mean(cotwo_per_va)
bysort country industry pet: egen green_patents_per_cap_pet=mean(green_patents_adjusted_per_cap)
bysort country industry pet: egen green_patents_a_per_cap_pet=mean(green_patents_adjusted_a_per_cap)
bysort country industry pet: egen green_patents_b_per_cap_pet=mean(green_patents_adjusted_b_per_cap)
bysort country industry pet: egen green_patents_per_gdp_pet=mean(green_patents_adjusted_per_gdp)
bysort country industry pet: egen green_patents_a_per_gdp_pet=mean(green_patents_adjusted_a_per_gdp)
bysort country industry pet: egen green_patents_b_per_gdp_pet=mean(green_patents_adjusted_b_per_gdp)
bysort country industry pet: egen share_pet=mean(share)

sort country industry year
drop if pet[_n]==pet[_n-1]

gen fin_dev1_pet_l1=fin_dev1_pet[_n-1] if industry[_n]==industry[_n-1]
gen fin_str2_pet_l1=fin_str2_pet[_n-1] if industry[_n]==industry[_n-1]

gen cotwo_wd_fin_dev1_pet=cotwo_intensity_wd*fin_dev1_pet_l1
gen cotwo_wd_fin_str2_pet=cotwo_intensity_wd*fin_str2_pet_l1

gen share_pet_l1=share_pet[_n-1] if industry[_n]==industry[_n-1]

egen cp=group(country pet)
egen ip=group(industry pet)

label var share_pet_l1 "Sector share"
label var cotwo_wd_fin_dev1_pet "Financial development $\times$ CO2 intensity"
label var cotwo_wd_fin_str2_pet "Equity share $\times$ CO2 intensity"

eststo clear
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp_pet 			cotwo_wd_fin_dev1_pet cotwo_wd_fin_str2_pet share_pet_l1, absorb(ci ip cp) cluster (ci)
** value added growth
eststo reg3: reghdfe va_g_pet 					cotwo_wd_fin_dev1_pet cotwo_wd_fin_str2_pet share_pet_l1, absorb(ci ip cp) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va_pet 			cotwo_wd_fin_dev1_pet cotwo_wd_fin_str2_pet share_pet_l1, absorb(ci ip cp) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4 
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA5.tex", replace ///
			b(%9.4f) se(%9.4f) f nonum nolines drop(_cons) ///
			stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
			labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
			label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA5.tex" "${tables}\\TableOA5-fin.tex", from("CO2") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA5.tex"


********************************************************************************	
di "FINANCIAL DEVELOPMENT AND STRUCTURE, CREDIT VERSUS STOCK (TABLE OA6)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear

** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 			cotwo_credit_l1 cotwo_stock_l1 share_l1, absorb (ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g cotwo_credit_l1 	cotwo_stock_l1 share_l1, absorb (ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 			cotwo_credit_l1 cotwo_stock_l1 share_l1, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA6.tex", replace ///
			b(%9.4f) se(%9.4f) f nonum nolines keep(cotwo_credit_l1 cotwo_stock_l1 share_l1) ///
			stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
			labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
			label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA6.tex" "${tables}\\TableOA6-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA6.tex"


********************************************************************************	
di "CONTROLLING FOR EXTERNAL FINANCIAL DEPENDENCE (TABLE OA7)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear

** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 					cotwo_fin_dev1_l1 cotwo_fin_str2_l1 ext_dep_fin_dev1_l1 ext_dep_fin_str2_l1 share_l1, absorb (ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g cotwo_fin_dev1_l1 			cotwo_fin_str2_l1 ext_dep_fin_dev1_l1 ext_dep_fin_str2_l1 share_l1, absorb (ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va cotwo_fin_dev1_l1 	cotwo_fin_str2_l1 ext_dep_fin_dev1_l1 ext_dep_fin_str2_l1 share_l1, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 	

noi esttab 	reg* using "${tables}\\TableOA7.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines /// 
		keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 ext_dep_fin_dev1_l1 ext_dep_fin_str2_l1 share_l1) ///
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA7.tex" "${tables}\\TableOA7-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA7.tex"

********************************************************************************	
di "ROBUSTNESS: ALTERNATIVE POLLUTION INTENSIFIES (TABLE OA8)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

lab var cotwo_c_fin_str2_l1 "Equity share cross CO{2} intensity (Contemporaneous)"

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear
** Contemporaneous carbon intensity
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 				cotwo_c_fin_dev1_l1 cotwo_c_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g 						cotwo_c_fin_dev1_l1 cotwo_c_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 				cotwo_c_fin_dev1_l1 cotwo_c_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 	

noi esttab 	reg* using "${tables}\\TableOA8_a.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines /// 
		keep(cotwo_c_fin_dev1_l1 cotwo_c_fin_str2_l1 share_l1) ///
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA8_a.tex" "${tables}\\TableOA8_a-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA8_a.tex"

lab var cotwo_alt_fin_dev1_l1 "Financial development $\times$ CO{2} intensity (US)"
lab var cotwo_alt_fin_str2_l1 "Equity share $\times$ CO{2} intensity (US)"

eststo clear
** US carbon intensity
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 			cotwo_alt_fin_dev1_l1 cotwo_alt_fin_str2_l1 share_l1 if country!="United States", absorb(ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g 					cotwo_alt_fin_dev1_l1 cotwo_alt_fin_str2_l1 share_l1 if country!="United States", absorb(ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 			cotwo_alt_fin_dev1_l1 cotwo_alt_fin_str2_l1 share_l1 if country!="United States", absorb(ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA8_b.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines /// 
		keep(cotwo_alt_fin_dev1_l1 cotwo_alt_fin_str2_l1 share_l1) ///
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA8_b.tex" "${tables}\\TableOA8_b-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA8_b.tex"
	
	

********************************************************************************	
di "ADDING CORPORATE BONDS (TABLE OA9)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

*Financial development = credit + stocks + bonds; Equity share = stocks / (credit + stocks + bonds)
label var share_l1 "Sector share"

foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 			cotwo_fin_dev1_b_l1 cotwo_fin_str2_c_l1 share_l1, absorb (ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g 					cotwo_fin_dev1_b_l1 cotwo_fin_str2_c_l1 share_l1, absorb (ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 			cotwo_fin_dev1_b_l1 cotwo_fin_str2_c_l1 share_l1, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA9.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines /// 
		keep(cotwo_fin_dev1_b_l1 cotwo_fin_str2_c_l1 share_l1) ///
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA9.tex" "${tables}\\TableOA9-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA9.tex"


********************************************************************************	
di "ADDING PRIVATE EQUITY (TABLE OA10)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 		cotwo_fin_dev1_e_l1 cotwo_fin_str2_e_l1 share_l1, absorb (ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g 				cotwo_fin_dev1_e_l1 cotwo_fin_str2_e_l1 share_l1, absorb (ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 		cotwo_fin_dev1_e_l1 cotwo_fin_str2_e_l1 share_l1, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA10.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines /// 
		keep(cotwo_fin_dev1_e_l1 cotwo_fin_str2_e_l1 share_l1) ///
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA10.tex" "${tables}\\TableOA10-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA10.tex"


********************************************************************************	
di "ONLY BUSINESS CREDIT (TABLE OA11)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear

** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 		cotwo_fin_dev1a_l1 cotwo_fin_str2a_l1 share_l1, absorb (ci it ct) cluster(ci)
** Value added growth
eststo reg3: reghdfe va_g 				cotwo_fin_dev1a_l1 cotwo_fin_str2a_l1 share_l1, absorb (ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 		cotwo_fin_dev1a_l1 cotwo_fin_str2a_l1 share_l1, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA11.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines drop(_cons) /// 
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA11.tex" "${tables}\\TableOA11-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA11.tex"


********************************************************************************	
di "CONTROLLING FOR FUEL SUBSIDIES (TABLE OA12)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 fin_dev1_subsidy_l1 fin_str2_subsidy_l1 share_l1, absorb (ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g 				cotwo_fin_dev1_l1 cotwo_fin_str2_l1 fin_dev1_subsidy_l1 fin_str2_subsidy_l1 share_l1, absorb (ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 fin_dev1_subsidy_l1 fin_str2_subsidy_l1 share_l1, absorb (ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA12.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines /// 
		keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 fin_dev1_subsidy_l1 fin_str2_subsidy_l1 share_l1) ///
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA12.tex" "${tables}\\TableOA12-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA12.tex"



********************************************************************************	
di "CONTROLLING FOR ENVIRONMENTAL LAWS AND POLICIES (TABLE OA13)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

label var cotwo_environmental_laws_l1 "No. environmental laws and policies $\times$ CO{2} intensity"

eststo clear
** Panel A. Environmental laws and policies
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 cotwo_environmental_laws_l1 share_l1, absorb(ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g 				cotwo_fin_dev1_l1 cotwo_fin_str2_l1 cotwo_environmental_laws_l1 share_l1, absorb(ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 cotwo_environmental_laws_l1 share_l1, absorb(ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA13_a.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines drop(_cons) ///
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA13_a.tex" "${tables}\\TableOA13_a-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA13_a.tex"

eststo clear
** Panel B. Carbon tax or ETS
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 cotwo_carbon_tax_ets_l1 share_l1, absorb(ci it ct) cluster(ci)
** value added growth
eststo reg3: reghdfe va_g 				cotwo_fin_dev1_l1 cotwo_fin_str2_l1 cotwo_carbon_tax_ets_l1 share_l1, absorb(ci it ct) cluster(ci)
** CO2 per value added
eststo reg4: reghdfe cotwo_per_va 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 cotwo_carbon_tax_ets_l1 share_l1, absorb(ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": 	 reg2 reg3 reg4
estadd local ctryyrFE "Yes": 	 reg2 reg3 reg4 
estadd local secyrFE "Yes": 	 reg2 reg3 reg4 

noi esttab 	reg* using "${tables}\\TableOA13_b.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines drop(_cons) /// 
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA13_b.tex" "${tables}\\TableOA13_b-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA13_b.tex"


********************************************************************************	
di "ALTERNATIVE EMISSIONS DATA (TABLE OA14)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear
*** CO2 data from exio, including non-combustion
** CO2 per GDP
eststo reg2: reghdfe cotwo_per_gdp_exio 	cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)

*** All air emissions data from exio, including non-combustion
** Emissions per GDP
eststo reg4: reghdfe tot_air_per_gdp_exio 	cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)

estadd local ctrysecFE "Yes": reg2 reg4
estadd local ctryyrFE "Yes":  reg2 reg4 
estadd local secyrFE "Yes":   reg2 reg4 

noi esttab 	reg* using "${tables}\\TableOA14.tex", replace ///
		b(%9.4f) se(%9.4f) f nonum nolines drop(_cons) /// 
		stats(ctrysecFE ctryyrFE secyrFE N r2 , fmt(0 0 0 %15.0fc 2) /// 
		labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] No. Observations" "R-squared")) ///
		label nomtitles style(tex) nogaps nonotes	star(* .1 ** .05 *** .01)  
filefilter "${tables}\\TableOA14.tex" "${tables}\\TableOA14-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\TableOA14.tex"




********************************************************************************	
di "PROPERTIES OF INITIAL AND PROPENSITY SCORE-MATCHED SAMPLE (TABLE OA15)"
********************************************************************************
use "$data\2_Interim files\orbis_cleaned.dta", clear

eststo clear
estimates clear

gen BE = .
gen nonBE = .
gen diff = .
gen pval = .
gen ttest = ""


local i = 1
foreach var in tang prof nopl size {
	
	ttest `var' if year == 2004, by(belgium)   // before matching

	replace BE = `r(mu_2)' 					if _n==`i'
	replace nonBE = `r(mu_1)' 				if _n==`i'
	replace diff = `r(mu_2)' - `r(mu_1)' 	if _n==`i'
	replace pval = `r(p)' 					if _n==`i'
	replace ttest = "`var'" if _n==`i'
	
	local i = `i' + 1
}

	ttest tang if year == 2004, by(belgium) // after matching
	replace BE = `r(N_2)' if _n==5
	replace nonBE = `r(N_1)' if _n==5

local i = 10
foreach var in tang prof nopl size {
	
	ttest `var' if year == 2004 & !missing(_weight), by(belgium) // after matching

	replace BE = `r(mu_2)' 					if _n==`i'
	replace nonBE = `r(mu_1)' 				if _n==`i'
	replace diff = `r(mu_2)' - `r(mu_1)' 	if _n==`i'
	replace pval = `r(p)' 					if _n==`i'
	replace ttest = "`var'" if _n==`i'
	
	local i = `i' + 1
}

	ttest tang if year == 2004 & !missing(_weight), by(belgium) // after matching
	replace BE = `r(N_2)' if _n==14
	replace nonBE = `r(N_1)' if _n==14
	
gen 	lab = ""
replace lab = "Tangible assets / Total assets" if ttest=="tang"
replace lab = "Operating profit / Total assets" if ttest=="prof"
replace lab = "Negative profit dummy" if ttest=="nopl"
replace lab = "Log (Total assets)" if ttest=="size"
replace lab = "No. observations" if _n==14 | _n==5

keep BE nonBE diff pval ttest lab

gen 	helper = "MATCHED" if inrange(_n, 1, 5)
replace	helper = "NON-MATCHED" if inrange(_n, 10, 14)

drop if missing(helper)

gen 	star = "*" 		if pval <=0.001 
replace star = "**" 	if pval <=0.050 
replace star = "***" 	if pval <=0.010 

replace diff = round(diff, 0.001)
replace BE = round(BE, 0.001)
replace nonBE = round(nonBE, 0.001)

gen difference = string(diff) + star
replace difference = "" if difference=="."
replace difference = subinstr(difference, ".", "0.", .)

gen BE_sample = string(BE) 
replace BE_sample = subinstr(BE_sample, ".", "0.", .) if BE<1

gen nonBE_sample = string(nonBE)
replace nonBE_sample = subinstr(nonBE_sample, ".", "0.", .)  if BE<1
replace nonBE_sample = "2,330" if nonBE_sample=="2330"

keep  lab BE_sample nonBE_sample difference helper

preserve
drop if helper=="NON-MATCHED"
drop helper
order lab BE_sample nonBE_sample difference
cd "$tables"
dataout, save(TableOA15_1) tex replace dec(3)


	filefilter "${tables}\\TableOA15_1.tex" "${tables}\\TableOA15_2.tex", from("\BSend{document}") to("") replace	
	filefilter "${tables}\\TableOA15_2.tex" "${tables}\\TableOA15_3.tex", from("\BSend{tabular}") to("") replace	
	filefilter "${tables}\\TableOA15_3.tex" "${tables}\\TableOA15_4.tex", from("\BSbegin{tabular}{lccc} \BShline") to("") replace	
	filefilter "${tables}\\TableOA15_4.tex" "${tables}\\TableOA15_5.tex", from("\BSbegin{document}") to("") replace	
	filefilter "${tables}\\TableOA15_5.tex" "${tables}\\TableOA15_6.tex", from("\BSdocumentclass[]{article}") to("") replace	
	filefilter "${tables}\\TableOA15_6.tex" "${tables}\\TableOA15_7.tex", from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace	
	filefilter "${tables}\\TableOA15_7.tex" "${tables}\\TableOA15_8.tex", from("lab & BE\BS_sample & nonBE\BS_sample & difference \BS\BS") to("") replace
	filefilter "${tables}\\TableOA15_8.tex" "${tables}\\TableOA15_9.tex", from("\BShline") to("") replace
	filefilter "${tables}\\TableOA15_9.tex" "${tables}\\TableOA15_a-fin.tex", from(".000") to("") replace	
	
	forvalues i = 1(1)9 {
		cap erase "${tables}\\TableOA15_`i'.tex"
	}
restore

preserve
drop if helper=="MATCHED"
drop helper
order lab BE_sample nonBE_sample difference
cd "$tables"
dataout, save(TableOA15_1) tex replace dec(3)


	filefilter "${tables}\\TableOA15_1.tex" "${tables}\\TableOA15_2.tex", from("\BSend{document}") to("") replace	
	filefilter "${tables}\\TableOA15_2.tex" "${tables}\\TableOA15_3.tex", from("\BSend{tabular}") to("") replace	
	filefilter "${tables}\\TableOA15_3.tex" "${tables}\\TableOA15_4.tex", from("\BSbegin{tabular}{lccc} \BShline") to("") replace	
	filefilter "${tables}\\TableOA15_4.tex" "${tables}\\TableOA15_5.tex", from("\BSbegin{document}") to("") replace	
	filefilter "${tables}\\TableOA15_5.tex" "${tables}\\TableOA15_6.tex", from("\BSdocumentclass[]{article}") to("") replace	
	filefilter "${tables}\\TableOA15_6.tex" "${tables}\\TableOA15_7.tex", from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace	
	filefilter "${tables}\\TableOA15_7.tex" "${tables}\\TableOA15_8.tex", from("lab & BE\BS_sample & nonBE\BS_sample & difference \BS\BS ") to("") replace
	filefilter "${tables}\\TableOA15_8.tex" "${tables}\\TableOA15_9.tex", from("\BShline") to("") replace
	filefilter "${tables}\\TableOA15_9.tex" "${tables}\\TableOA15_b-fin.tex", from(".000") to("") replace	
	
	forvalues i = 1(1)9 {
		cap erase "${tables}\\TableOA15_`i'.tex"
	}
restore



********************************************************************************	
di "ISOLATE COUNTRIES WITH LOW CORRELATION BETWEEN ENVIRONMENTAL LAWS AND INSTRUMENTS (TABLE OA16)"
********************************************************************************
** Isolate: Bulgaria, Colombia, Costa Rica, Hungary, Morocco, and Thailand

use "$data\2_Interim files\country_cleaned.dta", clear

egen idd=group(country)
tab country if idd==7 | idd==11 | idd==12 | idd==21 | idd==31 | idd==43

*** Column correlations 
preserve
corr dom_st_lawpol entrybarriers treated_stock cur100
matrix define C = r(C)
drop _all
svmat double C, names(col)
matrix drop C
gen 	lab = ""
replace lab = "Number of green laws and regulations up to this point" if _n==1 	// dom_st_lawpol
replace lab = "Entry barriers" if _n==2 										// entrybarriers
replace lab = "Equity market liberalization" if _n==3 						 	// treated_stock
replace lab = "Current account liberalization" if _n==4 						// cur100
save "${tables}\corrOA15_1.dta", replace
restore

*** Column 2 correlations
preserve
corr dom_st_lawpol entrybarriers treated_stock cur100 /// 
	if idd!=7 & idd!=11 & idd!=12 & idd!=21 & idd!=31 & idd!=43
matrix define C = r(C)
drop _all
svmat double C, names(col)
matrix drop C
gen 	lab = ""
replace lab = "Number of green laws and regulations up to this point" if _n==1 	// dom_st_lawpol
replace lab = "Entry barriers" if _n==2 										// entrybarriers
replace lab = "Equity market liberalization" if _n==3 						 	// treated_stock
replace lab = "Current account liberalization" if _n==4 						// cur100
save "${tables}\corrOA15_2.dta", replace
restore

*** Panel A columns 1 and 2 
preserve
use "${tables}\corrOA15_1.dta", clear
keep dom_st_lawpol lab
order lab, first
ren dom_st_lawpol full_sample
merge 1:1 lab using "${tables}\corrOA15_2.dta"
keep lab full_sample dom_st_lawpol
ren dom_st_lawpol sub_sample

gen 	sort = 1 
replace sort = 2 if lab == "Entry barriers" 
replace sort = 3 if lab == "Equity market liberalization"
replace sort = 4 if lab == "Current account liberalization"
sort sort

drop sort

drop if full_sample==1 
cd "$tables"
dataout, save(TableOA16_1) tex replace dec(2)


	filefilter "${tables}\\TableOA16_1.tex" "${tables}\\TableOA16_2.tex", from("\BSend{document}") to("") replace	
	filefilter "${tables}\\TableOA16_2.tex" "${tables}\\TableOA16_3.tex", from("\BSend{tabular}") to("") replace	
	filefilter "${tables}\\TableOA16_3.tex" "${tables}\\TableOA16_4.tex", from("\BSbegin{tabular}{lcc} \BShline") to("") replace	
	filefilter "${tables}\\TableOA16_4.tex" "${tables}\\TableOA16_5.tex", from("\BSbegin{document}") to("") replace	
	filefilter "${tables}\\TableOA16_5.tex" "${tables}\\TableOA16_6.tex", from("\BSdocumentclass[]{article}") to("") replace	
	filefilter "${tables}\\TableOA16_6.tex" "${tables}\\TableOA16_7.tex", from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace	
	filefilter "${tables}\\TableOA16_7.tex" "${tables}\\TableOA16_8.tex", from("lab & full\BS_sample & sub\BS_sample \BS\BS \BShline") to("") replace
	filefilter "${tables}\\TableOA16_8.tex" "${tables}\\TableOA16_a-fin.tex", from("\BShline") to("") replace	
	
	forvalues i = 1(1)8 {
		cap erase "${tables}\\TableOA16_`i'.tex"
	}
restore	

cap erase "${tables}\corrOA16_1.dta"
cap erase "${tables}\corrOA16_2.dta"

*** Panel B

* First stages and R2
label var fin_dev1_l1 "Financial development"
label var fin_str2_l1 "Equity share"
									
xi: ivreg2 cotwo_total_per_gdp 	(fin_dev1_l1 fin_str2_l1=entrybarriers_l2 treated_stock_l2 cur100_l2) /// 
										log_gdp_per_cap_l1 log_gdp_per_cap_sq_l1 pop_mil_l1 recession_l1 dom_st_lawpol_l1 i.country i.year /// 
										if idd!=7 & idd!=11 & idd!=12 & idd!=21 & idd!=31 & idd!=43
estimates store reg2

estadd local ctrycontrols "Yes":  reg2
estadd local ctryFE "Yes":  reg2
estadd local yrFE "Yes":  reg2

noi esttab  reg2 using "${tables}\\TableOA16_b-fin.tex", replace ///
	keep(fin_dev1_l1 fin_str2_l1) ///
	b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(ctrycontrols ctryFE yrFE r2 N idstat idp cdf j jp, fmt(0 0 0 2 %15.0fc 3 3 3 3 3) /// 
	labels("\hline \addlinespace[1ex] Country controls" "Country FE" "Year FE" /// 
		   "\hline \addlinespace[1ex] R-squared" "No. Observations" /// 
		   "\hline \addlinespace[1ex] Kleibergen-Paap LM statistic" "\textit{p}-value" "F statistic" "Hansen J statistic" "\textit{p}-value")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)	
	
		
********************************************************************************	
di "PROPERTIES OF INITIAL AND PROPENSITY SCORE-MATCHED SAMPLE (TABLE OA17)"
********************************************************************************
use "$data\2_Interim files\country_sector_cleaned.dta", clear

sort industry, stable
drop if industry[_n]==industry[_n-1]

keep cotwo_intensity_wd rd tang_2 sued_share
*round to two decimals
lab var cotwo_intensity_wd "Carbon intensity"
lab var sued_share "Litigation risk"
lab var rd "R\&D intensity"
lab var tang_2 "Asset tangibility"

eststo clear
estpost correlate ///
		cotwo_intensity_wd rd tang_2 sued_share ///
		, matrix listwise
esttab using "${tables}\TableOA17.tex", unstack b(2) replace f ///
style(tex) nonotes nomtitle nonum nostar label compress nogaps noobs not

filefilter "${tables}\\TableOA17.tex" "${tables}\\TableOA17-fin.tex", from(" &Carbon intensity&R\BS&D intensity&Asset tangibility&Litigation risk\BS\BS") to("") replace

cap erase "${tables}\\TableOA17.tex"	
	
log close