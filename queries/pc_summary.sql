SELECT branch , SUM(opening_balance) AS OPENING_BALANCE,SUM( refilled) AS refilled,SUM(SCHapproved) AS SCHapproved, SUM(Finance_approved) AS Finance_approved,
SUM(CHcancelled) AS CHcancelled,SUM(SCHcancelled) AS SCHcancelled, SUM(Finance_cancelled) AS Finance_cancelled
 ,SUM(opening_balance)+SUM( refilled) - SUM(SCHapproved) - SUM(Finance_approved) + SUM(CHcancelled) + SUM(SCHcancelled) + SUM(Finance_cancelled)  AS balance
 FROM
(
SELECT 'Opening balance' AS STATUS,branch,IFNULL(SUM(credit),0) AS opening_balance,0 AS refilled,0 AS SCHapproved,0 AS Finance_approved,
0 AS CHcancelled,0 AS SCHcancelled,0 AS Finance_cancelled,0 AS pending ,0 AS balance
 FROM pettycash WHERE branch=?
AND  (STATUS IS NULL OR STATUS =6)
AND DATE(created_date)<= '2020-11-24'
GROUP BY branch

UNION ALL
SELECT 'Refilled Amount' AS STATUS,branch,0 AS opening_balance,IFNULL(SUM(credit),0)AS refilled,0 AS SCHapproved,0 AS Finance_approved,
0 AS CHcancelled,0 AS SCHcancelled,0 AS Finance_cancelled,0 AS pending ,0 AS balance
 FROM pettycash WHERE branch=?
AND  ( STATUS =6)
AND DATE(created_date) BETWEEN ? AND ?

UNION ALL
SELECT 'SCH Approved' AS STATUS,branch,0 AS opening_balance,0 AS refilled,IFNULL(SUM(debit),0) AS SCHapproved,0 AS Finance_approved,
0 AS CHcancelled,0 AS SCHcancelled,0 AS Finance_cancelled,0 AS pending ,0 AS balance
 FROM pettycash WHERE branch=?
AND  (STATUS =2)
AND DATE(created_date) BETWEEN ? AND ?

UNION ALL
SELECT 'Finance Approved' AS STATUS,branch,0 AS opening_balance,0 AS refilled,0 AS SCHapproved,IFNULL(SUM(debit),0) AS Finance_approved,
0 AS CHcancelled,0 AS SCHcancelled,0 AS Finance_cancelled,0 AS pending ,0 AS balance
 FROM pettycash WHERE branch=?
AND  (STATUS =4)
AND DATE(created_date) BETWEEN ? AND ?


UNION ALL
SELECT 'SCH Cancelled' AS STATUS,branch,0 AS opening_balance,0 AS refilled,0 AS SCHapproved,0 AS Finance_approved,
0 AS CHcancelled,IFNULL(SUM(CREDIT),0)-IFNULL(SUM(debit),0) AS SCHcancelled,0 AS Finance_cancelled,0 AS pending ,0 AS balance
 FROM pettycash WHERE branch=?
AND  ( STATUS =3)
AND DATE(created_date) BETWEEN ? AND ?

UNION ALL
SELECT 'CH Cancelled' AS STATUS,branch,0 AS opening_balance,0 AS refilled,0 AS SCHapproved,0 AS Finance_approved,
IFNULL(SUM(CREDIT),0)-IFNULL(SUM(debit),0) AS CHcancelled,0 AS SCHcancelled,0 AS Finance_cancelled,0 AS pending ,0 AS balance
 FROM pettycash WHERE branch=?
AND  (STATUS =-1)
AND DATE(created_date) BETWEEN ? AND ?


UNION ALL
SELECT 'Finance Cancelled' AS STATUS,branch,0 AS opening_balance,0 AS refilled,0 AS SCHapproved,0 AS Finance_approved,
0 AS CHcancelled,0 AS SCHcancelled,IFNULL(SUM(CREDIT),0)-IFNULL(SUM(debit),0) AS Finance_cancelled,0 AS pending ,0 AS balance
 FROM pettycash WHERE branch=?
AND  ( STATUS =5)
AND DATE(created_date) BETWEEN ? AND ?
) AS pc
WHERE BRANCH IS NOT NULL
GROUP BY branch