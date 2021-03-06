require "rails_helper"

RSpec.describe Student::ProfilesController do
  it "sends a message to student's team to reconsider division on dob change" do
    Timecop.freeze(Division.cutoff_date - 1.day) do
      student = FactoryBot.create(
        :student,
        email: "student@testing.com",
        date_of_birth: 13.years.ago
      )
      team = FactoryBot.create(:team)
      TeamRosterManaging.add(team, student)

      expect(team.division_name).to eq("junior")

      sign_in(student)

      patch :update, params: {
        student_profile: {
          account_attributes: {
            id: student.account_id,
            date_of_birth: 15.years.ago,
          },
        }
      }

      expect(team.reload.division_name).to eq("senior")
    end
  end
end
