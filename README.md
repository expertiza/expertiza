Expertiza
=========

<<<<<<< HEAD
[![Build Status](https://travis-ci.org/expertiza/expertiza.png?branch=rails4)](https://travis-ci.org/expertiza/expertiza)
[![Code Climate](https://codeclimate.com/github/expertiza/expertiza.png)](https://codeclimate.com/github/expertiza/expertiza)
[![Coverage Status](https://coveralls.io/repos/expertiza/expertiza/badge.png?branch=rails4)](https://coveralls.io/r/expertiza/expertiza?branch=rails4)

###E1510. Fix Instructor Login Performance Issue
###Problem description
Currently when an Instructor logs into Expertiza,there a lot of select* from assignments queries being fired on database which would have an adverse effect on performance.
Analyze and reduce the number of select queries executed to improve the performance.
####Screenshot of console when Instructor logs in
<img align=left src="https://github.com/fwu8/expertiza/blob/master/photo/before_modify.png" style="float:left;with:100px;height:300px">
There are six select assignment queries after load _row_header.html.erb
###Use [Query Reviewer](https://github.com/nesquena/query_reviewer) to trace the queries

<img align=left src="https://github.com/fwu8/expertiza/blob/master/photo/query_reviewer.png" style="float:left;with:100px;height:300px">
We use Query Reviewer to trace the queries and found the where the queries are executed multiply times.

###What we do to fix it
* We found that the _row_header.html.erb file called methods form assignment_node.rb, which executed the select assignment queries multiple times, which are redundant.
After modifying the methods,the performance is highly improved.
* We also modified _assignments_actions.html.erb to further improve the performance.

####Screenshot of console when Instructor logs in after modification
<img align=left src="https://github.com/fwu8/expertiza/blob/master/photo/after_modify.png" style="float:left;with:100px;height:300px">

As shown above,there is only one query executed after _row_header.html.erb is loaded.
The time consumption has been reduced dramatically.(Dropped from 900+ms to 200+ms)