FactoryBot.define do
  factory :account do
    sequence(:email) { |n| "account#{n}@example.com" }
    password { "secret1234" }
    email_confirmed_at { Time.current }

    date_of_birth { Date.today - 31.years }
    first_name { "Factory" }
    last_name { "Account" }

    city "Chicago"
    location_confirmed true

    after :create do |a|
      RegisterToCurrentSeasonJob.perform_now(a)
      a.update_column(:profile_image, "foo/bar/baz.png")

      unless a.student_profile.present? or a.consent_signed?
        a.create_consent_waiver(FactoryBot.attributes_for(:consent_waiver))
      end

      unless a.background_check.present?
        a.create_background_check!(FactoryBot.attributes_for(:background_check))
      end
    end
  end
end
