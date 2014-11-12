Expertiza
=========

User:
* Admin: user2
* Teacher: user6
* Student: userxxxx
* Password: password



==========
###Project Description:
Classes involved:controllers/assignment_controller.rb (488 lines)
views/assignment/edit.html.erb (55 lines) in production branch (not in master branch)

What needs to be done:
* A checkbox “Review rubrics vary by round” should be added to the “Rubric” tab in the view of creating/editing assignment. No corresponding field in “assignments” table is necessary. We can tell if this checkbox should be checked by checking “assignments_questionnaires” table by current assignment_id. If there is no record with a non-null value in “used_in_round” field, this assignment is not using this feature and the checkbox should not be checked. (if one assignment has 2 rounds but they are using the same set of rubrics, for each type of rubric there should be only one entry with “used_in_round” field null)R
* There should be a editable “deadline name” for each due date on “due date” panel if this type of review is specified to be “varying by rounds” in the “rubrics” tab (the input should be recorded in deadline_name field in due_dates table)
* Another “description URL” text box should be editable when this type of review is specified to be “varying by rounds” in the “rubrics” tab (the input should be recorded in description_url field in due_dates table)
* The "deadline_name" and "description URL" could be hidden when you change the status of the checkbox in Due_Date tab
* A drop-down box which help instructor to select review rubric should be added for a review round when this type of review is specified to be “varying by rounds” in the “rubrics” tab (the input should be recorded in assignments_questionnaires table)
* There are no tests for the code. Create appropriate functional and integration tests.

==========
###Different Environment for this branch!!! (especially different from Rails4)

* Ruby: 1.8.7
* Rails: 2.3.15
* Java: 1.6
* Openjdk: 6.0
* Database: expertiza_scrubbed_2014_03_14.sql

Installation tips:
1. Install JDK: 
    sudo apt-get install openjdk-6-jdk

2. Install java: 
http://www.mkyong.com/java/how-to-install-java-jdk-on-ubuntu-linux/

3. Install ruby 1.8.7
  1. https://gorails.com/setup/ubuntu/14.04
  2. sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
  3. curl -L https://get.rvm.io | bash -s stable
  4. source ~/.rvm/scripts/rvm
  5. echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
  6. rvm install 1.8.7
  7. rvm use 1.8.7 --default
  8. ruby -v


4. Bundle install
  *  Error: gem install linecache -v ‘0.46’ fails
  Solution:debug19
  *  Error:mongrel 1.1.5
  Solution:change gemfile: gem "mongrel", ">= 1.2.0.pre2"
  *  Error: mysql2
  Solution: comment mysql2 in gemfile.lock

5. sudo apt-get install libmysql-ruby libmysqlclient-dev

6. gem install mysql2
  1. sudo apt-get install mysql-server mysql-client 
  2. mysql -uroot -proot
  3. mysql > show databases;
  4. create database db_development
  5. mysql -h localhost -uroot -proot pg_development< /home/xshao2/Desktop/expertiza_scrubbed_2014_03_14.sql

6. rake db:migrate
 * Error:undefined method `source_index' for Gem:Module
  Solution:gem update --system 1.8.25
 * Error:rake development database is not configured
  Solution: config/database.yml :

7. Set config/database.yml file:
  development:
  adapter: mysql
  database: pg_developmen
  username: root
  password:
  host: localhost

8. Import database file:
  mysql -h localhost -uroot -proot pg_development< /home/xshao2/Desktop/expertiza_scrubbed_2014_03_14.sql

==========
###Main changes
* Change "Rubric" Tab of Assignment
* Change "Due_date" Tab of Assignment
* Make slight changes to existing methods/codes

More detailed changes could be seen in Github files changes.

More detailed description on this project, please visit our wiki page: http://wiki.expertiza.ncsu.edu/index.php/CSC/ECE_517_Fall_2014/OSS_E1450_cxm#Exampls
