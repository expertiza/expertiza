drop database if exists pg_development;
drop database if exists pg_test;
drop user expertiza@localhost;

create database if not exists pg_development CHARACTER SET = 'utf8' COLLATE = 'utf8_unicode_ci';
create database if not exists pg_test CHARACTER SET = 'utf8' COLLATE = 'utf8_unicode_ci';

create user expertiza@localhost;

grant all on pg_development.* to expertiza@localhost;
grant all on pg_test.* to expertiza@localhost;
