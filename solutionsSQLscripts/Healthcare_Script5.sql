use healthcare;

/* 1 */

select personname, count(treatmentid) as cnt_treatments, datediff(curdate(), dob) div 365.25 as age
from treatment
left join patient using (patientID)
left join person
on patient.patientid=person.personid
group by personid, dob
order by cnt_treatments desc;

/* 2 */

with main_cte as
(
select diseaseID, diseasename, gender,
count(treatmentid) as gndr_cnt
from treatment as t1
left join person
on t1.patientID=person.personID
left join disease using (diseaseID)
group by diseaseID, gender
), cte2 as (
select diseaseID, diseasename, gndr_cnt as gndr_cnt_fm
from main_cte
where gender='female'
), cte3 as (
select diseaseID, diseasename, gndr_cnt as gndr_cnt_m
from main_cte
where gender='male'
)

select cte2.diseasename,
gndr_cnt_m, gndr_cnt_fm,
round(gndr_cnt_m/gndr_cnt_fm, 2) as `male to female ratio`
from cte2
inner join cte3 using (diseaseID)
order by `male to female ratio` desc
;

/* 3 */

select diseasename,
	   city,
	   city_trmnt_cnt
from (
	  select *,
		   rank() over(partition by diseaseID order by city_trmnt_cnt desc) as ranku
	from (
		  select diseaseID,
				 diseasename,
				 city,
				 count(treatmentid) as city_trmnt_cnt
		  from treatment
		  left join person
		  on treatment.patientID=person.personid
		  left join address using (addressID)
		  left join disease using (diseaseID)
		  group by diseaseID, city
		 ) as derived_tbl1
	 ) as derived_tbl2
where ranku<4
;

/* 4 */

select pharmacyname,
diseasename,
(
select count(if(year(date)='2021', 1, NULL))
from pharmacy as pharm2
left join prescription using (pharmacyID)
left join treatment using (treatmentID)
left join disease as dis2 using (diseaseID)
where pharm2.pharmacyID=pharm1.pharmacyID and dis2.diseaseID=dis1.diseaseID
) as presc_cnt_2021,
(
select count(if(year(date)='2022', 1, NULL))
from pharmacy as pharm2
left join prescription using (pharmacyID)
left join treatment using (treatmentID)
left join disease as dis2 using (diseaseID)
where pharm2.pharmacyID=pharm1.pharmacyID and dis2.diseaseID=dis1.diseaseID
) as presc_cnt_2022
from pharmacy as pharm1
cross join disease as dis1
;

/* 5 */

with cte1 as (
select companyID, companyname, state, count(treatmentID) as cnt_plns
from treatment
left join person
on treatment.patientID=person.personID
left join address using (addressID)
left join claim using (claimID)
left join insuranceplan using (UIN)
left join insurancecompany using (companyID)
where claim.claimID is not NULL
group by companyID, state
order by companyID
)

select companyname, state, cnt_plns
from cte1 as tbl1
where cnt_plns = (
				  select max(cnt_plns)
				  from cte1 as tbl2
				  where tbl1.companyID=tbl2.companyID
				  );

