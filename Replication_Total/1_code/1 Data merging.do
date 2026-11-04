 log using "${logs}\1 Data merging.txt", replace 
	
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
* COUNTRY*SECTOR DATA CLEANING: Merge datasets
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


*1:1 matching based on country*year*industry identifier

use "$data\1_Raw files\iea.dta", clear

local dataset_list1 `" "exio.dta" "' 

foreach  filename of local dataset_list1 {
local temp_path1 = "$data\1_Raw files" + "\" + "`filename'" 
	merge 1:1 iso2 industry year using "`temp_path1'"
	drop _merge
}

local dataset_list2 `" "wiod.dta" "unido.dta" "stan.dta" "'

foreach filename of local dataset_list2 {
local temp_path2 = "$data\1_Raw files" + "\" + "`filename'" 
	merge 1:1 code industry year using "`temp_path2'"
	drop _merge
}

local dataset_list3 `"  "patstat.dta" "'

foreach filename of local dataset_list3 {
local temp_path3 = "$data\1_Raw files\" + "\" + "`filename'" 
	merge 1:1 code industry year using "`temp_path3'"
	drop _merge
}


*m:1 matching based on country*year identifier

local dataset_list4 `" "wdi.dta" "financial structure.dta" "business credit.dta" "ets.dta" "quinn.dta" "bekaert.dta" "iea policies.dta"   "'

foreach filename of local dataset_list4 {
local temp_path4 = "$data\1_Raw files" + "\" + "`filename'" 
	merge m:1 code year using "`temp_path4'"
	drop _merge
}

local dataset_list5 `" "evca.dta" "abiad.dta" "'

foreach filename of local dataset_list5 {
local temp_path5 = "$data\1_Raw files" + "\" + "`filename'" 
	merge m:1 country year using "`temp_path5'"
	drop _merge
}

*m:1 matching based on country*industry identifier

local dataset_list6 `" "fuel subsidies.dta" "'

foreach filename of local dataset_list6 {
local temp_path6 = "$data\1_Raw files" + "\" + "`filename'" 
	merge m:1 code industry using "`temp_path6'"
	drop _merge
}

*m:1 matching based on industry identifier

local dataset_list7 `" "levinson.dta" "epa.dta" "compustat.dta" "laeven.dta" "braun.dta" "'

foreach filename of local dataset_list7 {
local temp_path7 = "$data\1_Raw files" + "\" + "`filename'" 
	merge m:1 industry using "`temp_path7'"
	drop _merge
}

drop if industry==.
drop if country=="Russian Federation"

save "$data\2_Interim files\country_sector_cleaned.dta", replace


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
* COUNTRY DATA CLEANING: Merge datasets
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


use "$data\1_Raw files\iea country.dta", clear

*1:1 matching based on country*year identifier

local dataset_list3 `" "wdi.dta" "financial structure.dta" "business credit.dta" "ets.dta" "quinn.dta" "bekaert.dta" "iea policies.dta" "'

foreach filename of local dataset_list3 {
local temp_path3 = "$data\1_Raw files" + "\" + "`filename'" 
	merge m:1 code year using "`temp_path3'"
	drop _merge
}

local dataset_list4 `" "evca.dta" "abiad.dta" "'

foreach filename of local dataset_list4 {
local temp_path4 = "$data\1_Raw files" + "\" + "`filename'" 
	merge m:1 country year using "`temp_path4'"
	drop _merge
}

replace country="Macedonia, FYR" if country=="North Macedonia"
drop if country=="Russian Federation"

replace country = "China" if country=="China (People's Republic of)"

save "$data\2_Interim files\country_cleaned.dta", replace


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
* COUNTRY*SECTOR DATA CLEANING: Create variables, re-label
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

use "$data\2_Interim files\country_sector_cleaned.dta", clear

*main financial variables

*producing compound variables

gen fin_dev1=credit+stock
gen fin_str2=stock/fin_dev1
gen fin_dev1_b=credit+stock+prbond
gen fin_str2_c=stock/(credit+stock+prbond)

