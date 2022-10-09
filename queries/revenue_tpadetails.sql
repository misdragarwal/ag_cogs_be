SELECT
ENTITY,
DATE(REVENUEDATE) AS TRANSACTION_DATE,
BILLED,
PAYORTYPE,
PATIENTNAME AS PAYER_NAME,
PAYORNAME AS AGENCY_NAME,
UNIT,
GROUP1 AS 'GROUP',
SUBGROUP,
PATIENTID AS MRN,
PATIENTNAME AS PATIENT_NAME,
PATIENT_AGE,
BILLNO,
BILLID AS BILL_ID,
ITEMCODE,
ITEMNAME,
QUANTITY,
AMOUNT AS TOTAL_AMOUNT,
DISCOUNT_AMOUNT,
NET_AMOUNT,
PATIENT_AMOUNT,
PAYOR_AMOUNT,
EYE,
GENDER,
IF(TPA_CLAIM ='null',TPA_CLAIM,CONCAT("'",TPA_CLAIM)) AS TPA_CLAIM,
-- SEND_DATE,
-- ACKNOWLEDGE_DATE,
-- SUBMITTED_DATE,
-- SENT_ID,
-- ACKNOWLEDGE_ID,
-- SUBMITTED_ID,
ADDRESS
FROM
(
(SELECT
	BILL.ID AS BILLID,OCRE.DESCRIPTION AS ENTITY,
          BILLACCUNIT.ACCOUNTUNIT AS BILLED,
	CONVERT_TZ(BILL.REVENUE_DATE, '+00:00', REPLACE(TZ.GMT_ID,'GMT','')) AS REVENUEDATE,
	BILL.BILL_NO AS BILLNO,
	PATIENT.PATIENTID AS PATIENTID,
	PATIENT.PATIENTNAME AS PATIENTNAME,
	PATIENT.AGE AS PATIENT_AGE,

	ACCHEAD.ACCOUNTHEAD AS UNIT,
	 SUB.`ACCOUNTSUBHEAD`  AS 'GROUP1',
	 LED.`LEDGER` AS 'SUBGROUP',
	 CHARGE.CHARGE AS ITEMNAME,
	CHARGE.CHARGECODE AS ITEMCODE,
	DETAIL.SERVICE_AMOUNT AS AMOUNT,
	DETAIL.QUANTITY AS QUANTITY,
	DETAIL.SERVICE_DISCOUNT AS DISCOUNT_AMOUNT,
	(DETAIL.SERVICE_AMOUNT - DETAIL.SERVICE_DISCOUNT) AS NET_AMOUNT,
	DETAIL.CLAIM_AMOUNT AS PAYOR_AMOUNT,
	(DETAIL.SERVICE_AMOUNT - DETAIL.SERVICE_DISCOUNT - DETAIL.CLAIM_AMOUNT) AS PATIENT_AMOUNT,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'Self', IF(PAYORTYPE.PAYORCATEGORY ='Cash','Self',PAYORTYPE.PAYORCATEGORY)) AS PAYORTYPE,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'SELF PAYING', PAYORTYPE.PAYORTYP) AS PAYORNAME,
	BILL.TPA_CLAIM_ID AS 'TPA_CLAIM',
	RIC.GENDER AS GENDER,
	IF(ADVICEDETAIL.ADVICEDEYE IS NULL,ADVICEDETAIL.ADVICEDEYE,CONCAT(UPPER(ADVICEDETAIL.ADVICEDEYE),' EYE')) AS EYE,
	PATIENT.CONTACTADDRESS AS ADDRESS,
	'' AS SEND_DATE,
	'' AS ACKNOWLEDGE_DATE,
	'' AS SUBMITTED_DATE,
	'' AS SENT_ID,
	'' AS ACKNOWLEDGE_ID,
	'' AS SUBMITTED_ID
