select
	[source_id],[title],[make],[model],[power],[color],[capacity],[transmission],[fuel],[construction_year]
    ,[price_net],[price_gross],[added],[mileage],[url],[category] as original_category,
-- Logic/algorithm to assign correct engine_type to car rows in car-golf-dataset
	case
		when title like '%TSI%' then 'TSI'
		when title like '%TDI%' then 'TDI'
		when title like '%TDI-CR%' then 'TDI-CR'
		when title like '%e-Golf%' then 'e-Golf'
		when title like '%eTSI%' then 'eTSI'
		when title like '%GTD%' then 'GTD'
		when title like '%GTI%' then 'GTI'
		when title COLLATE Latin1_General_BIN LIKE '% R %' then 'R'
		when title like '%TSI eHybrid%' then 'TSI eHybrid'
		when title like '%TSI GTE%' then 'TSI GTE'
		when title like '%TSI Plug-In-Hybrid GTE%' then 'TSI Plug-In-Hybrid GTE'
		else NULL
	end as extracted_engine_type,
-- Logic/algorithm to assign correct category to car rows in car-golf-dataset
	case 
			when category like '%Small Car%' or category like '%smallcar%' then 'Small Car'
			when category like '%Van%' or category like '%Minibus%' then 'Van/Minibus'
			when category like '%Estate%' then 'Estate Car'
			when category like '%Cabrio%' or category like '%Roadster%' then 'Cabriolet/Roadster'
			when category like '%Sports%' then 'Sports Car'
			when category like '%Other%' then 'Other Car'
			when category like '%Off%' then 'Off-road Vehicle'
			when category like '%Saloon%' then 'Saloon'
			when category like '%Limousine%' then 'Limousine'
			else NULL
		end as corrected_category,
-- Flag for Transmission Mismatch
	case
		when transmission like '%auto%' and title like '%auto%' then 'Match'
		when transmission like '%manu%' and title like '%manu%' then 'Match'
		when transmission is NULL 
			and title not like '%dsg%'
			and title not like '%auto%'
			and title not like '%manu%'
		then 'Match'
		else 'Mismatch, Suspicious'
	end as transmission_mismatch,
-- Flag for Fuel Mismatch
	case
		when cast(fuel as varchar(max)) like '%petrol%' and title like '%petrol%' then 'Match'
		when cast(fuel as varchar(max)) like '%diesel%' and title like '%diesel%' then 'Match'
		when cast(fuel as varchar(max)) like '%hybrid%' and title like '%hybrid%' then 'Match'
		else 'Mismatch, Suspicious'
	end as fuel_mismatch,
-- Flag for Power Mismatch
	case
		when power = 0 and (title like '%kw%' or title like '%hp%' or title like '%ps%') then 'Mismatch in Power, Suspicious'
		else 'power not missing'
	end as 'missing_power',
--Flag for Invalid Power Value (power does not match expected values)
	case
		when power <> 0 and (power < 50 or power > 500) then 'Invalid Power, Suspicious'
		else 'power is valid'
	end as 'invalid_power'
from
	[car-golf-dataset]