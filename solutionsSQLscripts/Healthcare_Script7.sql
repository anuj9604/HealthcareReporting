use healthcare;

/* 1 */

delimiter $$

create procedure claims_higher_than_average (in disease_id int)
begin
	declare avg_claim_cnt float;
	declare disease_claim_cnt float;
	
	select count(claimID)/count(distinct diseaseID) into avg_claim_cnt
	from treatment
	left join disease using (diseaseID)
	;

	select count(claimID) into disease_claim_cnt
	from treatment
	left join disease using (diseaseID)
	where diseaseID=disease_id
	;

	if disease_claim_cnt > avg_claim_cnt then
		select "claimed higher than average";
	else
		select "lower than average";
	end if;
end $$

delimiter ;


/* 2 */

delimiter $$

create procedure genderwise_report (in disease_id int)
begin
	declare dis_name varchar(255);
	declare male_treated int;
	declare female_treated int;

	select diseasename into dis_name
	from disease
	where diseaseID=disease_id
	;

	select count(if(gender='male', 1, NULL)),
	count(if(gender='female', 1, NULL)) into
	male_treated, female_treated
	from treatment
	left join disease using (diseaseID)
	left join person on treatment.patientID=person.personID
	where diseaseID = disease_id
	;

	if male_treated > female_treated then
		select dis_name,
		male_treated as number_of_male_treated,
		female_treated as number_of_female_treated,
		'male';
	elseif male_treated = female_treated then
		select dis_name,
		male_treated as number_of_male_treated,
		female_treated as number_of_female_treated,
		'same';
	else
		select dis_name,
		male_treated as number_of_male_treated,
		female_treated as number_of_female_treated,
		'female';
	end if;
end $$

delimiter ;

/* 3 */
explain
(
select planname, companyname, 'Most Claimed' as clm_status
from treatment
inner join claim using (claimID)
left join insuranceplan using (UIN)
left join insurancecompany using (companyID)
group by uin
order by count(claimID) desc
limit 3
)
union
(
select planname, companyname, 'Least Claimed' as clm_status
from treatment
inner join claim using (claimID)
left join insuranceplan using (UIN)
left join insurancecompany using (companyID)
group by uin
order by count(claimID)
limit 3
)
;

/* 4 */

delimiter $$

create function age_cat (birth_date date, sex varchar(10))
returns varchar(50)
deterministic
begin
	declare age_cat varchar(50);
	if sex='male' then
		if birth_date > '2005-01-01' then
			set age_cat = 'Young Male';
		elseif birth_date < '2005-01-01' and birth_date >= '1985-01-01' then
			set age_cat = 'Adult Male';
		elseif birth_date < '1985-01-01' and birth_date >= '1970-01-01' then
			set age_cat = 'Mid Age Male';
		else
			set age_cat = 'Elder Male';
		end if;
	else
		if birth_date > '2005-01-01' then
			set age_cat = 'Young Female';
		elseif birth_date < '2005-01-01' and birth_date >= '1985-01-01' then
			set age_cat = 'Adult Female';
		elseif birth_date < '1985-01-01' and birth_date >= '1970-01-01' then
			set age_cat = 'Mid Age Female';
		else
			set age_cat = 'Elder Female';
		end if;
	end if;

		return age_cat;
end $$

delimiter ;

/* 5 */
explain
select companyName, productName, description,
if(maxPrice>1000, 'pricey', 'affordable') as price_cat
from medicine
where maxPrice>1000 or maxPrice<5
order by maxPrice desc;