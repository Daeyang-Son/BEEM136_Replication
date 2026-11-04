 log using "${logs}\6 Charts Online Appendix.txt", replace 

********************************************************************************	
di "SUMMARY STATISTICS (OA CHART 1)"
********************************************************************************

use "$data\2_Interim files\orbis_cleaned.dta", clear

forval x=1995(1)2018 {
gen dummy_`x'=0
replace dummy_`x'=1 if year==`x'
gen dummy_`x'_cotwo_ass=dummy_`x'*cotwo_ass
gen dummy_`x'_cotwo_sal=dummy_`x'*cotwo_sal
}

* emissions

reghdfe log_emissions_per_assets dummy_2006_cotwo_sal dummy_2007_cotwo_sal dummy_2008_cotwo_sal dummy_2009_cotwo_sal dummy_2010_cotwo_sal if country=="BE" & year>=2005 & year<=2010, a(firmid year)

regsave dummy_2006_cotwo_sal dummy_2007_cotwo_sal dummy_2008_cotwo_sal dummy_2009_cotwo_sal dummy_2010_cotwo_sal using "$tables/OA_Chart1", replace

use "$tables/OA_Chart1", clear
keep var coef stderr
gen year=.

foreach i of num 2006/2010 {
    replace year=`i' if strpos(var, "`i'")
}

drop var
gen ci90=1.66*stderr

label var coef "Point estimate"

* domestic loans

serrbar coef ci90 year, xlabel(2005 "-1" 2006 "0" 2007 "1" 2008 "2" 2009 "3" 2010 "4") title ("Notional interest deduction and log emissions")

graph export "${figures}/ChartOA1.png", replace height(1600)

log close