create database if not exists pg_development;
create database if not exists pg_test;

create user expertiza@localhost;

grant all on pg_development.* to expertiza@localhost;
grant all on pg_test.* to expertiza@localhost;
