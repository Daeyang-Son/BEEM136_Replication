log using "${logs}\4 Tables Appendix.txt", replace  
 
********************************************************************************	
di "SUMMARY STATISTICS (TA2)"
********************************************************************************

use "$data\2_Interim files\country_cleaned.dta", clear

** country-level


lab var cotwo_total_per_gdp "CO$_{2} emissions/GDP"
lab var fin_dev1 "Financial development"
lab var fin_str2 "Equity share"
lab var gdp_per_cap "GDP per capita"
lab var pop_mil "Population"
lab var recession "Recession"
lab var dom_st_lawpol "# environmental laws and policies"
lab var entrybarriers "Entry barriers"
lab var treated_stock "Equity market liberalization"
lab var cur100 "Current account liberalization"

global country_lev "cotwo_total_per_gdp fin_dev1 fin_str2 gdp_per_cap pop_mil recession dom_st_lawpol entrybarriers treated_stock cur100"

tabstat $country_lev, stat(mean p50 sd min  max) col(stats)

keep $country_lev
outreg2 using "${tables}\\Table_TA2.tex", replace sum(detail) eqkeep(mean p50 sd min  max) tex(frag) label dec(3) sortvar($country_lev)


filefilter "${tables}\\Table_TA2.tex" "${tables}\\Table_TA2_1.tex", from(" & (1) & (2) & (3) & (4) & (5) \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_1.tex" "${tables}\\Table_TA2_2.tex", from(" &  &  &  &  &  \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_2.tex" "${tables}\\Table_TA2_3.tex", from("\BSbegin{tabular}{lccccc} \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_3.tex" "${tables}\\Table_TA2_4.tex", from(" &  &  &  &  &  \BS\BS \BShline") to("") replace
filefilter "${tables}\\Table_TA2_4.tex" "${tables}\\Table_TA2_5.tex", from("VARIABLES & mean & p50 & sd & min & max \BS\BS \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_5.tex" "${tables}\\Table_TA2_6.tex", from("\BSend{tabular}") to("") replace	
filefilter "${tables}\\Table_TA2_6.tex" "${tables}\\Table_TA2_country-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	

cap erase "${tables}\Table_TA2.tex"
forvalues i = 1(1)6 {
		cap erase "${tables}\\Table_TA2_`i'.tex"
	}
cap erase "${tables}\Table_TA2.txt"


** industry level (UNIDO)

use "$data\2_Interim files\country_sector_cleaned.dta", clear

lab var cotwo_per_gdp "CO2 emissions/GDP"
lab var va_g "Growth in value added"
lab var cotwo_per_va "CO2 emissions per value added"
lab var green_patents_adjusted_per_gdp "Green patents/GDP"
lab var green_patents_adjusted_a_per_gdp "Green patents/GDP (excl. transport and waste)"
lab var green_patents_adjusted_b_per_gdp "Green patents/GDP (energy intensive sectors)"
lab var share "Sector share"

gen manf = (inlist(industry, 20, 26, 27, 1516, 1719, 2122, 2325, 2833, 3435))

keep if manf==1

global industry_lev "cotwo_per_gdp va_g cotwo_per_va share green_patents_adjusted_per_gdp green_patents_adjusted_a_per_gdp green_patents_adjusted_b_per_gdp"

tabstat $industry_lev, stat(mean p50 sd min  max) col(stats)

keep $industry_lev
outreg2 using "${tables}\\Table_TA2.tex", replace sum(detail) eqkeep(mean p50 sd min  max) tex(frag) label dec(3) sortvar($industry_lev)


filefilter "${tables}\\Table_TA2.tex" "${tables}\\Table_TA2_1.tex", from(" & (1) & (2) & (3) & (4) & (5) \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_1.tex" "${tables}\\Table_TA2_2.tex", from(" &  &  &  &  &  \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_2.tex" "${tables}\\Table_TA2_3.tex", from("\BSbegin{tabular}{lccccc} \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_3.tex" "${tables}\\Table_TA2_4.tex", from(" &  &  &  &  &  \BS\BS \BShline") to("") replace
filefilter "${tables}\\Table_TA2_4.tex" "${tables}\\Table_TA2_5.tex", from("VARIABLES & mean & p50 & sd & min & max \BS\BS \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_5.tex" "${tables}\\Table_TA2_6.tex", from("\BSend{tabular}") to("") replace	
filefilter "${tables}\\Table_TA2_6.tex" "${tables}\\Table_TA2_industry_UNIDO-fin.tex", from("CO2") to("CO\$_{2}\$") replace	

cap erase "${tables}\Table_TA2.tex"
forvalues i = 1(1)6 {
		cap erase "${tables}\\Table_TA2_`i'.tex"
	}
cap erase "${tables}\Table_TA2.txt"


** industry level (OECD)

use "$data\2_Interim files\country_sector_cleaned.dta", clear

lab var cotwo_per_gdp "CO2 emissions/GDP"
lab var va_g "Growth in value added"
lab var cotwo_per_va "CO2 emissions per value added"
lab var green_patents_adjusted_per_gdp "Green patents/GDP"
lab var green_patents_adjusted_a_per_gdp "Green patents/GDP (excl. transport and waste)"
lab var green_patents_adjusted_b_per_gdp "Green patents/GDP (energy intensive sectors)"
lab var share "Sector share"

keep if oecd==1

global industry_lev_oecd "cotwo_per_gdp va_g_oecd cotwo_per_va_oecd green_patents_adjusted_per_gdp green_patents_adjusted_a_per_gdp green_patents_adjusted_b_per_gdp va_oecd_share"

tabstat $industry_lev_oecd, stat(mean p50 sd min  max) col(stats)

keep $industry_lev_oecd
outreg2 using "${tables}\\Table_TA2.tex", replace sum(detail) eqkeep(mean p50 sd min  max) tex(frag) label dec(3) sortvar($industry_lev_oecd)


filefilter "${tables}\\Table_TA2.tex" "${tables}\\Table_TA2_1.tex", from(" & (1) & (2) & (3) & (4) & (5) \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_1.tex" "${tables}\\Table_TA2_2.tex", from(" &  &  &  &  &  \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_2.tex" "${tables}\\Table_TA2_3.tex", from("\BSbegin{tabular}{lccccc} \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_3.tex" "${tables}\\Table_TA2_4.tex", from(" &  &  &  &  &  \BS\BS \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_4.tex" "${tables}\\Table_TA2_5.tex", from("VARIABLES & mean & p50 & sd & min & max \BS\BS \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_5.tex" "${tables}\\Table_TA2_6.tex", from("\BSend{tabular}") to("") replace	
filefilter "${tables}\\Table_TA2_6.tex" "${tables}\\Table_TA2_industry_OECD-fin.tex", from("CO2") to("CO\$_{2}\$") replace	

cap erase "${tables}\Table_TA2.tex"
forvalues i = 1(1)6 {
		cap erase "${tables}\\Table_TA2_`i'.tex"
	}
cap erase "${tables}\Table_TA2.txt"


** firm level (Orbis)

use "$data\2_Interim files\orbis_cleaned.dta", clear

keep if (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & emissions_per_sales>=0 & emissions_per_assets>=0

lab var equity_share "Equity share"
lab var emissions_per_sales "CO$_{2} emissions/sales, in thousands"
lab var emissions_per_assets "CO$_{2} emissions/assets, in thousands"

replace emissions_per_sales=emissions_per_sales/1000
replace emissions_per_assets=emissions_per_assets/1000

global orbis "emissions_per_sales emissions_per_assets equity_share"

tabstat $orbis, stat(mean p50 sd min  max) col(stats)

keep $orbis
outreg2 using "${tables}\\Table_TA2.tex", replace sum(detail) eqkeep(mean p50 sd min  max) tex(frag) label dec(3) sortvar($orbis)



filefilter "${tables}\\Table_TA2.tex" "${tables}\\Table_TA2_1.tex", from(" & (1) & (2) & (3) & (4) & (5) \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_1.tex" "${tables}\\Table_TA2_2.tex", from(" &  &  &  &  &  \BS\BS") to("") replace	
filefilter "${tables}\\Table_TA2_2.tex" "${tables}\\Table_TA2_3.tex", from("\BSbegin{tabular}{lccccc} \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_3.tex" "${tables}\\Table_TA2_4.tex", from(" &  &  &  &  &  \BS\BS \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_4.tex" "${tables}\\Table_TA2_5.tex", from("VARIABLES & mean & p50 & sd & min & max \BS\BS \BShline") to("") replace	
filefilter "${tables}\\Table_TA2_5.tex"  "${tables}\\Table_TA2_6.tex", from("\BSend{tabular}") to("") replace	
filefilter "${tables}\\Table_TA2_6.tex" "${tables}\\Table_TA2_orbis-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	

cap erase "${tables}\Table_TA2.tex"
forvalues i = 1(1)6 {
		cap erase "${tables}\\Table_TA2_`i'.tex"
	}
cap erase "${tables}\Table_TA2.txt"



log close


