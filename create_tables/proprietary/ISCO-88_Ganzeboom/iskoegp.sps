** last fix: summer 1994.
** last fix: may 2001 IIIa and IIIb distinguished.
 
** STANDARD RECODE OF OCCUPATIONS IN EGP SCORE
* THE MODULE HAS BEEN CHANGED TO A FORMAT FOR AN INDETERMINATE
* NUMBER OF VARIABLES. YOU NEED TO DEFINE IN YOUR FILE THE FOLLOWING
* MACRO VARIABLES:
* @ISKO
* @EGP11
* @SEMPL
* @SUPVIS.
 
do repeat iii=@isko / eee=@egp11.
compute eee=iii.
end repeat.

include file="U:\)ISMF\Incl\iskopromo.sps".
execute.
include file='U:\)ISMF\Incl\iskoroot.sps'.
execute.

DO REPEAT      E=@EGP11 / IS=@ISKO / sv=@supvis / s=@sempl.
COMMENT        #P CODES PROMOTABILITY OF CERTAIN OCCUPATIONS.
COMPUTE        #P=IS.
RECODE         #P (1000 thru 9299=1)(else=0).
compute        #d=is.
comment        #d codes degradability of certain occupations.
recode         #d (1300 thru 1319 3400 thru 3439 4000 thru 5230=1)(else=0).
IF             ((E=3) AND (SV GE 1)) E=2.
if             ((e eq 3 or e eq 2) and (s eq 2) and (#d=1)) e=4.
IF             ((E GE 7 AND E LE 9) AND (S=2) and (#p=1)) E=5.
IF             ((E=8) AND (SV GE 1)) E=7.
IF             ((E=10) AND (S=2)) E=11.
IF             ((E=4) AND (SV lt 1)) E=5.
IF             ((E=5) AND (SV Ge 1)) E=4.
IF             ((E=2 OR E=3 OR E=4) AND (SV GE 10)) E=1.
end repeat.

recode @egp11 (4=5)(5=6).
 
do repeat eee=@egp11 /iii=@isko.
do if (eee eq 3).
recode iii (4142 4190 4200 thru 4215 5000 thru 5239=4) into eee.
end if.
end repeat.

add value labels @egp11
 (1)   I :Higher Controllers
 (2)  II :Lower Controllers
 (3) IIIa:Routine Nonmanual
 (4) IIIb:Lower Sales-Service
 (5)  IVa:Selfempl with empl
 (6)  IVb:Selfempl no empl
 (7)   V :Manual Supervisors
 (8)  VI :Skilled Worker
 (9) VIIa:Unskilled Worker
 (10)VIIb:Farm Labor
 (11) IVc:Selfempl Farmer.

