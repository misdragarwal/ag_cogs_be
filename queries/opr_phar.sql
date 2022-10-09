SELECT entity, NATIVE,COUNT(DISTINCT(billno)) AS  phar_ct,SUM(NET_AMOUNT) AS phar_val FROM `revenue_details` 
WHERE -- NATIVE = 'ANN' AND
 TRANSACTION_DATE BETWEEN ? AND ?
AND  UNIT ='PHARMACY'
GROUP BY NATIVE;