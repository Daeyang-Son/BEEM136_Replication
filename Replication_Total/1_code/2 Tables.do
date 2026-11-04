
log using "${logs}\2 Tables.txt", replace 

* This do file produces Table 1 - 9

********************************************************************************	
di "INDUSTRY BENCHMARKS (TABLE 1)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

*creating a dataset that contains descriptive statistics

keep industry cotwo_intensity_wd_all rd tang_2 sued_share
sumup cotwo_intensity_wd_all rd tang_2 sued_share, by(industry) statistics(mean) replace
collapse cotwo_intensity_wd_all rd tang_2 sued_share, by(industry)


*labelling variables to produce industry codes and names for descriptive stats table

gen industry_n = industry

label define industry_n 20 "Wood and products of wood and cork" 26 "Other non-metallic mineral products" 27 "Basic metals" 45 "Construction" 60 "Land transport: transport via pipelines" 61 "Water transport" 62 "Air transport" 105 "Agriculture, hunting, forestry, and fishing" 1014 "Mining and quarrying" 1516 "Food products, beverages, and tobacco" 1719 "Textiles, textile products, leather, and footwear" 2122 "Pulp, paper, paper products, printing, and publishing" 2325 "Chemical, rubber, plastics, and fuel products" 2833 "Fabricated metal products, machinery, and equipment" 3435 "Transport equipment" 4041 "Electricity, gas, and water supply"
label values industry_n industry_n
label define industry 20 "20_" 26 "26_" 27 "27_" 45 "45_" 60 "60_" 61 "61_" 62 "62_" 105 "01-05" 1014 "10-14" 1516 "15-16" 1719 "17-19" 2122 "21-22" 2325 "23-25" 2833 "28-33" 3435 "34-35" 4041 "40-41"
label values industry industry

decode industry, gen(industry_code)
decode industry_n, gen(industry_name)
gen industry_order=industry_code
replace industry_order=substr(industry_order, 1, 2)
destring industry_order, replace
sort industry_order

*exporting final table of summary stats

keep industry_code industry_name cotwo_intensity_wd_all rd tang_2 sued_share
order industry_code industry_name cotwo_intensity_wd_all rd tang_2 sued_share
cd "$tables"
dataout, save(Table1) tex replace dec(3)

	filefilter "${tables}\\Table1.tex" "${tables}\\Table1_1.tex", from("\BSend{document}") to("") replace	
	filefilter "${tables}\\Table1_1.tex" "${tables}\\Table1_2.tex", from("\BSend{tabular}") to("") replace	
	filefilter "${tables}\\Table1_2.tex" "${tables}\\Table1_3.tex", from("\BSbegin{tabular}{lccccc} \BShline") to("") replace	
	filefilter "${tables}\\Table1_3.tex" "${tables}\\Table1_4.tex", from("\BSbegin{document}") to("") replace	
	filefilter "${tables}\\Table1_4.tex" "${tables}\\Table1_5.tex", from("\BSdocumentclass[]{article}") to("") replace	
	filefilter "${tables}\\Table1_5.tex" "${tables}\\Table1_6.tex", from("\BSsetlength{\BSpdfpagewidth}{8.5in} \BSsetlength{\BSpdfpageheight}{11in}") to("") replace	
	filefilter "${tables}\\Table1_6.tex" "${tables}\\Table1_7.tex", from("industry\BS_code & industry\BS_name & cotwo\BS_intensity\BS_wd\BS_all & rd & tang\BS_2 & sued\BS_share \BS\BS \BShline") to("") replace
	filefilter "${tables}\\Table1_7.tex" "${tables}\\Table1_8.tex", from("d \BS\BS") to("d \BS\BS \BShline") replace	
	filefilter "${tables}\\Table1_8.tex" "${tables}\\Table1-fin.tex", from("\BS_") to(" ") replace	
	
	cap erase "${tables}\Table1.tex"
	forvalues i = 1(1)8 {
		cap erase "${tables}\\Table1_`i'.tex"
	}
	

********************************************************************************	
di "FINANCE AND CARBON EMISSIONS: AGGREGATE RESULTS (TABLE 2)"
********************************************************************************

use "$data\2_Interim files\country_cleaned.dta", clear
drop if country=="China" // do not have sufficent data on "No. environmental laws and policies" 

