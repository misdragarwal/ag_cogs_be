SELECT * FROM
(
SELECT 
	IF(ITM.ITEMCODE IS NULL,'',ITM.ITEMCODE) AS 'item_code'
	, IF(ITM.ADITMNAME IS NULL,SDTL.ITEMNAME,ITM.ADITMNAME) AS 'item_name'
	, SSD.BATCH_NO as 'batch_no'
	, ITM.ADITMUNIT AS 'uom'
	, IF(PAT.PATIENTID IS NULL,'Retail Sales',SDTL.SALESDETAILSTATUS) AS 'trans_type'
	, DATE(BILL.BILL_DATE) AS 'trans_date'
	, IF(ITM.ITEMTYPE = 'F','Frames',IF(ITM.ITEMTYPE = 'L','Lens',IF(ITM.ITEMTYPE = 'M','Material',IF(ITM.ITEMTYPE = 'D','Drugs','Lens')))) AS 'item_type'
	, CASE 
	       	 WHEN ITMC.ITMCGCATEGNAME IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN 'OPTICALS' 
	       	 WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN 'OPTICALS' 
	       	 WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 'OPTICALS' 
		     WHEN ITMC.ITMCGCATEGNAME LIKE '%PHARMACY%' THEN 'PHARMACY'
		     WHEN ITMC.ITMCGCATEGNAME LIKE '%LAB%' THEN 'LABORATORY'
		     WHEN ITMC.ITMCGCATEGNAME LIKE '%OPERATION THEAT%' THEN 'OPERATION THEATRE'
	  END AS 'TOP'
	, ITM.ADITMDEPT AS 'second'
	, ITMC.ITMCGCATEGNAME AS 'group'
	, ITM.SUBCATEGORY AS 'sub_group'
	, BILL.BILL_NO AS 'bill_no'
	, SALES.SALESNO AS 'sales_no'
	, (SDTL.QUANTITY) AS 'quantity'
	, IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) AS 'Unit_price'
	, IF(SSD.COST_PRICE IS NULL ,IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.COST_PRICE) AS 'cost_price'
	, CASE
		WHEN ROC.DESCRIPTION IN ('OMA','OGH') THEN 
			CASE
				WHEN ITMC.ITMCGCATEGNAME  IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				ELSE
					IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(SDTL.QUANTITY)
			END 
		WHEN ROC.DESCRIPTION IN ('OMZ','OMD') THEN
			CASE
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				ELSE
					IF(SSD.COST_PRICE IS NULL ,IF(SSD.UNIT_PRICE IS NULL,ITM.ADITMUNITRATE,SSD.UNIT_PRICE),SSD.COST_PRICE)*(SDTL.QUANTITY)
			END
		WHEN ROC.DESCRIPTION IN ('OTA','OZA','OUG','ORW','ONI') THEN
			IF(SSD.COST_PRICE IS NULL ,IF(SSD.UNIT_PRICE IS NULL,ITM.ADITMUNITRATE,SSD.UNIT_PRICE),SSD.COST_PRICE)*(SDTL.QUANTITY)
		WHEN ROC.DESCRIPTION IN ('ONA') THEN
			CASE
				WHEN ITMC.ITMCGCATEGNAME  IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				WHEN (IF(ITM.ADITMNAME IS NULL,SDTL.ITEMNAME,ITM.ADITMNAME)	LIKE ('%Visionace%')) THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)
				WHEN (IF(ITM.ADITMNAME IS NULL,SDTL.ITEMNAME,ITM.ADITMNAME)	LIKE ('EDR Refresh%')) THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SDTL.QUANTITY)	
				ELSE
					IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(SDTL.QUANTITY)
			END
	END AS actual_value
	, IFNULL(RDT1.TAX,RDT.TAX) AS 'tax'
	, IFNULL(RDT1.VALUE,RDT.VALUE) AS 'tax_percent'
	, UNIT.ACCOUNTUNIT AS 'branch'
	, ROC.DESCRIPTION AS 'entity'
	, UNIT.ADDRESSLINE2 AS 'region'
	, IF(ITMC.ITMCGCATEGNAME = 'LENS','OPTICAL LENS',DEPT.DEPARTMENTNAME) AS 'unit'
	, SALES.WORKORDERSTATUS AS 'wo_status'
	, IF(MANF.ID IS NULL,ITM.MANUFACTURERID,MANF.MANUFACTURER) AS MANUFACTURER
	, IFNULL(SSD.MRP,ITM.ADITMMRP) AS MRP
