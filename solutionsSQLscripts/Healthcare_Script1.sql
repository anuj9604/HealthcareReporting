/* 1 */
use healthcare;

select age_group, count(*) as count
from (
select case
	when (datediff(date, dob) div 365.25) < 15 then 'Childeren'
	when (datediff(date, dob) div 365.25) between 15 and 24 then 'Youth'
	when (datediff(date, dob) div 365.25) between 25 and 64 then 'Adults'
	else 'Seniors'
end as age_group
from treatment
left join patient using (patientID)
where year (date) = '2022'
) as derived_tbl
group by age_group;

/* 2 */

explain

with cte as (
select diseaseID, diseasename, gender
from treatment
left join disease using (diseaseID) 
left join person
on treatment.patientID=person.personID
), sub_cte1 as (
select diseasename, count(*) as male_count
from cte
where gender='male'
group by diseaseID
), sub_cte2 as (
select diseasename, count(*) as female_count
from cte
where gender='female'
group by diseaseID
)

select sub_cte1.diseasename, round(male_count/female_count, 2) as male_to_female_ratio
from sub_cte1
inner join sub_cte2 using(diseasename);

/* 3 */

select gender,
count(*) as `# of treatment`,
count(claimID) as `# of claims`,
round(count(*)/count(claimID), 2) as `treatment to claim ratio`
from treatment
left join person
on treatment.patientID=person.personID
group by gender;

/* 4 */

/* Interpretation 1 */
select pharmacyname, productname, sum(quantity),
sum(quantity*maxPrice) as total_MRP,
sum(quantity*maxPrice-0.01*quantity*maxPrice*discount) as total_discounted
from keep
left join medicine using (medicineID)
left join pharmacy using (pharmacyID)
group by pharmacyID, medicineID;

/* Interpretation 2 */
select pharmacyname, sum(quantity),
sum(quantity*maxPrice) as total_MRP,
sum(quantity*maxPrice-0.01*quantity*maxPrice*discount) as total_discounted
from keep
left join medicine using (medicineID)
left join pharmacy using (pharmacyID)
group by pharmacyID;

/* 5 */

explain select pharmacyID,
max(count_meds) as max_count_meds,
min(count_meds) as min_count_meds,
round(avg(count_meds), 2) as avg_count_meds
from (
select pharmacyID, prescriptionID, sum(quantity) as count_meds
from prescription
left join contain using(prescriptionID)
group by pharmacyID, prescriptionID
) as t
group by pharmacyID;

