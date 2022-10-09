SELECT
DATE(PATIENTBILL.BILL_DATE) AS 'trans_date',
CRE.DESCRIPTION AS 'entity',
ACCUNIT.`ACCOUNTUNIT` AS 'billed',
IF (SERVICE.SERVICE_ID LIKE ('DSAL%'),IF(ITMC.`ITMCGCATEGNAME` IN ('LENS','OPTICAL LENS'),'OPTICALS',SUBSTRING(DEPT.DEPARTMENTNAME,5,LENGTH(DEPT.DEPARTMENTNAME))),ACCHEAD.ACCOUNTHEAD) AS 'unit',
IF (SERVICE.SERVICE_ID LIKE ('DSAL%'),(SALDETAIL.QUANTITY*SALDETAIL.MRP) ,SERVICE.SERVICE_AMOUNT) - IFNULL(IF (SERVICE.SERVICE_ID LIKE ('DSAL%'),SALDETAIL.DISCOUNTAMOUNT,SERVICE.SERVICE_DISCOUNT),0) AS 'net_amount'
FROM
BILL_CREDIT_DEBIT_AUDIT AS CREDITDEBIT
INNER JOIN BILL_PATIENT_BILL AS PATIENTBILL ON PATIENTBILL.ID = CREDITDEBIT.BILL_ID
INNER JOIN RT_DATA_ACCOUNT_HEAD AS ACCHEAD ON ACCHEAD.ID = CREDITDEBIT.ACCOUNT_HEAD
INNER JOIN `RT_DATA_ACCOUNT_UNIT` AS ACCUNIT ON ACCUNIT.ID = CREDITDEBIT.`ACCOUNT_UNIT`
       INNER JOIN RT_ORGANIZATION_CORE CRE ON CRE.ID = PATIENTBILL.TENANTID
INNER JOIN BILL_SERVICE_DETAIL AS SERVICE ON SERVICE.ID = CREDITDEBIT.BILL_DETAIL_ID
LEFT JOIN RT_TICKET_DIRECTSALESDETAIL SALDETAIL ON SALDETAIL.SALESID = SERVICE.SERVICE_ID
LEFT JOIN RT_DATA_CHARGE_DETAIL AS CHARGEDETAIL ON CHARGEDETAIL.ID = SERVICE.CHARGEDETAIL_ID
LEFT JOIN RT_DATA_CORE AS CORE ON CORE.ID = CHARGEDETAIL.ID
LEFT JOIN RT_DATA_CHARGE AS CHARGE ON CHARGE.ID = CORE.PARENT_TICKET_ID
LEFT JOIN `RT_DATA_ACCOUNTSUBHEAD` SUB ON SUB.ID=CHARGE.ACCSUBHEAD
LEFT JOIN `RT_DATA_LEDGER` LED ON LED.ID=CHARGE.CHARGELEDGER
LEFT JOIN RT_INDIVIDUAL_PATIENT AS PATIENT ON PATIENTBILL.`PATIENT_ID`= PATIENT.ID
LEFT JOIN RT_INDIVIDUAL_CUSTOMER AS CUSTOMER ON CUSTOMER.ID = PATIENTBILL.CUSTOMER_ID
LEFT JOIN RT_DATA_PAYORTYPE AS PAYORTYPE ON PATIENTBILL.PAYOR_TYPE_ID = PAYORTYPE.ID
LEFT JOIN RT_DATA_ITEM ITEM ON ITEM.ID = SALDETAIL.ITEMID
LEFT JOIN RT_DATA_ITEM_CATEGORY ITMC
ON ITEM.CATEGORY = ITMC.ID
LEFT JOIN RT_DATA_TAX AS TAX ON ITEM.CGST = TAX.ID
LEFT JOIN RT_DATA_TAX AS TAX1 ON ITEM.SGST = TAX1.ID
LEFT JOIN RT_DATA_DEPARTMENT DEPT ON DEPT.ID = SALDETAIL.DEPTID
WHERE
DATE(PATIENTBILL.BILL_DATE) =DATE_SUB(CURDATE(), INTERVAL 1 DAY)
AND CREDITDEBIT.AMOUNT > 0