FROM 
	RT_DATA_ACCOUNT_UNIT UNIT 
	JOIN BILL_PATIENT_BILL BILL ON BILL.ACC_UNIT_ID = UNIT.ID
	JOIN RT_DATA_CORE RDC ON RDC.ID=UNIT.ID
	JOIN RT_ORGANIZATION_CORE ROC ON ROC.ID=RDC.TENANTID
	JOIN BILL_SERVICE_DETAIL DTL ON BILL.ID = DTL.BILL_ID
	JOIN RT_TICKET_DIRECTSALES SALES ON DTL.SERVICE_ID = SALES.ID
	JOIN RT_TICKET_DIRECTSALESDETAIL SDTL ON SALES.ID = SDTL.SALESID
	JOIN RT_DATA_ITEM ITM ON ITM.ID = SDTL.ITEMID LEFT JOIN  RT_ORGANIZATION_MANUFACTURER MANF ON MANF.ID = ITM.MANUFACTURERID
	LEFT JOIN RT_DATA_TAX RDT ON RDT.ID=ITM.TAXTYPE
	LEFT JOIN RT_INDIVIDUAL_PATIENT AS PAT ON(BILL.PATIENT_ID = PAT.ID)
	JOIN RT_DATA_ITEM_CATEGORY ITMC ON ITM.CATEGORY = ITMC.ID
	LEFT JOIN STORE_STOCK_DETAIL AS SSD ON (SDTL.STOCKDETAILID = SSD.ID)
	LEFT JOIN RT_DATA_TAX RDT1 ON RDT1.ID=SSD.TAX
	LEFT JOIN RT_DATA_DEPARTMENT AS DEPT ON (SDTL.DEPTID = DEPT.ID)
WHERE 
	DATE(BILL.BILL_DATE)=DATE_SUB(CURDATE(), INTERVAL 1 DAY)
	AND DTL.SERVICE_ID IS NOT NULL
	AND ROC.DESCRIPTION NOT IN ('AEH','AHC','AHI','OHC','ERC','AJE')
	AND UNIT.DATASTATUS='Active'
	
UNION ALL	

