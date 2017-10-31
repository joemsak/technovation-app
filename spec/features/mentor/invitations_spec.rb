require "rails_helper"

RSpec.feature "Mentors and invitations" do
  scenario "A mentor accepts an invitation" do
    team = FactoryBot.create(:team)

    mentor = FactoryBot.create(:mentor)

    invite = FactoryBot.create(
      :mentor_invite,
      team: team,
      invitee: mentor,
      invitee_email: mentor.email
    )

    sign_in(mentor)
    visit mentor_mentor_invite_path(invite, mailer_token: mentor.mailer_token)

    click_button "Accept"

    expect(team.reload.mentors).to eq([mentor])
  end
end