FROM
	BILL_PATIENT_BILL AS BILL
	JOIN RT_ORGANIZATION_CORE OCRE ON OCRE.ID = BILL.TENANTID
	INNER JOIN BILL_SERVICE_DETAIL AS DETAIL ON DETAIL.BILL_ID = BILL.ID
	AND DETAIL.PACKAGE_ID IS NULL AND DETAIL.SCREEN != 4
	INNER JOIN RT_DATA_CHARGE_DETAIL AS CHARGEDETAIL ON CHARGEDETAIL.ID = DETAIL.CHARGEDETAIL_ID
	INNER JOIN RT_DATA_CORE AS CORE ON CORE.ID = CHARGEDETAIL.ID
	INNER JOIN RT_DATA_CHARGE AS CHARGE ON CHARGE.ID = CORE.PARENT_TICKET_ID
          INNER JOIN RT_DATA_ACCOUNTSUBHEAD AS SUB ON SUB.ID = CHARGE.ACCSUBHEAD
	LEFT JOIN `RT_DATA_LEDGER` LED ON LED.ID=CHARGE.CHARGELEDGER
	INNER JOIN RT_DATA_ACCOUNT_HEAD AS ACCHEAD ON ACCHEAD.ID = CHARGE.CHARGACCOUNTHEAD
	LEFT JOIN RT_INDIVIDUAL_PATIENT AS PATIENT ON PATIENT.ID = BILL.PATIENT_ID
	LEFT JOIN RT_INDIVIDUAL_CORE AS RIC ON RIC.ID=PATIENT.ID
	LEFT JOIN RT_TICKET_DOCTOR_ADVICEDETAIL AS ADVICEDETAIL ON ADVICEDETAIL.ID=DETAIL.SERVICE_ID
	LEFT JOIN RT_DATA_PAYORTYPE AS PAYORTYPE ON BILL.PAYOR_TYPE_ID = PAYORTYPE.ID
	LEFT JOIN RT_DATA_ACCOUNT_UNIT PATACCUNIT ON PATACCUNIT.ID= IF(PATIENT.ID IS NULL,BILL.ACC_UNIT_ID  ,PATIENT.ACCUNIT )
	LEFT JOIN `RT_DATA_ACCOUNT_UNIT` AS BILLACCUNIT ON BILLACCUNIT.ID = BILL.`ACC_UNIT_ID`
	LEFT JOIN SYS_ADMIN_TIMEZONE AS TZ ON TZ.TIMEZONE_ID = IF(PATACCUNIT.STATUS != 0,PATACCUNIT.ACCUNITTIMEZONEID,BILLACCUNIT.ACCUNITTIMEZONEID)
WHERE

BILL.REVENUE_DATE BETWEEN DATE_SUB(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY) AND (DATE_ADD(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY))
AND BILL.REVENUE_DATE >=  CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND BILL.REVENUE_DATE <=  CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 23:59:59'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND (DETAIL.BILL_STATUS != 4 OR (DETAIL.CLAIM_AMOUNT>0))
AND (DETAIL.REASON != 'Deleted From Counseling Console' OR DETAIL.REASON IS NULL)
AND PAYORTYPE.PAYORCATEGORY <> 'Cash'
)
UNION ALL
(
SELECT
	BILL.ID AS BILLID,OCRE.DESCRIPTION AS ENTITY,
	BILLACCUNIT.ACCOUNTUNIT AS BILLED,
	CONVERT_TZ(CREDITDEBIT.CREATED_TIME, '+00:00', REPLACE(TZ.GMT_ID,'GMT','')) AS REVENUEDATE,
	BILL.BILL_NO AS BILLNO,
	PATIENT.PATIENTID AS PATIENTID,
	PATIENT.PATIENTNAME AS PATIENTNAME,
	PATIENT.AGE AS PATIENT_AGE,

	ACCHEAD.ACCOUNTHEAD AS UNIT,
	 SUB.`ACCOUNTSUBHEAD`  AS 'GROUP',
	 LED.`LEDGER` AS 'SUBGROUP',
	CHARGE.CHARGE AS ITEMNAME,
	CHARGE.CHARGECODE AS ITEMCODE,
	-DETAIL.SERVICE_AMOUNT AS AMOUNT,
	-DETAIL.QUANTITY AS QUANTITY,
	-DETAIL.SERVICE_DISCOUNT AS DISCOUNT_AMOUNT,
	-(DETAIL.SERVICE_AMOUNT - DETAIL.SERVICE_DISCOUNT) AS NET_AMOUNT,
	-(DETAIL.CLAIM_AMOUNT) AS PAYOR_AMOUNT,
	-(DETAIL.SERVICE_AMOUNT - DETAIL.SERVICE_DISCOUNT - DETAIL.CLAIM_AMOUNT) AS PATIENT_AMOUNT,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'Self', IF(PAYORTYPE.PAYORCATEGORY ='Cash','Self',PAYORTYPE.PAYORCATEGORY)) AS PAYORTYPE,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'SELF PAYING', PAYORTYPE.PAYORTYP) AS PAYORNAME,
	BILL.TPA_CLAIM_ID AS 'TPA_CLAIM',
	RIC.GENDER AS GENDER,
	IF(ADVICEDETAIL.ADVICEDEYE IS NULL,ADVICEDETAIL.ADVICEDEYE,CONCAT(UPPER(ADVICEDETAIL.ADVICEDEYE),' EYE')) AS EYE,
	PATIENT.CONTACTADDRESS AS ADDRESS,
	'' AS SEND_DATE,
	'' AS ACKNOWLEDGE_DATE,
	'' AS SUBMITTED_DATE,
	'' AS SENT_ID,
	'' AS ACKNOWLEDGE_ID,
	'' AS SUBMITTED_ID


