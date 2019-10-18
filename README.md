E1971. OSS project Finklestein: Instructors & Institutions
=========

**Team_4430:** 
lli46, rwu5, yzhu48

**Mentor** 
Carmen Bentley (cnaiken@ncsu.edu)

**What is does:** 
Models can have many associations. For example, a ‘role’ can have many ‘users’ and the reverse a ‘user’ belongs to a ‘role. One important association in the Expertiza system is that between instructors and the institutions to which they belong. This can be an important attribute to groups, restrict, and even validate user permissions.

**What’s wrong with it:** 
Currently, models that can be associated with an institution are provided a pre-populated selection scroll when being created. This list should be presented in alphabetical order, but this is not the case when creating a new course. Additionally, and more importantly, there is an issue of associating an institution with a new instructor that is not listed in the selection scroll.

**What needs to be done:**
* Fix Issue #987: The institution list should be sorted alphabetically.
* Fix Issue #964: Adding a new institution during creation of an instructor profile.
* Fix Issue #1188: Listing of instructors should show their institutions on the same line as their new feature.

