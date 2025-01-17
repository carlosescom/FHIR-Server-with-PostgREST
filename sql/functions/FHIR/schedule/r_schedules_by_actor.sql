drop function if exists r_schedules_by_actor;

create or replace function r_schedules_by_actor(
	actor_id text
)
returns table(
	schedule_id text,
	schedule_planning_horizon jsonb
)
as $$
	select
		resource ->> 'id',
		resource -> 'planningHorizon'
	from schedule
	where(
		to_timestamp(resource #>> '{planningHorizon,start}','YYYY-MM-DD HH:MI:SS') > CURRENT_TIMESTAMP
		and
		resource #>> '{actor,0,id}' = actor_id
	);
$$ language sql;