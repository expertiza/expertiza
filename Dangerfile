CURRENT_MAINTAINERS = %w[
  efg
  Winbobob
  TheAkbar
].freeze

MODIFIED_FILES = git.modified_files + git.added_files

# ------------------------------------------------------------------------------
# 0. Welcome message
# ------------------------------------------------------------------------------
unless CURRENT_MAINTAINERS.include? github.pr_author
  if github.pr_title =~ /E[0-9]{4}/
    WELCOME_MESSAGE_COURSE_PROJECT =
      markdown <<-MARKDOWN
Thanks for the pull request, and welcome! :tada: The Expertiza team is excited to review your changes, and you should hear from us soon.

This repository is being automatically checked for code-quality issues using `Code Climate`.
You can see results for this analysis in the PR status below. Newly introduced issues should be fixed before a pull request is considered ready to review.

Also, please spend some time looking at the instructions at the top of your course project writeup.
If you have any questions, please send email to <a href="mailto:expertiza-support@lists.ncsu.edu">expertiza-support@lists.ncsu.edu</a>.
      MARKDOWN

    message(WELCOME_MESSAGE_COURSE_PROJECT)
  else
    WELCOME_MESSAGE =
      markdown <<-MARKDOWN
Thanks for the pull request, and welcome! :tada: The Expertiza team is excited to review your changes, and you should hear from us soon.

This repository is being automatically checked for code quality issues using `Code Climate`.
You can see results for this analysis in the PR status below. Newly introduced issues should be fixed before a pull request is considered ready to review.

If you have any questions, please send email to <a href="mailto:expertiza-support@lists.ncsu.edu">expertiza-support@lists.ncsu.edu</a>.
      MARKDOWN

    message(WELCOME_MESSAGE)
  end
end

# ------------------------------------------------------------------------------
# 1. Your pull request should not be too big (more than 500 LoC).
# ------------------------------------------------------------------------------
if git.lines_of_code > 500
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request is more than 500 LoC.
Please make sure you did not commit unnecessary changes, such as `schema.rb`, `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 2. Your pull request should not be too small (less than 50 LoC).
# ------------------------------------------------------------------------------
if github.pr_title =~ /E[0-9]{4}/ and git.lines_of_code < 50
  SMALL_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request is less than 50 LoC.
If you are finished refactoring the code, please consider writing corresponding tests.
    MARKDOWN

  warn(SMALL_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 3. Your pull request should not touch too many files (more than 30 files).
# ------------------------------------------------------------------------------
if MODIFIED_FILES.size > 30
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request touches more than 30 files.
Please make sure you did not commit unnecessary changes, such as `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 4. Your pull request should not have too many duplicated commit messages.
# ------------------------------------------------------------------------------
messages = git.commits.map(&:message)
if messages.size - messages.uniq.size >= 5
  DUP_COMMIT_MESSAGE =
    markdown <<-MARKDOWN
