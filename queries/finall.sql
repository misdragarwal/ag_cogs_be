SELECT * FROM (SELECT * FROM (SELECT   CASE
           WHEN Approval_status=0 THEN 'Need SCH Approval'
           WHEN Approval_status=1 THEN 'Pending'
           WHEN Approval_status=2 THEN 'Approved'
           WHEN Approval_status=3 THEN 'Cancelled By sch'
           WHEN Approval_status=4 THEN 'Cancelled'
       END AS drtApproval_status,bill.Comments AS billcomments,drcus.NAME AS 'DRTNAME',date(bill.Created_on) as 'Drt_Created_on',date(bill.Approved_time) as 'Drt_Approved_time',date(bill.Admin_Approved_time) as 'Drt_Admin_Approved_time',date(bill.Cancelled_time) as 'Drt_Cancelled_time',bill.*
,usr.name AS 'CH_Name',usr.branches as 'CH_branch',schusr.name AS 'SCH_Name',schusr.branches as 'SCH_Branch'
,drcus.Infavour_of,drcus.Payment_type,drcus.Pan_no,concat("'",drcus.Account_no) as Account_no,drcus.Bank_ifsc,drcus.Bank_name
       FROM drt_bills AS bill
INNER JOIN `drt_customer` AS drcus ON bill.Drt_id=drcus.ID
INNER JOIN `users` AS usr ON usr.emp_id=bill.Created_by AND usr.role='ch_user'
left JOIN `users` AS schusr ON schusr.emp_id=bill.Sch_Approved_by AND schusr.role='sch_user'
WHERE (bill_date between ? and ?) AND Approval_status=1 ORDER BY Approved_time DESC) AS a ORDER BY Billed_branch ASC )AS a1
UNION
SELECT * FROM (SELECT * FROM (SELECT   CASE
           WHEN Approval_status=0 THEN 'Need SCH Approval'
           WHEN Approval_status=1 THEN 'Pending'
           WHEN Approval_status=2 THEN 'Approved'
           WHEN Approval_status=3 THEN 'Cancelled By sch'
           WHEN Approval_status=4 THEN 'Cancelled'
       END AS drtApproval_status,bill.Comments AS billcomments,drcus.NAME AS 'DRTNAME',date(bill.Created_on) as 'Drt_Created_on',date(bill.Approved_time) as 'Drt_Approved_time',date(bill.Admin_Approved_time) as 'Drt_Admin_Approved_time',date(bill.Cancelled_time) as 'Drt_Cancelled_time',bill.*
,usr.name AS 'CH_Name',usr.branches as 'CH_branch',schusr.name AS 'SCH_Name',schusr.branches as 'SCH_Branch'
,drcus.Infavour_of,drcus.Payment_type,drcus.Pan_no,concat("'",drcus.Account_no) as Account_no,drcus.Bank_ifsc,drcus.Bank_name
FROM drt_bills AS bill
INNER JOIN `drt_customer` AS drcus ON bill.Drt_id=drcus.ID
INNER JOIN `users` AS usr ON usr.emp_id=bill.Created_by AND usr.role='ch_user'
left JOIN `users` AS schusr ON schusr.emp_id=bill.Sch_Approved_by AND schusr.role='sch_user'
WHERE (bill_date between ? and ?) AND Approval_status=2 ORDER BY Admin_Approved_time DESC ) AS b ORDER BY Billed_branch ASC) AS b1
UNION
SELECT * FROM(SELECT * FROM(
SELECT   CASE
           WHEN Approval_status=0 THEN 'Need SCH Approval'
           WHEN Approval_status=1 THEN 'Pending'
           WHEN Approval_status=2 THEN 'Approved'
           WHEN Approval_status=3 THEN 'Cancelled By sch'
           WHEN Approval_status=4 THEN 'Cancelled'
           END AS drtApproval_status,bill.Comments AS billcomments,drcus.NAME AS 'DRTNAME',date(bill.Created_on) as 'Drt_Created_on',date(bill.Approved_time) as 'Drt_Approved_time',date(bill.Admin_Approved_time) as 'Drt_Admin_Approved_time',date(bill.Cancelled_time) as 'Drt_Cancelled_time',bill.*
,usr.name AS 'CH_Name',usr.branches as 'CH_branch',schusr.name AS 'SCH_Name',schusr.branches as 'SCH_Branch'
,drcus.Infavour_of,drcus.Payment_type,drcus.Pan_no,concat("'",drcus.Account_no) as Account_no,drcus.Bank_ifsc,drcus.Bank_name
       FROM drt_bills AS bill
INNER JOIN `drt_customer` AS drcus ON bill.Drt_id=drcus.ID
INNER JOIN `users` AS usr ON usr.emp_id=bill.Created_by AND usr.role='ch_user'
left JOIN `users` AS schusr ON schusr.emp_id=bill.Sch_Approved_by AND schusr.role='sch_user'
WHERE (bill_date between ? and ?) AND Approval_status=4 ORDER BY Approved_time DESC
) AS c ORDER BY Billed_branch ASC)AS c1
UNION
SELECT * FROM (SELECT * FROM (
SELECT   CASE
           WHEN Approval_status=0 THEN 'Need SCH Approval'
           WHEN Approval_status=1 THEN 'Pending'
           WHEN Approval_status=2 THEN 'Approved'
           WHEN Approval_status=3 THEN 'Cancelled By sch'
           WHEN Approval_status=4 THEN 'Cancelled'
        END AS drtApproval_status,bill.Comments AS billcomments,drcus.NAME AS 'DRTNAME',date(bill.Created_on) as 'Drt_Created_on',date(bill.Approved_time) as 'Drt_Approved_time',date(bill.Admin_Approved_time) as 'Drt_Admin_Approved_time',date(bill.Cancelled_time) as 'Drt_Cancelled_time',bill.*
,usr.name AS 'CH_Name',usr.branches as 'CH_branch',schusr.name AS 'SCH_Name',schusr.branches as 'SCH_Branch'
,drcus.Infavour_of,drcus.Payment_type,drcus.Pan_no,concat("'",drcus.Account_no) as Account_no,drcus.Bank_ifsc,drcus.Bank_name
FROM drt_bills AS bill
INNER JOIN `drt_customer` AS drcus ON bill.Drt_id=drcus.ID
INNER JOIN `users` AS usr ON usr.emp_id=bill.Created_by AND usr.role='ch_user'
left JOIN `users` AS schusr ON schusr.emp_id=bill.Sch_Approved_by AND schusr.role='sch_user'
WHERE (bill_date between ? and ?) AND Approval_status=3 ORDER BY Cancelled_time DESC
)AS d ORDER BY Billed_branch ASC ) AS d1
UNION
SELECT * FROM (SELECT * FROM (
SELECT   CASE
           WHEN Approval_status=0 THEN 'Need SCH Approval'
           WHEN Approval_status=1 THEN 'Pending'
           WHEN Approval_status=2 THEN 'Approved'
           WHEN Approval_status=3 THEN 'Cancelled By sch'
           WHEN Approval_status=4 THEN 'Cancelled'
        END AS drtApproval_status,bill.Comments AS billcomments,drcus.NAME AS 'DRTNAME',date(bill.Created_on) as 'Drt_Created_on',date(bill.Approved_time) as 'Drt_Approved_time',date(bill.Admin_Approved_time) as 'Drt_Admin_Approved_time',date(bill.Cancelled_time) as 'Drt_Cancelled_time',bill.*
,usr.name AS 'CH_Name',usr.branches as 'CH_branch',schusr.name AS 'SCH_Name',schusr.branches as 'SCH_Branch'
,drcus.Infavour_of,drcus.Payment_type,drcus.Pan_no,concat("'",drcus.Account_no) as Account_no,drcus.Bank_ifsc,drcus.Bank_name
       FROM drt_bills AS bill
INNER JOIN `drt_customer` AS drcus ON bill.Drt_id=drcus.ID
INNER JOIN `users` AS usr ON usr.emp_id=bill.Created_by AND usr.role='ch_user'
left JOIN `users` AS schusr ON schusr.emp_id=bill.Sch_Approved_by AND schusr.role='sch_user'
WHERE (bill_date between ? and ?) AND Approval_status=0 ORDER BY Created_on DESC
)AS e ORDER BY Billed_branch ASC) AS e1