*producing lags of variables

egen panel_var = group(country industry)
sort code year industry
xtset panel_var year

gen credit_l1=L1.credit
gen stock_l1=L1.stock
gen bonds_l1=L1.prbond
gen fin_dev1_l1=L1.fin_dev1
gen fin_str2_l1=L1.fin_str2
gen fin_dev1_b_l1=L1.fin_dev1_b
gen fin_str2_c_l1=L1.fin_str2_c
gen dom_st_lawpol_l1=L1.dom_st_lawpol
	 
*produce labels
label var credit "Credit to the private sector/GDP"
label var stock "Stock market capitalization/GDP"
label var prbond "Value of private bonds/GDP"
label var fin_dev1 "(Credit to the private + stock market capitalization)/GDP"
label var fin_str2 "Stock market capit./(credit to the private sector+stock market capit.)"
label var fin_dev1_b "(Credit to the private sector+stock market capit.+value of private bonds)/GDP"
label var fin_str2_c "Stock market capit./(credit to the private+stock market capit.+private bonds)"

label var credit_l1 "Credit to the private sector/GDP, 1 lag"
label var stock_l1 "Stock market capitalization/GDP, 1 lag"
label var bonds_l1 "Value of private bonds/GDP, 1 lag"
label var fin_dev1_l1 "(Credit to the private + stock market capitalization)/GDP, 1 lag"
label var fin_str2_l1 "Stock market capit./(credit to the private sector+stock market capit.), 1 lag"
label var fin_dev1_b_l1 "(Credit to the private sector+stock market capit.+private bonds)/GDP, 1 lag"
label var fin_str2_c_l1 "Stock market capit./(private credit+stock market capit.+private bonds), 1 lag"

label var dom_st_lawpol_l1 "Total number of laws & policies passed in a country until time t-1, 1 lag"

** for Table OA9

gen fin_dev1_e_l1 = credit_l1+stock_l1+priveq_l1
gen fin_str2_e_l1 = (stock_l1+priveq_l1)/(credit_l1+stock_l1+priveq_l1)


** for Table OA12

gen fin_dev1_a = credit_bus+stock
gen fin_str2_a = (stock)/(stock+credit_bus)
sort country industry year
gen fin_dev1_a_l1=fin_dev1_a[_n-1] if industry[_n]==industry[_n-1]
gen fin_str2_a_l1=fin_str2_a[_n-1] if industry[_n]==industry[_n-1]

forval x=1990(1)2015 {
gen year_`x'=0
replace year_`x'=1 if `x'==year
}

egen ci = group (country industry)
egen ct = group (country year)
egen it = group (industry year)


**Need to create interaction variables by hand as xtabond function in Stata doesn't work with x1#x2 syntax for interactions.
** for all analysis

*identifying industry C02 benchmarks

tostring industry, gen(industry_cat)
encode industry_cat, gen(industry_cat2)

drop cotwo_intensity_wd

bysort industry : egen cotwo_intensity_wd = mean(cotwo_per_va)
bysort industry : egen cotwo_intensity_wd_oecd = mean(cotwo_per_va_oecd)
gen cotwo_intensity_wd_all=cotwo_intensity_wd 
replace cotwo_intensity_wd_all=cotwo_intensity_wd_oecd if missing(cotwo_intensity_wd_all)

gen cotwo_fin_dev1_l1 = cotwo_intensity_wd * fin_dev1_l1
gen cotwo_fin_str2_l1 = cotwo_intensity_wd * fin_str2_l1


label var cotwo_fin_dev1_l1 "Financial development cross CO$_{2} intensity"
label var cotwo_fin_str2_l1 "Equity share cross CO$_{2} intensity"

** for Table 4

gen cotwo_entry_l2 = cotwo_intensity_wd * entrybarriers_l2 
gen cotwo_treated_stock_l2 = cotwo_intensity_wd * treated_stock_l2
gen cotwo_cur100_l2 = cotwo_intensity_wd * cur100_l2


** for Table 7

