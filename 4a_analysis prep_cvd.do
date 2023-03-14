** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          4a_analysis prep_cvd.do
    //  project:                BNR-CVD
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      14-MAR-2023
    // 	date last modified      14-MAR-2023
    //  algorithm task          Preparing cleaned 2021 dataset for analysis
    //  status                  Completed
    //  objective               To have a cleaned and prepared 2021 heart and stroke incidence datasets for 
	//							 - annual report analysis
	//							 - data requests
    //  methods                 (1) Remove unnecessary variables (i.e. cleaning flags, etc.)
	//							(2) Rename variable labels in prep for use in data requests
	//							(3) Create analysis variables
	//							(4) Create identifiable and deidentified datasets for:
	//								- heart analysis/data requests
	//								- stroke analysis/data requests
	//							(5) Remove irrelevant variables (i.e. heart variables removed from stroke dataset and vice versa)
	//							(6) Re-assign variable that identifies records with both heart and stroke events (sd_bothevent)
	//  support:                Natasha Sobers and Ian R Hambleton

    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p116"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p116

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\4a_analysis prep_cvd.smcl", replace
** HEADER -----------------------------------------------------

** Load cleaned final form 2021 dataset
use "`datapath'\version03\2-working\BNRCVDCORE_CleanedData_final", clear

count //1145

** Checking to ensure irrelevant missing code checkboxes do not have data in them 
** (e.g. nohosp missing code is 99 so the other variables can be removed from the dataset since REDCap db exports all the possible missing codes for checkbox variables)
count if nohosp___88==1 //0
count if nohosp___999==1 //0
count if nohosp___9999==1 //0

count if absdxs___88==1 //0
count if absdxs___999==1 //0
count if absdxs___9999==1 //0

count if absdxh___88==1 //0
count if absdxh___999==1 //0
count if absdxh___9999==1 //0

count if asp___88==1 //0
count if asp___999==1 //0
count if asp___9999==1 //0

count if warf___88==1 //0
count if warf___999==1 //0
count if warf___9999==1 //0

count if hep___88==1 //0
count if hep___999==1 //0
count if hep___9999==1 //0

count if heplmw___88==1 //0
count if heplmw___999==1 //0
count if heplmw___9999==1 //0

count if pla___88==1 //0
count if pla___999==1 //0
count if pla___9999==1 //0

count if stat___88==1 //0
count if stat___999==1 //0
count if stat___9999==1 //0

count if fibr___88==1 //0
count if fibr___999==1 //0
count if fibr___9999==1 //0

count if ace___88==1 //0
count if ace___999==1 //0
count if ace___9999==1 //0

count if arbs___88==1 //0
count if arbs___999==1 //0
count if arbs___9999==1 //0

count if cors___88==1 //0
count if cors___999==1 //0
count if cors___9999==1 //0

count if antih___88==1 //0
count if antih___999==1 //0
count if antih___9999==1 //0

count if nimo___88==1 //0
count if nimo___999==1 //0
count if nimo___9999==1 //0

count if antis___88==1 //0
count if antis___999==1 //0
count if antis___9999==1 //0

count if ted___88==1 //0
count if ted___999==1 //0
count if ted___9999==1 //0

count if beta___88==1 //0
count if beta___999==1 //0
count if beta___9999==1 //0

count if bival___88==1 //0
count if bival___999==1 //0
count if bival___9999==1 //0

count if disdxs___88==1 //0
count if disdxs___999==1 //0
count if disdxs___9999==1 //0

count if disdxh___88==1 //0
count if disdxh___999==1 //0
count if disdxh___9999==1 //0

count if recdxs___88==1 //0
count if recdxs___999==1 //0
count if recdxs___9999==1 //0

count if recdxh___88==1 //0
count if recdxh___999==1 //0
count if recdxh___9999==1 //0

** Check if record_id is unique allowing removal of other unique ID variables
sort record_id 
quietly by record_id : gen dup = cond(_N==1,0,_n)
sort record_id
count if dup>0 //415 - all DCOs with blank record_id
count if dup>0 & record_id!="" //0

