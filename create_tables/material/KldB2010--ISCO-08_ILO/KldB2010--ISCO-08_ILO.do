import excel "D:/lokal/stata-derivescores/create_tables/proprietary/KldB2010--ISCO08_ILO/Umsteigeschluessel-KldB2010-ISCO-08.xls", ///
	sheet("Umsteiger KldB 2010 auf ISCO") cellrange(A5:F1508) firstrow ///
	allstring clear

gen comment=""
gen sourceConceptScheme="KldB2010"
rename KldB20105Steller sourceConcept
gen targetConceptScheme="ISCO08_ILO"
rename ISCO084Steller targetConcept
gen anzahl = real(Schwerpunkt1undAnzahlder)
bysort sourceConcept (anzahl): gen N=_N
bysort sourceConcept (anzahl): gen n=_n
count if n!=anzahl
gen prob=0
replace prob=2/(N+1) if n==1
replace prob=1/(N+1) if n>1
keep sourceConceptScheme sourceConcept targetConceptScheme targetConcept prob comment
order sourceConceptScheme sourceConcept targetConceptScheme targetConcept prob comment

/*
preserve
* check integrity of table
import delimited D:/lokal/stata-derivescores/tables/KldB2010.csv, encoding(UTF-8) stringcols(1/4) case(preserve) clear 
keep if labelStyle=="de_short"
rename Concept sourceConcept
tempfile KldB2010
save `KldB2010', replace

import delimited D:/lokal/stata-derivescores/tables/ISCO-08_ILO.csv, encoding(UTF-8) stringcols(1/4) case(preserve) clear 
keep if labelStyle=="en"
rename Concept targetConcept
tempfile ISCO08_ILO
save `ISCO08_ILO', replace
restore
* all sourceConcepts exist in sourceConceptscheme:
merge m:1 sourceConcept using `KldB2010', keep(master match) nogen assert(match)

* all targetConcepts exist in targetConceptScheme:
merge m:1 targetConcept using `ISCO08_ILO', keep(master match) nogen assert(match)
*/
export delimited using "D:\lokal\stata-derivescores\tables\KldB2010--ISCO-08_ILO.csv", quote replace
