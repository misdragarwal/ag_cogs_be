SELECT BILLED AS branch,TRANSACTION_DATE AS trans_date,SUM(QUANTITY) AS 'BILL_COUNT',SUM(NET_AMOUNT) AS 'AMOUNT' FROM `revenue_details` WHERE ITEMNAME ='AVA FOR GLAUCOMA' AND TRANSACTION_DATE BETWEEN ? AND ? GROUP BY BILLED,TRANSACTION_DATE