** Remove unnecessary variables (e.g. cleaning flag variables, irrelevant missing code checkbox variables, etc.)
drop copycf copydemo copyptm copyeve copyhx copytests copycomp copymeds copydis copyfu1 nohosp___88 nohosp___999 nohosp___9999 absdxs___88 absdxs___999 absdxs___9999 absdxh___88 absdxh___999 absdxh___9999 asp___88 asp___999 asp___9999 warf___88 warf___999 warf___9999 hep___88 hep___999 hep___9999 heplmw___88 heplmw___999 heplmw___9999 pla___88 pla___999 pla___9999 stat___88 stat___999 stat___9999 fibr___88 fibr___999 fibr___9999 ace___88 ace___999 ace___9999 arbs___88 arbs___999 arbs___9999 cors___88 cors___999 cors___9999 antih___88 antih___999 antih___9999 nimo___88 nimo___999 nimo___9999 antis___88 antis___999 antis___9999 ted___88 ted___999 ted___9999 beta___88 beta___999 beta___9999 bival___88 bival___999 bival___9999 disdxs___88 disdxs___999 disdxs___9999 disdxh___88 disdxh___999 disdxh___9999 recdxs___88 recdxs___999 recdxs___9999 recdxh___88 recdxh___999 recdxh___9999 rvetype repinstrument flag1 flag2 flag3 flag4 flag5 flag6 flag7 flag8 flag9 flag10 flag11 flag12 flag13 flag14 flag15 flag16 flag17 flag18 flag19 flag20 flag21 flag22 flag23 flag24 flag25 flag26 flag27 flag28 flag29 flag30 flag31 flag32 flag33 flag34 flag35 flag36 flag37 flag38 flag39 flag40 flag41 flag42 flag43 flag44 flag45 flag46 flag47 flag48 flag49 flag50 flag51 flag52 flag53 flag54 flag55 flag56 flag57 flag58 flag59 flag60 flag61 flag62 flag63 flag64 flag65 flag66 flag67 flag68 flag69 flag70 flag71 flag72 flag73 flag74 flag75 flag76 flag77 flag78 flag79 flag80 flag81 flag82 flag83 flag84 flag85 flag86 flag87 flag88 flag89 flag90 flag91 flag92 flag93 flag94 flag95 flag96 flag97 flag98 flag99 flag100 flag101 flag102 flag103 flag104 flag105 flag106 flag107 flag108 flag109 flag110 flag111 flag112 flag113 flag114 flag115 flag116 flag117 flag118 flag119 flag120 flag121 flag122 flag123 flag124 flag125 flag126 flag127 flag128 flag129 flag130 flag131 flag132 flag133 flag134 flag135 flag136 flag137 flag138 flag139 flag140 flag141 flag142 flag143 flag144 flag145 flag146 flag147 flag148 flag149 flag150 flag151 flag152 flag153 flag154 flag155 flag156 flag157 flag158 flag159 flag160 flag161 flag162 flag163 flag164 flag165 flag166 flag167 flag168 flag169 flag170 flag171 flag172 flag173 flag174 flag175 flag176 flag177 flag178 flag179 flag180 flag181 flag182 flag183 flag184 flag185 flag186 flag187 flag188 flag189 flag190 flag191 flag192 flag193 flag194 flag195 flag196 flag197 flag198 flag199 flag200 flag201 flag202 flag203 flag204 flag205 flag206 flag207 flag208 flag209 flag210 flag211 flag212 flag213 flag214 flag215 flag216 flag217 flag218 flag219 flag220 flag221 flag222 flag223 flag224 flag225 flag226 flag227 flag228 flag229 flag230 flag231 flag232 flag233 flag234 flag235 flag236 flag237 flag238 flag239 flag240 flag241 flag242 flag243 flag244 flag245 flag246 flag247 flag248 flag249 flag250 flag251 flag252 flag253 flag254 flag255 flag256 flag257 flag258 flag259 flag260 flag261 flag262 flag263 flag264 flag265 flag266 flag267 flag268 flag269 flag270 flag271 flag272 flag273 flag274 flag275 flag276 flag277 flag278 flag279 flag280 flag281 flag282 flag283 flag284 flag285 flag286 flag287 flag288 flag289 flag290 flag291 flag292 flag293 flag294 flag295 flag296 flag297 flag298 flag299 flag300 flag301 flag302 flag303 flag304 flag305 flag306 flag307 flag308 flag309 flag310 flag311 flag312 flag313 flag314 flag315 flag316 flag317 flag318 flag319 flag320 flag321 flag322 flag323 flag324 flag325 flag326 flag327 flag328 flag329 flag330 flag331 flag332 flag333 flag334 flag335 flag336 flag337 flag338 flag339 flag340 flag341 flag342 flag343 flag344 flag345 flag346 flag347 flag348 flag349 flag350 flag351 flag352 flag353 flag354 flag355 flag356 flag357 flag358 flag359 flag360 flag361 flag362 flag363 flag364 flag365 flag366 flag367 flag368 flag369 flag370 flag371 flag372 flag373 flag374 flag375 flag376 flag377 flag378 flag379 flag380 flag381 flag382 flag383 flag384 flag385 flag386 flag387 flag388 flag389 flag390 flag391 flag392 flag393 flag394 flag395 flag396 flag397 flag398 flag399 flag400 flag401 flag402 flag403 flag404 flag405 flag406 flag407 flag408 flag409 flag410 flag411 flag412 flag413 flag414 flag415 flag416 flag417 flag418 flag419 flag420 flag421 flag422 flag423 flag424 flag425 flag426 flag427 flag428 flag429 flag430 flag431 flag432 flag433 flag434 flag435 flag436 flag437 flag438 flag439 flag440 flag441 flag442 flag443 flag444 flag445 flag446 flag447 flag448 flag449 flag450 flag451 flag452 flag453 flag454 flag455 flag456 flag457 flag458 flag459 flag460 flag461 flag462 flag463 flag464 flag465 flag466 flag467 flag468 flag469 flag470 flag471 flag472 flag473 flag474 flag475 flag476 flag477 flag478 flag479 flag480 flag481 flag482 flag483 flag484 flag485 flag486 flag487 flag488 flag489 flag490 flag491 flag492 flag493 flag494 flag495 flag496 flag497 flag498 flag499 flag500 flag501 flag502 flag503 flag504 flag505 flag506 flag507 flag508 flag509 flag510 flag511 flag512 flag513 flag514 flag515 flag516 flag517 flag518 flag519 flag520 flag521 flag522 flag523 flag524 flag525 flag526 flag527 flag528 flag529 flag530 flag531 flag532 flag533 flag534 flag535 flag536 flag537 flag538 flag539 flag540 flag541 flag542 flag543 flag544 flag545 flag546 flag547 flag548 flag549 flag550 flag551 flag552 flag553 flag554 flag555 flag556 flag557 flag558 flag559 flag560 flag561 flag562 flag563 flag564 flag565 flag566 flag567 flag568 flag569 flag570 flag571 flag572 flag573 flag574 flag575 flag576 flag577 flag578 flag579 flag580 flag581 flag582 flag583 flag584 flag585 flag586 flag587 flag588 flag589 flag590 flag591 flag592 flag593 flag594 flag595 flag596 flag597 flag598 flag599 flag600 flag601 flag602 flag603 flag604 flag605 flag606 flag607 flag608 flag609 flag610 flag611 flag612 flag613 flag614 flag615 flag616 flag617 flag618 flag619 flag620 flag621 flag622 flag623 flag624 flag625 flag626 flag627 flag628 flag629 flag630 flag631 flag632 flag633 flag634 flag635 flag636 flag637 flag638 flag639 flag640 flag641 flag642 flag643 flag644 flag645 flag646 flag647 flag648 flag649 flag650 flag651 flag652 flag653 flag654 flag655 flag656 flag657 flag658 flag659 flag660 flag661 flag662 flag663 flag664 flag665 flag666 flag667 flag668 flag669 flag670 flag671 flag672 flag673 flag674 flag675 flag676 flag677 flag678 flag679 flag680 flag681 flag682 flag683 flag684 flag685 flag686 flag687 flag688 flag689 flag690 flag691 flag692 flag693 flag694 flag695 flag696 flag697 flag698 flag699 flag700 flag701 flag702 flag703 flag704 flag705 flag706 flag707 flag708 flag709 flag710 flag711 flag712 flag713 flag714 flag715 flag716 flag717 flag718 flag719 flag720 flag721 flag722 flag723 flag724 flag725 flag726 flag727 flag728 flag729 flag730 flag731 flag732 flag733 flag734 flag735 flag736 flag737 flag738 flag739 flag740 flag741 flag742 flag743 flag744 flag745 flag746 flag747 flag748 flag749 flag750 flag751 flag752 flag753 flag754 flag755 flag756 flag757 flag758 flag759 flag760 flag761 flag762 flag763 flag764 flag765 flag766 flag767 flag768 flag769 flag770 flag771 flag772 flag773 flag774 flag775 flag776 flag777 flag778 flag779 flag780 flag781 flag782 flag783 flag784 flag785 flag786 flag787 flag788 flag789 flag790 flag791 flag792 flag793 flag794 flag795 flag796 flag797 flag798 flag799 flag800 flag801 flag802 flag803 flag804 flag805 flag806 flag807 flag808 flag809 flag810 flag811 flag812 flag813 flag814 flag815 flag816 flag817 flag818 flag819 flag820 flag821 flag822 flag823 flag824 flag825 flag826 flag827 flag828 flag829 flag830 flag831 flag832 flag833 flag834 flag835 flag836 flag837 flag838 flag839 flag840 flag841 flag842 flag843 flag844 flag845 flag846 flag847 flag848 flag849 flag850 flag851 flag852 flag853 flag854 flag855 flag856 flag857 flag858 flag859 flag860 flag861 flag862 flag863 flag864 flag865 flag866 flag867 flag868 flag869 flag870 flag871 flag872 flag873 flag874 flag875 flag876 flag877 flag878 flag879 flag880 flag881 flag882 flag883 flag884 flag885 flag886 flag887 flag888 flag889 flag890 flag891 flag892 flag893 flag894 flag895 flag896 flag897 flag898 flag899 flag900 flag901 flag902 flag903 flag904 flag905 flag906 flag907 flag908 flag909 flag910 flag911 flag912 flag913 flag914 flag915 flag916 flag917 flag918 flag919 flag920 flag921 flag922 flag923 flag924 flag925 flag926 flag927 flag928 flag929 flag930 flag931 flag932 flag933 flag934 flag935 flag936 flag937 flag938 flag939 flag940 flag941 flag942 flag943 flag944 flag945 flag946 flag947 flag948 flag949 flag950 flag951 flag952 flag953 flag954 flag955 flag956 flag957 flag958 flag959 flag960 flag961 flag962 flag963 flag964 flag965 flag966 flag967 flag968 flag969 flag970 flag971 flag972 flag973 flag974 flag975 flag976 flag977 flag978 flag979 flag980 flag981 flag982 flag983 flag984 flag985 flag986 flag987 flag988 flag989 flag990 flag991 flag992 flag993 flag994 flag995 flag996 flag997 flag998 flag999 flag1000 flag1001 flag1002 flag1003 flag1004 flag1005 flag1006 flag1007 flag1008 flag1009 flag1010 flag1011 flag1012 flag1013 flag1014 flag1015 flag1016 flag1017 flag1018 flag1019 flag1020 flag1021 flag1022 flag1023 flag1024 flag1025 flag1026 flag1027 flag1028 flag1029 flag1030 flag1031 flag1032 flag1033 flag1034 flag1035 flag1036 flag1037 flag1038 flag1039 flag1040 flag1041 flag1042 flag1043 flag1044 flag1045 flag1046 flag1047 flag1048 flag1049 flag1050 flag1051 flag1052 flag1053 flag1054 flag1055 flag1056 flag1057 flag1058 flag1059 flag1060 flag1061 flag1062 flag1063 flag1064 flag1065 flag1066 flag1067 flag1068 flag1069 flag1070 flag1071 flag1072 flag1073 flag1074 flag1075 flag1076 flag1077 flag1078 flag1079 flag1080 flag1081 flag1082 flag1083 flag1084 flag1085 flag1086 flag1087 flag1088 flag1089 flag1090 flag1091 flag1092 flag1093 flag1094 flag1095 flag1096 flag1097 flag1098 flag1099 flag1100 flag1101 flag1102 flag1103 flag1104 flag1105 flag1106 flag1107 flag1108 flag1109 flag1110 flag1111 flag1112 flag1113 flag1114 flag1115 flag1116 flag1117 flag1118 flag1119 flag1120 flag1121 flag1122 flag1123 flag1124 flag1125 flag1126 flag1127 flag1128 flag1129 flag1130 flag1131 flag1132 flag1133 flag1134 flag1135 flag1136 flag1137 flag1138 flag1139 flag1140 flag1141 flag1142 flag1143 flag1144 flag1145 flag1146 flag1147 flag1148 flag1149 flag1150 flag1151 flag1152 flag1153 flag1154 flag1155 flag1156 flag1157 flag1158 flag1159 flag1160 flag1161 flag1162 flag1163 flag1164 flag1165 flag1166 flag1167 flag1168 flag1169 flag1170 flag1171 flag1172 flag1173 flag1174 flag1175 flag1176 flag1177 flag1178 flag1179 flag1180 flag1181 flag1182 flag1183 flag1184 flag1185 flag1186 flag1187 flag1188 flag1189 flag1190 flag1191 flag1192 flag1193 flag1194 flag1195 flag1196 flag1197 flag1198 flag1199 flag1200 flag1201 flag1202 flag1203 flag1204 flag1205 flag1206 flag1207 flag1208 flag1209 flag1210 flag1211 flag1212 flag1213 flag1214 flag1215 flag1216 flag1217 flag1218 flag1219 flag1220 flag1221 flag1222 flag1223 flag1224 flag1225 flag1226 flag1227 flag1228 flag1229 flag1230 flag1231 flag1232 flag1233 flag1234 flag1235 flag1236 flag1237 flag1238 flag1239 flag1240 flag1241 flag1242 flag1243 flag1244 flag1245 flag1246 flag1247 flag1248 flag1249 flag1250 flag1251 flag1252 flag1253 flag1254 flag1255 flag1256 flag1257 flag1258 flag1259 flag1260 flag1261 flag1262 flag1263 flag1264 flag1265 flag1266 flag1267 flag1268 flag1269 flag1270 flag1271 flag1272 flag1273 flag1274 flag1275 flag1276 flag1277 flag1278 flag1279 flag1280 flag1281 flag1282 flag1283 flag1284 flag1285 flag1286 flag1287 flag1288 flag1289 flag1290 flag1291 flag1292 flag1293 flag1294 flag1295 flag1296 flag1297 flag1298 flag1299 flag1300 flag1301 flag1302 flag1303 flag1304 flag1305 flag1306 flag1307 flag1308 flag1309 flag1310 flag1311 flag1312 flag1313 flag1314 flag1315 flag1316 flag1317 flag1318 flag1319 flag1320 flag1321 flag1322 flag1323 flag1324 flag1325 flag1326 flag1327 flag1328 flag1329 flag1330 flag1331 flag1332 flag1333 flag1334 flag1335 flag1336 flag1337 flag1338 flag1339 flag1340 flag1341 flag1342 flag1343 flag1344 flag1345 flag1346 flag1347 flag1348 flag1349 flag1350 flag1351 flag1352 flag1353 flag1354 flag1355 flag1356 flag1357 flag1358 flag1359 flag1360 flag1361 flag1362 flag1363 flag1364 flag1365 flag1366 flag1367 flag1368 flag1369 flag1370 flag1371 flag1372 flag1373 flag1374 flag1375 flag1376 flag1377 flag1378 flag1379 flag1380 flag1381 flag1382 flag1383 flag1384 flag1385 flag1386 flag1387 flag1388 flag1389 flag1390 flag1391 flag1392 flag1393 flag1394 flag1395 flag1396 flag1397 flag1398 flag1399 flag1400 flag1401 flag1402 flag1403 flag1404 flag1405 flag1406 flag1407 flag1408 flag1409 flag1410 flag1411 flag1412 flag1413 flag1414 flag1415 flag1416 flag1417 flag1418 flag1419 flag1420 flag1421 flag1422 flag1423 flag1424 flag1425 flag1426 flag1427 flag1428 flag1429 flag1430 flag1431 flag1432 flag1433 flag1434 flag1435 flag1436 flag1437 flag1438 flag1439 flag1440 flag1441 flag1442 flag1443 flag1444 flag1445 flag1446 flag1447 flag1448 flag1449 flag1450 flag1451 flag1452 flag1453 flag1454 flag1455 flag1456 flag1457 flag1458 flag1459 flag1460 flag1461 flag1462 flag1463 flag1464 flag1465 flag1466 flag1467 flag1468 flag1469 flag1470 flag1471 flag1472 flag1473 flag1474 flag1475 flag1476 flag1477 flag1478 flag1479 flag1480 flag1481 flag1482 flag1483 flag1484 flag1485 flag1486 flag1487 flag1488 flag1489 flag1490 flag1491 flag1492 flag1493 flag1494 flag1495 flag1496 flag1497 flag1498 flag1499 flag1500 flag1501 flag1502 flag1503 flag1504 flag1505 flag1506 flag1507 flag1508 flag1509 flag1510 flag1511 flag1512 flag1513 flag1514 flag1515 flag1516 flag1517 flag1518 flag1519 flag1520 flag1521 flag1522 flag1523 flag1524 flag1525 flag1526 flag1527 flag1528 flag1529 flag1530 flag1531 flag1532 flag1533 flag1534 flag1535 flag1536 flag1537 flag1538 flag1539 flag1540 flag1541 flag1542 flag1543 flag1544 flag1545 flag1546 flag1547 flag1548 flag1549 flag1550 flag1551 flag1552 flag1553 flag1554 flag1555 flag1556 flag1557 flag1558 flag1559 flag1560 flag1561 flag1562 flag1563 flag1564 flag1565 flag1566 flag1567 flag1568 flag1569 flag1570 flag1571 flag1572 flag1573 flag1574 flag1575 flag1576 flag1577 flag1578 flag1579 flag1580 flag1581 flag1582 flag1583 flag1584 flag1585 flag1586 flag1587 flag1588 flag1589 flag1590 flag1591 flag1592 flag1593 flag1594 flag1595 flag1596 flag1597 flag1598 flag1599 flag1600 flag1601 flag1602 flag1603 flag1604 flag1605 flag1606 flag1607 flag1608 flag1609 flag1610 flag1611 flag1612 flag1613 flag1614 flag1615 flag1616 flag1617 flag1618 flag1619 flag1620 flag1621 flag1622 flag1623 flag1624 flag1625 flag1626 flag1627 flag1628 flag1629 flag1630 flag1631 flag1632 flag1633 flag1634 flag1635 flag1636 flag1637 flag1638 flag1639 flag1640 flag1641 flag1642 flag1643 flag1644 flag1645 flag1646 flag1647 flag1648 flag1649 flag1650 flag1651 flag1652 flag1653 flag1654 flag1655 flag1656 flag1657 flag1658 flag1659 flag1660 flag1661 flag1662 flag1663 flag1664 flag1665 flag1666 flag1667 flag1668 flag1669 flag1670 flag1671 flag1672 flag1673 flag1674 flag1675 flag1676 flag1677 flag1678 flag1679 flag1680 flag1681 flag1682 flag1683 flag1684 flag1685 flag1686 flag1687 flag1688 flag1689 flag1690 flag1691 flag1692 flag1693 flag1694 flag1695 flag1696 flag1697 flag1698 flag1699 flag1700 flag1701 flag1702 flag1703 flag1704 flag1705 flag1706 flag1707 flag1708 flag1709 flag1710 flag1711 flag1712 flag1713 flag1714 flag1715 flag1716 flag1717 flag1718 flag1719 flag1720 flag1721 flag1722 flag1723 flag1724 flag1725 flag1726 flag1727 flag1728 flag1729 flag1730 flag1731 flag1732 flag1733 flag1734 flag1735 flag1736 flag1737 flag1738 flag1739 flag1740 flag1741 flag1742 flag1743 flag1744 flag1745 flag1746 flag1747 flag1748 flag1749 flag1750 flag1751 flag1752 flag1753 flag1754 flag1755 flag1756 flag1757 flag1758 flag1759 flag1760 flag1761 flag1762 flag1763 flag1764 flag1765 flag1766 flag1767 flag1768 flag1769 flag1770 flag1771 flag1772 flag1773 flag1774 flag1775 flag1776 flag1777 flag1778 flag1779 flag1780 flag1781 flag1782 flag1783 flag1784 flag1785 flag1786 flag1787 flag1788 flag1789 flag1790 flag1791 flag1792 flag1793 flag1794 flag1795 flag1796 flag1797 flag1798 flag1799 flag1800 flag1801 flag1802 flag1803 flag1804 flag1805 flag1806 flag1807 flag1808 flag1809 flag1810 flag1811 flag1812 flag1813 flag1814 flag1815 flag1816 flag1817 flag1818 flag1819 flag1820 flag1821 flag1822 flag1823 flag1824 flag1825 flag1826 flag1827 flag1828 flag1829 flag1830 flag1831 flag1832 flag1833 flag1834 flag1835 flag1836 flag1837 flag1838 flag1839 flag1840 flag1841 flag1842 flag1843 flag1844 flag1845 flag1846 flag1847 flag1848 flag1849 flag1850 flag1851 flag1852 flag1853 flag1854 flag1855 flag1856 flag1857 flag1858 flag1859 flag1860 flag1861 flag1862 flag1863 flag1864 flag1865 flag1866 flag1867 flag1868 flag1869 flag1870 flag1871 flag1872 flag1873 flag1874 non_numeric_hsym1t non_numeric_etime non_numeric_tropt non_numeric_ecgt non_numeric_reperft non_numeric_aspt non_numeric_warft non_numeric_hept non_numeric_heplmwt non_numeric_plat non_numeric_statt non_numeric_fibrt non_numeric_acet non_numeric_arbst non_numeric_corst non_numeric_antiht non_numeric_nimot non_numeric_antist non_numeric_tedt non_numeric_betat non_numeric_bivalt non_numeric_dist non_numeric_tod dlcyr cfdodyr sd_dob edateyr flagdate sd_currentdate fmcdate_text fmcdatetime2 dae_text daetae2 daedis_text daetaedis2 doh_text dohtoh2 ambcalld_text ambcalldt2 atscnd_text atscndt2 frmscnd_text frmscndt2 hospd_text hospdt2 hsym1d_text hsym1dt2 edate_text eventdt2 tropd_text tropdt2 ecgd_text ecgdt2 reperfd_text reperfdt2 aspd_text aspdt2 warfd_text warfdt2 hepd_text hepdt2 heplmwd_text heplmwdt2 plad_text pladt2 statd_text statdt2 fibrd_text fibrdt2 aced_text acedt2 arbsd_text arbsdt2 corsd_text corsdt2 antihd_text antihdt2 nimod_text nimodt2 antisd_text antisdt2 tedd_text teddt2 betad_text betadt2 bivald_text bivaldt2 disd_text disdt2 dod_text dodtod2 sd_dcyear dd_cleaned dd_duprec dd_elecmatch dd_redcap_event_name dd_event dd_recstatdc dup link_id unique_id redcap_event_name redcap_repeat_instrument redcap_repeat_instance redcap_data_access_group cfadmyr sd_record_id