FROM
	BILL_PATIENT_BILL AS BILL
	JOIN RT_ORGANIZATION_CORE OCRE ON OCRE.ID = BILL.TENANTID
	INNER JOIN BILL_SERVICE_DETAIL AS DETAIL ON DETAIL.BILL_ID = BILL.ID
	AND DETAIL.PACKAGE_ID IS NULL AND DETAIL.SCREEN != 4 -- AND DETAIL.BILL_STATUS NOT IN (4,5)
	INNER JOIN RT_DATA_CHARGE_DETAIL AS CHARGEDETAIL ON CHARGEDETAIL.ID = DETAIL.CHARGEDETAIL_ID
	INNER JOIN RT_DATA_CORE AS CORE ON CORE.ID = CHARGEDETAIL.ID
	INNER JOIN RT_DATA_CHARGE AS CHARGE ON CHARGE.ID = CORE.PARENT_TICKET_ID
          INNER JOIN RT_DATA_ACCOUNTSUBHEAD AS SUB ON SUB.ID = CHARGE.ACCSUBHEAD
	INNER JOIN RT_DATA_ACCOUNT_HEAD AS ACCHEAD ON ACCHEAD.ID = CHARGE.CHARGACCOUNTHEAD
	LEFT JOIN RT_INDIVIDUAL_PATIENT AS PATIENT ON PATIENT.ID = BILL.PATIENT_ID
	LEFT JOIN RT_INDIVIDUAL_CORE AS RIC ON RIC.ID=PATIENT.ID
	LEFT JOIN `RT_DATA_LEDGER` LED ON LED.ID=CHARGE.CHARGELEDGER
	LEFT JOIN RT_DATA_PAYORTYPE AS PAYORTYPE ON BILL.PAYOR_TYPE_ID = PAYORTYPE.ID
	LEFT JOIN RT_TICKET_DOCTOR_ADVICEDETAIL AS ADVICEDETAIL ON ADVICEDETAIL.ID=DETAIL.SERVICE_ID
	LEFT JOIN BILL_CREDIT_DEBIT_AUDIT AS CREDITDEBIT ON  CREDITDEBIT.BILL_ID = BILL.ID AND CREDITDEBIT.BILL_DETAIL_ID IS NOT NULL
	LEFT JOIN RT_DATA_ACCOUNT_UNIT PATACCUNIT ON PATACCUNIT.ID= IF(PATIENT.ID IS NULL,BILL.ACC_UNIT_ID  ,PATIENT.ACCUNIT )
	LEFT JOIN `RT_DATA_ACCOUNT_UNIT` AS BILLACCUNIT ON BILLACCUNIT.ID = BILL.`ACC_UNIT_ID`
	LEFT JOIN SYS_ADMIN_TIMEZONE AS TZ ON TZ.TIMEZONE_ID = IF(PATACCUNIT.STATUS != 0,PATACCUNIT.ACCUNITTIMEZONEID,BILLACCUNIT.ACCUNITTIMEZONEID)
WHERE


 (CREDITDEBIT.BILL_DETAIL_ID IS NULL OR CREDITDEBIT.BILL_DETAIL_ID = DETAIL.ID )
AND CREDITDEBIT.CREATED_TIME BETWEEN DATE_SUB(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY) AND (DATE_ADD(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY))
AND CREDITDEBIT.CREATED_TIME >= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND CREDITDEBIT.CREATED_TIME <= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 23:59:59'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND (BILL.REVENUE_DATE < CREDITDEBIT.CREATED_TIME)
AND CREDITDEBIT.AMOUNT < 0
AND PAYORTYPE.PAYORCATEGORY <> 'Cash'
	)
