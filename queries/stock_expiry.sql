SELECT 
 OCRE.DESCRIPTION,OCRE.ORGANIZATIONNAME,ACCUNIT.ADDRESSLINE2 AS REGION,
ITM.ITEMCODE,ITM.ADITMNAME,
 DAT.DEPARTMENTNAME,DETAIL.CURRENT_STOCK AS QUANTITY,DETAIL.BATCH_NO,DETAIL.EXPIRYDATE,DETAIL.UNIT_PRICE
 ,DETAIL.CURRENT_STOCK*DETAIL.UNIT_PRICE AS 'Total Value OF Expiry Items' 
,  IFNULL(GOODS.GRNSEQUENCE,'STOCKUPLOAD')
 ,SUP.NAME AS VENDOR
  FROM STORE_STOCK_DETAIL DETAIL
LEFT JOIN RT_TICKET_CORE DCRE
ON DCRE.ID =DETAIL.GRN_DETAIL_ID
LEFT JOIN `RT_TICKET_GOODSRECEIVED` GOODS 
LEFT JOIN `RT_ORGANIZATION_SUPPLIER` SUP
ON SUP.ID = GOODS.GOODSSUPPLIER
ON GOODS.ID = DCRE.PARENT_TICKET_ID
JOIN RT_DATA_ITEM ITM
ON ITM.ID = DETAIL.ITEM_ID
INNER JOIN RT_DATA_DEPARTMENT DAT
ON DAT.ID = DETAIL.DEPT_ID
JOIN RT_DATA_ACCOUNT_UNIT ACCUNIT
ON ACCUNIT.ID = DAT.ACCOUNTUNITID
LEFT JOIN RT_DATA_CORE CRE
ON CRE.ID = DAT.ID
LEFT JOIN RT_ORGANIZATION_CORE OCRE
ON OCRE.ID = CRE.TENANTID
WHERE DATE(DETAIL.EXPIRYDATE) <= DATE_ADD(DATE(NOW()), INTERVAL ? MONTH)
AND CURRENT_STOCK>=1
AND DAT.DATASTATUS ='ACTIVE'


