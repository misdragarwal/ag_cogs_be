SELECT PARENT_BRANCH,BRANCH,SUM(CASH_AMOUNT) AS CASH_AMOUNT,SUM(CASH_DEPOSIT) AS CASH_DEPOSIT,
SUM(CARD_AMOUNT) AS CARD_AMOUNT,SUM(CARD_DEPOSIT) AS CARD_DEPOSIT,SUM(CASH_ADMIN) AS CASH_ADMIN,SUM(CARD_ADMIN) AS CARD_ADMIN
FROM collection_recon AS cr
WHERE cr.BRANCH= ? AND cr.PAYMENT_OR_REFUND_DATE BETWEEN ? AND ?
 -- WHERE cr.PAYMENT_OR_REFUND_DATE BETWEEN ? AND ?
--  AND cr.BRANCH= ?
 GROUP BY
 BRANCH
