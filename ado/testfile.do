/*
THIS TEST FILE IS TO BE RUN WITH STATA'S WORKING DIRECTORY SET TO 
THE MAIN PROJECT PATH
*/

// drop clutter and initialise macros
set more off
clear all
discard

// create a new, empty PLUS-directory, install the current version of the package there
local olddir `"`c(pwd)'"'
capture : cd `"./PLUStemp"'
if (_rc==0) cd ".."
else mkdir `"./PLUStemp"'
sysdir set PLUS `"./PLUStemp"'
net install derivescores , from(`c(pwd)') replace

// clear screen
cls

// test procedure
derivescores wipe , verbose
clear
derivescores setup


sysuse auto , clear
replace make="1" in 1
replace make="11" in 2
replace make="111" in 3
replace make="1110" in 4
rename rep78 sourceConcept
rename headroom targetConcept
rename turn probmarker
generate aux1=1000
generate aux2=2000
replace foreign=0 in 1
replace foreign=0 in 2
replace foreign=2 in 3
replace foreign=2 in 4
replace length=0 in 1
replace length=1 in 2
replace length=10 in 3
replace length=10 in 4
generate KldB88=make
replace KldB88="0110" in 1
replace KldB88="0111" in 2
replace KldB88="0115" in 3
replace KldB88="0116" in 4
expand 1000 in 1/4
derivescores crosswalk make , generate(ISCO_Ganzeboom) from("ISCO-88_ILO") to("ISCO-88_Ganzeboom")
derivescores crosswalk ISCO_Ganzeboom , generate(EGP) from("ISCO-88_Ganzeboom") to("EGP_Ganzeboom") aux(foreign length)
derivescores cr KldB88 , generate(KldB2010) from("KldB88") to("KldB2010")
*browse

exit 0
