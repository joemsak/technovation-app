namespace :cm do
  desc "Remove students from mentor list oops"
  task remove_students_from_mentor_list: :environment do
    auth = { api_key: ENV.fetch("CAMPAIGN_MONITOR_API_KEY") }

    StudentProfile.current.find_each do |profile|
      begin
        CreateSend::Subscriber.new(
          auth,
          ENV.fetch("MENTOR_LIST_ID"),
          profile.email
        ).delete

        puts "Removed #{profile.email}"
      rescue => e
        puts "PROBLEM REMOVING #{profile.email}"
        puts e.message
      end
    end
  end

  desc "Add students who are not subscribed"
  task add_students: :environment do
    auth = { api_key: ENV.fetch("CAMPAIGN_MONITOR_API_KEY") }

    StudentProfile.current.find_each do |profile|
      begin
        CreateSend::Subscriber.add(
          auth,
          ENV.fetch("STUDENT_LIST_ID"),
          profile.email,
          profile.full_name,
          [],
          false # resubscribe?
        )
        puts "Added #{profile.email}"
      rescue => e
        puts "PROBLEM ADDING #{profile.email}"
        puts e.message
      end
    end
  end

  desc "Add mentors who are not subscribed"
  task add_mentors: :environment do
    auth = { api_key: ENV.fetch("CAMPAIGN_MONITOR_API_KEY") }

    MentorProfile.current.find_each do |profile|
      begin
        CreateSend::Subscriber.add(
          auth,
          ENV.fetch("MENTOR_LIST_ID"),
          profile.email,
          profile.full_name,
          [
            { Key: 'City',
              Value: profile.city },
            { Key: 'State/Province',
              Value: profile.state_province },
            { Key: 'Country',
              Value: FriendlyCountry.(profile, prefix: false) },
          ],
          false # resubscribe?
        )
        puts "Added #{profile.email}"
      rescue => e
        puts "PROBLEM ADDING #{profile.email}"
        puts e.message
      end
    end
  end

  desc "Remove mentors not passing BG check or consent signed"
  task remove_unapproved_mentors: :environment do
    auth = { api_key: ENV.fetch("CAMPAIGN_MONITOR_API_KEY") }

    Account.joins(:mentor_profile, season_registrations: :season)
           .includes(:background_check, :consent_waiver)
           .references(:background_checks, :consent_waivers)
           .where("consent_waivers.id IS NULL OR (accounts.country = ? AND background_checks.id IS NULL)", "US")
           .pluck(:email).each do |email|
      begin
        CreateSend::Subscriber.new(auth, ENV.fetch("MENTOR_LIST_ID"), email).delete
        puts "Removed #{email}"
      rescue => e
        puts "PROBLEM REMOVING #{email}"
        puts e.message
      end
    end
  end

  desc "Remove judges who have not signed the waiver"
  task remove_unconsenting_judges: :environment do
    auth = { api_key: ENV.fetch("CAMPAIGN_MONITOR_API_KEY") }

    Account.joins(:judge_profile)
           .includes(:consent_waiver)
           .references(:consent_waivers)
           .where("consent_waivers.id IS NULL")
           .pluck(:email).each do |email|
      begin
        CreateSend::Subscriber.new(
          auth,
          ENV.fetch("JUDGE_LIST_ID"),
          email
        ).delete

        puts "Removed #{email}"
      rescue => e
        puts "PROBLEM REMOVING #{email}"
        puts e.message
      end
    end
  end

  desc "Add judges who have signed the waiver"
  task add_consenting_judges: :environment do
    auth = { api_key: ENV.fetch("CAMPAIGN_MONITOR_API_KEY") }

    Account.joins(:judge_profile, :consent_waiver).each do |a|
      begin
        CreateSend::Subscriber.add(
          auth,
          ENV.fetch("JUDGE_LIST_ID"),
          a.email,
          a.full_name,
          [{ Key: 'City', Value: a.city },
           { Key: 'State/Province', Value: a.state_province },
           { Key: 'Country', Value: FriendlyCountry.(a) }],
          false # resubscribe?
        )
        puts "Added #{a.email}"
      rescue => e
        puts "PROBLEM ADDING #{a.email}"
        puts e.message
      end
    end
  end
end