** Re-label variables as some have long labels due to export format from REDCap into Stata 
//JC 14mar2023: after starting relabelling, I now realize I need to relabel only those wherein the label has not fully exported or needs clarifying as there are a large number of variables
label var dd_deathid "Death Data: Unique ID"
label var dd_fname "Death Data: First Name"
label var dd_lname "Death Data: Last Name(s)"
label var dd_dob "Death Data: DOB"
label var dd_natregno "Death Data: NRN (string)"
label var dd_dod "Death Data: Date of Death"
label var dd_coddeath "Death Data: All/Combined CODs"
label var dd_pname "Death Data: Deceased's Name"
label var dd_age "Death Data: Age"
label var dd_mname "Death Data: Middle Name(s)"
label var dd_regnum "Death Data: Registry Dept #"
label var dd_nrn "Death Data: NRN (numeric)"
label var dd_sex "Death Data: Sex"
label var dd_heart "Death Data: Eligible Heart COD"
label var dd_stroke "Death Data: Eligible Stroke COD"
label var dd_cod1a "Death Data: COD1a"
label var dd_address "Death Data: Deceased's Address"
label var dd_parish "Death Data: Deceased's Parish"
label var dd_pod "Death Data: Place of Death (numeric)"
label var dd_namematch "Death Data: Name Match"
label var dd_dddoa "Death Data: Abstraction DateTime"
label var dd_ddda "Death Data: Abstractor"
label var dd_odda "Death Data: Other Abstractor"
label var dd_certtype "Death Data: Certificate Type"
label var dd_district "Death Data: Certificate District"
label var dd_agetxt "Death Data: Age Descriptor"
label var dd_nrnnd "Death Data: Is NRN documented?"
label var dd_mstatus "Death Data: Marital Status"
label var dd_occu "Death Data: Occupation"
label var dd_durationnum "Death Data: Duration of Illness"
label var dd_durationtxt "Death Data: Duration Descriptor"
label var dd_onsetnumcod1a "Death Data: Onset Death Interval-COD1a"
label var dd_onsettxtcod1a "Death Data: Onset Descriptor-COD1a"
label var dd_cod1b "Death Data: COD1b"
label var dd_onsetnumcod1b "Death Data: Onset Death Interval-COD1b"
label var dd_onsettxtcod1b "Death Data: Onset Descriptor-COD1b"
label var dd_cod1c "Death Data: COD1c"
label var dd_onsetnumcod1c "Death Data: Onset Death Interval-COD1c"
label var dd_onsettxtcod1c "Death Data: Onset Descriptor-COD1c"
label var dd_cod1d "Death Data: COD1d"
label var dd_onsetnumcod1d "Death Data: Onset Death Interval-COD1d"
label var dd_onsettxtcod1d "Death Data: Onset Descriptor-COD1d"
label var dd_cod2a "Death Data: COD2a"
label var dd_onsetnumcod2a "Death Data: Onset Death Interval-COD2a"
label var dd_onsettxtcod2a "Death Data: Onset Descriptor-COD2a"
label var dd_cod2b "Death Data: COD2b"
label var dd_onsetnumcod2b "Death Data: Onset Death Interval-COD2b"
label var dd_onsettxtcod2b "Death Data: Onset Descriptor-COD2b"
label var dd_deathparish "Death Data: Parish Where Person Died"
label var dd_regdate "Death Data: Date of Registration"
label var dd_certifier "Death Data: Name of Certifier"
label var dd_certifieraddr "Death Data: Address of Certifier"
label var dd_codheart "Death Data: COD category-Heart"
label var dd_codstroke "Death Data: COD category-Stroke"
label var dd_dodyear "Death Data: Year of Death"
label var dd_placeofdeath "Death Data: Place of Death (string)"
label var record_id "Incidence Data: Unique ID"
label var sd_etype "Stata Derived: Event Type"
label var cfadmdate "Incidence Data: Date of Admission (hospital)/Visit (community)"
label var dlc "Incidence Data: Date at Last Known Contact"
label var cfcods "Incidence Data: CODs at Casefinding"
label var cfage "Incidence Data: Age at Casefinding (autocalculated)"
label var fname "Incidence Data: First Name"
label var lname "Incidence Data: Last Name(s)"
label var cfdoa "Incidence Data: Casefinding (CF) Date"
label var cfdoat "Incidence Data: CF Time"
label var cfda "Incidence Data: CF Data Abstractor"
label var sri "Incidence Data: CF Both Event Types"
label var srirec "Incidence Data: CF Both Event Record ID"
label var evolution "Incidence Data: Stroke-in-Evolution"
label var sourcetype "Incidence Data: CF Source Type"
label var firstnf "Incidence Data: First Notification Source"
label var cfsource___1 "Incidence Data: CF Source-A1"
label var cfsource___2 "Incidence Data: CF Source-A2"
label var cfsource___3 "Incidence Data: CF Source-A3/HDU"
label var cfsource___4 "Incidence Data: CF Source-A5"
label var cfsource___5 "Incidence Data: CF Source-A6"
label var cfsource___6 "Incidence Data: CF Source-MICU"
label var cfsource___7 "Incidence Data: CF Source-SICU"
label var cfsource___8 "Incidence Data: CF Source-B5"
label var cfsource___9 "Incidence Data: CF Source-B6"
label var cfsource___10 "Incidence Data: CF Source-B7"
label var cfsource___11 "Incidence Data: CF Source-B8"
label var cfsource___12 "Incidence Data: CF Source-C5"
label var cfsource___13 "Incidence Data: CF Source-C6"
label var cfsource___14 "Incidence Data: CF Source-C7/PICU"
label var cfsource___15 "Incidence Data: CF Source-C9"
label var cfsource___16 "Incidence Data: CF Source-C9"
label var cfsource___17 "Incidence Data: CF Source-C10/Stroke Unit"
label var cfsource___18 "Incidence Data: CF Source-12"
label var cfsource___19 "Incidence Data: CF Source-Cardiac Unit"
label var cfsource___20 "Incidence Data: CF Source-Med Rec"
label var cfsource___21 "Incidence Data: CF Source-Death Rec"
label var cfsource___22 "Incidence Data: CF Source-A&E"
label var cfsource___23 "Incidence Data: CF Source-Bay View hospital"
label var cfsource___24 "Incidence Data: CF Source-Sparman Clinic (4H)"
label var cfsource___25 "Incidence Data: CF Source-Polyclinic"
label var cfsource___26 "Incidence Data: CF Source-Private Physician"
label var cfsource___27 "Incidence Data: CF Source-Emergency Clinic(SCMC,FMH,CMC,etc)"
label var cfsource___28 "Incidence Data: CF Source-Nursing Home"
label var cfsource___29 "Incidence Data: CF Source-District Hospital"
label var cfsource___30 "Incidence Data: CF Source-Geriatric Hospital"
label var cfsource___31 "Incidence Data: CF Source-Psychiatric Hospital"
label var cfsource___32 "Incidence Data: CF Source-Member of Public"
label var cfsource___33 "Incidence Data: CF Source-MedData"
label var retsource "Incidence Data: Retrieval Source/Current Location of Patient Notes (Ward/Dept/Clinic)"
label var oretsrce "Incidence Data: Other Retrieval Source"
label var mname "Incidence Data: Middle Name(s)"
label var sex "Incidence Data: Sex"
label var dob "Incidence Data: Date of Birth"
label var cfage_da "Incidence Data: Age at Casefinding (entered by DA)"
label var natregno "Incidence Data: NRN (numeric)"
label var sd_natregno "Incidence Data: NRN (string)"
label var recnum "Incidence Data: Hospital/Patient Notes #"
label var ineligible "Incidence Data: Case Status-Ineligible"
label var initialdx "Incidence Data: CF Initial Diagnosis"
label var finaldx "Incidence Data: CF Final Diagnosis"
label var duprec "Incidence Data: Duplicate Record ID"
label var hstatus "Incidence Data: Hospital Status"
label var slc "Incidence Data: Vital Status at Last Known Contact"
label var cfdod "Incidence Data: CF Date of Death"
label var docname "Incidence Data: CF Doctor's full name(s)"
label var docaddr "Incidence Data: CF Doctor's address incl. clinic name + parish"
label var cstatus "Incidence Data: CF Case Status"
label var eligible "Incidence Data: Case Status-Eligible"
label var pendrv "Incidence Data: Case Status-Pending Review"
label var duplicate "Incidence Data: Duplicate Status"
label var dupcheck "Incidence Data: Duplicate checked?"
label var requestdate1 "Incidence Data: Date Notes Requested 1"
label var requestdate2 "Incidence Data: Date Notes Requested 2"
label var requestdate3 "Incidence Data: Date Notes Requested 3"
label var nfdb "Incidence Data: Was this record from NFdb?"
label var nfdbrec "Incidence Data: NFdb Record ID"
label var reabsrec "Incidence Data: Which Record ID are you reabstracting?"
label var toabs "Incidence Data: Do you want to abstract this case?"
label var casefinding_complete "Incidence Data: CF form status"
label var adoa "Incidence Data: DEMO Abstraction Date"
label var adoat "Incidence Data: DEMO Abstraction Time"
label var ada "Incidence Data: DEMO Data Abstractor"
label var mstatus "Incidence Data: Marital Status"
label var resident "Incidence Data: Residency Status"
label var citizen "Incidence Data: Citizenship Status"
label var addr "Incidence Data: Patient's Address"
label var parish "Incidence Data: Patient's Parish"
label var hometel "Incidence Data: Home Tel. #"
label var worktel "Incidence Data: Work Tel. #"
label var celltel "Incidence Data: Cell Tel. #"
label var demographics_complete "Incidence Data: DEMO form status"
label var ptmdoa "Incidence Data: PTM Abstraction Date"
label var ptmdoat "Incidence Data: PTM Abstraction Time"
label var ptmda "Incidence Data: PTM Data Abstractor"
label var fmc "Incidence Data: First Medical Contact?"
label var fmcplace "Incidence Data: Place of First Medical Contact"
label var ofmcplace "Incidence Data: Other First Medical Contact"
label var fmcdate "Incidence Data: Visit Date (FMC)"
label var fmctime "Incidence Data: Visit Time (FMC)"
label var hospital "Incidence Data: Name of Hospital"
label var aeadmit "Incidence Data: Patient seen in A&E?"
label var dae "Incidence Data: Admission Date (A&E)"
label var tae "Incidence Data: Admission Time (A&E)"
label var daedis "Incidence Data: Discharge Date (A&E)"
label var taedis "Incidence Data: Discharge Time (A&E)"
label var wardadmit "Incidence Data: Patient admitted to Ward?"
label var doh "Incidence Data: Admission Date (Ward)"
label var toh "Incidence Data: Admission Time (Ward)"
label var arrivalmode "Incidence Data: Mode of Arrival to Hospital"
label var ambcalld "Incidence Data: Date Ambulance NOTIFIED"
label var ambcallt "Incidence Data: Time Ambulance NOTIFIED"
label var atscnd "Incidence Data: Date Ambulance AT SCENE"
label var atscnt "Incidence Data: Time Ambulance AT SCENE"
label var frmscnd "Incidence Data: Date Ambulance FROM SCENE"
label var frmscnt "Incidence Data: Time Ambulance FROM SCENE"
label var hospd "Incidence Data: Date Ambulance AT HOSPITAL"
label var hospt "Incidence Data: Time Ambulance AT HOSPITAL"
label var ward___1 "Incidence Data: Patient treated in ICU/HDU"
label var ward___2 "Incidence Data: Patient treated in A&E"
label var ward___3 "Incidence Data: Patient treated on Medical Ward(s)"
label var ward___4 "Incidence Data: Patient treated on Stroke Unit"
label var ward___5 "Incidence Data: Patient treated on Cardiac Unit"
label var ward___98 "Incidence Data: Patient treated on Other dept/unit/ward(s)"
label var nohosp___1 "Incidence Data: Patient in community managed at Private Physician"
label var nohosp___2 "Incidence Data: Patient in community managed Overseas"
label var nohosp___3 "Incidence Data: Patient in community managed at Nursing Home"
label var nohosp___4 "Incidence Data: Patient in community Medically unattended"
label var nohosp___5 "Incidence Data: Patient in community managed at Home by doc/nurse"
label var nohosp___6 "Incidence Data: Patient in community managed at District/Geriatric Hospital"
label var nohosp___98 "Incidence Data: Patient in community managed in Other way"
label var nohosp___99 "Incidence Data: Patient in community managed is Not Documented"
label var patient_management_complete "Incidence Data: PTM form status"
label var edoa "Incidence Data: EVENT Abstraction Date"
label var edoat "Incidence Data: EVENT Abstraction Time"
label var eda "Incidence Data: EVENT Data Abstractor"
label var sign4 "Incidence Data: Had swallow screen by healthcare before oral intake + within 24h?"
label var reviewer___1 "Incidence Data: Event reviewed by Clinical Director"
label var reviewer___2 "Incidence Data: Event reviewed by Registrar"
label var reviewer___3 "Incidence Data: Event reviewed by Principal Investigator"
label var cardiac "Incidence Data: Had cardiac arrest before hospitalisation for this event?"
label var resus "Incidence Data: Patient have cardiac resuscitation (CPR)?"
label var event_complete "Incidence Data: EVENT form status"
label var hxdoa "Incidence Data: HISTORY Abstraction Date"
label var hxdoat "Incidence Data: HISTORY Abstraction Time"
label var hxda "Incidence Data: HISTORY Data Abstractor"
label var dbchecked "Incidence Data: Checked database/datasets for previous stroke/heart events?"
label var history_complete "Incidence Data: HISTORY form status"
label var tdoa "Incidence Data: TESTS Abstraction Date"
label var tdoat "Incidence Data: TESTS Abstraction Time"
label var tda "Incidence Data: TESTS Data Abstractor"
label var assess14 "Incidence Data: Cognitive Impairment Screening"
label var tests_complete "Incidence Data: TESTS form status"
label var dxdoa "Incidence Data: COMPLICATIONS Abstraction Date"
label var dxdoat "Incidence Data: COMPLICATIONS Abstraction Time"
label var dxda "Incidence Data: COMPLICATIONS Data Abstractor"
label var hcomp "Incidence Data: Any complications during hospitalisation at abstraction?"
label var absdxs___1 "Incidence Data: Stroke Abstraction Diagnosis-Ischaemic Stroke"
label var absdxs___2 "Incidence Data: Stroke Abstraction Diagnosis-Intracerebral Haemorrhage"
label var absdxs___3 "Incidence Data: Stroke Abstraction Diagnosis-Subarachnoid Haemorrhage"
label var absdxs___4 "Incidence Data: Stroke Abstraction Diagnosis-Unclassified Type"
label var absdxs___5 "Incidence Data: Stroke Abstraction Diagnosis-CVA"
label var absdxs___6 "Incidence Data: Stroke Abstraction Diagnosis-R/o query (?)CVA"
label var absdxs___7 "Incidence Data: Stroke Abstraction Diagnosis-TIA"
label var absdxs___8 "Incidence Data: Stroke Abstraction Diagnosis-R/o query (?)TIA"
label var absdxs___99 "Incidence Data: Stroke Abstraction Diagnosis-Not Documented"
label var absdxh___1 "Incidence Data: Heart Abstraction Diagnosis-STEMI"
label var absdxh___2 "Incidence Data: Heart Abstraction Diagnosis-NSTEMI"
label var absdxh___3 "Incidence Data: Heart Abstraction Diagnosis-AMI (definite)"
label var absdxh___4 "Incidence Data: Heart Abstraction Diagnosis-R/o query (?)AMI"
label var absdxh___5 "Incidence Data: Heart Abstraction Diagnosis-ACS"
label var absdxh___6 "Incidence Data: Heart Abstraction Diagnosis-R/o query (?)ACS"
label var absdxh___7 "Incidence Data: Heart Abstraction Diagnosis-Unstable Angina"
label var absdxh___8 "Incidence Data: Heart Abstraction Diagnosis-Chest pain ?cause"
label var absdxh___9 "Incidence Data: Heart Abstraction Diagnosis-LBBB (new onset)"
label var absdxh___10 "Incidence Data: Heart Abstraction Diagnosis-Sudden cardiac death"
label var absdxh___99 "Incidence Data: Heart Abstraction Diagnosis-Not Documented"
label var complications_dx_complete "Incidence Data: COMPLICATIONS form status"
label var rxdoa "Incidence Data: MEDICATIONS Abstraction Date"
label var rxdoat "Incidence Data: MEDICATIONS Abstraction Time"
label var rxda "Incidence Data: MEDICATIONS Data Abstractor"
label var asp___1 "Aspirin (Acute use)"
label var asp___2 "Aspirin (Chronic use)"
label var asp___3 "Aspirin (Contraindications)"
label var asp___99 "Aspirin (No record of use)"
label var warf___1 "Warfarin (Acute use)"
label var warf___2 "Warfarin (Chronic use)"
label var warf___3 "Warfarin (Contraindications)"
label var warf___99 "Warfarin (No record of use)"
label var warf___99999 "Warfarin (Unanswered by DA)"
label var hep___1 "Heparin (sc/iv) (UFH-Unfractionated Heparin) (Acute use)"
label var hep___2 "Heparin (sc/iv) (UFH-Unfractionated Heparin) (Chronic use)"
label var hep___3 "Heparin (sc/iv) (UFH-Unfractionated Heparin) (Contraindications)"
label var hep___99 "Heparin (sc/iv) (UFH-Unfractionated Heparin) (No record of use)"
label var hep___99999 "Heparin (sc/iv) (UFH-Unfractionated Heparin) (Unanswered by DA)"
label var heplmw___1 "Heparin (LMWH-Low molecular weight heparin) (Acute use)"
label var heplmw___2 "Heparin (LMWH-Low molecular weight heparin) (Chronic use)"
label var heplmw___3 "Heparin (LMWH-Low molecular weight heparin) (Contraindications)"
label var heplmw___99 "Heparin (LMWH-Low molecular weight heparin) (No record of use)"
label var heplmw___99999 "Heparin (LMWH-Low molecular weight heparin) (Unanswered by DA)"
label var pla___1 "Antiplatelet agents (Acute use)"
label var pla___2 "Antiplatelet agents (Chronic use)"
label var pla___3 "Antiplatelet agents (Contraindications)"
label var pla___99 "Antiplatelet agents (No record of use)"
label var pla___99999 "Antiplatelet agents (Unanswered by DA)"
label var stat___1 "Statin (Acute use)"
label var stat___2 "Statin (Chronic use)"
label var stat___3 "Statin (Contraindications)"
label var stat___99 "Statin (No record of use)"
label var stat___99999 "Statin (Unanswered by DA)"
label var fibr___1 "Fibrinolytic agents (Acute use)"
label var fibr___2 "Fibrinolytic agents (Chronic use)"
label var fibr___3 "Fibrinolytic agents (Contraindications)"
label var fibr___99 "Fibrinolytic agents (No record of use)"
label var fibr___99999 "Fibrinolytic agents (Unanswered by DA)"
label var ace___1 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Acute use)"
label var ace___2 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Chronic use)"
label var ace___3 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Contraindications)"
label var ace___99 "Angiotensin-Converting Enzyme (ACE) Inhibitors (No record of use)"
label var ace___99999 "Angiotensin-Converting Enzyme (ACE) Inhibitors (Unanswered by DA)"
label var arbs___1 "Angiotensin II Receptor Blockers (ARBs) (Acute use)"
label var arbs___2 "Angiotensin II Receptor Blockers (ARBs) (Chronic use)"
label var arbs___3 "Angiotensin II Receptor Blockers (ARBs) (Contraindications)"
label var arbs___99 "Angiotensin II Receptor Blockers (ARBs) (No record of use)"
label var arbs___99999 "Angiotensin II Receptor Blockers (ARBs) (Unanswered by DA)"
label var cors___1 "Corticosteroids (Acute use)"
label var cors___2 "Corticosteroids (Chronic use)"
label var cors___3 "Corticosteroids (Contraindications)"
label var cors___99 "Corticosteroids (No record of use)"
label var cors___99999 "Corticosteroids (Unanswered by DA)"
label var antih___1 "Antihypertensives (Acute use)"
label var antih___2 "Antihypertensives (Chronic use)"
label var antih___3 "Antihypertensives (Contraindications)"
label var antih___99 "Antihypertensives (No record of use)"
label var nimo___1 "Nimodipine (Acute use)"
label var nimo___2 "Nimodipine (Chronic use)"
label var nimo___3 "Nimodipine (Contraindications)"
label var nimo___99 "Nimodipine (No record of use)"
label var nimo___99999 "Nimodipine (Unanswered by DA)"
label var antis___1 "Antiseizures (Acute use)"
label var antis___2 "Antiseizures (Chronic use)"
label var antis___3 "Antiseizures (Contraindications)"
label var antis___99 "Antiseizures (No record of use)"
label var antis___99999 "Antiseizures (Unanswered by DA)"
label var ted___1 "TED Stockings (Acute use)"
label var ted___2 "TED Stockings (Chronic use)"
label var ted___3 "TED Stockings (Contraindications)"
label var ted___99 "TED Stockings (No record of use)"
label var ted___99999 "TED Stockings (Unanswered by DA)"
label var beta___1 "Beta Blockers (Acute use)"
label var beta___2 "Beta Blockers (Chronic use)"
label var beta___3 "Beta Blockers (Contraindications)"
label var beta___99 "Beta Blockers (No record of use)"
label var bival___1 "Bivalrudin (Acute use)"
label var bival___2 "Bivalrudin (Chronic use)"
label var bival___3 "Bivalrudin (Contraindications)"
label var bival___99 "Bivalrudin (No record of use)"
label var medications_complete "Incidence Data: MEDICATIONS form status"
label var ddoa "Incidence Data: DISCHARGE Abstraction Date"
label var ddoat "Incidence Data: DISCHARGE Abstraction Time"
label var dda "Incidence Data: DISCHARGE Data Abstractor"
label var aspdis "Aspirin prescribed at discharge"
label var warfdis "Warfarin prescribed at discharge"
label var heplmwdis "Heparin (LMWH-Low molecular weight heparin) prescribed at discharge"
label var pladis "Antiplatelet Agents prescribed at discharge"
label var statdis "Statin prescribed at discharge"
label var fibrdis "Fibrinolytic agents prescribed at discharge"
label var acedis "Angiotensin-Converting Enzyme (ACE) Inhibitors prescribed at discharge"
label var arbsdis "Angiotensin II Receptor Blockers (ARBs) prescribed at discharge"
label var corsdis "Corticosteroids prescribed at discharge"
label var antihdis "Antihypertensives prescribed at discharge"
label var nimodis "Nimodipine prescribed at discharge"
label var antisdis "Antiseizures prescribed at discharge"
label var teddis "TED Stockings prescribed at discharge"
label var betadis "Beta Blockers prescribed at discharge"
label var bivaldis "Bivalrudin prescribed at discharge"
label var dcomp "Incidence Data: Any complications during hospitalisation at discharge?"
label var disdxs___1 "Incidence Data: Stroke Discharge Diagnosis-Ischaemic Stroke"
label var disdxs___2 "Incidence Data: Stroke Discharge Diagnosis-Intracerebral Haemorrhage"
label var disdxs___3 "Incidence Data: Stroke Discharge Diagnosis-Subarachnoid Haemorrhage"
label var disdxs___4 "Incidence Data: Stroke Discharge Diagnosis-Unclassified Type"
label var disdxs___5 "Incidence Data: Stroke Discharge Diagnosis-CVA"
label var disdxs___6 "Incidence Data: Stroke Discharge Diagnosis-R/o query (?)CVA"
label var disdxs___7 "Incidence Data: Stroke Discharge Diagnosis-TIA"
label var disdxs___8 "Incidence Data: Stroke Discharge Diagnosis-R/o query (?)TIA"
label var disdxs___99 "Incidence Data: Stroke Discharge Diagnosis-Not Documented"
label var disdxh___1 "Incidence Data: Heart Discharge Diagnosis-STEMI"
label var disdxh___2 "Incidence Data: Heart Discharge Diagnosis-NSTEMI"
label var disdxh___3 "Incidence Data: Heart Discharge Diagnosis-AMI (definite)"
label var disdxh___4 "Incidence Data: Heart Discharge Diagnosis-R/o query (?)AMI"
label var disdxh___5 "Incidence Data: Heart Discharge Diagnosis-ACS"
label var disdxh___6 "Incidence Data: Heart Discharge Diagnosis-R/o query (?)ACS"
label var disdxh___7 "Incidence Data: Heart Discharge Diagnosis-Unstable Angina"
label var disdxh___8 "Incidence Data: Heart Discharge Diagnosis-Chest pain ?cause"
label var disdxh___9 "Incidence Data: Heart Discharge Diagnosis-LBBB (new onset)"
label var disdxh___10 "Incidence Data: Heart Discharge Diagnosis-Sudden cardiac death"
label var disdxh___99 "Incidence Data: Heart Discharge Diagnosis-Not Documented"
label var recdxs___1 "Incidence Data: Stroke Reclassified Diagnosis-Ischaemic Stroke"
label var recdxs___2 "Incidence Data: Stroke Reclassified Diagnosis-Intracerebral Haemorrhage"
label var recdxs___3 "Incidence Data: Stroke Reclassified Diagnosis-Subarachnoid Haemorrhage"
label var recdxs___4 "Incidence Data: Stroke Reclassified Diagnosis-Unclassified Type"
label var recdxs___5 "Incidence Data: Stroke Reclassified Diagnosis-CVA"
label var recdxs___6 "Incidence Data: Stroke Reclassified Diagnosis-R/o query (?)CVA"
label var recdxs___7 "Incidence Data: Stroke Reclassified Diagnosis-TIA"
label var recdxs___8 "Incidence Data: Stroke Reclassified Diagnosis-R/o query (?)TIA"
label var recdxs___99 "Incidence Data: Stroke Reclassified Diagnosis-Not Documented"
label var recdxh___1 "Incidence Data: Heart Reclassified Diagnosis-STEMI"
label var recdxh___2 "Incidence Data: Heart Reclassified Diagnosis-NSTEMI"
label var recdxh___3 "Incidence Data: Heart Reclassified Diagnosis-AMI (definite)"
label var recdxh___4 "Incidence Data: Heart Reclassified Diagnosis-R/o query (?)AMI"
label var recdxh___5 "Incidence Data: Heart Reclassified Diagnosis-ACS"
label var recdxh___6 "Incidence Data: Heart Reclassified Diagnosis-R/o query (?)ACS"
label var recdxh___7 "Incidence Data: Heart Reclassified Diagnosis-Unstable Angina"
label var recdxh___8 "Incidence Data: Heart Reclassified Diagnosis-Chest pain ?cause"
label var recdxh___9 "Incidence Data: Heart Reclassified Diagnosis-LBBB (new onset)"
label var recdxh___10 "Incidence Data: Heart Reclassified Diagnosis-Sudden cardiac death"
label var recdxh___99 "Incidence Data: Heart Reclassified Diagnosis-Not Documented"
label var orecdx "Other reclassified diagnosis(s) - How many (other than above) are documented?"
label var readmit "Patient re-admitted to hospital for EVENT within 28 days after this discharge?"
label var discharge_complete "Incidence Data: DISCHARGE form status"
label var fu1oday "Please specify other reason F/U interview not possible"
label var furesident "Of the last 12 months, how long have you been resident in Barbados?"
label var mainwork "Over the last 12 months, which best describes your (their) main work status?"
label var rankin2 "2) Able to look after yourself (themselves) and carry out all normal activities?"
label var f1rankin2 "2) Able to look after yourself (themselves) and carry out all normal activities?"
label var day_fu_complete "Incidence Data: F/U form status"
label var sd_multiadm "Stata Derived: Patient with Multiple Admissions"
label var sd_casetype "Stata Derived: Event taken from CVD database or death data?"
label var sd_bothevent "Stata Derived: Patient with Both Stroke + AMI"
label var sd_multievent "Stata Derived: Patient with Multiple Events of Stroke or AMI"
rename comments sd_comments
label var sd_comments "Stata Derived: Analyst's Comments"
label var sd_fmcdatetime "Stata Derived: DateTime of FIRST MEDICAL CONTACT"
label var sd_daetae "Stata Derived: DateTime Admitted to A&E"
label var sd_daetaedis "Stata Derived: DateTime Discharged from A&E"
label var sd_dohtoh "Stata Derived: DateTime Admitted to Ward"
label var sd_ambcalldt "Stata Derived: DateTime Ambulance NOTIFIED"
label var sd_atscndt "Stata Derived: DateTime Ambulance AT SCENE"
label var sd_frmscndt "Stata Derived: DateTime Ambulance FROM SCENE"
label var sd_hospdt "Stata Derived: DateTime Ambulance AT HOSPITAL"
label var sd_hsym1dt "Stata Derived: DateTime of Chest Pain"
label var sd_eventdt "Stata Derived: DateTime of Event"
label var sd_tropdt "Stata Derived: DateTime of Troponin"
label var sd_ecgdt "Stata Derived: DateTime of ECG"
label var sd_reperfdt "Stata Derived: DateTime of Reperfusion"
label var sd_aspdt "Stata Derived: DateTime of Aspirin"
label var sd_warfdt "Stata Derived: DateTime of Warfarin"
label var sd_hepdt "Stata Derived: DateTime of Heparin (ufh-sc/iv)"
label var sd_heplmwdt "Stata Derived: DateTime of Heparin (lmw)"
label var sd_pladt "Stata Derived: DateTime of Antiplatelet Agents"
label var sd_statdt "Stata Derived: DateTime of Statin"
label var sd_fibrdt "Stata Derived: DateTime of Fibrinolytic Agents"
label var sd_acedt "Stata Derived: DateTime of Angiotensin-Converting Enzyme (ACE) Inhibitors"
label var sd_arbsdt "Stata Derived: DateTime of Angiotensin II Receptor Blockers (ARBs)"
label var sd_corsdt "Stata Derived: DateTime of Corticosteroids"
label var sd_antihdt "Stata Derived: DateTime of Antihypertensives"
label var sd_nimodt "Stata Derived: DateTime of Nimodipine"
label var sd_antisdt "Stata Derived: DateTime of Antiseizures"
label var sd_teddt "Stata Derived: DateTime of TED Stockings"
label var sd_betadt "Stata Derived: DateTime of Beta Blockers"
label var sd_bivaldt "Stata Derived: DateTime of Bivalrudin"
label var sd_disdt "Stata Derived: DateTime of Discharge on DISCHARGE form"
label var sd_dodtod "Stata Derived: DateTime of Death on DISCHARGE form"

