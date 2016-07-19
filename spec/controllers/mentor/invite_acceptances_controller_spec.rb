require "rails_helper"

RSpec.describe Mentor::InviteAcceptancesController do
  describe "GET #show" do
    it "redirects to the mentor team page when the mentor account exists" do
      mentor = FactoryGirl.create(:mentor)
      invite = FactoryGirl.create(:team_member_invite, invitee_email: mentor.email)

      expect(get :show, id: invite.invite_token).to redirect_to mentor_team_path(invite.team)
    end
  end
end
