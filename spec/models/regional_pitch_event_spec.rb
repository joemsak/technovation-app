require "rails_helper"

RSpec.describe RegionalPitchEvent do
  it "triggers an updates on team submission average scores if unofficial is toggled" do
    team = FactoryGirl.create(:team)
    sub = FactoryGirl.create(:submission, :complete, team: team)

    live_judge = FactoryGirl.create(:judge_profile)
    virtual_judge = FactoryGirl.create(:judge_profile)

    rpe = RegionalPitchEvent.create!({
      name: "RPE",
      starts_at: Date.today,
      ends_at: Date.today + 1.day,
      division_ids: Division.senior.id,
      city: "City",
      venue_address: "123 Street St.",
    })

    team.regional_pitch_events << rpe
    team.save

    live_judge.regional_pitch_events << rpe
    live_judge.save

    live_judge.submission_scores.create!({
      team_submission: sub,
      sdg_alignment: 5,
      completed_at: Time.current
    })

    virtual_judge.submission_scores.create!({
      team_submission: sub,
      sdg_alignment: 2,
      completed_at: Time.current
    })

    # 10 points for completed technical checklist
    expect(sub.reload.average_score).to eq(15)

    rpe.update_attributes(unofficial: true)

    expect(sub.reload.average_score).to eq(12)

    rpe.update_attributes(unofficial: false)

    expect(sub.reload.average_score).to eq(15)
  end
end