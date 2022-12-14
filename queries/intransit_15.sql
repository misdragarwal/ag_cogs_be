SELECT
	OCRE.DESCRIPTION,
        DIRECTISSUE.ISSUINGDEPARTMENT AS ISSUE_DEPT ,
        (SELECT DEPARTMENTNAME FROM RT_DATA_DEPARTMENT WHERE ID = ISSUE_DEPT) AS ISSUING_DEPARTMENT,
        DIRECTISSUE.RECEIVINGDEPARTMENT AS RECEIV_DEPT,
        (SELECT DEPARTMENTNAME FROM RT_DATA_DEPARTMENT WHERE ID = RECEIV_DEPT) AS RECEIVING_DEPARTMENT,
        DIRECTISSUE.ISSUEID AS TRANSACTION_NO,
        ITEM.ADITMNAME AS ITEM_NAME,
        DIRECTISSUEDETAIL.BATCHNO AS BATCH_NUMBER,
        DIRECTISSUEDETAIL.EXPIRYDATE AS EXPIRY_DATE,
        DIRECTISSUEDETAIL.QUANTITY AS INTRANSIST_QUANTITY,
        (CORE.CREATEDTIME) AS ISSUESDATE,
        CORE.CREATEDBY AS USER_CREATED,
        DIRECTISSUEDETAIL.UNITPRICE AS UNIT_PRICE,
        ITEM.ADITMMRP AS MRP,
        DIRECTISSUEDETAIL.ISSUESTATUS AS STATUS,
				  DIRECTISSUEDETAIL.QUANTITY*DIRECTISSUEDETAIL.UNITPRICE AS TOTALVALUE
FROM
        RT_TICKET_DIRECTISSUE AS  DIRECTISSUE
        LEFT JOIN RT_TICKET_DIRECTISSUEDETAIL AS DIRECTISSUEDETAIL ON DIRECTISSUEDETAIL.ISSUEID = DIRECTISSUE.ID
        LEFT JOIN RT_DATA_ITEM AS ITEM ON ITEM.ID= DIRECTISSUEDETAIL.ITEMID
        LEFT JOIN RT_TICKET_CORE AS CORE ON CORE.ID= DIRECTISSUEDETAIL.ID
        LEFT JOIN `RT_ORGANIZATION_CORE` OCRE ON OCRE.ID = CORE.TENANTID
WHERE
  DATEDIFF(CURDATE(),DATE(CORE.CREATEDTIME))>15
 AND DIRECTISSUEDETAIL.QUANTITY > 0
AND DIRECTISSUEDETAIL.ISSUESTATUS LIKE '%Transit%'
AND OCRE.DESCRIPTION IN ('AHC','AEH','AHI')
ORDER BY
OCRE.DESCRIPTION
