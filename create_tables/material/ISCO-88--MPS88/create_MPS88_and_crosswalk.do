cd "D:\lokal\stata-derivescores\"
* The following table is extracted from:
* Christoph, Bernhard: Zur Messung des Berufsprestiges: Aktualisierung der 
* Magnitude-Prestigeskala auf die Berufsklassifikation ISCO88 [Measuring 
* occupational prestige: updating the magnitude-prestige-scale to ISCO88]
* https://nbn-resolving.org/urn:nbn:de:0168-ssoar-207543 

import excel "create_tables\proprietary\ISCO-88--MPS88\bernhard2005.xlsx", ///
	firstrow allstring clear
rename MPS88 Concept
tempfile sheet
save `sheet', replace
duplicates drop Concept, force

gen ConceptScheme="MPS88"
gen labelStyle = "default"
gen prefLabel = ""
gen prefValue = real(Concept)
format prefValue %9.1f
sort prefValue
gen sortorder = _n

drop ISCO88 label_de

order ConceptScheme labelStyle Concept prefLabel sortorder prefValue

export delimited using "tables\MPS88.csv", quote replace datafmt

import delimited tables\ISCO-88_Ganzeboom.csv, delimiter(comma) varnames(1) case(preserve) encoding(utf8) stringcols(1 2 3 4) clear 
*keep if labelStyle=="de"
rename Concept ISCO88
merge 1:1 ISCO88 using `sheet'
keep if _merge==3
rename ConceptScheme sourceConceptScheme
rename ISCO88 sourceConcept
gen targetConceptScheme="MPS88"
rename Concept targetConcept
gen prob=1
gen comment=""

keep sourceConceptScheme sourceConcept targetConceptScheme targetConcept prob comment
order sourceConceptScheme sourceConcept targetConceptScheme targetConcept prob comment

export delimited using "tables\ISCO-88_Ganzeboom--MPS88", quote replace datafmt
