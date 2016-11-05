require "rails_helper"

RSpec.feature "Mentors leave their own team" do
  scenario "leave the team" do
    mentor = FactoryGirl.create(:mentor, :on_team)
    sign_in(mentor)

    click_link "My teams"
    click_link mentor.team_names.last

    click_link "Leave #{mentor.team_names.last}"
    expect(current_path).to eq(mentor_dashboard_path)

    click_link "My teams"
    expect(page).not_to have_link(Team.last.name)
  end
end
