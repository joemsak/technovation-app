require "rails_helper"

RSpec.describe Admin::ParticipantsController do
  before do
    admin = FactoryGirl.create(:admin)
    sign_in(admin)
  end

  it "sends a message to student's team to reconsider division on dob change" do
    Timecop.freeze(Division.cutoff_date - 1.day) do
      student = FactoryGirl.create(
        :student,
        email: "student@testing.com",
        date_of_birth: 13.years.ago
      )
      team = FactoryGirl.create(:team)
      TeamRosterManaging.add(team, student)

      expect(team.division_name).to eq("junior")

      patch :update, params: {
        id: student.account_id,
        account: {
          date_of_birth: 15.years.ago,
        },
      }

      expect(team.reload.division_name).to eq("senior")
    end
  end

  %w{student mentor judge regional_ambassador}.each do |scope|
    it "updates #{scope} newsletters with a change to the email address" do
      profile = FactoryGirl.create(scope, email: "old@oldtime.com")

      allow(UpdateProfileOnEmailListJob).to receive(:perform_later)

      patch :update, params: {
        id: profile.account_id,
        account: {
          email: "new@email.com",
        },
      }

      expect(UpdateProfileOnEmailListJob).to have_received(:perform_later)
        .with(profile.account_id, "old@oldtime.com", "#{scope.upcase}_LIST_ID")
    end

    it "updates newsletters with a change to the address" do
      profile = FactoryGirl.create(scope)

      allow(UpdateProfileOnEmailListJob).to receive(:perform_later)

      patch :update, params: {
        id: profile.account_id,
        account: {
          city: "Los Angeles",
          state_province: "CA",
        },
      }

      expect(UpdateProfileOnEmailListJob).to have_received(:perform_later)
        .with(profile.account_id, profile.account.email, "#{scope.upcase}_LIST_ID")
    end

    it "updates #{scope} newsletters with changes to first name" do
      profile = FactoryGirl.create(scope)

      allow(UpdateProfileOnEmailListJob).to receive(:perform_later)

      patch :update, params: {
        id: profile.account_id,
        account: {
          first_name: "someone cool",
        },
      }

      expect(UpdateProfileOnEmailListJob).to have_received(:perform_later)
        .with(profile.account_id, profile.account.email, "#{scope.upcase}_LIST_ID")
    end

    it "updates #{scope} newsletters with changes to last name" do
      profile = FactoryGirl.create(scope)

      allow(UpdateProfileOnEmailListJob).to receive(:perform_later)

      patch :update, params: {
        id: profile.account_id,
        account: {
          last_name: "someone really cool",
        },
      }

      expect(UpdateProfileOnEmailListJob).to have_received(:perform_later)
        .with(profile.account_id, profile.account.email, "#{scope.upcase}_LIST_ID")
    end
  end
end