CURRENT_MAINTAINERS = %w(
  efg
  yangsong8
  Winbobob
  ferryxo
)

# ------------------------------------------------------------------------------
# Welcome message
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author
  if github.pr_title =~ /E[0-9]\{4\}/
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
# You've made changes to app, but didn't write any tests?
# ------------------------------------------------------------------------------
has_app_changes = !git.modified_files.grep(/app/).empty?
has_spec_changes = !git.modified_files.grep(/spec/).empty?

if has_app_changes && !has_spec_changes
  if Dir.exist?('spec')
    NO_TEST_MESSAGE =
      markdown <<-MARKDOWN
There are code changes, but no corresponding tests.
Please include tests if this PR introduces any modifications in behavior.
      MARKDOWN

    warn(NO_TEST_MESSAGE, sticky: true)
  else
    markdown <<-MARKDOWN
Thanks for the PR! This project lacks automated tests, which makes reviewing and approving it somewhat difficult.
Please make sure that your contribution has not broken backwards compatibility or introduced any risky changes.
    MARKDOWN
  end
end

# ------------------------------------------------------------------------------
# Your PR is too big (more than 500 LoC).
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
# Your course project PR is too small (less than 50 LoC).
# ------------------------------------------------------------------------------
if github.pr_title =~ /E[0-9]\{4\}/ and git.lines_of_code < 50
  SMALL_PR_MESSAGE = 
    markdown <<-MARKDOWN
