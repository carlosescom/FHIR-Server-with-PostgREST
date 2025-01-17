drop function if exists r_slots;

create or replace function r_slots(
	schedule_actor_id text
)
returns table(
	slot_id text,
	slot_start text,
	slot_end text,
	slot_status text
)
as $$
	select
		resource ->> 'id',
		resource ->> 'start',
		resource ->> 'end',
		resource ->> 'status'
	from slot
	where(
		resource #>> '{schedule,id}' in(
			select
				resource ->> 'id'
			from schedule,
				jsonb_array_elements(resource -> 'actor') actor
			where(
				actor ->> 'id' = schedule_actor_id
			)
		)
	);
$$ language sql;