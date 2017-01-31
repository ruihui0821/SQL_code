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

12:Florida
125138#, PENSACOLA BEACH-SANTA ROSA ISLAND AUTHORITY, ESCAMBIA COUNTY
-- change to 120082 PENSACOLA, CITY OF ESCAMBIA COUNTY

34: New Jersey
340570#, NEW JERSEY MEADOWLANDS COMMISSION,  BERGEN COUNTY
The Hackensack Meadowlands Commission was renamed the New Jersey Meadowlands Commission on August 27, 2001.
-- change to 340039, HACKENSACK, CITY OF BERGEN COUNTY
36: New York
361591#, SENECA NATION OF INDIANS CATTARAUGUS COUNTY/ERIE COUNTY/CHAUTAUQUA COUNTY/ALLEGANY COUNTY
-- change to 361367 CATTARAUGUS, VILLAGE OF CATTARAUGUS COUNTY
05: ARKANSAS
050171
050168#, HELENA-WEST HELENA, CITY OF Helena and West Helena have consolidated into a single government. The name of the new community is "Helena-West Helena". Use CID 050168 for all policies in the former communities of "Helena" (CID 050168) and "West Helena" (CID 050171). The Initia, 
PHILLIPS COUNTY
-- change to 050168
13: Geogia
135175#, BROOKHAVEN, CITY OF BROOKHAVEN IS LOCATED ON DEKALB COUNTY FIRM PANELS: 0011J, 0012J, 0013J, 0014J, AND 0016J DATED 05/16/2013. The inital FIRM date for Brookhaven is 05/15/1980.
DEKALB COUNTY
-- change to 130065, 130065# DEKALB COUNTY * DEKALB COUNTY
48: Texas
481565#, FAYETTE CO. W.C.& I.D.-MONUMENT HILL, FAYETTE COUNTY
-- change to 480815, 480815# FAYETTE COUNTY* FAYETTE COUNTY

130159
-- change to 130158, 130158# AUGUSTA-RICHMOND COUNTY, CITY OF, RICHMOND COUNTY, The City of Augusta and Richmond County Consolidated into a new community The City of Augusta- Richmond County.

210066
-- change to 210067, 210067# LEXINGTON-FAYETTE URBAN COUNTY GOVERNMENT, FAYETTE COUNTY

125098
-- change to 120635, 120635# MIAMI-DADE COUNTY*, MIAMI-DADE COUNTY, INCLUDES THE UNINCORPORATED AREAS ONLY

481537
-- change to 480484# CONROE, CITY OF, MONTGOMERY COUNTY
