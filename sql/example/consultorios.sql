drop function if exists consultorios;

create or replace function consultorios(
    chargeitem_note text,
	organization_id text,
	specialty_code text,
	practitioner_name_string text,
	location_name_string text
)
returns table(
    practitionerrole_id text,
    practitioner_name text,
    practitionerrole_availableTime jsonb,
    practitionerrole_location text,
	practitionerrole_telecom jsonb,
	chargeitem_code jsonb,
	chargeitem_base_appointment_price jsonb
)
as $$
begin
	if location_name_string = '' then
		raise notice 'empty location_name_string';
	else
		return query select
			practitionerrole.resource ->> 'id',
			practitionerrole.resource #>> '{practitioner,display}',
			practitionerrole.resource #> '{availableTime}',
			practitionerrole.resource #>> '{location,0,id}',
			practitionerrole.resource #> '{telecom}',
			chargeitem.resource #> '{code,coding}',
			chargeitem.resource #> '{priceOverride}'
		from practitionerrole inner join chargeitem
		on practitionerrole.resource #>> '{id}' = chargeitem.resource #>> '{performer,0,actor,id}'
		where(
			chargeitem.resource @> ('{"note":[{"text":"'||chargeitem_note||'"}]}')::jsonb
			and
			practitionerrole.resource @> ('{"organization":{"id":"'||organization_id||'"}}')::jsonb
			and
			practitionerrole.resource @> ('{"specialty":[{"coding":[{"code":"'||specialty_code||'"}]}]}')::jsonb
			and
			practitionerrole.resource #>> '{practitioner,display}' @@ practitioner_name_string
			and
			practitionerrole.resource #>> '{location,0,display}' @@ location_name_string
		);
	end if;
end;
$$ language 'plpgsql';