require 'will_paginate/array'

module SearchTeams
  def self.call(filter)
    teams = if filter.nearby.present?
              student_ids = StudentAccount.near(filter.nearby, 50).collect(&:id)
              mentor_ids = MentorAccount.near(filter.nearby, 50).collect(&:id)

              Team.current
                  .joins(:memberships)
                  .where("memberships.member_id IN (?)", student_ids + mentor_ids)
                  .uniq
            else
              Team.current
            end

    teams = case filter.spot_available
            when true
              teams.select { |t| t.spot_available? }
            else
              teams
            end

    teams = case filter.has_mentor
            when true
              teams.select { |t| t.mentors.any? }
            when false
              teams.select { |t| t.mentors.empty? }
            else
              teams
            end

    teams.paginate(page: filter.page)
  end
end
