/*-------------------------------------------------------------------------------
  derivescores.ado: Stata tool to enable structured derivation of (score) variables from classifications based on derivation tables
  
    Copyright (C) 2017 	Daniel Bela (daniel.bela@lifbi.de)
			Knut Wenzig

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------*/
*! derivescores.ado: Stata tool to enable structured derivation of (score) variables from classifications based on derivation tables
program define derivescores , nclass sortpreserve
	version 14 // Stata version 14 or newer required
	// parse subcommands: valid are "help", "setup", "list", "wipe", "info", "valuelabel", "crosswalk", "destring"
	local validcmds help setup list wipe info valuelabel crosswalk destring
	gettoken cmd 0 : 0, parse(`" ,"')
        local cmdlength=length(`"`cmd'"')
	// no subcommand specified -- issue error message
        if (`cmdlength'==0) {
		noisily : display as error `"{cmd:derivescores} subcommand needed {c -} valid subcommands are: {it:`validcmds'}"'
 	     	derivescores_help
		exit 198
        }
	// handle abbreviation of subcommands
	foreach validcmd of local validcmds {
		if (substr(`"`validcmd'"',1,max(1,`cmdlength'))==`"`cmd'"') {
			local cmd `"`validcmd'"'
			continue , break
		}
	}
	// check if subcommand is valid
	if (`: list cmd in validcmds'==0) {
		noisily : display as error `"illegal {cmd:derivescores} subcommand {c -} valid subcommands are: {it:`validcmds'}"'
 	     	derivescores_help
		exit 198
	}
	// execute subcommand
	capture : noisily derivescores_`cmd' `0'
	if (_rc!=0) {
		derivescores_help
		exit _rc
	}
	exit 0
end
// EOF
