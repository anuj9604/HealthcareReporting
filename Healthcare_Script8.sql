use healthcare;

/* 1 */
-- For each age(in years), how many patients have gone for treatment?

-- Optimized Query
-- Changed * to patientID

-- Ans 1
-- Using YEAR in DATEDIFF instead of hour
SELECT 
	DATEDIFF(year, dob , GETDATE()) AS age, 
	count(Treatment.patientID) AS numTreatments
FROM Person
JOIN Patient ON Patient.patientID = Person.personID
JOIN Treatment ON Treatment.patientID = Patient.patientID
group by DATEDIFF(year, dob , GETDATE())
order by numTreatments desc;

-- Ans 2
-- Tried to avoid date func in groupBy
with cte as
(SELECT 
	DATEDIFF(year, dob , GETDATE()) AS age, 
	1 as cnt
FROM Person
JOIN Patient ON Patient.patientID = Person.personID
JOIN Treatment ON Treatment.patientID = Patient.patientID
)
select
	age
	,sum(cnt) AS numTreatments
from cte
group by age
order by numTreatments desc;


/* 2 */
-- Rather than creating 3 separate permanent tables, to save the data.
-- we do a left join on all relevant tables.
select
	a.city
	,count(pn.personID) as numRegisteredPeople
	,count(p.pharmacyID) as numInsuranceCompany
	,count(ic.companyID) as numPharmacy
from Address a
left join Pharmacy p on p.addressID = a.addressID
left join InsuranceCompany ic on ic.addressID = a.addressID
left join Person pn on pn.addressID = a.addressID
group by a.city;


/* 3 */
-- Total quantity of medicine for each prescription prescribed by Ally Scripts
-- If the total quantity of medicine is less than 20 tag it as "Low Quantity".
-- If the total quantity of medicine is from 20 to 49 (both numbers including) tag it as "Medium Quantity".
-- If the quantity is more than equal to 50 then tag it as "High quantity".

-- Rather than filtering using pharmacy name, we set a variable setting
-- pharmacy ID fo Ally Script and use that, as it is an indexed attribute
set @id = null;

select pharmacyId into @id
from pharmacy
where pharmacyName = 'Ally Scripts';

select
contain.prescriptionID, sum(contain.quantity) as totalQuantity,
CASE WHEN sum(quantity) < 20 THEN 'Low Quantity'
WHEN sum(quantity) < 50 THEN 'Medium Quantity'
ELSE 'High Quantity' END AS Tag

FROM contain
JOIN prescription using (prescriptionID)
JOIN pharmacy using (pharmacyID)
where pharmacy.pharmacyID = @id
group by contain.prescriptionID;


/* 4 */
-- The total quantity of medicine in a prescription is the sum of the quantity of all the medicines in the prescription.
-- Select the prescriptions for which the total quantity of medicine exceeds
-- the avg of the total quantity of medicines for all the prescriptions.

-- The question aked is Prescription who exceed avg medicine quantity in single prescripotion
-- So I neglected Pharmacy join and used CTE and avoid creating a new table
with cte as
(select  Prescription.prescriptionID, sum(quantity) as totalQuantity
from Prescription
join Contain on Contain.prescriptionID = Prescription.prescriptionID
join Medicine on Medicine.medicineID = Contain.medicineID
join Treatment on Treatment.treatmentID = Prescription.treatmentID
where YEAR(date) = 2022
group by Prescription.prescriptionID)
select
	prescriptionID
	,totalQuantity
from cte
where totalQuantity > (select avg(totalQuantity) from cte);

/* 5 */
-- Select every disease that has 'p' in its name, and 
-- the number of times an insurance claim was made for each of them. 

-- To count Claim ID we only need Treatment table
-- Joining Disease table for name check, and changed the where condition by removing sub-query

SELECT Disease.diseaseName, COUNT(Treatment.claimID) as numClaims
FROM Disease
JOIN Treatment ON Disease.diseaseID = Treatment.diseaseID
WHERE diseaseName LIKE '%p%'
GROUP BY diseaseName;