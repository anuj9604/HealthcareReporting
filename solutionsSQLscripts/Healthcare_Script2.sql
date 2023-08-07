use healthcare;

/* 1 */

select city,
count(distinct pharmacyID)/count(prescriptionID) as `number of pharmacy to prescription`
from pharmacy
left join address using (addressID)
left join prescription using (pharmacyID)
group by city
having count(prescriptionID)>100
order by `number of pharmacy to prescription`
limit 3;

/* 2 */
explain
with cte1 as (
select city, diseaseName, count(*) as patient_count
from treatment
left join person
on treatment.patientID=person.personID
left join address using (addressID)
left join disease using (diseaseID)
where state='AL'
group by city, diseaseName
),cte2 as (
select city, max(patient_count) as maxi
from cte1
group by city
)

-- select city, group_concat(diseaseName), max(patient_count)
-- from cte1
-- group by city;


select *
from cte1
where exists(
select *
from cte2
where cte1.city=cte2.city and cte1.patient_count=cte2.maxi
);

/* 3 */
with cte1 as (
select diseaseName, planName, count(*) as counter
from treatment
left join claim using (claimID)
left join insuranceplan using (UIN)
left join disease using (diseaseID)
where claim.claimID is not NULL
group by disease.diseaseID, insuranceplan.uin
), cte2 as (
select diseaseName, max(counter) as maxy
from cte1
group by diseaseName
)


select *
from cte1
where exists(
select *
from cte2
where cte1.diseaseName=cte2.diseaseName and cte1.counter=cte2.maxy
)
order by diseaseName;

/* 4*/

select diseasename, count(*)
from (select diseasename, address1, city, state, count(*)
from treatment
left join person
on treatment.patientID=person.personID
left join disease using (diseaseID)
inner join address using (addressID)
group by diseaseID, addressID
having count(*)>1
order by diseaseName) as dis_add_cnt
right join disease using (diseasename)
group by diseasename
;

/* 5 */
select state, round(count(treatmentID)/count(claimID), 2) as treat_to_claim
from treatment
left join person
on treatment.patientID=person.personID
left join address using (addressID)
where date between '2021-04-1' and '2022-03-31'
group by state
order by treat_to_claim desc;

-- create index treatment_date
-- on treatment (date);
-- 
-- alter table treatment
-- drop index treatment_date;