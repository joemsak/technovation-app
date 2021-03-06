require "rails_helper"

RSpec.feature "Manage admin accounts" do
  scenario "invite a new admin to signup via email" do
    ActionMailer::Base.deliveries.clear

    sign_in(:admin)

    click_link "Admins"
    click_link "Setup a new admin"

    fill_in "First name", with: "Joe"
    fill_in "Last name", with: "Sak"
    fill_in "Email", with: "joe@iridescentlearning.org"

    expect {
      click_button "Invite"
    }.to change {
      Account.temporary_password.count
    }.from(0).to(1)
    .and change {
      ActionMailer::Base.deliveries.count
    }.from(0).to(1)

    new_admin = Account.temporary_password.last
    visit admin_signup_path(token: new_admin.admin_invitation_token)

    password = SecureRandom.hex(10)
    fill_in "Password", with: password

    click_button "Save"

    expect(current_path).to eq(admin_dashboard_path)

    click_link "Logout"

    visit signin_path

    fill_in "Email", with: "joe@iridescentlearning.org"
    fill_in "Password", with: password

    click_button "Sign in"

    expect(current_path).to eq(admin_dashboard_path)
  end
end