** Create analysis variables
**********
** YEAR **
**********
gen sd_eventyear=year(edate)
label var sd_eventyear "Stata Derived: Year of Event"
***********
** AGE_5 **
***********
gen age5 = recode(age,4,9,14,19,24,29,34,39,44,49,54,59,64,69,74,79,84,200)

recode age5 4=1 9=2 14=3 19=4 24=5 29=6 34=7 39=8 44=9 49=10 54=11 59=12 64=13 /// 
                        69=14 74=15 79=16 84=17 200=18

label define age5_lab 1 "0-4" 	 2 "5-9"    3 "10-14" ///
					  4 "15-19"  5 "20-24"  6 "25-29" ///
					  7 "30-34"  8 "35-39"  9 "40-44" ///
					 10 "45-49" 11 "50-54" 12 "55-59" ///
					 13 "60-64" 14 "65-69" 15 "70-74" ///
					 16 "75-79" 17 "80-84" 18 "85 & over", modify
label values age5 age5_lab
label var age5 "Stata Derived: 5-year age bands"

sort sex age5

tab age5 ,m //none missing

************
** AGE_10 **
************
gen age_10 = recode(age5,3,5,7,9,11,13,15,17,200)
recode age_10 3=1 5=2 7=3 9=4 11=5 13=6 15=7 17=8 200=9