gen rd_fin_dev1_l1 = rd * fin_dev1_l1
gen rd_fin_str2_l1 = rd * fin_str2_l1
gen tang_fin_dev1_l1 = tang_2 * fin_dev1_l1
gen tang_fin_str2_l1 = tang_2 * fin_str2_l1
gen litig_fin_dev1_l1 = sued_share * fin_dev1_l1
gen litig_fin_str2_l1 = sued_share * fin_str2_l1

label var rd_fin_dev1_l1 "Financial development cross R&D intensity"
label var rd_fin_str2_l1 "Equity share cross R&D intensity"
label var tang_fin_dev1_l1 "Financial development cross Asset tangibility"
label var tang_fin_str2_l1 "Equity share cross Asset tangibility"
label var litig_fin_dev1_l1 "Financial development cross Litigation risk"
label var litig_fin_str2_l1 "Equity share cross Litigation risk"

** for Table OA3

gen cotwo_high_fin_dev1_l1=cotwo_intensity_high*fin_dev1_l1
gen cotwo_high_fin_str2_l1=cotwo_intensity_high*fin_str2_l1

label var cotwo_high_fin_dev1_l1 "Financial development cross CO$_{2} intensity"
label var cotwo_high_fin_str2_l1 "Equity share cross CO$_{2} intensity"

** for Table OA5

gen cotwo_credit_l1 = cotwo_intensity_wd * credit_l1
gen cotwo_stock_l1 = cotwo_intensity_wd * stock_l1

label var cotwo_credit_l1 "Credit/GDP cross CO$_{2} intensity"
label var cotwo_stock_l1 "Stocks/GDP cross CO$_{2} intensity"

** for Table OA6

gen ext_dep_fin_dev1_l1 = ext_dep * fin_dev1_l1
gen ext_dep_fin_str2_l1 = ext_dep * fin_str2_l1

label var ext_dep_fin_dev1_l1 "Financial development cross External dependence"
label var ext_dep_fin_str2_l1 "Equity share cross External dependence"

** for Table OA7

local industry_cat_levels = r(levels)
drop cotwo_intensity_wd_c

bysort industry year: egen cotwo_intensity_wd_c = mean(cotwo_per_va)

gen cotwo_c_fin_dev1_l1 = cotwo_intensity_wd_c * fin_dev1_l1
gen cotwo_c_fin_str2_l1 = cotwo_intensity_wd_c * fin_str2_l1

drop cotwo_intensity_alt
bysort industry year: egen x = mean(cotwo_per_va) if country!="United States"
bysort industry: egen cotwo_intensity_alt=mean(x)
drop x 


gen cotwo_alt_fin_dev1_l1 = cotwo_intensity_alt * fin_dev1_l1
gen cotwo_alt_fin_str2_l1 = cotwo_intensity_alt * fin_str2_l1

label var cotwo_c_fin_dev1_l1 "Financial development cross CO$_{2} intensity (Contemporaneous)"
label var cotwo_c_fin_str2_l1 "Equity share cross CO$_{2} intensity (Contemporaneous)"

label var cotwo_alt_fin_str2_l1 "Financial development cross CO$_{2} intensity (US)"
label var cotwo_c_fin_str2_l1 "Equity share cross CO$_{2} intensity (US)"

** for Table OA8

gen cotwo_fin_dev1_b_l1 = cotwo_intensity_wd * fin_dev1_b_l1
gen cotwo_fin_str2_c_l1 = cotwo_intensity_wd * fin_str2_c_l1

label var cotwo_fin_dev1_b_l1 "Financial development with bonds cross CO$_{2} intensity"
label var cotwo_fin_str2_c_l1 "Equity share with bonds cross CO$_{2} intensity"

** for Table OA9

*gen fin_dev1_e_l1 = credit_l1+stock_l1+priveq_l1
*gen fin_str2_e_l1 = (stock_l1+priveq_l1)/(credit_l1+stock_l1+priveq_l1)

gen cotwo_fin_dev1_e_l1 = cotwo_intensity_wd * fin_dev1_e_l1
gen cotwo_fin_str2_e_l1 = cotwo_intensity_wd * fin_str2_e_l1

