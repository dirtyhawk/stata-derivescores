/*-------------------------------------------------------------------------------
  derivescores_help.ado: helper script for -derivescores- to display inline help
  
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
*! derivescores_help.ado: helper script for -derivescores- to display inline help
/*
	This procedure displays a syntax diagram of -derivescores- and links to the
	appropriate help file.
	It is supposed to be called if anything goes wrong when running -derivescores-,
	or if explicitly opened with -derivescores help-. 
*/
program define derivescores_help , nclass
	// issue help message
	noisily : display as error _newline in smcl `"{text}This help message is a stub. Please help improving {cmd:derivescores} by writing a real help text. Lateron, it will be expanded to a full Stata help file."'
	// quit
	exit 0
end
// EOF
