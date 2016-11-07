require "rails_helper"

RSpec.feature "Register as a mentor" do
  before do
    page.driver.browser.set_cookie("signup_token=#{SignupAttempt.create!(email: "mentor@mentor.com", password: "secret1234", status: SignupAttempt.statuses[:active]).signup_token}")

    visit mentor_signup_path

    fill_in "First name", with: "Mentor"
    fill_in "Last name", with: "McGee"

    select_date Date.today - 31.years, from: "Date of birth"

    fill_in "Postal code -OR- City & State/Province", with: "Chicago, IL"

    fill_in "School or company name", with: "John Hughes High."
    fill_in "Job title", with: "Janitor / Man of the Year"

    click_button "Create Your Account"
  end

  scenario "Redirected to mentor dashboard" do
    expect(current_path).to eq(mentor_dashboard_path)
  end

  scenario "Address details saved" do
    expect(MentorProfile.last.address_details).to eq("Chicago, IL, United States")
  end
end