UNION ALL
(SELECT
	BILL.ID AS BILLID,OCRE.DESCRIPTION AS ENTITY,
	BILLACCUNIT.ACCOUNTUNIT AS BILLED,
	CONVERT_TZ(BILL.REVENUE_DATE, '+00:00', REPLACE(TZ.GMT_ID,'GMT','')) AS REVENUEDATE,
	BILL.BILL_NO AS BILLNO,
	PATIENT.PATIENTID AS PATIENTID,
	PATIENT.PATIENTNAME AS PATIENTNAME,
	PATIENT.AGE AS PATIENT_AGE,

	ACCHEAD.ACCOUNTHEAD AS UNIT,
	ITMC.`ITMCGCATEGNAME`  AS 'GROUP',
	ITEM.SUBCATEGORY AS 'SUBGROUP',
	ITEM.ADITMNAME AS ITEMNAME,
	ITEM.ITEMCODE AS ITEMCODE,
	CASE  WHEN BILL.REVENUE_DATE > SALESRETURNDETAIL.CREATEDTIME THEN
	DIRECTSALESDETAIL.TOTAL - SUM(SALESRETURNDETAIL.RETURNAMOUNT)
	ELSE DIRECTSALESDETAIL.TOTAL
	END AS AMOUNT,
	CASE  WHEN BILL.REVENUE_DATE > SALESRETURNDETAIL.CREATEDTIME THEN
	DIRECTSALESDETAIL.QUANTITY - SUM(SALESRETURNDETAIL.RETURNQUANTITY)
	ELSE DIRECTSALESDETAIL.QUANTITY
	END AS QUANTITY,
	IF(DIRECTSALESDETAIL.DISCOUNTAMOUNT IS NULL, 0, DIRECTSALESDETAIL.DISCOUNTAMOUNT) AS DISCOUNT_AMOUNT,
	CASE  WHEN BILL.REVENUE_DATE > SALESRETURNDETAIL.CREATEDTIME THEN
	(DIRECTSALESDETAIL.TOTAL  - IF(DIRECTSALESDETAIL.DISCOUNTAMOUNT IS NULL, 0, DIRECTSALESDETAIL.DISCOUNTAMOUNT)) - SUM(SALESRETURNDETAIL.RETURNAMOUNT)
	ELSE (DIRECTSALESDETAIL.TOTAL  - IF(DIRECTSALESDETAIL.DISCOUNTAMOUNT IS NULL, 0, DIRECTSALESDETAIL.DISCOUNTAMOUNT))
	END AS NET_AMOUNT,
	CASE  WHEN BILL.REVENUE_DATE > SALESRETURNDETAIL.CREATEDTIME THEN
	IF(DIRECTSALESDETAIL.CLAIMAMOUNT>0,IF(DIRECTSALESDETAIL.CLAIMAMOUNT IS NULL,0,DIRECTSALESDETAIL.CLAIMAMOUNT) - SUM(SALESRETURNDETAIL.RETURNAMOUNT),0)
	ELSE IF(DIRECTSALESDETAIL.CLAIMAMOUNT IS NULL,0,DIRECTSALESDETAIL.CLAIMAMOUNT)
	END AS PAYOR_AMOUNT,
	CASE  WHEN BILL.REVENUE_DATE > SALESRETURNDETAIL.CREATEDTIME THEN
	(DIRECTSALESDETAIL.TOTAL  - IF(DIRECTSALESDETAIL.DISCOUNTAMOUNT IS NULL, 0, DIRECTSALESDETAIL.DISCOUNTAMOUNT)) - SUM(SALESRETURNDETAIL.RETURNAMOUNT)-(IF(DIRECTSALESDETAIL.CLAIMAMOUNT>0,IF(DIRECTSALESDETAIL.CLAIMAMOUNT IS NULL,0,DIRECTSALESDETAIL.CLAIMAMOUNT) - SUM(SALESRETURNDETAIL.RETURNAMOUNT),0))
	ELSE (DIRECTSALESDETAIL.TOTAL  - IF(DIRECTSALESDETAIL.DISCOUNTAMOUNT IS NULL, 0, DIRECTSALESDETAIL.DISCOUNTAMOUNT)-IF(DIRECTSALESDETAIL.CLAIMAMOUNT IS NULL,0,DIRECTSALESDETAIL.CLAIMAMOUNT))
	END   AS PATIENT_AMOUNT,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'Self', IF(PAYORTYPE.PAYORCATEGORY ='Cash','Self',PAYORTYPE.PAYORCATEGORY)) AS PAYORTYPE,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'SELF PAYING', PAYORTYPE.PAYORTYP) AS PAYORNAME,
	BILL.TPA_CLAIM_ID AS 'TPA_CLAIM',
	RIC.GENDER AS GENDER,
	'' AS EYE,
	PATIENT.CONTACTADDRESS AS ADDRESS,
	'' AS SEND_DATE,
	'' AS ACKNOWLEDGE_DATE,
	'' AS SUBMITTED_DATE,
	'' AS SENT_ID,
	'' AS ACKNOWLEDGE_ID,
	'' AS SUBMITTED_ID