label define age_10_lab 1 "0-14"   2 "15-24"  3 "25-34" ///
                        4 "35-44"  5 "45-54"  6 "55-64" ///
                        7 "65-74"  8 "75-84"  9 "85 & over" , modify

label values age_10 age_10_lab
label var age_10 "Stata Derived: 10-year age bands"

sort sex age_10

tab age_10 ,m //none missing

tab sd_etype ,m
/*
      Stata |
   Derived: |
 Event Type |      Freq.     Percent        Cum.
------------+-----------------------------------
     Stroke |        690       60.26       60.26
      Heart |        455       39.74      100.00
------------+-----------------------------------
      Total |      1,145      100.00
*/
//Note: some death records had both heart and stroke CODs so need to re-assign event type when splitting datasets below

count //1145

** Create identifiable CVD dataset
label data "BNR-CVD data 2021: Identifiable Dataset (CVD-HEART+STROKE)"
notes _dta :These data prepared from BB national death register and REDCap BNRCVD_CORE database
save "`datapath'\version03\3-output\2021_prep analysis_identifiable_cvd" ,replace
note: TS This dataset is used for cross-checking identifiable data with REDCap database
note: TS This dataset includes all reportable heart and stroke incidence and death data

** Create identifiable HEART dataset
preserve
drop sri srirec evolution ssym1* ssym2* ssym3* ssym4* sign1 sign2 sign3 sign4 sonset sday swalldate swalld* cardmon nihss stype dstroke tia assess assess1 assess2 assess3 assess4 assess7 assess8 assess9 assess10 assess12 assess14 dct dmri dcerangio dcarangio dcarus ct doct doctday doctmonth doctyear stime ctfeat ctinfarct ctsubhaem ctinthaem tdhemi tvdrain huti hfall hhydro hhaemo absdxs_* cors* antih* nimo* antis* ted* duti dfall dhydro dhaemo disdxs_* recdxs_* strunit sunitadmsame astrunitd astrunitdday astrunitdmonth astrunitdyear sunitdissame dstrunitd dstrunitdday dstrunitdmonth dstrunitdyear pstrsit pstrosit rankin* f1rankin* dd_stroke sd_corsdt sd_antihdt sd_nimodt sd_antisdt sd_teddt //stroke variables
replace sd_bothevent=2 if dd_deathid==34138
replace sd_bothevent=2 if record_id=="2915"
replace sd_bothevent=1 if record_id=="3128"
replace sd_casetype=2 if record_id=="3128" //stroke is DCO
replace sd_comments="JC 14mar2023: this case was abstracted as a stroke event but heart event seen on death certificate." if record_id=="3128" //stroke is DCO
replace sd_comments="JC 14mar2023: this case was abstracted as a heart event but stroke event seen on death certificate." if record_id=="2915" //stroke is DCO
replace sd_etype=2 if dd_heart==1 & sd_etype!=2 //16 changes
drop if sd_etype!=2 //674 deleted
count //471
label data "BNR-CVD data 2021: Identifiable Dataset (HEART)"
notes _dta :These data prepared from BB national death register and REDCap BNRCVD_CORE database
save "`datapath'\version03\3-output\2021_prep analysis_identifiable_heart" ,replace
note: TS This dataset is used for cross-checking identifiable data with REDCap database
note: TS This dataset includes all reportable heart incidence and death data
restore

