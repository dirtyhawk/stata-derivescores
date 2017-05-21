
** This module makes sure that managers and owners with certain
** employment statuses go into the right place.

do repeat iii=@isko / sss=@sempl.
do if (sss eq 2).
. recode iii (6130=1311).
end if.
end repeat.

execute.

do repeat s=@sempl / sv=@supvis / is=@isko.
if ( is eq 7510 and sv le 0) sv=5.
if ((is ge 6100 and is le 6133) and sv ge 1) is=1311.
if ((is ge 9200 and is le 9213) and sv gt 1) is=6132.
do if (sv ge 11).
recode is (1311=1221)(1312=1222)(1313=1223)(1314=1224)(1315=1225)
          (1316=1226)(1317=1227)(1318=1228)(1319=1229)(1300,1310=1220).
end if.
do if (sv ge 1 and sv le 10).
recode is (1221=1311)(1222=1312)(1223=1313)(1224=1314)(1225=1315)
          (1226=1316)(1227=1317)(1228=1318)(1229=1319)(1200 1210 1220=1310).
end if.
if ((is eq 1220 or (is ge 1222 and is le 1229))
   and (s eq 2) and sv ge 11) is=1210.
end repeat.

 


