Feature: To check degree of Relevance
  In order to check the various methods of the class
  As an Administrator
  I want to check if the actual and expected values match.

 @one
  Scenario: Check actual v/s expected values
    Given Instance of the class is created
    When I compare 6 and "compare_vertices"
    Then It will return true
    When I compare 6 and "compare_edges_non_syntax_diff"
    Then It will return true
    When I compare 3 and "compare_edges_syntax_diff"
    Then It will return true
    When I compare 3 and "compare_edges_diff_type"
    Then It will return true
    When I compare 3 and "compare_SVO_edges"
    Then It will return true
    When I compare 3 and "compare_SVO_diff_syntax"
    Then It will return true


