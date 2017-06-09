import excel "D:\lokal\stata-derivescores\create_tables\proprietary\KldB88--KldB2010\Umsteigeschluessel-KldB1988-4-Steller-KldB2010-5-Steller.xls", ///
	sheet("Umstieg_KldB 1988_KldB 2010") cellrange(A5:F3881) firstrow ///
	allstring clear

gen comment=""
* corrections
replace Schwerpunkt1undAnzahlderA = "4" in 1808
replace Schwerpunkt1undAnzahlderA = "5" in 1809
replace Schwerpunkt1undAnzahlderA = "6" in 1810
replace Schwerpunkt1undAnzahlderA = "13" in 1890
replace Schwerpunkt1undAnzahlderA = "5" in 2026
replace Schwerpunkt1undAnzahlderA = "3" in 2104	
replace Schwerpunkt1undAnzahlderA = "5" in 2125
replace Schwerpunkt1undAnzahlderA = "1" in 2923 /*not clear*/
replace Schwerpunkt1undAnzahlderA = "2" in 2924 /*not clear*/
replace Schwerpunkt1undAnzahlderA = "3" in 2925 /*not clear*/
replace Schwerpunkt1undAnzahlderA = "4" in 2926 /*not clear*/
replace Schwerpunkt1undAnzahlderA = "3" in 3563
replace Schwerpunkt1undAnzahlderA = "4" in 3564
replace Schwerpunkt1undAnzahlderA = "5" in 3565
replace KldB19884Steller = "8813" in 3626 /*not clear*/

replace comment = "source table containing crosswalk corrected" in 1808
replace comment = "source table containing crosswalk corrected" in 1809
replace comment = "source table containing crosswalk corrected" in 1810
replace comment = "source table containing crosswalk corrected" in 1890
replace comment = "source table containing crosswalk corrected" in 2026
replace comment = "source table containing crosswalk corrected" in 2104	
replace comment = "source table containing crosswalk corrected" in 2125
replace comment = "source table containing crosswalk corrected, not clear" in 2923 /*not clear*/
replace comment = "source table containing crosswalk corrected, not clear" in 2924 /*not clear*/
replace comment = "source table containing crosswalk corrected, not clear" in 2925 /*not clear*/
replace comment = "source table containing crosswalk corrected, not clear" in 2926 /*not clear*/
replace comment = "source table containing crosswalk corrected" in 3563
replace comment = "source table containing crosswalk corrected" in 3564
replace comment = "source table containing crosswalk corrected" in 3565
replace comment = "source table containing crosswalk corrected, not clear" in 3626 /*not clear*/

	
gen sourceConceptScheme="KldB88"
rename KldB19884Steller sourceConcept
gen targetConceptScheme="KldB2010"
rename KldB20105Steller targetConcept
gen anzahl = real(Schwerpunkt1undAnzahlderA)
bysort sourceConcept (anzahl): gen N=_N
bysort sourceConcept (anzahl): gen n=_n
count if n!=anzahl
gen prob=0
replace prob=2/(N+1) if n==1
replace prob=1/(N+1) if n>1
replace prob=0 if targetConcept=="0"
replace comment="no equivalent target concept" if targetConcept=="0"
replace targetConcept="" if targetConcept=="0"
keep sourceConceptScheme sourceConcept targetConceptScheme targetConcept prob comment
order sourceConceptScheme sourceConcept targetConceptScheme targetConcept prob comment

export delimited using "D:\lokal\stata-derivescores\tables\KldB88--KldB2010.csv", quote replace
