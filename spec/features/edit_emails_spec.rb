require 'rails_helper'

describe 'should edit profile email options' do

  before(:each) do
    create(:assignment)
  end

  describe 'email address' do
    it 'should edit email address' do
      login_as("instructor6")
      visit('/profile/edit')
      expect(page).to have_current_path('/profile/edit')
      expect(page).to have_content("E-mail address")
      expect(page).to have_content("E-mail options")

      fill_in 'E-mail address', with: 'ychen75@ncsu.edu'
      expect(find_field('E-mail address').value).to eq 'ychen75@ncsu.edu'
    end
  end



  describe 'email preferences options'  do

    context 'When someone else reviews my work' do
      it "should check 'When someone else reviews my work' option" do
        login_as("instructor6")
        visit('/profile/edit')
        expect(page).to have_current_path('/profile/edit')
        expect(page).to have_content("E-mail address")
        expect(page).to have_content("E-mail options")

        find(:css, "#user_email_on_review").set(true)

        review_box = find('#user_email_on_review')
        expect(review_box).to be_checked
      end

      it "should uncheck 'When someone else reviews my work' option" do
        login_as "instructor6"
        visit '/profile/edit'
        expect(page).to have_current_path('/profile/edit')

        find(:css, "#user_email_on_review").set(false)

        review_box = find('#user_email_on_review')
        expect(review_box).not_to be_checked
      end
    end

    context 'When someone else submits work I am assigned to review' do
      it "should check 'When someone else submits work I am assigned to review' option" do
        login_as("instructor6")
        visit('/profile/edit')
        expect(page).to have_current_path('/profile/edit')
        expect(page).to have_content("E-mail address")
        expect(page).to have_content("E-mail options")

        find(:css, "#user_email_on_submission").set(true)

        review_box = find('#user_email_on_submission')
        expect(review_box).to be_checked
      end

      it "should uncheck 'When someone else submits work I am assigned to review' option" do
        login_as "instructor6"
        visit '/profile/edit'
        expect(page).to have_current_path('/profile/edit')

        find(:css, "#user_email_on_submission").set(false)

        review_box = find('#user_email_on_submission')
        expect(review_box).not_to be_checked
      end
    end

    context 'When someone else reviews one of my reviews (metareviews my work)' do
      it "should check 'When someone else reviews one of my reviews (metareviews my work)' option" do
        login_as("instructor6")
        visit('/profile/edit')
        expect(page).to have_current_path('/profile/edit')
        expect(page).to have_content("E-mail address")
        expect(page).to have_content("E-mail options")

        find(:css, "#user_email_on_review_of_review").set(true)

        review_box = find('#user_email_on_review_of_review')
        expect(review_box).to be_checked
      end

      it "should uncheck 'When someone else reviews one of my reviews (metareviews my work)' option" do
        login_as "instructor6"
        visit '/profile/edit'
        expect(page).to have_current_path('/profile/edit')

        find(:css, "#user_email_on_review_of_review").set(false)

        review_box = find('#user_email_on_review_of_review')
        expect(review_box).not_to be_checked
      end
    end

    context 'Send me copies of emails sent for assignments' do
      it "should check 'Send me copies of emails sent for assignments' option" do
        login_as("instructor6")
        visit('/profile/edit')
        expect(page).to have_current_path('/profile/edit')
        expect(page).to have_content("E-mail address")
        expect(page).to have_content("E-mail options")

        find("#user_copy_of_emails").set(true)

        review_box = find('#user_copy_of_emails')
        expect(review_box).to be_checked
      end

      it "should uncheck 'Send me copies of emails sent for assignments' option" do
        login_as "instructor6"
        visit '/profile/edit'
        expect(page).to have_current_path('/profile/edit')

        find(:css, "#user_copy_of_emails").set(true)

        review_box = find(:css, "#user_copy_of_emails")
        expect(review_box).not_to be_checked
      end
    end
  end
end