label var fin_dev1_l1 "Financial development"
label var fin_str2_l1 "Equity share"
label var log_gdp_per_cap_l1  "Log GDP per capita"
label var log_gdp_per_cap_sq_l1  "Log GDP per capita squared"
label var pop_mil_l1  "Log (Population)"
label var recession_l1  "Recession"
label var dom_st_lawpol_l1 "No. environmental laws and policies"
label var entrybarriers_l2 "Entry barriers "
label var treated_stock_l2  "Equity market liberalization "
label var cur100_l2 "Current account liberalization"
*formal variable definitions can be found in table notes, all variables are lagged
encode country, gen(country_)

gl c log_gdp_per_cap_l1 log_gdp_per_cap_sq_l1 pop_mil_l1 recession_l1 dom_st_lawpol_l1

* Generate new varaible so that we can use them but aviod them showing up in the output
foreach var in log_gdp_per_cap_l1 log_gdp_per_cap_sq_l1 pop_mil_l1 recession_l1 dom_st_lawpol_l1 {
    gen T_`var' = `var'
}

gl cT T_log_gdp_per_cap_l1 T_log_gdp_per_cap_sq_l1 T_pop_mil_l1 T_recession_l1 T_dom_st_lawpol_l1

eststo clear 
* OLS
eststo ols2: reghdfe cotwo_total_per_gdp fin_dev1_l1 fin_str2_l1	$c, a(country year) vce(robust)

* First stages and R2
eststo fs1: xi: reg fin_dev1_l1 entrybarriers_l2 treated_stock_l2 cur100_l2 $cT i.country i.year 
eststo fs2: xi: reg fin_str2_l1 entrybarriers_l2 treated_stock_l2 cur100_l2 $cT i.country i.year 
	
* 2SLS
eststo sls2: xi: ivreg2 cotwo_total_per_gdp (fin_dev1_l1 fin_str2_l1=entrybarriers_l2 treated_stock_l2 cur100_l2) $c i.country i.year, robust

* GMM
xtset country_ year
eststo gmm2: xi: xtabond cotwo_total_per_gdp l(0/0).(fin_dev1_l1 fin_str2_l1 $c) i.year, lags(1) vce(gmm)


estadd local ctryFE "Yes":  ols2 fs1 fs2  sls2  gmm2 
estadd local yrFE "Yes":  ols2 fs1 fs2  sls2  gmm2 
noi esttab  ols2 fs1 fs2  sls2  gmm2   using "${tables}\\Table2-fin.tex", replace ///
	keep(fin_dev1_l1 fin_str2_l1 $c entrybarriers_l2 treated_stock_l2 cur100_l2) ///
	b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(ctryFE yrFE r2 N idstat idp cdf j jp, fmt(0 0 2 %15.0fc 3 3 3 3 3) /// 
	labels("\hline \addlinespace[1ex] Country FE" "Year FE" /// 
		   "\hline \addlinespace[1ex] R-squared" "No. Observations" /// 
		   "\hline \addlinespace[1ex] Kleibergen-Paap LM statistic" "\textit{p}-value" "F statistic" "Hansen J statistic" "\textit{p}-value")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)	

	
********************************************************************************	
di "FINANCE AND CARBON EMISSIONS (TABLE 3)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

lab var cotwo_fin_dev1_l1 "Financial development $\times$ CO$_{2} intensity"
lab var cotwo_fin_str2_l1 "Equity share $\times$ CO$_{2} intensity"

label var share_l1 "Sector share"

eststo clear


** Emissions per GDP: Credit markets and stock markets, country-industry, industry-year, and country-year FEs
** OLS
eststo ols_pergdp: reghdfe cotwo_per_gdp cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** 2SLS
eststo iv_pergdp: xi: ivreg2 cotwo_per_gdp (cotwo_fin_dev1_l1 cotwo_fin_str2_l1=cotwo_entry_l2 cotwo_treated_stock_l2 cotwo_cur100_l2) share_l1 i.ci i.it i.ct, cluster(ci)
** Arellano-Bond
eststo gmm_pergdp: xi: xtabond cotwo_per_gdp l(0/0).(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) i.ci i.it i.ct, lags(1) vce(gmm)

estadd local crtsecFE "Yes": ols_pergdp iv_pergdp gmm_pergdp
estadd local crtyrFE "Yes": ols_pergdp iv_pergdp gmm_pergdp
estadd local secyrFE "Yes": ols_pergdp iv_pergdp gmm_pergdp

