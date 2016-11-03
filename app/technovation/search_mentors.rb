module SearchMentors
  def self.call(filter)
    mentors = MentorProfile.where.not(id: filter.user.id)

    unless filter.text.blank?
      results = Account.search(
        query: {
          query_string: {
            query: "*#{filter.text}*"
          }
        },
        from: 0,
        size: 10_000,
      ).results
      mentors = mentors.where(id: results.flat_map { |r| r._source.id })
    end

    if filter.expertise_ids.any?
      mentors = mentors.by_expertise_ids(filter.expertise_ids)
    end

    if filter.nearby.present?
      miles = filter.nearby == "anywhere" ? 40_000 : 50
      nearby = filter.nearby == "anywhere" ? filter.user.address_details : filter.nearby

      mentors = mentors.near(nearby, miles).order("distance")
    end

    if filter.needs_team
      mentors = mentors.where("accounts.id NOT IN
        (SELECT DISTINCT(member_id) FROM memberships
                                    WHERE memberships.member_type = 'MentorProfile'
                                    AND memberships.joinable_type = 'Team'
                                    AND memberships.joinable_id IN

          (SELECT DISTINCT(id) FROM teams WHERE teams.id IN

            (SELECT DISTINCT(registerable_id) FROM season_registrations
                                              WHERE season_registrations.registerable_type = 'Team'
                                              AND season_registrations.season_id = ?)))", Season.current.id)
    end

    if filter.virtual_only
      mentors = mentors.virtual
    end

    mentors.searchable
  end
end