label var cotwo_fin_dev1_e_l1 "Financial development cross CO$_{2} intensity"
label var cotwo_fin_str2_e_l1 "Equity share cross CO$_{2} intensity"

** for Table OA10

gen fin_dev1_subsidy_l1 = subsidy_fuel_post * fin_dev1_l1
gen fin_str2_subsidy_l1 = subsidy_fuel_post * fin_str2_l1

label var fin_dev1_subsidy_l1 "Financial development cross Fuel subsidies"
label var fin_str2_subsidy_l1 "Equity share cross Fuel subsidies"

** for Table OA11

gen cotwo_environmental_laws_l1 = cotwo_intensity_wd * dom_st_lawpol_l1
gen cotwo_carbon_tax_ets_l1 = cotwo_intensity_wd * carbon_tax_ets_l1

label var cotwo_environmental_laws_l1 "# environmental laws and policies cross CO$_{2} intensity"
label var cotwo_carbon_tax_ets_l1 "Carbon tax or ETS cross CO$_{2} intensity"

** for Table OA12

gen cotwo_fin_dev1a_l1 = cotwo_intensity_wd * fin_dev1_a_l1
gen cotwo_fin_str2a_l1 = cotwo_intensity_wd * fin_str2_a_l1

label var cotwo_fin_dev1a_l1 "Financial development cross CO$_{2} intensity"
label var cotwo_fin_str2a_l1 "Equity share cross CO$_{2} intensity"

save "$data\2_Interim files\country_sector_cleaned.dta", replace



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
* COUNTRY DATA CLEANING: Create variables, re-label
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

use "$data\2_Interim files\country_cleaned.dta", clear

forval x=1990(1)2015 {
gen year_`x'=0
replace year_`x'=1 if `x'==year
}

drop if missing(country) & code=="EST"


*main financial variables

*producing compound variables

gen fin_dev1=credit+stock
gen fin_str2=stock/fin_dev1
gen fin_dev1_b=credit+stock+prbond
gen fin_str2_c=stock/(credit+stock+prbond)

*producing lags of variables

encode country,gen(country1)
sort code year
xtset country1 year

gen credit_l1=L1.credit
gen stock_l1=L1.stock
gen bonds_l1=L1.prbond
gen fin_dev1_l1=L1.fin_dev1
gen fin_str2_l1=L1.fin_str2
gen fin_dev1_b_l1=L1.fin_dev1_b
gen fin_str2_c_l1=L1.fin_str2_c
gen dom_st_lawpol_l1=L1.dom_st_lawpol
	 
*produce labels
label var credit "Credit to the private sector/GDP"
label var stock "Stock market capitalization/GDP, 1 lag"
label var prbond "Value of private bonds/GDP"
label var fin_dev1 "(Credit to the private + stock market capitalization)/GDP"
label var fin_str2 "Stock market capit./(credit to the private sector+stock market capit.)"
label var fin_dev1_b "(Credit to the private sector+stock market capit.+value of private bonds)/GDP"
label var fin_str2_c "Stock market capit./(credit to the private+stock market capit.+private bonds)"

label var credit_l1 "Credit to the private sector/GDP, 1 lag"
label var stock_l1 "Stock market capitalization/GDP, 1 lag"
label var bonds_l1 "Value of private bonds/GDP, 1 lag"
label var fin_dev1_l1 "(Credit to the private + stock market capitalization)/GDP, 1 lag"
label var fin_str2_l1 "Stock market capit./(credit to the private sector+stock market capit.), 1 lag"
label var fin_dev1_b_l1 "(Credit to the private sector+stock market capit.+private bonds)/GDP, 1 lag"
label var fin_str2_c_l1 "Stock market capit./(private credit+stock market capit.+private bonds), 1 lag"
label var dom_st_lawpol_l1 "Total number of laws & policies passed in a country until time t-1, 1 lag"


save "$data\2_Interim files\country_cleaned.dta", replace



