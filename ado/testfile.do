/*
THIS TEST FILE IS TO BE RUN WITH STATA'S WORKING DIRECTORY SET TO 
THE MAIN PROJECT PATH
*/

// drop clutter and initialise macros
set more off

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
derivescores init , verbose

browse

exit 0
