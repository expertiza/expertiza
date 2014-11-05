Expertiza
=========

User:
* Admin: user2
* Teacher: user6
* Student: userxxxx
* Password: password



==========
###What needs to be done:
* checkbox “Review rubrics vary by round” should be added to the “General” tab in the view of creating/editing assignment
* 4 checkboxes “Review rubrics vary by round” should be added on the “rubrics” tab
* There should be a editable “deadline name” for each due date on “due date” panel if this type of review is specified to be “varying by rounds” in the “rubrics” tab.
* Another “description URL” text box should be editable when this type of review is specified to be “varying by rounds” in the “rubrics” tab.
* A drop-down box which help instructor to select review rubric should be added for a review round when this type of review is specified to be “varying by rounds” in the “rubrics” tab  (the input should be recorded in assignments_questionnaires table)


###Our Changes:
* A checkbox "Review rubric vary by round" has been added to the "General" tab in the view of creating/editing assignment as    well as "rubric" tab.By selecting this box, you can specify if the assignment reiview varies by round or not.
* Under "rubric" tab, there are four types of rubric: review, metareview, author feedback and teammate review. The instructor   can set how many review he/she wants to use for the assignment by setting the round under "due date" tab
* Under "due date" panel, "deadline name" textfield has been added. 
* Under "due date" panel, "description URL" textfield has been added. 

==========
###How to build our environment

1. Install JDK: 
    sudo apt-get install openjdk-6-jdk

2. Install java: 
http://www.mkyong.com/java/how-to-install-java-jdk-on-ubuntu-linux/

1. Install ruby 1.8.7
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