SELECT 
	ITM.ITEMCODE AS 'item_code'
	, ITM.ADITMNAME AS 'item-name'
	, SSD.BATCH_NO
	, ITM.ADITMUNIT AS 'uom'
	, SADTL.REASON AS 'trans_type'
	, DATE(CRE.CREATEDTIME) AS 'trans_date'
	, IF(ITM.ITEMTYPE = 'F','Frames',IF(ITM.ITEMTYPE = 'L','Lens',IF(ITM.ITEMTYPE = 'M','Material',IF(ITM.ITEMTYPE = 'D','Drugs','Lens')))) AS 'item_type'
	, CASE 
	       	 WHEN ITMC.ITMCGCATEGNAME IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN 'OPTICALS' 
	       	 WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN 'OPTICALS' 
	       	 WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 'OPTICALS' 
		     WHEN ITMC.ITMCGCATEGNAME LIKE '%PHARMACY%' THEN 'PHARMACY'
		     WHEN ITMC.ITMCGCATEGNAME LIKE '%LAB%' THEN 'LABORATORY'
		       WHEN ITMC.ITMCGCATEGNAME LIKE '%OPERATION THEAT%' THEN 'OPERATION THEATRE'
	     END AS 'TOP'
	, ITM.ADITMDEPT AS 'second'
	, ITM.SUBCATEGORY AS 'group'
	, ITM.SUBCATEGORY AS 'sub_group'
	, SADTL.ID AS 'bill_no'
	, SADTL.ID AS 'Salesno'
	, SADTL.QUANTITY AS 'quantity'
	, SSD.UNIT_PRICE AS 'unit_price'
	, SSD.COST_PRICE AS 'cost_price'
	, CASE
		WHEN ROC.DESCRIPTION IN ('OMA','OGH') THEN 
			CASE
				WHEN ITMC.ITMCGCATEGNAME  IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				ELSE
					IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(SADTL.QUANTITY)
			END 
		WHEN ROC.DESCRIPTION IN ('OMZ','OMD') THEN
			CASE
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				ELSE
					IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(SADTL.QUANTITY)
			END
		WHEN ROC.DESCRIPTION IN ('OTA','OZA','OUG','ORW','ONI') THEN
			IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(SADTL.QUANTITY)
		WHEN ROC.DESCRIPTION IN ('ONA') THEN
			CASE
				WHEN ITMC.ITMCGCATEGNAME  IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				WHEN ITM.ADITMNAME LIKE ('%Visionace%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)
				WHEN ITM.ADITMNAME LIKE ('EDR Refresh%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (SADTL.QUANTITY)	
				ELSE
					IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(SADTL.QUANTITY)
			END
	END AS actual_value
	, IFNULL(RDT1.TAX,RDT.TAX) AS 'tax'
	, IFNULL(RDT1.VALUE,RDT.VALUE) AS 'tax_percent'
	, UNIT.ACCOUNTUNIT AS 'branch'
	, ROC.DESCRIPTION AS 'entity'
	, UNIT.ADDRESSLINE2 AS 'Region'
	, DEP.DEPARTMENTNAME AS 'unit'
	, '' AS 'wo_status'
	, IF(MANF.ID IS NULL,ITM.MANUFACTURERID,MANF.MANUFACTURER) AS MANUFACTURER
	, IFNULL(SSD.MRP,ITM.ADITMMRP) AS MRP
FROM 
	RT_TICKET_STOCKADJUSTMENTDETAIL SADTL
	JOIN RT_TICKET_CORE CRE ON SADTL.ID = CRE.ID
	JOIN RT_DATA_ITEM ITM ON ITM.ID = SADTL.ITEMID 
	LEFT JOIN  RT_ORGANIZATION_MANUFACTURER MANF ON MANF.ID = ITM.MANUFACTURERID
	JOIN RT_DATA_ITEM_CATEGORY ITMC ON ITM.CATEGORY = ITMC.ID
	LEFT JOIN RT_DATA_TAX RDT ON RDT.ID=ITM.TAXTYPE
	JOIN STORE_STOCK_DETAIL SSD ON SADTL.STOCKDETAILID = SSD.ID
	LEFT JOIN RT_DATA_TAX RDT1 ON RDT1.ID=SSD.TAX
	JOIN RT_DATA_DEPARTMENT DEP ON SADTL.DEPTID = DEP.ID
	JOIN RT_DATA_ACCOUNT_UNIT UNIT ON DEP.ACCOUNTUNITID = UNIT.ID
	JOIN RT_DATA_CORE RDC ON RDC.ID=UNIT.ID
	JOIN RT_ORGANIZATION_CORE ROC ON ROC.ID=RDC.TENANTID
WHERE 
	DATE(CRE.CREATEDTIME)=DATE_SUB(CURDATE(), INTERVAL 1 DAY)
	AND TRANSTYPE LIKE 'Reduction'
	AND ROC.DESCRIPTION NOT IN ('AEH','AHC','AHI','OHC','ERC','AJE')
	AND UNIT.DATASTATUS='Active'

UNION ALL

SELECT 
	IF(ITM.ITEMCODE IS NULL,'',ITM.ITEMCODE) AS 'item_code'
	, IF(ITM.ADITMNAME IS NULL,SDTL.ITEMNAME,ITM.ADITMNAME) AS 'item_name'
	, SSD.BATCH_NO
	, ITM.ADITMUNIT AS 'uom'
	, IF(PAT.PATIENTID IS NULL,'Retail Sales',SDTL.SALESDETAILSTATUS) AS 'trans_type'
	, DATE(RETCORE.CREATEDTIME) AS 'trans_date'
	, IF(ITM.ITEMTYPE = 'F','Frames',IF(ITM.ITEMTYPE = 'L','Lens',IF(ITM.ITEMTYPE = 'M','Material',IF(ITM.ITEMTYPE = 'D','Drugs','Lens')))) AS 'item_type'
	, CASE 
	       	 WHEN ITMC.ITMCGCATEGNAME IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN 'OPTICALS' 
	       	 WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN 'OPTICALS' 
	       	 WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 'OPTICALS' 
		     WHEN ITMC.ITMCGCATEGNAME LIKE '%PHARMACY%' THEN 'PHARMACY'
		     WHEN ITMC.ITMCGCATEGNAME LIKE '%LAB%' THEN 'LABORATORY'
		       WHEN ITMC.ITMCGCATEGNAME LIKE '%OPERATION THEAT%' THEN 'OPERATION THEATRE'
	  END AS 'TOP'
	, ITM.ADITMDEPT AS 'second'
	, ITMC.ITMCGCATEGNAME AS 'group'
	, ITM.SUBCATEGORY AS 'sub_group'
	, BILL.BILL_NO AS 'bill_no'
	, SALES.SALESNO AS 'Salesno'
	, -(RETURNDET.RETURNQUANTITY) AS 'quantity'
	, IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) AS 'Unit_price'
	, IF(SSD.COST_PRICE IS NULL ,IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.COST_PRICE) AS 'cost_price'
	, -CASE
		WHEN ROC.DESCRIPTION IN ('OMA','OGH') THEN 
			CASE
				WHEN ITMC.ITMCGCATEGNAME  IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				ELSE
					IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(RETURNDET.RETURNQUANTITY)
			END 
		WHEN ROC.DESCRIPTION IN ('OMZ','OMD') THEN
			CASE
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				ELSE
					IF(SSD.COST_PRICE IS NULL ,IF(SSD.UNIT_PRICE IS NULL,ITM.ADITMUNITRATE,SSD.UNIT_PRICE),SSD.COST_PRICE)*(RETURNDET.RETURNQUANTITY)
			END
		WHEN ROC.DESCRIPTION IN ('OTA','OZA','OUG','ORW','ONI') THEN
			IF(SSD.COST_PRICE IS NULL ,IF(SSD.UNIT_PRICE IS NULL,ITM.ADITMUNITRATE,SSD.UNIT_PRICE),SSD.COST_PRICE)*(RETURNDET.RETURNQUANTITY)
		WHEN ROC.DESCRIPTION IN ('ONA') THEN
			CASE
				WHEN ITMC.ITMCGCATEGNAME  IN ('FRAMES','LENS','CONTACT LENS','SUNGLASS','OPTICAL LENS') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%OPTICAL SUNGLASS%') THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				WHEN ITMC.ITMCGCATEGNAME LIKE  ('%FRAME%') THEN 
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				WHEN (IF(ITM.ADITMNAME IS NULL,SDTL.ITEMNAME,ITM.ADITMNAME)	LIKE ('%Visionace%')) THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)
				WHEN (IF(ITM.ADITMNAME IS NULL,SDTL.ITEMNAME,ITM.ADITMNAME)	LIKE ('EDR Refresh%')) THEN
					IF(SSD.UNIT_PRICE IS NULL , IF(ITM.ADITMUNITRATE IS NULL,ITM.ADITMUNITRATE,ITM.ADITMUNITRATE) ,SSD.UNIT_PRICE) * (RETURNDET.RETURNQUANTITY)	
				ELSE
					IF(SSD.COST_PRICE IS NULL ,SSD.UNIT_PRICE,SSD.COST_PRICE)*(RETURNDET.RETURNQUANTITY)
			END
	END AS actual_value
	, IFNULL(RDT1.TAX,RDT.TAX) AS 'tax'
	, IFNULL(RDT1.VALUE,RDT.VALUE) AS 'tax_percent'
	, UNIT.ACCOUNTUNIT AS 'branch'
	, ROC.DESCRIPTION AS 'entity'
	, UNIT.ADDRESSLINE2 AS 'Region'
	, IF(ITMC.ITMCGCATEGNAME = 'LENS','OPTICAL LENS',DEPT.DEPARTMENTNAME) AS 'unit'
	, SALES.WORKORDERSTATUS AS 'wo_status'
	, IF(MANF.ID IS NULL,ITM.MANUFACTURERID,MANF.MANUFACTURER) AS MANUFACTURER
	, IFNULL(SSD.MRP,ITM.ADITMMRP) AS MRP