** Create de-identified HEART dataset
preserve
drop sri srirec evolution ssym1* ssym2* ssym3* ssym4* sign1 sign2 sign3 sign4 sonset sday swalldate swalld* cardmon nihss stype dstroke tia assess assess1 assess2 assess3 assess4 assess7 assess8 assess9 assess10 assess12 assess14 dct dmri dcerangio dcarangio dcarus ct doct doctday doctmonth doctyear stime ctfeat ctinfarct ctsubhaem ctinthaem tdhemi tvdrain huti hfall hhydro hhaemo absdxs_* cors* antih* nimo* antis* ted* duti dfall dhydro dhaemo disdxs_* recdxs_* strunit sunitadmsame astrunitd astrunitdday astrunitdmonth astrunitdyear sunitdissame dstrunitd dstrunitdday dstrunitdmonth dstrunitdyear pstrsit pstrosit rankin* f1rankin* dd_stroke sd_corsdt sd_antihdt sd_nimodt sd_antisdt sd_teddt //stroke variables
drop dd_fname dd_lname dd_dob dd_natregno dd_pname fname lname mname dob dobday dobmonth dobyear natregno sd_natregno nrnyear nrnmonth nrnday nrnnum recnum addr parish hometel worktel celltel fnamekin lnamekin sametel homekin workkin cellkin dd_mname dd_regnum dd_nrn dd_address dd_parish //identifiable variables
replace sd_bothevent=2 if dd_deathid==34138
replace sd_bothevent=2 if record_id=="2915"
replace sd_bothevent=1 if record_id=="3128"
replace sd_casetype=2 if record_id=="3128" //stroke is DCO
replace sd_comments="JC 14mar2023: this case was abstracted as a stroke event but heart event seen on death certificate." if record_id=="3128" //stroke is DCO
replace sd_comments="JC 14mar2023: this case was abstracted as a heart event but stroke event seen on death certificate." if record_id=="2915" //stroke is DCO
replace sd_etype=2 if dd_heart==1 & sd_etype!=2 //16 changes
drop if sd_etype!=2 //674 deleted
count //471
label data "BNR-CVD data 2021: De-identified Dataset (HEART)"
notes _dta :These data prepared from BB national death register and REDCap BNRCVD_CORE database
save "`datapath'\version03\3-output\2021_prep analysis_deidentified_heart" ,replace
note: TS This dataset is used for for analysis of heart incidence data
note: TS This dataset includes all reportable heart incidence and death data; excludes identifiable data
restore

