SELECT entity, NATIVE,SUM(QUANTITY) AS  contact_ct,SUM(NET_AMOUNT) AS contact_val FROM `revenue_details` 
WHERE -- NATIVE = 'ANN' AND
 TRANSACTION_DATE BETWEEN ? AND ?
AND  `GROUP` = 'CONTACT LENS'
GROUP BY NATIVE;