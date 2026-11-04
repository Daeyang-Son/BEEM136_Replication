 log using "${logs}\3 Charts.txt", replace 
 
 * This do file produces Charts 1 and 2.

********************************************************************************	
di "GLOBAL FINANCIAL DEVELOPMENT OVER TIME (CHART 1)"
********************************************************************************

use "$data\2_Interim files\country_cleaned.dta", clear


keep if year<=2015

bysort code: egen fd_av=mean(fin_dev1)
bysort code: egen fs_av=mean(fin_str2)

drop if fd_av==. | fs_av==.

bysort year: egen pop_mil_tot=sum(pop_mil)
gen pop_ratio= pop_mil/ pop_mil_tot

gen fd_pw= fin_dev1* pop_ratio
gen fs_pw= fin_str2* pop_ratio

bysort year: egen fd_world=sum( fd_pw)
bysort year: egen fs_world=sum( fs_pw)

label var fd_world "Financial Development"
label var fs_world "Equity Share"

label var year "   "



qui twoway (line fd_world year if year>=1990 & code=="USA", lcolor(gs0) lwidth(medthick) title("Financial Development and Equity Share") subtitle("World, 1990-2015")) (line fs_world year if year>=1990 & code=="USA", lcolor(gs0) lwidth(medthick) lpattern(dash))

graph export "${figures}/Chart1.png", replace height(1600)

********************************************************************************	
di "CARBON EMISSIONS PER CAPITA OVER TIME (CHART 2)"
********************************************************************************

use "$data\2_Interim files\country_sector_cleaned.dta", clear

tabstat cotwo_intensity_wd fin_str2, stat(n mean med) col(stat)

* low carbon intensity, low equity share
reghdfe cotwo_per_gdp year_1991-year_2015 if cotwo_intensity_wd<.49 & fin_str2<.39 & cotwo_intensity_wd!=. & fin_str2!=. & share_l1!=., a(ci)

regsave year_1991-year_2015 using "$tables/Chart2_1", replace


use "$tables/Chart2_1", clear

keep var coef stderr
gen year=.
foreach i of num 1991/2015 {
    replace year=`i' if strpos(var, "`i'")
}
drop var

gen ci95=1.96*stderr
label var coef "Point estimate"
label var year "Year"

serrbar coef ci95 year, xlabel(1991 "91" 1992 "92" 1993 "93" 1994 "94" 1995 "95" 1996 "96" 1997 "97" 1998 "98" 1999 "99" 2000 "00" 2001 "01" 2002 "02" 2003 "03" 2004 "04" 2005 "05" 2006 "06" 2007 "07" 2008 "08" 2009 "09" 2010 "10" 2011 "11" 2012 "12" 2013 "13" 2014 "14" 2015 "15", alternate) title ("Low carbon intensity, low equity share") yscale (range(-0.005 0.005)) ylabel(#7)

graph export "${figures}/Chart2_1.png", replace height(1600)
cap erase "$tables/Chart2_1.dta"


* low carbon intensity, high equity share
use "$data\2_Interim files\country_sector_cleaned.dta", clear

reghdfe cotwo_per_gdp year_1991-year_2015 if cotwo_intensity_wd<.49 & fin_str2>.39 & cotwo_intensity_wd!=. & fin_str2!=. & share_l1!=., a(ci)

regsave year_1991-year_2015 using "$tables/Chart2_2", replace

use "$tables/Chart2_2", clear

keep var coef stderr
gen year=.
foreach i of num 1991/2015 {
    replace year=`i' if strpos(var, "`i'")
}
drop var

gen ci95=1.96*stderr
label var coef "Point estimate"
label var year "Year"

serrbar coef ci95 year, xlabel(1991 "91" 1992 "92" 1993 "93" 1994 "94" 1995 "95" 1996 "96" 1997 "97" 1998 "98" 1999 "99" 2000 "00" 2001 "01" 2002 "02" 2003 "03" 2004 "04" 2005 "05" 2006 "06" 2007 "07" 2008 "08" 2009 "09" 2010 "10" 2011 "11" 2012 "12" 2013 "13" 2014 "14" 2015 "15", alternate) title ("Low carbon intensity, high equity share") yscale (range(-0.005 0.005)) ylabel(#7)

graph export "${figures}/Chart2_2.png", replace height(1600)
cap erase "$tables/Chart2_2.dta"


* high carbon intensity, low equity share
use "$data\2_Interim files\country_sector_cleaned.dta", clear

reghdfe cotwo_per_gdp year_1991-year_2015 if cotwo_intensity_wd>.49 & fin_str2<.39 & cotwo_intensity_wd!=. & fin_str2!=. & share_l1!=., a(ci)

regsave year_1991-year_2015 using "$tables/Chart2_3", replace

use "$tables/Chart2_3", clear

keep var coef stderr
gen year=.
foreach i of num 1991/2015 {
    replace year=`i' if strpos(var, "`i'")
}
drop var

gen ci95=1.96*stderr
label var coef "Point estimate"
label var year "Year"

serrbar coef ci95 year, xlabel(1991 "91" 1992 "92" 1993 "93" 1994 "94" 1995 "95" 1996 "96" 1997 "97" 1998 "98" 1999 "99" 2000 "00" 2001 "01" 2002 "02" 2003 "03" 2004 "04" 2005 "05" 2006 "06" 2007 "07" 2008 "08" 2009 "09" 2010 "10" 2011 "11" 2012 "12" 2013 "13" 2014 "14" 2015 "15", alternate) title ("High carbon intensity, low equity share") yscale (range(-0.02 0.01)) ylabel(#7)

graph export "${figures}/Chart2_3.png", replace height(1600)
cap erase "$tables/Chart2_3.dta"


* high carbon intensity, high equity share
use "$data\2_Interim files\country_sector_cleaned.dta", clear

reghdfe cotwo_per_gdp year_1991-year_2015 if cotwo_intensity_wd>.49 & fin_str2>.39 & cotwo_intensity_wd!=. & fin_str2!=. & share_l1!=., a(ci)

regsave year_1991-year_2015 using "$tables/Chart2_4", replace

use "$tables/Chart2_4", clear

keep var coef stderr
gen year=.
foreach i of num 1991/2015 {
    replace year=`i' if strpos(var, "`i'")
}
drop var

gen ci95=1.96*stderr
label var coef "Point estimate"
label var year "Year"

serrbar coef ci95 year, xlabel(1991 "91" 1992 "92" 1993 "93" 1994 "94" 1995 "95" 1996 "96" 1997 "97" 1998 "98" 1999 "99" 2000 "00" 2001 "01" 2002 "02" 2003 "03" 2004 "04" 2005 "05" 2006 "06" 2007 "07" 2008 "08" 2009 "09" 2010 "10" 2011 "11" 2012 "12" 2013 "13" 2014 "14" 2015 "15", alternate) title ("High carbon intensity, high equity share") yscale (range(-0.02 0.01)) ylabel(#7)

graph export "${figures}/Chart2_4.png", replace height(1600)
cap erase "$tables/Chart2_4.dta"

log close