** Create identifiable STROKE dataset
preserve
drop hsym1* hsym2* hsym3* hsym4* hsym5* hsym6* hsym7* timi htype cardiac cardiachosp resus sudd pihd pcabg pcorangio bpm o2sat dctcorang dstress ckmbdone astdone tropdone tropcomm tropd* tropt* tropres trop1res trop2res ecg* ischecg oecg* tppv tnippv tdefib tcpr tmech tctcorang tpacetemp tcath hccf hcpang haneur hhypo hblock hafib hcshock hinfarct hrenal hcarest absdxh* beta* bival* dccf dcpang daneur dhypo dblock dafib dcshock dinfarct drenal dcarest disdxh* recdxh* carunit cunitadmsame acarunitd* cunitdissame dcarunitd* dd_heart sd_hsym1dt sd_tropdt sd_ecgdt sd_betadt sd_bivaldt //heart variables
replace sd_bothevent=1 if dd_deathid==34138
replace sd_bothevent=1 if record_id=="2915"
replace sd_casetype=2 if record_id=="2915" //stroke is DCO
replace sd_comments="JC 14mar2023: this case was abstracted as a heart event but stroke event seen on death certificate." if record_id=="2915" //stroke is DCO
replace sd_bothevent=2 if record_id=="3128"
replace sd_comments="JC 14mar2023: this case was abstracted as a stroke event but heart event seen on death certificate." if record_id=="3128" //stroke is DCO
replace sd_bothevent=1 if dd_deathid==34602
replace sd_bothevent=1 if dd_deathid==35389
replace sd_bothevent=1 if dd_deathid==36156
replace sd_bothevent=1 if dd_deathid==36192
replace sd_bothevent=1 if dd_deathid==36438
replace sd_bothevent=1 if dd_deathid==36731
replace sd_bothevent=1 if dd_deathid==36738
replace sd_bothevent=1 if dd_deathid==37287
replace sd_etype=1 if dd_stroke==1 & sd_etype!=1 //4 changes
drop if sd_etype!=1 //451 deleted
count //694
label data "BNR-CVD data 2021: Identifiable Dataset (STROKE)"
notes _dta :These data prepared from BB national death register and REDCap BNRCVD_CORE database
save "`datapath'\version03\3-output\2021_prep analysis_identifiable_stroke" ,replace
note: TS This dataset is used for cross-checking identifiable data with REDCap database
note: TS This dataset includes all reportable stroke incidence and death data
restore

