drop function if exists r_appointments_by_serviceCategory;

create or replace function r_appointments_by_serviceCategory(
	schedule_service_category_code text
)
returns table(
	appointment_id text,
	appointment_start text,
	appointment_end text,
	appointment_specialty text,
	appointment_appointmentType text,
	appointment_reasonCode text,
	appointment_participant jsonb
)
as $$
	select
		resource ->> 'id',
		resource #>> '{requestedPeriod,0,start}',
		resource #>> '{requestedPeriod,0,end}',
		resource #>> '{specialty,0,coding,0,display}',
		resource #>> '{appointmentType,coding,0,display}',
		resource #>> '{reasonCode,0,coding,0,display}',
		resource -> 'participant'
	from appointment
	where(
		appointment.resource #>> '{slot,0,id}' in(
			select
				resource ->> 'id'
			from slot
			where(
				slot.resource #>> '{schedule,id}' in(
					select
						resource ->> 'id'
					from schedule
					where(
						schedule.resource @>
						('{"serviceCategory":[{"coding":[{"code":"'||schedule_service_category_code||'"}]}]}')::jsonb
					)
				)
			)
		)
	);
$$ language sql;