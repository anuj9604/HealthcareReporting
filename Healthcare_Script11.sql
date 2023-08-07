use healthcare;

/* 1 */

delimiter $$

create procedure find_pharma (
in med_id int
)
begin

	select pharmacyName, phone, quantity as units_available
	from keep
	left join pharmacy using (pharmacyID)
	where medicineID = med_id and quantity>0;

end $$

delimiter ;

call find_pharma(207);

/* 2 */

delimiter $$

create function avg_presc_value_per_pharm (pharm_id int, year int)
returns float
deterministic
begin
	
    declare avg_presc_val float;
    
	with cte1 as (
	select prescriptionID, SUM(contain.quantity*maxPrice*(1-coalesce(discount*0.01, 0))) as total_value
	from pharmacy
	left join prescription using (pharmacyID)
	left join treatment using (treatmentID)
	left join contain using (prescriptionID)
	left join medicine using (medicineID)
	left join keep using (pharmacyID, medicineID)
	where pharmacyID = pharm_id and year(date) = year
	group by prescriptionID
	)

	select round(avg(total_value), 2) into avg_presc_val
	from cte1;
    
    return avg_presc_val;

end $$

delimiter ;

select avg_presc_value_per_pharm(1008, 2021) as average_prescription_value;

select avg_presc_value_per_pharm(1204, 2022) as average_prescription_value;

select avg_presc_value_per_pharm(9869, 2020) as average_prescription_value;

/* 3 */

delimiter $$

create procedure most_spread_disease_in_state (
in state_ varchar(20),
in year_ int
)
begin

	with cte1 as (
	select diseaseName, count(treatmentID) as trt_cnt
	from treatment
	left join person on treatment.patientID = person.personID
	left join address using (addressID)
	left join disease using (diseaseID)
	where state = state_ and year(date) = year_
	group by diseaseID
	)

	select diseaseName, trt_cnt
	from cte1
	where trt_cnt = (
	select max(trt_cnt)
	from cte1
	);
    
end $$

delimiter ;

call most_spread_disease_in_state('MA', 2020);

/* 4 */

delimiter $$

create function trt_cnt_CityDiseaseYear (
_city varchar(100),
_disease varchar(100),
_year int
)
returns int
deterministic
begin

	declare count int;
    select count(treatmentID) into count
    from `complete treatment details` as ctd
    left join address on ctd.persAdd = address.addressID
    left join disease using (diseaseID)
    where city = _city and diseaseName = _disease and year(date) = _year
	;
   
return count;
   
end $$

delimiter ;

-- drop function if exists trt_cnt_CityDiseaseYear;

select trt_cnt_CityDiseaseYear('Medford', 'Asthma', 2021) as treatment_count;

/* 5 */

delimiter $$

create function avg_claim_bal (
_company_id int
)
returns float
deterministic
begin
	
    declare avg_balance float;
    
    select round(avg(balance), 2) into avg_balance
	from treatment
	left join claim using (claimID)
	left join insuranceplan using (UIN)
	left join insurancecompany using (companyID)
	where year(date) = 2022 and insurancecompany.companyID = _company_id
	;
    
    return avg_balance;
    
end $$

delimiter ;

select avg_claim_bal(1409);