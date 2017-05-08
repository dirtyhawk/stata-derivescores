global source proprietary
global source direct
global ConceptScheme_variables ConceptScheme Concept prefLabel sortorder

*** ISCO-88_Ganzeboom
import delimited D:\temp\isco88\iskolab_modified.sps, ///
	delimiter(tab) varnames(nonames) rowrange(7:541) colrange(1:2) /// 
	stringcols(_all) encoding("utf-8") clear 

rename v1 Concept
rename v2 prefLabel
gen ConceptScheme="ISCO-88_Ganzeboom"
sort Concept
gen sortorder = _n
* sort military to the end
replace sortorder=1000 if sortorder==1
sort sortorder
replace sortorder = _n
order ConceptScheme Concept prefLabel sortorder
export delimited using D:\temp\stata-derivescores\tables\ISCO-88_Ganzeboom.csv, ///
	delimiter(",") quote replace
	

*** ISCO-88_Ganzeboom to ISEI_Ganzeboom	
infix str input_Concept 15-18 str output_Concept 20-21 using ///
	"D:\temp\isco88\iskoisei.sps", clear	
gen input_ConceptScheme="ISCO-88_Ganzeboom"
gen output_ConceptScheme="ISEI"
gen prob=1
order input_ConceptScheme input_Concept output_ConceptScheme output_Concept prob
export delimited using D:\temp\stata-derivescores\tables\ISCO-88_Ganzeboom--ISEI.csv, ///
	delimiter(",") quote replace
	
*** IDCO-88_COM
* source http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=ISCO_88_CO&StrFormat=CSV&StrLanguageCode=EN&IntKey=&IntLevel=&bExport=
local ConceptScheme "ISCO-88_COM"
import delimited D:/temp/ISCO_88_CO_20170508_221735.csv, ///
	delimiter(comma) bindquote(strict) varnames(1) stripquote(yes) ///
	stringcols(_all) clear 
rename code Concept
rename description prefLabel
keep Concept prefLabel
gen sortorder = _n
gen ConceptScheme="`ConceptScheme'"
order $ConceptScheme_variables
export delimited using "D:/temp/stata-derivescores/tables/`ConceptScheme'.csv", ///
	delimiter(",") quote replace

	
*** consolidate ConceptSchemes and Correspondence
local tables_folder "D:/temp/stata-derivescores/tables/" 
local temps
import delimited `tables_folder'ConceptSchemes_Correspondences.csv, ///
	delimiter(comma) bindquote(strict) varnames(1) case(preserve) clear 
keep if Correspondence == ""
levelsof ConceptScheme, local(ConceptSchemes)
display `"`ConceptSchemes'"'
set trace off
local ConceptScheme_number : word count `ConceptSchemes' 
display in red "`ConceptScheme_number'"
forvalues number = 1/`ConceptScheme_number' {
local ConceptScheme : word `number' of `ConceptSchemes'
display in red "`ConceptScheme'"
capture import delimited `tables_folder'`ConceptScheme'.csv, ///
	delimiter(comma) bindquote(strict) varnames(1) case(preserve) ///
	encoding(UTF-8) stringcols(2) clear 
if _rc==601 continue
tempfile file`number'
local temps = "file`number' `temps'"
save `file`number'', replace
}
display "`temps'"
clear
local temps_number : word count `temps'
foreach temp of local temps {
append using ``temp''
}
export delimited using "`tables_folder'ConceptSchemes.csv", ///
	delimiter(",") quote replace


append using "`temps'"


capture use teste
display _rc

local ConceptScheme_number : word count 123 123 
display in red "`ConceptScheme_number'"

local test "123-2"
display strtoname("`test'")
	
local url "http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=ISCO_88_CO&StrFormat=CSV&StrLanguageCode=EN&IntKey=&IntLevel=&bExport="
import delimited "`url'", delimiters(";") bindquote(strict) varnames(1) stripquote(yes) stringcols(_all) clear 

rename code concept

gen long value = 0
replace value = real(code)*10^(4-real(level))
drop order level parent explanatorynotes


import delimited D:\temp\isco88\scaleapp_modified.htm, ///
	delimiter(tab) varnames(nonames) rowrange(3:534) colrange(4:5)clear 
	