FROM
	BILL_PATIENT_BILL AS BILL
	JOIN RT_ORGANIZATION_CORE OCRE ON OCRE.ID = BILL.TENANTID
	INNER JOIN BILL_SERVICE_DETAIL AS DETAIL ON DETAIL.BILL_ID = BILL.ID
	AND DETAIL.SCREEN = 4
	INNER JOIN RT_DATA_CHARGE_DETAIL AS CHARGEDETAIL ON CHARGEDETAIL.ID = DETAIL.CHARGEDETAIL_ID
	INNER JOIN RT_DATA_CORE AS CORE ON CORE.ID = CHARGEDETAIL.ID
	INNER JOIN RT_DATA_CHARGE AS CHARGE ON CHARGE.ID = CORE.PARENT_TICKET_ID
	INNER JOIN RT_DATA_ACCOUNT_HEAD AS ACCHEAD ON ACCHEAD.ID = CHARGE.CHARGACCOUNTHEAD
	INNER JOIN RT_TICKET_DIRECTSALES AS DIRECTSALES ON DIRECTSALES.ID = DETAIL.SERVICE_ID
	INNER JOIN RT_TICKET_DIRECTSALESDETAIL AS DIRECTSALESDETAIL ON DIRECTSALESDETAIL.SALESID = DIRECTSALES.ID
	INNER JOIN RT_DATA_ITEM AS ITEM ON ITEM.ID = DIRECTSALESDETAIL.ITEMID
	LEFT JOIN RT_INDIVIDUAL_PATIENT AS PATIENT ON PATIENT.ID = BILL.PATIENT_ID
	LEFT JOIN RT_INDIVIDUAL_CORE AS RIC ON RIC.ID=PATIENT.ID
	LEFT JOIN RT_DATA_PAYORTYPE AS PAYORTYPE ON BILL.PAYOR_TYPE_ID = PAYORTYPE.ID
	LEFT JOIN RT_DATA_ACCOUNT_UNIT PATACCUNIT ON PATACCUNIT.ID= IF(PATIENT.ID IS NULL,BILL.ACC_UNIT_ID  ,PATIENT.ACCUNIT )
	LEFT JOIN `RT_DATA_ACCOUNT_UNIT` AS BILLACCUNIT ON BILLACCUNIT.ID = BILL.`ACC_UNIT_ID`
	LEFT JOIN RT_DATA_ITEM_CATEGORY ITMC
		ON ITEM.CATEGORY = ITMC.ID
		LEFT JOIN STORE_STOCK_DETAIL DTL
	ON DTL.ID = DIRECTSALESDETAIL.`STOCKDETAILID`
	LEFT JOIN
	(SELECT SALESDETAILID,TCORE.CREATEDTIME,SALESRETURNDETAIL.RETURNQUANTITY,SALESRETURNDETAIL.RETURNAMOUNT
	,SALESRETURNDETAIL.CLAIMAMOUNT
	FROM RT_TICKET_SALESRETURNDETAIL AS SALESRETURNDETAIL
	  JOIN RT_TICKET_CORE AS TCORE ON TCORE.ID = SALESRETURNDETAIL.ID
	) AS SALESRETURNDETAIL
	ON SALESRETURNDETAIL.SALESDETAILID = DIRECTSALESDETAIL.ID
	AND BILL.REVENUE_DATE > SALESRETURNDETAIL.CREATEDTIME
	LEFT JOIN SYS_ADMIN_TIMEZONE AS TZ ON TZ.TIMEZONE_ID = IF(PATACCUNIT.STATUS != 0,PATACCUNIT.ACCUNITTIMEZONEID,BILLACCUNIT.ACCUNITTIMEZONEID)

WHERE
	 (DIRECTSALES.WORKORDERSTATUS = 'Goods Delivered' OR DIRECTSALES.WORKORDERSTATUS IS NULL OR DIRECTSALES.WORKORDERSTATUS ='No Work Order Required'  OR DIRECTSALES.WORKORDERSTATUS ='Cancelled')
