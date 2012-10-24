Topic : E614. Refactoring and Testing - grades

GIT HUB link : https://github.com/san2488/expertiza

E614. Refactoring and Testing - grades
	Class:
		helper/grades_helper.rb (208 lines)
		views/grades/_reviews.html.erb (181 lines)

	What it does: Manages students grades in Expertiza

	What needs to be done:

		The 'find_question_type' method appears to be doing a lot. Refactor the method by breaking it up into smaller methods.
		Refactor the ruby code in the partial '_reviews.html.erb' by moving portions of it into a method in the controller maybe?
		File grades_helper.rb contains duplicate lines of code.
		e.g. if is_view
  			view_output = "No Response"
  			if !score.comments.nil?
    			view_output = score.comments
 			end
		     end

	Refactor this file by removing this and other such instances of duplicate lines of code in the class.
	Look for any unused methods or variables in these files.
	Also apply other refactorings such as Rename variable, Rename method to give the variables and methods more meaningful names.
	Write unit tests for all the methods in the grades_helper class.

The changes made by us :

	helper/grades_helper.rb
		Removed the label method as it was not called from anywhere in the application.
		Refactored the find_question_type method to 'DRY'out the is_view functionality.
		Removed the UI rendering functionality from the find_question_type method and put it in a new method render_ui.

	views/grades/_reviews.html.erb
		Refactored common questionnaire code into a new partial view. This significantly reduces duplication of code in the _review partial view.

	/* nabajyoti put the test name here */
		Created unit test to test the grade_helper functionality. The tests check whether the correct partials are rendered or not.
