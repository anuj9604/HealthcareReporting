use healthcare;

create view `complete treatment details` as
select t.*,
cl.balance,
inspl.UIN, inspl.planName,
inscom.companyID, inscom.companyName as insurance_comp_name , inscom.addressID as companyAdd,
presc.prescriptionID,
pharm.pharmacyID, pharm.pharmacyName, pharm.phone, pharm.addressID as pharmAdd,
cont.quantity,
med.*,
pers.personID, pers.personName, pers.phoneNumber, pers.gender, pers.addressID as persAdd
from treatment as t
left join prescription as presc using (treatmentID)
left join pharmacy as pharm using (pharmacyID)
left join contain as cont using (prescriptionID)
left join medicine as med using (medicineID)
left join person as pers on t.patientID=pers.personID
left join claim as cl using (claimID)
left join insuranceplan as inspl using (UIN)
left join insurancecompany as inscom using (companyID)
;


/* 1 */

select pharmacyID, pharmacyName,
sum(quantity) as `meds ttl qty`,
sum(if(hospitalExclusive='S', quantity, 0)) as `hospExcl meds ttl qty`,
round(sum(if(hospitalExclusive='S', quantity, 0))/sum(quantity)*100, 2) as `% hosp Excl meds`
from `complete treatment details`
where year(date)='2022'
group by pharmacyID
order by `% hosp Excl meds` desc
;

/* 2 */

select state,
1-round((count(claimID)/count(treatmentid)), 2) as `% no claim ratio`
from `complete treatment details` as ctd
left join address
on ctd.persAdd=address.addressID
group by state
order by `% no claim ratio` desc
;

/* 3 */

with cte1 as (
select state, diseaseID, diseaseName, count(*) as cnt_treatments
from treatment
left join disease using (diseaseID)
left join person
on treatment.patientID=person.personID
left join address using (addressID)
group by state, diseaseID
order by state
)

select state,
	   (
	   select max(cnt_treatments)
	   from cte1 as tbl2
	   where tbl1.state=tbl2.state
	   ) as disease_cnt_max,
	   (
	   select min(cnt_treatments)
	   from cte1 as tbl3
	   where tbl1.state=tbl3.state
	   ) as disease_cnt_min
from cte1 as tbl1
group by state
;

/* 4 */

select city,
count(patientID) as pnt_cnt,
round(count(patientID)/count(personID)*100, 2) as `% pnt to people`
from person
left join patient on (person.personID=patient.patientID)
left join address using (addressID)
group by city
having count(personID)>=10
order by `% pnt to people` desc;

/* 5 */

select companyname, count(medicineID) as ranitidine_cnt
from medicine
where substanceName like '%ranitidina%'
group by companyname
order by ranitidine_cnt desc
limit 3;