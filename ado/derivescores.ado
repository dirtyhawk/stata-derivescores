*! derivescores.ado: Stata tool to enable structured derivation of (score) variables from classifications based on derivation tables
program define derivescores , nclass sortpreserve
	version 14 // Stata version 14 or newer required
	// parse subcommands: valid are "help", "init", "list", "info", "label", "crosswalk"
	local validcmds help init list cleanup info label crosswalk
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