AND BILL.REVENUE_DATE BETWEEN DATE_SUB(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 2 DAY) AND (DATE_ADD(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY))
AND BILL.REVENUE_DATE >= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND BILL.REVENUE_DATE <= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 23:59:59'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND PAYORTYPE.PAYORCATEGORY <> 'Cash'
GROUP BY DIRECTSALESDETAIL.ID,SALESRETURNDETAIL.CREATEDTIME
HAVING
	QUANTITY > 0
)
UNION ALL
(SELECT
	BILL.ID AS BILLID,OCRE.DESCRIPTION AS ENTITY,
	BILLACCUNIT.ACCOUNTUNIT AS BILLED,
	CONVERT_TZ(TCORE.CREATEDTIME, '+00:00', REPLACE(TZ.GMT_ID,'GMT','')) AS REVENUEDATE,
	BILL.BILL_NO AS BILLNO,
	PATIENT.PATIENTID AS PATIENTID,
	PATIENT.PATIENTNAME AS PATIENTNAME,
	PATIENT.AGE AS PATIENT_AGE,

	ACCHEAD.ACCOUNTHEAD AS UNIT,
	ITMC.`ITMCGCATEGNAME`  AS 'GROUP',
	ITEM.SUBCATEGORY AS 'SUBGROUP',
	ITEM.ADITMNAME AS ITEMNAME,
	ITEM.ITEMCODE AS ITEMCODE,
	IF(DIRECTSALES.SALESSTATUS = 'Advance Received',-DIRECTSALESDETAIL.TOTAL,-(SALESRETURNDETAIL.RETURNAMOUNT+SALESRETURNDETAIL.TOTALDISCOUNT)) AS AMOUNT,  -- DIRECTSALESDETAIL.REFUNDAMOUNT updated as SALESRETURNDETAIL.RETURNAMOUNT
	-SALESRETURNDETAIL.RETURNQUANTITY AS QUANTITY,
	-IF(SALESRETURNDETAIL.TOTALDISCOUNT IS NULL, 0, SALESRETURNDETAIL.TOTALDISCOUNT) AS DISCOUNT_AMOUNT,
	IF(DIRECTSALES.SALESSTATUS = 'Advance Received',-(DIRECTSALESDETAIL.TOTAL-IF(DIRECTSALESDETAIL.DISCOUNTAMOUNT IS NULL, 0, DIRECTSALESDETAIL.DISCOUNTAMOUNT)),-SALESRETURNDETAIL.RETURNAMOUNT) AS NET_AMOUNT, -- DIRECTSALESDETAIL.REFUNDAMOUNT updated as SALESRETURNDETAIL.RETURNAMOUNT
	-IF(DIRECTSALESDETAIL.CLAIMAMOUNT IS NULL,0,DIRECTSALESDETAIL.CLAIMAMOUNT) AS PAYOR_AMOUNT,
	IF(DIRECTSALES.SALESSTATUS IN ('Advance Received','Bill Raised'),-(DIRECTSALESDETAIL.TOTAL-IF(DIRECTSALESDETAIL.DISCOUNTAMOUNT IS NULL, 0, DIRECTSALESDETAIL.DISCOUNTAMOUNT) - IF(DIRECTSALESDETAIL.CLAIMAMOUNT IS NULL,0,DIRECTSALESDETAIL.CLAIMAMOUNT)),-(SALESRETURNDETAIL.RETURNAMOUNT - SALESRETURNDETAIL.CLAIMAMOUNT)) AS PATIENT_AMOUNT,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'Self', IF(PAYORTYPE.PAYORCATEGORY ='Cash','Self',PAYORTYPE.PAYORCATEGORY)) AS PAYORTYPE,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'SELF PAYING', PAYORTYPE.PAYORTYP) AS PAYORNAME,
	BILL.TPA_CLAIM_ID AS 'TPA_CLAIM',
	RIC.GENDER AS GENDER,
	'' AS EYE,
	PATIENT.CONTACTADDRESS AS ADDRESS,
	'' AS SEND_DATE,
	'' AS ACKNOWLEDGE_DATE,
	'' AS SUBMITTED_DATE,
	'' AS SENT_ID,
	'' AS ACKNOWLEDGE_ID,
	'' AS SUBMITTED_ID