noi esttab ols_pergdp iv_pergdp gmm_pergdp using "${tables}\\Table3.tex", replace ///
	keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(crtsecFE crtyrFE secyrFE r2 N cdf, fmt(0 0 0 2 %15.0fc 3) /// 
	labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" "\hline \addlinespace[1ex] R-squared" "No. Observations" "\hline \addlinespace[1ex] First-stage F statistic")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)	
		
filefilter "${tables}\\Table3.tex" "${tables}\\Table3-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table3.tex"		
		
		
		
********************************************************************************	
di "FINANCE AND CARBON EMISSIONS: CROSS-SECTOR RE-ALLOCATION (TABLE 4)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear
** Credit markets and stock markets, country-industry, industry-year, and country-year FEs, OLS
eststo growth_ols: reghdfe va_g cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** Credit markets and stock markets, country-industry, industry-year, and country-year FEs, 2SLS
eststo growth_iv: xi: ivreg2 va_g (cotwo_fin_dev1_l1 cotwo_fin_str2_l1=cotwo_entry_l2 cotwo_treated_stock_l2 cotwo_cur100_l2) share_l1 i.ci i.it i.ct, cluster(ci)
** Credit markets and stock markets, country-industry, industry-year, and country-year FEs, Arellano-Bond
xtset panel_var year
eststo growth_gmm: xi: xtabond va_g l(0/0).(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) i.ci i.it i.ct, lags(1) vce(gmm)

estadd local crtsecFE "Yes": growth_ols growth_iv growth_gmm
estadd local crtyrFE "Yes": growth_ols growth_iv growth_gmm
estadd local secyrFE "Yes": growth_ols growth_iv growth_gmm

noi esttab growth_ols growth_iv growth_gmm using "${tables}\\Table4.tex", replace ///
	keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(crtsecFE crtyrFE secyrFE r2 N, fmt(0 0 0 2 %15.0fc) /// 
	labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" /// 
		   "\hline \addlinespace[1ex] R-squared" "No. Observations" "\hline \addlinespace[1ex] First-stage F statistics")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)		
		
filefilter "${tables}\\Table4.tex" "${tables}\\Table4-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table4.tex"	


	
	
********************************************************************************	
di "FINANCE AND CARBON EMISSIONS: WITHIN-SECTOR EFFICIENCY (TABLE 5)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

xtset panel_var year

eststo clear
** Credit markets and stock markets, country-industry, industry-year, and country-year FEs 
** OLS
eststo eff_ols: reghdfe cotwo_per_va cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** 2SLS
eststo eff_iv: xi: ivreg2 cotwo_per_va (cotwo_fin_dev1_l1 cotwo_fin_str2_l1=cotwo_entry_l2 cotwo_treated_stock_l2 cotwo_cur100_l2) share_l1 i.ci i.it i.ct, cluster(ci)
**  Arellano-Bond
eststo eff_gmm: xi: xtabond cotwo_per_va l(0/0).(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) i.ci i.it i.ct, lags(1) vce(gmm)

estadd local crtsecFE "Yes": eff_ols eff_iv eff_gmm
estadd local crtyrFE "Yes": eff_ols eff_iv eff_gmm
estadd local secyrFE "Yes": eff_ols eff_iv eff_gmm

noi esttab eff_ols eff_iv eff_gmm using "${tables}\\Table5.tex", replace ///
	keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(crtsecFE crtyrFE secyrFE r2 N, fmt(0 0 0 2 %15.0fc) /// 
	labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" /// 
		   "\hline \addlinespace[1ex] R-squared" "No. Observations" "\hline \addlinespace[1ex] First-stage F statistics")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)		
		
filefilter "${tables}\\Table5.tex" "${tables}\\Table5-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table5.tex"


********************************************************************************	
di "FINANCE AND CARBON EMISSIONS: GREEN PATENTS (TABLE 6)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

xtset panel_var year

eststo clear
** Panel A OLS