Your pull request is less than 50 LoC.
If you are finished refactoring the code, please consider writing corresponding tests.
    MARKDOWN

  warn(SMALL_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Your PR touches too many files (more than 30 files).
# ------------------------------------------------------------------------------
if git.modified_files.size > 30
  BIG_PR_MESSAGE =
    markdown <<-MARKDOWN
Your pull request touches more than 30 files.
Please make sure you did not commit unnecessary changes, such as `node_modules`, `change logs`.
    MARKDOWN

  warn(BIG_PR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Your PR should not have too many duplicated commit messages.
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
# If a PR is a work in progress and it shouldn't be merged.
# ------------------------------------------------------------------------------
if github.pr_title.include? "WIP" or github.pr_title.include? "wip"
  WIP_MESSAGE =
    markdown <<-MARKDOWN
This pull request is classed as `Work in Progress`. It cannot be merged right now.
    MARKDOWN

  warn(WIP_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not contain "Todo".
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
# The PR should not include temp, tmp, cache file.
# ------------------------------------------------------------------------------
if git.modified_files =~ /.*temp.*/ or
   git.modified_files =~ /.*tmp.*/ or
   git.modified_files =~ /.*cache.*/
   TEMP_FILE_MESSAGE =
   markdown <<-MARKDOWN
You committed `temp`, `tmp` or `cache` files. Please remove them.
   MARKDOWN

  fail(TEMP_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not include skipped test cases.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "xdescribe" or
  github.pr_diff.include? "xit" or
  github.pr_diff.include? "pending" or
  github.pr_diff.include? "skip"
  TEST_SKIPPED_MESSAGE =
    markdown <<-MARKDOWN
There are one or more skipped/pending test cases in your pull request. Please fix them so they run.
    MARKDOWN

  warn(TEST_SKIPPED_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Most of time, the PR should not change README.md.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and !git.modified_files.grep(/\.md/).empty?
  MARKDOWN_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You changed MARKDOWN (`*.md`) documents; please double-check whether it is necessary to do so.
Alternatively, you can insert project-related content in the description field of the pull request.
    MARKDOWN
  warn(MARKDOWN_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should change db schema only if there is new db migrations.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  git.modified_files.include? "schema.rb" or
  git.modified_files.include? "schema.json"
  DB_SCHEMA_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You should commit changes to the DB schema only if you have created new DB migrations.
Please double check your code. If you did not aim to change the DB, please revert the DB schema changes.
    MARKDOWN
  warn(DB_SCHEMA_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should normally avoid using global variables and/or class variables.
# ------------------------------------------------------------------------------
if github.pr_diff =~ /\$[A-Za-z0-9_]+/ or github.pr_diff =~ /@@[A-Za-z0-9_]+/
  GLOBAL_CLASS_VARIABLE_MESSAGE =
    markdown <<-MARKDOWN
You are using global variables (`$`) or class variables (`@@`); please double-check whether this is necessary.
    MARKDOWN

  warn(GLOBAL_CLASS_VARIABLE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should avoid keeping debugging code.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "puts" or
   github.pr_diff.include? "print" or
   github.pr_diff.include? "binding.pry" or
   github.pr_diff.include? "debugger;" or
   github.pr_diff.include? "console.log"
   fail("You are including debug code in your pull request, please remove it.", sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying *.yml or *.yml.example file.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and !git.modified_files.grep(/\.yml/).empty?
  YAML_FILE_MESSAGE =
    markdown <<-MARKDOWN
You should not change YAML (`*.yml`) or example (`*.yml.example`) files; please revert these changes.
    MARKDOWN

  fail(YAML_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying vendor folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and !git.modified_files.grep(/vendor/).empty?
  VENDOR_MESSAGE =
    markdown <<-MARKDOWN
You are modifying `vendor` folder, please double-check whether it is necessary.
    MARKDOWN

  warn(VENDOR_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying rails_helper.rb or spec_helper.rb file.
# ------------------------------------------------------------------------------
if git.modified_files.include? "rails_helper.rb" or
  git.modified_files.include? "spec_helper.rb"
  TEST_HELPER_FILE_MESSAGE =
  markdown <<-MARKDOWN
You should not change `rails_helper.rb` or `spec_helper.rb` file; please revert these changes.
  MARKDOWN

  fail(TEST_HELPER_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying Gemfile, Gemfile.lock.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and
  git.modified_files.include? "Gemfile" or
  git.modified_files.include? "Gemfile.lock"
  GEMFILE_CHANGE_MESSAGE =
    markdown <<-MARKDOWN
You are modifying `Gemfile` or `Gemfile.lock`, please double check whether it is necessary.
You are suppose to add a new gem only if you have a very good reason. Try to use existing gems instead.
Please revert changes to `Gemfile.lock` made by the IDE.
    MARKDOWN
  warn(GEMFILE_CHANGE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The PR should not modifying /spec/factories/ folder.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and !git.modified_files.grep(/spec\/factories/).empty?
  FIXTURE_FILE_MESSAGE =
  markdown <<-MARKDOWN
You are modifying `/spec/factories/` folder; please double-check whether it is necessary.
  MARKDOWN

  warn(FIXTURE_FILE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# The rspec does not need to require helper files.
# ------------------------------------------------------------------------------
if github.pr_diff.include? "require 'spec_helper'" or
   github.pr_diff.include? "require \"spec_helper\"" or
   github.pr_diff.include? "require 'rails_helper'" or
   github.pr_diff.include? "require \"rails_helper\"" or
   github.pr_diff.include? "require 'factory_girl_rails'" or
   github.pr_diff.include? "require \"factory_girl_rails\""
  RSPEC_REQUIRE_MESSAGE =
    markdown <<-MARKDOWN
You are requiring different helper methods in RSpec tests.
There have already been included, you do not need to require them again. Please remove them.
    MARKDOWN
  warn(RSPEC_REQUIRE_MESSAGE, sticky: true)
end

# ------------------------------------------------------------------------------
# Unit tests and integration tests should avoid using "create" keyword.
# ------------------------------------------------------------------------------
git.modified_files.each do |file|
  next unless file =~ /spec\/models/ or file =~ /spec\/controllers/
  if git.diff_for_file(file).patch.include? "create"
    CREATE_MOCK_UP_OBJ_MESSAGE =
      markdown <<-MARKDOWN
Using `create` in unit tests or integration tests may be overkill. Try to use `build` or `double` instead.
      MARKDOWN

    warn(CREATE_MOCK_UP_OBJ_MESSAGE, sticky: true)
    break
  end
end

# ------------------------------------------------------------------------------
# RSpec tests should avoid using "should" keyword.
# ------------------------------------------------------------------------------
git.modified_files.each do |file|
  next unless file =~ /.*_spec\.rb$/
  if git.diff_for_file(file).patch.include? "should"
    NO_SHOULD_SYNTAX_MESSAGE =
      markdown <<-MARKDOWN
The `should` syntax is deprecated in RSpec 3. Please use `expect` syntax instead.
Even in test descriptions, please avoid using `should`.
      MARKDOWN

    warn(NO_SHOULD_SYNTAX_MESSAGE, sticky: true)
    break
  end
end

# ------------------------------------------------------------------------------
# RSpec tests should avoid committing text files for testing purposes.
# ------------------------------------------------------------------------------
unless git.modified_files.grep(/spec\/.*\.txt/).empty?
  warn("You committed text files for testing purposes; please double-check whether this is necessary", sticky: true)
end

# ------------------------------------------------------------------------------
# You should not change Dangerfile.
# ------------------------------------------------------------------------------
if !CURRENT_MAINTAINERS.include? github.pr_author and !git.modified_files.grep(/Dangerfile/).empty?
  fail("You should not change Dangerfile!", sticky: true)
end


# ------------------------------------------------------------------------------
# RSpec tests should avoid shallow tests.
# ------------------------------------------------------------------------------
git.modified_files.each do |file|
  next unless file =~ /.*_spec\.rb$/
  diff = git.diff_for_file(file).patch
  num_of_expectations_of_obj_on_page = diff.scan(/expect\(page\).to have/).count
  if num_of_expectations_of_obj_on_page >= 5
    EXPECT_ON_OBJ_ON_PAGE_MESSAGE =
      markdown <<-MARKDOWN
In your tests, there are many expectations of elements on pages, which is good.
To avoid `shallow tests` -- tests concentrating on irrelevant, unlikely-to-fail conditions -- please write more expectations to validate other things, such as database records, dynamically generated contents.
      MARKDOWN

    warn(EXPECT_ON_OBJ_ON_PAGE_MESSAGE, sticky: true)
    break
  end
end