
select
	*
from
	crime_scene_report
where
	type = 'murder'
	and date = 20180115
	and city = 'SQL City'

---RESULT
--Security footage shows that there were 2 witnesses.
--The first witness lives at the last house on "Northwestern Dr".
-- (possibly 14887	Morty Schapiro)
--The second witness, named Annabel, lives somewhere on "Franklin Ave".
-- (possibly 16371	Annabel Miller)

--Now we find the details from our witnessess

select
	p.id,
	p.name,
	p.address_street_name,
	p.ssn,
	dl.age,
	dl.gender
from
	person p
	left join drivers_license dl on p.license_id = dl.id
where
	p.id in (16371,14887)
--RESULT
--id		name			address_street_name	ssn	age	gender
--14887	Morty Schapiro	Northwestern Dr	111564949	64	male
--16371	Annabel Miller	Franklin Ave	318771143	35	female


-- Check for the interview transcripts
select
	*
from
	interview i
where
	person_id in (16371,14887)
--RESULT
-- I saw a man run out. He had a "Get Fit Now Gym" bag. The membership number
-- on the bag started with "48Z". The man got into a car with a plate that included "H42W"

-- I recognized the killer from my gym when I was working out
-- last week on January the 9th


-- Looking into membership database, we find 2 suspects with the matching
-- data according to the first transcript.
select
	*
from
	get_fit_now_member
where
	id like '%48Z%'
	and membership_status = 'gold'

---RESULT
--48Z7A	28819	Joe Germuska
--48Z55	67318	Jeremy Bowers

-- BOTH suspects checked in at the gym on Jan9th according to the gym records.

select
	p.id,
	p.name,
	ci.check_in_date,
	gm.membership_status,
	dl.gender,
	dl.plate_number
from
	get_fit_now_check_in ci
	join get_fit_now_member gm on ci.membership_id = gm.id
	join person p on gm.person_id = p.id
	left join drivers_license dl on p.license_id = dl.id
where 
	check_in_date = 20180109
	and p.id in (28819,67318)
-- RESULT
--id	name			check_in_date	membership_status	gender	plate_number
--28819	Joe Germuska	20180109		gold				null	null
--67318	Jeremy Bowers	20180109		gold				male	0H42W2

-- But it seems only Jeremy Bowers has a Car.
-- Coincidentally the plate number matches the description
-- our witness gave us (line 47)

-- BANG!

select
	*
from
	interview i
where
	person_id = 67318
-- RESULT
--I was hired by a woman with a lot of money.
--I don't know her name but I know she's around 5'5" (65") or 5'7" (67").
--She has red hair and she drives a Tesla Model S.
--I know that she attended the SQL Symphony Concert 3 times in December 2017.



-- Lets dive deeper
select
	p.id,
	p.name,
	p.license_id,
	i.annual_income,
	count(fe.event_id) as event_count
from
	person p
	join drivers_license dl on p.license_id = dl.id
	join income i on p.ssn = i.ssn
	join facebook_event_checkin fe on p.id = fe.person_id
where
	dl.gender = 'female'
	and dl.hair_color = 'red'
	and dl.height between 65 and 67
	and dl.car_make = 'Tesla'
	and fe.event_id = 1143 --SQL Symphony
group by
	p.id,
	p.name,
	p.license_id,
	i.annual_income
	
-- RESULT
--id	name				license_id	annual_income	event_count
--99716	Miranda Priestly	202298		310000			3
