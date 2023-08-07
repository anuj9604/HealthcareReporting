use healthcare;

/* 1 */

select pharmacyname, count(hospitalExclusive) as cnt_h_exc_meds
from treatment
left join prescription using (treatmentID)
left join contain using (prescriptionID)
left join pharmacy using (pharmacyID)
left join medicine using (medicineID)
where year(date) in ('2021', '2022') and hospitalExclusive='S'
group by pharmacyID
order by cnt_h_exc_meds desc;

/* 2 */

-- Approach1
-- select planName, companyName, count(*) as cnt_claims
-- from claim
-- left join insuranceplan using (UIN)
-- left join insurancecompany using (companyID)
-- group by UIN
-- order by cnt_claims desc;

-- Approach2
select planName, companyName, count(*) as cnt_claims
from insuranceplan
left join claim using (UIN)
left join insurancecompany using (companyID)
group by UIN
order by cnt_claims desc;

/* 3 */

with cte1 as (
select companyID, companyName, planName, count(*) as cnt_claims
from claim
left join insuranceplan using (UIN)
left join insurancecompany using (companyID)
group by uin
)

select *
from cte1 as t1
where t1.cnt_claims = (
select max(t2.cnt_claims)
from cte1 as t2
where t1.companyID=t2.companyID
) or t1.cnt_claims = (
select min(t3.cnt_claims)
from cte1 as t3
where t1.companyID=t3.companyID
)
order by companyID
;

/* 4 */

with cte as (
select *
from treatment
right join person
on treatment.patientID=person.personID
left join address using (addressID)
)

select state,
count(distinct personID) as cnt_state_pop,
count(distinct patientID) as cnt_state_ptnts,
round(count(distinct personID)/count(distinct patientID), 2) as `people to patient ratio`
from cte
group by state
order by `people to patient ratio`;

/* 5 */

select pharmacyName, sum(quantity) as cnt_meds
from contain
left join medicine using (medicineID)
left join prescription using (prescriptionID)
left join treatment using (treatmentID)
left join pharmacy using (pharmacyID)
left join address using (addressID)
where state='AZ' and year(date)='2021' and taxcriteria='I'
group by pharmacyID
order by cnt_meds;



