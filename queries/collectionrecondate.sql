SELECT
cr.PARENT_BRANCH,cr.BRANCH,cr.PAYMENT_OR_REFUND_DATE,SUM(cd.CASH_AMOUNT)+SUM(REFUND_CASH_AMOUNT)  AS CASH_AMOUNT
,cr.CASH_DEPOSIT AS CASH_DEPOSIT,
SUM(cd.CARD_AMOUNT)+SUM(CARD_SERVICE_CHARGE_AMOUNT)+SUM(REFUND_CARD_AMOUNT) AS CARD_AMOUNT,
cr.CARD_DEPOSIT AS CARD_DEPOSIT,
SUM(cd.CHEQUE_AMOUNT)+SUM(REFUND_CHEQUE_AMOUNT) AS CHEQUE_AMOUNT,
SUM(cd.FUND_TRANSFER_AMOUNT) AS FUND_TRANSFERAMOUNT,
SUM(cd.PAYTM_AMOUNT) AS PAYTM_AMOUNT,SUM(cd.DD_AMOUNT) AS DD_AMOUNT,
SUM(cd.ONLINE_AMOUNT) AS ONLINE_AMOUNT
,CH_REMARKS
  FROM collection_recon AS cr
 LEFT JOIN collection_detail AS cd ON cr.BRANCH=cd.BRANCH AND cr.PAYMENT_OR_REFUND_DATE=cd.PAYMENT_OR_REFUND_DATE
 WHERE cr.PAYMENT_OR_REFUND_DATE = ?
 AND cr.BRANCH=?