** Per GDP: Green patents, Greener patents, Greenest patents: Credit markets and stock markets, country-industry, industry-year, and country-year FEs
eststo patent_pergdp_ols1: reghdfe green_patents_adjusted_per_gdp cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if green_patents_adjusted_per_gdp>0, absorb(ci it ct) cluster(ci)
eststo patent_pergdp_ols2: reghdfe green_patents_adjusted_a_per_gdp cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if green_patents_adjusted_a_per_gdp>0, absorb(ci it ct) cluster(ci)
eststo patent_pergdp_ols3: reghdfe green_patents_adjusted_b_per_gdp cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if green_patents_adjusted_b_per_gdp>0, absorb(ci it ct) cluster(ci)
eststo patent_pergdp_ols4: reghdfe green_patents_adjusted_b_per_gdp cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1 if oecd==1, absorb(ci it ct) cluster(ci)

** Panel B 2SLS

** Per GDP: Green patents, Greener patents, Greenest patents: Credit markets and stock markets, country-industry, industry-year, and country-year FEs
eststo patent_pergdp_iv1: xi: ivreg2 green_patents_adjusted_per_gdp (cotwo_fin_dev1_l1 cotwo_fin_str2_l1=cotwo_entry_l2 cotwo_treated_stock_l2 cotwo_cur100_l2) share_l1 i.ci i.it i.ct if green_patents_adjusted_per_gdp>0, cluster(ci)
eststo patent_pergdp_iv2: xi: ivreg2 green_patents_adjusted_a_per_gdp (cotwo_fin_dev1_l1 cotwo_fin_str2_l1=cotwo_entry_l2 cotwo_treated_stock_l2 cotwo_cur100_l2) share_l1 i.ci i.it i.ct if green_patents_adjusted_a_per_gdp>0, cluster(ci)
eststo patent_pergdp_iv3: xi: ivreg2 green_patents_adjusted_b_per_gdp (cotwo_fin_dev1_l1 cotwo_fin_str2_l1=cotwo_entry_l2 cotwo_treated_stock_l2 cotwo_cur100_l2) share_l1 i.ci i.it i.ct if green_patents_adjusted_b_per_gdp>0, cluster(ci)
eststo patent_pergdp_iv4: xi: ivreg2 green_patents_adjusted_b_per_gdp (cotwo_fin_dev1_l1 cotwo_fin_str2_l1=cotwo_entry_l2 cotwo_treated_stock_l2 cotwo_cur100_l2) share_l1 i.ci i.it i.ct if oecd==1, cluster(ci)

** Panel C GMM

** Per GDP: Green patents, Greener patents, Greenest patents: Credit markets and stock markets, country-industry, industry-year, and country-year FEs
eststo patent_pergdp_gmm1: xi: xtabond green_patents_adjusted_per_gdp l(0/0).(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) i.ci i.it i.ct if green_patents_adjusted_per_gdp>0, lags(1) vce(gmm)
eststo patent_pergdp_gmm2: xi: xtabond green_patents_adjusted_a_per_gdp l(0/0).(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) i.ci i.it i.ct if green_patents_adjusted_a_per_gdp>0, lags(1) vce(gmm)
eststo patent_pergdp_gmm3: xi: xtabond green_patents_adjusted_b_per_gdp l(0/0).(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) i.ci i.it i.ct if green_patents_adjusted_b_per_gdp>0, lags(1) vce(gmm)
eststo patent_pergdp_gmm4: xi: xtabond green_patents_adjusted_b_per_gdp l(0/0).(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1) i.ci i.it i.ct if oecd==1, lags(1) vce(gmm)

estadd local crtsecFE "Yes": patent_pergdp_gmm1 patent_pergdp_gmm2 patent_pergdp_gmm3 patent_pergdp_gmm4
estadd local crtyrFE "Yes":  patent_pergdp_gmm1 patent_pergdp_gmm2 patent_pergdp_gmm3 patent_pergdp_gmm4
estadd local secyrFE "Yes":  patent_pergdp_gmm1 patent_pergdp_gmm2 patent_pergdp_gmm3 patent_pergdp_gmm4

noi esttab *ols* using "${tables}\\Table6.tex", replace ///
	keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(r2 N, fmt(2 %15.0fc) /// 
	labels("\hline \addlinespace[1ex] R-squared" "No. Observations")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)		 
filefilter "${tables}\\Table6.tex" "${tables}\\Table6a-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table6.tex"	

noi esttab *iv* using "${tables}\\Table6.tex", replace ///
	keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(r2 N, fmt(2 %15.0fc) /// 
	labels("\hline \addlinespace[1ex] R-squared" "No. Observations")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)		
