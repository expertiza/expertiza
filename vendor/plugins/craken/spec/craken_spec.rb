RAILS_ROOT = "foo/bar/baz"
RAILS_ENV = "test"
ENV['app_name'] = "craken_test"
ENV['raketab_rails_env'] = "test"
ENV['rake_exe'] = '/usr/bin/bundle exec rake'

require File.dirname(__FILE__) + "/../lib/craken"
require 'fileutils'

describe Craken do

  include Craken

  describe "load_and_strip" do

    it "should load the user's installed crontab" do
      # figured out how to do this from here:
      # http://jakescruggs.blogspot.com/2007/11/mocking-backticks-and-other-kernel.html
      self.should_receive(:`).with(/crontab -l/).and_return('')
      load_and_strip
    end

    it "should strip out preinstalled raketab commands associated with the project" do

crontab = <<EOS
### craken_test test raketab start
this is a test
one more line
### craken_test test raketab end
EOS

      self.should_receive(:`).with(/crontab -l/).and_return(crontab)
      load_and_strip.should be_empty
    end

    it "should not strip out preinstalled raketab commands not associated with the project" do

crontab = <<EOS
1 2 3 4 5 blah blah
### craken_test test raketab start
this is a test
one more line
### craken_test test raketab end
6 7 8 9 10 foo bar
EOS

      self.should_receive(:`).with(/crontab -l/).and_return(crontab)
      load_and_strip.should == "1 2 3 4 5 blah blah\n6 7 8 9 10 foo bar\n"
    end
  end

  describe "append_tasks" do
    before(:each) do
      @crontab = "1 2 3 4 5 blah blah\n6 7 8 9 10 foo bar\n"
    end

    it "should add comments to the beginning and end of the rake tasks it adds to crontab" do
      raketab = "0 1 0 0 0 foo:bar"
      cron = append_tasks(@crontab, raketab)
      cron.should match(/### craken_test test raketab start\n0 1 0 0 0 /)
      cron.should match(/### craken_test test raketab end\n$/)
    end

    it "should ignore comments in the raketab string" do
raketab = <<EOS
# comment to ignore
0 1 0 0 0 foo:bar
# another comment to ignore
EOS
      cron = append_tasks(@crontab, raketab)
      cron.should_not match(/# comment to ignore/)
      cron.should_not match(/# another comment to ignore/)
    end
    
    it "should not munge the eight crontab special strings" do
raketab = <<EOS
@reboot brush:teeth
@yearly dont_forget_girlfriends:birthday
@annually just_damn_remember:it
@monthly do_some:sport
@weekly get:stash
@daily take:shower
@midnight stop_working_on_os:projects
@hourly drink:water
EOS
      cron = append_tasks(@crontab, raketab)
      cron.should match(/@reboot (.*)/)
      cron.should match(/@yearly (.*)/)
      cron.should match(/@annually (.*)/)
      cron.should match(/@monthly (.*)/)
      cron.should match(/@weekly (.*)/)
      cron.should match(/@daily (.*)/)
      cron.should match(/@midnight (.*)/)
      cron.should match(/@hourly (.*)/)
    end

    it "should not munge the crontab time configuration" do
raketab = <<EOS
0 1 0 0 0 foo:bar
1,2,3,4,5,6 0 7,8 4 5 baz:blarg
EOS
      cron = append_tasks(@crontab, raketab)
      cron.should match(/0 1 0 0 0 [^\d]/)
      cron.should match(/1,2,3,4,5,6 0 7,8 4 5 [^\d]/)
    end

    it "should add a cd command, rake command and environment variables" do
      raketab = "0 1 0 0 0 foo:bar"
      cron = append_tasks(@crontab, raketab)
      cron.should match(/0 1 0 0 0 cd #{Craken::DEPLOY_PATH} && #{Craken::RAKE_EXE} --silent RAILS_ENV=#{Craken::RAKETAB_RAILS_ENV} foo:bar/)
    end
    
    it "should use the rake command given via ENV['rake_exe']" do
      raketab = "0 1 0 0 0 foo:bar"
      cron = append_tasks(@crontab, raketab)
      cron.should include('/usr/bin/bundle exec rake')
    end

    it "should ignore additional data at the end of the configuration" do
      raketab = "0 1 0 0 0 foo:bar >> /tmp/foobar.log 2>&1"
      cron = append_tasks(@crontab, raketab)
      cron.should match(/0 1 0 0 0 cd #{Craken::DEPLOY_PATH} && #{Craken::RAKE_EXE} --silent RAILS_ENV=#{Craken::RAKETAB_RAILS_ENV} foo:bar >> \/tmp\/foobar.log 2>&1/)
    end
  end

  describe "install" do
    it "should install crontab by creating a temporary file, running crontab, then deleting the temp file" do
      crontab = "crontab"
      file_handle = mock("file handle")
      file_handle.should_receive(:write).with(crontab)
      File.should_receive(:open).with(/.crontab[0-9]*/, 'w').and_yield(file_handle)
      self.should_receive(:`).with(/crontab .crontab[0-9]*$/)
      FileUtils.should_receive(:rm).with(/.crontab[0-9]*/)
      install(crontab)
    end
  end

end
