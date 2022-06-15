# stata-derivescores
Stata tool to enable structured derivation of (score) variables from classifications based on derivation tables.

Install the package from within Stata by running:
`. net from https://raw.githubusercontent.com/dirtyhawk/stata-derivescores/master/`

Presentation slides are available: [doi:10.5281/zenodo.827308](https://doi.org/10.5281/zenodo.827308)

Here is a minimal example:
```
clear
set obs 1
gen isco = "9"

capture derivescores wipe
derivescores setup
derivescores crosswalk isco, from("ISCO-08_Kantar") to("ISCO-08_Ganzeboom") generate(ganzeboom)
```
