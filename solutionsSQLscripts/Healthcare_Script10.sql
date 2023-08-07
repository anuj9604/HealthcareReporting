use healthcare;

/* 1 */

delimiter $$

create procedure insurance_plan_perf(in cmpny_id int)
begin
	with cte1 as (
				  select uin,
				  		 planname,
		          		 diseaseID,
		          		 diseaseName,
						 count(claimID) as claim_cnt
				  from treatment
		  		  left join disease using (diseaseID)
				  left join claim using (claimID)
			 	  left join insuranceplan using (uin)
				  left join insurancecompany using (companyID)
				  where companyID = cmpny_id
				  group by uin, diseaseID
				 ),cte2 as (
				  			select uin,
				  		    max(claim_cnt) as maxy
				  			from cte1
				  			group by uin
				 ), cte3 as (
				  			select uin,
		   		  			group_concat(diseasename) as disease_max_claimed_for
				  			from cte1
				  			where cte1.claim_cnt = (
						  				  			select maxy
						  				  			from cte2
						  				  			where cte1.uin=cte2.uin
						 				 			)
				  			group by uin
				 			)
	
	select planname,
		   sum(claim_cnt) as cnt_claim,
		   (
			select disease_max_claimed_for
			from cte3
			where cte1.uin=cte3.uin
		   ) as disease_max_claimed_for
	from cte1
	group by uin
	;

end $$

delimiter ;

call insurance_plan_perf(1409);

/* 2 */

delimiter //

create procedure preferred_pharma_disease(
in disease_name varchar(100)
)
begin
	
	with cte1 as (
	select row_number() over(order by count(treatmentID) desc) as cnt_rnk,
	pharmacyname,
	count(treatmentID) as cnt_rcrds2021
	from treatment
	left join prescription using (treatmentID)
	left join pharmacy using (pharmacyID)
	left join disease using (diseaseID)
	where year(date)='2021' and diseasename = disease_name
	group by pharmacyID
	order by cnt_rnk
	limit 3
	), cte2 as (
	select row_number() over(order by count(treatmentID) desc) as cnt_rnk,
	pharmacyname,
	count(treatmentID) as cnt_rcrds2022
	from treatment
	left join prescription using (treatmentID)
	left join pharmacy using (pharmacyID)
	left join disease using (diseaseID)
	where year(date)='2022' and diseasename = disease_name
	group by pharmacyID
	order by cnt_rnk
	limit 3
	)
	
	select cte1.pharmacyname,
	cnt_rcrds2021,
	cte2.pharmacyname,
	cnt_rcrds2022
	from cte1
	left join cte2 using (cnt_rnk)
	;

end //

delimiter ;

call preferred_pharma_disease('Asthma');

/* 3 */

delimiter $$

create procedure state_perf ()
begin

	declare avg_insurance_patient_ratio float;

	select avg(ins_ptnt_rto) into avg_insurance_patient_ratio
	from (select count(distinct patientID)/count(distinct insurancecompany.companyID) as ins_ptnt_rto
	from treatment
	left join person
	on treatment.patientID = person.personID
	left join address using (addressID)
	left join claim using (claimID)
	left join insuranceplan using (uin)
	left join insurancecompany using (companyID)
	group by state) as drvd_tbl
	;

	select state,
	count(distinct patientID) as num_patients,
	count(distinct insurancecompany.companyID) as num_insurance_companies,
	count(distinct patientID)/count(distinct insurancecompany.companyID) as insurance_patient_ratio,
	case
		when count(distinct patientID)/count(distinct insurancecompany.companyID) < avg_insurance_patient_ratio then 'Recommended'
		else 'Not Recommended'
	end as Recommendation
	from treatment
	left join person
	on treatment.patientID = person.personID
	left join address using (addressID)
	left join claim using (claimID)
	left join insuranceplan using (uin)
	left join insurancecompany using (companyID)
	group by state
	;
    
end $$

delimiter ;

call state_perf();

/* 4 */

create table if not exists PlacesAdded (
placeID int primary key auto_increment,
placeName VARCHAR(100) NOT NULL,
placeType ENUM('city', 'state') NOT NULL,
timeAdded timestamp default now()
);

delimiter $$

create trigger new_place
after insert
on address
for each row
begin
	if new.city not in (select placeName from placesAdded) then
		insert into placesAdded (placeName, placeType)
        values (new.city, 'city');
	end if;
    
    if new.state not in (select placeName from placesAdded) then
		insert into placesAdded (placeName, placeType)
        values (new.state, 'state');
	end if;
    
end $$

delimiter ;

/* 5 */

create table if not exists Keep_Log (
id int primary key auto_increment,
medicineID int,
quantity int,
timeAdded timestamp default now()
);

delimiter $$

create trigger med_inventory_chk
before update
on keep
for each row
begin
	insert into Keep_Log (medicineID, quantity)
    values (old.medicineID, new.quantity-old.quantity);
end $$

delimiter ;