*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
* ORBIS FIRM-LEVEL DATA CLEANING: Merge datasets
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


use "$data\1_Raw files\orbis_anon.dta", clear

gen x=nace/100
gen temp=floor(x)

bysort firmid: egen industry=mean(temp)

rename VERIFIED_EMISSIONS_ emissions

gen emissions_per_assets=emissions/toas
gen emissions_per_sales=emissions/turn

bysort industry: egen cotwo_ass=mean(emissions_per_assets)
bysort industry: egen cotwo_sal=mean(emissions_per_sales)

gen post_2006=0
replace post_2006=1 if year>2006

gen post_2009=0
replace post_2009=1 if year>2009

gen post_2010=0
replace post_2010=1 if year>2010

gen post_2011=0
replace post_2011=1 if year>2011

gen post_2006_cotwo_ass=post_2006*cotwo_ass
gen post_2006_cotwo_sal=post_2006*cotwo_sal

gen post_2009_cotwo_ass=post_2009*cotwo_ass
gen post_2009_cotwo_sal=post_2009*cotwo_sal

gen post_2010_cotwo_ass=post_2010*cotwo_ass
gen post_2010_cotwo_sal=post_2010*cotwo_sal

gen post_2011_cotwo_ass=post_2011*cotwo_ass
gen post_2011_cotwo_sal=post_2011*cotwo_sal

gen log_equity=log(tshf)

replace solr=. if solr<0
gen equity_share=solr/100

replace emissions_per_assets=emissions_per_assets
replace emissions_per_sales=emissions_per_sales

gen log_emissions_per_assets=log(emissions_per_assets)
gen log_emissions_per_sales=log(emissions_per_sales)

gen be=0 if country=="NL" | country=="DE" | country=="LU" | country=="FR"
replace be=1 if country=="BE"

gen post_2006_be=post_2006*be
gen post_2006_cotwo_ass_be=post_2006_cotwo_ass*be
gen post_2006_cotwo_sal_be=post_2006_cotwo_sal*be

egen country_year=group(country year)

** Summary
codebook equity_share emissions_per_sales emissions_per_assets if (country=="BE" | country=="NL" | country=="DE" | country=="LU" | country=="FR") & emissions_per_sales>=0 & emissions_per_assets>=0

*** matched sample, construction

*encode bvdid, gen(firmid)
gen belgium = country == "BE"
bys firmid: egen sector = mean(floor(nace / 100)) 

* winsor2 shfd tshf ncli culi turn toas tfas oppl, replace by(sector year) cuts(1 99)

gen leverage = (ncli + culi) / toas
replace leverage = . if !inrange(leverage, 0, 2)

gen tang = tfas / toas	
gen prof = oppl / toas	
gen nopl = oppl < 0 if !missing(oppl)	
gen size = log(toas)

xtset firmid year
probit belgium tang prof size nopl c.size#c.tang c.size#c.prof i.sector if year == 2004
predict pscore if e(sample)

// adjust score to the groups of countries, sectors and years
egen cell = group(sector)
replace pscore = cell*2 + pscore

// use psmatch only to get matching
gen randomorder = runiform()
sort randomorder
psmatch2 belgium, caliper(0.1) neighbor(1) out(year) pscore(pscore) ties //noreplacement

// test PS matching results
ttest tang if year == 2004, by(belgium)	// before matching
ttest tang if year == 2004 & !missing(_weight), by(belgium) // after matching

ttest prof if year == 2004, by(belgium)	// before matching
ttest prof if year == 2004 & !missing(_weight), by(belgium) // after matching

ttest size if year == 2004, by(belgium)	// before matching
ttest size if year == 2004 & !missing(_weight), by(belgium) // after matching

ttest nopl if year == 2004, by(belgium)	// before matching
ttest nopl if year == 2004 & !missing(_weight), by(belgium) // after matching

//gen psmw = _weight
bys firmid: egen psmw = total(_weight), missing 

*** end of matched sample, construction

save "$data\2_Interim files\orbis_cleaned.dta", replace


log close