FROM
	BILL_PATIENT_BILL AS BILL
	JOIN RT_ORGANIZATION_CORE OCRE ON OCRE.ID = BILL.TENANTID
	INNER JOIN BILL_SERVICE_DETAIL AS DETAIL ON DETAIL.BILL_ID = BILL.ID AND DETAIL.SCREEN = 4
	INNER JOIN RT_DATA_CHARGE_DETAIL AS CHARGEDETAIL ON CHARGEDETAIL.ID = DETAIL.CHARGEDETAIL_ID
	INNER JOIN RT_DATA_CORE AS CORE ON CORE.ID = CHARGEDETAIL.ID
	INNER JOIN RT_DATA_CHARGE AS CHARGE ON CHARGE.ID = CORE.PARENT_TICKET_ID
	INNER JOIN RT_DATA_ACCOUNT_HEAD AS ACCHEAD ON ACCHEAD.ID = CHARGE.CHARGACCOUNTHEAD
	INNER JOIN RT_TICKET_DIRECTSALES AS DIRECTSALES ON DIRECTSALES.ID = DETAIL.SERVICE_ID
	INNER JOIN RT_TICKET_DIRECTSALESDETAIL AS DIRECTSALESDETAIL ON DIRECTSALESDETAIL.SALESID = DIRECTSALES.ID
	INNER JOIN RT_TICKET_SALESRETURNDETAIL AS SALESRETURNDETAIL ON SALESRETURNDETAIL.SALESDETAILID = DIRECTSALESDETAIL.ID
	INNER JOIN RT_TICKET_CORE AS TCORE ON TCORE.ID = SALESRETURNDETAIL.ID
	INNER JOIN RT_DATA_ITEM AS ITEM ON ITEM.ID = DIRECTSALESDETAIL.ITEMID
	LEFT JOIN RT_INDIVIDUAL_PATIENT AS PATIENT ON PATIENT.ID = BILL.PATIENT_ID
	LEFT JOIN RT_INDIVIDUAL_CORE AS RIC ON RIC.ID=PATIENT.ID
	LEFT JOIN RT_TICKET_VISIT AS VISIT ON VISIT.ID = BILL.VISIT_ID
	LEFT JOIN RT_DATA_PAYORTYPE AS PAYORTYPE ON BILL.PAYOR_TYPE_ID = PAYORTYPE.ID
	LEFT JOIN RT_DATA_ACCOUNT_UNIT PATACCUNIT ON PATACCUNIT.ID= IF(PATIENT.ID IS NULL,BILL.ACC_UNIT_ID  ,PATIENT.ACCUNIT )
	LEFT JOIN `RT_DATA_ACCOUNT_UNIT` AS BILLACCUNIT ON BILLACCUNIT.ID = BILL.`ACC_UNIT_ID`
	LEFT JOIN RT_DATA_ITEM_CATEGORY ITMC
	ON ITEM.CATEGORY = ITMC.ID
	LEFT JOIN STORE_STOCK_DETAIL DTL
	ON DTL.ID = DIRECTSALESDETAIL.`STOCKDETAILID`
	LEFT JOIN SYS_ADMIN_TIMEZONE AS TZ ON TZ.TIMEZONE_ID = IF(PATACCUNIT.STATUS != 0,PATACCUNIT.ACCUNITTIMEZONEID,BILLACCUNIT.ACCUNITTIMEZONEID)
WHERE

	(DIRECTSALES.WORKORDERSTATUS = 'Goods Delivered' OR DIRECTSALES.WORKORDERSTATUS IS NULL OR DIRECTSALES.WORKORDERSTATUS ='No Work Order Required' OR DIRECTSALES.WORKORDERSTATUS ='Cancelled')
AND TCORE.CREATEDTIME BETWEEN DATE_SUB(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY) AND (DATE_ADD(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY))
AND TCORE.CREATEDTIME >= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND TCORE.CREATEDTIME <= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 23:59:59'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND BILL.REVENUE_DATE IS NOT NULL
AND  BILL.REVENUE_DATE <= TCORE.CREATEDTIME
AND DIRECTSALESDETAIL.RETURNQUANTITY IS NOT NULL
AND PAYORTYPE.PAYORCATEGORY <> 'Cash'
)
UNION ALL
(
SELECT
	BILL.ID AS BILLID,OCRE.DESCRIPTION AS ENTITY,
	BILLACCUNIT.ACCOUNTUNIT AS BILLED,
	CONVERT_TZ(BILL.REVENUE_DATE, '+00:00', REPLACE(TZ.GMT_ID,'GMT','')) AS REVENUEDATE,
	BILL.BILL_NO AS BILLNO,
	PATIENT.PATIENTID AS PATIENTID,
	PATIENT.PATIENTNAME AS PATIENTNAME,
	PATIENT.AGE AS PATIENT_AGE,
	ACCHEAD.ACCOUNTHEAD AS UNIT,
	 SUB.`ACCOUNTSUBHEAD`  AS 'GROUP',
	 LED.`LEDGER` AS 'SUBGROUP',
	CHARGE.CHARGE AS ITEMNAME,
	CHARGE.CHARGECODE AS ITEMCODE,
	-DETAIL.SERVICE_AMOUNT AS AMOUNT,
	-DETAIL.QUANTITY AS QUANTITY,
	-DETAIL.SERVICE_DISCOUNT AS DISCOUNT_AMOUNT,
	-(DETAIL.SERVICE_AMOUNT - DETAIL.SERVICE_DISCOUNT) AS NET_AMOUNT,
	-(DETAIL.CLAIM_AMOUNT) AS PAYOR_AMOUNT,
	-(DETAIL.SERVICE_AMOUNT - DETAIL.SERVICE_DISCOUNT - DETAIL.CLAIM_AMOUNT) AS PATIENT_AMOUNT,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'Self', IF(PAYORTYPE.PAYORCATEGORY ='Cash','Self',PAYORTYPE.PAYORCATEGORY)) AS PAYORTYPE,
	IF(PAYORTYPE.PAYORCATEGORY IS NULL, 'SELF PAYING', PAYORTYPE.PAYORTYP) AS PAYORNAME,
	BILL.TPA_CLAIM_ID AS 'TPA_CLAIM',
	RIC.GENDER AS GENDER,
	IF(ADVICEDETAIL.ADVICEDEYE IS NULL,ADVICEDETAIL.ADVICEDEYE,CONCAT(UPPER(ADVICEDETAIL.ADVICEDEYE),' EYE')) AS EYE,
	PATIENT.CONTACTADDRESS AS ADDRESS,
	'' AS SEND_DATE,
	'' AS ACKNOWLEDGE_DATE,
	'' AS SUBMITTED_DATE,
	'' AS SENT_ID,
	'' AS ACKNOWLEDGE_ID,
	'' AS SUBMITTED_ID