filefilter "${tables}\\Table6.tex" "${tables}\\Table6b-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table6.tex"	

noi esttab *gmm* using "${tables}\\Table6.tex", replace ///
	keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  b(%9.4f) se(%9.4f) f nonum nolines ///
	stats(N crtsecFE crtyrFE secyrFE, fmt(%15.0fc 0 0 0) /// 
	labels("\hline \addlinespace[1ex] No. Observations" /// 
		   "\hline \\ \hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE")) ///
	label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)			
filefilter "${tables}\\Table6.tex" "${tables}\\Table6c-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table6.tex"	


********************************************************************************	
di "FINANCE AND CARBON EMISSIONS: FIRM-LEVEL EVIDENCE (TABLE 7)"
********************************************************************************

use "$data\2_Interim files\orbis_cleaned.dta", clear

lab var post_2006 		"Post 2006"
lab var post_2006_be 	"Post 2006 $\times$ Belgium"

lab var post_2006_cotwo_sal 	"Post 2006 $\times$ CO$_{2} intensity"
lab var post_2006_cotwo_sal_be 	"Post 2006 $\times$ CO$_{2} intensity $\times$ Belgium"

** Panel A. Change in equity funding
eststo clear
* Column 1. Belgium
eststo table7a_col1: reghdfe equity_share post_2006 	///
								if country=="BE" & year>=2001 & year<=2010, absorb(firmid)
