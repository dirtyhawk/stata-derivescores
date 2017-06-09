import delimited D:\lokal\stata-derivescores\tables\ISCO-88_Ganzeboom.csv, ///
	delimiter(comma) bindquote(strict) varnames(1) stripquote(yes) asfloat ///
	encoding(UTF-8) stringcols(1 2 3 4) numericcols(5) case(preserve) clear 
gen isco88_raw = real(Concept)
gen selfempl_raw = .
gen supvis_raw = .
tempfile blanko
save `blanko', replace
tempfile all
save `all', replace

local supvislist 0 1 10 11
local selfempllist 0 2

foreach supvis of local supvislist {
	set trace off
	foreach selfempl of local selfempllist {
		use `blanko', clear
		replace selfempl_raw = `selfempl'
		replace supvis_raw = `supvis'
		display "result_`supvis'_`selfempl'"
		append using `all'
		save `all', replace
	}
}
drop if supvis_raw==.
save `all', replace

* ganzeboom spss
gen ISKOg = isco88_raw
gen SEMPLg = selfempl_raw
gen SUPVISg = supvis_raw
gen EGP11g = 0
export delimited using "D:\temp\isco88toegp.csv", replace

* hendricks stata
use `all', clear
gen isko=isco88_raw
replace isko=3452 if isko==110
gen sempl= selfempl_raw
replace sempl=1 if sempl==2
gen supvis=supvis_raw
iskoegp egp11_hendricks , isko(isko) sempl(sempl) supvis(supvis)
merge 1:1 isco88_raw selfempl_raw supvis_raw using D:\temp\ganzeboom_spss_88_to_egp.dta, keepusing(EGP11g ISKOg SEMPLg SUPVISg)

* differences hendricks-ganzeboom:
** hendricks uses slightly different equivalent for iskoroot.sps
** hendricks doesnot implement lines 39-45 in iskoegp.sps

* file ganzeboom_spss_88_to_egp.dta is produced by
* reproduce_table_for_ganzebooms_algorithm.sps
* this SPSS script is equivalent to iskoegp.sps, 
* which launches iskopromo.sps and iskoroot.sps
*   except one correction for concept "110 [armed forces]" 
*   (not used in derivation) which is linked to
*   3452	[armed forces non-commissioned officers + army nfs].

*show that it makes no difference to supervise 10 or 11 (not really clear in ganzebooms skript)
use D:\temp\ganzeboom_spss_88_to_egp.dta, clear
keep if supvis_raw==10 | supvis_raw==11
fre supvis_raw
bysort Concept selfempl_raw: egen EGPmax=max(EGP11g)
bysort Concept selfempl_raw: egen EGPmin=min(EGP11g)
bysort Concept selfempl_raw: gen Concept_n=_n
gen change_within=1
bysort Concept selfempl_raw: replace change_within=0 if EGPmin==EGPmax
fre change_within

* produce correspondence
use D:\temp\ganzeboom_spss_88_to_egp.dta, clear
drop if supvis_raw==11
rename ConceptScheme sourceConceptScheme
rename Concept sourceConcept
gen targetConceptScheme = "EGP_Ganzeboom"
rename EGP11g targetConcept
rename selfempl_raw aux1
rename supvis_raw aux2
keep sourceConceptScheme sourceConcept aux1 aux2 targetConceptScheme targetConcept
order sourceConceptScheme sourceConcept aux1 aux2 targetConceptScheme targetConcept
sort sourceConcept aux1 aux2
export delimited using "D:\lokal\stata-derivescores\tables\ISCO-88_Ganzeboom--EGP_Ganzeboom.csv", nolabel quote replace