Your pull request has many duplicated commit messages. Please try to `squash` similar commits.
And using meaningful commit messages later.
    MARKDOWN

  warn(DUP_COMMIT_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 5. Your pull request is "work in progress" and it will not be merged.
# ------------------------------------------------------------------------------
if github.pr_title.include? "WIP" or github.pr_title.include? "wip"
  WIP_MESSAGE =
    markdown <<-MARKDOWN
This pull request is classed as `Work in Progress`. It cannot be merged right now.
    MARKDOWN

  warn(WIP_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 6. Your pull request should not contain "Todo" keyword.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "TODO" or
  github.pr_diff.include? "Todo" or
  github.pr_diff.include? "todo" or
  github.pr_diff.include? "toDo"
  TODO_MESSAGE =
    markdown <<-MARKDOWN
This pull request contains `TODO` task(s); please fix them.
    MARKDOWN

  warn(TODO_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 7. Your pull request should not include temp, tmp, cache file.
# ------------------------------------------------------------------------------
if git.added_files.grep(/.*temp.*/).any? or
   git.added_files.grep(/.*tmp.*/).any? or
   git.added_files.grep(/.*cache.*/).any?
  TEMP_FILE_MESSAGE =
    markdown <<-MARKDOWN
You committed `temp`, `tmp` or `cache` files. Please remove them.
    MARKDOWN

  fail(TEMP_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 8. Your pull request should avoid using global variables and/or class variables.
# ------------------------------------------------------------------------------
if github.pr_diff =~ /\$[A-Za-z0-9_]+/ or github.pr_diff =~ /@@[A-Za-z0-9_]+/
  GLOBAL_CLASS_VARIABLE_MESSAGE =
    markdown <<-MARKDOWN
You are using global variables (`$`) or class variables (`@@`); please double-check whether this is necessary.
    MARKDOWN

  warn(GLOBAL_CLASS_VARIABLE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 9. Your pull request should avoid keeping debugging code.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "puts " or
   github.pr_diff.include? "print " or
   github.pr_diff.include? "binding.pry" or
   github.pr_diff.include? "debugger;" or
   github.pr_diff.include? "console.log"
  fail("You are including debug code in your pull request, please remove it.", sticky: true)
end

# ------------------------------------------------------------------------------
# 10. You should write tests after making changes to the application.
# ------------------------------------------------------------------------------
if MODIFIED_FILES.grep(/app/).any? && MODIFIED_FILES.grep(/spec/).empty?
  NO_TEST_MESSAGE =
    markdown <<-MARKDOWN
There are code changes, but no corresponding tests.
Please include tests if this PR introduces any modifications in behavior.
    MARKDOWN

  warn(NO_TEST_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 11. Your pull request should not include skipped/pending/focused test cases.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /.*_spec\.rb$/
  diff = git.diff_for_file(file).patch
  if diff.include? "xdescribe" or
     diff.include? "xspecify" or
     diff.include? "xexample" or
     diff.include? "xit" or
     diff.include? "skip(" or
     diff.include? "skip " or
     diff.include? "pending(" or
     diff.include? "fdescribe" or
     diff.include? "fit"
    TEST_SKIPPED_MESSAGE =
      markdown <<-MARKDOWN
There are one or more skipped/pending/focused test cases in your pull request. Please fix them.
      MARKDOWN

    warn(TEST_SKIPPED_MESSAGE, sticky: true)
  end
end

# ------------------------------------------------------------------------------
# 12. Unit tests and integration tests should avoid using "create" keyword.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /spec\/models/ or file =~ /spec\/controllers/
  diff = git.diff_for_file(file).patch
  next unless diff.include? " create(" or diff.include? "{create("
  CREATE_MOCK_UP_OBJ_MESSAGE =
    markdown <<-MARKDOWN
  Using `create` in unit tests or integration tests may be overkill. Try to use `build` or `double` instead.
    MARKDOWN

  warn(CREATE_MOCK_UP_OBJ_MESSAGE, sticky: true)
  break
end

# ------------------------------------------------------------------------------
# 13. RSpec tests should avoid using "should" keyword.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /.*_spec\.rb$/
  next unless git.diff_for_file(file).patch.include? ".should"
  NO_SHOULD_SYNTAX_MESSAGE =
    markdown <<-MARKDOWN
The `should` syntax is deprecated in RSpec 3. Please use `expect` syntax instead.
Even in test descriptions, please avoid using `should`.
    MARKDOWN

  warn(NO_SHOULD_SYNTAX_MESSAGE, sticky: true)
  break
end

# ------------------------------------------------------------------------------
# 14. Your RSpec testing files do not need to require helper files (e.g., rails_helper.rb, spec_helper.rb). 
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  (MODIFIED_FILES.grep(/rails_helper\.rb/).any? or MODIFIED_FILES.grep(/spec_helper\.rb/).any?)
  TEST_HELPER_FILE_MESSAGE =
    markdown <<-MARKDOWN
You should not change `rails_helper.rb` or `spec_helper.rb` file; please revert these changes.
    MARKDOWN

  warn(TEST_HELPER_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 15. You should avoid committing text files for RSpec tests.
# ------------------------------------------------------------------------------
if MODIFIED_FILES.grep(/.*spec.*\.txt/).any? or MODIFIED_FILES.grep(/.*spec.*\.csv/).any?
  warn("You committed text files (`*.txt` or `*.csv`) for RSpec tests; please double-check whether this is necessary.", sticky: true)
end

# ------------------------------------------------------------------------------
# 16. Your pull request should not change or add *.md files unless you have a good reason.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.md/).any?
  MARKDOWN_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You changed MARKDOWN (`*.md`) documents; please double-check whether it is necessary to do so.
Alternatively, you can insert project-related content in the description field of the pull request.
    MARKDOWN

  warn(MARKDOWN_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 17. Your pull request should not change DB schema unless there is new DB migrations.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  (MODIFIED_FILES.grep(/schema\.rb/).any? or MODIFIED_FILES.grep(/schema\.json/).any?)
  DB_SCHEMA_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You should commit changes to the DB schema (`db/schema.rb`) only if you have created new DB migrations.
Please double check your code. If you did not aim to change the DB, please revert the DB schema changes.
    MARKDOWN

  warn(DB_SCHEMA_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 18. Your pull request should not modify *.yml or *.yml.example file.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.yml/).any?
  YAML_FILE_MESSAGE =
    markdown <<-MARKDOWN
You changed YAML (`*.yml`) or example (`*.yml.example`) files; please double-check whether this is necessary.
    MARKDOWN

  warn(YAML_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 19. Your pull request should not modify test-related helper files.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "require 'rspec'" or
   github.pr_diff.include? "require \"rspec\"" or
   github.pr_diff.include? "require 'spec_helper'" or
   github.pr_diff.include? "require \"spec_helper\"" or
   github.pr_diff.include? "require 'rails_helper'" or
   github.pr_diff.include? "require \"rails_helper\"" or
   github.pr_diff.include? "require 'test_helper'" or
   github.pr_diff.include? "require \"test_helper\"" or
   github.pr_diff.include? "require 'factory_girl_rails'" or
   github.pr_diff.include? "require \"factory_girl_rails\""
  RSPEC_REQUIRE_MESSAGE =
    markdown <<-MARKDOWN
You are requiring `rspec` gem or different helper methods in RSpec tests.
There have already been included, you do not need to require them again. Please remove them.
    MARKDOWN

  warn(RSPEC_REQUIRE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 20. Your pull request should not modify Gemfile, Gemfile.lock.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  (MODIFIED_FILES.include? "Gemfile" or MODIFIED_FILES.include? "Gemfile.lock")
  GEMFILE_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You are modifying `Gemfile` or `Gemfile.lock`, please double check whether it is necessary.
You are suppose to add a new gem only if you have a very good reason. Try to use existing gems instead.
Please revert changes to `Gemfile.lock` made by the IDE.
    MARKDOWN

  warn(GEMFILE_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 21. You should not change .bowerrc.
# ------------------------------------------------------------------------------
fail("You changed .bowerrc; please double-check whether this is necessary", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.bowerrc/).any?

# ------------------------------------------------------------------------------
# 22. You should not change .gitignore.
# ------------------------------------------------------------------------------
fail("You changed .gitignore; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.gitignore/).any?

# ------------------------------------------------------------------------------
# 23. You should not change .mention-bot.
# ------------------------------------------------------------------------------
fail("You changed .mention-bot; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.mention-bot/).any?

# ------------------------------------------------------------------------------
# 24. You should not change .rspec.
# ------------------------------------------------------------------------------
fail("You changed .rspec; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/\.rspec/).any?

# ------------------------------------------------------------------------------
# 25. You should not change Capfile.
# ------------------------------------------------------------------------------
fail("You changed Capfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Capfile/).any?

# ------------------------------------------------------------------------------
# 26. You should not change Dangerfile.
# ------------------------------------------------------------------------------
fail("You changed Dangerfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Dangerfile/).any?

# ------------------------------------------------------------------------------
# 27. You should not change Guardfile.
# ------------------------------------------------------------------------------
fail("You changed Guardfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Guardfile/).any?

# ------------------------------------------------------------------------------
# 28. You should not change LICENSE.
# ------------------------------------------------------------------------------
fail("You changed LICENSE; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/LICENSE/).any?

# ------------------------------------------------------------------------------
# 29. You should not change Procfile.
# ------------------------------------------------------------------------------
fail("You changed Procfile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Procfile/).any?

# ------------------------------------------------------------------------------
# 30. You should not change Rakefile.
# ------------------------------------------------------------------------------
fail("You changed Rakefile; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/Rakefile/).any?

# ------------------------------------------------------------------------------
# 31. You should not change bower.json.
# ------------------------------------------------------------------------------
fail("You changed bower.json; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/bower\.json/).any?

# ------------------------------------------------------------------------------
# 32. You should not change config.ru.
# ------------------------------------------------------------------------------
fail("You changed config.ru; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/config\.ru/).any?

# ------------------------------------------------------------------------------
# 33. You should not change setup.sh.
# ------------------------------------------------------------------------------
fail("You changed setup.sh; please double-check whether this is necessary.", sticky: true) if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/setup\.sh/).any?

# ------------------------------------------------------------------------------
# 34. The PR should not modify vendor folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/vendor/).any?
  VENDOR_MESSAGE =
    markdown <<-MARKDOWN
You modified `vendor` folder, please double-check whether it is necessary.
    MARKDOWN

  warn(VENDOR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# 35. You should not modify /spec/factories/ folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and MODIFIED_FILES.grep(/spec\/factories/).any?
  FIXTURE_FILE_MESSAGE =
    markdown <<-MARKDOWN
You modified `spec/factories/` folder; please double-check whether it is necessary.
    MARKDOWN

  warn(FIXTURE_FILE_MESSAGE, sticky: true)
end

# git.added_files
# ------------------------------------------------------------------------------
# 36. You should not commit .vscode folder to your pull request.
# ------------------------------------------------------------------------------
if git.added_files.grep(/\.vscode/).any?
  VSCODE_MESSAGE =
    markdown <<-MARKDOWN
You committed `.vscode/` folder; please remove it.
    MARKDOWN

  warn(VSCODE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# RSpec tests should avoid shallow tests
# 37. Not writing expectations for the tests.
# 38. Test expectations do not include matchers, such as comparisons (e.g.,equal(expected_value)),
#     the status change of objects (e.g.,change(object, :value).by(delta)), error handlings (e.g.,raise_error("message")).
# 39. In feature tests, expectations only focus on words appearance on the view(e.g.,expect(page).to have_content(word)),
#     and without otherevidence, such as the new creation of the object, new record in DB.
# ------------------------------------------------------------------------------
MODIFIED_FILES.each do |file|
  next unless file =~ /.*_spec\.rb$/
  diff = git.diff_for_file(file).patch
  num_of_tests = diff.scan(/\s*it\s['"]/).count
  num_of_expect_key_words = diff.scan(/\s*expect\s*\(/).count
  num_of_expectation_without_machers = diff.scan(/\s*expect\s*[({][0-9a-zA-Z._]*[)}]\s*$/).count
  num_of_expectations_on_page = diff.scan(/\s*expect\(page\).to have/).count
  if num_of_expect_key_words < num_of_tests
    NOT_WRITING_EXPECTATIONS_FOR_TESTS_MESSAGE =
      markdown <<-MARKDOWN
One or more of your tests do not have expectations.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please write at least one expectation for each test.
      MARKDOWN

    warn(EXPECT_ON_OBJ_ON_PAGE_MESSAGE, sticky: true)
    break
  elsif num_of_expectation_without_machers > 0
    EXPECTATION_WITHOUT_MATCHERS_MESSAGE =
      markdown <<-MARKDOWN
One or more of your test expectations do not have matchers.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please include matchers, such as comparisons (e.g., `equal(expected_value)`), the status change of objects (e.g., `change(object, :value).by(delta)`), error handlings (e.g., `raise_error("message")`).
      MARKDOWN

    warn(EXPECTATION_WITHOUT_MATCHERS_MESSAGE, sticky: true)
    break
  elsif num_of_expect_key_words - num_of_expectations_on_page < num_of_tests
    EXPECT_ON_OBJ_ON_PAGE_MESSAGE =
      markdown <<-MARKDOWN
In your tests, there are many expectations of elements on pages, which is good.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please write more expectations to validate other things, such as database records, dynamically generated contents.
      MARKDOWN

    warn(EXPECT_ON_OBJ_ON_PAGE_MESSAGE, sticky: true)
    break
  end
end
