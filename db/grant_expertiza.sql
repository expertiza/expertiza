create database pg_development;
create database pg_test;

create user expertiza@localhost;

grant all on pg_development.* to expertiza@localhost;
grant all on pg_test.* to expertiza@localhost;
