
  Scenario1: Instructor can set the review rubric varies by round
      Given an instructor named "user6"
      And I am logged in as "user6" 
      @instructor
      @manage_assignments

      When I move to the "Assignments" page
      And I click the "edit" link for "Week 4 wiki"
      And I check "Review rubric varies by round?"
      And I fill in "2014,11,10" for "Round1 Submission"
      And I fill in "2014,11,30" for "Round1 Review"
      And I fill in "2014,12,20" for "Round2 Submission"
      And I fill in "2014,12,22" for "Round2:Review"
      And I use Review Round1 named "update_wiki"
      And I use Review Round2"named "rubric1"
      Then I press "Save"

@wip
Scenario2: Student should see the review rubric for 1st round
  Given I am logged in as a user13
  And I move to the "Assignments" page
  And I click the "Week 4 wiki" link
  When I click the "Others' work" link
  Then I should see "update_wiki"

Scenario3: Instructor then change the due date of Round 2, so that the student would see a different review rubric
      Given an instructor named "user6"
      And I am logged in as "user6" 
      @instructor
      @manage_assignments

      When I move to the "Assignments" page
      And I click the "edit" link for "Week 4 wiki"
      And I fill in "2014,10,10" for "Round1 Submission"
      And I fill in "2014,10,22" for "Round1 Review"
      And I fill in "2014,11,10" for "Round2 Submission"
      And I fill in "2014,12,23" for "Round2:Review"
      Then I press "Save"


@wip
Scenario4: Student should see the review rubric for 2st round, which is different from the 1st one
  Given I am logged in as a user13
  And I move to the "Assignments" page
  And I click the "Week 4 wiki" link
  When I click the "Others' work" link
  Then I should see "rubric1"