** Create de-identified STROKE dataset
preserve
drop hsym1* hsym2* hsym3* hsym4* hsym5* hsym6* hsym7* timi htype cardiac cardiachosp resus sudd pihd pcabg pcorangio bpm o2sat dctcorang dstress ckmbdone astdone tropdone tropcomm tropd* tropt* tropres trop1res trop2res ecg* ischecg oecg* tppv tnippv tdefib tcpr tmech tctcorang tpacetemp tcath hccf hcpang haneur hhypo hblock hafib hcshock hinfarct hrenal hcarest absdxh* beta* bival* dccf dcpang daneur dhypo dblock dafib dcshock dinfarct drenal dcarest disdxh* recdxh* carunit cunitadmsame acarunitd* cunitdissame dcarunitd* dd_heart sd_hsym1dt sd_tropdt sd_ecgdt sd_betadt sd_bivaldt //heart variables
drop dd_fname dd_lname dd_dob dd_natregno dd_pname fname lname mname dob dobday dobmonth dobyear natregno sd_natregno nrnyear nrnmonth nrnday nrnnum recnum addr parish hometel worktel celltel fnamekin lnamekin sametel homekin workkin cellkin dd_mname dd_regnum dd_nrn dd_address dd_parish //identifiable variables
replace sd_bothevent=1 if dd_deathid==34138
replace sd_bothevent=1 if record_id=="2915"
replace sd_casetype=2 if record_id=="2915" //stroke is DCO
replace sd_comments="JC 14mar2023: this case was abstracted as a heart event but stroke event seen on death certificate." if record_id=="2915" //stroke is DCO
replace sd_bothevent=2 if record_id=="3128"
replace sd_comments="JC 14mar2023: this case was abstracted as a stroke event but heart event seen on death certificate." if record_id=="3128" //stroke is DCO
replace sd_bothevent=2 if dd_deathid==34602
replace sd_bothevent=2 if dd_deathid==35389
replace sd_bothevent=2 if dd_deathid==36156
replace sd_bothevent=2 if dd_deathid==36192
replace sd_bothevent=2 if dd_deathid==36438
replace sd_bothevent=2 if dd_deathid==36731
replace sd_bothevent=2 if dd_deathid==36738
replace sd_bothevent=2 if dd_deathid==37287
replace sd_etype=1 if dd_stroke==1 & sd_etype!=1 //4 changes
drop if sd_etype!=1 //451 deleted
count //694
label data "BNR-CVD data 2021: De-identified Dataset (STROKE)"
notes _dta :These data prepared from BB national death register and REDCap BNRCVD_CORE database
save "`datapath'\version03\3-output\2021_prep analysis_deidentified_stroke" ,replace
note: TS This dataset is used for for analysis of stroke incidence data
note: TS This dataset includes all reportable stroke incidence and death data; excludes identifiable data
restore