describe "is able show search logs" do

  let(:admin) { build(:admin, id: 5) }
  let(:superadmin) { build(:superadmin, id: 1) }

    it "admin must be able to search logs" do
      user = admin
      stub_current_user(user, user.role.name, user.role)
      visit '/versions/search'
      fill_in 'start_time', with: (Time.now.in_time_zone - 1.day).strftime("%Y/%m/%d %H:%M")
      fill_in 'end_time', with: (Time.now.in_time_zone + 10.days).strftime("%Y/%m/%d %H:%M")
      click_button 'Search'
      expect(page).to have_css("#version_result")
    end

    it "super-admin must be able to search logs" do
      user = superadmin
      stub_current_user(user, user.role.name, user.role)
      visit '/versions/search'
      fill_in 'start_time', with: (Time.now.in_time_zone - 10.days).strftime("%Y/%m/%d %H:%M")
      fill_in 'end_time', with: (Time.now.in_time_zone + 10.days).strftime("%Y/%m/%d %H:%M")
      click_button 'Search'
      expect(page).to have_css("#version_result")
    end

end