FROM
	BILL_PATIENT_BILL AS BILL
	JOIN RT_ORGANIZATION_CORE OCRE ON OCRE.ID = BILL.TENANTID
	INNER JOIN BILL_SERVICE_DETAIL AS DETAIL ON DETAIL.BILL_ID = BILL.ID
	AND DETAIL.PACKAGE_ID IS NULL AND DETAIL.SCREEN != 4 -- AND DETAIL.BILL_STATUS NOT IN (4,5)
	INNER JOIN RT_DATA_CHARGE_DETAIL AS CHARGEDETAIL ON CHARGEDETAIL.ID = DETAIL.CHARGEDETAIL_ID
	INNER JOIN RT_DATA_CORE AS CORE ON CORE.ID = CHARGEDETAIL.ID
	INNER JOIN RT_DATA_CHARGE AS CHARGE ON CHARGE.ID = CORE.PARENT_TICKET_ID
          INNER JOIN RT_DATA_ACCOUNTSUBHEAD AS SUB ON SUB.ID = CHARGE.ACCSUBHEAD
	INNER JOIN RT_DATA_ACCOUNT_HEAD AS ACCHEAD ON ACCHEAD.ID = CHARGE.CHARGACCOUNTHEAD
	LEFT JOIN RT_INDIVIDUAL_PATIENT AS PATIENT ON PATIENT.ID = BILL.PATIENT_ID
	LEFT JOIN RT_INDIVIDUAL_CORE AS RIC ON RIC.ID=PATIENT.ID
	LEFT JOIN `RT_DATA_LEDGER` LED ON LED.ID=CHARGE.CHARGELEDGER
	LEFT JOIN RT_DATA_PAYORTYPE AS PAYORTYPE ON BILL.PAYOR_TYPE_ID = PAYORTYPE.ID
	LEFT JOIN RT_TICKET_DOCTOR_ADVICEDETAIL AS ADVICEDETAIL ON ADVICEDETAIL.ID=DETAIL.SERVICE_ID
	LEFT JOIN RT_DATA_ACCOUNT_UNIT PATACCUNIT ON PATACCUNIT.ID= IF(PATIENT.ID IS NULL,BILL.ACC_UNIT_ID  ,PATIENT.ACCUNIT )
	LEFT JOIN `RT_DATA_ACCOUNT_UNIT` AS BILLACCUNIT ON BILLACCUNIT.ID = BILL.`ACC_UNIT_ID`
	LEFT JOIN SYS_ADMIN_TIMEZONE AS TZ ON TZ.TIMEZONE_ID = IF(PATACCUNIT.STATUS != 0,PATACCUNIT.ACCUNITTIMEZONEID,BILLACCUNIT.ACCUNITTIMEZONEID)
WHERE
	 BILL.REVENUE_DATE BETWEEN DATE_SUB(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY) AND (DATE_ADD(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'), INTERVAL 1 DAY))
AND BILL.REVENUE_DATE >= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 00:00:00'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND BILL.REVENUE_DATE <= CONVERT_TZ(CONCAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),' 23:59:59'),REPLACE(TZ.GMT_ID,'GMT',''),'+00:00')
AND ((DETAIL.BILL_STATUS = 4 OR DETAIL.BILL_STATUS = 2) AND DETAIL.SERVICE_ID LIKE 'PKG-%')
AND PAYORTYPE.PAYORCATEGORY <> 'Cash'
GROUP BY DETAIL.ID
	)
ORDER BY
BILLID
) AS A
WHERE BILLED NOT IN ('NAB', 'UGD', 'TZA', 'ZMB', 'GHA', 'RWD', 'MZQ', 'BRA', 'MDR','GDL','EBN','FLQ','NGA','CGU')
