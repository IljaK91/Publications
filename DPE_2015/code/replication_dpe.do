*==============================================================================
* "Economic Shocks & Civil Conflict in Sub-Saharan Africa 1981-2010"
* Stata do-file for recreating results in the paper
* This version: 20 September 2013
* Package for Rare Events Logit can be found at:
* http://gking.harvard.edu/relogit
*==============================================================================

* Load the data
clear
version 12
cd <specify DIR>
log <DIR>rainconflict_re-analysis.log, replace
use RainShocksConflict_Re-Analysis.dta
tsset ccode year

* Generate country FE, country-specific time trend, and country controls
tab ccode, gen(Iccode)	

local i=1
while (`i'< 48){
quietly gen Iccyear`i' = Iccode`i'*year
label variable Iccyear`i' "Country-specific time trends for Iccode`i'"
local i = `i' + 1
}

global x_id= "pt8 lnpop_l polity2sq_l y_0 preg mountains oildummy"


*==============================================================================
* Table 2: IV-2SLS (First-stage): Economic growth & rainfall
*==============================================================================
*	(1) 
reg gdp_g gpcp_g gpcp_gl, robust cluster(ccode)
*	(2) 
reg gdp_g gpcp_g gpcp_gl Iccode* Iccyear*, robust cluster(ccode)
*	(3) 
reg gdp_g gpcp_g gpcp_gl $x_id Iccyear*, robust cluster(ccode)
*	(4) 
reg gdp_g gpcp_d gpcp_dl, robust cluster(ccode)
*	(5) 
reg gdp_g gpcp_d gpcp_dl Iccode* Iccyear*, robust cluster(ccode)
*	(6) 
reg gdp_g gpcp_d gpcp_dl $x_id Iccyear*, robust cluster(ccode)





*==============================================================================
* Table 3: Table 5: OLS: Growth per sector & rainfall
*==============================================================================
* 	(1) 
reg agri_g gpcp_g gpcp_gl Iccode* Iccyear*, robust cluster(ccode)
*	(2) 
reg agri_g gpcp_g gpcp_gl $x_id Iccyear*, robust cluster(ccode)
*	(3) 
reg agri_g gpcp_d gpcp_dl Iccode* Iccyear*, robust cluster(ccode)
*	(4) 
reg agri_g gpcp_d gpcp_dl $x_id Iccyear*, robust cluster(ccode)
*	(5)
reg ind_g gpcp_g gpcp_gl Iccode* Iccyear*, robust cluster(ccode)
*	(6)
reg ind_g gpcp_g gpcp_gl $x_id Iccyear*, robust cluster(ccode)
*	(7)
reg ind_g gpcp_d gpcp_dl Iccode* Iccyear*, robust cluster(ccode)
*	(8)
reg ind_g gpcp_d gpcp_dl $x_id Iccyear*, robust cluster(ccode)




*==============================================================================
* Table 4: Reduced form: Conflict onset & rainfall
*==============================================================================
*	(1)
reg conflict_onset gpcp_g gpcp_gl Iccode* Iccyear*, robust cluster(ccode)
*	(2)
reg conflict_onset gpcp_g gpcp_gl $x_id Iccyear*, robust cluster(ccode)
*	(3)
relogit conflict_onset gpcp_g gpcp_gl $x_id, cluster(ccode) 
*	(4)
reg conflict_onset gpcp_d gpcp_dl Iccode* Iccyear*, robust cluster(ccode)
*	(5)
reg conflict_onset gpcp_d gpcp_dl $x_id Iccyear*, robust cluster(ccode)
*	(6)
relogit conflict_onset gpcp_d gpcp_dl $x_id, cluster(ccode) 




*==============================================================================
* Table 5: IV-2SLS (second stage): Conflict onset & economic growth
*==============================================================================
*	(1)
reg conflict_onset gdp_g gdp_gl (gpcp_g gpcp_gl), robust cluster(ccode)
*	(2)
reg conflict_onset gdp_g gdp_gl Iccode* Iccyear* (gpcp_g gpcp_gl Iccode* Iccyear*), robust cluster(ccode)
*	(3)
reg conflict_onset gdp_g gdp_gl $x_id Iccyear* (gpcp_g gpcp_gl $x_id Iccyear*), robust cluster(ccode)
*	(4)
reg conflict_onset gdp_g gdp_gl (gpcp_d gpcp_dl), robust cluster(ccode)
*	(5)
reg conflict_onset gdp_g gdp_gl Iccode* Iccyear* (gpcp_d gpcp_dl Iccode* Iccyear*), robust cluster(ccode)
*	(6)
reg conflict_onset gdp_g gdp_gl $x_id Iccyear* (gpcp_d gpcp_dl $x_id Iccyear*), robust cluster(ccode)




*==============================================================================
* Table 6: IV-2SLS (second stage): Conflict onset & economic growth per sector
*==============================================================================
*	(1)
reg conflict_onset agri_g agri_gl Iccode* Iccyear* (gpcp_d gpcp_dl Iccode* Iccyear*), robust cluster(ccode)
*	(2)
reg conflict_onset agri_g agri_gl $x_id Iccyear* (gpcp_d gpcp_dl $x_id Iccyear*), robust cluster(ccode)
*	(3)
reg conflict_onset ind_g ind_gl Iccode* Iccyear* (gpcp_d gpcp_dl Iccode* Iccyear*), robust cluster(ccode)
*	(4)
reg conflict_onset ind_g ind_gl $x_id Iccyear* (gpcp_d gpcp_dl $x_id Iccyear*), robust cluster(ccode)




*==============================================================================
* Table 7: IV-2SLS (second stage): Conflict onset (5-year intermittency) 
* & economic growth
*==============================================================================
*	(1)
reg conflict_onset5 gdp_g gdp_gl (gpcp_g gpcp_gl), robust cluster(ccode)
*	(2)
reg conflict_onset5 gdp_g gdp_gl Iccode* Iccyear* (gpcp_g gpcp_gl Iccode* Iccyear*), robust cluster(ccode)
*	(3)
reg conflict_onset5 gdp_g gdp_gl $x_id Iccyear* (gpcp_g gpcp_gl $x_id Iccyear*), robust cluster(ccode)
*	(4)
reg conflict_onset5 gdp_g gdp_gl (gpcp_d gpcp_dl), robust cluster(ccode)
*	(5)
reg conflict_onset5 gdp_g gdp_gl Iccode* Iccyear* (gpcp_d gpcp_dl Iccode* Iccyear*), robust cluster(ccode)
*	(6)
reg conflict_onset5 gdp_g gdp_gl $x_id Iccyear* (gpcp_d gpcp_dl $x_id Iccyear*), robust cluster(ccode)




*==============================================================================
* Table 8: Descriptive statistics
*==============================================================================
* 	Panel A: Civil conflict
sum anyconflict conflict_onset conflict_offset conflict_onset5
*	Panel B: Precipitation
sum gpcp gpcp_g gpcp_gl gpcp_d gpcp_dl
*	Panel C: Economic growth
sum gdp_g gdp_gl agri_g ind_g
*	Panel D: Country controls
sum $x_id 




*==============================================================================
* Table 10: Economic Growth & Rainfall: First Stage per period
*=====================================================================================
*	(1)
reg gdp_g gpcp_g gpcp_gl Iccode* Iccyear*, robust cluster(ccode)
*	(2)
reg gdp_g gpcp_d gpcp_dl Iccode* Iccyear*, robust cluster(ccode)
*	(3)
reg gdp_g gpcp_g gpcp_gl Iccode* Iccyear* if year<2000, robust cluster(ccode)
*	(4)
reg gdp_g gpcp_d gpcp_dl Iccode* Iccyear* if year<2000, robust cluster (ccode)
*	(5)
reg gdp_g gpcp_g gpcp_gl Iccode* Iccyear* if year>1999, robust cluster(ccode)
*	(6)
reg gdp_g gpcp_d gpcp_dl Iccode* Iccyear* if year>1999, robust cluster (ccode)

log close 