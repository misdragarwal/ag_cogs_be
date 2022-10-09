/*
delete from revenue_report where trans_date BETWEEN DATE_SUB(DATE(NOW()),INTERVAL 1 DAY) AND DATE(NOW());
INSERT INTO revenue_report (entity,branch,trans_date,surgery,pharmacy,opticals,laboratory,consultation,others,ftd)
SELECT branch.billed_entity,billed,transaction_date,
SUM( IF( unit='SURGERY', net_amount,0) ) AS surgery,
SUM( IF( unit='PHARMACY', net_amount,0) ) AS pharmacy,  
SUM( IF( unit IN('OPTICALS','CONTACTLENS','CONTACT LENS') , net_amount ,0) ) AS opticals,
SUM( IF( unit='LABORATORY', net_amount,0 ) ) AS laboratory,
SUM( IF( unit='CONSULTATION', net_amount,0 ) ) AS consultation,
SUM( IF( unit NOT IN ('SURGERY','PHARMACY','OPTICALS','LABORATORY','CONSULTATION'), net_amount,0 ) ) AS others,
SUM(net_amount) AS ftd
FROM revenue_details det
JOIN  branches branch
ON branch.code = billed
WHERE transaction_date BETWEEN DATE_SUB(DATE(NOW()),INTERVAL 1 DAY) AND DATE(NOW())
GROUP BY billed,transaction_date ORDER BY billed;
*/ -- Commented on 2-Nov-2021

DELETE FROM revenue_report WHERE trans_date BETWEEN DATE_SUB(DATE(NOW()),INTERVAL 1 DAY) AND DATE(NOW());
INSERT INTO revenue_report (entity,branch,trans_date,surgery,pharmacy,opticals,laboratory,consultation,others,ftd)
SELECT branch.billed_entity,billed,transaction_date,
SUM( IF( unit='SURGERY', `Net_Amount_W/O_GST`,0) ) AS surgery,
SUM( IF( unit='PHARMACY', `Net_Amount_W/O_GST`,0) ) AS pharmacy,  
SUM( IF( unit IN('OPTICALS','CONTACTLENS','CONTACT LENS') , `Net_Amount_W/O_GST` ,0) ) AS opticals,
SUM( IF( unit='LABORATORY', `Net_Amount_W/O_GST`,0 ) ) AS laboratory,
SUM( IF( unit='CONSULTATION', `Net_Amount_W/O_GST`,0 ) ) AS consultation,
SUM( IF( unit NOT IN ('SURGERY','PHARMACY','OPTICALS','LABORATORY','CONSULTATION','CONTACTLENS','CONTACT LENS'), `Net_Amount_W/O_GST`,0 ) ) AS others,
SUM(`Net_Amount_W/O_GST`) AS ftd
FROM revenue_details det
JOIN  branches branch
ON branch.code = billed
WHERE transaction_date BETWEEN DATE_SUB(DATE(NOW()),INTERVAL 1 DAY) AND DATE(NOW())
GROUP BY billed,transaction_date ORDER BY billed;