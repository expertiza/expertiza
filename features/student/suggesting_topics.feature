Feature: Student suggesting topics while he can
  A student can suggest a topic for a individual Media Wiki assignment provided
  the assignment allows them to do so.

Scenario: Student logs in, opens the assignment & suggests a topic
  Given I am participating on a "Fringe_Event"
  And I am logged in as a "student2"
  And the assignment "Fringe_Event" allows me to suggest topics
  And I provide the Title & the Description on the following page
  And I click "Submit"
  Then the following page should emit the text "Thank you for your suggestion!"
