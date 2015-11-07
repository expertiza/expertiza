# Expertiza
Expertiza is a web application where students can submit and peer-review learning objects (articles, code, web sites, etc). It is used in select courses at NC State and by professors at several other colleges and universities.

***

This repository contains information related to the Assignment E1574: Feature test for assignment submission by student.

This repository _is not_ the original repository for Expertiza. Here is the link to the original repository:
* [Original Repository](https://github.com/expertiza/expertiza)


## For the reviewer
### Overview of the Assignment
Feature test for assignment submission by student mocks the steps required in assignment submission on Expertiza. After the assignment is created by the instructor, the student can submit the assignment by taking the following steps:
* Login
* Select the assignment
* Select "Your Work"
* Upload the link or file

The goal is to test these steps using rspec and capybara.

### Running the Feature Test
To run the feature test, follow the steps
* Clone this repository in a new directory: 
```
git clone https://github.com/shrenujgandhi/expertiza.git
```
* Create database
```
cd expertiza
rake db:create:all 
```
* Import database
```
$ cd Downloads
$ mysql -u root -p expertiza_development < expertiza_scrubbed_2015_08_14.sql
password
```
* Migrate database
```
$ cd expertiza
$ rake db:migrate
```
* Run feature test
```
$ rspec spec/features/student_submission_spec.rb
```

## Attribution
This repository was constructed by [Shrenuj Gandhi](https://github.com/shrenujgandhi), [Kunal Bhandari](https://github.com/kunalb6), and [Bharghav Jhaveri](
https://github.com/BhargavJhaveri) under the guidance of [Yatish Mehta](https://github.com/yatish27). Thanks to [Abhishek Lingwal](https://github.com/imabhishekl) and [Glen Menezes](https://github.com/gmeneze) for their assistance in generating assignments using capybara script.
