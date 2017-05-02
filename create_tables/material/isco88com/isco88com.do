local url "http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=ISCO_88_CO&StrFormat=CSV&StrLanguageCode=EN&IntKey=&IntLevel=&bExport="
import delimited "`url'", delimiters(";") bindquote(strict) varnames(1) stripquote(yes) stringcols(_all) clear 
gen long value = 0
replace value = real(code)*10^(4-real(level))

