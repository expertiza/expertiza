## create a team t whose name is the username of this participant
insert into teams (name, parent_id) 
select distinct users.name, assignments.id 
from participants, assignments, users
where assignments.team_assignment = 0 
and participants.parent_id = assignments.id 
and participants.user_id = users.id;

## create a teams_users record with team name of t and username of the participant on team t.
insert into teams_users (team_id, user_id)
select distinct teams.id, participants.user_id
from participants, assignments, users, teams
where assignments.team_assignment = 0 
and participants.parent_id = assignments.id 
and participants.user_id = users.id 
and teams.parent_id = assignments.id 
and teams.parent_id = participants.parent_id 
and teams.name = users.name;

## if there is an entry in the signed_up_users table whose creator_id is p, then change the creator_id to t.
update signed_up_users, teams_users, teams, sign_up_topics, participants, assignments
set signed_up_users.creator_id = teams_users.team_id
where signed_up_users.creator_id = teams_users.user_id 
and signed_up_users.topic_id = sign_up_topics.id 
and teams_users.team_id = teams.id 
and teams.parent_id = participants.parent_id 
and participants.parent_id = sign_up_topics.assignment_id 
and participants.parent_id = assignments.id 
and assignments.team_assignment = 0 
and signed_up_users.creator_id <> teams_users.team_id;

## for each response_map whose reviewee_id is p, change it to t.
update participants, assignments, teams, teams_users, users, response_maps 
set response_maps.reviewee_id = teams.id
where teams.parent_id = participants.parent_id 
and teams.id = teams_users.team_id 
and teams_users.user_id = participants.user_id 
and participants.user_id = users.id 
and teams.name = users.name 
and participants.parent_id = assignments.id 
and assignments.team_assignment = 0 
and response_maps.reviewed_object_id = assignments.id 
and response_maps.reviewee_id = participants.id;

## Remove the team_assignment field from the assignments table.
update assignments
set team_assignment = 1
where team_assignment = 0;

#alternate script
alter table assignments
drop column team_assignment;
