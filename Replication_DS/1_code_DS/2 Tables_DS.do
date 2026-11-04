
log using "${logs}\2 Tables.txt", replace 


* Replication Table 3 OLS	
********************************************************************************	
di "FINANCE AND CARBON EMISSIONS (TABLE 3)"
********************************************************************************

use "$data\2_Interim files_DS\country_sector_cleaned.dta", clear


lab var cotwo_fin_dev1_l1 "Financial development $\times$ CO$_{2} intensity"
lab var cotwo_fin_str2_l1 "Equity share $\times$ CO$_{2} intensity"
lab var share_l1 "Sector share"


eststo clear


eststo ols_pergdp: reghdfe cotwo_per_gdp cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)


estadd local crtsecFE "Yes": ols_pergdp
estadd local crtyrFE "Yes": ols_pergdp
estadd local secyrFE "Yes": ols_pergdp


noi esttab ols_pergdp using "${tables}\\Table.tex", replace ///
	keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) nonum nolines ///
	stats(crtsecFE crtyrFE secyrFE r2 N, fmt(0 0 0 2 %15.0fc) /// 
	labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] R-squared" "No. Observations")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)	

	
filefilter "${tables}\\Table.tex" "${tables}\\Table-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table.tex"		
		


* Extension of Replication Table 3 OLS
********************************************************************************
di "EXTENSION: EXCLUDING HIGH ENVIRONMENTAL POLICY COUNTRIES - TABLE 3"
********************************************************************************

use "$data\2_Interim files_DS\country_sector_cleaned.dta", clear


lab var cotwo_fin_dev1_l1 "Financial development $\times$ CO$_{2} intensity"
lab var cotwo_fin_str2_l1 "Equity share $\times$ CO$_{2} intensity"
lab var share_l1 "Sector share"


* Exclude the same 18 countries (inlist - max 10)
drop if inlist(country, "Australia", "Brazil", "Canada", "China", "France", "Germany")
drop if inlist(country, "India", "Ireland", "Italy", "Japan", "Mexico", "Netherlands")
drop if inlist(country, "Norway", "Portugal", "Spain", "Sweden", "United Kingdom", "United States")


eststo ext: reghdfe cotwo_per_gdp cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)


estadd local crtsecFE "Yes": ext
estadd local crtyrFE "Yes": ext
estadd local secyrFE "Yes": ext


noi esttab ext using "${tables}\Table-Extension.tex", replace ///
    keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) nonum nolines ///
    stats(crtsecFE crtyrFE secyrFE r2 N, fmt(0 0 0 2 %15.0fc) ///
    labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] R-squared" "No. Observations")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)

	
filefilter "${tables}\\Table-Extension.tex" "${tables}\\Table-Extension-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace
cap erase "${tables}\\Table-Extension.tex"			
	

	
		
capture log close