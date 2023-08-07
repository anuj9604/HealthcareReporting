/* 1 */

/* Method 1 */
explain
select coalesce(state, 'All states') as states,
coalesce(gender, 'All genders') as genders,
count(treatmentID) as treatments_cnt
from treatment
left join person on treatment.patientID=person.personID
left join address using (addressID)
left join disease using (diseaseID)
where diseasename='Autism'
group by state, gender with rollup;

/* Method 2 */
select case
	when grouping(state) then 'All States'
	else state
end as states,
case
	when grouping(gender) then 'All Genders'
	else gender
end as genders,
count(treatmentID) as treatments_cnt
from treatment
left join person on treatment.patientID=person.personID
left join address using (addressID)
left join disease using (diseaseID)
where diseasename='Autism'
group by state, gender with rollup;

/* 2 */
explain
with cte1 as (
select uin, year(date) as year, count(claim.claimID) as claim_cnt
from treatment
left join claim using (claimID)
left join insuranceplan using (UIN)
where year(date) in (2020, 2021, 2023) and claim.claimID is not null
group by uin, year(date) with rollup
order by uin
), cte2 as (
select (
 select planname
 from insuranceplan
 where cte1.uin=insuranceplan.uin
) as Insurance_Plan,
(
 select companyname
 from insuranceplan
 left join insurancecompany using (companyid)
 where cte1.uin=insuranceplan.uin
) as Insurance_Company,
coalesce(year, 'All Years') as years,
claim_cnt
from cte1
where uin is not null
)

select *
from cte2
order by Insurance_Plan, years;

/* 3 */
explain
with cte1 as (
select state, diseasename,
count(treatmentID) as cnt
from treatment
left join person
on treatment.patientID=person.personID
left join address using (addressID)
left join disease using (diseaseID)
where year(date)='2022'
group by state, diseasename with rollup
), cte2 as (
select coalesce(cte1.state, 'All States') as states,
coalesce(cte1.diseasename, 'All Diseases') as diseases,
cnt,
row_number() over(partition by state order by cnt desc) as max_cnt_rnk,
row_number() over(partition by state order by cnt asc) as min_cnt_rnk
from cte1
)

select states, diseases, cnt
from cte2
where max_cnt_rnk in (1,2) or min_cnt_rnk=1
;

/* 4 */
explain
with cte1 as (
select (
select diseasename
from disease as d
where d.diseaseID = drvd_tbl.diseaseID
) as diseasename,
(
select pharmacyName
from pharmacy as ph
where ph.pharmacyID = drvd_tbl.pharmacyID
) as pharmacyname,
prsc_cnt
from (
select diseaseID, pharmacyID, count(prescriptionID) as prsc_cnt
from treatment
left join disease using (diseaseID)
left join prescription using (treatmentID)
left join pharmacy using (pharmacyID)
where year(date)='2022'
group by diseaseID, pharmacyID with rollup
) as drvd_tbl
)

select coalesce(diseasename, '/--All--/') as diseases,
coalesce(pharmacyname, '/--All--/') as pharmacies,
prsc_cnt
from cte1;

/* 5 */

select coalesce(diseasename, '/--All--/') as diseases,
coalesce(gender, '/--All--/') as genders,
trt_cnt
from (
select diseasename, gender, count(treatmentID) as trt_cnt
from treatment
left join person
on treatment.patientID = person.personID
left join disease using (diseaseID)
where year(date)='2022'
group by diseasename, gender with rollup
) as drvd_tbl
;