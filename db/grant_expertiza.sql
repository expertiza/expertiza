drop database if exists expertiza_development;
drop database if exists expertiza_test;

create database if not exists expertiza_development CHARACTER SET = 'utf8' COLLATE = 'utf8_unicode_ci';
create database if not exists expertiza_test CHARACTER SET = 'utf8' COLLATE = 'utf8_unicode_ci';

create user expertiza@localhost;

grant all on expertiza_development.* to expertiza@localhost;
grant all on expertiza_test.* to expertiza@localhost;
