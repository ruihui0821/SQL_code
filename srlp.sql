select commname, commno, count(*) from srlp where commno not in (select j.j_cid from fima.jurisdictions j) group by 1,2 order by 3 desc;
                  commname                   | commno | count 
---------------------------------------------+--------+-------
 PENSACOLA BEACH-SANTA ROSA ISLAND AUTHORITY | 125138 |   228
 NEW JERSEY MEADOWLANDS COMMISSION           | 340570 |     8
 SENECA NATION OF INDIANS                    | 361591 |     4
 WEST HELENA, CITY OF                        | 050171 |     3
 BROOKHAVEN, CITY OF                         | 135175 |     2
 METROPOLITAN DADE COUNTY*                   | 125098 |     2
 CHATEAU WOODS, CITY OF                      | 481537 |     1
 AUGUSTA, CITY OF                            | 130159 |     1
 FAYETTE CO. W.C.& I.D.-MONUMENT HILL        | 481565 |     1
 FAYETTE COUNTY*                             | 210066 |     1
(10 rows)
