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
derivescores cleanup , verbose
clear
sysuse auto , clear
replace make="1" in 1
replace make="11" in 2
replace make="111" in 3
replace make="1110" in 4
rename rep78 sourceConcept
rename headroom targetConcept
derivescores init
derivescores crosswalk make , generate(newvar) from("ISCO-88_ILO") to("ISCO-88_Ganzeboom") numeric 

*browse

exit 0
