SELECT
parent_branch
, region
, branch
, SUM(cash_amount) AS cash_amount
, SUM(cash_deposit) AS cash_deposit
, SUM(cash_admin) AS cash_admin
, (SUM(cash_deposit)+SUM(cash_admin))-SUM(cash_amount) AS cash_diff
, SUM(card_amount) AS card_amount
, SUM(card_deposit) AS card_deposit
, SUM(card_admin) AS card_admin
, (SUM(card_deposit)+SUM(card_admin))-SUM(card_amount) AS card_diff
FROM (
SELECT
parent_branch
, branch
, region
, sum(cash_amount) as cash_amount
, sum(cash_deposit) AS cash_deposit
, 0 AS cash_admin
, 0 AS cash_diff
, sum(card_amount) as card_amount
, sum(card_deposit) AS card_deposit
, 0 AS card_admin
, 0 AS card_diff
FROM
collection_recon_aprtojun2021
group by
parent_branch
, branch
, region
UNION ALL
SELECT
parent_branch
, branch
, region
, sum(cash_amount) as cash_amount
, 0 AS cash_deposit
, 0 AS cash_admin
, 0 AS cash_diff
, sum(card_amount) as card_amount
, 0 AS card_deposit
, 0 AS card_admin
, 0 AS card_diff
FROM
collection_recon
WHERE
payment_or_refund_date<=DATE_SUB(CURDATE(), INTERVAL 1 DAY)
group by
parent_branch
, branch
, region
UNION ALL
SELECT
parent_branch
, branch
, region
, 0 AS cash_amount
, sum(cash_deposit) as cash_deposit
, sum(cash_admin) as cash_admin
, sum(cash_diff) as cash_diff
, 0 AS card_amount
, sum(card_deposit) as card_depotsit
, sum(card_admin) as card_admin
, sum(card_diff) as card_diff
FROM
collection_recon
WHERE
payment_or_refund_date<=CURDATE()
group by
parent_branch
, branch
, region
)
AS A
group by
parent_branch
, region
, branch