use healthcare;

/* 1 */

(select case
	when productType=1 then 'Generic'
	when productType=2 then 'Patent'
	else 'Reference'
end as med_category,
medicine.*
from medicine
where productType in (1,2,3) and taxCriteria='I')
union
(select case
	when productType=4 then 'Similar'
	when productType=5 then 'New'
	else 'Specific'
end as med_category,
medicine.*
from medicine
where productType in (4,5,6) and taxCriteria='II')
;

/* 2 */

set @ally_id=(select pharmacyID from pharmacy where pharmacyName='Ally Scripts');

select prescriptionID,
sum(quantity) as totalQuantity,
case
	when sum(quantity)<20 then 'Low Quantity'
	when sum(quantity) between 20 and 49 then 'Medium Quantity'
	else 'High Quantity'
end as Tag
from prescription
left join contain using (prescriptionID)
where pharmacyID=@ally_id
group by prescriptionID;

-- explain
-- select prescriptionID,
-- sum(quantity) as totalQuantity,
-- case
-- 	when sum(quantity)<20 then 'Low Quantity'
-- 	when sum(quantity) between 20 and 49 then 'Medium Quantity'
-- 	else 'High Quantity'
-- end as Tag
-- from prescription
-- left join contain using (prescriptionID)
-- left join pharmacy using (pharmacyID)
-- where pharmacyName='Ally Scripts'
-- group by prescriptionID;

/* 3 */
set @spotrx_id=(select pharmacyID from pharmacy where pharmacyname='Spot Rx');

select productName,
medicineid,
case
	when quantity>7500 then 'HIGH'
	when quantity<1000 then 'LOW'
	else 'N/A'
end as quantity_cat,
case
	when discount=0 then 'NONE'
	when discount>=30 then 'HIGH'
	else 'N/A'
end as discount_cat
from keep
left join medicine using (medicineID)
where pharmacyID=@spotrx_id and ((quantity>7500 and discount=0) or (quantity<1000 and discount>=30))
;

/* 4 */

set @avg_maxprice = (select avg(maxPrice) from medicine);

/* Approach1 */
select medicineid, productname,
case
	when maxPrice<(0.5*@avg_maxprice) then 'Affordable'
	else 'Costly'
end as Affordability
from medicine
where maxPrice<(0.5*@avg_maxprice) or maxPrice>(2*@avg_maxprice)
;

/* Approach2 */
select *
from (select medicineid, productname,
if(maxPrice<(0.5*@avg_maxprice),
	'Affordable', if(maxPrice>(2*@avg_maxprice),
					'Costly', 'N/A')
  ) as Affordability
from medicine) as derived_tbl
where affordability <> 'N/A'
;

/* 5 */

select personName, gender, dob,
case
	when dob>'2005-01-01' and gender='male' then 'YoungMale'
	when dob>'2005-01-01' and gender='female' then 'YoungFemale'
	when dob between ('1985-01-01' and '2005-01-01') and gender='male' then 'AdultMale'
	when dob between ('1985-01-01' and '2005-01-01') and gender='female' then 'AdultFemale'
	when dob between ('1970-01-01' and '1984-12-31') and gender='male' then 'MidAgeMale'
	when dob between ('1970-01-01' and '1984-12-31') and gender='female' then 'MidAgeFemale'
	when dob<'1970-01-01' and gender='male' then 'ElderMale'
	when dob<'1970-01-01' and gender='female' then 'ElderFemale'
	else 'N/A'
end as age_category
from patient
left join person
on patient.patientID = person.personID;