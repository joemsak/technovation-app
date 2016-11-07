FactoryGirl.define do
  factory :student_profile, aliases: [:student, :student_account] do
    account

    school_name { "FactoryGirl High" }

    transient do
      geocoded "Chicago, IL"
      date_of_birth Date.today - 15.years
      email nil
      password nil
    end

    before(:create) do |s, e|
      unless s.parental_consent.present?
        s.build_parental_consent(FactoryGirl.attributes_for(:parental_consent))
      end

      attrs = FactoryGirl.attributes_for(:account)

      s.build_account(attrs.merge(
        geocoded: e.geocoded,
        date_of_birth: e.date_of_birth,
        email: e.email || attrs[:email],
        password: e.password || attrs[:password],
      ))

      s.account.build_honor_code_agreement(FactoryGirl.attributes_for(:honor_code_agreement))
    end

    trait :on_team do
      after(:create) do |s|
        team = FactoryGirl.create(:team, members_count: 0)
        FactoryGirl.create(:team_membership, member_type: "StudentProfile",
                                             member_id: s.id,
                                             joinable: team)
      end
    end

    trait :full_profile do
      parent_guardian_email "example@example.com"
      parent_guardian_name "Parenty McGee"
      school_name "My school"
    end
  end

  factory :mentor_profile, aliases: [:mentor, :mentor_account] do
    school_company_name { "FactoryGirl" }
    job_title { "Engineer" }
    bio "A complete bio"

    transient do
      first_name nil
      geocoded "Chicago, IL"
      country nil
      email nil
      password nil
    end

    before(:create) do |m, e|
      attrs = FactoryGirl.attributes_for(:account)

      m.build_account(attrs.merge(
        geocoded: e.geocoded,
        country: e.country || attrs[:country],
        first_name: e.first_name || attrs[:first_name],
        email: e.email || attrs[:email],
        password: e.password || attrs[:password],
      ))

      unless m.background_check.present?
        m.account.build_background_check(FactoryGirl.attributes_for(:background_check))
      end

      unless m.consent_signed?
        m.account.build_consent_waiver(FactoryGirl.attributes_for(:consent_waiver))
      end

      unless m.honor_code_signed?
        m.account.build_honor_code_agreement(FactoryGirl.attributes_for(:honor_code_agreement))
      end
    end

    trait :with_expertises do
      after(:create) do |m|
        2.times do
          FactoryGirl.create(:expertise, mentor_profile_ids: m.id)
        end
      end
    end

    trait :on_team do
      after(:create) do |m|
        team = FactoryGirl.create(:team)
        FactoryGirl.create(:team_membership, member_type: "MentorProfile",
                                             member_id: m.id,
                                             joinable: team)
      end
    end
  end

  factory :regional_ambassador_profile, aliases: [:ambassador, :regional_ambassador, :ambassador_account, :regional_ambassador_account] do
    organization_company_name { "FactoryGirl" }
    job_title { "Engineer" }
    ambassador_since_year { Time.current.year }
    bio "A complete bio"

    account

    transient do
      geocoded "Chicago, IL"
      country nil
      email nil
      password nil
    end

    before(:create) do |r, e|
      attrs = FactoryGirl.attributes_for(:account)

      r.build_account(attrs.merge(
        geocoded: e.geocoded,
        country: e.country || attrs[:country],
        email: e.email || attrs[:email],
        password: e.password || attrs[:password],
      ))

      unless r.background_check.present?
        r.account.build_background_check(FactoryGirl.attributes_for(:background_check))
      end
    end

    trait :approved do
      after(:create) do |m|
        m.approved!
      end
    end
  end

  factory :judge_profile, aliases: [:judge, :judge_account] do
    company_name { "FactoryGirl" }
    job_title { "Engineer" }
    association(:account)
  end
end
