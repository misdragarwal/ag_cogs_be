SELECT
UNT.ACCOUNTUNIT AS 'branch'
, ROC.DESCRIPTION AS 'branch_entity'
,DATE(CRE.`CREATEDTIME`) AS 'trans_date'
,  COUNT(DISTINCT PAT.PATIENTID) AS 'ftd_count'
,COUNT(BILL.BILL_NO) AS 'bill_count'
FROM
RT_INDIVIDUAL_PATIENT PAT
JOIN RT_INDIVIDUAL_CORE CRE
ON CRE.ID=PAT.ID
JOIN `RT_DATA_ACCOUNT_UNIT` UNT ON PAT.ACCUNIT = UNT.ID
JOIN RT_ORGANIZATION_CORE ROC ON ROC.ORGANIZATIONNAME=UNT.ACCOUNTUNIT
LEFT JOIN
( SELECT DISTINCT BPB.BILL_NO,BPB.PATIENT_ID,DATE(BPB.BILL_DATE) AS BILL_DATE  FROM  BILL_PATIENT_BILL BPB
 JOIN BILL_SERVICE_DETAIL BSD ON BSD.BILL_ID = BPB.ID
 JOIN RT_DATA_CORE RDC ON RDC.ID = BSD.CHARGEDETAIL_ID
 JOIN RT_DATA_CHARGE RDH ON RDH.ID = RDC.PARENT_TICKET_ID
 AND DATE(BPB.BILL_DATE)= DATE_SUB(CURDATE(), INTERVAL 1 DAY) -- BETWEEN  '2018-04-01' AND '2020-03-08'
AND UPPER(RDH.CHARGE) LIKE '%CONSULTA%' AND BPB.STATUS =1
) AS BILL
ON PAT.ID = BILL.PATIENT_ID
AND DATE(BILL_DATE) = DATE(CRE.`CREATEDTIME`)
WHERE
DATE(CRE.`CREATEDTIME`)=DATE_SUB(CURDATE(), INTERVAL 1 DAY) -- BETWEEN  '2018-04-01' AND '2020-03-08'
GROUP BY
UNT.ACCOUNTUNIT
, DATE(CRE.`CREATEDTIME`)