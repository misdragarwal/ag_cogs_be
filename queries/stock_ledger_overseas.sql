SELECT
    DESCRIPTION,
    ORGANIZATIONNAME,
    (CURDATE()) AS PREVDATE,
    ITEMID,
    ITEMNAME,
    ITEMCODE,
    REGION,
    SECONDCATEGORY,
    ITEMCATEGORY,
    SUBCATEGORY,
    UNITS,
    MANUFACTURER,
    COST_PRICE,
    UNITPRICE,
    DEPTID,
    DEPTNAME,
    CASE WHEN DEPARTNAME IN ('PHARMACY','OPTICALS','LAB','CONTACT LENS') THEN DEPARTNAME
    WHEN CLS_OPN_ALL.DEPARTNAME IN ('OT','MAIN OT','RETINA OT','LASIK OT') THEN 'OT'
    ELSE 'OTHERS' END AS DEPARTMENT_NAME,
    SUM(OPENING) AS OpeningStock,    
    SUM(OPENING_VALUE) AS OpeningValue,
    GRN AS Purchase,
    GRN_VAL AS PurchaseValue,       
    GRNRETURN AS PurchaseReturn,    
    GRNRETURN_VAL AS PurchaseReturnValue,
    SALES AS Issues,    
    SALES_VAL AS IssuesValue,
    SALESRETURN AS SalesReturn,
    SALESRETURN_VAL AS SalesReturnValue,        
    ADJUST_ADD AS 'StockAdjustment(T)',
    ADJUST_ADD_VAL AS 'StockAdjustmentValue(T)',
    ADJUST_SUB AS 'StockAdjustment(O)',
    ADJUST_SUB_VAL AS 'StockAdjustmentValue(O)',
    ISSUE_ADD AS StockTransferIn,  
    ISSUE_ADD_VAL AS StockTransferInValue,
    ISSUE_SUB AS StockTransferOut,
    ISSUE_SUB_VAL AS StockTransferOutValue,
    CLOSING AS ClosingStock, 
    IF(CLOSING=0,0,SUM(CLOSING_VALUE)) AS ClosingStockValue,
    ISSUE_TRANSIT AS TransitStock,
    ISSUE_TRANSIT_VAL AS TransitStockValue
 FROM
 (
    SELECT
        DESCRIPTION,
        ORGANIZATIONNAME,
        ITEMID,
        0 AS OPENING ,
        SUM(CLOSING) AS CLOSING,
        0 AS OPENING_VALUE,
        SUM(CLOSING_VALUE) CLOSING_VALUE,
        REGION,
        SECONDCATEGORY,
        ITEMCATEGORY,
        DEPTNAME,
        DEPTID,
        ITEMNAME,
        ITEMCODE,
        SUBCATEGORY,
        MANUFACTURER,
        UNITS,
        COST_PRICE,
        UNITPRICE,
        SUM(SALES) AS SALES,
        SUM(SALESRETURN) AS  SALESRETURN,
        SUM(GRNRETURN) AS GRNRETURN,
        SUM(GRN) AS GRN,
        SUM(ADJUST_ADD) AS ADJUST_ADD,
        SUM(ADJUST_SUB) AS ADJUST_SUB,
        SUM(ISSUE_SUB)AS ISSUE_SUB,
        SUM(ISSUE_ADD) AS ISSUE_ADD,
        SUM(ISSUE_TRANSIT) AS ISSUE_TRANSIT,
        SUM(SALES_VAL) AS SALES_VAL,
        SUM(SALESRETURN_VAL) AS SALESRETURN_VAL,
        SUM(GRNRETURN_VAL) AS GRNRETURN_VAL,
        SUM(GRN_VAL) AS GRN_VAL,
        SUM(ADJUST_ADD_VAL) AS ADJUST_ADD_VAL,
        SUM(ADJUST_SUB_VAL) AS ADJUST_SUB_VAL,
        SUM(ISSUE_SUB_VAL) AS ISSUE_SUB_VAL,
        SUM(ISSUE_ADD_VAL) AS ISSUE_ADD_VAL,
        SUM(ISSUE_TRANSIT_VAL) AS ISSUE_TRANSIT_VAL,
        DEPARTNAME
    FROM
    (
        SELECT
            DESCRIPTION,
            ORGANIZATIONNAME,
            ITEMID,
            STOCK_ID,
            (SELECT CLOSING_STOCK FROM `STORE_STOCK_REGISTER` REG1 WHERE REG1.ID=MAX(REG_ID)) CLOSING,
            ITEMCATEGORY,
            DEPTNAME,
            DEPTID,
            ITEMNAME,
            ITEMCODE,
            SUBCATEGORY,
            MANUFACTURER,
            UNITS,
            COST_PRICE,
            UNITPRICE,
            SUM(SALES) AS SALES,
            SUM(SALESRETURN) AS  SALESRETURN,
            SUM(GRNRETURN) AS GRNRETURN,
            SUM(GRN) AS GRN,
            SUM(ADJUST_ADD) AS ADJUST_ADD,
            SUM(ADJUST_SUB) AS ADJUST_SUB,
            SUM(ISSUE_SUB)AS ISSUE_SUB,
            SUM(ISSUE_ADD) AS ISSUE_ADD,
            SUM(ISSUE_TRANSIT) AS ISSUE_TRANSIT,
            SUM(SALES_VAL) AS SALES_VAL,
            SUM(SALESRETURN_VAL) AS SALESRETURN_VAL,
            SUM(GRNRETURN_VAL) AS GRNRETURN_VAL,
            SUM(GRN_VAL) AS GRN_VAL,
            SUM(ADJUST_ADD_VAL) AS ADJUST_ADD_VAL,
            SUM(ADJUST_SUB_VAL) AS ADJUST_SUB_VAL,
            SUM(ISSUE_SUB_VAL) AS ISSUE_SUB_VAL,
            SUM(ISSUE_ADD_VAL) AS ISSUE_ADD_VAL,
            SUM(ISSUE_TRANSIT_VAL) AS ISSUE_TRANSIT_VAL,
            SUM(CLOSING_VALUE) AS CLOSING_VALUE,
             SECONDCATEGORY,REGION,
             DEPARTNAME
         FROM
         (
            SELECT
            ROC.DESCRIPTION,
            ROC.ORGANIZATIONNAME,
            REG.ID AS REG_ID,
            ITEM.ID AS ITEMID,
            REG.STOCK_ID AS STOCK_ID,
            DETAIL.BATCH_NO AS BATCHNO,
            DETAIL.ID AS DETAILID,
            DETAIL.DEPT_ID AS DEPTID,
            ITEMCATEGORY.ITMCGCATEGNAME AS ITEMCATEGORY,
            DEPT.DEPARTMENTNAME AS DEPTNAME,
            RIGHT(DEPT.DEPARTMENTNAME,LENGTH(DEPT.DEPARTMENTNAME)-4) AS DEPARTNAME,
            ITEM.ADITMNAME AS ITEMNAME,
            ITEM.ITEMCODE AS ITEMCODE,
            ITEM.SUBCATEGORY AS SUBCATEGORY,
            IFNULL(MANUF.MANUFACTURER,ITEM.MANUFACTURERID) AS MANUFACTURER,
            ITEM.ADITMUNIT AS UNITS,
            DETAIL.COST_PRICE AS COST_PRICE,
            DETAIL.UNIT_PRICE AS UNITPRICE,
            IF(((ADJUST.PATIENTID IS NOT NULL AND REG.TRANS_TYPE='ADJUSTMENT') OR REG.TRANS_TYPE='SALES' OR ADJUST.ADJUSTMENTTYPE=1),REG.TRANS_QTY,0) AS SALES,
            IF( REG.TRANS_TYPE='SALESRETURN',REG.TRANS_QTY,0) AS SALESRETURN,
            IF( (REG.TRANS_TYPE='GRNRETURN'  OR (REG.TRANS_TYPE='GRNUPDATE' AND REG.TRANS_MODE='SUB')),REG.TRANS_QTY,0) AS GRNRETURN,
            IF( (REG.TRANS_TYPE='GRN' OR (REG.TRANS_TYPE='GRNUPDATE' AND REG.TRANS_MODE='ADD')),REG.TRANS_QTY,0) AS GRN,
            IF(ADJUST.PATIENTID IS NULL AND ((REG.TRANS_TYPE='ADJUSTMENT' AND REG.TRANS_MODE='ADD') OR REG.TRANS_TYPE='STOCKUPLOAD'),REG.TRANS_QTY,0) AS ADJUST_ADD,
            IF(ADJUST.PATIENTID IS NULL AND  ((ADJUST.ADJUSTMENTTYPE!=1 AND REG.TRANS_TYPE='ADJUSTMENT' AND REG.TRANS_MODE='SUB' ) OR REG.TRANS_TYPE='GRNREMOVE'),REG.TRANS_QTY,0) AS ADJUST_SUB,
            IF((REG.TRANS_TYPE LIKE 'ISSUED' OR REG.TRANS_TYPE LIKE 'ISSUE IN TRANSIT') AND REG.TRANS_MODE='SUB',REG.TRANS_QTY,0) AS ISSUE_SUB,
            IF((REG.TRANS_TYPE LIKE 'ISSUE' OR REG.TRANS_TYPE LIKE 'RETURN' ) AND REG.TRANS_MODE='ADD',REG.TRANS_QTY,0) AS ISSUE_ADD,
            IF(REG.TRANS_TYPE LIKE '%TRANSIT%',REG.TRANS_QTY,0) AS ISSUE_TRANSIT,
            IF(((ADJUST.PATIENTID IS NOT NULL AND REG.TRANS_TYPE='ADJUSTMENT') OR REG.TRANS_TYPE='SALES' OR ADJUST.ADJUSTMENTTYPE=1),REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS SALES_VAL,
            IF( REG.TRANS_TYPE='SALESRETURN',REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS SALESRETURN_VAL,
            IF( (REG.TRANS_TYPE='GRNRETURN' OR (REG.TRANS_TYPE='GRNUPDATE' AND REG.TRANS_MODE='SUB')),REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS GRNRETURN_VAL,
            IF( (REG.TRANS_TYPE='GRN' OR (REG.TRANS_TYPE='GRNUPDATE' AND REG.TRANS_MODE='ADD')),REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS GRN_VAL,
            IF(ADJUST.PATIENTID IS NULL AND ((REG.TRANS_TYPE='ADJUSTMENT' AND REG.TRANS_MODE='ADD') OR REG.TRANS_TYPE='STOCKUPLOAD'),REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS ADJUST_ADD_VAL,
            IF(ADJUST.PATIENTID IS NULL AND ((ADJUST.ADJUSTMENTTYPE!=1 AND REG.TRANS_TYPE='ADJUSTMENT' AND REG.TRANS_MODE='SUB') OR REG.TRANS_TYPE='GRNREMOVE' ),REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS ADJUST_SUB_VAL,
            IF((REG.TRANS_TYPE LIKE 'ISSUED' OR REG.TRANS_TYPE LIKE 'ISSUE IN TRANSIT')  AND REG.TRANS_MODE='SUB',REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS ISSUE_SUB_VAL,
            IF((REG.TRANS_TYPE LIKE 'ISSUE' OR REG.TRANS_TYPE LIKE 'RETURN' ) AND REG.TRANS_MODE='ADD',REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS ISSUE_ADD_VAL,
            IF(REG.TRANS_TYPE LIKE '%TRANSIT%',REG.TRANS_QTY*DETAIL.UNIT_PRICE,0) AS ISSUE_TRANSIT_VAL,
            REG.TRANS_TYPE,
            CLOSING_STOCK AS CLOSING,
            ((CLOSING_STOCK - OPENING_STOCK) * DETAIL.UNIT_PRICE) AS CLOSING_VALUE,
            ITEM.ADITMDEPT AS  'SECONDCATEGORY',
            UNIT.ADDRESSLINE2 AS 'REGION'
            FROM
            RT_DATA_ITEM AS ITEM
            LEFT JOIN STORE_STOCK_DETAIL AS DETAIL ON ITEM.ID=DETAIL.ITEM_ID
            LEFT JOIN STORE_STOCK_REGISTER AS REG ON REG.ITEM_TRANS_ID=DETAIL.ID -- and (DETAIL.BATCH_NO=REG.BATCH_NO OR REG.BATCH_NO IS NULL)
            LEFT JOIN RT_DATA_DEPARTMENT AS DEPT ON DEPT.ID=DETAIL.DEPT_ID
            LEFT JOIN RT_DATA_ACCOUNT_UNIT AS UNIT ON UNIT.ID=DEPT.ACCOUNTUNITID
            JOIN RT_DATA_CORE AS RDC ON RDC.ID=UNIT.ID
            JOIN RT_ORGANIZATION_CORE AS ROC ON ROC.ID=RDC.TENANTID
            LEFT JOIN RT_DATA_ITEM_CATEGORY AS ITEMCATEGORY ON ITEMCATEGORY.ID=ITEM.CATEGORY
            LEFT JOIN RT_ORGANIZATION_MANUFACTURER AS MANUF ON ITEM.MANUFACTURERID=MANUF.ID
            LEFT JOIN RT_TICKET_STOCKADJUSTMENTDETAIL AS ADJUST ON ADJUST.ID = REG.TRANS_ID
            WHERE DATE(REG.TRANS_DATE) BETWEEN TIMESTAMP(DATE_SUB(DATE(DATE_SUB(CURDATE(), INTERVAL 1 SECOND)),INTERVAL (DAY(DATE_SUB(CURDATE(), INTERVAL 1 SECOND))-1) DAY)) AND DATE_ADD(CURDATE(), interval 24*60*60 - 1 second)
            AND DEPT.DATASTATUS ='ACTIVE'
            AND ROC.DESCRIPTION NOT IN ('AEH','AHC','AHI','OHC')
            ORDER BY
            REG.ID DESC
        ) CLS
        GROUP BY ITEMID,STOCK_ID,DEPTID
    ) CLS_GRP
    GROUP BY ITEMID,DEPTID
    UNION ALL
    SELECT
     DESCRIPTION,
        ORGANIZATIONNAME,
        ITEMID,
        SUM(OPENING) AS OPENING,
        SUM(OPENING) AS CLOSING,
        SUM(OPENING_VALUE) AS OPENING_VALUE,
        SUM(OPENING_VALUE) AS CLOSING_VALUE,
        REGION,
         SECONDCATEGORY,
        ITEMCATEGORY,
        DEPTNAME,
        DEPTID,
        ITEMNAME,
        ITEMCODE,
        SUBCATEGORY,
        MANUFACTURER,
        UNITS,
        COST_PRICE,
        UNITPRICE,
            0 AS SALES,
            0 AS SALESRETURN,
            0 AS GRNRETURN,
            0 AS GRN,
            0 AS ADJUST_ADD,
            0 AS ADJUST_SUB,
            0 AS ISSUE_SUB,
            0 AS ISSUE_ADD,
            0 AS ISSUE_TRANSIT,
            0 AS SALES_VAL,
            0 AS SALESRETURN_VAL,
            0 AS GRNRETURN_VAL,
            0 AS GRN_VAL,
            0 AS ADJUST_ADD_VAL,
            0 AS ADJUST_SUB_VAL,
            0 AS ISSUE_SUB_VAL,
            0 AS ISSUE_ADD_VAL,
            0 AS ISSUE_TRANSIT_VAL,DEPARTNAME
    FROM
    (
        SELECT
            DESCRIPTION,
            ORGANIZATIONNAME,
            ITEMID,
            DETAILID,
            STOCK_ID,
            DEPTID,
            (SELECT CLOSING_STOCK FROM `STORE_STOCK_REGISTER` REG1 WHERE REG1.ID=MAX(REG_ID)) OPENING,
            SECONDCATEGORY,
            REGION,
            ITEMCATEGORY,
            DEPTNAME,
            ITEMNAME,
            ITEMCODE,
            SUBCATEGORY,
            MANUFACTURER,
            UNITS,
            COST_PRICE,
            UNITPRICE,
            SUM(OPENING_VALUE) AS OPENING_VALUE,DEPARTNAME
         FROM
         (
            SELECT
                ROC.DESCRIPTION,
                ROC.ORGANIZATIONNAME,
                REG.ID AS REG_ID,
                ITEM.ID AS ITEMID,
                REG.STOCK_ID AS STOCK_ID,
                DETAIL.BATCH_NO AS BATCHNO,
                DETAIL.ID AS DETAILID,
                ITEMCATEGORY.ITMCGCATEGNAME AS ITEMCATEGORY,
                DEPT.DEPARTMENTNAME AS DEPTNAME,
                RIGHT(DEPT.DEPARTMENTNAME,LENGTH(DEPT.DEPARTMENTNAME)-4) AS DEPARTNAME,
                ITEM.ADITMNAME AS ITEMNAME,
                ITEM.ITEMCODE AS ITEMCODE,
                ITEM.SUBCATEGORY AS SUBCATEGORY,
                IFNULL(MANUF.MANUFACTURER,ITEM.MANUFACTURERID) AS MANUFACTURER,
                ITEM.ADITMUNIT AS UNITS,
                DETAIL.COST_PRICE AS COST_PRICE,
                DETAIL.UNIT_PRICE AS UNITPRICE,
                CLOSING_STOCK AS OPENING,
                ((CLOSING_STOCK - OPENING_STOCK) * DETAIL.UNIT_PRICE) AS OPENING_VALUE,
                REG.UNIT_PRICE,
                OPENING_STOCK,
                CLOSING_STOCK,
                DETAIL.DEPT_ID AS DEPTID,
                ITEM.ADITMDEPT AS 'SECONDCATEGORY',
                UNIT.ADDRESSLINE2 AS REGION
            FROM
                RT_DATA_ITEM AS ITEM
                LEFT JOIN STORE_STOCK_DETAIL AS DETAIL ON ITEM.ID=DETAIL.ITEM_ID
                LEFT JOIN STORE_STOCK_REGISTER AS REG ON REG.ITEM_TRANS_ID=DETAIL.ID -- AND (DETAIL.BATCH_NO=REG.BATCH_NO or REG.BATCH_NO is Null)
                LEFT JOIN RT_DATA_DEPARTMENT AS DEPT ON DEPT.ID=DETAIL.DEPT_ID
                LEFT JOIN RT_DATA_ACCOUNT_UNIT AS UNIT ON UNIT.ID=DEPT.ACCOUNTUNITID
                JOIN RT_DATA_CORE AS RDC ON RDC.ID=UNIT.ID
                JOIN RT_ORGANIZATION_CORE AS ROC ON ROC.ID=RDC.TENANTID
                INNER JOIN RT_DATA_ITEM_CATEGORY AS ITEMCATEGORY ON ITEMCATEGORY.ID=ITEM.CATEGORY
                LEFT JOIN RT_ORGANIZATION_MANUFACTURER AS MANUF ON ITEM.MANUFACTURERID=MANUF.ID
            WHERE
                DATE(REG.TRANS_DATE) < TIMESTAMP(DATE_SUB(DATE(DATE_SUB(CURDATE(), INTERVAL 1 SECOND)),INTERVAL (DAY(DATE_SUB(CURDATE(), INTERVAL 1 SECOND))-1) DAY))
                AND DEPT.DATASTATUS ='ACTIVE'
                AND ROC.DESCRIPTION NOT IN ('AEH','AHC','AHI','OHC')
            ORDER BY
                REG.ID DESC
        ) OPN
        GROUP BY ITEMID,STOCK_ID,DEPTID
    ) OPN_GRP
    GROUP BY ITEMID,DEPTID
  HAVING SUM(OPENING) > 0
) CLS_OPN_ALL
GROUP BY ITEMID,DEPTID

