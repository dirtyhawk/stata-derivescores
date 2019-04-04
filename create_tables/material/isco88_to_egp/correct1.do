cd D:\lokal\stata-derivescores\
clear
import delimited tables\EGP_Ganzeboom.csv, encoding(utf8) ///
	stringcols(1 2 3 4) clear  case(preserve)
keep Concept prefValue
tempfile egp
save `egp', replace

import delimited tables\ISCO-88_Ganzeboom--EGP_Ganzeboom.csv, encoding(utf8) ///
	stringcols(1 2 3 4) clear   case(preserve) 
gen prefValue = real(targetConcept)
merge n:1 prefValue using `egp'
replace targetConcept=Concept
gen so = real(sourceConcept)
sort so
drop prefValue Concept _merge so
export delimited using "tables\ISCO-88_Ganzeboom--EGP_Ganzeboom.csv", quote replace