FROM 
	RT_DATA_ACCOUNT_UNIT UNIT 
	JOIN BILL_PATIENT_BILL BILL ON BILL.ACC_UNIT_ID = UNIT.ID
	JOIN RT_DATA_CORE RDC ON RDC.ID=UNIT.ID
	JOIN RT_ORGANIZATION_CORE ROC ON ROC.ID=RDC.TENANTID
	JOIN BILL_SERVICE_DETAIL DTL ON BILL.ID = DTL.BILL_ID
	JOIN RT_TICKET_DIRECTSALES SALES ON DTL.SERVICE_ID = SALES.ID
	JOIN RT_TICKET_DIRECTSALESDETAIL SDTL ON SALES.ID = SDTL.SALESID
	JOIN `RT_TICKET_SALESRETURNDETAIL` RETURNDET ON RETURNDET.SALESDETAILID = SDTL.ID
	JOIN RT_TICKET_CORE RETCORE ON RETCORE.ID = RETURNDET.ID
	JOIN RT_DATA_ITEM ITM ON ITM.ID = SDTL.ITEMID LEFT JOIN  RT_ORGANIZATION_MANUFACTURER MANF ON MANF.ID = ITM.MANUFACTURERID
	LEFT JOIN RT_DATA_TAX RDT ON RDT.ID=ITM.TAXTYPE
	LEFT JOIN RT_INDIVIDUAL_PATIENT AS PAT ON(BILL.PATIENT_ID = PAT.ID)
	JOIN RT_DATA_ITEM_CATEGORY ITMC ON ITM.CATEGORY = ITMC.ID
	LEFT JOIN STORE_STOCK_DETAIL AS SSD ON (SDTL.STOCKDETAILID = SSD.ID)
	LEFT JOIN RT_DATA_TAX RDT1 ON RDT1.ID=SSD.TAX
	LEFT JOIN RT_DATA_DEPARTMENT AS DEPT ON (SDTL.DEPTID = DEPT.ID)
WHERE 
	DATE(RETCORE.CREATEDTIME)=DATE_SUB(CURDATE(), INTERVAL 1 DAY)
	AND DTL.SERVICE_ID IS NOT NULL
	AND ROC.DESCRIPTION NOT IN ('AEH','AHC','AHI','OHC','ERC','AJE')
	AND UNIT.DATASTATUS='Active'
) AS COG
WHERE TOP IS NOT NULL