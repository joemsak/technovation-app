require "rails_helper"

RSpec.feature "Mentor creates a team" do
  scenario "Re-using a past team name" do
    SeasonToggles.team_building_enabled!

    mentor = FactoryGirl.create(:mentor, :geocoded)
    old_team = FactoryGirl.create(:team, name: "Awesomest Saucesests")
    old_team.update(seasons: [Season.current.year - 1])
    TeamRosterManaging.add(old_team, mentor)

    sign_in(mentor)

    within(".navigation") { click_link "My teams" }
    click_link "Register a new team"
    fill_in "Name", with: "Awesomest Saucesests"
    click_button I18n.t("views.application.create",
                        thing: I18n.t("models.team.class_name"))

    expect(page).to have_content("Your team has been created")
  end

  scenario "Re-using someone else's past team name" do
    SeasonToggles.team_building_enabled!

    mentor = FactoryGirl.create(:mentor)
    old_team = FactoryGirl.create(:team, name: "Awesomest Saucesests")
    old_team.update(seasons: [Season.current.year - 1])

    sign_in(mentor)

    within(".navigation") { click_link "My teams" }
    click_link "Register a new team"
    fill_in "Name", with: "Awesomest Saucesests"
    click_button I18n.t("views.application.create",
                        thing: I18n.t("models.team.class_name"))

    expect(page).to have_content("has already been taken")
  end
end