* Column 2. Belgium versus neighbors (non-matched)
eststo table7a_col2: reghdfe equity_share post_2006 post_2006_be ///
								if year>=2001 & year<=2010 & (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & year<=2010, absorb(firmid)
* Column 3. Belgium versus neighbors (non-matched)
eststo table7a_col3: reghdfe equity_share post_2006 post_2006_be [pw = psmw] /// 
								if year>=2001 & year<=2010 & (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & year<=2010, absorb(firmid)

estadd local firmFE "Yes": table7a_col1 table7a_col2 table7a_col3

noi esttab 	table7a* using "${tables}\\Table7a.tex", replace ///
			b(%9.4f) se(%9.4f) f nonum nolines ///
			stats(firmFE r2 N df_a, fmt(0 2 %15.0fc) /// 
			labels("\cmidrule(l{.75em}){1-4}  \addlinespace[1ex] Firm FE" "\cmidrule(l{.75em}){1-4}\addlinespace[1ex] R-squared" "No. Observations" "No. Firms")) ///
			label nomtitles style(tex) nogaps nonotes noconstant star(* .1 ** .05 *** .01)		
filefilter "${tables}\\Table7a.tex" "${tables}\\Table7a-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table7a.tex"
	
** Panel B. Change in emissions
eststo clear
* Column 1. Change in emissions per sales, Belgium
eststo table7b_col1: reghdfe log_emissions_per_sales post_2006_cotwo_sal /// 
												if country=="BE" & year<=2010, absorb(firmid year)
					 distinct firmid if e(sample)
					 eststo table7b_col1, addscalars(firmN `r(ndistinct)')						 
* Column 2. Change in emissions per sales, Belgium versus neighbors (non-matched)
eststo table7b_col2: reghdfe log_emissions_per_sales post_2006_cotwo_sal post_2006_cotwo_sal_be /// 
												if (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & year<=2010, absorb(firmid country_year)
					 distinct firmid if e(sample)
					 eststo table7b_col2, addscalars(firmN `r(ndistinct)')						 
* Column 3. Change in emissions per sales, Belgium versus neighbors (matched)
eststo table7b_col3: reghdfe log_emissions_per_sales post_2006_cotwo_sal post_2006_cotwo_sal_be [pw = psmw] /// 
												if (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & year<=2010, absorb(firmid)
					 distinct firmid if e(sample)
					 eststo table7b_col3, addscalars(firmN `r(ndistinct)')						 
* Column 4. Change in emissions per assets, Belgium
eststo table7b_col4: reghdfe log_emissions_per_assets post_2006_cotwo_sal /// 
												if country=="BE" & year<=2010, absorb(firmid year)
					 distinct firmid if e(sample)
					 eststo table7b_col4, addscalars(firmN `r(ndistinct)')						 
* Column 5. Change in emissions per assets, Belgium versus neighbors (non-matched)
eststo table7b_col5: reghdfe log_emissions_per_assets post_2006_cotwo_sal post_2006_cotwo_sal_be /// 
												if (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & year<=2010, absorb(firmid country_year)
					 distinct firmid if e(sample)
					 eststo table7b_col5, addscalars(firmN `r(ndistinct)')						 
* Column 6. Change in emissions per assets, Belgium versus neighbors (matched)
eststo table7b_col6: reghdfe log_emissions_per_assets post_2006_cotwo_sal post_2006_cotwo_sal_be [pw = psmw] /// 
												if (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & year<=2010, absorb(firmid)
					 distinct firmid if e(sample)
					 eststo table7b_col6, addscalars(firmN `r(ndistinct)')	
					 
estadd local firmFE "Yes": 		table7b_col1 table7b_col2 table7b_col3 table7b_col4 table7b_col5 table7b_col6
estadd local yrFE "Yes": 		table7b_col1 table7b_col4
estadd local yrFE "No": 		table7b_col2 table7b_col3 table7b_col5 table7b_col6
estadd local ctryyrFE "Yes": 	table7b_col2 table7b_col5 
estadd local ctryyrFE "No": 	table7b_col1 table7b_col3 table7b_col4 table7b_col6

noi esttab 	table7b* using "${tables}\\Table7b.tex", replace ///
			b(%9.4f) se(%9.4f) f nonum nolines noconstant ///
			stats(firmFE yrFE ctryyrFE r2 N firmN, fmt(0 0 0 2 %15.0fc 0) /// 
			labels("\hline \addlinespace[1ex] Firm FE" "Year FE" "Country $\times$ Year FE" "\hline \addlinespace[1ex] R-squared" "No. Observations" "No. Firms")) ///
			label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)			
filefilter "${tables}\\Table7b.tex" "${tables}\\Table7b-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table7b.tex"
	

********************************************************************************	
di "FINANCE AND CARBON EMISSIONS: CARBON LEAKAGE (TABLE 8)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

label var share_l1 "Sector share"
label var share_l1 "Sector share"
foreach i of varlist _all {
	local a : variable label `i'
	local a: subinstr local a " cross " " $\times$ "
	label var `i' "`a'"
}

eststo clear
** Imported CO2, total
eststo leak1: reghdfe import_co2_total_ag_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** Imported CO2, households
eststo leak2: reghdfe import_co2_hh_ag_per_gdp 			cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** Imported CO2, same sector
eststo leak3: reghdfe import_co2_ind_same_ag_per_gdp 	cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** Imported CO2, other sectors
eststo leak4: reghdfe import_co2_ind_other_ag_per_gdp 	cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** Imported CO2, GFCF
eststo leak5: reghdfe import_co2_gfcf_ag_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)
** Imported CO2, government
eststo leak6: reghdfe import_co2_gov_ag_per_gdp 		cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1, absorb(ci it ct) cluster(ci)


estadd local crtsecFE "Yes": leak1 leak2 leak3 leak4 leak5 leak6
estadd local crtyrFE "Yes": leak1 leak2 leak3 leak4 leak5 leak6
estadd local secyrFE "Yes": leak1 leak2 leak3 leak4 leak5 leak6


noi esttab  leak* using "${tables}\\Table8.tex", replace ///
			keep(cotwo_fin_dev1_l1 cotwo_fin_str2_l1 share_l1)  ///
			b(%9.4f) se(%9.4f) f nonum nolines ///
			order(cotwo_per_va cotwo_fin_dev1_l1 cotwo_fin_str2_l1 rd_fin_dev1_l1 rd_fin_str2_l1 tang_fin_dev1_l1 tang_fin_str2_l1 litig_fin_dev1_l1 litig_fin_str2_l1 share_l1) ///
			stats(crtsecFE crtyrFE secyrFE r2 N , fmt(0 0 0 2 %15.0fc) /// 
			labels("\hline \addlinespace[1ex] Country $\times$ Sector FE" "Country $\times$ Year FE" "Sector $\times$ Year FE" /// 
				   "\hline \addlinespace[1ex] R-squared" "No. Observations" )) ///
			label nomtitles style(tex) nogaps nonotes star(* .1 ** .05 *** .01)	
filefilter "${tables}\\Table8.tex" "${tables}\\Table8-fin.tex", from("CO{2}") to("CO\$_{2}\$") replace	
cap erase "${tables}\\Table8.tex"


capture log close