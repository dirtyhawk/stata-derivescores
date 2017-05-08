global source proprietary
gloabl source direct

*** ISCO-88_Ganzeboom
import delimited D:\temp\isco88\iskolab_modified.sps, ///
	delimiter(tab) varnames(nonames) rowrange(7:541) colrange(1:2) /// 
	stringcols(_all) encoding("utf-8") clear 

rename v1 Concept
rename v2 prefLabel
gen ConceptScheme="ISCO88_Ganzeboom"
sort Concept
gen sortorder = _n
replace sortorder=1000 if sortorder==1
sort sortorder
replace sortorder = _n
order ConceptScheme Concept prefLabel sortorder
export delimited using D:\temp\stata-derivescores\tables\ISCO-88_Ganzeboom.csv, ///
	delimiter(tab) replace
	

*** ISCO-88_Ganzeboom to ISEI_Ganzeboom	
infix str input_Concept 15-18 str output_Concept 20-21 using ///
	"D:\temp\isco88\iskoisei.sps", clear	
gen input_ConceptScheme="ISCO-88_Ganzeboom"
gen output_ConceptScheme="ISEI"
gen prob=1
order input_ConceptScheme input_Concept output_ConceptScheme output_Concept prob
export delimited using D:\temp\stata-derivescores\tables\ISCO-88_Ganzeboom--ISEI.csv, ///
	delimiter(tab) replace
	
ende
	
local url "http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=ISCO_88_CO&StrFormat=CSV&StrLanguageCode=EN&IntKey=&IntLevel=&bExport="
import delimited "`url'", delimiters(";") bindquote(strict) varnames(1) stripquote(yes) stringcols(_all) clear 

rename code concept

gen long value = 0
replace value = real(code)*10^(4-real(level))
drop order level parent explanatorynotes


import delimited D:\temp\isco88\scaleapp_modified.htm, ///
	delimiter(tab) varnames(nonames) rowrange(3:534) colrange(4:5)clear 
	
